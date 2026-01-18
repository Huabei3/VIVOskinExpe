function deltaE_results = calculate_deltaE_simple(data_cell, group_names, save_path)
% 简洁版：计算组内和组间的DeltaE2000差异
%
% 输入：
%   data_cell - 元胞数组，每组数据的Lab值在前3列
%   group_names - 组名
%   save_path - 保存路径
%
% 输出：
%   deltaE_results - 包含结果的结构体

k = length(data_cell);
intra_means = zeros(k, 1);
inter_means = zeros(k*(k-1)/2, 1);

%% 计算组内差异
for i = 1:k
    lab_data = data_cell{i}(:, 1:3);
    n = size(lab_data, 1);
    intra_matrix = zeros(n);
    
    % 计算所有样本对之间的DeltaE2000
    for m = 1:n
        for p = m+1:n
            deltaE = deltaE2000(lab_data(m, :), lab_data(p, :));
            intra_matrix(m, p) = deltaE;
            intra_matrix(p, m) = deltaE;
        end
    end
    
    % 对角线设为NaN
    intra_matrix(1:n+1:end) = NaN;
    
    % 计算组内均值（排除NaN）
    intra_means(i) = nanmean(intra_matrix(:));
end

%% 计算组间差异
group_means = cellfun(@(x) mean(x(:, 1:3), 1), data_cell, 'UniformOutput', false);
idx = 1;

for i = 1:k-1
    for j = i+1:k
        inter_means(idx) = deltaE2000(group_means{i}, group_means{j});
        idx = idx + 1;
    end
end

%% 计算最终结果
mean_intra = nanmean(intra_means);
mean_inter = mean(inter_means);

%% 显示结果
fprintf('\n组内DeltaE2000平均值: %.4f\n', mean_intra);
fprintf('组间DeltaE2000平均值: %.4f\n', mean_inter);

if mean_inter > mean_intra
    fprintf('✓ 组间差异 > 组内差异 (%.2f倍)\n', mean_inter/mean_intra);
else
    fprintf('✗ 组间差异 < 组内差异 (%.2f倍)\n', mean_inter/mean_intra);
end

%% 输出到Excel（如果路径存在）
if exist(save_path, 'dir')
    filename = fullfile(save_path, 'deltaE_simple_results.xlsx');
    
    % 创建结果表格
    results_table = {
        '统计指标', '值', '说明';
        '平均组内DeltaE2000', mean_intra, '组内样本间的平均颜色差异';
        '平均组间DeltaE2000', mean_inter, '组间均值间的平均颜色差异';
        '组间/组内比值', mean_inter/mean_intra, '比值>1表示组间差异更大';
        '比较结果', ifelse(mean_inter > mean_intra, '组间差异更大', '组内差异更大'), '';
    };
    
    % 各组详细结果
    detail_table = cell(k+1, 3);
    detail_table{1, 1} = '组名';
    detail_table{1, 2} = '样本数';
    detail_table{1, 3} = '组内DeltaE2000均值';
    
    for i = 1:k
        detail_table{i+1, 1} = group_names{i};
        detail_table{i+1, 2} = size(data_cell{i}, 1);
        detail_table{i+1, 3} = intra_means(i);
    end
    
    % 组间比较结果
    comp_table = cell(length(inter_means)+1, 3);
    comp_table{1, 1} = '比较组';
    comp_table{1, 2} = 'DeltaE2000';
    comp_table{1, 3} = '差异程度';
    
    idx = 1;
    for i = 1:k-1
        for j = i+1:k
            comp_table{idx+1, 1} = sprintf('%s vs %s', group_names{i}, group_names{j});
            comp_table{idx+1, 2} = inter_means(idx);
            comp_table{idx+1, 3} = interpret_deltaE_simple(inter_means(idx));
            idx = idx + 1;
        end
    end
    
    % 写入Excel
    writecell(results_table, filename, 'Sheet', '汇总结果');
    writecell(detail_table, filename, 'Sheet', '组内差异');
    writecell(comp_table, filename, 'Sheet', '组间比较');
    
    fprintf('结果已保存到: %s\n', filename);
end

%% 返回结果
deltaE_results.mean_intra = mean_intra;
deltaE_results.mean_inter = mean_inter;
deltaE_results.ratio = mean_inter/mean_intra;
deltaE_results.intra_values = intra_means;
deltaE_results.inter_values = inter_means;
end

%% 辅助函数：简单解释DeltaE值
function level = interpret_deltaE_simple(deltaE)
if deltaE < 1
    level = '极小';
elseif deltaE < 3
    level = '小';
elseif deltaE < 6
    level = '中等';
elseif deltaE < 10
    level = '明显';
else
    level = '非常大';
end
end

%% 辅助函数：ifelse
function result = ifelse(condition, true_val, false_val)
if condition
    result = true_val;
else
    result = false_val;
end
end