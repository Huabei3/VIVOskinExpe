close all; clc; clear;
%% 定义参数
attributes = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
attribute_names_new = ["Preference", "Attractiveness", "Feminine", "Cooperative", ...
    "Youth", "Healthy", "Fidelity", "Harmony", "Fair", "Ruddy"];
nations = ["AS", "CA", "SA", "AF"];
nation_names=["Asian","Caucasian","South Asian","African"];
lastParts = {'f04i', 'f05i', 'f06i', 'm04i', 'm05i', 'm06i',...
'f01i', 'f02i', 'f03i', 'm01i', 'm02i', 'm03i',...
'f07i', 'f08i','m07i', 'm08i',...
'f09i', 'f10i','m09i', 'm10i'};n_para = 21;iOr='i';
% lastParts = {'f04r', 'f05r', 'f06r', 'm04r', 'm05r', 'm06r',...
% 'f01r', 'f02r', 'f03r', 'm01r', 'm02r', 'm03r',...
% 'f07r', 'f08r','m07r', 'm08r',...
% 'f09r', 'f10r','m09r', 'm10r'};n_para = 14;iOr='r';
load("documents\valid_attr.mat", "map");
wd65 = [94.811, 100.00, 107.304];
datai_file = 'D:\work\VIVOskinExpe\renderCode\calibResults\datai_ipv18_3.mat';
LUT = load(datai_file);
XYZw_LUT = LUT.XYZw;
colors = hsv(length(attributes));
obs_types = ["non_model", "model_group", "model"];
% 定义人种对应的lastParts索引
nation_indices = cell(5, 1);
nation_indices{1} = 1:6;      % AS (Asian)
nation_indices{2} = 7:12;     % CA (Caucasian)  
nation_indices{3} = 13:16;    % SA (South Asian)
nation_indices{4} = 17:20;    % AF (African)
nation_indices{5} = 1:20;     % all
% 加载数据
Dtype = "efit2";
output_folder = fullfile("ellip_pic", Dtype);
load(fullfile(output_folder, strcat("data_reshaped_", iOr, ".mat")), "lab_fit_reshaped");

