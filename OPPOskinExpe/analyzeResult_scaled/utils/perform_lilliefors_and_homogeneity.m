function [normality_results, homogeneity_results, summary_stats] = ...
    perform_lilliefors_and_homogeneity(data_cell, label, sourceFolder)
% 对数据进行Lilliefors正态性检验和方差齐性检验
%
% 输入参数：
%   data_cell - 元胞数组，每个元素为一组数据矩阵
%   label - 变量标签，用于输出文件名
%   sourceFolder - 源文件夹路径
%
% 输出参数：
%   normality_results - 正态性检验结果
%   homogeneity_results - 方差齐性检验结果
%   summary_stats - 汇总统计信息

%% 提取数据
n = size(data_cell, 1);
data = cell(n, 1);
for i_type = 1:n
    data{i_type} = data_cell{i_type, 1};
end

%% Lilliefors正态性检验
disp('=== Lilliefors正态性检验 ===');
lillie_results = cell(n, 6);  % 存储结果：组号、维度、H值、P值、统计量、结论

% 获取数据维度
[num_samples, num_dimensions] = size(data{1});

% 存储所有正态性检验的P值
all_normality_p = [];

for group = 1:n
    current_data = data{group};
    
    fprintf('\n第%d组数据（%d个样本）：\n', group, num_samples);
    
    for dim = 1:num_dimensions
        % 提取当前维度的数据
        dim_data = current_data(:, dim);
        
        % Lilliefors检验
        [h, p, kstat] = lillietest(dim_data, 'Alpha', 0.05);
        
        % 判断结论
        if h == 0
            conclusion = '服从正态分布';
        else
            conclusion = '不服从正态分布';
        end
        
        % 存储结果
        lillie_results{(group-1)*num_dimensions + dim, 1} = ['Group ', num2str(group)];
        lillie_results{(group-1)*num_dimensions + dim, 2} = ['Dim ', num2str(dim)];
        lillie_results{(group-1)*num_dimensions + dim, 3} = h;
        lillie_results{(group-1)*num_dimensions + dim, 4} = p;
        lillie_results{(group-1)*num_dimensions + dim, 5} = kstat;
        lillie_results{(group-1)*num_dimensions + dim, 6} = conclusion;
        
        % 收集P值用于汇总
        all_normality_p = [all_normality_p; p];
        
        % 显示结果
        fprintf('  维度%d: H=%d, p=%.4f, 统计量=%.4f - %s\n', ...
                dim, h, p, kstat, conclusion);
    end
end

%% 方差齐性检验
disp('=== 方差齐性检验 ===');
% 准备数据用于方差齐性检验
variance_data = cell(1, num_dimensions);
group_labels = cell(1, num_dimensions);

for dim = 1:num_dimensions
    dim_all_data = [];
    dim_labels = [];
    
    for group = 1:n
        current_data = data{group};
        dim_data = current_data(:, dim);
        dim_all_data = [dim_all_data; dim_data];
        dim_labels = [dim_labels; group * ones(size(dim_data))];
    end
    
    variance_data{dim} = dim_all_data;
    group_labels{dim} = dim_labels;
end

% 执行方差齐性检验
vartest_results = cell(num_dimensions, 5);  % 存储结果：维度、检验方法、P值、统计量、结论

% 存储所有方差齐性检验的P值（Levene检验）
all_homogeneity_p = [];

for dim = 1:num_dimensions
    fprintf('\n维度%d的方差齐性检验：\n', dim);
    
    % Bartlett检验
    try
        [p_bartlett, tbl_bartlett, stats_bartlett] = vartestn(variance_data{dim}, group_labels{dim}, ...
                                                            'Display', 'off', 'TestType', 'Bartlett');
        bartlett_stat = tbl_bartlett{2, 5};  % 卡方统计量
    catch
        p_bartlett = NaN;
        bartlett_stat = NaN;
    end
    
    % Levene检验（对非正态数据更稳健）
    [p_levene, tbl_levene] = vartestn(variance_data{dim}, group_labels{dim}, ...
                                                   'Display', 'off', 'TestType', 'LeveneAbsolute');
    levene_stat = tbl_levene.fstat;  % F统计量
    
    % 收集Levene检验的P值
    all_homogeneity_p = [all_homogeneity_p; p_levene];
    
    % 判断结论（使用Levene检验的结果）
    if p_levene > 0.05
        conclusion = '方差齐性';
    else
        conclusion = '方差不齐';
    end
    
    % 存储结果
    vartest_results{dim, 1} = ['Dim ', num2str(dim)];
    vartest_results{dim, 2} = 'Bartlett检验';
    vartest_results{dim, 3} = p_bartlett;
    vartest_results{dim, 4} = bartlett_stat;
    vartest_results{dim, 5} = conclusion;
    
    vartest_results{dim+num_dimensions, 1} = ['Dim ', num2str(dim)];
    vartest_results{dim+num_dimensions, 2} = 'Levene检验';
    vartest_results{dim+num_dimensions, 3} = p_levene;
    vartest_results{dim+num_dimensions, 4} = levene_stat;
    vartest_results{dim+num_dimensions, 5} = conclusion;
    
    % 显示结果
    fprintf('  Bartlett检验: p=%.4f, 统计量=%.4f\n', p_bartlett, bartlett_stat);
    fprintf('  Levene检验: p=%.4f, 统计量=%.4f\n', p_levene, levene_stat);
    fprintf('  结论: %s\n', conclusion);
