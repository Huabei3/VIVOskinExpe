
%%
clc;clear;close all;
addpath("utils\")
%%

Dtype = "efit_p";
lightness_type="rela";
rgb2xyz_type="display";
if strcmp(Dtype,"efit_p")
    sourceFolder=fullfile('AnalyseResults_p',rgb2xyz_type,lightness_type);
else
    sourceFolder='AnalyseResults';
end
load(fullfile(sourceFolder,"data_for_Lilliefors.mat"), ...
    "cens_model","cens_makeup","cens_scene","cens_gender","cens_self");

% 所有要分析的变量
all_cens = {cens_gender, cens_scene, cens_makeup,  cens_self};
all_labels = {"gender", "scene", "makeup",  "self"};
num_vars = length(all_labels);

% 存储所有检验结果的汇总
summary_table = cell(6, num_vars + 1);  % 6行：维度数 + 5个统计量，列：标签+值

%% 对每个变量进行正态性和方差齐性检验
for var_idx = 1:num_vars
    cens_used = all_cens{var_idx};
    label = all_labels{var_idx};
    
    fprintf('\n=== 分析变量: %s ===\n', label);
    
    % 调用正态性和方差齐性检验函数
    [normality_results, homogeneity_results, summary_stats] = ...
        perform_lilliefors_and_homogeneity(cens_used, label, sourceFolder);
    
    % 构建汇总表
    if var_idx == 1
        % 第一列：统计指标
        summary_table{1, 1} = '统计指标';
        summary_table{2, 1} = '正态性检验P最小值';
        summary_table{3, 1} = '正态性检验P最大值';
        summary_table{4, 1} = '正态性检验P平均值';
        summary_table{5, 1} = '正态性检验结论';
        summary_table{6, 1} = '方差齐性检验P最小值';
        summary_table{7, 1} = '方差齐性检验P最大值';
        summary_table{8, 1} = '方差齐性检验P平均值';
        summary_table{9, 1} = '方差齐性检验结论';
    end
    
    % 填充数据
    summary_table{1, var_idx+1} = label;  % 列标题
    
    % 正态性检验结果
    summary_table{2, var_idx+1} = summary_stats.normality_p_min;
    summary_table{3, var_idx+1} = summary_stats.normality_p_max;
    summary_table{4, var_idx+1} = summary_stats.normality_p_mean;
    summary_table{5, var_idx+1} = summary_stats.normality_conclusion;
    
    % 方差齐性检验结果
    summary_table{6, var_idx+1} = summary_stats.homogeneity_p_min;
    summary_table{7, var_idx+1} = summary_stats.homogeneity_p_max;
    summary_table{8, var_idx+1} = summary_stats.homogeneity_p_mean;
    summary_table{9, var_idx+1} = summary_stats.homogeneity_conclusion;
    
    fprintf('  正态性: %s (P范围: %.4f-%.4f, 平均: %.4f)\n', ...
        summary_stats.normality_conclusion, ...
        summary_stats.normality_p_min, ...
        summary_stats.normality_p_max, ...
        summary_stats.normality_p_mean);
    
    fprintf('  方差齐性: %s (P范围: %.4f-%.4f, 平均: %.4f)\n', ...
        summary_stats.homogeneity_conclusion, ...
        summary_stats.homogeneity_p_min, ...
        summary_stats.homogeneity_p_max, ...
        summary_stats.homogeneity_p_mean);
end

%% 保存汇总表到Excel
output_folder = fullfile(sourceFolder, "Lilliefors");
if ~exist(output_folder, "dir")
    mkdir(output_folder);
end

summary_filename = fullfile(output_folder, 'all_variables_summary.xlsx');

% 创建工作簿
writecell(summary_table, summary_filename, 'Sheet', '汇总统计');

% 添加格式说明
format_table = {
    '统计指标说明:', '', '';
    '正态性检验P最小值', '所有组和维度中正态性检验的最小P值', 'P<0.05表示不满足正态性';
    '正态性检验P最大值', '所有组和维度中正态性检验的最大P值', 'P越大越可能满足正态性';
    '正态性检验P平均值', '所有组和维度中正态性检验的平均P值', '平均值>0.05通常认为基本满足正态性';
    '正态性检验结论', '基于平均P值的判断', '满足/不满足/部分满足';
    '方差齐性检验P最小值', '所有维度方差齐性检验的最小P值', 'P<0.05表示方差不齐';
    '方差齐性检验P最大值', '所有维度方差齐性检验的最大P值', 'P越大越可能满足方差齐性';
    '方差齐性检验P平均值', '所有维度方差齐性检验的平均P值', '平均值>0.05通常认为满足方差齐性';
    '方差齐性检验结论', '基于平均P值的判断', '满足/不满足/部分满足';
    '', '', '';
    '判断标准:', '', '';
    'P值>0.05', '接受原假设', '';
    'P值≤0.05', '拒绝原假设', '';
};

writecell(format_table, summary_filename, 'Sheet', '说明');

fprintf('\n=== 所有变量分析完成 ===\n');
fprintf('汇总表已保存到: %s\n', summary_filename);

%% 显示汇总表
fprintf('\n=== 所有变量检验结果汇总 ===\n');
disp("d");
%%
% 
% Dtype = "efit_p";
% lightness_type="rela";
% rgb2xyz_type="display";
% if strcmp(Dtype,"efit_p")
%     sourceFolder=fullfile('AnalyseResults_p',rgb2xyz_type,lightness_type);
% else
%     sourceFolder='AnalyseResults';
% end
% load(fullfile(sourceFolder,"data_for_Lilliefors.mat"), ...
%     "cens_model","cens_makeup","cens_scene","cens_gender","cens_self");
% % cens_used=cens_gender;label="gender";
% % cens_used=cens_scene;label="scene";
% % cens_used=cens_makeup;label="makeup";
% % cens_used=cens_model;label="model";
% cens_used=cens_self;label="self";
% n=size(cens_used,1);
% for i_type=1:n
%     data{i_type}=cens_used{i_type,1};
% end
% 
% 
% % n=size(cens_used,1);
% % for i_type=3:n
% %     data{i_type-2}=cens_used{i_type,1};
% % end
% %% Lilliefors正态性检验
% disp('=== Lilliefors正态性检验 ===');
% lillie_results = cell(n, 6);  % 存储结果：组号、维度、H值、P值、统计量、结论
% 
% for group = 1:n
%     current_data = data{group};
%     [num_samples, num_dimensions] = size(current_data);
% 
%     fprintf('\n第%d组数据（%d个样本）：\n', group, num_samples);
% 
%     for dim = 1:num_dimensions
%         % 提取当前维度的数据
%         dim_data = current_data(:, dim);
% 
%         % Lilliefors检验（改进的Kolmogorov-Smirnov检验）
%         [h, p, kstat] = lillietest(dim_data, 'Alpha', 0.05);
% 
%         % 判断结论
%         if h == 0
%             conclusion = '服从正态分布';
%         else
%             conclusion = '不服从正态分布';
%         end
% 
%         % 存储结果
%         lillie_results{(group-1)*num_dimensions + dim, 1} = ['Group ', num2str(group)];
%         lillie_results{(group-1)*num_dimensions + dim, 2} = ['Dim ', num2str(dim)];
%         lillie_results{(group-1)*num_dimensions + dim, 3} = h;
%         lillie_results{(group-1)*num_dimensions + dim, 4} = p;
%         lillie_results{(group-1)*num_dimensions + dim, 5} = kstat;
%         lillie_results{(group-1)*num_dimensions + dim, 6} = conclusion;
% 
%         % 显示结果
%         fprintf('  维度%d: H=%d, p=%.4f, 统计量=%.4f - %s\n', ...
%                 dim, h, p, kstat, conclusion);
%     end
% end
% 
% %% 方差齐性检验
% disp('=== 方差齐性检验 ===');
% % 准备数据用于方差齐性检验
% variance_data = cell(1, num_dimensions);
% group_labels = cell(1, num_dimensions);
% 
% for dim = 1:num_dimensions
%     dim_all_data = [];
%     dim_labels = [];
% 
%     for group = 1:n
%         current_data = data{group};
%         dim_data = current_data(:, dim);
%         dim_all_data = [dim_all_data; dim_data];
%         dim_labels = [dim_labels; group * ones(size(dim_data))];
%     end
% 
%     variance_data{dim} = dim_all_data;
%     group_labels{dim} = dim_labels;
% end
% 
% % 执行方差齐性检验
% vartest_results = cell(num_dimensions, 5);  % 存储结果：维度、检验方法、P值、统计量、结论
% 
% for dim = 1:num_dimensions
%     fprintf('\n维度%d的方差齐性检验：\n', dim);
% 
%     % Bartlett检验（要求数据服从正态分布）
%     try
%         [p_bartlett, tbl_bartlett, stats_bartlett] = vartestn(variance_data{dim}, group_labels{dim}, ...
%                                                             'Display', 'off', 'TestType', 'Bartlett');
%         bartlett_stat = tbl_bartlett{2, 5};  % 卡方统计量
%     catch
%         p_bartlett = NaN;
%         bartlett_stat = NaN;
%     end
% 
%     % Levene检验（对非正态数据更稳健）
%     [p_levene, tbl_levene] = vartestn(variance_data{dim}, group_labels{dim}, ...
%                                                    'Display', 'off', 'TestType', 'LeveneAbsolute');
%     levene_stat = tbl_levene.fstat;  % F统计量
% 
%     % 判断结论（使用Levene检验的结果）
%     if p_levene > 0.05
%         conclusion = '方差齐性';
%     else
%         conclusion = '方差不齐';
%     end
% 
%     % 存储结果
%     vartest_results{dim, 1} = ['Dim ', num2str(dim)];
%     vartest_results{dim, 2} = 'Bartlett检验';
%     vartest_results{dim, 3} = p_bartlett;
%     vartest_results{dim, 4} = bartlett_stat;
%     vartest_results{dim, 5} = conclusion;
% 
%     vartest_results{dim+num_dimensions, 1} = ['Dim ', num2str(dim)];
%     vartest_results{dim+num_dimensions, 2} = 'Levene检验';
%     vartest_results{dim+num_dimensions, 3} = p_levene;
%     vartest_results{dim+num_dimensions, 4} = levene_stat;
%     vartest_results{dim+num_dimensions, 5} = conclusion;
% 
%     % 显示结果
%     fprintf('  Bartlett检验: p=%.4f, 统计量=%.4f\n', p_bartlett, bartlett_stat);
%     fprintf('  Levene检验: p=%.4f, 统计量=%.4f\n', p_levene, levene_stat);
%     fprintf('  结论: %s\n', conclusion);
% end
% 
% %% 创建汇总统计表
% disp('=== 创建汇总统计表 ===');
% summary_results = cell(n*num_dimensions + 1, 7);
% summary_results{1, 1} = '组别';
% summary_results{1, 2} = '维度';
% summary_results{1, 3} = '样本数';
% summary_results{1, 4} = '均值';
% summary_results{1, 5} = '标准差';
% summary_results{1, 6} = '正态性(P值)';
% summary_results{1, 7} = '方差齐性(Levene P值)';
% 
% row_idx = 2;
% for group = 1:n
%     current_data = data{group};
%     [num_samples, ~] = size(current_data);
% 
%     for dim = 1:num_dimensions
%         dim_data = current_data(:, dim);
% 
%         % 获取对应的检验结果
%         lillie_idx = (group-1)*num_dimensions + dim;
%         levene_p = vartest_results{dim+num_dimensions, 3};
% 
%         summary_results{row_idx, 1} = ['Group ', num2str(group)];
%         summary_results{row_idx, 2} = ['Dim ', num2str(dim)];
%         summary_results{row_idx, 3} = num_samples;
%         summary_results{row_idx, 4} = mean(dim_data);
%         summary_results{row_idx, 5} = std(dim_data);
%         summary_results{row_idx, 6} = lillie_results{lillie_idx, 4};  % Lilliefors P值
%         summary_results{row_idx, 7} = levene_p;
% 
%         row_idx = row_idx + 1;
%     end
% end
% 
% %% 输出结果到Excel
% disp('=== 输出结果到Excel文件 ===');
% 
% % 创建输出文件名（带时间戳避免覆盖）
% output_folder=fullfile(sourceFolder,"Lilliefors");
% if ~exist(output_folder,"dir")
%     mkdir(output_folder);
% end
% output_filename = fullfile(output_folder, ...
%     strcat('statistical_analysis_',label,'.xlsx'));
% 
% % 写入Lilliefors检验结果
% lillie_header = {'组别', '维度', 'H值', 'P值', '统计量', '结论'};
% xlswrite(output_filename, lillie_header, '正态性检验', 'A1');
% xlswrite(output_filename, lillie_results, '正态性检验', 'A2');
% 
% % 写入方差齐性检验结果
% vartest_header = {'维度', '检验方法', 'P值', '统计量', '结论'};
% xlswrite(output_filename, vartest_header, '方差齐性检验', 'A1');
% xlswrite(output_filename, vartest_results, '方差齐性检验', 'A2');
% 
% % 写入汇总统计表
% xlswrite(output_filename, summary_results, '汇总统计', 'A1');
% 
% 
% fprintf('\n=== 分析完成 ===\n');
% fprintf('结果已保存到文件: %s\n', output_filename);
% fprintf('包含以下工作表：\n');
% fprintf('  1. 正态性检验 - Lilliefors检验结果\n');
% fprintf('  2. 方差齐性检验 - Bartlett和Levene检验结果\n');
% fprintf('  3. 汇总统计 - 描述性统计和检验P值汇总\n');
% 
% %% 可选：显示数据预览
% disp(' ');
% disp('数据预览（前3行）：');
% for group = 1:min(n, 3)
%     fprintf('第%d组数据（前3行）:\n', group);
%     disp(data{group}(1:min(3, size(data{group}, 1)), :));
% end