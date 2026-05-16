close all; clc; clear;
addpath("utils\")
%% =========================================================================
% 逐被试STRESS分析 - 识别离群被试
% 目标：计算每个被试的 individual inter-STRESS，找出拉高整体均值的离群被试
% =========================================================================

% 加载数据
load(fullfile('level_data', 'labNscore_level_p10.mat'));  % score_level: n_stim × n_subj
fprintf('数据维度: %d个刺激 × %d个被试\n', size(score_level,1), size(score_level,2));

X = score_level';       % n_subjects × n_stimuli
n_subjects = size(X, 1);
n_stimuli  = size(X, 2);

% 评分归一化到[0,1]（假设原始范围-3~3）
X_scaled = (X - (-3)) / 6;

% 整体均值向量
mean_scaled = mean(X_scaled, 1);   % 1 × n_stimuli

% =========================================================================
% Step 1: 计算逐被试STRESS
% =========================================================================
STRESS_i = zeros(n_subjects, 1);
for i = 1:n_subjects
    STRESS_i(i) = STRESS1(X_scaled(i, :)', mean_scaled');
end

STRESS_overall_mean = mean(STRESS_i);
STRESS_overall_std  = std(STRESS_i);
STRESS_overall_median = median(STRESS_i);

fprintf('\n========== 整体STRESS统计 ==========\n');
fprintf('均值:   %.4f\n', STRESS_overall_mean);
fprintf('中位数: %.4f\n', STRESS_overall_median);
fprintf('标准差: %.4f\n', STRESS_overall_std);
fprintf('最小:   %.4f (被试%d)\n', min(STRESS_i), find(STRESS_i == min(STRESS_i)));
fprintf('最大:   %.4f (被试%d)\n', max(STRESS_i), find(STRESS_i == max(STRESS_i)));

% =========================================================================
% Step 2: 离群被试识别（多标准）
% =========================================================================
fprintf('\n========== 离群被试识别 ==========\n');

% 标准1: STRESS > 均值 + 1.5*标准差
outlier_zscore = find(STRESS_i > STRESS_overall_mean + 1.5 * STRESS_overall_std);
% 标准2: STRESS > 90th percentile
p90 = prctile(STRESS_i, 90);
outlier_p90 = find(STRESS_i > p90);
% 标准3: STRESS > 1.5倍中位数
outlier_median = find(STRESS_i > 1.5 * STRESS_overall_median);
% 标准4: STRESS > 整体均值（正面离群：极端偏高）
outlier_above_mean = find(STRESS_i > STRESS_overall_mean);

fprintf('\n标准1 (Z-score > 1.5): 被试 %s\n', mat2str(outlier_zscore'));
fprintf('标准2 (90th pct): 被试 %s (p90=%.4f)\n', mat2str(outlier_p90'), p90);
fprintf('标准3 (>1.5×median): 被试 %s\n', mat2str(outlier_median'));
fprintf('标准4 (高于均值): 被试 %s\n', mat2str(outlier_above_mean'));

% 综合离群被试（至少被两个标准识别）
outlier_count = zeros(n_subjects, 1);
for idx = outlier_zscore(:)',  outlier_count(idx) = outlier_count(idx) + 1; end
for idx = outlier_p90(:)',      outlier_count(idx) = outlier_count(idx) + 1; end
for idx = outlier_median(:)',  outlier_count(idx) = outlier_count(idx) + 1; end

outliers_final = find(outlier_count >= 2);
fprintf('\n综合离群被试 (被≥2个标准识别): %s\n', mat2str(outliers_final'));

% =========================================================================
% Step 3: 统计被试评分特征（辅助解释离群原因）
% =========================================================================
fprintf('\n========== 被试评分特征分析 ==========\n');
fprintf('%-6s %-8s %-8s %-8s %-8s %-8s %-6s\n', ...
    '被试', '均值', '标准差', '范围', '偏度', '峰度', 'STRESS');
fprintf('%s\n', repmat('-',1,58));

for i = 1:n_subjects
    scores = X(i, :);
    s_stats = struct('mean', mean(scores), 'std', std(scores), ...
        'range', max(scores)-min(scores), 'skew', skewness(scores), ...
        'kurt', kurtosis(scores));
    flag = ternary(any(outliers_final == i), ' ★', '');
    fprintf('%-6d %-8.3f %-8.3f %-8.3f %-8.3f %-8.3f %-6.4f%s\n', ...
        i, s_stats.mean, s_stats.std, s_stats.range, s_stats.skew, s_stats.kurt, STRESS_i(i), flag);
end

% =========================================================================
% Step 4: 可视化
% =========================================================================
save_folder = fullfile('AnalyseResults_p', 'single_stress');
if ~exist(save_folder, 'dir'), mkdir(save_folder); end

% 4.1 逐被试STRESS条形图（排序）
[sorted_STRESS, sort_idx] = sort(STRESS_i, 'descend');
figure('Position', [100,100,900,500]);
bar(1:n_subjects, sorted_STRESS, 'FaceColor', [0.3 0.5 0.8]);
hold on;
yline(STRESS_overall_mean, 'r--', 'LineWidth', 2, 'DisplayName', sprintf('均值=%.4f', STRESS_overall_mean));
yline(p90, 'g--', 'LineWidth', 1.5, 'DisplayName', sprintf('90th%%=%.4f', p90));
% 标注离群被试
for ii = 1:n_subjects
    if any(outliers_final == sort_idx(ii))
        bar(ii, sorted_STRESS(ii), 'FaceColor', [0.9 0.2 0.2]);
        text(ii, sorted_STRESS(ii) + 0.01, sprintf('S%d', sort_idx(ii)), ...
            'HorizontalAlignment', 'center', 'FontSize', 9);
    end
end
xlabel('被试 (按STRESS降序)');
ylabel('Inter-STRESS');
title(sprintf('逐被试Inter-STRESS (离群被试标红★)\n均值=%.4f, 标准差=%.4f', ...
    STRESS_overall_mean, STRESS_overall_std));
legend({'STRESS', '均值', '90th percentile'}, 'Location', 'best');
grid on;
saveas(gcf, fullfile(save_folder, 'single_STRESS_bar.png'));
close(gcf);

% 4.2 STRESS vs 评分标准差（解释性散点图）
std_scores = std(X, 0, 2);
figure('Position', [100,100,700,500]);
scatter(std_scores, STRESS_i, 80, 'filled', 'CData', STRESS_i);
colormap(parula);
colorbar;
xlabel('被试评分标准差');
ylabel('Inter-STRESS');
title('STRESS vs 评分变异性\n（高标准差+高STRESS=评分极端但不稳定）');
grid on;
% 标注离群被试
for i = outliers_final(:)'
    [~, xi] = find(sort_idx == i);
    text(std_scores(i)+0.01, STRESS_i(i), sprintf('S%d', i), 'FontSize', 9);
end
saveas(gcf, fullfile(save_folder, 'STRESS_vs_std.png'));
close(gcf);

% 4.3 箱线图 + 个体点
figure('Position', [100,100,600,400]);
boxplot(STRESS_i, 'BoxStyle', 'filled');
hold on;
scatter(1:1:n_subjects, STRESS_i, 50, 'k', 'filled', 'MarkerFaceAlpha', 0.6);
% 离群点标红
for i = outliers_final(:)'
    scatter(1, STRESS_i(i), 80, 'r', 'filled');
end
xlabel('所有被试');
ylabel('Inter-STRESS');
title(sprintf('STRESS分布 (★=离群被试)\n均值=%.4f, 中位数=%.4f', ...
    STRESS_overall_mean, STRESS_overall_median));
grid on;
saveas(gcf, fullfile(save_folder, 'STRESS_boxplot.png'));
close(gcf);

% 4.4 评分模式热力图（按STRESS排序）
[~, visual_order] = sort(STRESS_i, 'descend');
X_visual = X(visual_order, :);
figure('Position', [100,100,900,400]);
imagesc(X_visual);
colorbar;
colormap(parula);
xlabel('刺激编号');
ylabel('被试 (STRESS降序)');
title('评分模式热力图 (按STRESS降序排列)');
% 标注离群被试
outlier_visual_pos = find(ismember(visual_order, outliers_final));
for pos = outlier_visual_pos(:)'
    rectangle('Position', [0.5, pos-0.5, n_stimuli, 1], ...
        'EdgeColor', 'r', 'LineWidth', 2, 'FaceColor', 'none');
end
saveas(gcf, fullfile(save_folder, 'score_pattern_heatmap.png'));
close(gcf);

% 4.5 评分偏度 vs STRESS（判断是否是"极端评分者"）
skew_scores = skewness(X, 0, 2);
kurt_scores = kurtosis(X, 0, 2);

figure('Position', [100,100,1100,400]);
subplot(1,3,1);
scatter(std_scores, STRESS_i, 50, 'filled');
xlabel('评分标准差'); ylabel('STRESS');
title('变异性 vs STRESS'); grid on;

subplot(1,3,2);
scatter(abs(skew_scores), STRESS_i, 50, 'filled');
xlabel('|偏度|'); ylabel('STRESS');
title('评分偏度 vs STRESS\n(高|偏度|=极端倾向)');
grid on;

subplot(1,3,3);
scatter(kurt_scores, STRESS_i, 50, 'filled');
xlabel('峰度'); ylabel('STRESS');
title('评分峰度 vs STRESS\n(高峰度=极端值多)');
grid on;

sgtitle('离群原因诊断');
saveas(gcf, fullfile(save_folder, 'outlier_diagnosis.png'));
close(gcf);

% =========================================================================
% Step 5: 保存结果
% =========================================================================
results = struct();
results.STRESS_i        = STRESS_i;
results.STRESS_mean     = STRESS_overall_mean;
results.STRESS_std      = STRESS_overall_std;
results.STRESS_median   = STRESS_overall_median;
results.outliers_zscore = outlier_zscore;
results.outliers_p90    = outlier_p90;
results.outliers_median = outlier_median;
results.outliers_final  = outliers_final;
results.std_scores      = std_scores;
results.skew_scores     = skew_scores;
results.kurt_scores     = kurt_scores;
results.X               = X;
results.n_subjects      = n_subjects;
results.n_stimuli       = n_stimuli;

save(fullfile(save_folder, 'single_STRESS_results.mat'), 'results');

fprintf('\n========== 分析完成 ==========\n');
fprintf('离群被试建议: %s\n', mat2str(outliers_final));
fprintf('结果保存至: %s\n', fullfile(save_folder, 'single_STRESS_results.mat'));

%% ========================================================================
% 辅助函数
% ========================================================================
function result = ternary(condition, true_val, false_val)
    if condition, result = true_val; else, result = false_val; end
end
