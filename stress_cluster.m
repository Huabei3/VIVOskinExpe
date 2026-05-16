% stress_cluster.m
% 聚类分析：对 stimulus 进行层次聚类 + K-means
% score_all_scaled: n_stimuli × n_observers，每行是一个刺激位点，每列是一个observer
% 聚类目标：按评分模式对刺激位点分组

%% 清理环境
clear; clc; close all;
addpath('D:\work\VIVOskinExpe\analyze');

%% 参数设置
source_folder = 'D:\work\VIVOskinExpe\skin_projectV7\B_data_analysis\results_CAT';
Dtype = 'unscaled';
scale_type_origin = 'efit_p';
n_bootstrap = 500;

%% 获取所有lastPart
all_items = dir(source_folder);
lastParts = all_items([all_items.isdir] & ...
    ~ismember({all_items.name}, {'.', '..'}));
lastParts = lastParts(startsWith({lastParts.name}, 'last'));

fprintf('发现 %d 个 lastPart 目录\n', length(lastParts));

%% 主循环
for i_dir = 1:length(lastParts)
    lastPart = lastParts(i_dir).name;

    % 遍历属性
    for attribute = 1:7
        fprintf('\n============================================================\n');
        fprintf('Processing: %s, Attribute: %d\n', lastPart, attribute);

        % 输出目录
        save_folder = fullfile('D:\work\VIVOskinExpe\analyze\AnalyseResults_p', ...
            Dtype, scale_type_origin, 'cluster_analysis', ...
            strrep(lastPart, 'add', ''), 'non_model', sprintf('%02d', attribute));
        if ~exist(save_folder, 'dir')
            mkdir(save_folder);
        end

        %% =======================================================================
        % Step 1: 构建 score_all_scaled（参照 process_data_CAT_p.m）
        % =======================================================================
        attribute_serial = sprintf('%02d', attribute);

        % 获取当前属性所有observer的目录
        dir_res = dir(fullfile(source_folder, lastPart, attribute_serial, 'obs*'));

        if isempty(dir_res)
            fprintf('  No data found for this attribute.\n');
            continue;
        end

        n_file = length(dir_res);
        fprintf('  找到 %d 个 observer 文件\n', n_file);

        % 确定 lab 位置数量（从第一个文件读取）
        first_data = readtable(fullfile(dir_res(1).folder, dir_res(1).name));
        n_lab = max(first_data.lab) + 1;
        fprintf('  n_lab=%d, n_file=%d\n', n_lab, n_file);

        score_all = zeros(n_lab, n_file);  % stimuli × observers

        for i_file = 1:n_file
            data = readtable(fullfile(dir_res(i_file).folder, dir_res(i_file).name));

            result_cell = {};
            for k = 1:height(data)
                labs = regexp(data.lab{k}, '\d+', 'match');
                scores = data.score(k);
                for j = 1:length(labs)
                    result_cell{end+1, 1} = str2double(labs{j});
                    result_cell{end, 2} = j;
                    result_cell{end, 3} = scores;
                end
            end

            result_cell = sortrows(result_cell, 1);

            score_lab = zeros(max(cell2mat(result_cell(:, 1))) + 1, 1);
            for i_lab = 0:max(cell2mat(result_cell(:, 1)))
                num_scores = find(cell2mat(result_cell(:, 1)) == i_lab);
                score_lab(i_lab + 1) = mean(cell2mat(result_cell(num_scores, 3)));
            end

            score_all(:, i_file) = score_lab;
        end

        fprintf('  构建完成: score_all = %d stimuli × %d observers\n', n_lab, n_file);

        % Z-score 标准化（每行归一化到[0,1]，对应 process_data_CAT_p 的处理）
        score_all_scaled = (score_all - 1) ./ 5;  % (原始评分-1)/5 映射到[0,1]

        %% =======================================================================
        % Step 2: 聚类分析（对 stimuli 聚类）
        % =======================================================================
        X = score_all_scaled;
        n_stim = size(X, 1);
        n_obs = size(X, 2);

        fprintf('\n  聚类矩阵: %d stimuli × %d observers\n', n_stim, n_obs);

        % 数据预处理：去重
        [X_unique, ~, ~] = unique(X, 'rows');
        n_unique = size(X_unique, 1);
        if n_unique < n_stim
            fprintf('  警告: 发现 %d 个重复行，去重后 n=%d\n', n_stim - n_unique, n_unique);
            X = X_unique;
            n_stim = n_unique;
        end

        if n_stim < 4
            fprintf('  样本数太少，跳过\n');
            continue;
        end

        % Min-max 归一化（按列，即每个 observer）
        X_min = min(X, [], 1);
        X_max = max(X, [], 1);
        X_scaled = (X - X_min) ./ (X_max - X_min + eps);

        %% 层次聚类
        D = pdist(X_scaled, 'euclidean');
        Z = linkage(D, 'ward');

        % 树状图
        figure('Position', [100, 100, 800, 600]);
        if n_stim <= 50
            dendrogram(Z, 0);
        else
            dendrogram(Z, ceil(n_stim/2));
        end
        title(sprintf('层次聚类树状图 (%s, Attr%d, n=%d)', lastPart, attribute, n_stim));
        xlabel('刺激位点');
        ylabel('距离');
        grid on;
        saveas(gcf, fullfile(save_folder, 'dendrogram.jpg'));
        close(gcf);

        %% 确定最佳K
        max_K = min(8, floor(n_stim / 2));
        if max_K < 2
            fprintf('  样本数太少，无法聚类\n');
            continue;
        end

        silhouette_scores = zeros(max_K-1, 1);
        for K = 2:max_K
            idx_c = cluster(Z, 'MaxClust', K);
            s = silhouette(X_scaled, idx_c, 'euclidean');
            silhouette_scores(K-1) = mean(s);
        end

        figure('Position', [100, 100, 600, 400]);
        plot(2:max_K, silhouette_scores, 'bo-', 'LineWidth', 2, 'MarkerSize', 8);
        title('轮廓系数法确定K');
        xlabel('聚类数 K');
        ylabel('平均轮廓系数');
        grid on;
        [~, best_K_silhouette] = max(silhouette_scores);
        best_K = best_K_silhouette + 1;
        fprintf('  推荐 K=%d (轮廓系数=%.4f)\n', best_K, max(silhouette_scores));
        saveas(gcf, fullfile(save_folder, 'K_selection.jpg'));
        close(gcf);

        %% 执行聚类
        K = best_K;
        opts = statset('Display', 'off', 'MaxIter', 1000);

        idx_hier = cluster(Z, 'MaxClust', K);
        [idx_km, ~, ~] = kmeans(X_scaled, K, 'Distance', 'sqeuclidean', ...
            'Replicates', 50, 'Options', opts);

        % 选择更稳定的结果
        c_hier = max(histcounts(idx_hier, 1:K));
        c_km = max(histcounts(idx_km, 1:K));
        if c_km >= c_hier
            idx = idx_km;
            method = 'K-means (平方欧几里得距离)';
        else
            idx = idx_hier;
            method = '层次聚类 (Ward方法)';
        end
        fprintf('  使用方法: %s\n', method);

        %% 轮廓分析
        figure('Position', [100, 100, 800, 600]);
        [s, h] = silhouette(X_scaled, idx, 'euclidean');
        title(sprintf('轮廓分析图 (K=%d, 平均轮廓系数=%.4f)', K, mean(s)));
        xlabel('轮廓系数');
        ylabel('刺激位点');
        grid on;
        saveas(gcf, fullfile(save_folder, 'silhouette.jpg'));
        close(gcf);

        %% 各簇大小
        cluster_sizes = histcounts(idx, 1:K+1);
        fprintf('\n  各簇刺激位点数量:\n');
        for k = 1:K
            fprintf('    簇%d: %d个 (%.1f%%)\n', k, cluster_sizes(k), cluster_sizes(k)/n_stim*100);
        end

        %% STRESS分析
        fprintf('\n========== 各簇STRESS分析 ==========\n');

        mean_scaled = mean(X_scaled, 1);
        STRESS_overall = zeros(n_stim, 1);
        for i = 1:n_stim
            STRESS_overall(i) = stress_metric(X_scaled(i, :)', mean_scaled');
        end
        STRESS_overall_mean = mean(STRESS_overall);
        fprintf('  [整体] STRESS均值=%.4f\n', STRESS_overall_mean);

        STRESS_per_cluster = zeros(K, 1);
        n_per_cluster = zeros(K, 1);
        for k = 1:K
            mask_k = (idx == k);
            X_k = X_scaled(mask_k, :);
            n_k = sum(mask_k);
            n_per_cluster(k) = n_k;
            if n_k > 1
                mean_k = mean(X_k, 1);
                STRESS_k = zeros(n_k, 1);
                for i = 1:n_k
                    STRESS_k(i) = stress_metric(X_k(i, :)', mean_k');
                end
                STRESS_per_cluster(k) = mean(STRESS_k);
            else
                STRESS_per_cluster(k) = 0;
            end
            fprintf('  [簇%d] n=%d | STRESS=%.4f\n', k, n_k, STRESS_per_cluster(k));
        end

        weighted_STRESS = sum(STRESS_per_cluster .* n_per_cluster) / sum(n_per_cluster);

        %% STRESS对比图
        figure('Position', [100, 100, 1000, 500]);
        subplot(1, 2, 1);
        boxplot(STRESS_overall, idx);
        hold on;
        plot(1:K, STRESS_per_cluster, 'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'r');
        xlabel('簇编号');
        ylabel('STRESS');
        title(sprintf('各簇STRESS分布\n(整体均值=%.4f)', STRESS_overall_mean));
        grid on;

        subplot(1, 2, 2);
        bar_colors = lines(K+1);
        bar_x = 1:K+1;
        bar_heights = [STRESS_per_cluster; weighted_STRESS];
        bar_labels = arrayfun(@(k) sprintf('簇%d', k), 1:K, 'UniformOutput', false);
        bar_labels{K+1} = '加权平均';
        bar(bar_x, bar_heights, 'FaceColor', 'flat', 'CData', bar_colors);
        hold on;
        yline(STRESS_overall_mean, 'r--', 'LineWidth', 2);
        set(gca, 'XTickLabel', bar_labels);
        ylabel('STRESS');
        title(sprintf('各簇STRESS对比\n(虚线=整体均值%.4f)', STRESS_overall_mean));
        legend('Location', 'best');
        grid on;

        sgtitle(sprintf('STRESS分析 (%s, Attr%d, K=%d)', lastPart, attribute, K));
        saveas(gcf, fullfile(save_folder, 'STRESS_comparison.jpg'));
        close(gcf);

        %% Bootstrap稳定性
        fprintf('\n========== Bootstrap 稳定性检验 ==========\n');
        fprintf('  执行 %d 次重采样...\n', n_bootstrap);

        co_list = cell(n_bootstrap, 1);
        valid_count = 0;
        for b = 1:n_bootstrap
            boot_idx = randsample(n_stim, n_stim, true);
            X_boot = X_scaled(boot_idx, :);
            try
                co_list{b} = kmeans(X_boot, K, 'Distance', 'sqeuclidean', ...
                    'Replicates', 20, 'Options', opts);
                valid_count = valid_count + 1;
            catch
                co_list{b} = [];
            end
            if mod(b, 200) == 0
                fprintf('    已完成 %d/%d\n', b, n_bootstrap);
            end
        end

        co_mat = zeros(n_stim, n_stim);
        for b = 1:n_bootstrap
            bc = co_list{b};
            if ~isempty(bc)
                for i = 1:n_stim
                    for j = (i+1):n_stim
                        if bc(i) == bc(j)
                            co_mat(i,j) = co_mat(i,j) + 1;
                            co_mat(j,i) = co_mat(j,i) + 1;
                        end
                    end
                end
            end
        end
        consensus = co_mat / valid_count;

        % 共识矩阵热力图
        [sorted_idx, sort_order] = sort(idx);
        consensus_sorted = consensus(sort_order, sort_order);

        figure('Position', [100, 100, 700, 600]);
        imagesc(consensus_sorted, [0, 1]);
        colorbar;
        colormap(flipud(hot));
        caxis([0 1]);
        cumsum_k = cumsum(cluster_sizes);
        for c = 1:K-1
            line([0.5, n_stim+0.5], [cumsum_k(c)+0.5, cumsum_k(c)+0.5], ...
                'Color', 'cyan', 'LineWidth', 1.5);
            line([cumsum_k(c)+0.5, cumsum_k(c)+0.5], [0.5, n_stim+0.5], ...
                'Color', 'cyan', 'LineWidth', 1.5);
        end
        title(sprintf('Bootstrap共识矩阵 (n=%d, K=%d)', valid_count, K));
        xlabel('刺激位点');
        ylabel('刺激位点');
        saveas(gcf, fullfile(save_folder, 'bootstrap_consensus.jpg'));
        close(gcf);

        %% 保存结果
        save(fullfile(save_folder, 'cluster_results.mat'), ...
            'X_scaled', 'idx', 'Z', 'K', 'method', 'score_all_scaled', ...
            'STRESS_overall', 'STRESS_per_cluster', 'cluster_sizes', ...
            'consensus', 'best_K_silhouette', 'silhouette_scores');

        fprintf('\n  结果已保存到: %s\n', save_folder);
    end
end

fprintf('\n============================================================\n');
fprintf('全部完成！\n');
