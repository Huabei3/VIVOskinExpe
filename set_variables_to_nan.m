clc;       % 清空命令窗口
clear;     % 清除工作区所有变量
addpath '..'

%% 设置参数
echo on;
% 用户可修改的参数
lastPart = 'f08i';  % 替换为需要处理的lastPart
attribute = 1;      % 替换为需要处理的attribute
attribute_names_new = ["Preference", "Attractiveness", "Feminine", "Cooperative", ...
    "Youth", "Healthy", "Fidelity","Harmony", "Fair", "Ruddy"];
i_para = 15;         % 替换为需要处理的i_para

if lastPart(end) == 'i' ||contains(lastPart,"add")
    picnames_groups = ["h3k","h4k","h5k","h6k","hd65","h7k","h8k", ...
                    "m3k","m4k","m5k","m6k","md65","m7k","m8k",...
                     "l3k","l4k","l5k","l6k","ld65","l7k","l8k"];
elseif lastPart(end) == 'r'
    picnames_groups = ["rs01","rs02","rs03","rs04","rs05","rs06","rs07", ...
                 "rs08","rs09","rs10","rs11","rs12","rs13","rs14"];
end
%% 构建路径和文件名
attribute_serial = strcat(sprintf("%02d", attribute), attribute_names_new(attribute));

% 定义基础路径
base_path = 'D:\\work\\VIVOskinExpe\\analyze\\AnalyseResults_p_free\\efit_p_free\\unscaled';

% 构建labNscore文件路径
if i_para >= 1 && i_para <= length(picnames_groups)
    picname_group = picnames_groups{i_para};
else
    error('i_para超出有效范围，请输入1-%d之间的数值', length(picnames_groups));
end

labNscore_file = fullfile(base_path, lastPart, 'non_model', attribute_serial, 'labNscore', ...
    ['labNscore_group' lastPart picname_group '.mat']);

% 构建ellipPara文件路径
ellipPara_file = fullfile(base_path, lastPart, 'non_model', attribute_serial, 'ellipPara', 'fitRes.mat');

%% 处理labNscore文件
if exist(labNscore_file, 'file')
    fprintf('处理labNscore文件: %s\n', labNscore_file);
    
    % 创建discarded文件夹并备份文件
    [labNscore_dir, labNscore_filename] = fileparts(labNscore_file);
    discarded_dir = fullfile(labNscore_dir, 'discarded');
    if ~exist(discarded_dir, 'dir')
        mkdir(discarded_dir);
        fprintf('已创建discarded文件夹: %s\n', discarded_dir);
    end
    
    % 备份文件
    backup_file = fullfile(discarded_dir, strcat(labNscore_filename , '.mat'));
    copyfile(labNscore_file, backup_file);
    fprintf('已备份labNscore文件到: %s\n', backup_file);
    
    % 加载文件
    load(labNscore_file);
    
    % 检查变量是否存在并设置为NaN
    lab_group(:) = NaN;
    fprintf('已将lab_group设置为NaN\n');

    
    lab_bfCAT(:) = NaN;
    fprintf('已将lab_bfCAT设置为NaN\n');

    
    p_group(:) = NaN;
    fprintf('已将p_group设置为NaN\n');

    
    % 保存修改后的文件
    save(labNscore_file, "lab_group","lab_bfCAT","p_group","picname_check");
    fprintf('已保存修改后的labNscore文件\n\n');
else
    fprintf('警告: labNscore文件不存在: %s\n\n', labNscore_file);
end

%% 处理ellipPara文件
if exist(ellipPara_file, 'file')
    fprintf('处理ellipPara文件: %s\n', ellipPara_file);
    
    % 创建discarded文件夹并备份文件
    [ellipPara_dir, ellipPara_filename] = fileparts(ellipPara_file);
    discarded_dir = fullfile(ellipPara_dir, 'discarded');
    if ~exist(discarded_dir, 'dir')
        mkdir(discarded_dir);
        fprintf('已创建discarded文件夹: %s\n', discarded_dir);
    end
    
    % 备份文件
    backup_file = fullfile(discarded_dir, strcat(ellipPara_filename ,'.mat'));
    copyfile(ellipPara_file, backup_file);
    fprintf('已备份ellipPara文件到: %s\n', backup_file);
    
    % 加载文件
    load(ellipPara_file);
    
    % 检查变量是否存在并设置第i_para行为NaN
    if exist('par_all', 'var') && ismatrix(par_all) && size(par_all, 1) >= i_para
        par_all(i_para, :) = NaN;
        fprintf('已将par_all第%d行设置为NaN\n', i_para);
        
        % 保存修改后的文件
        save(ellipPara_file, 'par_all');
        fprintf('已保存修改后的ellipPara文件\n');
    else
        if ~exist('par_all', 'var')
            fprintf('警告: par_all变量不存在于文件中\n');
        else
            fprintf('警告: par_all的行数不足%d行\n', i_para);
        end
    end
else
    fprintf('警告: ellipPara文件不存在: %s\n', ellipPara_file);
end

%% 显示pre_draw文件夹下的图像
pre_draw_file = fullfile(base_path, lastPart, 'non_model', attribute_serial, 'pre_draw', ...
    [lastPart picname_group '.mat.jpg']);

if exist(pre_draw_file, 'file')
    fprintf('\n显示图像: %s\n', pre_draw_file);
    img = imread(pre_draw_file);
    figure;
    imshow(img);
    title(['图像: ' lastPart picname_group '.mat.jpg']);
else
    fprintf('\n警告: pre_draw文件不存在: %s\n', pre_draw_file);
end
echo off;

fprintf('\n处理完成！\n');