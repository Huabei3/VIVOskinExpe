%% 简化的DBSCAN实现（当没有Statistics Toolbox时使用）
function labels = dbscan_simple(data, eps, minPts)
% 简化版DBSCAN实现
    n = size(data, 1);
    labels = zeros(n, 1);  % 0表示未分类
    cluster_id = 0;
    
    % 计算距离矩阵
    dist_matrix = pdist2(data, data);
    
    for i = 1:n
        if labels(i) ~= 0
            continue;  % 已分类
        end
        
        % 找出邻域内的点
        neighbors = find(dist_matrix(i, :) <= eps);
        
        if length(neighbors) < minPts
            labels(i) = -1;  % 标记为噪声
            continue;
        end
        
        % 创建新聚类
        cluster_id = cluster_id + 1;
        labels(i) = cluster_id;
        
        % 扩展聚类
        seeds = neighbors(neighbors ~= i);
        while ~isempty(seeds)
            j = seeds(1);
            seeds = seeds(2:end);
            
            if labels(j) == -1
                labels(j) = cluster_id;  % 将噪声点加入聚类
            end
            
            if labels(j) ~= 0
                continue;  % 已分类
            end
            
            labels(j) = cluster_id;
            
            % 找出j的邻域
            j_neighbors = find(dist_matrix(j, :) <= eps);
            
            if length(j_neighbors) >= minPts
                % 将j的邻域加入种子集
                seeds = [seeds; j_neighbors(j_neighbors ~= j)];
            end
        end
    end
end