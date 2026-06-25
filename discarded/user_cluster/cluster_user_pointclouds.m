function result = cluster_user_pointclouds(user_data, varargin)
    % cluster_user_pointclouds  对每个用户的点云（Lab 坐标）做用户间OT距离计算并聚类
    %
    % Usage:
    %   result = cluster_user_pointclouds(user_data)
    %   result = cluster_user_pointclouds(user_data, 'distance_method','EMD', 'clust_method','kmedoids', 'K',3)
    %
    % Inputs:
    %   user_data: cell array, length = num_users. 每个 cell: n_u x 3 (Lab)
    %
    % Optional name-value:
    %   'distance_method' : 'Wasserstein' (default) 或 'EMD'
    %   'clust_method'    : 'kmedoids' (default) / 'spectral' / 'hierarchical'
    %   'K'               : integer clusters (optional)
    %   'sinkhorn_reg'    : entropy reg lambda (default 0.05)
    %   'sinkhorn_maxiter': max iterations for sinkhorn (default 500)
    %   'sinkhorn_tol'    : tolerance (default 1e-9)
    %   'verbose'         : true/false
    %
    % Outputs (in struct result):
    %   labels: cluster labels (num_users x 1)
    %   D: pairwise distance matrix (num_users x num_users)
    %   sil_mean: mean silhouette
    %   ARI: adjusted rand index (if ground truth provided, else NaN)
    %   FMI: Fowlkes-Mallows index (if ground truth provided, else NaN)
    %   params: used params
    %%
    addpath("utils\")
    %% ---------------------- parse inputs ----------------------
    p = inputParser;
    addRequired(p, 'user_data', @(x) iscell(x) && ~isempty(x));
    addParameter(p, 'distance_method', 'Wasserstein', @(s) ismember(s,{'Wasserstein','EMD'}));
    addParameter(p, 'clust_method', 'kmedoids', @(s) ismember(s,{'kmedoids','spectral','hierarchical'}));
    addParameter(p, 'K', [], @(x) isempty(x) || (isnumeric(x) && isscalar(x) && x>=2));
    addParameter(p, 'sinkhorn_reg', 0.05, @(x) isnumeric(x) && x>0);
    addParameter(p, 'sinkhorn_maxiter', 500, @(x) isnumeric(x) && x>0);
    addParameter(p, 'sinkhorn_tol', 1e-9, @(x) isnumeric(x) && x>0);
    addParameter(p, 'verbose', true, @islogical);
    addParameter(p, 'ground_truth', [], @(x) isempty(x) || (isvector(x) && length(x)==length(user_data)));
    parse(p, user_data, varargin{:});
    opt = p.Results;
    
    num_users = numel(user_data);
    
    if opt.verbose
        fprintf("Users: %d, distance: %s, clustering: %s\n", num_users, opt.distance_method, opt.clust_method);
    end
    
    %% ------------------ compute pairwise OT distances ------------------
    D = zeros(num_users);
    for i = 1:num_users-1
        Xi = user_data{i};
        % ensure Nx3
        % if size(Xi,2) ~= 3
        %     error("Each user pointcloud must be n_i x 3 (Lab)");
        % end
        for j = i+1:num_users
            Xj = user_data{j};
            C = pdist2(Xi, Xj, 'euclidean').^2;   % cost matrix with squared euclidean
            % uniform weights
            ai = ones(size(Xi,1),1) ./ size(Xi,1);
            bj = ones(size(Xj,1),1) ./ size(Xj,1);
            % compute OT with Sinkhorn
            lambda = opt.sinkhorn_reg;
            maxiter = opt.sinkhorn_maxiter;
            tol = opt.sinkhorn_tol;
            transport_cost = sinkhorn_cost(C, ai, bj, lambda, maxiter, tol);
            switch opt.distance_method
                case 'EMD'
                    % treat transport_cost as OT cost (no root)
                    d = transport_cost;
                case 'Wasserstein'
                    % p=2 Wasserstein: sqrt(cost)
                    d = sqrt(max(transport_cost,0));
                otherwise
                    error('Unknown distance_method');
            end
            D(i,j) = d;
            D(j,i) = d;
        end
    end
    
    % small regularization to ensure symmetry positive
    D = (D + D')/2;
    
    %% ------------------ clustering ------------------
    K = opt.K;
    labels = [];
    
    switch opt.clust_method
        case 'kmedoids'
            if isempty(K)
                % choose K by silhouette mean across candidate Ks
                Ks = 2:min(6, num_users-1);
                bestK = Ks(1);
                bestSil = -inf;
                for k = Ks
                    % use kmedoids with precomputed distances
                    labels = custom_kmedoids(D, K);
                    % labk = kmedoids(D, k, 'Distance', 'precomputed', 'Replicates',5);
                    s = silhouette_from_D(D, labk);
                    if mean(s) > bestSil
                        bestSil = mean(s);
                        bestK = k;
                    end
                end
                K = bestK;
                if opt.verbose
                    fprintf("Auto selected K=%d (by silhouette)\n", K);
                end
            end
            labels = custom_kmedoids(D, K);
            % labels = kmedoids(D, K, 'Distance', 'precomputed', 'Replicates',10);
        case 'spectral'
            if isempty(K)
                Ks = 2:min(6, num_users-1);
                bestK = Ks(1);
                bestSil = -inf;
                for k = Ks
                    labk = spectral_clustering_from_D(D, k);
                    s = silhouette_from_D(D, labk);
                    if mean(s) > bestSil
                        bestSil = mean(s);
                        bestK = k;
                    end
                end
                K = bestK;
                if opt.verbose
                    fprintf("Auto selected K=%d (spectral, by silhouette)\n", K);
                end
            end
            labels = spectral_clustering_from_D(D, K);
        case 'hierarchical'
            % hierarchical clustering (agglomerative). Use average linkage by default
            % linkage requires condensed distance vector
            Y = squareform(D);
            Z = linkage(Y, 'average');
            if isempty(K)
                K = 3; % default if user didn't specify
                if opt.verbose
                    fprintf("hierarchical default K=3\n");
                end
            end
            labels = cluster(Z, 'maxclust', K);
        otherwise
            error('Unknown clust_method');
    end
    
    %% ------------------ evaluation ------------------
    % Silhouette (custom based on distance matrix)
    sil_vals = silhouette_from_D(D, labels);
    sil_mean = mean(sil_vals);
    
    % ARI and FMI (if ground truth provided)
    if ~isempty(opt.ground_truth)
        gt = opt.ground_truth(:);
        ARI = adjusted_rand_index(gt, labels);
        FMI = fowlkes_mallows_index(gt, labels);
    else
        ARI = NaN; FMI = NaN;
    end
    
    %% ------------------ results & plots ------------------
    result.labels = labels;
    result.D = D;
    result.sil_mean = sil_mean;
    result.sil_vals = sil_vals;
    result.ARI = ARI;
    result.FMI = FMI;
    result.params = opt;
    result.K = K;
    
    if opt.verbose
        fprintf("Clustering done. mean silhouette = %.4f\n", sil_mean);
        if ~isnan(ARI), fprintf("ARI = %.4f, FMI = %.4f\n", ARI, FMI); end
    end
    
    % plot distance heatmap
    figure('Name','User distance matrix'); imagesc(D); colorbar; axis square;
    title('Pairwise user distance'); xlabel('user'); ylabel('user');
    
    % plot each user's pointcloud in a*b* plane (scatter), color by cluster
    figure('Name','User pointclouds (a*b* plane)');
    colors = lines(max(1,max(labels)));
    hold on;
    for u = 1:num_users
        Xu = user_data{u};
        a = Xu(:,2); b = Xu(:,3);
        scatter(a, b, 20, repmat(colors(labels(u),:), size(Xu,1),1), 'filled', 'MarkerFaceAlpha',0.6);
    end
    xlabel('a*'); ylabel('b*'); title('User pointclouds colored by cluster'); axis equal; hold off;
    
    % dendrogram if hierarchical
    if strcmp(opt.clust_method,'hierarchical')
        figure('Name','Dendrogram');
        dendrogram(Z); title('Hierarchical clustering dendrogram');
    end

end











