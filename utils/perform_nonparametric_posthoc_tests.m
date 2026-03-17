function posthoc_results = perform_nonparametric_posthoc_tests(data_cell, group_names, varargin)
% 执行非参数事后多重比较检验（Dunn检验、Conover检验等）
% 
% 输入参数：
%   data_cell - 包含各组数据的元胞数组，每个元胞为n×d矩阵
%   group_names - 组名元胞数组
%   varargin - 可选参数：
%     'Method' - 非参数事后检验方法，可选：
%               'dunn' (默认), 'conover', 'dscf', 'nemenyi', 'steel-dwass'
%     'Alpha' - 显著性水平，默认0.05
%     'Display' - 是否显示结果，默认true
%     'ExportExcel' - 是否导出到Excel，默认false
%     'ExcelPath' - Excel保存路径（如果ExportExcel为true）
% 
% 输出参数：
%   posthoc_results - 包含所有检验结果的结构体

%% 参数解析
p = inputParser;
addRequired(p, 'data_cell', @iscell);
addRequired(p, 'group_names', @iscell);
addParameter(p, 'Method', 'dunn', @ischar);
addParameter(p, 'Alpha', 0.05, @(x) x>0 && x<1);
addParameter(p, 'Display', true, @islogical);
addParameter(p, 'ExportExcel', false, @islogical);
addParameter(p, 'ExcelPath', '', @ischar);
parse(p, data_cell, group_names, varargin{:});

% 获取参数
method = lower(p.Results.Method);
alpha = p.Results.Alpha;
display_results = p.Results.Display;
export_excel = p.Results.ExportExcel;
excel_path = p.Results.ExcelPath;

%% 数据验证
k = length(data_cell);  % 组数
if k < 3
    error('事后检验需要至少3组数据');
end

if length(group_names) ~= k
    error('组名数量必须与数据组数一致');
end

% 检查数据维度
num_dims = size(data_cell{1}, 2);
sample_sizes = zeros(1, k);
for i = 1:k
    if size(data_cell{i}, 2) ~= num_dims
        error('所有组的数据必须有相同的维度数');
    end
    sample_sizes(i) = size(data_cell{i}, 1);
end

%% 初始化结果结构
posthoc_results = struct();
posthoc_results.Method = method;
posthoc_results.Alpha = alpha;
posthoc_results.NumGroups = k;
posthoc_results.NumDimensions = num_dims;
posthoc_results.GroupNames = group_names;
posthoc_results.SampleSizes = sample_sizes;

% 存储各组的秩和
posthoc_results.GroupRanks = cell(1, num_dims);
% 存储各维度检验结果
for dim = 1:num_dims
    posthoc_results.(['Dim_' num2str(dim)]) = struct();
end

