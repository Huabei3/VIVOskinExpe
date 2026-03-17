% 已知椭圆特征参数，计算原始参数par(1)到par(6)
% 输入：hue_angle, chroma, long_axis, short_axis, theta, alpha
% 输出：par(1)到par(6)

function par = ellipse_features_to_par(hue_angle, chroma, long_axis, short_axis, theta, alpha)
    % 确保长短轴的正确性
    if long_axis < short_axis
        temp = long_axis;
        long_axis = short_axis;
        short_axis = temp;
    end
    
    % 计算A和B
    A = 1 ./ (long_axis.^2);
    B = 1 ./ (short_axis.^2);
    
    % 计算lambda参数
    lambda00 = A .* cosd(theta).^2 + B .* sind(theta).^2 + (A - B) .* cosd(2*theta) .* sind(theta).^2 ./ cosd(theta).^2;
    lambda11 = A .* sind(theta).^2 + B .* cosd(theta).^2 - (A - B) .* cosd(2*theta) .* sind(theta).^2 ./ cosd(theta).^2;
    lambda01 = 0.5 .* (B - A) .* sind(2*theta);
    lambda10 = lambda01;  % 保持对称性
    
    % 计算alpha的平方
    alpha_sq = alpha.^2;
    
    % 计算par(1)到par(4)
    par1 = lambda00 .* alpha_sq;
    par2 = lambda11 .* alpha_sq;
    par3 = 2 .* lambda01 .* alpha_sq;  % 注意原代码中lambda01和lambda10都是par3除以(2*alpha²)
    
    % 计算par(4)和par(5)（与色调角相关）
    par4 = chroma .* cosd(hue_angle);
    par5 = chroma .* sind(hue_angle);
    
    % 计算par(6)，根据alpha = -log(par6) => par6 = exp(-alpha)
    par6 = exp(-alpha);
    
    % 组合所有参数
    par = [par1, par2, par3, par4, par5, par6];
end