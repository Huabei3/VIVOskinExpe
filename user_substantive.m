close all; clc; clear;
addpath("utils\")
%% =========================================================================
% 刺激属性回归分析 - 从物理属性解释被试间分歧
% 目标：找出哪些刺激属性（L*, a*, b*, C*, h）上被试间分歧最大，
%       并用回归量化各属性的贡献
% =========================================================================

% 加载数据（包含刺激lab值和评分）
load(fullfile('level_data', 'labNscore_level_p10.mat'));
% lab_level: n_stim × 3 (L*, a*, b*)
% score_level: n_stim × n_subj

fprintf('数据维度: %d个刺激 × %d个被试\n', size(score_level,1), size(score_level,2));

X = score_level';                    % n_subjects × n_stimuli
lab = lab_level;                     % n_stimuli × 3 (L*, a*, b*)
n_stimuli = size(X, 2);
n_subjects = size(X, 1);

% =========================================================================
% Step 1: 计算每个刺激的被试间分歧指标
% =========================================================================
fprintf('\n========== 刺激层面分歧统计 ==========\n');

% 指标1: 评分标准差（最直观）
std_per_stim = std(X, 0, 1)';        % n_stim × 1

% 指标2: 评分范围
range_per_stim = (max(X, [], 1) - min(X, [], 1))';  % n_stim × 1

% 指标3: 基于dissimilarity的重构误差（对每个刺激的评分估计误差）
% 用均值向量估计每个被试对该刺激的评分，计算平均误差
mean_score = mean(X, 1);            % 1 × n_stim
mae_per_stim = mean(abs(X - repmat(mean_score, n_subjects, 1)), 1)';  % n_stim × 1

% 指标4: 评分一致性比例（评分相同的被试占比）
mode_score = mode(X, 1);             % 1 × n_stim
agree_ratio = zeros(n_stimuli, 1);
for s = 1:n_stimuli
    agree_ratio(s) = sum(X(:, s) == mode_score(s)) / n_subjects;
end

% 分歧排序
[~, sort_idx] = sort(std_per_stim, 'descend');
fprintf('\n分歧最大的5个刺激:\n');
fprintf('%-6s %-8s %-8s %-8s %-8s\n', '刺激', 'L*', 'a*', 'b*', '评分标准差');
fprintf('%s\n', repmat('-',1,40));
for ii = 1:min(5, n_stimuli)
    s = sort_idx(ii);
    fprintf('%-6d %-8.2f %-8.2f %-8.2f %-8.4f\n', s, lab(s,1), lab(s,2), lab(s,3), std_per_stim(s));
end

fprintf('\n分歧最小的5个刺激:\n');
for ii = 1:min(5, n_stimuli)
    s = sort_idx(end-ii+1);
    fprintf('%-6d %-8.2f %-8.2f %-8.2f %-8.4f\n', s, lab(s,1), lab(s,2), lab(s,3), std_per_stim(s));
end

% =========================================================================
% Step 2: 刺激物理属性计算
% =========================================================================
L_val = lab(:, 1);                   % L*
a_val = lab(:, 2);                   % a*
b_val = lab(:, 3);                   % b*
C_val = sqrt(a_val.^2 + b_val.^2);  % 色度
h_val = atan2d(b_val, a_val);       % 色相角 (degree)
h_val(h_val < 0) = h_val(h_val < 0) + 360;

% CIEDE2000 差异（每个刺激与中性色的差异）
delta_E00_neutral = sqrt(a_val.^2 + b_val.^2);  % 近似到中性色的色差

% 亮度分组（L*高/中/低）
L_group = discretize(L_val, 3, 'categorical');

fprintf('\n========== 刺激属性范围 ==========\n');
fprintf('L*:  [%.2f, %.2f]  均值=%.2f\n', min(L_val), max(L_val), mean(L_val));
fprintf('a*:  [%.2f, %.2f]  均值=%.2f\n', min(a_val), max(a_val), mean(a_val));
fprintf('b*:  [%.2f, %.2f]  均值=%.2f\n', min(b_val), max(b_val), mean(b_val));
fprintf('C*:  [%.2f, %.2f]  均值=%.2f\n', min(C_val), max(C_val), mean(C_val));
fprintf('h deg: [%.2f, %.2f]  均值=%.2f\n', min(h_val), max(h_val), mean(h_val));

% =========================================================================
% Step 3: 分歧 vs 物理属性的相关性
% =========================================================================
fprintf('\n========== 分歧 vs 物理属性 相关性 ==========\n');
fprintf('%-12s %-12s %-12s %-12s\n', '属性', 'Pearson r', 'p-value', '显著');
fprintf('%s\n', repmat('-',1,50));

attr_names = {'L*', 'a*', 'b*', 'C*', 'h deg', '|a*|', '|b*|', 'DeltaE_neutral'};
attr_matrix = [L_val, a_val, b_val, C_val, h_val, abs(a_val), abs(b_val), delta_E00_neutral];

regression_results = struct();
for a = 1:length(attr_names)
    [r_p, p_p] = corr(attr_matrix(:, a), std_per_stim, 'Type', 'Pearson');
    [r_s, p_s] = corr(attr_matrix(:, a), std_per_stim, 'Type', 'Spearman');
    regression_results(a).attr = attr_names{a};
    regression_results(a).r_pearson = r_p; regression_results(a).p_pearson = p_p;
    regression_results(a).r_spearman = r_s; regression_results(a).p_spearman = p_s;
    sig_p = ternary(p_p < 0.05, '*', '');
    sig_s = ternary(p_s < 0.05, '*', '');
    fprintf('%-12s %-12.4f %-12.4f %-12s\n', attr_names{a}, r_p, p_p, sig_p);
end

% =========================================================================
% Step 4: 多元回归分析
% =========================================================================
fprintf('\n========== 多元线性回归 (分歧 ~ 物理属性) ==========\n');

% 用 L*, C*, h 作为预测变量
X_reg = [L_val, C_val, h_val];
X_reg = [ones(n_stimuli, 1), X_reg];  % 加截距

% 多元回归
[b_reg, ~, r_int, ~, stats] = regress(std_per_stim, X_reg);

fprintf('\n回归系数:\n');
fprintf('%-12s %-12s %-12s\n', '变量', '系数', '标准化系数(beta)');
fprintf('%s\n', repmat('-',1,36));
var_names = {'截距', 'L*', 'C*', 'h deg'};
for v = 1:length(var_names)
    fprintf('%-12s %-12.4f', var_names{v}, b_reg(v));
    if v > 1
        % 标准化系数
        beta = b_reg(v) * std(attr_matrix(:, v-1)) / std(std_per_stim);
        fprintf(' %-12.4f\n', beta);
    else
        fprintf('\n');
    end
end
fprintf('\nR^2 = %.4f, F = %.2f, p = %.4f\n', stats(1), stats(2), stats(3));
if stats(3) < 0.05
    fprintf('-> 物理属性整体显著解释分歧的 %.1f%%\n', stats(1)*100);
else
    fprintf('-> 物理属性整体不显著 (p>0.05)，分歧可能由其他因素驱动\n');
end

% =========================================================================
% Step 5: 按亮度层分组分析
% =========================================================================
fprintf('\n========== 按亮度组分析分歧 ==========\n');
L_groups = {'低亮度(L*)', '中亮度(L*)', '高亮度(L*)'};
group_means = zeros(3, 1);
for g = 1:3
    mask = (L_group == g);
    group_means(g) = mean(std_per_stim(mask));
    fprintf('%s: n=%d, 平均分歧=%.4f\n', L_groups{g}, sum(mask), group_means(g));
end

% ANOVA 检验亮度组间分歧差异
grp = double(L_group);
[~, tbl, stats_anova] = anova1(std_per_stim, grp, 'off');
p_anova_L = tbl{2, 5};
fprintf('\n亮度组间分歧差异: F=%.2f, p=%.4f %s\n', ...
    tbl{2, 5}, p_anova_L, ternary(p_anova_L<0.05, '(显著)', '(不显著)'));

% =========================================================================
% Step 6: 可视化
% =========================================================================
save_folder = fullfile('AnalyseResults_p', 'substantive');
if ~exist(save_folder, 'dir'), mkdir(save_folder); end

% 6.1 分歧 vs 主要属性散点图
figure('Position', [100,100,1100,500]);
subplot(2,3,1);
scatter(L_val, std_per_stim, 60, 'filled', 'CData', std_per_stim);
colormap(parula); colorbar;
xlabel('L*'); ylabel('评分标准差');
title(sprintf('分歧 vs L* (r=%.3f)', corr(L_val, std_per_stim)));
grid on;

subplot(2,3,2);
scatter(C_val, std_per_stim, 60, 'filled', 'CData', std_per_stim);
colormap(parula); colorbar;
xlabel('C*'); ylabel('评分标准差');
title(sprintf('分歧 vs C* (r=%.3f)', corr(C_val, std_per_stim)));
grid on;

subplot(2,3,3);
scatter(h_val, std_per_stim, 60, 'filled', 'CData', std_per_stim);
colormap(parula); colorbar;
xlabel('h (deg)'); ylabel('评分标准差');
title(sprintf('分歧 vs h (r=%.3f)', corr(h_val, std_per_stim)));
grid on;

subplot(2,3,4);
scatter(a_val, b_val, 80, std_per_stim, 'filled');
colormap(parula); colorbar;
xlabel('a*'); ylabel('b*');
title('刺激色域 (颜色=分歧程度)');
grid on;

subplot(2,3,5);
scatter3(L_val, a_val, b_val, 80, std_per_stim, 'filled');
xlabel('L*'); ylabel('a*'); zlabel('b*');
title('3D色空间 (颜色=分歧程度)');

subplot(2,3,6);
bar(1:3, group_means, 'FaceColor', [0.3 0.5 0.8]);
hold on;
set(gca, 'XTickLabel', {'Low L*', 'Med L*', 'High L*'});
ylabel('平均评分标准差');
title(sprintf('亮度组间分歧 (p=%.3f)', p_anova_L));
grid on;

sgtitle('刺激属性与被试间分歧的关系');
saveas(gcf, fullfile(save_folder, 'substantive_scatter.png'));
close(gcf);

% 6.2 相关性热力图
figure('Position', [100,100,700,500]);
corr_attr = corr([attr_matrix(:, 1:5), std_per_stim, range_per_stim, mae_per_stim]);
attr_corr_names = {'L*', 'a*', 'b*', 'C*', 'h', 'SD', 'Range', 'MAE'};
imagesc(corr_attr, [-1, 1]);
colorbar;
colormap(parula);
set(gca, 'XTick', 1:length(attr_corr_names), 'XTickLabel', attr_corr_names, ...
    'YTick', 1:length(attr_corr_names), 'YTickLabel', attr_corr_names);
title('刺激属性与分歧指标相关性');
for i = 1:size(corr_attr,1)
    for j = 1:size(corr_attr,2)
        text(j, i, sprintf('%.2f', corr_attr(i,j)), ...
            'HorizontalAlignment', 'center', 'FontSize', 9, 'Color', 'white');
    end
end
saveas(gcf, fullfile(save_folder, 'attribute_correlation_heatmap.png'));
close(gcf);

% 6.3 分歧最大的刺激在色空间中的位置
figure('Position', [100,100,800,600]);
scatter(a_val, b_val, 150, std_per_stim, 'filled');
colormap(parula); colorbar;
hold on;
% 标注分歧最大的5个刺激
for ii = 1:5
    s = sort_idx(ii);
    text(a_val(s), b_val(s), sprintf('S%d', s), ...
        'FontSize', 10, 'FontWeight', 'bold', 'Color', 'red');
end
xlabel('a* (red-green axis)'); ylabel('b* (yellow-blue axis)');
title('Disagreement in color space\n(color=inter-subject disagreement, number=stimulus ID)');
grid on; axis equal;
saveas(gcf, fullfile(save_folder, 'disagreement_color_space.png'));
close(gcf);

% =========================================================================
% Step 7: 解释性总结
% =========================================================================
fprintf('\n========== 解释性总结 ==========\n');
[r_best, best_attr] = max(abs([regression_results.r_pearson]));
fprintf('与分歧相关性最强的属性: %s (r=%.4f, p=%.4f)\n', ...
    regression_results(best_attr).attr, regression_results(best_attr).r_pearson, ...
    regression_results(best_attr).p_pearson);

fprintf('\n实质性解释框架:\n');
if regression_results(4).r_pearson > 0 && regression_results(4).p_pearson < 0.05
    fprintf('  * 高色度(C*)刺激 -> 被试间分歧更大（饱和度感知因文化/经验差异大）\n');
end
if regression_results(1).r_pearson > 0 && regression_results(1).p_pearson < 0.05
    fprintf('  * 高亮度(L*)刺激 -> 被试间分歧更大（亮度感知与肤色背景交互）\n');
end
if p_anova_L < 0.05
    [~, max_g] = max(group_means);
    fprintf('  * %s组被试分歧最大\n', L_groups{max_g});
end
fprintf('  * 若无显著属性 -> 分歧来自个体差异而非刺激属性本身\n');

% =========================================================================
% Step 8: 保存结果
% =========================================================================
results = struct();
results.std_per_stim  = std_per_stim;
results.range_per_stim = range_per_stim;
results.mae_per_stim  = mae_per_stim;
results.lab           = lab;
results.L_val = L_val; results.a_val = a_val; results.b_val = b_val;
results.C_val = C_val; results.h_val = h_val;
results.attr_names    = attr_names;
results.attr_matrix   = attr_matrix;
results.regression    = regression_results;
results.b_reg         = b_reg;
results.stats_reg     = stats;
results.p_anova_L     = p_anova_L;

save(fullfile(save_folder, 'substantive_results.mat'), 'results');
fprintf('\n========== 分析完成 ==========\n');
fprintf('结果保存至: %s\n', fullfile(save_folder, 'substantive_results.mat'));

%% ========================================================================
% 辅助函数
% ========================================================================
function result = ternary(condition, true_val, false_val)
    if condition, result = true_val; else, result = false_val; end
end
