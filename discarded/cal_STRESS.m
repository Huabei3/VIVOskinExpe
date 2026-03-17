% rehash toolboxcache % 解决无法访问以前可以访问的文件，重新处理工具箱缓存
close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量
addpath("utils\")
%% 生成目录
attribute_names = ["Preference", "Attractiveness", "Feminine", "Cooperative", ...
    "Youth", "Healthy","Precise reproduction", ...
    "suit the environment or not", "white-skinned", "ruddy"];
attribute_names_new = ["Preference", "Attractiveness", "Feminine", "Cooperative", ...
    "Youth", "Healthy", "Fidelity","Harmony", "Fair", "Ruddy"];
attribute_serial=["01", "02", "03", "04", ...
    "05", "06", "07","08", "09", "10"];
source_folder = 'D:\work\VIVOskinExpe\analyze\expRes\f07i\model_group'; 
slashes=find(source_folder=='\');
last_folder=source_folder(slashes(end)+1:end);
last_folder1=fullfile("stress_mat",last_folder);
output_folder=strrep(source_folder,last_folder,last_folder1);


% 获取所有子文件夹
subfolders = dir(fullfile(source_folder, '*'));
subfolders = subfolders([subfolders.isdir]); % 只保留文件夹
subfolders = {subfolders.name}'; % 提取文件夹名称
subfolders(strcmp(subfolders(:,1) , '.')) = [];
subfolders(strcmp(subfolders(:,1) , '..')) = [];
subfolders(strcmp(subfolders(:,1) , 'stress_mat')) = [];
subfolders(strcmp(subfolders(:,1) , 'stress_csv')) = [];
subfolders(strcmp(subfolders(:,1) , 'discarded')) = [];
% 初始化一个 cell 数组来存储每个属性对应的文件路径
attribute_dirs = cell(length(attribute_names), 1);
for k = 1:length(attribute_names)
    % 遍历每个子文件夹
    for i = 1:length(subfolders)
        subfolder_path = fullfile(source_folder, subfolders{i});
        % 获取子文件夹中的所有文件
        files = dir(fullfile(subfolder_path, '*.*'));
        files = {files.name}'; % 提取文件名
        files(strcmp(files(:,1) , '.')) = [];
        files(strcmp(files(:,1) , '..')) = [];
     
        % 遍历每个文件
        for j = 1:length(files)
            file_name = files{j};
            % 遍历每个属性
            
            % 检查文件名是否包含某个属性
            if contains(file_name, attribute_names{k}) || contains(file_name, attribute_names_new{k})|| contains(file_name, attribute_serial{k})
                % 如果包含，则将文件路径添加到对应的属性目录中
                if isempty(attribute_dirs{k})
                    % 创建一个结构体数组，包含 folder 和 name 字段
                    attribute_dirs{k} = struct('folder', {subfolder_path}, 'name', {file_name});
                else
                    % 将新的文件路径添加到结构体数组中
                    attribute_dirs{k}(end+1).folder = subfolder_path;
                    attribute_dirs{k}(end).name = file_name;
                end
            end
        end
    end
end
for i_attr=1:size(attribute_dirs,1)
    output_folder_attr=fullfile(output_folder,attribute_names_new(i_attr));
    if ~exist(output_folder_attr,"dir")
        mkdir(output_folder_attr);
    end
    if ~isempty(attribute_dirs{i_attr,1})
        process_data_stress(attribute_dirs{i_attr,1}, output_folder_attr);
    end
end