%% 对每个维度分别进行事后检验
for dim = 1:num_dims
    if display_results
        fprintf('\n=== 维度 %d 非参数事后检验 ===\n', dim);
        fprintf('方法: %s\n', method);
        fprintf('显著性水平: α = %.3f\n', alpha);
    end
    
    % 准备当前维度的数据
    all_data = [];
    group_labels = [];
    group_data = cell(1, k);
    
    for i = 1:k
        current_data = data_cell{i}(:, dim);
        all_data = [all_data; current_data];
        group_labels = [group_labels; i * ones(size(current_data))];
        group_data{i} = current_data;
    end
    
    N = length(all_data);  % 总样本数
    
    %% 步骤1: 计算所有数据的秩
    [ranks, tieadj] = tiedrank(all_data);
    
    % 计算各组的秩和
    group_ranks = zeros(1, k);
    group_mean_ranks = zeros(1, k);
    for i = 1:k
        group_mask = (group_labels == i);
        group_ranks(i) = sum(ranks(group_mask));
        group_mean_ranks(i) = mean(ranks(group_mask));
    end
    
    % 存储秩信息
    posthoc_results.GroupRanks{dim} = struct(...
        'Ranks', ranks, ...
        'GroupRanks', group_ranks, ...
        'MeanRanks', group_mean_ranks, ...
        'TieAdjustment', tieadj);
    
    %% 步骤2: 进行Kruskal-Wallis检验（如果需要）
    [kw_p, kw_tbl] = kruskalwallis(all_data, group_labels, 'off');
    kw_chi2 = kw_tbl{2, 5};
    kw_df = kw_tbl{2, 3};
    
    %% 步骤3: 执行选择的事后检验方法
    switch method
        case 'dunn'
            % Dunn检验（最常用的非参数事后检验）
            result = perform_dunn_posthoc(group_data, group_mean_ranks, N, ...
                                          tieadj, alpha, group_names, display_results);
            
        case 'conover'
            % Conover检验
            result = perform_conover_posthoc(group_data, group_ranks, N, ...
                                             sample_sizes, tieadj, alpha, group_names, display_results);
            
        case 'nemenyi'
            % Nemenyi检验（用于Friedman检验的事后）
            result = perform_nemenyi_posthoc(group_mean_ranks, N, sample_sizes, ...
                                            tieadj, alpha, group_names, display_results);
            
        case 'steel-dwass'
            % Steel-Dwass检验（非参数多重比较，适用于方差不齐）
            result = perform_steel_dwass_posthoc(group_data, alpha, group_names, display_results);
            
        otherwise
            error('不支持的方法: %s。支持的方法: dunn, conover, nemenyi, steel-dwass', method);
    end
    
    %% 存储维度结果
    dim_result = struct();
    dim_result.Dimension = dim;
    dim_result.KW_Chi2 = kw_chi2;
    dim_result.KW_df = kw_df;
    dim_result.KW_p = kw_p;
    dim_result.TotalN = N;
    dim_result.MeanRanks = group_mean_ranks;
    dim_result.Comparisons = result.Comparisons;
    dim_result.PValues = result.PValues;
    dim_result.AdjustedPValues = result.AdjustedPValues;
    dim_result.Significant = result.Significant;
    dim_result.ComparisonTable = result.ComparisonTable;
    dim_result.SignificantComparisons = result.SignificantComparisons;
    
    posthoc_results.(['Dim_' num2str(dim)]) = dim_result;
    
    %% 显示结果
    if display_results
        fprintf('\nKruskal-Wallis检验结果: χ²(%d) = %.4f, p = %.6f\n', ...
            kw_df, kw_chi2, kw_p);
        
        if kw_p < alpha
            fprintf('总体检验显著，进行%s事后检验:\n', method);
        else
            fprintf('总体检验不显著，但仍进行%s事后检验作为探索性分析:\n', method);
        end
        
        fprintf('\n各组平均秩:\n');
        for i = 1:k
            fprintf('  %s: %.4f\n', group_names{i}, group_mean_ranks(i));
        end
        
        % 显示比较结果
        if ~isempty(result.ComparisonTable)
            fprintf('\n%s事后检验结果:\n', upper(method));
            fprintf('%-25s %-15s %-15s %-15s\n', ...
                '比较组', '统计量Z', '原始p值', '校正p值');
            fprintf('%s\n', repmat('-', 70, 1));
            
            table_data = result.ComparisonTable;
            for i = 2:size(table_data, 1)
                fprintf('%-25s %-15.4f %-15.6f %-15.6f\n', ...
                    table_data{i, 1}, ...
                    table_data{i, 2}, ...
                    table_data{i, 3}, ...
                    table_data{i, 4});
                
                % 显示显著性
                if table_data{i, 5}
                    fprintf('%67s\n', '** 显著 **');
                else
                    fprintf('%67s\n', '不显著');
                end
            end
            
            % 显示显著性总结
            sig_comps = result.SignificantComparisons;
            if ~isempty(sig_comps)
                fprintf('\n显著的比较组 (校正后p < %.3f):\n', alpha);
                for j = 1:length(sig_comps)
                    fprintf('  %s\n', sig_comps{j});
                end
            else
                fprintf('\n没有发现显著的比较组。\n');
            end
        end
    end
end

%% 导出到Excel
if export_excel
    if isempty(excel_path)
        excel_path = pwd;
    end
    filename = sprintf('nonparametric_posthoc_%s_results.xlsx', method);
    fullpath = fullfile(excel_path, filename);
    
    export_nonparametric_results(posthoc_results, fullpath);
    
    if display_results
        fprintf('\n结果已导出到: %s\n', fullpath);
    end
end

%% 可选：绘制结果图
% if display_results
%     plot_choice = input('\n是否绘制事后检验结果图？(y/n): ', 's');
%     if strcmpi(plot_choice, 'y')
%         plot_nonparametric_posthoc(posthoc_results);
%     end
% end

end

