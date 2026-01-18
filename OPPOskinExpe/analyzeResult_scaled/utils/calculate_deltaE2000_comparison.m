function deltaE_results = calculate_deltaE2000_comparison(data_cell, group_names, save_path, varargin)
% 计算各组数据之间的deltaE2000颜色差异
% 特别适用于样本量小的组间比较（可计算每个样本对之间的差异）
% 
% 输入参数：
%   data_cell - 包含各组数据的元胞数组，每个元胞为n×5矩阵
%               前3列应该是Lab值（L*, a*, b*）
%   group_names - 组名元胞数组
%   save_path - 保存Excel文件的路径
%   varargin - 可选参数：
%     'DeltaEMethod' - 色差公式，'deltaE2000'(默认)或'deltaE76'
%     'CompareType' - 比较类型：
%                    'all_pairs'(所有样本对), 'mean_comparison'(只比较均值)
%     'Display' - 是否显示结果，默认true
%     'Filename' - Excel文件名，默认'deltaE2000_results.xlsx'
%     'CILevel' - 置信区间水平，默认0.95
% 
% 输出参数：
%   deltaE_results - 包含所有计算结果的结构体

%% 参数解析
p = inputParser;
addRequired(p, 'data_cell', @iscell);
addRequired(p, 'group_names', @iscell);
addRequired(p, 'save_path', @ischar);
addParameter(p, 'DeltaEMethod', 'deltaE2000', @ischar);
addParameter(p, 'CompareType', 'all_pairs', @ischar);
addParameter(p, 'Display', true, @islogical);
addParameter(p, 'Filename', 'deltaE2000_results.xlsx', @ischar);
addParameter(p, 'CILevel', 0.95, @(x) x>0 && x<1);
parse(p, data_cell, group_names, save_path, varargin{:});

% 获取参数
deltaE_method = p.Results.DeltaEMethod;
compare_type = p.Results.CompareType;
display_results = p.Results.Display;
filename = p.Results.Filename;
ci_level = p.Results.CILevel;

%% 数据验证
k = length(data_cell);  % 组数
if k < 2
    error('至少需要2组数据进行比较');
end

if length(group_names) ~= k
    error('组名数量必须与数据组数一致');
end

% 检查每组数据是否有足够的列（至少3列用于Lab值）
min_cols = 3;
for i = 1:k
    if size(data_cell{i}, 2) < min_cols
        error('第%d组数据至少需要%d列（L*, a*, b*值）', i, min_cols);
    end
end

%% 初始化结果结构
deltaE_results = struct();
deltaE_results.GroupNames = group_names;
deltaE_results.NumGroups = k;
deltaE_results.DeltaEMethod = deltaE_method;
deltaE_results.CompareType = compare_type;
deltaE_results.CILevel = ci_level;

% 存储各组基本信息
for i = 1:k
    group_data = data_cell{i};
    group_size = size(group_data, 1);
    
    deltaE_results.(['Group_' num2str(i)]) = struct(...
        'Name', group_names{i}, ...
        'Size', group_size, ...
        'LabMeans', mean(group_data(:, 1:3), 1), ...  % 前3列的平均值
        'LabStd', std(group_data(:, 1:3), 0, 1), ...
        'LabData', group_data(:, 1:3) ...  % 只保留Lab数据
    );
end

%% 计算各组Lab均值
group_means = zeros(k, 3);  % 存储各组Lab均值
for i = 1:k
    group_means(i, :) = deltaE_results.(['Group_' num2str(i)]).LabMeans;
end

%% 执行比较计算
if strcmpi(compare_type, 'all_pairs')
    % 计算所有样本对之间的deltaE2000
    results = calculate_all_pairs_deltaE(data_cell, group_names, deltaE_method, ci_level, display_results);
else
    % 只计算组均值之间的deltaE2000
    results = calculate_mean_deltaE(group_means, group_names, deltaE_method, display_results);
end

%% 合并结果
deltaE_results.PairwiseResults = results.PairwiseResults;
deltaE_results.SummaryTable = results.SummaryTable;
deltaE_results.MeanDeltaETable = results.MeanDeltaETable;
deltaE_results.InterpretationTable = results.InterpretationTable;

