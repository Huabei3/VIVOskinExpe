close all; clc; clear;
addpath("utils\")
%% =========================================================================
% INDSCAL 分析 - 个体差异权重视角解释被试间STRESS差异
% 目标：用INDSCAL模型分解共同空间与个体权重，理解被试间差异的本质
% =========================================================================

% 加载数据
load(fullfile('level_data', 'labNscore_level_p10.mat'));
fprintf('数据维度: %d个刺激 × %d个被试\n', size(score_level,1), size(score_level,2));

X = score_level';                    % n_subjects × n_stimuli
n_subjects = size(X, 1);
n_stimuli  = size(X, 2);

% =========================================================================
% Step 1: 构造被试 × 刺激对 dissimilarity 矩阵
% =========================================================================
% INDSCAL 需要: n_stimuli × n_stimuli × n_subjects 的距离数组
% 格式: D(:,:,i) = 被试i的 dissimilarity 矩阵

fprintf('\n构造 INDSCAL 输入 (n_stim=%d, n_subj=%d)...\n', n_stimuli, n_subjects);

% 方法: 用评分向量的相关性距离作为 dissimilarity
% 对每个被试，计算所有刺激对的相关性距离
D_input = zeros(n_stimuli, n_stimuli, n_subjects);
for i = 1:n_subjects
    scores_i = X(i, :);  % 1 × n_stim
    % dissimilarity = |rating(s1) - rating(s2)|
    D_input(:, :, i) = abs(scores_i' - scores_i);
end

fprintf('使用: 评分差绝对值作为 dissimilarity\n');

% =========================================================================
% Step 2: INDSCAL 分析
% =========================================================================
fprintf('\n========== INDSCAL 分析 ==========\n');

% 尝试不同维度的 INDSCAL
dims_to_try = 2:min(5, n_stimuli-1);
stress_indscal = zeros(length(dims_to_try), 1);
rsq_indscal   = zeros(length(dims_to_try), 1);

common_spaces = cell(length(dims_to_try), 1);
weights_all   = cell(length(dims_to_try), 1);

for di = 1:length(dims_to_try)
    nd = dims_to_try(di);
    try
        [config, w, stress_val, stats] = ...
            indscal(D_input, nd, 'replicates', 10, 'weights', 'positive');

        common_spaces{di} = config;
        weights_all{di}    = w;
        stress_indscal(di) = stress_val;
        if isfield(stats, 'rsq')
            rsq_indscal(di) = stats.rsq;
        else
            rsq_indscal(di) = NaN;
        end
        fprintf('  维度=%d: STRESS=%.4f, R^2=%.4f\n', nd, stress_val, rsq_indscal(di));
    catch
        stress_indscal(di) = NaN;
        rsq_indscal(di)    = NaN;
        fprintf('  维度=%d: 失败\n', nd);
    end
end

% 选择最优维度（STRESS < 0.1 阈值 + elbow法则）
valid_stress = stress_indscal(~isnan(stress_indscal));
if any(valid_stress < 0.1)
    [~, best_dim_idx] = min(find(valid_stress < 0.1));
else
    [~, best_dim_idx] = min(stress_indscal);
end
best_dim = dims_to_try(best_dim_idx);

fprintf('\n最优维度: %d (STRESS=%.4f)\n', best_dim, stress_indscal(best_dim_idx));

% 最优维度的结果
common_config = common_spaces{best_dim_idx};   % n_stim × best_dim 共同空间
weights_opt   = weights_all{best_dim_idx};      % n_subjects × best_dim 权重

% =========================================================================
% Step 3: 权重分析
% =========================================================================
fprintf('\n========== 被试权重分析 ==========\n');

% 权重归一化（每个被试的权重平方和=1）
weights_norm = weights_opt ./ sqrt(sum(weights_opt.^2, 2) + eps);  % n_subj × n_dim

% 计算每个被试的"维度重要性"（归一化权重）
fprintf('%-6s ', '被试');
for d = 1:best_dim, fprintf('Dim%-4d ', d); end
fprintf('主导维度\n');
fprintf('%s\n', repmat('-',1, 6*best_dim+14));
for i = 1:n_subjects
    [~, dom_dim] = max(weights_norm(i, :));
    fprintf('%-6d ', i);
    for d = 1:best_dim
        fprintf('%.3f  ', weights_norm(i, d));
    end
    fprintf('Dim%d\n', dom_dim);
end

% 计算整体维度重要性（所有被试的平均权重）
mean_weights = mean(weights_norm, 1);
fprintf('\n整体维度重要性: ');
for d = 1:best_dim, fprintf('Dim%d=%.3f  ', d, mean_weights(d)); end
fprintf('\n');

% =========================================================================
% Step 4: 被试分组（基于权重向量）
% =========================================================================
fprintf('\n========== 基于权重的被试分组 ==========\n');

% 用权重向量做层次聚类
D_weight = pdist(weights_norm, 'euclidean');
Z_w = linkage(D_weight, 'ward');

% 自动选择K（轮廓系数）
max_K = min(5, floor(n_subjects/2));
best_K_w = 2; best_sil_w = -1;
for test_K = 2:max_K
    idx_w = cluster(Z_w, 'MaxClust', test_K);
    sizes = histcounts(idx_w, 1:test_K+1);
    if all(sizes(1:test_K) > 1)
        s = silhouette(weights_norm, idx_w, 'euclidean');
        if mean(s) > best_sil_w
            best_sil_w = mean(s); best_K_w = test_K;
        end
    end
end
idx_weight_cluster = cluster(Z_w, 'MaxClust', best_K_w);

fprintf('权重聚类最优K=%d (轮廓系数=%.3f)\n', best_K_w, best_sil_w);
fprintf('各簇被试:\n');
for k = 1:best_K_w
    members = find(idx_weight_cluster == k);
    fprintf('  簇%d (n=%d): 被试 %s\n', k, length(members), mat2str(members'));
end

% =========================================================================
% Step 5: 可视化
% =========================================================================
save_folder = fullfile('AnalyseResults_p', 'INDSCAL');
if ~exist(save_folder, 'dir'), mkdir(save_folder); end

% 5.1 STRESS vs 维度数（elbow图）
figure('Position', [100,100,800,500]);
subplot(1,2,1);
plot(dims_to_try, stress_indscal, 'bo-', 'LineWidth', 2, 'MarkerSize', 8);
hold on;
yline(0.1, 'r--', 'LineWidth', 1.5, 'DisplayName', 'STRESS=0.1 threshold');
xline(best_dim, 'g--', 'LineWidth', 1.5, 'DisplayName', sprintf('Optimal dim=%d', best_dim));
xlabel('Number of dimensions'); ylabel('INDSCAL STRESS');
title('INDSCAL STRESS vs Dimensions');
legend; grid on;

subplot(1,2,2);
valid_rsq = rsq_indscal(~isnan(rsq_indscal));
if ~isempty(valid_rsq)
    plot(dims_to_try, rsq_indscal, 'go-', 'LineWidth', 2, 'MarkerSize', 8);
end
xlabel('Number of dimensions'); ylabel('R^2');
title('INDSCAL R^2 vs Dimensions');
grid on;
saveas(gcf, fullfile(save_folder, 'indscal_stress_vs_dim.png'));
close(gcf);

% 5.2 权重热力图
figure('Position', [100,100,800,500]);
imagesc(weights_norm);
colormap(parula);
colorbar;
caxis([0, max(weights_norm(:))]);
xlabel('INDSCAL Dimension');
ylabel('Subject');
title(sprintf('Subject weights in common space (dim=%d)', best_dim));
set(gca, 'XTick', 1:best_dim, 'XTickLabel', arrayfun(@(d)sprintf('Dim%d', d), 1:best_dim, 'UniformOutput', false));
% 标注簇分界线
cumsum_k = cumsum(histcounts(idx_weight_cluster, 1:best_K_w+1));
for k = 1:best_K_w-1
    line([0.5, best_dim+0.5], [cumsum_k(k)+0.5, cumsum_k(k)+0.5], 'Color', 'white', 'LineWidth', 2);
end
% 标注簇标签
for k = 1:best_K_w
    members = find(idx_weight_cluster == k);
    mean_row = mean(members);
    text(best_dim + 0.3, mean_row, sprintf('C%d', k), ...
        'Color', 'white', 'FontSize', 12, 'FontWeight', 'bold');
end
saveas(gcf, fullfile(save_folder, 'weight_heatmap.png'));
close(gcf);

% 5.3 权重条形图（各维度）
figure('Position', [100,100,900,500]);
bar_colors = lines(best_K_w);
for k = 1:best_K_w
    members = find(idx_weight_cluster == k);
    weights_mats = weights_norm(members, :);
    mean_w = mean(weights_mats, 1);
    std_w  = std(weights_mats, 0, 1);

    x_pos = (k-1)*(best_dim+1) + (1:best_dim);
    bar(x_pos, mean_w, 'FaceColor', bar_colors(k,:), 'EdgeColor', 'white');
    hold on;
    errorbar(x_pos, mean_w, std_w, 'k.', 'LineWidth', 1);
end
set(gca, 'XTick', (0:best_K_w-1)*(best_dim+1) + best_dim/2 + 0.5, ...
    'XTickLabel', arrayfun(@(d)sprintf('Dim%d', d), 1:best_dim, 'UniformOutput', false));
title('Mean weights by cluster (error bar = std)');
ylabel('Normalized weight');
grid on;
legend(arrayfun(@(k)sprintf('Cluster %d', k), 1:best_K_w, 'UniformOutput', false), 'Location', 'best');
saveas(gcf, fullfile(save_folder, 'weight_bar.png'));
close(gcf);

% 5.4 共同空间散点图（2D投影）
if best_dim >= 2
    figure('Position', [100,100,900,600]);
    scatter(common_config(:,1), common_config(:,2), 100, 1:n_stimuli, 'filled');
    colormap(parula); colorbar;
    xlabel('INDSCAL Dim 1'); ylabel('INDSCAL Dim 2');
    title(sprintf('INDSCAL Common Space (n_stim=%d)', n_stimuli));
    grid on;
    hold on;
    for s = 1:n_stimuli
        text(common_config(s,1)+0.02, common_config(s,2), sprintf('%d', s), ...
            'FontSize', 8, 'Color', 'k');
    end
    saveas(gcf, fullfile(save_folder, 'common_space_2D.png'));
    close(gcf);
end

% 5.5 权重 vs STRESS（解释哪些被试STRESS高的原因）
try
    load(fullfile('AnalyseResults_p', 'single_stress', 'single_STRESS_results.mat'), ...
        'STRESS_i', 'outliers_final');
    if exist('STRESS_i', 'var')
        figure('Position', [100,100,900,500]);
        for d = 1:min(best_dim, 3)
            subplot(1, min(best_dim,3), d);
            scatter(weights_norm(:, d), STRESS_i, 60, 'filled', 'CData', STRESS_i);
            colormap(parula); colorbar;
            xlabel(sprintf('Dim%d weight', d)); ylabel('Inter-STRESS');
            r = corr(weights_norm(:, d), STRESS_i);
            title(sprintf('Dim%d weight vs STRESS\n(r=%.3f)', d, r));
            grid on;
            for i = outliers_final(:)'
                text(weights_norm(i,d), STRESS_i(i), sprintf('S%d', i), ...
                    'FontSize', 9, 'Color', 'red');
            end
        end
        sgtitle('Subject weights vs STRESS (high weight = more sensitive to that dimension)');
        saveas(gcf, fullfile(save_folder, 'weight_vs_stress.png'));
        close(gcf);
    end
end

% =========================================================================
% Step 6: 权重解读（与刺激属性关联）
% =========================================================================
fprintf('\n========== 维度解读 ==========\n');

% 加载刺激物理属性
load(fullfile('level_data', 'labNscore_level_p10.mat'), 'lab_level');
lab = lab_level;
L_val = lab(:, 1); a_val = lab(:, 2); b_val = lab(:, 3);
C_val = sqrt(a_val.^2 + b_val.^2);
h_val = atan2d(b_val, a_val); h_val(h_val<0) = h_val(h_val<0) + 360;

fprintf('\nINDSCAL维度 vs 刺激物理属性 相关性:\n');
fprintf('%-10s ', 'Dimension');
fprintf('%-8s %-8s %-8s %-8s %-8s\n', 'L*', 'a*', 'b*', 'C*', 'h');
fprintf('%s\n', repmat('-',1,50));
for d = 1:best_dim
    fprintf('Dim %-6d ', d);
    r_L = corr(common_config(:, d), L_val);
    r_a = corr(common_config(:, d), a_val);
    r_b = corr(common_config(:, d), b_val);
    r_C = corr(common_config(:, d), C_val);
    r_h = corr(common_config(:, d), h_val);
    fprintf('%-8.3f %-8.3f %-8.3f %-8.3f %-8.3f\n', r_L, r_a, r_b, r_C, r_h);
end

fprintf('\nInterpretation:\n');
for d = 1:best_dim
    r_L = corr(common_config(:, d), L_val);
    r_C = corr(common_config(:, d), C_val);
    r_h = corr(common_config(:, d), h_val);
    attr_names_d = {'L* (lightness)', 'C* (chroma)', 'h (hue)'};
    [max_abs, max_idx] = max([abs(r_L), abs(r_C), abs(r_h)]);
    if max_abs < 0.3
        fprintf('  Dim %d: weak correlation with physical attributes (complex perceptual dimension)\n', d);
    else
        fprintf('  Dim %d: mainly correlated with %s \n', d, attr_names_d{max_idx});
    end
end

% =========================================================================
% Step 7: 总结
% =========================================================================
fprintf('\n========== INDSCAL Summary ==========\n');
fprintf('Optimal dimensions: %d\n', best_dim);
fprintf('INDSCAL STRESS: %.4f\n', stress_indscal(best_dim_idx));

fprintf('\nWeight clustering:\n');
for k = 1:best_K_w
    members = find(idx_weight_cluster == k);
    if exist('STRESS_i', 'var')
        mean_stress_k = mean(STRESS_i(members));
        fprintf('  Cluster %d (n=%d): subjects %s, mean STRESS=%.4f\n', ...
            k, length(members), mat2str(members'), mean_stress_k);
    else
        fprintf('  Cluster %d (n=%d): subjects %s\n', k, length(members), mat2str(members'));
    end
end

fprintf('\nSubstantive interpretation:\n');
fprintf('  * INDSCAL weights reflect how much each subject relies on each dimension\n');
fprintf('  * High-weight clusters: highly sensitive to that dimension -> key for preference judgment\n');
fprintf('  * Low-weight clusters: less sensitive -> rely on other cues or different strategies\n');
fprintf('  * Weight differences (continuous) vs clustering (categorical) -> INDSCAL provides a more nuanced view\n');
fprintf('  * High STRESS subjects may have unequal weights -> their internal space is distorted\n');

% =========================================================================
% Step 8: 保存结果
% =========================================================================
results = struct();
results.common_config      = common_config;
results.weights_opt        = weights_opt;
results.weights_norm       = weights_norm;
results.best_dim          = best_dim;
results.stress_indscal    = stress_indscal;
results.rsq_indscal       = rsq_indscal;
results.idx_weight_cluster = idx_weight_cluster;
results.best_K_w           = best_K_w;
results.best_sil_w         = best_sil_w;

save(fullfile(save_folder, 'INDSCAL_results.mat'), 'results');
fprintf('\n========== Done ==========\n');
fprintf('Results saved to: %s\n', fullfile(save_folder, 'INDSCAL_results.mat'));
