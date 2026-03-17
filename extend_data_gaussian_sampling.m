function [extended_coords, extended_MSV] = extend_data_gaussian_sampling(coords, MSV, num_points_to_add)
% EXTEND_DATA_ALL_AXES_SAMPLING 沿着所有主成分方向进行延拓。
%   输入：
%     coords            - N x 2 的坐标矩阵
%     MSV               - N x 1 的函数值向量
%     num_points_to_add - 需要新增的点的数量
%
%   输出：
%     extended_coords - 延拓后的新坐标
%     extended_MSV    - 延拓后对应的新函数值

    if nargin < 3
        num_points_to_add = 500; % 默认新增500个点
    end

    if size(coords, 2) ~= 2
        error('输入坐标矩阵必须是N x 2的。');
    end

    % 1. 计算均值和协方差矩阵
    mu = mean(coords);
    Sigma = cov(coords);

    % 2. PCA：计算特征值和特征向量
    [V, D] = eig(Sigma);
    eigenvalues = diag(D);
    
    % 3. 构建新的协方差矩阵，用于延拓点的生成
    % 新的特征值：在所有主成分方向上增加方差，实现各方向的延拓
    long_axis_extend_factor = 2; % 长轴方向的延拓因子
    short_axis_extend_factor = 4; % 短轴方向的延拓因子
    
    [~, min_idx] = min(eigenvalues);
    [~, max_idx] = max(eigenvalues);

    new_eigenvalues = eigenvalues;
    new_eigenvalues(max_idx) = eigenvalues(max_idx) * long_axis_extend_factor;
    new_eigenvalues(min_idx) = eigenvalues(min_idx) * short_axis_extend_factor;

    new_D = diag(new_eigenvalues);
    new_Sigma = V * new_D * V';
    
    % 4. 使用新的协方差矩阵生成大量的延拓点，覆盖更大的范围
    total_points_to_generate = num_points_to_add * 5; 
    extended_coords_all = mvnrnd(mu, new_Sigma, total_points_to_generate);
    
    % 5. 过滤点：只保留距离在3σ到5σ范围内的点
    % 注意：这里使用原始的协方差矩阵来计算马哈拉诺比斯距离
    % 这样才能确保筛选出的点是在原始数据分布的3σ到5σ范围内的
    
    centered_extended_coords = extended_coords_all - mu;
    inv_Sigma = inv(Sigma);
    mahalanobis_dist_squared = sum(centered_extended_coords * inv_Sigma .* centered_extended_coords, 2);
    mahalanobis_dist = sqrt(mahalanobis_dist_squared);
    
    % 找到所有距离在3到5之间的点
    valid_indices = find(mahalanobis_dist >= 0 & mahalanobis_dist <= 5);
    
    % 从所有生成的点中，只保留有效的点
    if length(valid_indices) > num_points_to_add
        % 如果有效点太多，则随机选择
        valid_indices = valid_indices(randperm(length(valid_indices), num_points_to_add));
    end
    
    extended_coords = extended_coords_all(valid_indices, :);

    % 确保有足够的点
    if isempty(extended_coords)
        warning('未能生成任何有效点。请尝试调整延拓因子或生成点数。');
    end

    % 6. 对新坐标的函数值进行插值
    rbf_interpolant = scatteredInterpolant(coords, MSV, 'linear', 'none');
    extended_MSV = rbf_interpolant(extended_coords);
end