%% 显示结果
if display_results
    fprintf('\n=== DeltaE2000颜色差异分析结果 ===\n');
    fprintf('组数: %d\n', k);
    fprintf('色差公式: %s\n', deltaE_method);
    fprintf('比较类型: %s\n', compare_type);
    fprintf('置信水平: %.1f%%\n', ci_level*100);
    
    % 显示各组基本信息
    fprintf('\n各组Lab值统计:\n');
    fprintf('%-15s %-10s %-15s %-15s %-15s\n', ...
        '组名', '样本数', 'L*均值', 'a*均值', 'b*均值');
    fprintf('%s\n', repmat('-', 70, 1));
    
    for i = 1:k
        group_info = deltaE_results.(['Group_' num2str(i)]);
        fprintf('%-15s %-10d %-15.4f %-15.4f %-15.4f\n', ...
            group_info.Name, ...
            group_info.Size, ...
            group_info.LabMeans(1), ...
            group_info.LabMeans(2), ...
            group_info.LabMeans(3));
    end
    
    % 显示组间均值比较结果
    if ~isempty(results.MeanDeltaETable)
        fprintf('\n组间均值DeltaE2000:\n');
        fprintf('%-25s %-15s %-25s\n', ...
            '比较组', 'DeltaE2000', '差异程度');
        fprintf('%s\n', repmat('-', 65, 1));
        
        table_data = results.MeanDeltaETable;
        for i = 2:size(table_data, 1)
            fprintf('%-25s %-15.4f %-25s\n', ...
                table_data{i, 1}, ...
                table_data{i, 2}, ...
                table_data{i, 3});
        end
    end
    
    % 显示详细的成对比较结果（如果计算了）
    if strcmpi(compare_type, 'all_pairs') && ~isempty(results.SummaryTable)
        fprintf('\n组间成对DeltaE2000统计:\n');
        fprintf('%-25s %-10s %-10s %-10s %-10s %-15s %-15s\n', ...
            '比较组', '均值', '标准差', '最小值', '最大值', 'CI下限', 'CI上限');
        fprintf('%s\n', repmat('-', 85, 1));
        
        table_data = results.SummaryTable;
        for i = 2:size(table_data, 1)
            fprintf('%-25s %-10.4f %-10.4f %-10.4f %-10.4f %-15.4f %-15.4f\n', ...
                table_data{i, 1}, ...
                table_data{i, 2}, ...
                table_data{i, 3}, ...
                table_data{i, 4}, ...
                table_data{i, 5}, ...
                table_data{i, 6}, ...
                table_data{i, 7});
        end
    end
end

%% 导出结果到Excel
full_path = fullfile(save_path, filename);
fprintf('\n=== 正在导出结果到Excel文件: %s ===\n', full_path);

% 确保目录存在
if ~exist(save_path, 'dir')
    mkdir(save_path);
end

% 删除已存在的文件
if exist(full_path, 'file')
    delete(full_path);
end

