clc;clear;close all;
addpath("utils\")'
%%

lastParts=["inLab","indoorAdd","nightAdd","outdoorAdd","sunsetAdd"];
Dtype = "efit_p";
lightness_type="rela";
rgb2xyz_type="display";
if strcmp(Dtype,"efit_p")
    sourceFolder=fullfile('AnalyseResults_p',rgb2xyz_type,lightness_type);
else
    sourceFolder='AnalyseResults';
end
load(fullfile(sourceFolder,"data_for_Lilliefors.mat"), ...
    "cens_model","cens_makeup","cens_scene","cens_gender","cens_self_scene");

% 所有要分析的变量
all_cens = {cens_gender, cens_scene, cens_makeup, cens_model, cens_self_scene};
all_labels = {"gender", "scene", "makeup", "model", "self_scene"};
num_vars = length(all_labels);

% 初始化汇总表格
summary_table = cell(8, num_vars + 1);  % 8行统计指标，+1列用于标签
summary_table{1, 1} = '统计指标';
summary_table{2, 1} = '检验类型';
summary_table{3, 1} = 'P值最小值';
summary_table{4, 1} = 'P值最大值';
summary_table{5, 1} = 'P值平均值';
summary_table{6, 1} = 'P值中位数';
summary_table{7, 1} = '显著维度数';
summary_table{8, 1} = '检验结论';

% 存储所有变量的检验结果
all_results = cell(1, num_vars);

%% 对每个变量进行相应的检验
for var_idx = 1:num_vars
    cens_used = all_cens{var_idx};
    label = all_labels{var_idx};
    
    fprintf('\n=== 分析变量: %s ===\n', label);
    
    n = size(cens_used, 1);
    data = cell(1, n);
    for i_type = 1:n
        data{i_type} = cens_used{i_type, 1};
    end
    
    output_folder = fullfile(sourceFolder, label);    
    if ~exist(output_folder, 'dir')
        mkdir(output_folder);
    end
    output_folder=char(output_folder);
    
    % 根据变量类型执行不同的检验
    % 根据变量类型执行不同的检验
    if strcmp(label, "gender")
        % 独立样本t检验
        results = perform_ttest_2groups(data{1}, data{2}, output_folder);
        test_type = '独立样本t检验';
        
        % 提取P值（5个维度）
        p_values = zeros(5, 1);
        for dim = 1:5
            p_values(dim) = results.(['Dim' num2str(dim)]).PValue;
        end
        
        % 判断显著性
        significant_count = sum(p_values < 0.05);
        
    elseif strcmp(label, "self_scene")
        % 特殊处理：对每个场景分别进行自我/他人比较
        test_type = 'Kruskal-Wallis检验（分场景）';
        
        % 准备存储所有场景的结果
        all_scene_p_values = [];
        all_scene_significant = [];
        scene_names = {'inLab', 'indoorAdd', 'nightAdd', 'outdoorAdd', 'sunsetAdd'};
        
        fprintf('开始分析自我/他人比较（分场景）...\n');
        
        for scene_idx = 1:n
            scene_name = scene_names{scene_idx};
            fprintf('\n  场景: %s\n', scene_name);
            
            % 获取当前场景的自我和他人数据
            % cens_self_scene{i_row,1} 是自我数据
            % cens_self_scene{i_row,2} 是他人数据
            self_data = cens_used{scene_idx, 2};  % 自我数据
            others_data = cens_used{scene_idx, 1};  % 他人数据
            
            % 检查数据是否为空
            if isempty(self_data) || isempty(others_data)
                fprintf('   警告: 数据为空，跳过\n');
                continue;
            end
            
            % 准备数据元胞数组
            scene_data_cell = {self_data, others_data};
            scene_group_names = {sprintf('%s-self', scene_name), sprintf('%s-others', scene_name)};
            
            % 确保输出文件夹是字符串
            scene_output_folder = char(output_folder);  % 确保是字符数组
            
            % 执行Kruskal-Wallis检验
            try
                scene_results = perform_kruskalwallis_test(scene_data_cell, scene_group_names, ...
                    scene_output_folder, 'Alpha', 0.05, 'Display', false, ...
                    'Filename', sprintf('kw_scene_%s.xlsx', scene_name), ...
                    'MultipleComparison', false);
                
                % 提取当前场景的P值（5个维度）
                scene_p_values = zeros(5, 1);
                for dim = 1:5
                    scene_p_values(dim) = scene_results.(['Dim_' num2str(dim)]).PValue;
                end
                
                % 计算显著维度数
                scene_significant = sum(scene_p_values < 0.05);
                
                % 显示结果
                fprintf('    P值范围: %.4f-%.4f, 平均: %.4f\n', ...
                    min(scene_p_values), max(scene_p_values), mean(scene_p_values));
                fprintf('    显著维度: %d/5\n', scene_significant);
                
                % 存储结果
                all_scene_p_values = [all_scene_p_values; scene_p_values];
                all_scene_significant = [all_scene_significant; scene_significant];
                
            catch ME
                fprintf('   错误: %s\n', ME.message);
                continue;
            end
        end
        
        % 汇总所有场景的结果
        if ~isempty(all_scene_p_values)
            % 计算所有场景的P值统计
            p_min = min(all_scene_p_values(:));
            p_max = max(all_scene_p_values(:));
            p_mean = mean(all_scene_p_values(:));
            p_median = median(all_scene_p_values(:));
            
            % 计算平均显著维度数
            avg_significant = mean(all_scene_significant);
            total_scenes_analyzed = length(all_scene_significant);  % 改为不同的变量名
            
            % 填充汇总表格
            p_values = p_mean;  % 使用平均值作为代表性P值
            significant_count = round(avg_significant * 5);  % 转换为维度数
            
        else
            p_values = NaN;
            significant_count = NaN;
            p_min = NaN;
            p_max = NaN;
            p_mean = NaN;
            p_median = NaN;
            total_scenes_analyzed = 0;  % 初始化
            avg_significant = 0;  % 初始化
        end
        
    elseif strcmp(label, "makeup")
        group_names = {"makeup", "no-makeup"};
        
        % Kruskal-Wallis检验
        results = perform_kruskalwallis_test(cens_used, group_names, output_folder, ...
            'Alpha', 0.05, ...
            'Display', true, ...
            'Filename', 'kw_results.xlsx', ...
            'MultipleComparison', false);
        
        test_type = 'Kruskal-Wallis检验';
        
        % 提取P值（5个维度）
        p_values = zeros(5, 1);
        for dim = 1:5
            p_values(dim) = results.(['Dim_' num2str(dim)]).PValue;
        end
        
        % 判断显著性
        significant_count = sum(p_values < 0.05);
        
    elseif strcmp(label, "scene")
        % 准备组名
        for i_type = 1:size(cens_used, 1)
            group_names{i_type} = lastParts(i_type);
        end
        
        % Kruskal-Wallis检验（多组）
        results = perform_kruskalwallis_test(cens_used, group_names, output_folder, ...
            'Alpha', 0.05, ...
            'Display', true, ...
            'Filename', 'kw_results.xlsx', ...
            'MultipleComparison', true);
        
        test_type = 'Kruskal-Wallis检验（多组）';
        
        % 提取P值（5个维度）
        p_values = zeros(5, 1);
        for dim = 1:5
            p_values(dim) = results.(['Dim_' num2str(dim)]).PValue;
        end
        
        % 判断显著性
        significant_count = sum(p_values < 0.05);
        
        % 事后检验
        results_dunn = perform_nonparametric_posthoc_tests(cens_used, group_names, ...
            'Method', 'dunn', ...
            'Alpha', 0.05, ...
            'Display', true, ...
            'ExportExcel', true, ...
            'ExcelPath', output_folder);
        
    elseif strcmp(label, "model")
        types = ["female1", "female2", "female3", "female4", "female5", ...
            "male1", "male2", "male3", "male4"];
        
        for i_type = 1:size(cens_used, 1)
            group_names{i_type} = types(i_type);
        end
        
        % DeltaE2000颜色差异分析
        deltaE_results = calculate_deltaE_simple(cens_used, group_names, output_folder);
        test_type = 'DeltaE2000颜色差异';
        
        % 对于DeltaE分析，我们关注组间/组内比值
        % 这里简化处理，使用ratio作为判断依据
        p_values = NaN;  % DeltaE没有p值概念
        significant_count = NaN;
        
    end
    
    % 存储结果
    all_results{var_idx} = struct(...
        'Label', label, ...
        'TestType', test_type, ...
        'PValues', p_values, ...
        'SignificantCount', significant_count ...
    );
    
    % 填充汇总表格
    summary_table{1, var_idx+1} = label;  % 列标题
    summary_table{2, var_idx+1} = test_type;
    
    if ~all(isnan(p_values))
        % 计算统计量
        if ~strcmp(label, "self_scene")
            % 对于其他变量，使用原始计算方法
            p_min = min(p_values);
            p_max = max(p_values);
            p_mean = mean(p_values);
            p_median = median(p_values);
        end
        % 对于self_scene，p_min等已经在前面计算过了
        
        summary_table{3, var_idx+1} = p_min;
        summary_table{4, var_idx+1} = p_max;
        summary_table{5, var_idx+1} = p_mean;
        summary_table{6, var_idx+1} = p_median;
        summary_table{7, var_idx+1} = sprintf('%d/5', significant_count);
        
        % 判断检验结论
        if significant_count == 5
            conclusion = '所有维度显著差异';
        elseif significant_count >= 3
            conclusion = '多数维度显著差异';
        elseif significant_count >= 1
            conclusion = '部分维度显著差异';
        else
            conclusion = '无显著差异';
        end
        
        % 添加p值范围信息
        if p_min > 0.05
            conclusion = sprintf('%s (所有p>0.05)', conclusion);
        elseif p_max < 0.05
            conclusion = sprintf('%s (所有p<0.05)', conclusion);
        else
            conclusion = sprintf('%s (p范围:%.3f-%.3f)', conclusion, p_min, p_max);
        end
        
    else
        % DeltaE分析的特殊处理
        summary_table{3, var_idx+1} = 'N/A';
        summary_table{4, var_idx+1} = 'N/A';
        summary_table{5, var_idx+1} = 'N/A';
        summary_table{6, var_idx+1} = 'N/A';
        summary_table{7, var_idx+1} = 'N/A';
        
        if isfield(deltaE_results, 'ratio')
            ratio = deltaE_results.ratio;
            if ratio > 1
                conclusion = sprintf('组间差异>组内差异 (%.2f倍)', ratio);
            else
                conclusion = sprintf('组内差异>组间差异 (%.2f倍)', ratio);
            end
        else
            conclusion = '颜色差异分析';
        end
    end
    
    summary_table{8, var_idx+1} = conclusion;
    
    % 显示当前变量结果
    fprintf('检验类型: %s\n', test_type);
    if ~all(isnan(p_values)) && ~strcmp(label, "self_scene")
        fprintf('P值统计: 最小=%.6f, 最大=%.6f, 平均=%.6f\n', p_min, p_max, p_mean);
        fprintf('显著维度: %d/5\n', significant_count);
    elseif strcmp(label, "self_scene") && exist('total_scenes_analyzed', 'var')  % 修改这里
        fprintf('总计: %d个场景\n', total_scenes_analyzed);  % 修改这里
        fprintf('所有场景P值统计: 最小=%.6f, 最大=%.6f, 平均=%.6f\n', p_min, p_max, p_mean);
        fprintf('平均显著维度: %.1f/5\n', avg_significant);
    end
    fprintf('结论: %s\n\n', conclusion);
end

%% 保存汇总表到Excel
summary_folder = fullfile(sourceFolder, 'Summary_Results');
if ~exist(summary_folder, 'dir')
    mkdir(summary_folder);
end

summary_filename = fullfile(summary_folder, 'all_tests_summary.xlsx');

% 写入主汇总表
writecell(summary_table, summary_filename, 'Sheet', '汇总表');

% 创建详细统计表
detailed_table = cell(6, num_vars + 1);
detailed_table{1, 1} = '统计指标';
detailed_table{2, 1} = '检验类型';
detailed_table{3, 1} = '样本组数';
detailed_table{4, 1} = '总样本量';
detailed_table{5, 1} = '分析方法';
detailed_table{6, 1} = '主要发现';

for var_idx = 1:num_vars
    cens_used = all_cens{var_idx};
    label = all_labels{var_idx};
    
    detailed_table{1, var_idx+1} = label;
    detailed_table{2, var_idx+1} = summary_table{2, var_idx+1};
    
    % 计算样本信息
    if strcmp(label, "self_scene")
        % 特殊处理：计算所有场景的总样本量
        total_groups = 2;  % 每个场景有自我和他人两组
        total_samples = 0;
        for scene_idx = 1:size(cens_used, 1)
            if size(cens_used, 2) >= 2
                self_data = cens_used{scene_idx, 1};
                others_data = cens_used{scene_idx, 2};
                if ~isempty(self_data)
                    total_samples = total_samples + size(self_data, 1);
                end
                if ~isempty(others_data)
                    total_samples = total_samples + size(others_data, 1);
                end
            end
        end
    else
        total_groups = size(cens_used, 1);
        total_samples = 0;
        for i = 1:total_groups
            total_samples = total_samples + size(cens_used{i, 1}, 1);
        end
    end
    
    detailed_table{3, var_idx+1} = total_groups;
    detailed_table{4, var_idx+1} = total_samples;
    
    % 分析方法说明
    if strcmp(label, "gender")
        method_desc = '独立样本t检验，适用于两组正态分布数据比较';
    elseif strcmp(label, "self_scene")
        method_desc = '分场景Kruskal-Wallis检验，每个场景比较自我和他人差异';
    elseif strcmp(label, "makeup")
        method_desc = '非参数Kruskal-Wallis检验，适用于两组非正态分布数据';
    elseif strcmp(label, "scene")
        method_desc = '多组非参数Kruskal-Wallis检验+Dunn事后检验';
    elseif strcmp(label, "model")
        method_desc = 'DeltaE2000颜色差异分析，比较组内和组间颜色差异';
    end
    
    detailed_table{5, var_idx+1} = method_desc;
    detailed_table{6, var_idx+1} = summary_table{8, var_idx+1};
end

writecell(detailed_table, summary_filename, 'Sheet', '详细说明');

% 创建P值分布表（只对有p值的检验）
pvalue_table = cell(num_vars + 2, 7);
pvalue_table{1, 1} = '变量';
pvalue_table{1, 2} = '维度1 P值';
pvalue_table{1, 3} = '维度2 P值';
pvalue_table{1, 4} = '维度3 P值';
pvalue_table{1, 5} = '维度4 P值';
pvalue_table{1, 6} = '维度5 P值';
pvalue_table{1, 7} = '平均P值';

for var_idx = 1:num_vars
    results = all_results{var_idx};
    pvalue_table{var_idx+1, 1} = results.Label;
    results.Label
    
    if ~all(isnan(results.PValues))
        for dim = 1:5
            pvalue_table{var_idx+1, dim+1} = results.PValues(dim);
        end
        pvalue_table{var_idx+1, 7} = mean(results.PValues);
    else
        for dim = 1:6
            pvalue_table{var_idx+1, dim+1} = 'N/A';
        end
    end
end

% 添加显著性标注
pvalue_table{num_vars+2, 1} = '显著性标注';
pvalue_table{num_vars+2, 2} = '**p<0.01, *p<0.05';
pvalue_table{num_vars+2, 7} = '平均值';

writecell(pvalue_table, summary_filename, 'Sheet', 'P值分布');

disp(summary_filename);
%%
% clc;clear;close all;
% addpath("utils\")'
% %%
% 
% lastParts=["inLab","indoorAdd","nightAdd","outdoorAdd","sunsetAdd"];
% Dtype = "efit_p";
% lightness_type="rela";
% rgb2xyz_type="display";
% if strcmp(Dtype,"efit_p")
%     sourceFolder=fullfile('AnalyseResults_p',rgb2xyz_type,lightness_type);
% else
%     sourceFolder='AnalyseResults';
% end
% load(fullfile(sourceFolder,"data_for_Lilliefors.mat"), ...
%     "cens_model","cens_makeup","cens_scene","cens_gender","cens_self_scene");
% 
% % 所有要分析的变量
% all_cens = {cens_gender, cens_scene, cens_makeup, cens_model, cens_self_scene};
% all_labels = {"gender", "scene", "makeup", "model", "self"};
% num_vars = length(all_labels);
% 
% % 初始化汇总表格
% summary_table = cell(8, num_vars + 1);  % 8行统计指标，+1列用于标签
% summary_table{1, 1} = '统计指标';
% summary_table{2, 1} = '检验类型';
% summary_table{3, 1} = 'P值最小值';
% summary_table{4, 1} = 'P值最大值';
% summary_table{5, 1} = 'P值平均值';
% summary_table{6, 1} = 'P值中位数';
% summary_table{7, 1} = '显著维度数';
% summary_table{8, 1} = '检验结论';
% 
% % 存储所有变量的检验结果
% all_results = cell(1, num_vars);
% 
% %% 对每个变量进行相应的检验
% for var_idx = 1:num_vars
%     cens_used = all_cens{var_idx};
%     label = all_labels{var_idx};
% 
%     fprintf('\n=== 分析变量: %s ===\n', label);
% 
%     n = size(cens_used, 1);
%     data = cell(1, n);
%     for i_type = 1:n
%         data{i_type} = cens_used{i_type, 1};
%     end
% 
%     output_folder = fullfile(sourceFolder, label);
%     if ~exist(output_folder, 'dir')
%         mkdir(output_folder);
%     end
% 
%     % 根据变量类型执行不同的检验
%     if strcmp(label, "gender")
%         % 独立样本t检验
%         results = perform_ttest_2groups(data{1}, data{2}, output_folder);
%         test_type = '独立样本t检验';
% 
%         % 提取P值（5个维度）
%         p_values = zeros(5, 1);
%         for dim = 1:5
%             p_values(dim) = results.(['Dim' num2str(dim)]).PValue;
%         end
% 
%         % 判断显著性
%         significant_count = sum(p_values < 0.05);
% 
%     elseif strcmp(label, "self")
%         group_names = {"others", "self"};
%         output_folder = char(output_folder);
% 
%         % Kruskal-Wallis检验（两组时等价于Mann-Whitney U）
%         results = perform_kruskalwallis_test(cens_used, group_names, output_folder, ...
%             'Alpha', 0.05, ...
%             'Display', true, ...
%             'Filename', 'kw_results.xlsx', ...
%             'MultipleComparison', false);  % 两组不需要事后检验
% 
%         test_type = 'Kruskal-Wallis检验（两组）';
% 
%         % 提取P值（5个维度）
%         p_values = zeros(5, 1);
%         for dim = 1:5
%             p_values(dim) = results.(['Dim_' num2str(dim)]).PValue;
%         end
% 
%         % 判断显著性
%         significant_count = sum(p_values < 0.05);
% 
%     elseif strcmp(label, "makeup")
%         group_names = {"makeup", "no-makeup"};
%         output_folder = char(output_folder);
% 
%         % Kruskal-Wallis检验
%         results = perform_kruskalwallis_test(cens_used, group_names, output_folder, ...
%             'Alpha', 0.05, ...
%             'Display', true, ...
%             'Filename', 'kw_results.xlsx', ...
%             'MultipleComparison', false);
% 
%         test_type = 'Kruskal-Wallis检验';
% 
%         % 提取P值（5个维度）
%         p_values = zeros(5, 1);
%         for dim = 1:5
%             p_values(dim) = results.(['Dim_' num2str(dim)]).PValue;
%         end
% 
%         % 判断显著性
%         significant_count = sum(p_values < 0.05);
% 
%     elseif strcmp(label, "scene")
%         % 准备组名
%         for i_type = 1:size(cens_used, 1)
%             group_names{i_type} = lastParts(i_type);
%         end
%         output_folder = char(output_folder);
% 
%         % Kruskal-Wallis检验（多组）
%         results = perform_kruskalwallis_test(cens_used, group_names, output_folder, ...
%             'Alpha', 0.05, ...
%             'Display', true, ...
%             'Filename', 'kw_results.xlsx', ...
%             'MultipleComparison', true);
% 
%         test_type = 'Kruskal-Wallis检验（多组）';
% 
%         % 提取P值（5个维度）
%         p_values = zeros(5, 1);
%         for dim = 1:5
%             p_values(dim) = results.(['Dim_' num2str(dim)]).PValue;
%         end
% 
%         % 判断显著性
%         significant_count = sum(p_values < 0.05);
% 
%         % 事后检验
%         results_dunn = perform_nonparametric_posthoc_tests(cens_used, group_names, ...
%             'Method', 'dunn', ...
%             'Alpha', 0.05, ...
%             'Display', true, ...
%             'ExportExcel', true, ...
%             'ExcelPath', output_folder);
% 
%     elseif strcmp(label, "model")
%         types = ["female1", "female2", "female3", "female4", "female5", ...
%             "male1", "male2", "male3", "male4"];
% 
%         for i_type = 1:size(cens_used, 1)
%             group_names{i_type} = types(i_type);
%         end
%         output_folder = char(output_folder);
% 
%         % DeltaE2000颜色差异分析
%         deltaE_results = calculate_deltaE_simple(cens_used, group_names, output_folder);
%         test_type = 'DeltaE2000颜色差异';
% 
%         % 对于DeltaE分析，我们关注组间/组内比值
%         % 这里简化处理，使用ratio作为判断依据
%         p_values = NaN;  % DeltaE没有p值概念
%         significant_count = NaN;
% 
%     end
% 
%     % 存储结果
%     all_results{var_idx} = struct(...
%         'Label', label, ...
%         'TestType', test_type, ...
%         'PValues', p_values, ...
%         'SignificantCount', significant_count ...
%     );
% 
%     % 填充汇总表格
%     summary_table{1, var_idx+1} = label;  % 列标题
%     summary_table{2, var_idx+1} = test_type;
% 
%     if ~all(isnan(p_values))
%         % 计算统计量
%         p_min = min(p_values);
%         p_max = max(p_values);
%         p_mean = mean(p_values);
%         p_median = median(p_values);
% 
%         summary_table{3, var_idx+1} = p_min;
%         summary_table{4, var_idx+1} = p_max;
%         summary_table{5, var_idx+1} = p_mean;
%         summary_table{6, var_idx+1} = p_median;
%         summary_table{7, var_idx+1} = sprintf('%d/5', significant_count);
% 
%         % 判断检验结论
%         if significant_count == 5
%             conclusion = '所有维度显著差异';
%         elseif significant_count >= 3
%             conclusion = '多数维度显著差异';
%         elseif significant_count >= 1
%             conclusion = '部分维度显著差异';
%         else
%             conclusion = '无显著差异';
%         end
% 
%         % 添加p值范围信息
%         if p_min > 0.05
%             conclusion = sprintf('%s (所有p>0.05)', conclusion);
%         elseif p_max < 0.05
%             conclusion = sprintf('%s (所有p<0.05)', conclusion);
%         else
%             conclusion = sprintf('%s (p范围:%.3f-%.3f)', conclusion, p_min, p_max);
%         end
% 
%     else
%         % DeltaE分析的特殊处理
%         summary_table{3, var_idx+1} = 'N/A';
%         summary_table{4, var_idx+1} = 'N/A';
%         summary_table{5, var_idx+1} = 'N/A';
%         summary_table{6, var_idx+1} = 'N/A';
%         summary_table{7, var_idx+1} = 'N/A';
% 
%         if isfield(deltaE_results, 'ratio')
%             ratio = deltaE_results.ratio;
%             if ratio > 1
%                 conclusion = sprintf('组间差异>组内差异 (%.2f倍)', ratio);
%             else
%                 conclusion = sprintf('组内差异>组间差异 (%.2f倍)', ratio);
%             end
%         else
%             conclusion = '颜色差异分析';
%         end
%     end
% 
%     summary_table{8, var_idx+1} = conclusion;
% 
%     % 显示当前变量结果
%     fprintf('检验类型: %s\n', test_type);
%     if ~all(isnan(p_values))
%         fprintf('P值统计: 最小=%.6f, 最大=%.6f, 平均=%.6f\n', p_min, p_max, p_mean);
%         fprintf('显著维度: %d/5\n', significant_count);
%     end
%     fprintf('结论: %s\n\n', conclusion);
% end
% 
% %% 保存汇总表到Excel
% summary_folder = fullfile(sourceFolder, 'Summary_Results');
% if ~exist(summary_folder, 'dir')
%     mkdir(summary_folder);
% end
% 
% summary_filename = fullfile(summary_folder, 'all_tests_summary.xlsx');
% 
% % 写入主汇总表
% writecell(summary_table, summary_filename, 'Sheet', '汇总表');
% 
% % 创建详细统计表
% detailed_table = cell(6, num_vars + 1);
% detailed_table{1, 1} = '统计指标';
% detailed_table{2, 1} = '检验类型';
% detailed_table{3, 1} = '样本组数';
% detailed_table{4, 1} = '总样本量';
% detailed_table{5, 1} = '分析方法';
% detailed_table{6, 1} = '主要发现';
% 
% for var_idx = 1:num_vars
%     cens_used = all_cens{var_idx};
%     label = all_labels{var_idx};
% 
%     detailed_table{1, var_idx+1} = label;
%     detailed_table{2, var_idx+1} = summary_table{2, var_idx+1};
% 
%     % 计算样本信息
%     total_groups = size(cens_used, 1);
%     total_samples = 0;
%     for i = 1:total_groups
%         total_samples = total_samples + size(cens_used{i, 1}, 1);
%     end
% 
%     detailed_table{3, var_idx+1} = total_groups;
%     detailed_table{4, var_idx+1} = total_samples;
% 
%     % 分析方法说明
%     if strcmp(label, "gender")
%         method_desc = '独立样本t检验，适用于两组正态分布数据比较';
%     elseif strcmp(label, "self") || strcmp(label, "makeup")
%         method_desc = '非参数Kruskal-Wallis检验，适用于两组非正态分布数据';
%     elseif strcmp(label, "scene")
%         method_desc = '多组非参数Kruskal-Wallis检验+Dunn事后检验';
%     elseif strcmp(label, "model")
%         method_desc = 'DeltaE2000颜色差异分析，比较组内和组间颜色差异';
%     end
% 
%     detailed_table{5, var_idx+1} = method_desc;
%     detailed_table{6, var_idx+1} = summary_table{8, var_idx+1};
% end
% 
% writecell(detailed_table, summary_filename, 'Sheet', '详细说明');
% 
% % 创建P值分布表（只对有p值的检验）
% pvalue_table = cell(num_vars + 2, 7);
% pvalue_table{1, 1} = '变量';
% pvalue_table{1, 2} = '维度1 P值';
% pvalue_table{1, 3} = '维度2 P值';
% pvalue_table{1, 4} = '维度3 P值';
% pvalue_table{1, 5} = '维度4 P值';
% pvalue_table{1, 6} = '维度5 P值';
% pvalue_table{1, 7} = '平均P值';
% 
% for var_idx = 1:num_vars
%     results = all_results{var_idx};
%     pvalue_table{var_idx+1, 1} = results.Label;
% 
%     if ~all(isnan(results.PValues))
%         for dim = 1:5
%             pvalue_table{var_idx+1, dim+1} = results.PValues(dim);
%         end
%         pvalue_table{var_idx+1, 7} = mean(results.PValues);
%     else
%         for dim = 1:6
%             pvalue_table{var_idx+1, dim+1} = 'N/A';
%         end
%     end
% end
% 
% % 添加显著性标注
% pvalue_table{num_vars+2, 1} = '显著性标注';
% pvalue_table{num_vars+2, 2} = '**p<0.01, *p<0.05';
% pvalue_table{num_vars+2, 7} = '平均值';
% 
% writecell(pvalue_table, summary_filename, 'Sheet', 'P值分布');
% 
% disp(summary_filename);
% 
