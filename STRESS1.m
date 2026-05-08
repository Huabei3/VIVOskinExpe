function STRESS_inter_ = STRESS1(d, d_hat)
    % d: 原始距离矩阵（高维）
    % d_hat: 拟合距离矩阵（低维）
    
    % 检查输入矩阵的大小是否一致
    if size(d) ~= size(d_hat)
        error('原始距离矩阵和拟合距离矩阵的大小必须一致');
    end

    % 计算距离差的平方和
    numerator = sum((d(:) - d_hat(:)).^2);

    % 计算原始距离的平方和
    denominator = sum(d(:).^2);

    STRESS_inter_ = sqrt(numerator / denominator);
end