try
    %% 工作表1: 各组基本信息
    info_table = cell(k + 2, 6);
    info_table{1, 1} = '组名';
    info_table{1, 2} = '样本数';
    info_table{1, 3} = 'L*均值';
    info_table{1, 4} = 'L*标准差';
    info_table{1, 5} = 'a*均值';
    info_table{1, 6} = 'a*标准差';
    info_table{1, 7} = 'b*均值';
    info_table{1, 8} = 'b*标准差';
    
    for i = 1:k
        group_info = deltaE_results.(['Group_' num2str(i)]);
        info_table{i+1, 1} = group_info.Name;
        info_table{i+1, 2} = group_info.Size;
        info_table{i+1, 3} = group_info.LabMeans(1);
        info_table{i+1, 4} = group_info.LabStd(1);
        info_table{i+1, 5} = group_info.LabMeans(2);
        info_table{i+1, 6} = group_info.LabStd(2);
        info_table{i+1, 7} = group_info.LabMeans(3);
        info_table{i+1, 8} = group_info.LabStd(3);
    end
    
    % 添加空行和色差解释
    info_table{k+2, 1} = 'DeltaE2000解释标准:';
    info_table{k+3, 1} = 'DeltaE2000值';
    info_table{k+3, 2} = '差异程度';
    info_table{k+3, 3} = '视觉感知';
    info_table{k+4, 1} = '< 1.0';
    info_table{k+4, 2} = '非常小';
    info_table{k+4, 3} = '几乎不可察觉';
    info_table{k+5, 1} = '1.0 - 2.0';
    info_table{k+5, 2} = '小';
    info_table{k+5, 3} = '经验观察者可察觉';
    info_table{k+6, 1} = '2.0 - 3.0';
    info_table{k+6, 2} = '中等';
    info_table{k+6, 3} = '可察觉但不明显';
    info_table{k+7, 1} = '3.0 - 5.0';
    info_table{k+7, 2} = '明显';
    info_table{k+7, 3} = '明显差异';
    info_table{k+8, 1} = '5.0 - 10.0';
    info_table{k+8, 2} = '大';
    info_table{k+8, 3} = '非常大差异';
    info_table{k+9, 1} = '> 10.0';
    info_table{k+9, 2} = '非常大';
    info_table{k+9, 3} = '不同颜色';
    
    writecell(info_table, full_path, 'Sheet', '基本信息');
    
    %% 工作表2: 组间均值DeltaE
    if ~isempty(results.MeanDeltaETable)
        writecell(results.MeanDeltaETable, full_path, 'Sheet', '组间均值比较');
    end
    
    %% 工作表3: 成对比较统计（如果计算了）
    if strcmpi(compare_type, 'all_pairs') && ~isempty(results.SummaryTable)
        writecell(results.SummaryTable, full_path, 'Sheet', '成对比较统计');
        
        % 工作表4: 详细的成对差异
        detailed_table = {};
        row_idx = 1;
        
        for comp = 1:size(results.PairwiseResults, 2)
            comp_result = results.PairwiseResults(comp);
            
            % 添加比较组标题
            detailed_table{row_idx, 1} = sprintf('=== %s ===', comp_result.Comparison);
            row_idx = row_idx + 1;
            
            % 添加统计摘要
            detailed_table{row_idx, 1} = '统计摘要:';
            row_idx = row_idx + 1;
            detailed_table{row_idx, 1} = '均值'; detailed_table{row_idx, 2} = comp_result.Mean;
            row_idx = row_idx + 1;
            detailed_table{row_idx, 1} = '标准差'; detailed_table{row_idx, 2} = comp_result.Std;
            row_idx = row_idx + 1;
            detailed_table{row_idx, 1} = '最小值'; detailed_table{row_idx, 2} = comp_result.Min;
            row_idx = row_idx + 1;
            detailed_table{row_idx, 1} = '最大值'; detailed_table{row_idx, 2} = comp_result.Max;
            row_idx = row_idx + 1;
            detailed_table{row_idx, 1} = sprintf('%.0f%%CI下限', ci_level*100); 
            detailed_table{row_idx, 2} = comp_result.CI_Lower;
            row_idx = row_idx + 1;
            detailed_table{row_idx, 1} = sprintf('%.0f%%CI上限', ci_level*100); 
            detailed_table{row_idx, 2} = comp_result.CI_Upper;
            row_idx = row_idx + 1;
            
            % 添加具体差异值
            if ~isempty(comp_result.AllDeltaE)
                row_idx = row_idx + 1;
                detailed_table{row_idx, 1} = '所有成对DeltaE值:';
                row_idx = row_idx + 1;
                
                % 按矩阵形式排列
                n1 = comp_result.Size1;
                n2 = comp_result.Size2;
                deltaE_matrix = reshape(comp_result.AllDeltaE, n2, n1)';
                
                % 添加行标签和列标签
                detailed_table{row_idx, 1} = '样本';
                for j = 1:n2
                    detailed_table{row_idx, j+1} = sprintf('组2-%d', j);
                end
                row_idx = row_idx + 1;
                
                for i = 1:n1
                    detailed_table{row_idx, 1} = sprintf('组1-%d', i);
                    for j = 1:n2
                        detailed_table{row_idx, j+1} = deltaE_matrix(i, j);
                    end
                    row_idx = row_idx + 1;
                end
            end
            
            row_idx = row_idx + 2;  % 比较组间空行
        end
        
        if ~isempty(detailed_table)
            writecell(detailed_table, full_path, 'Sheet', '详细成对差异');
        end
    end
    
    %% 工作表5: 色差解释
    interpretation_table = results.InterpretationTable;
    if ~isempty(interpretation_table)
        writecell(interpretation_table, full_path, 'Sheet', '色差解释');
    end
    
    fprintf('Excel文件已成功创建: %s\n', full_path);
    fprintf('包含的工作表:\n');
    fprintf('  1. 基本信息 - 各组Lab值统计和色差解释标准\n');
    if ~isempty(results.MeanDeltaETable)
        fprintf('  2. 组间均值比较 - 各组均值之间的DeltaE2000\n');
    end
    if strcmpi(compare_type, 'all_pairs')
        fprintf('  3. 成对比较统计 - 组间所有样本对的DeltaE统计\n');
        fprintf('  4. 详细成对差异 - 每对样本的具体DeltaE值\n');
    end
    fprintf('  5. 色差解释 - 根据DeltaE值的差异程度解释\n');
    
