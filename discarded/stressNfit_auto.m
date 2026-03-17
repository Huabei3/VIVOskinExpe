% rehash toolboxcache % 解决无法访问以前可以访问的文件，重新处理工具箱缓存
close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量

%% 生成目录
source_folder = 'D:\work\VIVOskinExpe\analyze\expRes\femalevivoi'; 
slashes = strfind(source_folder, '\');
lastPart = source_folder(slashes(1, end) + 1:end);
model = lastPart(1:end - 1);

% 定义所有需要处理的 attribute
attributes = [1, 2, 3, 4, 5, 6, 8, 9];
attribute_names = ["Preference", "Attractiveness", "Feminine", "Cooperative", ...
    "Youth", "Healthy", "suit the environment or not", "white-skinned", "ruddy"];

% 初始化存储 row_delete 的 cell
row_delete_all = cell(length(attributes), 33); % 33 是 i_group 的最大值

% 循环处理每个 attribute
for attribute = attributes
    fprintf('Processing attribute: %d\n', attribute);
    
    % 生成 attribute_serial
    attribute_serial = strcat(sprintf("%02d", attribute), attribute_names(attribute));
    
    % 获取所有格式为 obs%02d 的子文件夹
    subFolders = dir(fullfile(source_folder, 'obs*'));
    subFolders = subFolders([subFolders.isdir]); % 只保留文件夹
    
    % 初始化一个空的 dir 结构体数组
    dir_res = [];
    
    % 支持的文件格式
    supportedFormats = {'.csv', '.xls', '.xlsx'};
    
    % 遍历每个子文件夹
    for i_obs = 1:length(subFolders)
        % 获取当前子文件夹路径
        folderPath = fullfile(source_folder, subFolders(i_obs).name);
        
        % 遍历支持的文件格式
        for fmt = supportedFormats
            % 构建目标文件名
            targetFileName = sprintf('%s_%02d%s', subFolders(i_obs).name, attribute, fmt{1});
            targetFilePath = fullfile(folderPath, targetFileName);
            
            % 检查文件是否存在
            if exist(targetFilePath, 'file')
                % 获取文件的 dir 信息
                fileInfo = dir(targetFilePath);
                
                % 将 dir 信息添加到结构体数组中
                dir_res = [dir_res; fileInfo];
                break; % 如果找到文件，跳出格式循环
            end
        end
    end
    
    % 定义输出目录
    output_folder = fullfile('AlalyseResults', lastPart, attribute_serial);
    if ~exist(output_folder, 'dir')
        mkdir(output_folder);
    end
    
    % 处理数据并保存
    process_data(dir_res, output_folder, lastPart, attribute, attribute_names);
    
    % 拟合椭圆
    dir_labNgroup = dir(fullfile(output_folder, 'labNscore', '*.mat'));
    outputFolder = fullfile(output_folder, 'ellipPara');
    if ~exist(outputFolder, 'dir')
        mkdir(outputFolder);
    end
    
    % 初始化存储拟合结果的变量
    par_all = [];
    r_all = [];
    parNr_all = [];
    
    % 循环处理每个 i_group
    for i_group = 1:length(dir_labNgroup)
        fprintf('Processing i_group: %d\n', i_group);
        
        % 加载数据
        MSVNlab = load(fullfile(dir_labNgroup(i_group).folder, dir_labNgroup(i_group).name));
        lab_group_original = MSVNlab.lab_group; % 原始 lab_group
        MSV_group_original = MSVNlab.MSV_group; % 原始 MSV_group
        
        % 复制一份用于修改
        lab_group = lab_group_original;
        MSV_group = MSV_group_original;
        
        % 初始化 row_delete 和对应的 lab_group 数据
        row_delete = [];
        row_delete_lab_group = [];
        
        while true
            % 拟合椭圆
            [par, r, y] = my_ellipsoidfit3(lab_group, MSV_group);
            
            % 如果 r >= 0.85，退出循环
            if r >= 0.85
                break;
            end
            
            % 找到最大误差的索引
            [~, max_ind] = max(abs(y - MSV_group));
            
            % 记录原始 lab_group 中的索引
            original_index = find(ismember(lab_group_original, lab_group(max_ind, :), 'rows'));
            
            % 将原始索引加入 row_delete
            row_delete = [row_delete; original_index];
            
            % 将对应的 lab_group 数据加入 row_delete_lab_group
            row_delete_lab_group = [row_delete_lab_group; lab_group_original(original_index, :)];
            
            % 删除异常数据点
            lab_group(max_ind, :) = [];
            MSV_group(max_ind, :) = [];
        end
        
        % 存储 row_delete 和对应的 lab_group 数据
        row_delete_all{attribute, i_group} = {row_delete, row_delete_lab_group};
        
        % 存储拟合结果
        par_all = [par_all; par];
        r_all = [r_all; r];
        parNr_all = [parNr_all; [par, r]];
    end
    
    % 保存拟合结果
    save(fullfile(outputFolder, "fitRes_level.mat"), 'par_all', 'r_all', 'parNr_all');
end

% 保存 row_delete_all 到 mat 文件
save(fullfile('AlalyseResults', lastPart, 'row_delete_all.mat'), 'row_delete_all');

disp('All attributes and i_groups processed successfully.');

%% 辅助函数
function process_data(dir_res, output_folder, lastPart, attribute, attribute_names)
    % 处理数据并保存
    resfile = fullfile(dir_res(1).folder, dir_res(1).name);
    result = readtable(resfile);
    result_cell = table2cell(result);
    indices = result_cell(:, 1);
    indices = cell2mat(indices);
    n_lab = max(indices) + 1;
    n_file = length(dir_res);

    score_all = zeros(n_lab, n_file);
    num_lab_all = zeros(n_lab, n_file);
    STRESS_intra = [];
    repeat_score_all = [];

    for i_file = 1:length(dir_res)
        resfile = fullfile(dir_res(i_file).folder, dir_res(i_file).name);
        result = readtable(resfile);
        result_cell = table2cell(result);
        scores = cell2mat(result_cell(:, 3));
        scores = mapMatrixValues(scores);
        for k = 1:length(scores)
            result_cell{k, 3} = scores(k);
        end
        result_cell = sortrows(result_cell, 1);
        repeat_score = [];
        picname_lab = [];
        score_lab = zeros(max(cell2mat(result_cell(:, 1))) + 1, 1);
        num_lab = zeros(max(cell2mat(result_cell(:, 1))) + 1, 1);
        for i_lab = 0:max(cell2mat(result_cell(:, 1)))
            num_scores = find(cell2mat(result_cell(:, 1)) == i_lab);
            score_lab(i_lab + 1) = mean(cell2mat(result_cell(num_scores, 3)));
            picname_lab = [picname_lab; result_cell(num_scores(1), 2)];
            num_lab(i_lab + 1) = length(num_scores);
            if num_lab(i_lab + 1) > 1
                repeat_score_temp = [i_lab, cell2mat(result_cell(num_scores(1), 3)), cell2mat(result_cell(num_scores(2), 3))];
                repeat_score = [repeat_score; repeat_score_temp];
            end
        end
        repeat_score(:, 2:3) = (repeat_score(:, 2:3) - 1) / 5;
        repeat_score_mean = (repeat_score(:, 2) + repeat_score(:, 3)) ./ 2;
        repeat_score_all = [repeat_score_all; {repeat_score}];
        STRESS_intra = [STRESS_intra; {dir_res(i_file).name, STRESS(repeat_score(:, 2), repeat_score_mean)}];
        score_all(:, i_file) = score_lab;
        num_lab_all(:, i_file) = num_lab;
    end

    STRESS_intra_mean = mean(cell2mat(STRESS_intra(:, 2)));
    score_all_scaled = (score_all - 1) / 5;
    score_all_mean = mean(score_all_scaled, 2);
    STRESS_inter = [];
    for i_file = 1:n_file
        STRESS_inter = [STRESS_inter; {dir_res(i_file).name, STRESS(score_all_scaled(:, i_file), score_all_mean)}];
    end

    save(fullfile(output_folder, 'STRESS.mat'), 'STRESS_inter', 'STRESS_intra');

    % 计算 z_score
    score_all = round(score_all);
    for i_pic = 1:size(score_all, 1)
        for i_grade = 1:6
            count(i_pic, i_grade) = sum(score_all(i_pic, :) == i_grade);
        end
    end
    for i_grade = 1:6
        cumu(:, i_grade) = sum(count(:, 1:i_grade), 2);
    end
    LG = log((cumu + 0.5) ./ (size(score_all, 2) - cumu + 0.5));
    z_score = LG * 0.6422 + 0.0003;
    for i_grade = 1:5
        diff(:, i_grade) = z_score(:, i_grade + 1) - z_score(:, i_grade);
    end
    mean_diff = mean(diff, 1);
    boundary(1, 1) = 0;
    for i_grade = 2:6
        boundary(1, i_grade) = boundary(1, i_grade - 1) + mean_diff(1, i_grade - 1);
    end
    scaledValue = repmat(boundary, size(z_score, 1), 1) - z_score;
    meanScaledValue = mean(scaledValue(:, 1:5), 2);
    MSV_scaled = (meanScaledValue - min(meanScaledValue)) ./ (max(meanScaledValue) - min(meanScaledValue));

    % 处理并保存每个 group 的 z-score 和 lab
    load(fullfile('dlabsNpicname', strcat(lastPart, ".mat")));
    picname_check = [];
    for i_group = 1:33:length(score_all)
        picname_group = picname_lab{i_group}(1:end - 3);
        picname_check{floor((i_group - 1) / 33) + 1, 1} = picname_lab{i_group}(1:end - 3);
        lab_group = [];
        for i_pic = 1:length(dlabsNpicname)
            if strcmp(dlabsNpicname{i_pic, 2}(1:end - 3), picname_group)
                lab_group = [lab_group; dlabsNpicname{i_pic, 1}];
            end
        end
        MSV_group = MSV_scaled(i_group:i_group + 32, :);
        outputFolder = fullfile(output_folder, 'labNscore');
        if ~exist(outputFolder, 'dir')
            mkdir(outputFolder);
        end
        save(fullfile(outputFolder, strcat("labNscore_group", picname_group, ".mat")), ...
            'lab_group', 'MSV_group','picname_check');
    end
end

function degree = atan2d_360(y, x)
    degree = atan2d(y, x);
    if degree < 0
        degree = degree + 360;
    end
end



function mappedMatrix = mapMatrixValues(matrix)
    mappedMatrix = matrix;
    [rows, cols] = size(matrix);
    for i = 1:rows
        for j = 1:cols
            if matrix(i, j) == -3
                mappedMatrix(i, j) = 1;
            elseif matrix(i, j) == -2
                mappedMatrix(i, j) = 2;
            elseif matrix(i, j) == -1
                mappedMatrix(i, j) = 3;
            elseif matrix(i, j) == 1
                mappedMatrix(i, j) = 4;
            elseif matrix(i, j) == 2
                mappedMatrix(i, j) = 5;
            elseif matrix(i, j) == 3
                mappedMatrix(i, j) = 6;
            end
        end
    end
end

function [lab_group, MSV_group] = delete_bad(lab_group, MSV_group, lastPart, i_group, attribute)
    delete_ind = [];
    if strcmp(lastPart, "femalevivoi")
        if attribute == 1
            if i_group == 1
                delete_ind = 24;
            elseif i_group == 15
                delete_ind = 22;
            end
        elseif attribute == 2
            if i_group == 1
                delete_ind = 29;
            elseif i_group == 15
                delete_ind = [17, 9];
            end
        elseif attribute == 3
            if i_group == 15
                delete_ind = 24;
            end
        end
    end
    lab_group(delete_ind, :) = [];
    MSV_group(delete_ind, :) = [];
end