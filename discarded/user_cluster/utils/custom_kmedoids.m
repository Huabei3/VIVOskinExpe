function labels = custom_kmedoids(D, K, max_iter)
    if nargin < 3
        max_iter = 100;
    end
    
    n = size(D, 1);
    
    % 随机初始化 medoids
    medoids = randperm(n, K);
    labels = zeros(n, 1);
    
    for iter = 1:max_iter
        % 分配步骤：将每个点分配到最近的 medoid
        for i = 1:n
            [~, labels(i)] = min(D(i, medoids));
        end
        
        % 更新步骤：在每个簇中找到新的 medoid
        new_medoids = zeros(1, K);
        for k = 1:K
            cluster_indices = find(labels == k);
            if ~isempty(cluster_indices)
                % 找到使簇内距离总和最小的点作为新的 medoid
                cluster_distances = D(cluster_indices, cluster_indices);
                [~, min_idx] = min(sum(cluster_distances, 2));
                new_medoids(k) = cluster_indices(min_idx);
            else
                new_medoids(k) = medoids(k);
            end
        end
        
        % 检查收敛
        if isequal(sort(medoids), sort(new_medoids))
            break;
        end
        medoids = new_medoids;
    end
end