catch ME
    error('导出Excel文件失败: %s', ME.message);
end

%% 可选：绘制结果图
if display_results
    plot_choice = input('\n是否绘制DeltaE结果图？(y/n): ', 's');
    if strcmpi(plot_choice, 'y')
        plot_deltaE_results(deltaE_results, save_path);
    end
end
end

%% ========== 辅助函数：计算所有样本对之间的DeltaE ==========
function results = calculate_all_pairs_deltaE(data_cell, group_names, method, ci_level, display_results)
    k = length(data_cell);
    results = struct();
    
    % 生成所有可能的组对
    comparisons = nchoosek(1:k, 2);
    num_comps = size(comparisons, 1);
    
    pairwise_results = struct();
    summary_table = cell(num_comps + 1, 7);
    mean_deltaE_table = cell(num_comps + 1, 3);
    interpretation_table = cell(num_comps + 1, 4);
    
    % 表头
    summary_table{1, 1} = '比较组';
    summary_table{1, 2} = 'DeltaE均值';
    summary_table{1, 3} = 'DeltaE标准差';
    summary_table{1, 4} = 'DeltaE最小值';
    summary_table{1, 5} = 'DeltaE最大值';
    summary_table{1, 6} = sprintf('%.0f%%CI下限', ci_level*100);
    summary_table{1, 7} = sprintf('%.0f%%CI上限', ci_level*100);
    
    mean_deltaE_table{1, 1} = '比较组';
    mean_deltaE_table{1, 2} = 'DeltaE2000';
    mean_deltaE_table{1, 3} = '差异程度';
    
    interpretation_table{1, 1} = '比较组';
    interpretation_table{1, 2} = 'DeltaE2000值';
    interpretation_table{1, 3} = '差异程度';
    interpretation_table{1, 4} = '视觉意义';
    
    for comp = 1:num_comps
        i = comparisons(comp, 1);
        j = comparisons(comp, 2);
        
        % 提取两组数据（只取前3列：Lab值）
        data1 = data_cell{i}(:, 1:3);
        data2 = data_cell{j}(:, 1:3);
        
        n1 = size(data1, 1);
        n2 = size(data2, 1);
        
        % 计算所有样本对之间的DeltaE
        all_deltaE = zeros(n1 * n2, 1);
        idx = 1;
        
        for m = 1:n1
            for n = 1:n2
                if strcmpi(method, 'deltaE2000')
                    deltaE = deltaE2000(data1(m, :), data2(n, :));
                else
                    deltaE = computeDeltaE76(data1(m, :), data2(n, :));
                end
                all_deltaE(idx) = deltaE;
                idx = idx + 1;
            end
        end
        
        % 计算统计量
        mean_val = mean(all_deltaE);
        std_val = std(all_deltaE);
        min_val = min(all_deltaE);
        max_val = max(all_deltaE);
        
        % 计算置信区间
        if length(all_deltaE) > 1
            se = std_val / sqrt(length(all_deltaE));
            t_critical = tinv(1 - (1-ci_level)/2, length(all_deltaE)-1);
            ci_lower = mean_val - t_critical * se;
            ci_upper = mean_val + t_critical * se;
        else
            ci_lower = mean_val;
            ci_upper = mean_val;
        end
        
        % 判断差异程度
        [diff_level, visual_meaning] = interpret_deltaE(mean_val);
        
        % 存储结果
        comp_name = sprintf('%s vs %s', group_names{i}, group_names{j});
        pairwise_results(comp).Comparison = comp_name;
        pairwise_results(comp).Mean = mean_val;
        pairwise_results(comp).Std = std_val;
        pairwise_results(comp).Min = min_val;
        pairwise_results(comp).Max = max_val;
        pairwise_results(comp).CI_Lower = ci_lower;
        pairwise_results(comp).CI_Upper = ci_upper;
        pairwise_results(comp).Size1 = n1;
        pairwise_results(comp).Size2 = n2;
        pairwise_results(comp).AllDeltaE = all_deltaE;
        pairwise_results(comp).DifferenceLevel = diff_level;
        
        % 填充表格
        summary_table{comp+1, 1} = comp_name;
        summary_table{comp+1, 2} = mean_val;
        summary_table{comp+1, 3} = std_val;
        summary_table{comp+1, 4} = min_val;
        summary_table{comp+1, 5} = max_val;
        summary_table{comp+1, 6} = ci_lower;
        summary_table{comp+1, 7} = ci_upper;
        
        mean_deltaE_table{comp+1, 1} = comp_name;
        mean_deltaE_table{comp+1, 2} = mean_val;
        mean_deltaE_table{comp+1, 3} = diff_level;
        
        interpretation_table{comp+1, 1} = comp_name;
        interpretation_table{comp+1, 2} = mean_val;
        interpretation_table{comp+1, 3} = diff_level;
        interpretation_table{comp+1, 4} = visual_meaning;
        
        % 显示进度
        if display_results
            fprintf('完成 %s: DeltaE均值=%.4f (%s)\n', comp_name, mean_val, diff_level);
        end
    end
    
    results.PairwiseResults = pairwise_results;
    results.SummaryTable = summary_table;
    results.MeanDeltaETable = mean_deltaE_table;
    results.InterpretationTable = interpretation_table;
