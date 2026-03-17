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

load("documents\valid_attr.mat", "map");

wd65 = [94.811, 100.00, 107.304];
datai_file = 'D:\work\VIVOskinExpe\renderCode\calibResults\datai_ipv18_3.mat';
LUT = load(datai_file);
XYZw_LUT = LUT.XYZw;
colors = hsv(length(attributes));
obs_types = ["non_model", "model_group", "model"];

% 定义人种对应的lastParts索引
nation_indices = cell(5, 1);
nation_indices{1} = 1:6;     % AS (Asian)
nation_indices{2} = 7:12;    % CA (Caucasian)  
nation_indices{3} = 13:16;   % SA (South Asian)
nation_indices{4} = 17:20;   % AF (African)
nation_indices{5} = 1:20;    % all

% 加载数据
Dtype = "efit2";
output_folder = fullfile("ellip_pic", Dtype);
load(fullfile(output_folder, strcat("data_reshaped_", iOr, ".mat")), "lab_fit_reshaped");

% 创建存储检验结果的单元格数组
anova_results = cell(length(obs_types), length(nations), length(attributes));

%% 执行ANOVA检验
obs_types = ["non_model","model_group"];
for i_obs = 1:length(obs_types)
    obs_type = obs_types(i_obs);
    
    for i_nation = 1:length(nations)
        nation = nations(i_nation);
        nation_name = nation_names(i_nation);
        
        % 获取当前人种的lastPart索引（不区分性别）
        curr_nation_indices = nation_indices{i_nation};
        n_lastParts = length(curr_nation_indices);
        
        % 检查样本量
        if n_lastParts < 2
            fprintf('警告: %s 人种的lastPart数量不足，跳过检验\n', char(nation_name));
            continue;
        end
        
        for i_attr = 1:length(attributes)
            attribute = attributes(i_attr);
            attribute_name = attribute_names_new(attribute);
            
            % 初始化检验结果
            p_values = [1, 1];
            significant = [false, false];
            group_labels = cell(n_lastParts, 1);  % 存储每个lastPart的标签
            
            % 提取各lastPart组别的有效数据
            part_a_data = cell(n_lastParts, 1);
            part_b_data = cell(n_lastParts, 1);
            
            % 按lastPart分组收集数据（不区分性别）
            for i_part = 1:n_lastParts
                part_idx = curr_nation_indices(i_part);
                lastPart = lastParts{part_idx};
                
                % 生成组标签（例如：AS_1, AS_2,...）
                group_labels{i_part} = [char(nation), '_', num2str(i_part)];
                
                % 提取a*和b*值并去除NaN
                if i_attr == 7
                    i_obs_used = 2;
                else
                    i_obs_used = i_obs;
                end
                
                a_data = lab_fit_reshaped{i_obs_used, i_nation}(:, 2, i_part, attribute);
                b_data = lab_fit_reshaped{i_obs_used, i_nation}(:, 3, i_part, attribute);
                
                valid_a = a_data(~isnan(a_data));
                valid_b = b_data(~isnan(b_data));
                
                part_a_data{i_part} = valid_a;
                part_b_data{i_part} = valid_b;
            end
            
            % 确保每组有足够样本
            all_valid = true;
            for i_part = 1:n_lastParts
                if length(part_a_data{i_part}) < 2 || length(part_b_data{i_part}) < 2
                    all_valid = false;
                    break;
                end
            end
            
            if ~all_valid
                continue;
            end
            
            % 初始化多重比较结果
            comp_a = [];
            comp_b = [];
            
            % 执行ANOVA检验
            for i_dim = 1:2
                if i_dim == 1
                    group_data = part_a_data;
                else
                    group_data = part_b_data;
                end
                
                % 合并所有组的数据
                all_data = [];
                group_labels_num = [];
                
                for i_part = 1:n_lastParts
                    curr_data = group_data{i_part};
                    all_data = [all_data; curr_data];
                    group_labels_num = [group_labels_num; i_part*ones(size(curr_data))];
                end
                
                % 执行单因素方差分析
                [p, ~, stats] = anovan(all_data, group_labels_num);
                close all force;
                p_values(i_dim) = p;
                significant(i_dim) = p < 0.05;
                
                % 执行多重比较（如果ANOVA显著）
                if significant(i_dim)
                    if i_dim == 1
                        comp_a = multcompare(stats);
                    else
                        comp_b = multcompare(stats);
                    end
                end
            end
            
            % 存储检验结果
            anova_results{i_obs, i_nation, i_attr} = struct( ...
                'p_value_a', p_values(1), ...
                'p_value_b', p_values(2), ...
                'significant_a', significant(1), ...
                'significant_b', significant(2), ...
                'group_labels', group_labels, ...
                'comparison_a', comp_a, ...
                'comparison_b', comp_b);
        end
        
        % 显示进度
        fprintf('完成检验: %s, %s (属性: %d/%d)\n', ...
                char(obs_type), char(nation_name), i_attr, length(attributes));
    end
    
    % ********** 使用cell数组收集结果 **********
    results_cell = {};
    
    % 填充结果数据
    for i_nation = 1:length(nations)
        nation = nations(i_nation);
        nation_name = nation_names(i_nation);
        
        for i_attr = 1:length(attributes)
            attribute = attributes(i_attr);
            attribute_name = attribute_names_new(attribute);
            
            result = anova_results{i_obs, i_nation, i_attr};
            results_cell{end+1, 1} = char(obs_type);
            results_cell{end, 2} = char(nation_name);
            results_cell{end, 3} = attribute;
            results_cell{end, 4} = char(attribute_name);
            
            if isempty(anova_results{i_obs, i_nation, i_attr}) || ...
               ~isfield(anova_results{i_obs, i_nation, i_attr}, 'p_value_a')
                
                results_cell{end, 5} = NaN;  % p_value_a
                results_cell{end, 6} = NaN;  % p_value_b
                results_cell{end, 7} = NaN;  % significant_a
                results_cell{end, 8} = NaN;  % significant_b
            else
                results_cell{end, 5} = result.p_value_a;
                results_cell{end, 6} = result.p_value_b;
                results_cell{end, 7} = result.significant_a;
                results_cell{end, 8} = result.significant_b;
            end
        end
    end
    
    % 添加表头
    header = {'ObserverType', 'Nation', 'AttributeID', 'AttributeName', 'PValue_a', 'PValue_b', 'Significant_a', 'Significant_b'};
    results_with_header = [header; results_cell];
    
    % ********** 数据处理：删除指定列并调整格式 **********
    % 移除不需要的列（ObserverType, AttributeID）
    % 列索引说明: 1=ObserverType, 2=Nation, 3=AttributeID, 4=AttributeName, 5=PValue_a, 6=PValue_b, 7=Significant_a, 8=Significant_b
    keepCols = [2,4,5,6,7,8];  % 保留: Nation, AttributeName, PValue_a, PValue_b, Significant_a, Significant_b
    results_processed = results_with_header(:, keepCols);
    
    % 保存处理后的数据（路径中nation改为appearance）
    output_folder1 = fullfile(output_folder, "appearance");
    if ~exist(output_folder1, "dir")
        mkdir(output_folder1);
    end
    xlsx_file_processed = fullfile(output_folder1, strcat(iOr, '_', obs_type, '_appearance_ANOVA.xlsx'));
    xlswrite(xlsx_file_processed, results_processed);  % 保存处理后的数据
    fprintf('处理后结果已保存至: %s\n', xlsx_file_processed);
    
    % 保存原始数据备份（包含所有列）
    xlsx_file_raw = fullfile(output_folder1, strcat(iOr, '_', obs_type, '_appearance_ANOVA_raw.xlsx'));
    xlswrite(xlsx_file_raw, results_with_header);  % 保存原始数据
    fprintf('原始数据备份已保存至: %s\n', xlsx_file_raw);
end