end

%% 创建汇总统计表
disp('=== 创建汇总统计表 ===');
summary_results = cell(n*num_dimensions + 1, 7);
summary_results{1, 1} = '组别';
summary_results{1, 2} = '维度';
summary_results{1, 3} = '样本数';
summary_results{1, 4} = '均值';
summary_results{1, 5} = '标准差';
summary_results{1, 6} = '正态性(P值)';
summary_results{1, 7} = '方差齐性(Levene P值)';

row_idx = 2;
for group = 1:n
    current_data = data{group};
    [num_samples, ~] = size(current_data);
    
    for dim = 1:num_dimensions
        dim_data = current_data(:, dim);
        
        % 获取对应的检验结果
        lillie_idx = (group-1)*num_dimensions + dim;
        levene_p = vartest_results{dim+num_dimensions, 3};
        
        summary_results{row_idx, 1} = ['Group ', num2str(group)];
        summary_results{row_idx, 2} = ['Dim ', num2str(dim)];
        summary_results{row_idx, 3} = num_samples;
        summary_results{row_idx, 4} = mean(dim_data);
        summary_results{row_idx, 5} = std(dim_data);
        summary_results{row_idx, 6} = lillie_results{lillie_idx, 4};  % Lilliefors P值
        summary_results{row_idx, 7} = levene_p;
        
        row_idx = row_idx + 1;
    end
end

%% 输出结果到Excel
disp('=== 输出结果到Excel文件 ===');

% 创建输出文件夹
output_folder = fullfile(sourceFolder, "Lilliefors");
if ~exist(output_folder, "dir")
    mkdir(output_folder);
end

output_filename = fullfile(output_folder, ...
    strcat('statistical_analysis_', label, '.xlsx'));

% 写入Lilliefors检验结果
lillie_header = {'组别', '维度', 'H值', 'P值', '统计量', '结论'};
xlswrite(output_filename, lillie_header, '正态性检验', 'A1');
xlswrite(output_filename, lillie_results, '正态性检验', 'A2');

% 写入方差齐性检验结果
vartest_header = {'维度', '检验方法', 'P值', '统计量', '结论'};
xlswrite(output_filename, vartest_header, '方差齐性检验', 'A1');
xlswrite(output_filename, vartest_results, '方差齐性检验', 'A2');

% 写入汇总统计表
xlswrite(output_filename, summary_results, '汇总统计', 'A1');

fprintf('\n=== 分析完成 ===\n');
fprintf('结果已保存到文件: %s\n', output_filename);

%% 计算汇总统计信息
summary_stats = struct();

% 正态性检验汇总
summary_stats.normality_p_min = min(all_normality_p);
summary_stats.normality_p_max = max(all_normality_p);
summary_stats.normality_p_mean = mean(all_normality_p);

% 判断正态性结论
if summary_stats.normality_p_min > 0.05
    summary_stats.normality_conclusion = '满足正态性';
elseif sum(all_normality_p > 0.05) / length(all_normality_p) > 0.5
    summary_stats.normality_conclusion = '部分满足正态性';
else
    summary_stats.normality_conclusion = '不满足正态性';
end

% 方差齐性检验汇总
summary_stats.homogeneity_p_min = min(all_homogeneity_p);
summary_stats.homogeneity_p_max = max(all_homogeneity_p);
summary_stats.homogeneity_p_mean = mean(all_homogeneity_p);

% 判断方差齐性结论
if summary_stats.homogeneity_p_mean > 0.05
    summary_stats.homogeneity_conclusion = '满足方差齐性';
elseif sum(all_homogeneity_p > 0.05) / length(all_homogeneity_p) > 0.5
    summary_stats.homogeneity_conclusion = '部分满足方差齐性';
else
    summary_stats.homogeneity_conclusion = '不满足方差齐性';
end

% 返回结果
normality_results = lillie_results;
homogeneity_results = vartest_results;

%% 显示数据预览
disp(' ');
disp('数据预览（前3行）：');
for group = 1:min(n, 3)
    fprintf('第%d组数据（前3行）:\n', group);
    disp(data{group}(1:min(3, size(data{group}, 1)), :));
end
end