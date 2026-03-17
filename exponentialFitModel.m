function [par, r, y] = exponentialFitModel(D_CCT)
    % 输入数据预处理
    D_CCT(D_CCT(:,2) == 6500, :) = [];
    xdata = D_CCT(:,2); % x数据
    ydata = D_CCT(:,1); % y数据

    % 确保数据是按xdata排序的
    [xdata, sortIdx] = sort(xdata);
    ydata = ydata(sortIdx);

    % 定义指数函数模型
    f = @(p, x) p(1) + p(2) * exp(-p(3) * x);

    % 初始参数估计
    % 为了提供合理的初始参数，可以尝试以下方法：
    % 1. p(1) 可以近似为 ydata 的最小值
    % 2. p(2) 可以近似为 ydata 的最大值与最小值的差
    % 3. p(3) 可以假设为一个较小的正数
    a0 = [min(ydata), max(ydata) - min(ydata), 0.01];

    % 参数上下界
    lb = [-Inf, -Inf, -Inf]; % 下界，确保 p(2) 和 p(3) 为非负
    ub = [Inf, Inf, Inf]; % 上界

    % 拟合过程
    options = optimset('MaxFunEvals', 200000, 'Display', 'off');
    par = lsqcurvefit(f, a0, xdata, ydata, lb, ub, options);

    % 计算拟合值和相关系数
    y = f(par, xdata);
    r = corr(y, ydata);

    % 输出结果
    fprintf('Fitted parameters: a = %.4f, b = %.4f, c = %.4f\n', par(1), par(2), par(3));
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
    title('Exponential Fitting Result');
    legend('Data', 'Fitted Curve');
    hold off;
end