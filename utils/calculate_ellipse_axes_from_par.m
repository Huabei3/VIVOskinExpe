function [A, B, phi] = calculate_ellipse_axes_from_par(par)
% calculate_ellipse_axes_from_par 从椭圆参数计算长轴A和短轴B。
%   par = [a1, a2, a3, a4, a5, a6]
%   椭圆方程: a1*x^2 + a2*y^2 + a3*xy + a4*x + a5*y + a6 = 0
%   在你的函数中，似乎椭圆方程是:
%   a1*x^2 + a2*y^2 + a3*xy + a4*x + a5*y + C = 0 
%   这里 par(1), par(2), par(3) 是二次项系数，par(4), par(5) 是中心，
%   par(6) 是一个缩放因子，它影响椭圆的大小，但不是直接的常数项。
%   我们关注 sqrt(a1*dx^2 + a2*dy^2 + a3*dx*dy) = constant 的形式
%   这里的 par(1), par(2), par(3) 对应于二次形式的系数。
%   这通常对应于 conic section 的形式 Ax^2 + Bxy + Cy^2 + Dx + Ey + F = 0
%   你的参数对应于:
%   A_quad = par(1)
%   B_quad = par(3)
%   C_quad = par(2)
%   这里的椭圆方程是 (x-cx)^2/alpha^2 + (y-cy)^2/beta^2 = 1 这种形式的变体
%   但你的函数形式是 1/(1 + par(6)*exp(sqrt(Q(x,y)))) = value
%   等高线是当 par(6)*exp(sqrt(Q(x,y))) = constant 时，即 sqrt(Q(x,y)) = constant'
%   Q(x,y) = par(1)*(x-par(4))^2 + par(2)*(y-par(5))^2 + par(3)*(x-par(4))*(y-par(5))
%   因此，我们关注 Q(x,y) = K^2 的椭圆。
%   这里的 K 是一个常数，取决于等高线级别。
%   我们通常取 LevelList 为 0.5 或 1 的等高线。
%   如果 1/(1 + par(6)*exp(sqrt(Q))) = 0.5，则 par(6)*exp(sqrt(Q)) = 1，
%   sqrt(Q) = -log(par(6))。 令 K = -log(par(6))。
%   所以椭圆的二次形式是 par(1)*(x-par(4))^2 + par(2)*(y-par(5))^2 + par(3)*(x-par(4))*(y-par(5)) = K^2
%   将其标准化为 Ax^2 + Bxy + Cy^2 = 1 的形式，其中 x,y 是中心化坐标。
%   A_coeff = par(1) / K^2
%   B_coeff = par(3) / K^2
%   C_coeff = par(2) / K^2
%
%   然而，为了避免依赖 K（其值取决于 par(6) 和等高线级别），
%   我们可以直接使用二次形式的系数来计算轴长和旋转角度。
%   对于二次型 Ax^2 + Bxy + Cy^2，其特征值可以用于确定轴长。
%   注意这里的 A, B, C 是二次项的系数，不要和轴长 A, B 混淆。
%   你的 par(1), par(2), par(3) 直接对应这些系数。
%   Let Q(x,y) = par(1)x^2 + par(3)xy + par(2)y^2
%   对应的矩阵 M = [par(1), par(3)/2; par(3)/2, par(2)]
%   特征值 lambda1, lambda2 满足 det(M - lambda*I) = 0
%   lambda^2 - trace(M)*lambda + det(M) = 0
%   trace(M) = par(1) + par(2)
%   det(M) = par(1)*par(2) - (par(3)/2)^2
%   特征值是 lambda = (trace(M) +/- sqrt(trace(M)^2 - 4*det(M))) / 2
%   对于一个椭圆，如果方程是 lambda1*x'^2 + lambda2*y'^2 = K^2 (在主轴坐标系下)
%   那么半轴长是 sqrt(K^2/lambda1) 和 sqrt(K^2/lambda2)
%   这里的 K^2 在你的函数中是 -log(par(6))^2。
%   所以，半轴长是 K / sqrt(lambda) = -log(par(6)) / sqrt(lambda)
%   这里 K 必须是正数。如果 par(6) >= 1，则 -log(par(6)) <= 0，这会导致问题。
%   实际应用中，par(6) 应该在 0 到 1 之间，以使 exp() 项为正。
%   如果 par(6) 小于 1， -log(par(6)) 是正的。
%   如果 par(6) 大于 1， -log(par(6)) 是负的，这意味着椭圆是虚的，或者你的函数定义有误。
%   假设我们关注的是实际的椭圆形状和大小，且 par(6) 使得 -log(par(6)) 为正。
%   实际等高线是 F(x,y) = 0.5 或者 1，这对应于 par(6)*exp(sqrt(Q(x,y))) = 1 或者 0。
%   如果 LevelList 是 0.5，那么 par(6)*exp(sqrt(Q)) = 1，所以 sqrt(Q) = -log(par(6))
%   因此 Q = (-log(par(6)))^2。我们将这个值设为 K_sq。
%   K_sq = (-log(par(6)))^2;
%   如果 par(6) 非常大或非常小，-log(par(6)) 可能导致 NaN 或 Inf。
%   我们应该检查 par(6) 的合理范围。通常 par(6) 应该大于 0。
%   在你的函数定义中， par(6) 作为一个系数，通常是正的。
%   假设 par(6) 使得 -log(par(6)) 有效且为正。

    if par(6) <= 0 || isnan(par(6)) || isinf(par(6))
        % 如果 par(6) 无效，则轴长无法计算，返回 NaN 或错误
        A = NaN;
        B = NaN;
        phi = NaN;
        warning('calculate_ellipse_axes_from_par:InvalidPar6', 'par(6) 必须为正且有限，当前值为 %f', par(6));
        return;
    end
    
    K_val = -log(par(6)); % 对于等高线 Level=0.5
    if K_val <= 0 % 如果 K_val <= 0，意味着等高线不存在或为虚椭圆，或者 par(6) >= 1
        % 如果 LevelList 是 0.5，要求 par(6)*exp(sqrt(Q)) = 1，则 sqrt(Q) = -log(par(6))
        % 这要求 -log(par(6)) > 0，即 par(6) < 1。
        % 否则，函数无法形成一个实的椭圆等高线，返回 NaN
        A = NaN;
        B = NaN;
        phi = NaN;
        % warning('calculate_ellipse_axes_from_par:InvalidKValue', 'K_val (-log(par(6))) 必须大于0，当前值为 %f。这可能表示等高线未形成实椭圆。', K_val);
        return;
    end

    A_quad = par(1);
    B_quad = par(3); % 交叉项系数
    C_quad = par(2);

    % 构建二次型矩阵
    M = [A_quad, B_quad/2; B_quad/2, C_quad];

    % 计算特征值
    lambda = eig(M);

    % 确保特征值为正，否则不是椭圆
    if any(lambda <= 0)
        A = NaN;
        B = NaN;
        phi = NaN;
        % warning('calculate_ellipse_axes_from_par:NotAnEllipse', '二次型矩阵的特征值非正，可能不是一个椭圆。');
        return;
    end

    % 计算半轴长
    % 半轴长 a = K / sqrt(lambda1), b = K / sqrt(lambda2)
    % 这里 K 是 sqrt(Q) 的常数值，即 K_val。
    A_semi = K_val / sqrt(min(lambda)); % 对应较小的特征值，得到更大的轴长（主轴）
    B_semi = K_val / sqrt(max(lambda)); % 对应较大的特征值，得到更小的轴长（次轴）

    A = 2 * A_semi; % 长轴
    B = 2 * B_semi; % 短轴

    % 计算旋转角度 phi (可选，如果需要绘图)
    % 对于矩阵 [A_quad, B_quad/2; B_quad/2, C_quad]
    % tan(2*phi) = B_quad / (A_quad - C_quad)
    if A_quad == C_quad
        if B_quad == 0
            phi = 0; % 圆或轴对齐
        else
            phi = pi/4; % 对角线椭圆
        end
    else
        phi = 0.5 * atan2(B_quad, (A_quad - C_quad));
    end
end