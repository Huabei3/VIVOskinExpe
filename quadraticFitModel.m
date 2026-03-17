function [par, r, y] = quadraticFitModel(D_CCT)
    % 输入数据预处理
    xdata = D_CCT(:,2); % x数据
    ydata = D_CCT(:,1); % y数据

    % 确保数据是按xdata排序的
    [xdata, sortIdx] = sort(xdata);
    ydata = ydata(sortIdx);

    % 定义二次函数模型
    f = @(a, xdata) a(1) * xdata.^2 + a(2) * xdata + a(3);

    % 初始参数估计
    % 这里可以简单地使用线性拟合的斜率和截距作为初始估计
    p = polyfit(xdata, ydata, 2);
    a0 = [p(1), p(2), p(3)]; % 初始参数 [a, b, c]

    % 参数上下界
    lb = [-Inf, -Inf, -Inf]; % 下界
    ub = [Inf, Inf, Inf]; % 上界

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
    y_fit = f(a, x_fit); % 根据拟合参数计算预测值

    % 绘制平滑曲线
    plot(x_fit, y_fit, 'r-', 'LineWidth', 2);

    % 添加标签和标题
    xlabel('xdata');
    ylabel('ydata');
    title('Quadratic Fitting Result');
    legend('Data', 'Fitted Curve');
    hold off;
end