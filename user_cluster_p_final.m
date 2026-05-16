close all;
clc;
clear;
addpath("utils\")
%% =========================================================================
% 用户聚类分析脚本 - 解释高Inter-stress
% 原理：将高Inter-stress群体拆分为偏好一致的子群体，降低簇内STRESS
% =========================================================================

% 加载原脚本的STRESS计算结果（score_all矩阵）
% 如果没有运行过原脚本，先运行 calSTRESSNfit_p_final.m
load(fullfile('AnalyseResults_p','efit_p','scaled','labNscore','labNscore_level_p10.mat'));

% =========================================================================
% Step 1: 构造被试×刺激矩阵 (n_stimuli × n_subjects)
% =========================================================================
% score_level: n_lab × n_file 矩阵（行=刺激，列=被试）
% 转置后 X: n_subjects × n_stimuli，每行代表一个被试的评分向量

% 选择要分析的亮度层（默认用L=10示例，可修改为其他层或循环所有层）
level = 10;
load(fullfile('AnalyseResults_p','efit_p','scaled','labNscore', ...
    sprintf('labNscore_level_p%d.mat', level)));

fprintf('正在分析亮度层 L=%.1f\n', level/10);
fprintf('数据维度: %d个刺激 × %d个被试\n', size(score_level,1), size(score_level,2));

% 转置：行为被试，列为刺激
X = score_level';  % n_subjects × n_stimuli

n_subjects = size(X, 1);
n_stimuli = size(X, 2);

% =========================================================================
% Step 2: 数据预处理 - 相关距离标准化
% =========================================================================
% 使用Pearson相关系数距离，对量值偏移不敏感（适合偏好模式聚类）
% 注意：相关性距离 = 1 - Pearson correlation，值越小越相似

% 方法A: 直接用原始评分计算相关性
% D_correlation = pdist(X, 'correlation');

% 方法B: 先标准化每个被试的评分（z-score或min-max），再计算欧氏距离
% 这样可以去掉不同被试使用不同评分范围的影响
X_scaled = (X - min(X, [], 2)) ./ (max(X, [], 2) - min(X, [], 2) + eps);  % 每行归一化到[0,1]
D_euclidean = pdist(X_scaled, 'euclidean');

% 使用相关性距离（推荐）
D = pdist(X, 'correlation');
D_matrix = squareform(D);

% =========================================================================
% Step 3: 层次聚类 + 树状图可视化
% =========================================================================
% 使用Ward方法：最小化簇内方差
Z = linkage(D, 'ward');

% 绘制树状图
figure('Position', [100, 100, 800, 600]);
dendrogram(Z, 'Label', arrayfun(@(x) sprintf('S%d', x), 1:n_subjects, 'UniformOutput', false));
title(sprintf('层次聚类树状图 (L=%.1f)\nWard方法，相关性距离', level/10));
xlabel('被试');
ylabel('距离');
grid on;

% 保存树状图
save_folder = fullfile('AnalyseResults_p','efit_p','scaled','cluster_analysis');
if ~exist(save_folder, 'dir')
    mkdir(save_folder);
end
saveas(gcf, fullfile(save_folder, sprintf('dendrogram_L%d.png', level)));
close(gcf);

% =========================================================================
% Step 4: 确定最佳聚类数K
% =========================================================================
max_K = min(10, floor(n_subjects / 2));  % 最大聚类数不超过样本数的一半

% 4.1 计算不同K的轮廓系数 (Silhouette Score)
silhouette_scores = zeros(max_K-1, 1);
for K = 2:max_K
    idx = cluster(Z, 'MaxClust', K);
    s = silhouette(X, idx, 'correlation');
    silhouette_scores(K-1) = mean(s);
end

% 4.2 计算不同K的簇内平方和 (Within-cluster SS) - 肘部法则
WSS = zeros(max_K, 1);
for K = 1:max_K
    if K == 1
        WSS(K) = sum(pdist(X, 'correlation').^2) / (2 * n_subjects);
    else
        idx = cluster(Z, 'MaxClust', K);
        idx_kmeans = kmeans(X, K, 'Distance', 'correlation', 'Replicates', 50, 'Display', 'off');
        centroids = zeros(K, size(X, 2));
        for k = 1:K
            if sum(idx_kmeans == k) > 0
                centroids(k, :) = mean(X(idx_kmeans == k, :), 1);
            end
        end
        WSS(K) = 0;
        for i = 1:n_subjects
            WSS(K) = WSS(K) + (1 - corr(X(i, :)', centroids(idx_kmeans(i), :)'))^2;
        end
    end
end

% 4.3 绘制评估图
figure('Position', [100, 100, 1200, 400]);

% 轮廓系数
subplot(1, 3, 1);
plot(2:max_K, silhouette_scores, 'bo-', 'LineWidth', 2, 'MarkerSize', 8);
title('轮廓系数法确定K');
xlabel('聚类数 K');
ylabel('平均轮廓系数');
grid on;
[~, best_K_silhouette] = max(silhouette_scores);
fprintf('轮廓系数法推荐 K = %d (score = %.4f)\n', best_K_silhouette + 1, max(silhouette_scores));

% 肘部法则
subplot(1, 3, 2);
plot(1:max_K, WSS, 'ro-', 'LineWidth', 2, 'MarkerSize', 8);
title('肘部法则确定K');
xlabel('聚类数 K');
ylabel('簇内平方和 (WSS)');
grid on;

% BIC准则（使用高斯混合模型）
% 注意：当被试数 < 刺激数时，需要先做PCA降维
subplot(1, 3, 3);
bic_scores = zeros(max_K-1, 1);
if n_subjects > n_stimuli
    % 数据足够，可以直接用GMM
    for K = 2:max_K
        GMModel = fitgmdist(X, K, 'Replicates', 50, 'CovarianceType', 'diagonal');
        bic_scores(K-1) = GMModel.BIC;
    end
else
    % 被试数 < 刺激数，先PCA降维到n_subjects-1维
    fprintf('  提示: 被试数(%d) < 刺激数(%d)，PCA降维后计算BIC\n', n_subjects, n_stimuli);
    [~, score] = pca(X);
    n_pca_components = min(n_subjects - 1, size(X, 2));
    X_pca = score(:, 1:n_pca_components);
    for K = 2:max_K
        try
            GMModel = fitgmdist(X_pca, K, 'Replicates', 50, ...
                'CovarianceType', 'diagonal', 'RegularizationValue', 1e-4);
            bic_scores(K-1) = GMModel.BIC;
        catch
            bic_scores(K-1) = NaN;  % GMM失败时设为NaN
        end
    end
end
valid_bic = bic_scores(~isnan(bic_scores));
if ~isempty(valid_bic)
    plot(2:max_K, bic_scores, 'go-', 'LineWidth', 2, 'MarkerSize', 8);
else
    text(0.5, 0.5, 'GMM failed for all K', 'Units', 'normalized', 'HorizontalAlignment', 'center');
end
title('BIC准则确定K (GMM)');
xlabel('聚类数 K');
ylabel('BIC');
grid on;
[~, best_K_bic] = min(bic_scores);
if all(isnan(bic_scores))
    best_K_bic = NaN;
    fprintf('  BIC准则: GMM在所有K上均失败，无法推荐K值\n');
end
fprintf('BIC准则推荐 K = %d (BIC = %.4f)\n', best_K_bic + 1, min(bic_scores));

saveas(gcf, fullfile(save_folder, sprintf('K_selection_L%d.png', level)));
close(gcf);

% 综合推荐：优先考虑轮廓系数，但最终由用户确认
recommended_K = best_K_silhouette + 1;
fprintf('\n========== K值选择建议 ==========\n');
fprintf('轮廓系数推荐: K = %d (轮廓系数 = %.4f)\n', best_K_silhouette + 1, max(silhouette_scores));
if ~isnan(best_K_bic)
    fprintf('BIC准则推荐:  K = %d (BIC = %.4f)\n', best_K_bic + 1, nanmin(bic_scores));
else
    fprintf('BIC准则推荐:  K = N/A (GMM失败)\n');
end
fprintf('推荐使用 K = %d，可根据实际解释性调整\n', recommended_K);
%%
% =========================================================================
% Step 5: 执行聚类
% =========================================================================
K = recommended_K;  % 可手动修改为其他K值
% K=5;
fprintf('\n========== 执行K=%d聚类 ==========\n', K);

% 5.1 层次聚类结果
idx_hierarchical = cluster(Z, 'MaxClust', K);

% 5.2 K-means细化（使用相关性距离，重复50次取最优）
opts = statset('Display', 'off', 'MaxIter', 1000);
[idx_kmeans, ~, ~, D_kmeans] = kmeans(X, K, ...
    'Distance', 'correlation', ...
    'Replicates', 50, ...
    'Options', opts);

% 选择聚类一致性更高的结果
consistency_hier = max(histcounts(idx_hierarchical, 1:K));
consistency_kmeans = max(histcounts(idx_kmeans, 1:K));
if consistency_kmeans >= consistency_hier
    idx = idx_kmeans;
    method = 'K-means (相关性距离)';
else
    idx = idx_hierarchical;
    method = '层次聚类 (Ward方法)';
end
fprintf('使用聚类方法: %s\n', method);

% =========================================================================
% Step 6: 聚类结果可视化
% =========================================================================

% 6.1 轮廓分析图
figure('Position', [100, 100, 800, 600]);
[s, h] = silhouette(X, idx, 'correlation');
title(sprintf('轮廓分析图 (K=%d, 平均轮廓系数=%.4f)', K, mean(s)));
xlabel('轮廓系数');
ylabel('被试');
grid on;
saveas(gcf, fullfile(save_folder, sprintf('silhouette_L%d_K%d.png', level, K)));
close(gcf);

% 6.2 各簇大小统计
cluster_sizes = histcounts(idx, 1:K+1);
fprintf('\n各簇被试数量:\n');
for k = 1:K
    fprintf('  簇%d: %d人 (%.1f%%)\n', k, cluster_sizes(k), cluster_sizes(k)/n_subjects*100);
end

% 6.3 雷达图/热力图：各簇的评分模式
figure('Position', [100, 100, 1200, 400]);
for k = 1:K
    subplot(1, K, k);
    cluster_k_mask = (idx == k);
    cluster_k_scores = X(cluster_k_mask, :);
    mean_k = mean(cluster_k_scores, 1);
    std_k = std(cluster_k_scores, 0, 1);

    % 绘制均值±标准差
    errorbar(1:n_stimuli, mean_k, std_k, 'o-', 'LineWidth', 1.5, 'MarkerSize', 4);
    xlabel('刺激编号');
    ylabel('评分');
    title(sprintf('簇%d (n=%d)\n均值±标准差', k, sum(cluster_k_mask)));
    grid on;
    xlim([0, n_stimuli+1]);
end
sgtitle('各簇评分模式对比');
saveas(gcf, fullfile(save_folder, sprintf('cluster_pattern_L%d_K%d.png', level, K)));
close(gcf);

% 6.4 热力图：被试×刺激矩阵，按聚类排序
[sorted_idx, order] = sort(idx);
X_sorted = X(order, :);

figure('Position', [100, 100, 1000, 600]);
imagesc(X_sorted);
colorbar;
colormap(parula);
xlabel('刺激编号');
ylabel('被试 (按簇排序)');
title(sprintf('被试-刺激评分热力图 (K=%d)', K));

% 添加簇分界线
cumsum_k = cumsum(cluster_sizes);
for k = 1:K-1
    line([0.5, n_stimuli+0.5], [cumsum_k(k)+0.5, cumsum_k(k)+0.5], 'Color', 'r', 'LineWidth', 2);
end
saveas(gcf, fullfile(save_folder, sprintf('heatmap_L%d_K%d.png', level, K)));
close(gcf);

% =========================================================================
% Step 7: 计算各簇的Inter-STRESS
% =========================================================================
fprintf('\n========== 各簇Inter-STRESS分析 ==========\n');

% 原始整体STRESS_inter（用于比较）
score_scaled = (X - (-3)) / 6;  % 归一化到[0,1]
mean_scaled = mean(score_scaled, 1);

STRESS_overall = zeros(n_subjects, 1);
for i = 1:n_subjects
    STRESS_overall(i) = STRESS(score_scaled(i, :)', mean_scaled');
end
STRESS_overall_mean = mean(STRESS_overall);
STRESS_overall_std = std(STRESS_overall);
fprintf('\n[整体] Inter-STRESS: 均值=%.4f, 标准差=%.4f\n', STRESS_overall_mean, STRESS_overall_std);

% 计算每个簇的簇内Inter-STRESS
STRESS_per_cluster = zeros(K, 1);
STRESS_per_cluster_std = zeros(K, 1);
n_per_cluster = zeros(K, 1);

for k = 1:K
    mask_k = (idx == k);
    X_k = X(mask_k, :);
    n_k = sum(mask_k);
    n_per_cluster(k) = n_k;

    % 簇内均值
    mean_k = mean(X_k, 1);
    mean_k_scaled = (mean_k - (-3)) / 6;

    % 簇内每个被试与簇内均值的STRESS
    STRESS_k = zeros(n_k, 1);
    for i = 1:n_k
        score_i_scaled = (X_k(i, :) - (-3)) / 6;
        STRESS_k(i) = STRESS(score_i_scaled', mean_k_scaled');
    end

    STRESS_per_cluster(k) = mean(STRESS_k);
    STRESS_per_cluster_std(k) = std(STRESS_k);

    fprintf('\n[簇%d] n=%d | Inter-STRESS: 均值=%.4f, 标准差=%.4f', ...
        k, n_k, STRESS_per_cluster(k), STRESS_per_cluster_std(k));
    fprintf(' | 簇内被试: ');
    fprintf('%d ', find(mask_k));
    fprintf('\n');
end

% =========================================================================
% Step 8: 效果评估 - 聚类是否降低了Inter-STRESS?
% =========================================================================
fprintf('\n========== 聚类效果评估 ==========\n');

% 加权平均的簇内STRESS
weighted_STRESS_cluster = sum(STRESS_per_cluster .* n_per_cluster) / sum(n_per_cluster);
fprintf('\n聚类前整体Inter-STRESS:  %.4f\n', STRESS_overall_mean);
fprintf('聚类后加权簇内STRESS:    %.4f\n', weighted_STRESS_cluster);
fprintf('STRESS降低比例:          %.1f%%\n', (1 - weighted_STRESS_cluster/STRESS_overall_mean) * 100);

% 统计检验：簇间STRESS差异是否显著（ANOVA）
[~, tbl, p_anova] = anova1(STRESS_overall, idx, 'off');
p_anova_val = tbl{2, 5};  % 从ANOVA表中提取p值
fprintf('\n簇间STRESS差异ANOVA p值: %.4f %s\n', p_anova_val, ...
    ternary(p_anova_val < 0.05, '(显著)', '(不显著)'));

% =========================================================================
% Step 9: 可视化比较
% =========================================================================
figure('Position', [100, 100, 1000, 600]);

% 9.1 各簇Inter-STRESS箱线图
subplot(1, 2, 1);
boxplot(STRESS_overall, idx);
hold on;
plot(1:K, STRESS_per_cluster, 'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'r');
xlabel('簇编号');
ylabel('Inter-STRESS');
title(sprintf('各簇Inter-STRESS分布\n(红点=均值, 整体均值=%.4f)', STRESS_overall_mean));
grid on;

% 9.2 条形图对比
subplot(1, 2, 2);
bar_colors = lines(K+1);
bar_x = 1:K+1;
bar_heights = [STRESS_per_cluster; weighted_STRESS_cluster];
bar_labels = arrayfun(@(k) sprintf('簇%d', k), 1:K, 'UniformOutput', false);
bar_labels{K+1} = '加权平均';
bar(bar_x, bar_heights, 'FaceColor', 'flat', 'CData', bar_colors);
hold on;
yline(STRESS_overall_mean, 'r--', 'LineWidth', 2, 'DisplayName', '整体均值');
set(gca, 'XTickLabel', bar_labels);
ylabel('Inter-STRESS');
title(sprintf('各簇Inter-STRESS对比\n(虚线=整体均值%.4f)', STRESS_overall_mean));
legend('Location', 'best');
grid on;

saveas(gcf, fullfile(save_folder, sprintf('STRESS_comparison_L%d_K%d.png', level, K)));
close(gcf);

% =========================================================================
% Step 9b: Bootstrap 聚类稳定性检验
% =========================================================================
fprintf('\n========== Bootstrap 聚类稳定性检验 ==========\n');
n_bootstrap = 1000;  % 重采样次数
fprintf('正在执行 %d 次Bootstrap重采样...\n', n_bootstrap);

% 初始化共现矩阵：记录每对被试被分到同一簇的次数
co_membership = zeros(n_subjects, n_subjects);

% Bootstrap 重采样（用普通for循环，避免parfor变量分类问题）
co_membership_list = cell(n_bootstrap, 1);  % 存储每次的簇分配结果
valid_count = 0;

for b = 1:n_bootstrap
    % 有放回抽样：抽取与原样本等量的被试索引
    bootstrap_idx = randsample(n_subjects, n_subjects, true);
    X_bootstrap = X(bootstrap_idx, :);

    % 对重采样数据做相同的聚类（K-means，相关性距离）
    opts = statset('Display', 'off', 'MaxIter', 1000);
    try
        boot_cluster = kmeans(X_bootstrap, K, ...
            'Distance', 'correlation', ...
            'Replicates', 20, ...
            'Options', opts);
        co_membership_list{b} = boot_cluster;
        valid_count = valid_count + 1;
    catch
        co_membership_list{b} = [];
    end
    if mod(b, 200) == 0
        fprintf('  已完成 %d/%d 次重采样...\n', b, n_bootstrap);
    end
end

% 汇总为共现矩阵
fprintf('  成功 %d/%d 次重采样\n', valid_count, n_bootstrap);
co_membership = zeros(n_subjects, n_subjects);
for b = 1:n_bootstrap
    boot_cluster = co_membership_list{b};
    if ~isempty(boot_cluster)
        for i = 1:n_subjects
            for j = (i+1):n_subjects
                if boot_cluster(i) == boot_cluster(j)
                    co_membership(i, j) = co_membership(i, j) + 1;
                    co_membership(j, i) = co_membership(j, i) + 1;
                end
            end
        end
    end
end

% 计算共识矩阵（归一化为[0,1]，用有效重采样次数）
consensus_matrix = co_membership / valid_count;

% 绘制共识矩阵热力图，按原始聚类结果排序
[sorted_idx, sort_order] = sort(idx);
consensus_sorted = consensus_matrix(sort_order, sort_order);

figure('Position', [100, 100, 700, 600]);
imagesc(consensus_sorted, [0, 1]);
colorbar;
colormap(flipud(hot));  % 0=白，1=黑，热力图
caxis([0 1]);

% 添加簇分界线
cumsum_k = cumsum(cluster_sizes);
for c = 1:K-1
    line([0.5, n_subjects+0.5], [cumsum_k(c)+0.5, cumsum_k(c)+0.5], ...
        'Color', 'cyan', 'LineWidth', 1.5);
    line([cumsum_k(c)+0.5, cumsum_k(c)+0.5], [0.5, n_subjects+0.5], ...
        'Color', 'cyan', 'LineWidth', 1.5);
end

title(sprintf('Bootstrap 共识矩阵 (K=%d, n=%d次有效)\n颜色: 0=从未同簇, 1=始终同簇', K, valid_count));
xlabel('被试 (按簇排序)');
ylabel('被试 (按簇排序)');

% 标注被试编号
xticks(1:n_subjects);
yticks(1:n_subjects);
xticklabels(arrayfun(@(x) sprintf('%d', x), sort_order, 'UniformOutput', false));
yticklabels(arrayfun(@(x) sprintf('%d', x), sort_order, 'UniformOutput', false));

saveas(gcf, fullfile(save_folder, sprintf('bootstrap_consensus_L%d_K%d.png', level, K)));
close(gcf);

% 计算稳定性指标
% 1. 每个簇的内部共识（簇内被试对被分到同一簇的平均比例）
fprintf('\n各簇内部共识 (应为 > 0.8 才算稳定):\n');
cluster_stability = zeros(K, 1);
for k = 1:K
    members = find(idx == k);
    n_members = length(members);
    if n_members > 1
        internal_sum = 0;
        count = 0;
        for i = 1:n_members
            for j = (i+1):n_members
                internal_sum = internal_sum + consensus_matrix(members(i), members(j));
                count = count + 1;
            end
        end
        cluster_stability(k) = internal_sum / count;
        fprintf('  簇%d (n=%d): 内部共识=%.3f %s\n', ...
            k, n_members, cluster_stability(k), ...
            ternary(cluster_stability(k) >= 0.8, '✓ 稳定', '(偏弱)'));
    else
        cluster_stability(k) = NaN;
        fprintf('  簇%d (n=1): 单人被试，无共识指标\n', k);
    end
end

% 2. 整体平均共识（对角块内的平均值）
diagonal_consensus = mean(cluster_stability(~isnan(cluster_stability)));
fprintf('\n整体簇内共识: %.3f\n', diagonal_consensus);

% 3. 簇间分离度（簇间被试对从未同簇的比例）
off_diagonal_sum = 0;
off_diagonal_count = 0;
for i = 1:n_subjects
    for j = (i+1):n_subjects
        if idx(i) ~= idx(j)
            off_diagonal_sum = off_diagonal_sum + (1 - consensus_matrix(i, j));
            off_diagonal_count = off_diagonal_count + 1;
        end
    end
end
off_diagonal_separation = off_diagonal_sum / off_diagonal_count;
fprintf('簇间分离度 (簇间被试从未同簇的比例): %.3f\n', off_diagonal_separation);

% Bootstrap 稳定性总结
fprintf('\n========== Bootstrap 稳定性总结 ==========\n');
fprintf('重采样次数: %d (有效: %d)\n', n_bootstrap, valid_count);
fprintf('簇内共识均值: %.3f (%s)\n', diagonal_consensus, ...
    ternary(diagonal_consensus >= 0.8, '稳定', '偏弱'));
fprintf('簇间分离度:  %.3f (%s)\n', off_diagonal_separation, ...
    ternary(off_diagonal_separation >= 0.9, '分离良好', '有一定重叠'));

% 如果簇内共识 >= 0.8 且簇间分离 >= 0.9，聚类是稳健的
is_stable = (diagonal_consensus >= 0.8) && (off_diagonal_separation >= 0.9);
fprintf('\n结论: 聚类 %s\n', ternary(is_stable, '✓ 统计稳健', '△ 稳健性一般，建议减少K值或剔除离群被试'));

% =========================================================================
% Step 10: 保存结果
% =========================================================================
save(fullfile(save_folder, sprintf('cluster_results_L%d_K%d.mat', level, K)), ...
    'idx', 'K', 'n_subjects', 'n_stimuli', ...
    'STRESS_overall', 'STRESS_overall_mean', 'STRESS_overall_std', ...
    'STRESS_per_cluster', 'STRESS_per_cluster_std', ...
    'n_per_cluster', 'weighted_STRESS_cluster', ...
    'silhouette_scores', 'WSS', 'bic_scores', ...
    'best_K_silhouette', 'best_K_bic', ...
    'co_membership', 'consensus_matrix', ...
    'cluster_stability', 'diagonal_consensus', 'off_diagonal_separation', ...
    'valid_count', 'Z');

fprintf('\n========== 分析完成 ==========\n');
fprintf('结果保存至: %s\n', fullfile(save_folder, sprintf('cluster_results_L%d_K%d.mat', level, K)));

% =========================================================================
% Step 11: 多亮度层批量分析（可选）
% =========================================================================
% 如果需要分析所有亮度层，取消下面注释
%{
fprintf('\n========== 批量分析所有亮度层 ==========\n');
results_all = struct();
for level = 10:10:80
    load(fullfile('AnalyseResults_p','efit_p','scaled','labNscore', ...
        sprintf('labNscore_level_p%d.mat', level)));
    X = score_level';

    % 执行聚类分析...
    % 保存到results_all
end
save(fullfile(save_folder, 'cluster_results_all_levels.mat'), 'results_all');
%}

%% =========================================================================
% 辅助函数
% =========================================================================
function result = ternary(condition, true_val, false_val)
    if condition
        result = true_val;
    else
        result = false_val;
    end
end

%% =========================================================================
% Strategy B: 剔除离群被试后重新聚类
% =========================================================================
function results = strategy_B_outlier_removal(X, idx, K, n_bootstrap, save_folder, level, consensus_matrix)
    fprintf('\n');
    fprintf('============================================================\n');
    fprintf('策略B: 剔除离群被试后重新聚类\n');
    fprintf('============================================================\n');

    n_subjects = size(X, 1);

    % ---------- B1: 识别离群被试 ----------
    fprintf('\n[B1] 识别离群被试...\n');

    % 方法1: 轮廓系数极低的被试
    s_all = silhouette(X, idx, 'correlation');
    outlier_silhouette = find(s_all < 0);  % 轮廓系数 < 0 = 在错误簇中

    % 方法2: 单人被试簇的成员
    singleton_clusters = find(histcounts(idx, 1:K) == 1);
    singleton_subjects = find(ismember(idx, singleton_clusters));

    % 方法3: 被分到孤立小簇（人数<=2）的被试
    small_clusters = find(histcounts(idx, 1:K) <= 2);
    small_subjects = find(ismember(idx, small_clusters));

    % 合并前两种方法（凝聚力方法较慢，跳过）
    outlier_union = union(outlier_silhouette, singleton_subjects);
    % 也把人数<=2的簇加入考虑
    outlier_union = union(outlier_union, small_subjects);

    fprintf('\n  离群被试识别结果:\n');
    fprintf('    方法1 (轮廓系数<0):  被试 %s\n', mat2str(outlier_silhouette'));
    fprintf('    方法2 (单人被试簇):  被试 %s\n', mat2str(singleton_subjects'));
    fprintf('    方法3 (小簇<=2人):  被试 %s\n', mat2str(small_subjects'));
    fprintf('    合并后离群被试:       %s\n', mat2str(outlier_union'));

    % 默认只剔除单人被试簇成员，人数<=2的小簇保留（让聚类决定）
    outliers_to_remove = singleton_subjects;
    fprintf('\n  默认剔除被试(单人被试簇): %s (共%d人)\n', mat2str(outliers_to_remove), length(outliers_to_remove));
    if ~isempty(small_subjects)
        fprintf('  人数<=2的小簇成员(保留参与聚类): %s\n', mat2str(setdiff(small_subjects, singleton_subjects)));
    end

    % ---------- B2: 剔除离群后重新聚类 ----------
    fprintf('\n[B2] 剔除离群被试后重新聚类...\n');
    keep_mask = ~ismember(1:n_subjects, outliers_to_remove);
    X_clean = X(keep_mask, :);
    n_clean = size(X_clean, 1);
    kept_subjects = find(keep_mask);
    fprintf('  剔除前: %d人 | 剔除后: %d人\n', n_subjects, n_clean);

    % 如果剩余人数不足4人，无法做有意义的聚类
    if n_clean < 4
        fprintf('  ⚠ 剔除后剩余人数不足(%d人<4)，跳过策略B。\n', n_clean);
        results = struct();
        results.skipped = true;
        results.reason = '剩余人数不足4人';
        save(fullfile(save_folder, sprintf('strategyB_L%d.mat', level)), 'results');
        fprintf('策略B已跳过\n');
        return;
    end

    % 重新计算距离和聚类
    D_clean = pdist(X_clean, 'correlation');
    Z_clean = linkage(D_clean, 'ward');

    % 尝试多个K，选择最优
    best_K_clean = 2;
    best_silhouette_clean = -1;
    for test_K = 2:min(6, floor(n_clean / 2))
        idx_test = kmeans(X_clean, test_K, 'Distance', 'correlation', 'Replicates', 50, 'Display', 'off');
        s_test = silhouette(X_clean, idx_test, 'correlation');
        if mean(s_test) > best_silhouette_clean
            best_silhouette_clean = mean(s_test);
            best_K_clean = test_K;
        end
    end
    K_clean = best_K_clean;
    fprintf('  最优K: %d (轮廓系数=%.4f)\n', K_clean, best_silhouette_clean);

    % 执行聚类
    opts = statset('Display', 'off', 'MaxIter', 1000);
    [idx_clean, ~] = kmeans(X_clean, K_clean, ...
        'Distance', 'correlation', 'Replicates', 50, 'Options', opts);

    % ---------- B3: Bootstrap 检验剔除后的聚类 ----------
    fprintf('\n[B3] Bootstrap 稳定性检验 (剔除后, n=%d次重采样)...\n', n_bootstrap);
    co_membership_clean = cell(n_bootstrap, 1);
    valid_clean = 0;
    for b = 1:n_bootstrap
        bootstrap_idx = randsample(n_clean, n_clean, true);
        X_boot = X_clean(bootstrap_idx, :);
        try
            boot_clust = kmeans(X_boot, K_clean, 'Distance', 'correlation', 'Replicates', 20, 'Options', opts);
            co_membership_clean{b} = boot_clust;
            valid_clean = valid_clean + 1;
        catch
            co_membership_clean{b} = [];
        end
    end

    % 汇总共识矩阵
    co_mat_clean = zeros(n_clean, n_clean);
    for b = 1:n_bootstrap
        bc = co_membership_clean{b};
        if ~isempty(bc)
            for i = 1:n_clean
                for j = (i+1):n_clean
                    if bc(i) == bc(j)
                        co_mat_clean(i, j) = co_mat_clean(i, j) + 1;
                        co_mat_clean(j, i) = co_mat_clean(j, i) + 1;
                    end
                end
            end
        end
    end
    consensus_clean = co_mat_clean / valid_clean;

    % 计算稳定性
    diag_cons_clean = zeros(K_clean, 1);
    for k = 1:K_clean
        members = find(idx_clean == k);
        if length(members) > 1
            sum_c = 0; cnt = 0;
            for i = 1:length(members)
                for j = (i+1):length(members)
                    sum_c = sum_c + consensus_clean(members(i), members(j));
                    cnt = cnt + 1;
                end
            end
            diag_cons_clean(k) = sum_c / cnt;
        else
            diag_cons_clean(k) = NaN;
        end
    end
    diag_mean_clean = nanmean(diag_cons_clean);

    off_diag_sum = 0; off_diag_cnt = 0;
    for i = 1:n_clean
        for j = (i+1):n_clean
            if idx_clean(i) ~= idx_clean(j)
                off_diag_sum = off_diag_sum + (1 - consensus_clean(i, j));
                off_diag_cnt = off_diag_cnt + 1;
            end
        end
    end
    off_diag_clean = off_diag_sum / off_diag_cnt;

    % 计算STRESS
    score_clean = (X_clean - (-3)) / 6;
    mean_clean = mean(score_clean, 1);
    stress_clean = zeros(n_clean, 1);
    for i = 1:n_clean
        stress_clean(i) = STRESS(score_clean(i, :)', mean_clean');
    end
    stress_overall_clean = mean(stress_clean);

    % 簇内STRESS
    stress_cluster_clean = zeros(K_clean, 1);
    n_per_clean = zeros(K_clean, 1);
    for k = 1:K_clean
        mask = (idx_clean == k);
        X_k = X_clean(mask, :);
        n_k = sum(mask);
        n_per_clean(k) = n_k;
        if n_k < 2
            % 单人被试簇：与整体均值比较，无簇内变异
            stress_cluster_clean(k) = NaN;
        else
            mean_k = mean(X_k, 1);
            mean_k_s = (mean_k - (-3)) / 6;
            stress_k = zeros(n_k, 1);
            for i = 1:n_k
                stress_k(i) = STRESS((X_k(i,:)-(-3))/6', mean_k_s');
            end
            stress_cluster_clean(k) = mean(stress_k);
        end
    end
    weighted_stress_clean = nansum(stress_cluster_clean .* n_per_clean) / n_clean;

    % ---------- B4: 输出汇总 ----------
    fprintf('\n========== 策略B 结果汇总 ==========\n');
    fprintf('剔除离群被试: %s\n', mat2str(outliers_to_remove));
    fprintf('最优K: %d\n', K_clean);
    fprintf('\n各簇人数:\n');
    for k = 1:K_clean
        if isnan(stress_cluster_clean(k))
            fprintf('  簇%d: %d人 | STRESS=N/A | 簇内共识=%.3f (单人被试)\n', ...
                k, n_per_clean(k), diag_cons_clean(k));
        else
            fprintf('  簇%d: %d人 | STRESS=%.4f | 簇内共识=%.3f\n', ...
                k, n_per_clean(k), stress_cluster_clean(k), diag_cons_clean(k));
        end
    end
    fprintf('\n聚类前整体STRESS: %.4f\n', stress_overall_clean);
    fprintf('聚类后加权STRESS: %.4f\n', weighted_stress_clean);
    fprintf('STRESS降低: %.1f%%\n', (1 - weighted_stress_clean/stress_overall_clean)*100);
    fprintf('\nBootstrap稳定性:\n');
    fprintf('  簇内共识: %.3f (%s)\n', diag_mean_clean, ternary(diag_mean_clean>=0.8,'✓稳定','偏弱'));
    fprintf('  簇间分离: %.3f (%s)\n', off_diag_clean, ternary(off_diag_clean>=0.9,'分离良好','一般'));

    % 绘图
    figure('Position', [100,100,900,400]);
    subplot(1,3,1);
    bar(1:K_clean, stress_cluster_clean);
    ylabel('Inter-STRESS'); xlabel('簇'); title('各簇STRESS'); grid on;
    subplot(1,3,2);
    bar(1:K_clean, diag_cons_clean); ylim([0 1]);
    ylabel('簇内共识'); xlabel('簇'); title('Bootstrap稳定性'); grid on;
    subplot(1,3,3);
    bar(1:K_clean, n_per_clean); ylabel('人数'); xlabel('簇'); title('各簇人数'); grid on;
    sgtitle(sprintf('策略B: 剔除%d个离群后K=%d', length(outliers_to_remove), K_clean));
    saveas(gcf, fullfile(save_folder, sprintf('strategyB_L%d.png', level)));
    close(gcf);

    % 保存
    results = struct();
    results.outliers_removed = outliers_to_remove;
    results.kept_subjects = kept_subjects;
    results.K_clean = K_clean;
    results.idx_clean = idx_clean;
    results.stress_cluster = stress_cluster_clean;
    results.weighted_stress = weighted_stress_clean;
    results.diagonal_consensus = diag_mean_clean;
    results.off_diagonal_separation = off_diag_clean;
    results.diag_per_cluster = diag_cons_clean;
    results.n_per_cluster = n_per_clean;

    save(fullfile(save_folder, sprintf('strategyB_L%d.mat', level)), 'results');
    fprintf('\n策略B结果已保存\n');
end

%% =========================================================================
% Strategy C: 层次聚类树状图自然断点（一致性聚类）
% =========================================================================
function results = strategy_C_dendrogram_cut(X, D, Z, n_bootstrap, save_folder, level)
    fprintf('\n');
    fprintf('============================================================\n');
    fprintf('策略C: 层次聚类树状图自然断点（一致性聚类）\n');
    fprintf('============================================================\n');

    n_subjects = size(X, 1);

    % ---------- C1: 从树状图提取所有可能的cut高度 ----------
    fprintf('\n[C1] 分析层次聚类树状图，寻找自然断点...\n');

    % 获取linkage的高度（即每次合并的距离）
    Z_heights = Z(:, 3);
    unique_heights = sort(unique(Z_heights), 'descend');  % 从高到低

    % 测试不同的K值对应的轮廓系数（模拟不同cut高度的效果）
    test_K_range = 2:min(8, floor(n_subjects / 2));
    stability_by_K = zeros(length(test_K_range), 1);
    mean_sil_by_K = zeros(length(test_K_range), 1);

    for ci = 1:length(test_K_range)
        test_K = test_K_range(ci);
        opts = statset('Display', 'off', 'MaxIter', 1000);
        idx_test = kmeans(X, test_K, 'Distance', 'correlation', 'Replicates', 30, 'Options', opts);
        s_test = silhouette(X, idx_test, 'correlation');
        mean_sil_by_K(ci) = mean(s_test);

        % 非单簇比例（每个簇至少2人）
        cluster_sizes_test = histcounts(idx_test, 1:test_K);
        stability_by_K(ci) = sum(cluster_sizes_test > 1) / test_K;
    end

    % 找轮廓系数最高的K
    [~, best_ci] = max(mean_sil_by_K);
    best_K_dendro = test_K_range(best_ci);

    fprintf('  扫描K从%d到%d，最优K=%d (轮廓系数=%.4f)\n', ...
        test_K_range(1), test_K_range(end), best_K_dendro, max(mean_sil_by_K));

    % 绘制cut高度分析图
    figure('Position', [100,100,1000,400]);
    subplot(1,3,1);
    plot(test_K_range, mean_sil_by_K, 'bo-', 'LineWidth', 2, 'MarkerSize', 8);
    xlabel('K值'); ylabel('平均轮廓系数'); title('轮廓系数法确定K');
    hold on;
    [~, best_marker_idx] = max(mean_sil_by_K);
    plot(test_K_range(best_marker_idx), max(mean_sil_by_K), 'ro', 'MarkerSize', 14, 'MarkerFaceColor', 'r');
    grid on;

    subplot(1,3,2);
    dendrogram(Z, 0);
    title(sprintf('层次聚类树状图\n(查看自然断点，最优K=%d)', best_K_dendro));

    subplot(1,3,3);
    plot(test_K_range, stability_by_K, 'go-', 'LineWidth', 2, 'MarkerSize', 8);
    xlabel('K值'); ylabel('非单簇比例'); title('各簇非单成员比例'); grid on;
    saveas(gcf, fullfile(save_folder, sprintf('strategyC_K_selection_L%d.png', level)));
    close(gcf);

    % ---------- C2: 在最优cut处执行聚类 ----------
    fprintf('\n[C2] 在最优Cut处执行聚类 (K=%d)...\n', best_K_dendro);
    opts = statset('Display', 'off', 'MaxIter', 1000);
    [idx_dendro, ~] = kmeans(X, best_K_dendro, 'Distance', 'correlation', 'Replicates', 50, 'Options', opts);

    cluster_sizes_dendro = histcounts(idx_dendro, 1:best_K_dendro);
    fprintf('  各簇人数: ');
    fprintf('%d ', cluster_sizes_dendro);
    fprintf('\n');

    % ---------- C3: Bootstrap 稳定性检验 ----------
    fprintf('\n[C3] Bootstrap 稳定性检验 (n=%d次重采样)...\n', n_bootstrap);
    co_membership_d = cell(n_bootstrap, 1);
    valid_d = 0;
    for b = 1:n_bootstrap
        bootstrap_idx = randsample(n_subjects, n_subjects, true);
        X_boot = X(bootstrap_idx, :);
        try
            boot_clust = kmeans(X_boot, best_K_dendro, 'Distance', 'correlation', 'Replicates', 20, 'Options', opts);
            co_membership_d{b} = boot_clust;
            valid_d = valid_d + 1;
        catch
            co_membership_d{b} = [];
        end
    end

    co_mat_d = zeros(n_subjects, n_subjects);
    for b = 1:n_bootstrap
        bc = co_membership_d{b};
        if ~isempty(bc)
            for i = 1:n_subjects
                for j = (i+1):n_subjects
                    if bc(i) == bc(j)
                        co_mat_d(i,j) = co_mat_d(i,j) + 1;
                        co_mat_d(j,i) = co_mat_d(j,i) + 1;
                    end
                end
            end
        end
    end
    consensus_d = co_mat_d / valid_d;

    % 计算各簇共识
    diag_cons_d = zeros(best_K_dendro, 1);
    for k = 1:best_K_dendro
        members = find(idx_dendro == k);
        if length(members) > 1
            sum_c = 0; cnt = 0;
            for i = 1:length(members)
                for j = (i+1):length(members)
                    sum_c = sum_c + consensus_d(members(i), members(j));
                    cnt = cnt + 1;
                end
            end
            diag_cons_d(k) = sum_c / cnt;
        else
            diag_cons_d(k) = NaN;
        end
    end
    diag_mean_d = nanmean(diag_cons_d);

    off_d_sum = 0; off_d_cnt = 0;
    for i = 1:n_subjects
        for j = (i+1):n_subjects
            if idx_dendro(i) ~= idx_dendro(j)
                off_d_sum = off_d_sum + (1 - consensus_d(i,j));
                off_d_cnt = off_d_cnt + 1;
            end
        end
    end
    off_diag_d = off_d_sum / off_d_cnt;

    % 计算STRESS
    score_d = (X - (-3)) / 6;
    mean_d = mean(score_d, 1);
    stress_d = zeros(n_subjects, 1);
    for i = 1:n_subjects
        stress_d(i) = STRESS(score_d(i,:)', mean_d');
    end
    stress_overall_d = mean(stress_d);

    stress_cluster_d = zeros(best_K_dendro, 1);
    n_per_d = zeros(best_K_dendro, 1);
    for k = 1:best_K_dendro
        mask = (idx_dendro == k);
        X_k = X(mask, :);
        n_k = sum(mask);
        n_per_d(k) = n_k;
        mean_k_s = (mean(X_k,1) - (-3)) / 6;
        sk = zeros(n_k,1);
        for i = 1:n_k
            sk(i) = STRESS((X_k(i,:)-(-3))/6', mean_k_s');
        end
        stress_cluster_d(k) = mean(sk);
    end
    weighted_stress_d = sum(stress_cluster_d .* n_per_d) / n_subjects;

    % ---------- C4: 绘制共识矩阵热力图 ----------
    [sorted_d, order_d] = sort(idx_dendro);
    consensus_sorted_d = consensus_d(order_d, order_d);
    cumsum_d = cumsum(cluster_sizes_dendro);

    figure('Position', [100,100,700,600]);
    imagesc(consensus_sorted_d, [0 1]);
    colormap(flipud(hot)); colorbar;
    for c = 1:best_K_dendro-1
        line([0.5, n_subjects+0.5], [cumsum_d(c)+0.5, cumsum_d(c)+0.5], 'Color', 'cyan', 'LineWidth', 1.5);
        line([cumsum_d(c)+0.5, cumsum_d(c)+0.5], [0.5, n_subjects+0.5], 'Color', 'cyan', 'LineWidth', 1.5);
    end
    title(sprintf('策略C共识矩阵 (K=%d)\n对角块=簇内共识, 块外=簇间分离', best_K_dendro));
    xticks(1:n_subjects); yticks(1:n_subjects);
    xticklabels(arrayfun(@(x)sprintf('%d',x), order_d, 'UniformOutput', false));
    yticklabels(arrayfun(@(x)sprintf('%d',x), order_d, 'UniformOutput', false));
    saveas(gcf, fullfile(save_folder, sprintf('strategyC_consensus_L%d_K%d.png', level, best_K_dendro)));
    close(gcf);

    % ---------- C5: 汇总 ----------
    fprintf('\n========== 策略C 结果汇总 ==========\n');
    fprintf('Cut高度: %.4f | K: %d\n', best_cut, best_K_dendro);
    fprintf('\n各簇详情:\n');
    for k = 1:best_K_dendro
        fprintf('  簇%d (n=%d): STRESS=%.4f, 簇内共识=%.3f, 被试: %s\n', ...
            k, n_per_d(k), stress_cluster_d(k), diag_cons_d(k), mat2str(find(idx_dendro==k)'));
    end
    fprintf('\n聚类前整体STRESS: %.4f\n', stress_overall_d);
    fprintf('聚类后加权STRESS: %.4f\n', weighted_stress_d);
    fprintf('STRESS降低: %.1f%%\n', (1 - weighted_stress_d/stress_overall_d)*100);
    fprintf('\nBootstrap稳定性:\n');
    fprintf('  簇内共识: %.3f (%s)\n', diag_mean_d, ternary(diag_mean_d>=0.8,'✓稳定','偏弱'));
    fprintf('  簇间分离: %.3f (%s)\n', off_diag_d, ternary(off_diag_d>=0.9,'分离良好','一般'));

    results = struct();
    results.best_cut = best_cut;
    results.K = best_K_dendro;
    results.idx = idx_dendro;
    results.stress_cluster = stress_cluster_d;
    results.weighted_stress = weighted_stress_d;
    results.diagonal_consensus = diag_mean_d;
    results.off_diagonal_separation = off_diag_d;
    results.diag_per_cluster = diag_cons_d;
    results.n_per_cluster = n_per_d;

    save(fullfile(save_folder, sprintf('strategyC_L%d.mat', level)), 'results');
    fprintf('\n策略C结果已保存\n');
end

%% =========================================================================
% 主程序结束 — 运行策略B和C
% =========================================================================
fprintf('\n');
fprintf('============================================================\n');
fprintf('是否运行进阶策略分析？\n');
fprintf('============================================================\n');
fprintf('策略B: 剔除离群被试后重新聚类\n');
fprintf('策略C: 层次聚类树状图自然断点\n');
fprintf('\n取消注释下面的行来运行对应策略:\n');
fprintf('  results_B = strategy_B_outlier_removal(X, idx, K, n_bootstrap, save_folder, level, consensus_matrix);\n');
fprintf('  results_C = strategy_C_dendrogram_cut(X, D, Z, n_bootstrap, save_folder, level);\n');
%%
% 取消下面注释可同时运行两个策略:
% {
results_B = strategy_B_outlier_removal(X, idx, K, n_bootstrap, save_folder, level, consensus_matrix);
results_C = strategy_C_dendrogram_cut(X, D, Z, n_bootstrap, save_folder, level);
% }

