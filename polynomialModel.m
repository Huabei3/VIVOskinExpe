function [par, r, y] = polynomialModel(D_CCT)
    % 输入参数:
    %   D_CCT: 输入数据矩阵，第一列是因变量，第二列是自变量
    %   useCubic: 布尔值，true表示使用三次多项式，false表示使用二次多项式
    
    % 输入验证

    useCubic = true; % 默认使用二次多项式
    
    
    % 输入数据预处理
    D_CCT(D_CCT(:,2) == 6500, :) = [];  % 移除CCT=6500的数据点
    xdata = D_CCT(:,2); % 自变量
    ydata = D_CCT(:,1); % 因变量

    % 确保数据是按xdata排序的
    [xdata, sortIdx] = sort(xdata);
    ydata = ydata(sortIdx);

    % 定义多项式模型
    if useCubic
        % 三次多项式模型: y = a₁x³ + a₂x² + a₃x + a₄
        f = @(a, xdata) a(1)*xdata.^3 + a(2)*xdata.^2 + a(3)*xdata + a(4);
        
        % 初始参数估计（基于典型数据特征）
        a0 = [0.00001, -0.1, 10, 1000];
        
        % 参数上下界
        lb = [-inf, -inf, -inf, -inf];
        ub = [inf, inf, inf, inf];
        
        modelName = '三次多项式';
    else
        % 二次多项式模型: y = a₁x² + a₂x + a₃
        f = @(a, xdata) a(1)*xdata.^2 + a(2)*xdata + a(3);
        
        % 初始参数估计（基于典型数据特征）
        a0 = [0.001, -1, 5000];
        
        % 参数上下界
        lb = [-inf, -inf, -inf];
        ub = [inf, inf, inf];
        
        modelName = '二次多项式';
    end

    % 拟合过程
    options = optimset('MaxFunEvals', 200000, 'Display', 'off');
    a = lsqcurvefit(f, a0, xdata, ydata, lb, ub, options);

    % 计算拟合值和相关系数
    y = f(a, xdata);
    r = corr(y, ydata);

    % 输出结果
    par = a;
    fprintf('%s拟合的相关系数是 %.4f\n', modelName, r);

    % 绘制拟合结果
    hold on;
    
    % 生成平滑的曲线
    x_fit = linspace(min(xdata), max(xdata), 1000); % 生成1000个点，覆盖xdata的范围
    y_fit = f(a, x_fit); % 根据拟合参数计算预测值

    % 绘制平滑曲线
    if useCubic
        plot(x_fit, y_fit, 'g-', 'LineWidth', 2); % 三次多项式用绿色线
    else
        plot(x_fit, y_fit, 'b-', 'LineWidth', 2); % 二次多项式用蓝色线
    end
    
    % 添加图例说明
    if ~ishold
        legend('数据点', [modelName, '拟合曲线']);
    end
    
    % 添加标签和标题
    xlabel('自变量');
    ylabel('因变量');
    title([modelName, '拟合结果']);
end