%% ========== 辅助函数：Dunn检验 ==========
function result = perform_dunn_posthoc(group_data, mean_ranks, N, tieadj, alpha, group_names, display_results)
    k = length(group_data);
    result = struct();
    
    % 计算比较矩阵
    comparisons = nchoosek(1:k, 2);
    num_comps = size(comparisons, 1);
    
    z_stats = zeros(num_comps, 1);
    p_values = zeros(num_comps, 1);
    
    % 计算Dunn检验的Z统计量
    for comp = 1:num_comps
        i = comparisons(comp, 1);
        j = comparisons(comp, 2);
        
        % 样本量
        ni = length(group_data{i});
        nj = length(group_data{j});
        
        % 平均秩差
        rank_diff = mean_ranks(i) - mean_ranks(j);
        
        % 标准误差
        SE = sqrt((N*(N+1)/12 - tieadj/(12*(N-1))) * (1/ni + 1/nj));
        
        % Z统计量
        z_stats(comp) = rank_diff / SE;
        
        % 双尾p值
        p_values(comp) = 2 * (1 - normcdf(abs(z_stats(comp))));
    end
    
    % 多重比较校正（Bonferroni）
    adjusted_p = p_values * num_comps;  % Bonferroni校正
    adjusted_p = min(adjusted_p, 1);    % 确保不超过1
    
    % 创建比较表
    comparison_table = cell(num_comps + 1, 6);
    comparison_table{1, 1} = '比较组';
    comparison_table{1, 2} = 'Z统计量';
    comparison_table{1, 3} = '原始p值';
    comparison_table{1, 4} = '校正p值';
    comparison_table{1, 5} = '显著性';
    comparison_table{1, 6} = '平均秩差';
    
    significant_comparisons = {};
    
    for comp = 1:num_comps
        i = comparisons(comp, 1);
        j = comparisons(comp, 2);
        
        comp_name = sprintf('%s vs %s', group_names{i}, group_names{j});
        is_significant = adjusted_p(comp) < alpha;
        
        comparison_table{comp+1, 1} = comp_name;
        comparison_table{comp+1, 2} = z_stats(comp);
        comparison_table{comp+1, 3} = p_values(comp);
        comparison_table{comp+1, 4} = adjusted_p(comp);
        comparison_table{comp+1, 5} = is_significant;
        comparison_table{comp+1, 6} = mean_ranks(i) - mean_ranks(j);
        
        if is_significant
            significant_comparisons{end+1} = comp_name;
        end
    end
    
    % 存储结果
    result.Comparisons = comparisons;
    result.ZStats = z_stats;
    result.PValues = p_values;
    result.AdjustedPValues = adjusted_p;
    result.Significant = adjusted_p < alpha;
    result.ComparisonTable = comparison_table;
    result.SignificantComparisons = significant_comparisons;
end

%% ========== 辅助函数：Conover检验 ==========
function result = perform_conover_posthoc(group_data, group_ranks, N, sample_sizes, tieadj, alpha, group_names, display_results)
    k = length(group_data);
    result = struct();
    
    comparisons = nchoosek(1:k, 2);
    num_comps = size(comparisons, 1);
    
    t_stats = zeros(num_comps, 1);
    p_values = zeros(num_comps, 1);
    
    % 计算Conover检验的t统计量
    for comp = 1:num_comps
        i = comparisons(comp, 1);
        j = comparisons(comp, 2);
        
        ni = sample_sizes(i);
        nj = sample_sizes(j);
        
        % 平均秩
        mean_rank_i = group_ranks(i) / ni;
        mean_rank_j = group_ranks(j) / nj;
        
        % 秩方差
        rank_var = (N*(N+1)/12 - tieadj/(12*(N-1)));
        
        % t统计量
        t_stats(comp) = (mean_rank_i - mean_rank_j) / ...
                       sqrt(rank_var * (1/ni + 1/nj) * ((N-1-kw_stat)/(N-k)));
        
        % 自由度
        df = N - k;
        
        % 双尾p值
        p_values(comp) = 2 * (1 - tcdf(abs(t_stats(comp)), df));
    end
    
    % 校正p值（Bonferroni）
    adjusted_p = p_values * num_comps;
    adjusted_p = min(adjusted_p, 1);
    
    % 创建比较表
    comparison_table = cell(num_comps + 1, 7);
    comparison_table{1, 1} = '比较组';
    comparison_table{1, 2} = 't统计量';
    comparison_table{1, 3} = '自由度';
    comparison_table{1, 4} = '原始p值';
    comparison_table{1, 5} = '校正p值';
    comparison_table{1, 6} = '显著性';
    comparison_table{1, 7} = '平均秩差';
    
    significant_comparisons = {};
    
    for comp = 1:num_comps
        i = comparisons(comp, 1);
        j = comparisons(comp, 2);
        
        comp_name = sprintf('%s vs %s', group_names{i}, group_names{j});
        is_significant = adjusted_p(comp) < alpha;
        
        comparison_table{comp+1, 1} = comp_name;
        comparison_table{comp+1, 2} = t_stats(comp);
        comparison_table{comp+1, 3} = N - k;
        comparison_table{comp+1, 4} = p_values(comp);
        comparison_table{comp+1, 5} = adjusted_p(comp);
        comparison_table{comp+1, 6} = is_significant;
        comparison_table{comp+1, 7} = group_ranks(i)/sample_sizes(i) - group_ranks(j)/sample_sizes(j);
        
        if is_significant
            significant_comparisons{end+1} = comp_name;
        end
    end
    
    result.Comparisons = comparisons;
    result.TStats = t_stats;
    result.PValues = p_values;
    result.AdjustedPValues = adjusted_p;
    result.Significant = adjusted_p < alpha;
    result.ComparisonTable = comparison_table;
    result.SignificantComparisons = significant_comparisons;
