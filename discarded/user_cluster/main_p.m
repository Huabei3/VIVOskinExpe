%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 用户聚类稳定性分析 （可变 K，支持自动聚类）
% 数据结构要求：
%   data: [num_samples × num_users], e.g. [N × 20]
%
% 功能：
%   1. 遍历样本点数量 n = sample_range
%   2. 每个 n 随机选样本点 repeat 次
%   3. 对用户聚类（K-means 或自动聚类）
%   4. 指标：
%      - 平均簇内相关系数 overlap
%      - Silhouette Score
%      - 覆盖率 coverage
%   5. 输出三条趋势曲线
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% --------------------------- 参数设置 -----------------------------

% 输入数据：请替换成你的数据
% data = your matrix  (N × 20)

[num_samples, num_users] = size(data);

sample_range = 5:5:num_samples;   % 样本点数量范围
repeat = 50;                      % 每个 n 随机抽样次数

% 聚类参数
K_default = 3;         % 默认 K=3
use_auto_cluster = false;   % 若为 true，使用自动聚类（层次聚类）

% 指标存储
overlap_results = zeros(length(sample_range), repeat);
silhouette_results = zeros(length(sample_range), repeat);
coverage_results = zeros(length(sample_range), repeat);

%% --------------------------- 主循环 -----------------------------
for si = 1:length(sample_range)
    n = sample_range(si);
    
    fprintf("Processing sample size = %d ...\n", n);
    
    for r = 1:repeat
        
        % 随机选 n 个样本点
        idx = randperm(num_samples, n);
        sub = data(idx, :);                   % (n × num_users)
        
        % 用户向量：转置成 (num_users × n)
        user_vec = sub';
        
        %% ------------------- 聚类  -------------------
        if use_auto_cluster
            % 自动 K：层次聚类 + 最大轮廓系数
            K = auto_choose_K(user_vec);
            labels = cluster_users_auto(user_vec, K);
        else
            K = K_default;
            labels = kmeans(user_vec, K, "Replicates", 10);
        end
        
        
        %% ------------------- 指标计算 -------------------
        % --- 1. 平均簇内相关（Overlap） ---
        overlap_results(si, r) = calc_cluster_overlap(user_vec, labels, K);
        
        % --- 2. Silhouette（聚类精度） ---
        sil = silhouette(user_vec, labels);
        silhouette_results(si, r) = mean(sil);
        
        % --- 3. 覆盖率（cluster size 均衡程度） ---
        coverage_results(si, r) = calc_coverage(labels, K, num_users);
    end
end

%% --------------------------- 绘图 -----------------------------
figure; 
plot(sample_range, mean(overlap_results, 2), "-o", "LineWidth", 2);
xlabel("样本点数量 n"); ylabel("簇平均重叠率 Overlap");
title("样本点数量 vs 簇纯度（Overlap）"); grid on;

figure; 
plot(sample_range, mean(silhouette_results, 2), "-o", "LineWidth", 2);
xlabel("样本点数量 n"); ylabel("Silhouette 精度");
title("样本点数量 vs 聚类精度（Silhouette）"); grid on;

figure; 
plot(sample_range, mean(coverage_results, 2), "-o", "LineWidth", 2);
xlabel("样本点数量 n"); ylabel("Coverage 覆盖率");
title("样本点数量 vs 覆盖率（簇人数均衡性）"); grid on;

disp("分析完成！");
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% ================================================================
% 函数部分
%% ================================================================

% ----------------------- 自动选择 K -------------------------------
function K = auto_choose_K(user_vec)
    maxK = 6;
    best_sil = -inf;
    bestK = 2;
    
    for k = 2:maxK
        labels = kmeans(user_vec, k, "Replicates", 5);
        s = silhouette(user_vec, labels);
        if mean(s) > best_sil
            best_sil = mean(s);
            bestK = k;
        end
    end
    K = bestK;
end

% ----------------------- 自动聚类 -------------------------------
function labels = cluster_users_auto(user_vec, K)
    Z = linkage(user_vec, "ward");
    labels = cluster(Z, "maxclust", K);
end

% ----------------------- 计算簇平均相关（Overlap） ----------------
function overlap = calc_cluster_overlap(user_vec, labels, K)
    sum_corr = 0;
    count = 0;
    
    for k = 1:K
        idx = find(labels == k);
        if length(idx) < 2
            continue;
        end
        
        sub = user_vec(idx, :);
        cmat = corrcoef(sub');
        
        upper = triu(cmat, 1);
        vals = upper(upper ~= 0);
        
        sum_corr = sum_corr + mean(vals);
        count = count + 1;
    end
    
    if count == 0
        overlap = 0;
    else
        overlap = sum_corr / count;
    end
end

% ----------------------- 计算覆盖率 ------------------------------
function coverage = calc_coverage(labels, K, num_users)
    sizes = zeros(K,1);
    for k = 1:K
        sizes(k) = sum(labels == k) / num_users;
    end
    coverage = 1 - std(sizes);   % 越接近 1 表示越均衡
end
