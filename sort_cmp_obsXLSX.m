clear; close all; clc;

addpath("utils\")

% --- 1. 定义参数 ---
source_folder = 'D:\work\VIVOskinExpe\analyze\AnalyseResults1\efit2\sum_list';
output_filename = fullfile(source_folder, 'com_obs.xlsx');
obs_types = ["non_model", "model_group", "model"];
nations = ["AS", "CA", "SA", "AF"];

if exist(output_filename, 'file')
    delete(output_filename);
    fprintf('已删除旧的结果文件: %s\n', output_filename);
end

fprintf('开始合并Excel文件...\n\n');

% --- 2. 按 Nation 循环 (对应每个工作表) ---
for i_nation = 1:length(nations)
    current_nation = nations(i_nation);
    fprintf('正在处理工作表: %s\n', current_nation);
    combined_sheet_data = {};

    % --- 3. 按 obs_type 循环 (对应每个源文件) ---
    for i_obs = 1:length(obs_types)
        current_obs_type = obs_types(i_obs);

        source_filename = strcat("characteristic_para_i_", current_obs_type, ".xlsx");
        source_filepath = fullfile(source_folder, source_filename);

        try
            fprintf(' -> 正在读取文件: %s\n', source_filename);
            [~, ~, raw_data] = xlsread(source_filepath, char(current_nation));

            if isempty(raw_data)
                warning(' -> 在文件 "%s" 的工作表 "%s" 中未找到数据，已跳过。', source_filename, current_nation);
                continue;
            end

            num_cols_to_take = min(5, size(raw_data, 2));
            data_to_combine = raw_data(:, 1:num_cols_to_take);
            combined_sheet_data = [combined_sheet_data, data_to_combine];

        catch ME
            warning(' -> 读取失败！无法从 "%s" 中读取工作表 "%s"。\n 错误信息: %s\n 已跳过此文件。', ...
                source_filename, current_nation, ME.message);
        end
    end

    % --- 4. 读取 average_i.XLSX 文件并拼接前7列 ---
    try
        average_filename = 'average_i.XLSX';
        average_filepath = fullfile(source_folder, average_filename);
        fprintf(' -> 正在读取文件: %s\n', average_filename);

        [~, ~, avg_raw_data] = xlsread(average_filepath, char(current_nation));
        if isempty(avg_raw_data)
            warning(' -> 在文件 "%s" 的工作表 "%s" 中未找到数据，已跳过。', average_filename, current_nation);
        else
            num_avg_cols_to_take = min(7, size(avg_raw_data, 2));
            avg_data_to_combine = avg_raw_data(:, 1:num_avg_cols_to_take);
            combined_sheet_data = [combined_sheet_data, avg_data_to_combine];
        end

    catch ME
        warning(' -> 读取失败！无法从 "%s" 中读取工作表 "%s"。\n 错误信息: %s\n 已跳过此文件。', ...
            average_filename, current_nation, ME.message);
    end

    % --- 5. 添加新列 (h_ave-h_stranger, h_ave-h_acquaintance, h_ave-h_model) ---
    if ~isempty(combined_sheet_data)
        header = {'h_ave-h_stranger', 'h_ave-h_acquaintance', 'h_ave-h_model'};
        new_columns = [];

        for row = 2:size(combined_sheet_data, 1)
            h_ave = combined_sheet_data{row, 20};  % 第20列
            h_stranger = combined_sheet_data{row, 5}; % 第5列
            h_acquaintance = combined_sheet_data{row, 10}; % 第10列
            h_model = combined_sheet_data{row, 15}; % 第15列

            % 计算差值
            diff_stranger = h_ave - h_stranger;
            diff_acquaintance = h_ave - h_acquaintance;
            diff_model = h_ave - h_model;

            % 添加到新列
            new_columns = [new_columns; {diff_stranger, diff_acquaintance, diff_model}];
        end

        % 合并标题和数据
        combined_sheet_data = [combined_sheet_data, [header; new_columns]];
    end

    % --- 6. 写入拼接好的数据 ---
    if ~isempty(combined_sheet_data)
        fprintf(' => 正在将合并后的数据写入到输出文件...\n');
        try
            xlswrite(output_filename, combined_sheet_data, char(current_nation));
        catch ME
            fprintf(2, ' => 写入失败！无法将数据写入工作表 "%s"。\n 错误信息: %s\n', ...
                current_nation, ME.message);
        end
    else
        warning('没有为工作表 "%s" 成功合并任何数据，因此不会创建该工作表。', current_nation);
    end

    fprintf('\n');
end

fprintf('所有工作表处理完毕！合并后的文件已保存为: %s\n', output_filename);
