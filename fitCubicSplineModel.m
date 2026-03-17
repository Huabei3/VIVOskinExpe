function [y_mean, ss_total, ss_residual, r_squared] = fitCubicSplineModel(D_CCT)
    % 三次样条分段模型拟合函数
    % 输入: D_CCT - 包含两列的矩阵，第一列是x值，第二列是y值
    % 输出: y_mean - 原始数据的均值
    %       ss_total - 总离差平方和
    %       ss_residual - 残差平方和
    %       r_squared - 决定系数(R²)
    
    % 检查输入数据格式
    if ~ismatrix(D_CCT) || size(D_CCT, 2) ~= 2
        error('输入D_CCT必须是一个N×2的矩阵');
    end
    
    % 提取x和y数据
    x = D_CCT(:, 1);
    y = D_CCT(:, 2);
    
    % 检查数据长度
    if length(x) < 5
        error('数据点数量过少，无法进行三次样条拟合');
    end
    
    % 定义三次样条分段模型
    % 参数 p = [breakpoint, a1, b1, c1, d1, a2, b2, c2, d2]
    spline_model = @(p, x) ...
        (x <= p(1)) .* (p(2) + p(3)*(x-p(1)) + p(4)*(x-p(1)).^2 + p(5)*(x-p(1)).^3) + ...
        (x > p(1)) .* (p(6) + p(7)*(x-p(1)) + p(8)*(x-p(1)).^2 + p(9)*(x-p(1)).^3);
    
    % 初始参数猜测 (确保在断点处连续)
    % 根据数据范围估计断点（取中间值）
    x_min = min(x);
    x_max = max(x);
    breakpoint_guess = x_min + 0.5 * (x_max - x_min);
    
    % 鲁棒地计算断点处的y值作为a1和a2的初始猜测
    [~, idx_near_breakpoint] = min(abs(x - breakpoint_guess));
    a_guess = y(idx_near_breakpoint);
    
    % 估计左右两段的斜率作为b1和b2的初始猜测
    left_idx = x < breakpoint_guess;
    right_idx = x > breakpoint_guess;
    
    % 确保左右两段都有足够的数据点
    if sum(left_idx) < 3
        % 如果左边数据点不足，使用所有数据的斜率
        p_left = polyfit(x, y, 1);
        b1_guess = p_left(1);
    else
        p_left = polyfit(x(left_idx), y(left_idx), 1);
        b1_guess = p_left(1);  % 分离为两行以兼容旧版本MATLAB
    end
    
    if sum(right_idx) < 3
        % 如果右边数据点不足，使用所有数据的斜率
        p_right = polyfit(x, y, 1);
        b2_guess = p_right(1);
    else
        p_right = polyfit(x(right_idx), y(right_idx), 1);
        b2_guess = p_right(1);  % 分离为两行以兼容旧版本MATLAB
    end
    
    % 初始参数向量 [breakpoint, a1, b1, c1, d1, a2, b2, c2, d2]
    p0 = [
        breakpoint_guess,  % breakpoint
        a_guess,           % a1 (左段常数项)
        b1_guess,          % b1 (左段一次项系数)
        0,                 % c1 (左段二次项系数)
        0,                 % d1 (左段三次项系数)
        a_guess,           % a2 (右段常数项，等于a1以保证连续性)
        b2_guess,          % b2 (右段一次项系数)
        0,                 % c2 (右段二次项系数)
        0                  % d2 (右段三次项系数)
    ];
    
    % 定义误差函数
    error_fun = @(p) sum((spline_model(p, x) - y).^2);
    
    % 使用fminsearch进行参数估计
    options = optimset('Display', 'iter', 'MaxIter', 1000, 'MaxFunEvals', 5000);
    p_fit = fminsearch(error_fun, p0, options);
    
    % 计算拟合值
    y_fit = spline_model(p_fit, x);
    
    % 计算统计指标
    y_mean = mean(y);
    ss_total = sum((y - y_mean).^2);
    ss_residual = sum((y - y_fit).^2);
    r_squared = 1 - (ss_residual / ss_total);
    
    % 输出拟合参数（可选）
    fprintf('三次样条分段模型拟合结果:\n');
    fprintf('分段点: %.2f\n', p_fit(1));
    fprintf('左段: y = %.6f + %.6f*(x-%.2f) + %.6f*(x-%.2f)^2 + %.6f*(x-%.2f)^3\n', ...
        p_fit(2), p_fit(3), p_fit(1), p_fit(4), p_fit(1), p_fit(5), p_fit(1));
    fprintf('右段: y = %.6f + %.6f*(x-%.2f) + %.6f*(x-%.2f)^2 + %.6f*(x-%.2f)^3\n', ...
        p_fit(6), p_fit(7), p_fit(1), p_fit(8), p_fit(1), p_fit(9), p_fit(1));
    fprintf('统计指标: SS_total = %.6f, SS_residual = %.6f, R² = %.4f\n', ...
        ss_total, ss_residual, r_squared);
    
    % 绘制拟合结果（可选）
    figure('Position', [100, 100, 1000, 800]);
    
    % 绘制数据点和拟合曲线
    subplot(2, 1, 1);
    plot(x, y, 'b.', 'MarkerSize', 12, 'DisplayName', '数据点');
    hold on;
    
    x_fit = linspace(min(x), max(x), 1000);
    y_fit_smooth = spline_model(p_fit, x_fit);
    plot(x_fit, y_fit_smooth, 'r-', 'LineWidth', 2, 'DisplayName', '拟合曲线');
    
    % 标记分段点
    plot(p_fit(1), spline_model(p_fit, p_fit(1)), 'mo', 'MarkerSize', 10, 'MarkerFaceColor', 'm', 'DisplayName', '拟合分段点');
    
    legend('Location', 'best');
    title('三次样条分段模型拟合结果');
    xlabel('X');
    ylabel('Y');
    grid on;
    
    % 绘制残差图
    subplot(2, 1, 2);
    residuals = y - y_fit;
    stem(x, residuals, 'filled', 'MarkerSize', 6);
    hold on;
    yline(0, 'k--', 'LineWidth', 1);
    title('拟合残差图');
    xlabel('X');
    ylabel('残差');
    grid on;
end