% 添加路径（确保函数可用）
addpath("utils\");

% 创建存储检验结果的单元格数组
anova_results = cell(length(nations), length(obs_types)); 
assumption_results = cell(length(nations), length(obs_types)); % 存储假设检验结果

%% 执行ANOVA检验
obs_types_for_loop = ["non_model","model_group"]; % Limit observer types for this analysis
for i_nation = 1:length(nations) % Outer loop: Iterate through nations
    nation = nations(i_nation);
    nation_name = nation_names(i_nation);
    curr_nation_lastParts_indices = nation_indices{i_nation}; % This is used to get the actual lastPart string

    for i_obs = 1:length(obs_types_for_loop) % Inner loop: Iterate through observer types
        obs_type = obs_types_for_loop(i_obs);
        
        fprintf('\n=== Nation: %s, Observer: %s ===\n', nation_name, obs_type);
        
        % Initialize p_values and significant flags for L, C, h
        p_values = [1, 1, 1]; 
        significant = [false, false, false]; 
        group_labels = attribute_names_new; % Groups are now attributes

        % Extract valid data for the current nation and observer type, grouped by attribute
        attr_L_data = cell(length(attributes), 1);
        attr_C_data = cell(length(attributes), 1);
        attr_h_data = cell(length(attributes), 1);

        % Collect data for all attributes within the current nation and observer type
        for i_attr = 1:length(attributes)
            attribute = attributes(i_attr);
            
            % Initialize current attribute's data
            curr_attr_L = [];
            curr_attr_C = [];
            curr_attr_h = [];

            % Loop through the *internal* indices for the third dimension of lab_fit_reshaped
            for j_lastPart_internal_idx = 1:length(curr_nation_lastParts_indices) 
                
                % Determine which observation data to use based on attribute 7 condition
                i_obs_used = i_obs; % Default to current observer type index
                if attribute == 7
                    i_obs_used_idx_in_full_list = find(strcmp(obs_types, "model_group"));
                    if ~isempty(i_obs_used_idx_in_full_list)
                        i_obs_used = i_obs_used_idx_in_full_list;
                    else
                        warning('Model group not found in full obs_types list for attribute 7 adjustment.');
                    end
                end

                % CORRECTED LINE: Use j_lastPart_internal_idx for the third dimension
                L_data_temp = lab_fit_reshaped{i_obs_used, i_nation}(:, 1, j_lastPart_internal_idx, attribute);
                a_data_temp = lab_fit_reshaped{i_obs_used, i_nation}(:, 2, j_lastPart_internal_idx, attribute);
                b_data_temp = lab_fit_reshaped{i_obs_used, i_nation}(:, 3, j_lastPart_internal_idx, attribute);
                
                C_data_temp = sqrt(a_data_temp.^2 + b_data_temp.^2);
                h_data_temp = atan2d(b_data_temp, a_data_temp);

                valid_indices = ~isnan(L_data_temp) & ~isnan(C_data_temp) & ~isnan(h_data_temp);
                
                curr_attr_L = [curr_attr_L; L_data_temp(valid_indices)];
                curr_attr_C = [curr_attr_C; C_data_temp(valid_indices)];
                curr_attr_h = [curr_attr_h; h_data_temp(valid_indices)];
            end
            
            attr_L_data{i_attr} = curr_attr_L;
            attr_C_data{i_attr} = curr_attr_C;
            attr_h_data{i_attr} = curr_attr_h;
        end

        % Ensure each attribute group has enough samples for ANOVA
        all_valid_for_anova = true;
        for i_attr = 1:length(attributes)
            if length(attr_L_data{i_attr}) < 2 || length(attr_C_data{i_attr}) < 2 || length(attr_h_data{i_attr}) < 2
                all_valid_for_anova = false;
                fprintf('警告: 属性 %s 数据不足，跳过ANOVA\n', attribute_names_new(i_attr));
                break;
            end
        end
        
        if ~all_valid_for_anova
            % Store empty result or skip if not enough data for ANOVA
            anova_results{i_nation, i_obs} = struct( ...
                'p_value_L', NaN, 'p_value_C', NaN, 'p_value_h', NaN, ...
                'significant_L', false, 'significant_C', false, 'significant_h', false, ...
                'group_labels', attribute_names_new, ...
                'comparison_L', [], 'comparison_C', [], 'comparison_h', []);
            
            assumption_results{i_nation, i_obs} = struct( ...
                'L_Normality', '数据不足', 'C_Normality', '数据不足', 'h_Normality', '数据不足', ...
                'Homogeneity', '数据不足', ...
                'Normality_Conclusion', '数据不足', 'Homogeneity_Conclusion', '数据不足');
            continue; 
        end

        % Initialize multiple comparison results
        comp_L = [];
        comp_C = [];
        comp_h = [];
        
        % Perform ANOVA for L, C, and h
        for i_dim = 1:3 % 1 for L, 2 for C, 3 for h
            fprintf('\n分析维度: ');
            if i_dim == 1
                group_data = attr_L_data;
                dim_name = 'L*';
            elseif i_dim == 2
                group_data = attr_C_data;
                dim_name = 'C*';
            else
                group_data = attr_h_data;
                dim_name = 'h*';
            end
            fprintf('%s\n', dim_name);
            
            % Combine data from all groups (attributes)
            all_data = [];
            group_labels_num = [];
            
            for i_attr_group = 1:length(attributes)
                curr_data = group_data{i_attr_group};
                all_data = [all_data; curr_data];
                group_labels_num = [group_labels_num; i_attr_group*ones(size(curr_data))];
            end
            
            % ========== 执行正态性和方差齐性检验 ==========
            fprintf('  执行正态性和方差齐性检验...\n');
            
            % 将数据转换为perform_lilliefors_and_homogeneity函数需要的格式
            % 需要将数据按组分离为元胞数组
            data_cell = cell(length(attributes), 1);
            for i_attr_group = 1:length(attributes)
                data_cell{i_attr_group} = group_data{i_attr_group};
            end
            
            % 创建标签
            label = sprintf('%s_%s_%s', nation_name, obs_type, dim_name);
            
            % 创建临时文件夹存储检验结果
            temp_folder = fullfile(output_folder, 'Assumption_Tests');
            if ~exist(temp_folder, 'dir')
                mkdir(temp_folder);
            end
            
            % 调用正态性和方差齐性检验函数
            try
                [normality_results, homogeneity_results, summary_stats] = ...
                    perform_lilliefors_and_homogeneity(data_cell, attribute_names_new, temp_folder, 'Display', false);
                
                % 存储假设检验结果
                if i_dim == 1
                    assumption_results{i_nation, i_obs} = struct();
                end
                
                % 保存正态性结论
                assumption_results{i_nation, i_obs}.([dim_name '_Normality']) = summary_stats.normality_conclusion;
                assumption_results{i_nation, i_obs}.([dim_name '_Normality_P_min']) = summary_stats.normality_p_min;
                assumption_results{i_nation, i_obs}.([dim_name '_Normality_P_mean']) = summary_stats.normality_p_mean;
                
                % 保存方差齐性结论
                if i_dim == 1 % 只保存一次方差齐性结果（假设对所有维度相同）
                    assumption_results{i_nation, i_obs}.Homogeneity = summary_stats.homogeneity_conclusion;
                    assumption_results{i_nation, i_obs}.Homogeneity_P_min = summary_stats.homogeneity_p_min;
                    assumption_results{i_nation, i_obs}.Homogeneity_P_mean = summary_stats.homogeneity_p_mean;
                end
                
                fprintf('    正态性: %s (P_min=%.4f, P_mean=%.4f)\n', ...
                    summary_stats.normality_conclusion, ...
                    summary_stats.normality_p_min, ...
                    summary_stats.normality_p_mean);
                
                if i_dim == 1
                    fprintf('    方差齐性: %s (P_min=%.4f, P_mean=%.4f)\n', ...
                        summary_stats.homogeneity_conclusion, ...
                        summary_stats.homogeneity_p_min, ...
                        summary_stats.homogeneity_p_mean);
                end
                
                % 检查假设是否满足
                normality_ok = summary_stats.normality_p_min >= 0.05; % 所有P值都≥0.05
                homogeneity_ok = summary_stats.homogeneity_p_min >= 0.05;
                
                if ~normality_ok
                    fprintf('    警告: 正态性假设可能不满足，建议使用非参数检验\n');
                end
                if ~homogeneity_ok
                    fprintf('    警告: 方差齐性假设可能不满足，建议使用校正的ANOVA\n');
                end
                
            catch ME
                fprintf('    假设检验错误: %s\n', ME.message);
                assumption_results{i_nation, i_obs}.([dim_name '_Normality']) = '检验失败';
            end
            
            % ========== 执行ANOVA ==========
            fprintf('  执行ANOVA...\n');
            [p, ~, stats] = anovan(all_data, {group_labels_num}); % 'off' to suppress display
            close all force; % Close the ANOVA figure
            
            p_values(i_dim) = p;
            significant(i_dim) = p < 0.05;
            
            fprintf('    ANOVA p值: %.6f (%s)\n', p, ifelse(p < 0.05, '显著', '不显著'));
            
            % Perform multiple comparisons (if ANOVA is significant)
            if significant(i_dim)
                fprintf('    进行多重比较...\n');
                if i_dim == 1
                    comp_L = multcompare(stats, 'Display', 'off');
                elseif i_dim == 2
                    comp_C = multcompare(stats, 'Display', 'off');
                else
                    comp_h = multcompare(stats, 'Display', 'off');
                end
                close all force; % Close multcompare figure
            end
        end
        
        % Store results for current nation and observer type
        anova_results{i_nation, i_obs} = struct( ...
            'p_value_L', p_values(1), ...
            'p_value_C', p_values(2), ...
            'p_value_h', p_values(3), ...
            'significant_L', significant(1), ...
            'significant_C', significant(2), ...
            'significant_h', significant(3), ...
            'group_labels', group_labels, ...
            'comparison_L', comp_L, ...
            'comparison_C', comp_C, ...
            'comparison_h', comp_h);
            
        fprintf('=== %s %s 分析完成 ===\n\n', nation_name, obs_type);
    end
end

% ********** Collect ANOVA results into a cell array for Excel export **********
anova_results_cell = {};

% Populate ANOVA result data
for i_nation = 1:length(nations)
    nation_name = nation_names(i_nation);
    
    for i_obs = 1:length(obs_types_for_loop)
        obs_type = obs_types_for_loop(i_obs);
        
        result = anova_results{i_nation, i_obs};
        
        anova_results_cell{end+1, 1} = char(nation_name);
        anova_results_cell{end, 2} = char(obs_type);
        
        if isempty(result) || ~isfield(result, 'p_value_L')
            anova_results_cell{end, 3} = NaN;  % p_value_L
            anova_results_cell{end, 4} = NaN;  % p_value_C
            anova_results_cell{end, 5} = NaN;  % p_value_h
            anova_results_cell{end, 6} = NaN;  % significant_L
            anova_results_cell{end, 7} = NaN;  % significant_C
            anova_results_cell{end, 8} = NaN;  % significant_h
            anova_results_cell{end, 9} = NaN;  % significant (overall)
        else
            anova_results_cell{end, 3} = result.p_value_L;
            anova_results_cell{end, 4} = result.p_value_C;
            anova_results_cell{end, 5} = result.p_value_h;
            anova_results_cell{end, 6} = result.significant_L;
            anova_results_cell{end, 7} = result.significant_C;
            anova_results_cell{end, 8} = result.significant_h;
            anova_results_cell{end, 9} = result.significant_L || result.significant_C || result.significant_h; % significant overall
        end
    end
end

% ********** Collect Assumption Test results **********
assumption_results_cell = {};
assumption_results_cell{1, 1} = 'Nation';
assumption_results_cell{1, 2} = 'ObserverType';
assumption_results_cell{1, 3} = 'Dimension';
assumption_results_cell{1, 4} = 'Normality_Conclusion';
assumption_results_cell{1, 5} = 'Normality_P_min';
assumption_results_cell{1, 6} = 'Normality_P_mean';
assumption_results_cell{1, 7} = 'Homogeneity_Conclusion';
assumption_results_cell{1, 8} = 'Homogeneity_P_min';
assumption_results_cell{1, 9} = 'Homogeneity_P_mean';
assumption_results_cell{1, 10} = 'ANOVA_Applicable';

row_idx = 2;
for i_nation = 1:length(nations)
    nation_name = nation_names(i_nation);
    
    for i_obs = 1:length(obs_types_for_loop)
        obs_type = obs_types_for_loop(i_obs);
        
        result = assumption_results{i_nation, i_obs};
        
        if ~isempty(result)
            % L* 维度
            assumption_results_cell{row_idx, 1} = char(nation_name);
            assumption_results_cell{row_idx, 2} = char(obs_type);
            assumption_results_cell{row_idx, 3} = 'L*';
            assumption_results_cell{row_idx, 4} = result.L_Normality;
            assumption_results_cell{row_idx, 5} = result.L_Normality_P_min;
            assumption_results_cell{row_idx, 6} = result.L_Normality_P_mean;
            assumption_results_cell{row_idx, 7} = result.Homogeneity;
            assumption_results_cell{row_idx, 8} = result.Homogeneity_P_min;
            assumption_results_cell{row_idx, 9} = result.Homogeneity_P_mean;
            
            % 判断ANOVA是否适用
            if result.L_Normality_P_min >= 0.05 && result.Homogeneity_P_min >= 0.05
                assumption_results_cell{row_idx, 10} = '适用';
            else
                assumption_results_cell{row_idx, 10} = '不适用（建议非参数检验）';
            end
            row_idx = row_idx + 1;
            
            % C* 维度
            assumption_results_cell{row_idx, 1} = char(nation_name);
            assumption_results_cell{row_idx, 2} = char(obs_type);
            assumption_results_cell{row_idx, 3} = 'C*';
            assumption_results_cell{row_idx, 4} = result.C_Normality;
            assumption_results_cell{row_idx, 5} = result.C_Normality_P_min;
            assumption_results_cell{row_idx, 6} = result.C_Normality_P_mean;
            assumption_results_cell{row_idx, 7} = result.Homogeneity;
            assumption_results_cell{row_idx, 8} = result.Homogeneity_P_min;
            assumption_results_cell{row_idx, 9} = result.Homogeneity_P_mean;
            row_idx = row_idx + 1;
            
            % h* 维度
            assumption_results_cell{row_idx, 1} = char(nation_name);
            assumption_results_cell{row_idx, 2} = char(obs_type);
            assumption_results_cell{row_idx, 3} = 'h*';
            assumption_results_cell{row_idx, 4} = result.h_Normality;
            assumption_results_cell{row_idx, 5} = result.h_Normality_P_min;
            assumption_results_cell{row_idx, 6} = result.h_Normality_P_mean;
            assumption_results_cell{row_idx, 7} = result.Homogeneity;
            assumption_results_cell{row_idx, 8} = result.Homogeneity_P_min;
            assumption_results_cell{row_idx, 9} = result.Homogeneity_P_mean;
            row_idx = row_idx + 1;
        end
    end
end

% ********** Save processed data **********
output_folder_attr = fullfile(output_folder, "attribute");
if ~exist(output_folder_attr, "dir")
    mkdir(output_folder_attr);
end

% Save ANOVA results
xlsx_file_anova = fullfile(output_folder_attr, strcat(iOr, '_attribute_ANOVA_LCh.xlsx'));
anova_header = {'Nation', 'ObserverType', 'PValue_L', 'PValue_C', 'PValue_h', ...
          'Significant_L', 'Significant_C', 'Significant_h', 'Significant_Overall'};
anova_results_with_header = [anova_header; anova_results_cell];
xlswrite(xlsx_file_anova, anova_results_with_header, 'ANOVA结果');
fprintf('ANOVA结果保存到: %s\n', xlsx_file_anova);

% Save assumption test results
xlswrite(xlsx_file_anova, assumption_results_cell, '假设检验结果');
fprintf('假设检验结果保存到: %s\n', xlsx_file_anova);

% ********** 创建汇总报告 **********
summary_cell = {};
summary_cell{1, 1} = '=== ANOVA和假设检验汇总报告 ===';
summary_cell{2, 1} = sprintf('数据文件: data_reshaped_%s.mat', iOr);
summary_cell{3, 1} = sprintf('分析时间: %s', datestr(now));
summary_cell{5, 1} = '一、ANOVA结果摘要:';

row_idx = 6;
for i_nation = 1:length(nations)
    for i_obs = 1:length(obs_types_for_loop)
        result = anova_results{i_nation, i_obs};
        if ~isempty(result) && isfield(result, 'p_value_L')
            summary_cell{row_idx, 1} = sprintf('%s - %s:', nation_names(i_nation), obs_types_for_loop(i_obs));
            summary_cell{row_idx, 2} = sprintf('L*: p=%.4f, C*: p=%.4f, h*: p=%.4f', ...
                result.p_value_L, result.p_value_C, result.p_value_h);
            row_idx = row_idx + 1;
        end
    end
end

row_idx = row_idx + 2;
summary_cell{row_idx, 1} = '二、假设检验结果摘要:';
row_idx = row_idx + 1;

for i_nation = 1:length(nations)
    for i_obs = 1:length(obs_types_for_loop)
        result = assumption_results{i_nation, i_obs};
        if ~isempty(result) && isfield(result, 'L_Normality')
            summary_cell{row_idx, 1} = sprintf('%s - %s:', nation_names(i_nation), obs_types_for_loop(i_obs));
            summary_cell{row_idx, 2} = sprintf('正态性(L*): %s, 方差齐性: %s', ...
                result.L_Normality, result.Homogeneity);
            row_idx = row_idx + 1;
        end
    end
end

% 保存汇总报告
xlswrite(xlsx_file_anova, summary_cell, '汇总报告');

%% 辅助函数
function result = ifelse(condition, true_val, false_val)
    if condition
        result = true_val;
    else
        result = false_val;
    end
end




%%
% close all; clc; clear;
% %% 定义参数
% attributes = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
% attribute_names_new = ["Preference", "Attractiveness", "Feminine", "Cooperative", ...
%     "Youth", "Healthy", "Fidelity", "Harmony", "Fair", "Ruddy"];
% nations = ["AS", "CA", "SA", "AF"];
% nation_names=["Asian","Caucasian","South Asian","African"];
% lastParts = {'f04i', 'f05i', 'f06i', 'm04i', 'm05i', 'm06i',...
% 'f01i', 'f02i', 'f03i', 'm01i', 'm02i', 'm03i',...
% 'f07i', 'f08i','m07i', 'm08i',...
% 'f09i', 'f10i','m09i', 'm10i'};n_para = 21;iOr='i';
% % lastParts = {'f04r', 'f05r', 'f06r', 'm04r', 'm05r', 'm06r',...
% % 'f01r', 'f02r', 'f03r', 'm01r', 'm02r', 'm03r',...
% % 'f07r', 'f08r','m07r', 'm08r',...
% % 'f09r', 'f10r','m09r', 'm10r'};n_para = 14;iOr='r';
% load("documents\valid_attr.mat", "map");
% wd65 = [94.811, 100.00, 107.304];
% datai_file = 'D:\work\VIVOskinExpe\renderCode\calibResults\datai_ipv18_3.mat';
% LUT = load(datai_file);
% XYZw_LUT = LUT.XYZw;
% colors = hsv(length(attributes));
% obs_types = ["non_model", "model_group", "model"];
% % 定义人种对应的lastParts索引
% nation_indices = cell(5, 1);
% nation_indices{1} = 1:6;      % AS (Asian)
% nation_indices{2} = 7:12;     % CA (Caucasian)  
% nation_indices{3} = 13:16;    % SA (South Asian)
% nation_indices{4} = 17:20;    % AF (African)
% nation_indices{5} = 1:20;     % all
% % 加载数据
% Dtype = "efit2";
% output_folder = fullfile("ellip_pic", Dtype);
% load(fullfile(output_folder, strcat("data_reshaped_", iOr, ".mat")), "lab_fit_reshaped");
% % 创建存储检验结果的单元格数组
% % Now anova_results will store results for each nation and observer type
% anova_results = cell(length(nations), length(obs_types)); 
% %% 执行ANOVA检验 (Changed to group by Attribute within each Nation)
% obs_types_for_loop = ["non_model","model_group"]; % Limit observer types for this analysis
% for i_nation = 1:length(nations) % Outer loop: Iterate through nations
%     nation = nations(i_nation);
%     nation_name = nation_names(i_nation);
%     curr_nation_lastParts_indices = nation_indices{i_nation}; % This is used to get the actual lastPart string
% 
%     for i_obs = 1:length(obs_types_for_loop) % Inner loop: Iterate through observer types
%         obs_type = obs_types_for_loop(i_obs);
% 
%         % Initialize p_values and significant flags for L, C, h
%         p_values = [1, 1, 1]; 
%         significant = [false, false, false]; 
%         group_labels = attribute_names_new; % Groups are now attributes
% 
%         % Extract valid data for the current nation and observer type, grouped by attribute
%         attr_L_data = cell(length(attributes), 1);
%         attr_C_data = cell(length(attributes), 1);
%         attr_h_data = cell(length(attributes), 1);
% 
%         % Collect data for all attributes within the current nation and observer type
%         for i_attr = 1:length(attributes)
%             attribute = attributes(i_attr);
% 
%             % Initialize current attribute's data
%             curr_attr_L = [];
%             curr_attr_C = [];
%             curr_attr_h = [];
% 
%             % Loop through the *internal* indices for the third dimension of lab_fit_reshaped
%             % which corresponds to the lastParts for the CURRENT nation
%             for j_lastPart_internal_idx = 1:length(curr_nation_lastParts_indices) 
%                 % lastPart_global_idx = curr_nation_lastParts_indices(j_lastPart_internal_idx); % This variable is not directly used for indexing lab_fit_reshaped
% 
%                 % Determine which observation data to use based on attribute 7 condition
%                 i_obs_used = i_obs; % Default to current observer type index
%                 if attribute == 7
%                     % Note: If attribute is 7, original code used i_obs_used=2 (model_group).
%                     % If "model_group" is always the 2nd element in obs_types, this is fine.
%                     % Otherwise, ensure i_obs_used points to the correct index for "model_group".
%                     % Assuming obs_types_for_loop = ["non_model", "model_group"] means 2 is model_group.
%                     i_obs_used_idx_in_full_list = find(strcmp(obs_types, "model_group"));
%                     if ~isempty(i_obs_used_idx_in_full_list)
%                         i_obs_used = i_obs_used_idx_in_full_list;
%                     else
%                         warning('Model group not found in full obs_types list for attribute 7 adjustment.');
%                     end
%                 end
% 
%                 % CORRECTED LINE: Use j_lastPart_internal_idx for the third dimension
%                 L_data_temp = lab_fit_reshaped{i_obs_used, i_nation}(:, 1, j_lastPart_internal_idx, attribute);
%                 a_data_temp = lab_fit_reshaped{i_obs_used, i_nation}(:, 2, j_lastPart_internal_idx, attribute);
%                 b_data_temp = lab_fit_reshaped{i_obs_used, i_nation}(:, 3, j_lastPart_internal_idx, attribute);
% 
%                 C_data_temp = sqrt(a_data_temp.^2 + b_data_temp.^2);
%                 h_data_temp = atan2d(b_data_temp, a_data_temp);
% 
%                 valid_indices = ~isnan(L_data_temp) & ~isnan(C_data_temp) & ~isnan(h_data_temp);
% 
%                 curr_attr_L = [curr_attr_L; L_data_temp(valid_indices)];
%                 curr_attr_C = [curr_attr_C; C_data_temp(valid_indices)];
%                 curr_attr_h = [curr_attr_h; h_data_temp(valid_indices)];
%             end
% 
%             attr_L_data{i_attr} = curr_attr_L;
%             attr_C_data{i_attr} = curr_attr_C;
%             attr_h_data{i_attr} = curr_attr_h;
%         end
% 
%         % Ensure each attribute group has enough samples for ANOVA
%         all_valid_for_anova = true;
%         for i_attr = 1:length(attributes)
%             if length(attr_L_data{i_attr}) < 2 || length(attr_C_data{i_attr}) < 2 || length(attr_h_data{i_attr}) < 2
%                 all_valid_for_anova = false;
%                 break;
%             end
%         end
% 
%         if ~all_valid_for_anova
%             % Store empty result or skip if not enough data for ANOVA
%             anova_results{i_nation, i_obs} = struct( ...
%                 'p_value_L', NaN, 'p_value_C', NaN, 'p_value_h', NaN, ...
%                 'significant_L', false, 'significant_C', false, 'significant_h', false, ...
%                 'group_labels', attribute_names_new, ...
%                 'comparison_L', [], 'comparison_C', [], 'comparison_h', []);
%             continue; 
%         end
% 
%         % Initialize multiple comparison results
%         comp_L = [];
%         comp_C = [];
%         comp_h = [];
% 
%         % Perform ANOVA for L, C, and h
%         for i_dim = 1:3 % 1 for L, 2 for C, 3 for h
%             if i_dim == 1
%                 group_data = attr_L_data;
%             elseif i_dim == 2
%                 group_data = attr_C_data;
%             else
%                 group_data = attr_h_data;
%             end
% 
%             % Combine data from all groups (attributes)
%             all_data = [];
%             group_labels_num = [];
% 
%             for i_attr_group = 1:length(attributes) % Renamed i_attr to avoid conflict with outer loop
%                 curr_data = group_data{i_attr_group};
%                 all_data = [all_data; curr_data];
%                 group_labels_num = [group_labels_num; i_attr_group*ones(size(curr_data))];
%             end
% 
%             % Perform one-way ANOVA
%             % FIX: Wrap group_labels_num in a cell array for anovan
%             [p, ~, stats] = anovan(all_data, {group_labels_num}); % 'off' to suppress display
%             close all force; % Close the ANOVA figure
% 
%             p_values(i_dim) = p;
%             significant(i_dim) = p < 0.05;
% 
%             % Perform multiple comparisons (if ANOVA is significant)
%             if significant(i_dim)
%                 % It's good practice to close figures generated by multcompare if not needed
%                 if i_dim == 1
%                     comp_L = multcompare(stats, 'Display', 'off');
%                 elseif i_dim == 2
%                     comp_C = multcompare(stats, 'Display', 'off');
%                 else
%                     comp_h = multcompare(stats, 'Display', 'off');
%                 end
%                 close all force; % Close multcompare figure
%             end
%         end
% 
%         % Store results for current nation and observer type
%         anova_results{i_nation, i_obs} = struct( ...
%             'p_value_L', p_values(1), ...
%             'p_value_C', p_values(2), ...
%             'p_value_h', p_values(3), ...
%             'significant_L', significant(1), ...
%             'significant_C', significant(2), ...
%             'significant_h', significant(3), ...
%             'group_labels', group_labels, ...
%             'comparison_L', comp_L, ...
%             'comparison_C', comp_C, ...
%             'comparison_h', comp_h);
%     end
% end
% 
% % ********** Collect results into a cell array for Excel export **********
% results_cell = {};
% 
% % Populate result data
% for i_nation = 1:length(nations)
%     nation_name = nation_names(i_nation);
% 
%     for i_obs = 1:length(obs_types_for_loop)
%         obs_type = obs_types_for_loop(i_obs);
% 
%         result = anova_results{i_nation, i_obs};
% 
%         results_cell{end+1, 1} = char(nation_name);
%         results_cell{end, 2} = char(obs_type);
% 
%         if isempty(result) || ~isfield(result, 'p_value_L')
%             results_cell{end, 3} = NaN;  % p_value_L
%             results_cell{end, 4} = NaN;  % p_value_C
%             results_cell{end, 5} = NaN;  % p_value_h
%             results_cell{end, 6} = NaN;  % significant_L
%             results_cell{end, 7} = NaN;  % significant_C
%             results_cell{end, 8} = NaN;  % significant_h
%             results_cell{end, 9} = NaN;  % significant (overall)
%         else
%             results_cell{end, 3} = result.p_value_L;
%             results_cell{end, 4} = result.p_value_C;
%             results_cell{end, 5} = result.p_value_h;
%             results_cell{end, 6} = result.significant_L;
%             results_cell{end, 7} = result.significant_C;
%             results_cell{end, 8} = result.significant_h;
%             results_cell{end, 9} = result.significant_L || result.significant_C || result.significant_h; % significant overall
%         end
%     end
% end
% 
% % Add header
% header = {'Nation', 'ObserverType', 'PValue_L', 'PValue_C', 'PValue_h', ...
%           'Significant_L', 'Significant_C', 'Significant_h', 'Significant_Overall'};
% results_with_header = [header; results_cell];
% 
% % ********** Save processed data **********
% output_folder_attr = fullfile(output_folder, "attribute");
% if ~exist(output_folder_attr, "dir")
%     mkdir(output_folder_attr);
% end
% 
% xlsx_file_processed_attr = fullfile(output_folder_attr, strcat(iOr, '_attribute_ANOVA_LCh.xlsx'));
% xlswrite(xlsx_file_processed_attr, results_with_header);
% fprintf('Processed results saved to: %s\n', xlsx_file_processed_attr);