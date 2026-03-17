function [par, r, y] = splineModel(D_CCT, sec_num)
    % 输入数据预处理
    if sec_num == 2
        % 删除6500对应的行
        D_CCT(D_CCT(:,2) == 6500, :) = [];
    end

    xdata = D_CCT(:,2); % x数据
    ydata = D_CCT(:,1); % y数据

    % 根据sec_num选择不同的分段拟合模型
    if sec_num == 2
        % 两段拟合
        % 定义分段函数
        f = @(a, xdata) ...
            (xdata <= a(1)) .* (a(2) + a(3)*(xdata-a(1)) + a(4)*(xdata-a(1)).^2 + a(5)*(xdata-a(1)).^3) + ...
            (xdata > a(1)) .* (a(2) + a(3)*(a(1)-a(1)) + a(4)*(a(1)-a(1)).^2 + a(5)*(a(1)-a(1)).^3 + ...
                           a(6)*(xdata-a(1)) + a(7)*(xdata-a(1)).^2 + a(8)*(xdata-a(1)).^3);

        % 初始参数估计
        a0 = [mean(xdata), mean(ydata), 0, 0, 0, 0, 0, 0];
        lb = [min(xdata), -inf, -inf, -inf, -inf, -inf, -inf, -inf]; % 下界
        ub = [max(xdata), inf, inf, inf, inf, inf, inf, inf]; % 上界

    elseif sec_num == 3
        % 三段拟合
        % 定义分段函数
        f = @(a, xdata) ...
            (xdata <= a(1)) .* (a(3) + a(4)*(xdata-a(1)) + a(5)*(xdata-a(1)).^2 + a(6)*(xdata-a(1)).^3) + ...
            (xdata > a(1) & xdata <= a(2)) .* (a(3) + a(7)*(xdata-a(1)) + a(8)*(xdata-a(1)).^2 + a(9)*(xdata-a(1)).^3) + ...
            (xdata > a(2)) .* (a(3) + a(7)*(a(2)-a(1)) + a(8)*(a(2)-a(1)).^2 + a(9)*(a(2)-a(1)).^3 + ...
                           a(10)*(xdata-a(2)) + a(11)*(xdata-a(2)).^2 + a(12)*(xdata-a(2)).^3);

        % 初始参数估计
        a0 = [mean(xdata), mean(xdata), mean(ydata), 0, 0, 0, 0, 0, 0, 0, 0, 0];
        lb = [min(xdata), min(xdata), -inf, -inf, -inf, -inf, -inf, -inf, -inf, -inf, -inf, -inf]; % 下界
        ub = [max(xdata), max(xdata), inf, inf, inf, inf, inf, inf, inf, inf, inf, inf]; % 上界

    else
        error('sec_num must be 2 or 3');
    end

    % 拟合过程
    options = optimset('MaxFunEvals', 200000, 'Display', 'off');
    a = lsqcurvefit(f, a0, xdata, ydata, lb, ub, options);

    % 计算拟合值和相关系数
    y = f(a, xdata);
    r = corr(y, ydata);

    % 输出结果
    par = a;
    fprintf('Correlation coefficient is %.2f\n', r);

    % 绘制拟合结果（可选）
    figure;
    scatter(xdata, ydata, 'filled'); % 绘制原始数据点
    hold on;
    
    % 生成平滑的曲线
    x_fit = linspace(min(xdata), max(xdata), 1000); % 生成1000个点，覆盖xdata的范围
    y_fit = f(par, x_fit); % 根据拟合参数计算预测值
    
    % 绘制平滑曲线
    plot(x_fit, y_fit, 'r-', 'LineWidth', 2);
    
    % 添加标签和标题
    xlabel('xdata');
    ylabel('ydata');
    title('Fitting Result');
    legend('Data', 'Fitted Curve');
    hold off;
end