end

%% ========== 辅助函数：导出到Excel ==========
function export_nonparametric_results(results, filepath)
    % 创建工作簿
    if exist(filepath, 'file')
        delete(filepath);
    end
    
    k = results.NumGroups;
    num_dims = results.NumDimensions;
    
    %% 工作表1: 汇总表
    summary_table = cell(num_dims * (k*(k-1)/2 + 3), 8);
    row_idx = 1;
    
    for dim = 1:num_dims
        dim_result = results.(['Dim_' num2str(dim)]);
        
        % 添加维度标题
        summary_table{row_idx, 1} = sprintf('=== 维度 %d ===', dim);
        row_idx = row_idx + 1;
        
        % Kruskal-Wallis结果
        summary_table{row_idx, 1} = 'Kruskal-Wallis检验:';
        summary_table{row_idx, 2} = dim_result.KW_Chi2;
        summary_table{row_idx, 3} = dim_result.KW_df;
        summary_table{row_idx, 4} = dim_result.KW_p;
        summary_table{row_idx, 5} = dim_result.KW_p < results.Alpha;
        row_idx = row_idx + 1;
        
        % 平均秩
        summary_table{row_idx, 1} = '各组平均秩:';
        row_idx = row_idx + 1;
        for i = 1:k
            summary_table{row_idx, 1} = results.GroupNames{i};
            summary_table{row_idx, 2} = dim_result.MeanRanks(i);
            row_idx = row_idx + 1;
        end
        row_idx = row_idx + 1;  % 空行
        
        % 事后比较结果
        if ~isempty(dim_result.ComparisonTable)
            table_data = dim_result.ComparisonTable;
            for i = 1:size(table_data, 1)
                for j = 1:size(table_data, 2)
                    summary_table{row_idx, j} = table_data{i, j};
                end
                row_idx = row_idx + 1;
            end
        end
        
        row_idx = row_idx + 2;  % 维度间空行
    end
    
    writecell(summary_table, filepath, 'Sheet', '汇总结果');
    
    %% 工作表2: 详细比较
    detailed_table = {};
    row_idx = 1;
    
    for dim = 1:num_dims
        dim_result = results.(['Dim_' num2str(dim)]);
        
        if ~isempty(dim_result.ComparisonTable)
            table_data = dim_result.ComparisonTable;
            
            % 添加维度标题
            detailed_table{row_idx, 1} = sprintf('维度 %d - %s事后检验', dim, upper(results.Method));
            row_idx = row_idx + 1;
            
            % 复制表头
            for j = 1:size(table_data, 2)
                detailed_table{row_idx, j} = table_data{1, j};
            end
            row_idx = row_idx + 1;
            
            % 复制数据
            for i = 2:size(table_data, 1)
                for j = 1:size(table_data, 2)
                    detailed_table{row_idx, j} = table_data{i, j};
                end
                row_idx = row_idx + 1;
            end
            
            row_idx = row_idx + 2;  % 维度间空行
        end
    end
    
    if ~isempty(detailed_table)
        writecell(detailed_table, filepath, 'Sheet', '详细比较');
    end
    
    %% 工作表3: 显著性总结
    sig_table = cell(num_dims + 1, 3);
    sig_table{1, 1} = '维度';
    sig_table{1, 2} = 'K-W检验显著性';
    sig_table{1, 3} = '显著的事后比较';
    
    for dim = 1:num_dims
        dim_result = results.(['Dim_' num2str(dim)]);
        
        sig_table{dim+1, 1} = dim;
        sig_table{dim+1, 2} = dim_result.KW_p < results.Alpha;
        
        if ~isempty(dim_result.SignificantComparisons)
            sig_str = strjoin(dim_result.SignificantComparisons, '; ');
        else
            sig_str = '无';
        end
        sig_table{dim+1, 3} = sig_str;
    end
    
    writecell(sig_table, filepath, 'Sheet', '显著性总结');
end