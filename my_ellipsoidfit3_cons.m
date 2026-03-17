function [par,r,y] = my_ellipsoidfit3(cielab,zscore,colorcenter)
% cielab should be m*3 matrix
% zscore should be m*1 vector

% if color center is preset, it will be fixed and not be optimized.
% output: par = [k1,k2,k3,k4,l0,a0,b0,k5,k6]
if nargin < 3
    xdata = cielab;
    ydata = zscore;
    % 定义拟合函数
    f = @(a, xdata) (1 ./ (1 + a(6) * exp(sqrt(a(1) * (xdata(:, 2) - a(4)).^2 + ...
        a(2) * (xdata(:, 3) - a(5)).^2 + a(3) * (xdata(:, 2) - a(4)) .* (xdata(:, 3) - a(5)))))) ...
        .* ((a(1) * (xdata(:, 2) - a(4)).^2 + a(2) * (xdata(:, 3) - a(5)).^2 + ...
        a(3) * (xdata(:, 2) - a(4)) .* (xdata(:, 3) - a(5))) >= 0);
    
    % 定义目标函数，用于 lsqnonlin
    objective = @(a) f(a, xdata) - ydata;
    
    % 定义非线性约束函数
    nonlcon = @(a) deal([], 4 * a(1) * a(2) - a(3)^2); % 约束条件 (4*a(1)*a(2) - a(3)^2) > 0
    
    % 初始化最佳拟合结果
    rmax = -inf;
    afinal = [];
    
    % 循环进行拟合
    for t = 1:100
        % 生成初始参数，并确保满足约束条件 (4*a(1)*a(2) - a(3)^2) > 0
        while true
            a0 = [rand, rand, rand, rand, rand, rand];
            if (4 * a0(1) * a0(2) - a0(3)^2) > 0
                break;
            end
        end
        
        % 设置优化选项
        options = optimoptions('lsqnonlin', 'MaxFunctionEvaluations', 200000);
        
        % 使用 lsqnonlin 进行拟合

        a = lsqnonlin(objective, a0, ...
            [0, 0, -inf, 5, 5, 0], [inf, inf, inf, 35, 35, 1], ...
            [], [], [], [], ...
            nonlcon, options);

        
        % 计算拟合结果
        y = f(a, xdata);
        
        % 计算相关系数
        r = corr(y, ydata);
        
        % 更新最佳拟合结果
        if r >= rmax
            rmax = r;
            afinal = a;
        end
    end
    
    % 输出最佳参数和相关系数
    par = afinal;
    a = afinal;
    y = f(a, xdata);
    
    % 绘制拟合结果
    scatter(ydata, y);
    xlabel('True Probability');
    ylabel('Predicted Probability');
    title('Fitting Result');
    
    fprintf('Correlation coefficient is %.2f\n', r); 
else
    xdata = cielab;
    ydata = zscore;

    f = @(a,xdata)(a(8)*exp(a(1)*sqrt((xdata(:,1)-colorcenter(1)).^2+a(2)*(xdata(:,2)-colorcenter(2)).^2+a(3)*(xdata(:,3)-colorcenter(3)).^2+a(4)*(xdata(:,2)-colorcenter(2)).*(xdata(:,3)-colorcenter(3))))+a(9)).*(((xdata(:,1)-colorcenter(1)).^2+a(2)*(xdata(:,2)-colorcenter(2)).^2+a(3)*(xdata(:,3)-colorcenter(3)).^2+a(4)*(xdata(:,2)-colorcenter(2)).*(xdata(:,3)-colorcenter(3)))>=0);
    rmax = 0;

    for t = 1:100
        a0 = [-rand,rand,rand,rand,rand,rand,rand,rand,rand];
        options = optimset('MaxFunEvals',200000);
        a = lsqcurvefit(f,a0,xdata,ydata,[-inf,0,0,-inf,-inf,-inf,-inf,-inf,-inf], ...
            [inf,inf,inf,inf,inf,inf,inf,inf,inf],options);
        y = (a(8)*exp(a(1)*sqrt((xdata(:,1)-colorcenter(1)).^2+a(2)*(xdata(:,2)-colorcenter(2)) ...
        .^2+a(3)*(xdata(:,3)-colorcenter(3)).^2+a(4)*(xdata(:,2)-colorcenter(2)).* ...
        (xdata(:,3)-colorcenter(3))))+a(9)).*(((xdata(:,1)-colorcenter(1)).^2+a(2)* ...
        (xdata(:,2)-colorcenter(2)).^2+a(3)*(xdata(:,3)-colorcenter(3)).^2+a(4)* ...
        (xdata(:,2)-colorcenter(2)).*(xdata(:,3)-colorcenter(3)))>=0);

        r = corr(y,ydata);
        if r >= rmax
            rmax = r;
            afinal = a;
        end
    end

    par = afinal;
    par(5:7) = colorcenter;
    a = afinal;
    y = (a(8)*exp(a(1)*sqrt((xdata(:,1)-colorcenter(1)).^2+a(2)*(xdata(:,2)-colorcenter(2)).^2 ...
        +a(3)*(xdata(:,3)-colorcenter(3)).^2+a(4)*(xdata(:,2)-colorcenter(2)) ...
        .*(xdata(:,3)-colorcenter(3))))+a(9)).*(((xdata(:,1)-colorcenter(1)).^2+a(2)* ...
        (xdata(:,2)-colorcenter(2)).^2+a(3)*(xdata(:,3)-colorcenter(3)).^2+a(4)*...
        (xdata(:,2)-colorcenter(2)).*(xdata(:,3)-colorcenter(3)))>=0);
    scatter(y,ydata);
    r = corr(y,ydata);
    fprintf('corralation coefficient is %.2f\n',r);
end
end