end

%% ========== 辅助函数：计算组均值之间的DeltaE ==========
function results = calculate_mean_deltaE(group_means, group_names, method, display_results)
    k = size(group_means, 1);
    results = struct();
    
    comparisons = nchoosek(1:k, 2);
    num_comps = size(comparisons, 1);
    
    pairwise_results = struct();
    mean_deltaE_table = cell(num_comps + 1, 3);
    interpretation_table = cell(num_comps + 1, 4);
    
    % 表头
    mean_deltaE_table{1, 1} = '比较组';
    mean_deltaE_table{1, 2} = 'DeltaE2000';
    mean_deltaE_table{1, 3} = '差异程度';
    
    interpretation_table{1, 1} = '比较组';
    interpretation_table{1, 2} = 'DeltaE2000值';
    interpretation_table{1, 3} = '差异程度';
    interpretation_table{1, 4} = '视觉意义';
    
    for comp = 1:num_comps
        i = comparisons(comp, 1);
        j = comparisons(comp, 2);
        
        lab1 = group_means(i, :);
        lab2 = group_means(j, :);
        
        % 计算DeltaE
        if strcmpi(method, 'deltaE2000')
            deltaE = deltaE2000(lab1, lab2);
        else
            deltaE = computeDeltaE76(lab1, lab2);
        end
        
        % 判断差异程度
        [diff_level, visual_meaning] = interpret_deltaE(deltaE);
        
        % 存储结果
        comp_name = sprintf('%s vs %s', group_names{i}, group_names{j});
        pairwise_results(comp).Comparison = comp_name;
        pairwise_results(comp).DeltaE = deltaE;
        pairwise_results(comp).DifferenceLevel = diff_level;
        pairwise_results(comp).Lab1 = lab1;
        pairwise_results(comp).Lab2 = lab2;
        
        % 填充表格
        mean_deltaE_table{comp+1, 1} = comp_name;
        mean_deltaE_table{comp+1, 2} = deltaE;
        mean_deltaE_table{comp+1, 3} = diff_level;
        
        interpretation_table{comp+1, 1} = comp_name;
        interpretation_table{comp+1, 2} = deltaE;
        interpretation_table{comp+1, 3} = diff_level;
        interpretation_table{comp+1, 4} = visual_meaning;
        
        if display_results
            fprintf('完成 %s: DeltaE=%.4f (%s)\n', comp_name, deltaE, diff_level);
        end
    end
    
    results.PairwiseResults = pairwise_results;
    results.MeanDeltaETable = mean_deltaE_table;
    results.InterpretationTable = interpretation_table;
    results.SummaryTable = [];  % 无成对统计
end

