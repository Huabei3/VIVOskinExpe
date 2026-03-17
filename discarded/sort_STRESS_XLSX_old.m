clc;clear;close all;
%%
function generate_STRESS_summary(big_main_folder, obs_type)
    % 定义大主文件夹路径
    % 获取所有 main_folder
    main_folders = dir(fullfile(big_main_folder, 'summer', 'female*'));
    main_folders = [main_folders; dir(fullfile(big_main_folder, 'summer', 'male*'))]; % 匹配 summer 下的所有文件夹
    main_folders = main_folders([main_folders.isdir]); % 只保留文件夹
    main_folders = {main_folders.name}; % 获取文件夹名称
    main_folders = main_folders(~ismember(main_folders, {'.', '..'})); % 移除 . 和 ..

    % 初始化 Excel 文件
    output_file = fullfile(big_main_folder, strcat('STRESS_', obs_type, '.xlsx'));
    if exist(output_file, 'file')
        delete(output_file); % 如果文件已存在，删除并重新创建
    end

    % 遍历每个 main_folder
    all_results = cell(length(main_folders) + 1, 3); % 用于存储汇总结果
    all_results{1, 1} = 'Main Folder';
    all_results{1, 2} = 'Mean STRESS_inter';
    all_results{1, 3} = 'Mean STRESS_intra';

    for idx = 1:length(main_folders)
        main_folder = fullfile(big_main_folder, 'summer', main_folders{idx});
        results = process_main_folder(main_folder, obs_type); % 处理每个 main_folder

        % 获取最后一级文件夹名称并处理
        last_part = gen_lastPart_new(main_folders{idx});
        sheet_name = last_part; % 使用处理后的名称作为工作表名称

        % 保存到单独的工作表
        writecell(results, output_file, 'Sheet', sheet_name);

        % 计算平均值并存储到汇总表
        mean_inter = mean(cell2mat(results(2:end, 2)), 'omitnan');
        mean_intra = mean(cell2mat(results(2:end, 3)), 'omitnan');
        all_results{idx + 1, 1} = gen_lastPart_new( main_folders{idx});
        all_results{idx + 1, 2} = mean_inter;
        all_results{idx + 1, 3} = mean_intra;
    end

    % 保存汇总结果到总工作表
    writecell(all_results, output_file, 'Sheet', 'Summary');

    disp(['结果已保存到: ', output_file]);
end

function results = process_main_folder(main_folder, obs_type)
    % 获取所有以数字开头的子文件夹
    subfolders = dir(fullfile(main_folder, obs_type, '0*')); % 匹配所有文件夹
    subfolders = [subfolders;dir(fullfile(main_folder, obs_type, '1*'))]; % 匹配所有文件夹
    subfolders = subfolders([subfolders.isdir]); % 只保留文件夹
    subfolders = {subfolders.name};
    subfolders = subfolders(~ismember(subfolders, {'.', '..'})); % 移除 . 和 ..

    % 初始化结果存储
    results = cell(length(subfolders) + 1, 3); % 用于存储结果
    results{1, 1} = 'Folder';
    results{1, 2} = 'Mean_STRESS_inter';
    results{1, 3} = 'Mean_STRESS_intra';

    % 遍历每个子文件夹
    for i = 1:length(subfolders)
        folder_name = subfolders{i};
        folder_path = fullfile(main_folder, obs_type, folder_name);

        % 特殊处理：以 "10" 开头的文件夹只处理 "10ruddyadd"
        if startsWith(folder_name, '10') && ~strcmp(folder_name, '10ruddyadd')
            continue; % 跳过其他以 "10" 开头的文件夹
        end

        % 检查是否存在 STRESS.mat 文件
        stress_file = fullfile(folder_path, 'STRESS.mat');
        if exist(stress_file, 'file')
            % 加载 STRESS.mat 文件
            load(stress_file, 'STRESS_inter', 'STRESS_intra');

            % 计算 STRESS_inter 和 STRESS_intra 的第二列均值
            mean_inter = mean(cell2mat(STRESS_inter(:, 2)));
            mean_intra = mean(cell2mat(STRESS_intra(:, 2)));

            % 存储结果
            results{i + 1, 1} = gen_attribute_new(strrep(folder_name, "add", ""));
            results{i + 1, 2} = mean_inter;
            results{i + 1, 3} = mean_intra;
        else
            % 如果文件不存在，标记为 NaN
            results{i + 1, 1} = gen_attribute_new(strrep(folder_name, "add", ""));
            results{i + 1, 2} = NaN;
            results{i + 1, 3} = NaN;
        end

    end

    rows_to_keep = ~any(cellfun(@isempty, results), 2);    
    results = results(rows_to_keep, :);

    results{i + 1, 1} = "mean";
    results{i + 1, 2} = mean(cell2mat(results(2:i,2)));
    results{i + 1, 3} = mean(cell2mat(results(2:i,3)));
    % disp("d")
end

% 调用函数
big_main_folder = 'D:\work\VIVOskinExpe\analyze\AnalyseResults';
obs_types=["all","model_group","non_model"];
for i_obstype=1:length(obs_types)
    obs_type = obs_types(i_obstype);
    generate_STRESS_summary(big_main_folder, obs_type);
end
