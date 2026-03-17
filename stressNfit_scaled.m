% rehash toolboxcache % 解决无法访问以前可以访问的文件，重新处理工具箱缓存
close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量
addpath("utils\")
%% 生成目录
%1 2 4
%--------non-model-group-------------
source_folder = 'D:\work\VIVOskinExpe\analyze\expRes\renamed\f05i\non_model'; 
% source_folder = 'D:\work\VIVOskinExpe\analyze\expRes\f04r\renamed\non_model'; 
group_type=1;

%--------model-group-------------
% source_folder = 'D:\work\VIVOskinExpe\analyze\expRes\male59i\model_group'; 
% group_type=2;
%--------model-------------
% source_folder = 'D:\work\VIVOskinExpe\analyze\expRes\malevivoi\model'; 
% group_type=3;
% %--------model-------------
% source_folder = 'D:\work\VIVOskinExpe\analyze\expRes\female41i\all'; 
% group_type=4;
%--------all_ruddy_normal-------------
% source_folder = 'D:\work\VIVOskinExpe\analyze\expRes\female78i\all_ruddy_normal'; 
% group_type=5;
%------------------------


Dtype='noCAT';

source_folder1 = char(strrep(source_folder,"renamed\",""));
slashes = strfind(source_folder1, '\');
obs_type=source_folder1(slashes(end) + 1:end);
lastPart = source_folder1(slashes(end-1) + 1:slashes(end) - 1);
if group_type==1    
    % lastPart = source_folder(slashes(1, end) + 1:end);
    attributes = [1, 2, 3, 4, 5, 6, 8, 9,10];
elseif group_type==2||group_type==3
    attributes = [1, 2, 3, 4, 5, 6,7, 8, 9,10];
elseif group_type==4
    attributes = [1, 2, 3, 4, 5, 6,7, 8, 9,10];
elseif group_type==5
    attributes = [10];
end
attributes = [1, 2, 3, 4, 5, 6, 8, 9,10];
% attributes = [1, 3,  5, 6, 8, 9,10];


% 定义所有需要处理的 attribute
attribute_names_new = ["Preference", "Attractiveness", "Feminine", "Cooperative", ...
    "Youth", "Healthy", "Fidelity","Harmony", "Fair", "Ruddy"];

[lastPart1]= gen_lastPart1(lastPart);

average_file=fullfile("aveSkin",strrep(lastPart1,"add",""),"autoNhand_scaleoverLUT.mat");
average=load(average_file);
average=average.average_lab_all(:,1:3);

% 循环处理每个 attribute
startTime = datetime('now'); 
for attribute = attributes
    fprintf('Processing savesavttribute: %d\n', attribute);
    
    % 生成 attribute_serial
    attribute_serial = strcat(sprintf("%02d", attribute), attribute_names_new(attribute));
    
   
    % 获取所有格式为 obs%02d 的子文件夹

    dir_res = findSpecificFiles(source_folder, attribute);
    

    save_folder=fullfile('AnalyseResults2',Dtype);%AnalyseResults2:scaled

    % 定义输出目录
    
    if group_type==1        
        output_folder = fullfile(save_folder, lastPart, ...
            'non_model', attribute_serial);        
    elseif group_type==2
        output_folder = fullfile(save_folder, lastPart, ...
        "model_group" ,attribute_serial);
    elseif group_type==3
        output_folder = fullfile(save_folder, lastPart, ...
        "model" ,attribute_serial);
    elseif group_type==4
        output_folder = fullfile(save_folder, lastPart, ...
        "all" ,attribute_serial);
    end


    if ~exist(output_folder, 'dir')
        mkdir(output_folder);
    end

    % 处理数据并保存
    process_data_scaled(dir_res, output_folder, lastPart,Dtype);
    

    
    % 拟合椭圆
    outputFolder = fullfile(output_folder, 'ellipPara');
    if ~exist(outputFolder, 'dir')
        mkdir(outputFolder);
    end
    
    % 初始化存储拟合结果的变量
    par_all = [];
    r_all = [];
    parNr_all = [];
    
    % 循环处理每个 i_group

    
    delete_log_folder = fullfile(output_folder, 'delete_log');
    if ~exist(delete_log_folder, 'dir')
        mkdir(delete_log_folder);
    end

    if exist(fullfile(delete_log_folder, 'row_delete_data.mat'),'file')
        deleteData=load(fullfile(delete_log_folder, 'row_delete_data.mat'), 'row_delete_all');
    end
    if exist(fullfile(outputFolder, "fitRes.mat"),'file')
        parData=load(fullfile(outputFolder, "fitRes.mat"), ...
            'par_all', 'r_all', 'parNr_all','picname_check');
    end
    % groups_again=[1];
    groups_again=[1:21];
    mix_idx=[];
    ori_idx=[];
    if lastPart(end) == 'i' 
        picnames_groups = ["h3k","h4k","h5k","h6k","hd65","h7k","h8k", ...
                        "m3k","m4k","m5k","m6k","md65","m7k","m8k",...
                         "l3k","l4k","l5k","l6k","ld65","l7k","l8k"];
    elseif lastPart(end) == 'r'
        picnames_groups = ["rs01","rs02","rs03","rs04","rs05","rs06","rs07", ...
                     "rs08","rs09","rs10","rs11","rs12","rs13","rs14"];
    end
    for i_group = 1:length(picnames_groups)
        fprintf('Processing i_group: %d\n', i_group);

        % 加载数据
        dir_labNgroup = dir(fullfile(output_folder, 'labNscore', ...
            strcat('labNscore_group',strrep(lastPart,"add",""), picnames_groups(i_group),'*.mat')));
        if isempty(dir_labNgroup)
            continue
        end
        MSVNlab = load(fullfile(dir_labNgroup(1).folder, dir_labNgroup(1).name));
        picname_check{i_group,1}=strcat(lastPart, picnames_groups(i_group));
        lab_group_original = MSVNlab.lab_group; % 原始 lab_group
        MSV_group_original = MSVNlab.MSV_group; % 原始 MSV_group

        
        % 复制一份用于修改
        lab_group = lab_group_original;
        MSV_group = MSV_group_original;


        if ~ismember(i_group,groups_again)
            par=parData.par_all(i_group,:);
            r=parData.r_all(i_group,:);
            row_delete=deleteData.row_delete_all{i_group,1}{1,1};
            row_delete_lab_group=deleteData.row_delete_all{i_group,1}{1,2};
            MSV_group(row_delete,:)=[];
            lab_group(row_delete,:)=[];


        else

            % 初始化 row_delete 和对应的 lab_group 数据
            row_delete = [];
            row_delete_lab_group = [];
            
            while true
                % 拟合椭圆
                [par_mean, r_mean] = calculate_weighted_or_simple_mean(group_type, row_delete, MSV_group_original, lab_group_original);
                % 如果 group_type == 3 且 row_delete >= 5，则调用函数
                if group_type == 5||(length(row_delete) >= 5)
                % if (group_type == 3 && length(row_delete) >= 5)||(length(row_delete) >= 24)
                    par=par_mean;
                    r=r_mean;
                    if ~isempty(par) % 如果返回的 par 不为空，则退出循环
                        break;
                    end
                end
                mean_cen(1)=mean(lab_group(:,1));
                mean_cen(2:3)=par_mean(1,4:5);
                if attribute == 10 && ismember(i_group,[15])
                    [par, r, y] = my_ellipsoidfit3_special(lab_group, MSV_group,mean_cen,lastPart,i_group);
                else
                    [par, r, y] = my_ellipsoidfit3_dy(lab_group, MSV_group,mean_cen);
                end
                


                [A, B, ~] = calculate_ellipse_axes_from_par(par);
                if (4*par(1)*par(2)-par(3)^2)>0&&r>=0.75
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
                % figure(1);
                plot_contour_with_scatter(par, lab_group, MSV_group);
            end
        end
        % 存储 row_delete 和对应的 lab_group 数据
        row_delete_all{i_group,1} = {row_delete, row_delete_lab_group};
        
        % 存储拟合结果
        par_all = [par_all; par];
        r_all = [r_all; r];
        parNr_all = [parNr_all; [par, r]];
        
        % 绘制等高线图并保存
        pre_draw_folder = fullfile(output_folder, 'pre_draw');
        if ~exist(pre_draw_folder, 'dir')
            mkdir(pre_draw_folder);
        end
        figure(1);
        plot_contour_with_scatter(par, lab_group, MSV_group);
        title(strrep(dir_labNgroup(1).name,'labNscore_group',''));

        frame = getframe(gcf); % 获取当前 Figure 窗口的帧
        img = frame2im(frame); % 将帧转换为图像数据
        imwrite(img, fullfile(pre_draw_folder, ...
            strcat(strrep(dir_labNgroup(1).name,'labNscore_group',''), '.jpg')));
        close(gcf);
    end
    % 保存 row_delete 和 row_delete_lab_group 到 delete_log 文件夹
    if exist('row_delete_all','var')
        save(fullfile(delete_log_folder, 'row_delete_data.mat'), 'row_delete_all');
    end

    % 保存拟合结果
    save(fullfile(outputFolder, "fitRes.mat"), ...
        'par_all', 'r_all', 'parNr_all','picname_check');
    
    % 生成 list 并保存为表格文件
    generate_list(output_folder, par_all, r_all, average);

end
currentTime = datetime('now');    
time_diff = currentTime - startTime;
fprintf('时间差: %s\n', time_diff);
disp('All attributes and i_groups processed successfully.');

%% 辅助函数

function [lastPart1]= gen_lastPart1(lastPart)
    lastParts1=["femaleVIVO","maleVIVO"];
    lastParts=["femalevivo","malevivo"];
    lastPart1=lastPart;
    for i=length(lastParts)
        lastPart1=strrep(lastPart1,lastParts(i),lastParts1(i));
    end
end




function [par, r] = calculate_weighted_or_simple_mean(group_type, row_delete, MSV_group_original, lab_group_original)

        % 找到 MSV_group_original > 0.5 的行
        high_score_rows = MSV_group_original > 0.5;
        
        if any(high_score_rows)
            % 加权平均
            weights = MSV_group_original(high_score_rows);
            weighted_mean = sum(lab_group_original(high_score_rows, 2:3) .* weights, 1) / sum(weights);
            par(1, 4:5) = weighted_mean;
        else
            % 找到 MSV_group_original 的最大值
            max_score = max(unique(MSV_group_original));
            max_score_rows = MSV_group_original == max_score;
            
            % 简单平均
            simple_mean = mean(lab_group_original(max_score_rows, 2:3), 1);
            par(1, 4:5) = simple_mean;
        end
        
        % 其他参数设为 0
        par(1, 1:3) = 0;
        par(1, 6) = 0;
        r = 1; % 设置 r 为 1，表示强制满足条件

end