%% ========== 辅助函数：解释DeltaE值的意义 ==========
function [diff_level, visual_meaning] = interpret_deltaE(deltaE_value)
% 根据DeltaE2000值解释颜色差异的程度
%
% 输入：
%   deltaE_value - DeltaE2000值
% 输出：
%   diff_level - 差异程度描述
%   visual_meaning - 视觉意义描述

% 定义DeltaE2000的感知阈值（根据工业标准）
if deltaE_value < 0.5
    diff_level = '极微小';
    visual_meaning = '几乎不可察觉，专业人士在严格控制条件下才能察觉';
    
elseif deltaE_value < 1.0
    diff_level = '非常小';
    visual_meaning = '经验丰富的观察者在最佳观察条件下可能察觉';
    
elseif deltaE_value < 2.0
    diff_level = '小';
    visual_meaning = '经验观察者可察觉，但差异不明显';
    
elseif deltaE_value < 3.0
    diff_level = '可察觉';
    visual_meaning = '一般观察者可以察觉到差异';
    
elseif deltaE_value < 5.0
    diff_level = '明显';
    visual_meaning = '明显差异，即使是普通观察者也容易察觉';
    
elseif deltaE_value < 10.0
    diff_level = '大';
    visual_meaning = '非常大的差异，看起来像不同但相似的颜色';
    
else
    diff_level = '非常大';
    visual_meaning = '完全不同的颜色';
end
end

%% ========== 辅助函数：计算DeltaE76 ==========
function deltaE76 = computeDeltaE76(lab1, lab2)
% 计算传统的DeltaE76色差（欧几里得距离）
L1 = lab1(1); a1 = lab1(2); b1 = lab1(3);
L2 = lab2(1); a2 = lab2(2); b2 = lab2(3);

deltaE76 = sqrt((L2 - L1)^2 + (a2 - a1)^2 + (b2 - b1)^2);
end

%% ========== 辅助函数：绘制DeltaE结果图 ==========
function plot_deltaE_results(deltaE_results, save_path)
% 绘制DeltaE分析结果图

%% 创建第一个图形：组间DeltaE比较
figure('Position', [100, 100, 1200, 600], 'Name', 'DeltaE2000组间比较');

% 检查是否有成对比较结果
if ~isempty(deltaE_results.MeanDeltaETable)
    table_data = deltaE_results.MeanDeltaETable;
    num_comps = size(table_data, 1) - 1;
    
    % 提取数据
    comp_names = cell(num_comps, 1);
    deltaE_values = zeros(num_comps, 1);
    diff_levels = cell(num_comps, 1);
    
    for i = 1:num_comps
        comp_names{i} = table_data{i+1, 1};
        deltaE_values(i) = table_data{i+1, 2};
        diff_levels{i} = table_data{i+1, 3};
    end
    
    % 绘制条形图
    subplot(1, 2, 1);
    bar_handle = bar(deltaE_values);
    xlabel('比较组', 'FontSize', 11);
    ylabel('DeltaE2000', 'FontSize', 11);
    title('组间DeltaE2000值', 'FontSize', 12, 'FontWeight', 'bold');
    grid on;
    
    % 设置x轴标签
    if num_comps <= 10
        set(gca, 'XTickLabel', comp_names, 'XTickLabelRotation', 45);
    else
        set(gca, 'XTickLabel', {});
        legend(comp_names, 'Location', 'bestoutside');
    end
    
    % 添加数值标签
    for i = 1:num_comps
        text(i, deltaE_values(i) + 0.1, sprintf('%.2f', deltaE_values(i)), ...
            'HorizontalAlignment', 'center', ...
            'VerticalAlignment', 'bottom', ...
            'FontSize', 9);
    end
    
    % 添加阈值线
    hold on;
    thresholds = [0.5, 1.0, 2.0, 3.0, 5.0, 10.0];
    threshold_labels = {'0.5', '1.0', '2.0', '3.0', '5.0', '10.0'};
    colors = {'b', 'g', 'y', 'm', 'r', 'k'};
    
    for t = 1:length(thresholds)
        plot([0, num_comps+1], [thresholds(t), thresholds(t)], ...
            '--', 'Color', colors{t}, 'LineWidth', 1);
    end
    
    % 添加阈值图例
    legend_texts = cell(1, length(thresholds));
    for t = 1:length(thresholds)
        legend_texts{t} = sprintf('阈值: %s', threshold_labels{t});
    end
    legend(legend_texts, 'Location', 'eastoutside');
    hold off;
    
    %% 第二个子图：差异程度分布
    subplot(1, 2, 2);
    
    % 统计各差异程度的数量
    unique_levels = unique(diff_levels);
    level_counts = zeros(length(unique_levels), 1);
    
    for i = 1:length(unique_levels)
        level_counts(i) = sum(strcmp(diff_levels, unique_levels{i}));
    end
    
    % 绘制饼图
    pie_handle = pie(level_counts);
    title('差异程度分布', 'FontSize', 12, 'FontWeight', 'bold');
    
    % 添加图例
    legend(unique_levels, 'Location', 'bestoutside');
    
    %% 添加整体标题
    sgtitle(sprintf('DeltaE2000颜色差异分析 - %s', deltaE_results.CompareType), ...
        'FontSize', 14, 'FontWeight', 'bold');
