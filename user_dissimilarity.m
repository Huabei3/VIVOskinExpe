close all; clc; clear;
addpath("utils\")
%% =========================================================================
% 两两被试 dissimilarity 相关分析 - 量化被试间共识程度
% 目标：计算每对被试 dissimilarity 矩阵的相关系数，量化整体共识水平
% =========================================================================

% 加载数据
load(fullfile('level_data', 'labNscore_level_p10.mat'));
fprintf('数据维度: %d个刺激 × %d个被试\n', size(score_level,1), size(score_level,2));

X = score_level';       % n_subjects × n_stimuli
n_subjects = size(X, 1);
n_stimuli  = size(X, 2);

% =========================================================================
% Step 1: 构造每对刺激的距离向量（per subject）
% =========================================================================
% 对每个被试，计算其所有刺激对的 dissimilarity（用评分差的绝对值）
% n_pairs = n_stimuli*(n_stimuli-1)/2
n_pairs = n_stimuli * (n_stimuli - 1) / 2;

% D_i: n_subjects × n_pairs，每行是一个被试的刺激对 dissimilarity 向量
D_i = zeros(n_subjects, n_pairs);
for i = 1:n_subjects
    pair_idx = 0;
    d_vec = zeros(n_pairs, 1);
    for s1 = 1:n_stimuli-1
        for s2 = s1+1:n_stimuli
            pair_idx = pair_idx + 1;
            d_vec(pair_idx) = abs(X(i, s1) - X(i, s2));  % 评分差的绝对值作为 dissimilarity
        end
    end
    D_i(i, :) = d_vec;
end

fprintf('每被试 dissimilarity 向量维度: %d × %d\n', n_subjects, n_pairs);

% =========================================================================
% Step 2: 两两 dissimilarity 相关
% =========================================================================
fprintf('\n计算 %d×%d 被试对的 dissimilarity 相关矩阵...\n', n_subjects, n_subjects);

corr_matrix_pearson  = zeros(n_subjects, n_subjects);
corr_matrix_spearman = zeros(n_subjects, n_subjects);

for i = 1:n_subjects
    for j = 1:n_subjects
        if i == j
            corr_matrix_pearson(i, j)  = 1;
            corr_matrix_spearman(i, j) = 1;
        elseif i < j
            % Pearson 相关：直接比较 dissimilarity 向量
            [r_p, ~] = corr(D_i(i, :)', D_i(j, :)', 'Type', 'Pearson');
            [r_s, ~] = corr(D_i(i, :)', D_i(j, :)', 'Type', 'Spearman');
            corr_matrix_pearson(i, j)  = r_p; corr_matrix_pearson(j, i)  = r_p;
            corr_matrix_spearman(i, j) = r_s; corr_matrix_spearman(j, i) = r_s;
        end
    end
end

% 上三角元素（不含对角）取平均
upper_tri_idx = triu(true(n_subjects), 1);
mean_r_pearson  = mean(corr_matrix_pearson(upper_tri_idx));
mean_r_spearman = mean(corr_matrix_spearman(upper_tri_idx));
std_r_pearson   = std(corr_matrix_pearson(upper_tri_idx));
std_r_spearman  = std(corr_matrix_spearman(upper_tri_idx));

fprintf('\n========== 被试间共识统计 ==========\n');
fprintf('Pearson  相关系数: 均值=%.4f, 标准差=%.4f, 范围=[%.4f, %.4f]\n', ...
    mean_r_pearson, std_r_pearson, ...
    min(corr_matrix_pearson(upper_tri_idx)), max(corr_matrix_pearson(upper_tri_idx)));
fprintf('Spearman 相关系数: 均值=%.4f, 标准差=%.4f, 范围=[%.4f, %.4f]\n', ...
    mean_r_spearman, std_r_spearman, ...
    min(corr_matrix_spearman(upper_tri_idx)), max(corr_matrix_spearman(upper_tri_idx)));

% =========================================================================
% Step 3: 可视化
% =========================================================================
save_folder = fullfile('AnalyseResults_p', 'dissimilarity');
if ~exist(save_folder, 'dir'), mkdir(save_folder); end

% 3.1 Dissimilarity 相关热力图（按层次聚类排序）
Z_d = linkage(pdist(D_i, 'correlation'), 'ward');
leaf_order = optimalleaforder(Z_d, pdist(D_i, 'correlation'));

figure('Position', [100,100,1000,450]);
subplot(1,2,1);
corr_sorted = corr_matrix_pearson(leaf_order, leaf_order);
imagesc(corr_sorted, [-1, 1]);
colorbar;
colormap(parula);
title(sprintf('被试间 dissimilarity Pearson 相关\n(按聚类排序, 均值=%.3f)', mean_r_pearson));
xlabel('被试'); ylabel('被试');
% 添加聚类分界线
c = cluster(Z_d, 'MaxClust', 4);
sorted_c = c(leaf_order);
cumsum_c = cumsum(histcounts(sorted_c, 1:max(sorted_c)+1));
for k = 1:length(cumsum_c)-1
    line([0.5, n_subjects+0.5], [cumsum_c(k)+0.5, cumsum_c(k)+0.5], 'Color', 'white', 'LineWidth', 1.5);
    line([cumsum_c(k)+0.5, cumsum_c(k)+0.5], [0.5, n_subjects+0.5], 'Color', 'white', 'LineWidth', 1.5);
end

subplot(1,2,2);
corr_sorted_s = corr_matrix_spearman(leaf_order, leaf_order);
imagesc(corr_sorted_s, [-1, 1]);
colorbar;
colormap(parula);
title(sprintf('被试间 dissimilarity Spearman 相关\n(按聚类排序, 均值=%.3f)', mean_r_spearman));
xlabel('被试'); ylabel('被试');
for k = 1:length(cumsum_c)-1
    line([0.5, n_subjects+0.5], [cumsum_c(k)+0.5, cumsum_c(k)+0.5], 'Color', 'white', 'LineWidth', 1.5);
    line([cumsum_c(k)+0.5, cumsum_c(k)+0.5], [0.5, n_subjects+0.5], 'Color', 'white', 'LineWidth', 1.5);
end
saveas(gcf, fullfile(save_folder, 'dissimilarity_correlation_heatmap.png'));
close(gcf);

% 3.2 相关分布直方图
figure('Position', [100,100,900,400]);
subplot(1,2,1);
histogram(corr_matrix_pearson(upper_tri_idx), 20, 'FaceColor', [0.3 0.5 0.8], 'EdgeColor', 'white');
hold on;
xline(mean_r_pearson, 'r--', 'LineWidth', 2, 'DisplayName', sprintf('均值=%.3f', mean_r_pearson));
xline(0.7, 'g:', 'LineWidth', 1.5, 'DisplayName', '0.7 阈值(共识)');
xlabel('Pearson r'); ylabel('被试对数量');
title('被试间 dissimilarity 相关分布 (Pearson)');
legend; grid on;

subplot(1,2,2);
histogram(corr_matrix_spearman(upper_tri_idx), 20, 'FaceColor', [0.3 0.6 0.3], 'EdgeColor', 'white');
hold on;
xline(mean_r_spearman, 'r--', 'LineWidth', 2, 'DisplayName', sprintf('均值=%.3f', mean_r_spearman));
xline(0.7, 'g:', 'LineWidth', 1.5, 'DisplayName', '0.7 阈值(共识)');
xlabel('Spearman r'); ylabel('被试对数量');
title('被试间 dissimilarity 相关分布 (Spearman)');
legend; grid on;
saveas(gcf, fullfile(save_folder, 'dissimilarity_correlation_hist.png'));
close(gcf);

% 3.3 共识水平评估
fprintf('\n========== 共识水平评估 ==========\n');
high_consensus_pairs = sum(corr_matrix_pearson(upper_tri_idx) > 0.7);
low_consensus_pairs  = sum(corr_matrix_pearson(upper_tri_idx) < 0.4);
total_pairs = sum(upper_tri_idx(:));

fprintf('高共识对 (>0.7): %d/%d (%.1f%%)\n', high_consensus_pairs, total_pairs, high_consensus_pairs/total_pairs*100);
fprintf('低共识对 (<0.4): %d/%d (%.1f%%)\n', low_consensus_pairs, total_pairs, low_consensus_pairs/total_pairs*100);

if mean_r_pearson > 0.7
    fprintf('结论: 被试间整体共识较高 (r>0.7)，高STRESS可能来自评分量表差异而非偏好结构差异\n');
elseif mean_r_pearson > 0.4
    fprintf('结论: 被试间存在中等共识，偏好结构有一定差异但并非完全随机\n');
else
    fprintf('结论: 被试间共识较低 (r<0.4)，偏好结构差异大，可能需要从刺激属性找解释\n');
end

% 3.4 低共识被试对识别
fprintf('\n========== 低共识被试对 (r < 0.4) ==========\n');
low_pairs = [];
for i = 1:n_subjects-1
    for j = i+1:n_subjects
        if corr_matrix_pearson(i, j) < 0.4
            low_pairs = [low_pairs; i, j, corr_matrix_pearson(i, j)];
        end
    end
end
if ~isempty(low_pairs)
    [~, sort_low] = sort(low_pairs(:, 3));
    low_pairs = low_pairs(sort_low, :);
    fprintf('%-6s %-6s %-8s\n', '被试i', '被试j', 'Pearson r');
    fprintf('%s\n', repmat('-',1,22));
    for row = 1:min(10, size(low_pairs, 1))
        fprintf('%-6d %-6d %-8.4f\n', low_pairs(row, 1), low_pairs(row, 2), low_pairs(row, 3));
    end
    if size(low_pairs, 1) > 10, fprintf('... (共%d对)\n', size(low_pairs, 1)); end
end

% =========================================================================
% Step 4: 与评分的直接相关（对比）
% =========================================================================
% 也计算评分向量的相关（与 dissimilarity 相关对比）
corr_rating_pearson  = zeros(n_subjects, n_subjects);
corr_rating_spearman = zeros(n_subjects, n_subjects);
for i = 1:n_subjects
    for j = 1:n_subjects
        if i < j
            [rp, ~] = corr(X(i, :)', X(j, :)', 'Type', 'Pearson');
            [rs, ~] = corr(X(i, :)', X(j, :)', 'Type', 'Spearman');
            corr_rating_pearson(i, j)  = rp; corr_rating_pearson(j, i)  = rp;
            corr_rating_spearman(i, j) = rs; corr_rating_spearman(j, i) = rs;
        else
            corr_rating_pearson(i, j)  = 1;
            corr_rating_spearman(i, j) = 1;
        end
    end
end
mean_r_rating_pearson  = mean(corr_rating_pearson(upper_tri_idx));
mean_r_rating_spearman = mean(corr_rating_spearman(upper_tri_idx));

fprintf('\n========== 评分向量相关 vs Dissimilarity相关 ==========\n');
fprintf('评分向量 Pearson:  均值=%.4f\n', mean_r_rating_pearson);
fprintf('Dissimilarity Pearson: 均值=%.4f\n', mean_r_pearson);
fprintf('（两者都低 → 真无共识；评分高但dissimilarity低 → 量表偏移）\n');

% =========================================================================
% Step 5: 保存结果
% =========================================================================
results = struct();
results.corr_matrix_pearson    = corr_matrix_pearson;
results.corr_matrix_spearman   = corr_matrix_spearman;
results.corr_rating_pearson    = corr_rating_pearson;
results.corr_rating_spearman   = corr_rating_spearman;
results.mean_r_pearson         = mean_r_pearson;
results.mean_r_spearman        = mean_r_spearman;
results.mean_r_rating_pearson  = mean_r_rating_pearson;
results.mean_r_rating_spearman = mean_r_rating_spearman;
results.std_r_pearson          = std_r_pearson;
results.low_pairs              = low_pairs;
results.leaf_order             = leaf_order;
results.D_i                    = D_i;
results.n_subjects             = n_subjects;

save(fullfile(save_folder, 'dissimilarity_results.mat'), 'results');
fprintf('\n========== 分析完成 ==========\n');
fprintf('结果保存至: %s\n', fullfile(save_folder, 'dissimilarity_results.mat'));
