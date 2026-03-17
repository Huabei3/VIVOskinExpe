%% analyze_and_flag_data
% 这个脚本用于遍历特定文件夹结构，计算STRESS，并识别不合格的观测文件夹。

close all;
clc;
clear;

% 将包含您的函数的文件夹添加到路径
addpath("utils\");

% --- 设置主源文件夹路径 ---
source_folder = 'D:\work\VIVOskinExpe\analyze\expRes';

% --- 初始化结果表格 ---
results_table = table('Size', [0, 7], ...
                      'VariableNames', {'obs_ID', 'obs_name', 'Placeholder', 'SubfolderName', 'IsQualified', 'IndMeanStress', 'GroupMeanStress'}, ...
                      'VariableTypes', {'string', 'string', 'double', 'string', 'logical', 'double', 'double'});

% --- 遍历一级子文件夹 (f01i, f01r, m01i, m01r, ...) ---
% 这里的模式匹配可以根据您的实际文件夹命名规则进行调整
pattern = {'f%02di', 'f%02dr', 'm%02di', 'm%02dr'};
for gender_idx = 1:2
    for type_idx = 1:2
        for num = 1:10
            subfolder_name = sprintf(pattern{(gender_idx-1)*2+type_idx}, num);
            first_level_folder = fullfile(source_folder, subfolder_name);

            if ~exist(first_level_folder, 'dir')
                continue; % 如果文件夹不存在则跳过
            end

            second_level_folder = fullfile(first_level_folder, 'non_model');
            if ~exist(second_level_folder, 'dir')
                continue; % 如果 'non_model' 文件夹不存在则跳过
            end

            % --- 遍历二级子文件夹 ('non_model') 下的三级子文件夹 (obs folders) ---
            obs_folders = dir(fullfile(second_level_folder, '*'));
            obs_folders = obs_folders([obs_folders.isdir]);
            obs_folders = obs_folders(~ismember({obs_folders.name}, {'.', '..', 'stress_mat'})); % 排除特殊文件夹

            % --- 处理每个obs文件夹 ---
            all_ind_mean_stress = [];
            for j = 1:length(obs_folders)
                obs_folder_path = fullfile(second_level_folder, obs_folders(j).name);

                % 定义输入和输出路径
                dir_ind_csv = dir(fullfile(obs_folder_path, "*.csv"));
                output_folder_ind = fullfile(obs_folder_path, "stress_mat");
                % 获取所有文件的大小
                file_sizes = [dir_ind_csv.bytes];
                file_sizes=round(file_sizes./100).*100;

                % 计算文件大小的众数
                file_mode = mode(file_sizes);

                % 设定阈值（10%）
                threshold = 0.20 * file_mode;

                % 找到并移除大小与众数相差超过10%的文件
                % abs() 函数计算差的绝对值
                % ismember() 函数用于查找哪些文件大小在保留列表中
                valid_files_logic = abs(file_sizes - file_mode) <= threshold;
                dir_ind_csv = dir_ind_csv(valid_files_logic);
                % 调用封装的函数来处理数据
                process_subject_stress(dir_ind_csv, output_folder_ind);

                % --- 加载STRESS数据并计算ind_mean_stress ---
                stress_file = fullfile(output_folder_ind, 'STRESS.mat');
                ind_mean_stress = nan; % 默认值
                if exist(stress_file, 'file')
                    load(stress_file, 'STRESS_intra');
                    if exist('STRESS_intra', 'var') && iscell(STRESS_intra) && size(STRESS_intra, 2) >= 2
                        % 确保第二列是数字
                        second_col_data = cellfun(@(x) x, STRESS_intra(:, 2), 'UniformOutput', false);
                        numeric_data = cell2mat(second_col_data);
                        if isnumeric(numeric_data)
                            ind_mean_stress = nanmean(numeric_data);
                        end
                    end
                end

                % 存储所有有效的ind_mean_stress
                if ~isnan(ind_mean_stress)
                    all_ind_mean_stress(end+1) = ind_mean_stress;
                end

            end % for j (obs folders)

            % --- 计算组平均值并识别不合格文件夹 ---
            group_mean_stress = nanmean(all_ind_mean_stress);

            for j = 1:length(obs_folders)
                obs_folder_name = obs_folders(j).name;

                % 提取 obs_name 和 obs_ID
                underscore_pos = strfind(obs_folder_name, '_');
                if isempty(underscore_pos)
                    obs_name = obs_folder_name;
                    obs_ID = "nan";
                else
                    obs_name = obs_folder_name(1:underscore_pos-1);
                    obs_ID = obs_folder_name(underscore_pos+1:end);
                end

                % 获取该文件夹的ind_mean_stress
                current_ind_mean_stress = nan;
                stress_file = fullfile(second_level_folder, obs_folder_name, 'stress_mat', 'STRESS.mat');
                if exist(stress_file, 'file')
                    load(stress_file, 'STRESS_intra');
                    if exist('STRESS_intra', 'var')
                        second_col_data = cellfun(@(x) x, STRESS_intra(:, 2), 'UniformOutput', false);
                        numeric_data = cell2mat(second_col_data);
                        if isnumeric(numeric_data)
                            current_ind_mean_stress = nanmean(numeric_data);
                        end
                    end
                end

                % 判断是否合格
                is_qualified = true;
                if ~isnan(group_mean_stress) && ~isnan(current_ind_mean_stress)
                    if current_ind_mean_stress > group_mean_stress * 1.5
                        is_qualified = false;
                    end
                end

                % 将结果添加到表格
                new_row = {obs_ID, obs_name, nan, second_level_folder, is_qualified, current_ind_mean_stress, group_mean_stress};
                results_table = [results_table; new_row];

            end % for j (obs folders)

        end % for num
    end % for type_idx
end % for gender_idx

% --- 保存结果到XLSX文件 ---
output_excel_path = fullfile("D:\work\VIVOskinExpe\汇报PPT", '绩效报销.xlsx');
writetable(results_table, output_excel_path);

disp(['分析完成，结果已保存到: ', output_excel_path]);