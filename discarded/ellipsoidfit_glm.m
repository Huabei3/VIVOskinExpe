function [afinal,r,y_pred] = ellipsoidfit_glm(lab_level,p)

    % 数据准备
    xdata = lab_level; % 这应该是 (L, a, b) 坐标，大小为 m x 3
    ydata = p; % 这是对应的概率，大小为 m x 1
    
    % 椭圆模型函数定义
    f = @(a, xdata) (1 ./ (1 + a(6) * exp(sqrt(a(1) * (xdata(:, 2) - a(4)).^2 + ...
        a(2) * (xdata(:, 3) - a(5)).^2 + a(3) * (xdata(:, 2) - a(4)) .* (xdata(:, 3) - a(5))))));
    
    % 损失函数定义
    % 目标是使得 ydata > 0.5 的点 f(a, xdata) 尽量接近 1 (在椭圆内)，ydata <= 0.5 的点 f(a, xdata) 尽量接近 0 (在椭圆外)
    loss_func = @(a) sum((f(a, xdata) - ydata).^2);
    
    % 参数初始值
    a0 = [rand, rand, rand, rand, rand, rand];
    
    % 使用 fminsearch 进行优化（也可以用 lsqcurvefit）
    options = optimset('MaxFunEvals', 200000, 'Display', 'iter');
    [afinal, fval] = fminsearch(loss_func, a0, options);
    
    % 使用优化后的参数计算拟合的结果
    y_pred = f(afinal, xdata);
    
    % 评估结果
    r = corr(y_pred, ydata);
    fprintf('Correlation coefficient is %.2f\n', r);
    
    % 绘制拟合结果
    scatter(ydata, y_pred);
    xlabel('True Probability');
    ylabel('Predicted Probability');
    title('Fitting Result');
end