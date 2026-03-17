function [y_mean,ss_total,ss_residual,r_squared] = fitExponentialDecayModel(data)
    % 带指数衰减的两段线性模型拟合函数
    

    % 提取x和y数据
    x = data(:, 2);  % 第二列是x值(3000-8000)
    y = data(:, 1);  % 第一列是y值
    
    % 定义带指数衰减的两段线性模型
    % 参数 p = [breakpoint, slope1, intercept1, slope2, intercept2, amplitude, decay_rate]
    model = @(p, x) ...
        (x <= p(1)) .* (p(2) * x + p(3)) + ...
        (x > p(1)) .* (p(4) * x + p(5) + p(6) * exp(-p(7) * (x - p(1))));
    
    % 初始参数猜测
    p0 = [
        5000,      % breakpoint - 分段点
        -0.00005,  % slope1 - 第一段斜率
        1.0,       % intercept1 - 第一段截距
        0.0001,    % slope2 - 第二段斜率
        -0.5,      % intercept2 - 第二段截距
        0.5,       % amplitude - 指数项幅度
        0.001      % decay_rate - 衰减率
    ];
    
    % 定义误差函数
    error_fun = @(p) sum((model(p, x) - y).^2);
    
    % 使用fminsearch进行参数估计
    options = optimset('Display', 'iter', 'MaxIter', 1000, 'MaxFunEvals', 5000);
    p_fit = fminsearch(error_fun, p0, options);
    
    % 计算拟合曲线
    x_fit = linspace(min(x), max(x), 1000);
    y_fit = model(p_fit, x_fit);
    
    % 计算R²值（拟合优度）
    y_mean = mean(y);
    ss_total = sum((y - y_mean).^2);
    ss_residual = sum((y - model(p_fit, x)).^2);
    r_squared = 1 - (ss_residual / ss_total);
    
    % 打印拟合结果
    fprintf('拟合结果 (带指数衰减的两段线性模型):\n');
    fprintf('分段点: 初始猜测 = %.2f, 拟合值 = %.2f\n', p0(1), p_fit(1));
    fprintf('第一段: 斜率 = %.6f, 截距 = %.4f --> 拟合: 斜率 = %.6f, 截距 = %.4f\n', ...
        p0(2), p0(3), p_fit(2), p_fit(3));
    fprintf('第二段: 斜率 = %.6f, 截距 = %.4f --> 拟合: 斜率 = %.6f, 截距 = %.4f\n', ...
        p0(4), p0(5), p_fit(4), p_fit(5));
    fprintf('指数项: 幅度 = %.4f, 衰减率 = %.6f --> 拟合: 幅度 = %.4f, 衰减率 = %.6f\n', ...
        p0(6), p0(7), p_fit(6), p_fit(7));
    fprintf('R² 值: %.4f\n', r_squared);
    
    % 绘制结果
    figure('Position', [100, 100, 1000, 800]);
    
    % 绘制数据点和拟合曲线
    subplot(2, 1, 1);
    plot(x, y, 'b.', 'MarkerSize', 12, 'DisplayName', '数据点');
    hold on;
    plot(x_fit, y_fit, 'r-', 'LineWidth', 2, 'DisplayName', '拟合曲线');
    
    % 标记分段点
    plot(p_fit(1), model(p_fit, p_fit(1)), 'mo', 'MarkerSize', 10, 'MarkerFaceColor', 'm', 'DisplayName', '拟合分段点');
    
    % 添加图例和标签
    legend('Location', 'best');
    title('带指数衰减的两段线性模型拟合结果');
    xlabel('X');
    ylabel('Y');
    grid on;
    
    % 绘制残差图
    subplot(2, 1, 2);
    residuals = y - model(p_fit, x);
    stem(x, residuals, 'filled', 'MarkerSize', 6);
    hold on;
    yline(0, 'k--', 'LineWidth', 1);
    title('拟合残差图');
    xlabel('X');
    ylabel('残差');
    grid on;
    
    % 显示拟合的函数表达式
    fprintf('\n拟合的函数表达式:\n');
    fprintf('当 x ≤ %.2f 时, y = %.6f * x + %.4f\n', p_fit(1), p_fit(2), p_fit(3));
    fprintf('当 x > %.2f 时, y = %.6f * x + %.4f + %.4f * exp(-%.6f * (x - %.2f))\n', ...
        p_fit(1), p_fit(4), p_fit(5), p_fit(6), p_fit(7), p_fit(1));
end