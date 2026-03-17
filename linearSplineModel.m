function [par, r, y] = linearSplineModel(D_CCT)
    % 输入数据预处理
    D_CCT(D_CCT(:,2) == 6500, :) = [];
    xdata = D_CCT(:,2); % x数据
    ydata = D_CCT(:,1); % y数据

    % 确保数据是按xdata排序的
    [xdata, sortIdx] = sort(xdata);
    ydata = ydata(sortIdx);

    % 定义分段点

    % 定义三段线性模型
    f = @(a, xdata) ...
        (xdata <= a(1)) .* (a(3) + a(4)*(xdata - a(1))) + ...
        (xdata > a(1) & xdata <= a(2)) .* (a(3) + a(5)*(xdata - a(1))) + ...
        (xdata > a(2)) .* ((a(3) + a(5)*(a(2) - a(1))) + a(6)*(xdata - a(2)));

    % 初始参数估计

    a0 = [5000, 6500, 2529.226 , -0.0169531, -0.505693, 0.44648];

    % 参数上下界
    % lb = [5000, 6500, -inf, -inf, -inf, -inf]; % 下界
    % ub = [5000, 6500, inf, inf, inf, inf]; % 上界
    lb = [-inf, 6500-500, -inf, -inf, -inf, -inf]; % 下界
    ub = [inf, 6500+500, inf, inf, inf, inf]; % 上界

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
    % figure;
    % scatter(xdata, ydata, 'filled'); % 绘制原始数据点
    hold on;

    % 生成平滑的曲线
    x_fit = linspace(min(xdata), max(xdata), 1000); % 生成1000个点，覆盖xdata的范围
    y_fit = f(a, x_fit); % 根据拟合参数计算预测值

    % 绘制平滑曲线
    plot(x_fit, y_fit, 'r-', 'LineWidth', 2);

    % 添加标签和标题
    xlabel('xdata');
    ylabel('ydata');
    title('Fitting Result');
end