end

%% 创建第二个图形：详细的成对比较（如果有）
if strcmpi(deltaE_results.CompareType, 'all_pairs') && ...
        ~isempty(deltaE_results.PairwiseResults)
    
    figure('Position', [100, 100, 1400, 800], 'Name', '成对DeltaE详细分布');
    
    num_comps = length(deltaE_results.PairwiseResults);
    num_rows = ceil(sqrt(num_comps));
    num_cols = ceil(num_comps / num_rows);
    
    for comp = 1:num_comps
        subplot(num_rows, num_cols, comp);
        
        result = deltaE_results.PairwiseResults(comp);
        
        % 绘制直方图
        histogram(result.AllDeltaE, 15, 'FaceColor', [0.2, 0.4, 0.6]);
        hold on;
        
        % 添加均值线
        plot([result.Mean, result.Mean], ylim, 'r-', 'LineWidth', 2);
        
        % 添加置信区间
        plot([result.CI_Lower, result.CI_Lower], ylim, 'r--', 'LineWidth', 1);
        plot([result.CI_Upper, result.CI_Upper], ylim, 'r--', 'LineWidth', 1);
        
        % 添加统计信息
        stats_text = sprintf('均值=%.2f\n标准差=%.2f\n范围=[%.2f, %.2f]', ...
            result.Mean, result.Std, result.Min, result.Max);
        
        text(0.05, 0.95, stats_text, 'Units', 'normalized', ...
            'VerticalAlignment', 'top', 'FontSize', 8, ...
            'BackgroundColor', [1, 1, 1, 0.7]);
        
        title(sprintf('%s\n%s', result.Comparison, result.DifferenceLevel), ...
            'FontSize', 9);
        xlabel('DeltaE2000');
        ylabel('频数');
        grid on;
        hold off;
    end
    
    sgtitle('各组成对DeltaE2000分布', 'FontSize', 14, 'FontWeight', 'bold');
end

%% 保存图形
save_choice = questdlg('是否保存图形？', '保存选项', ...
    '保存所有', '只保存第一个', '不保存', '保存所有');

fig_handles = findall(0, 'Type', 'figure');
for fig_idx = 1:length(fig_handles)
    fig = fig_handles(fig_idx);
    
    switch save_choice
        case '保存所有'
            filename = sprintf('deltaE_figure_%d_%s.png', fig_idx, ...
                deltaE_results.CompareType);
            fullpath = fullfile(save_path, filename);
            saveas(fig, fullpath);
            fprintf('图形已保存: %s\n', fullpath);
            
        case '只保存第一个'
            if fig_idx == 1
                filename = sprintf('deltaE_main_%s.png', ...
                    deltaE_results.CompareType);
                fullpath = fullfile(save_path, filename);
                saveas(fig, fullpath);
                fprintf('主图形已保存: %s\n', fullpath);
            end
    end
end
end

%% ========== 辅助函数：atan2d ==========
function deg = atan2d(y, x)
% 计算角度（度），类似MATLAB的atan2d函数
rad = atan2(y, x);
deg = rad * 180 / pi;
end

%% ========== 辅助函数：sind ==========
function y = sind(x)
% 正弦函数，输入为度
y = sin(x * pi / 180);
end

%% ========== 辅助函数：cosd ==========
function y = cosd(x)
% 余弦函数，输入为度
y = cos(x * pi / 180);
end