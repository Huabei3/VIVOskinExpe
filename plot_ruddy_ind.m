% rehash toolboxcache % 解决无法访问以前可以访问的文件，重新处理工具箱缓存
close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量

%% 生成目录
%1 2 4
%--------non-model-group-------------
source_folder = 'D:\work\VIVOskinExpe\analyze\expRes\pre\non_model'; 
group_type=1;

%--------model-group-------------
% source_folder = 'D:\work\VIVOskinExpe\analyze\expRes\femalevivoi\model_group'; 
% group_type=2;
%--------model-------------
% source_folder = 'D:\work\VIVOskinExpe\analyze\expRes\femalevivoi\model'; 
% group_type=3;
% %--------model-------------
% source_folder = 'D:\work\VIVOskinExpe\analyze\expRes\femalevivoi\all'; 
% group_type=4;
%--------all_ruddy_normal-------------
% source_folder = 'D:\work\VIVOskinExpe\analyze\expRes\female78i\all_ruddy_normal'; 
% group_type=5;
%------------------------
ifCAT=1;Dtype='summer';if_mix=0;

slashes = strfind(source_folder, '\');
obs_type=source_folder(slashes(end) + 1:end);
lastPart = source_folder(slashes(end-1) + 1:slashes(end) - 1);
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
attributes = [1,  3,  5, 6, 8, 9,10];
% attributes = attributes(1:end-1);
figure
% 定义所有需要处理的 attribute

attribute_names = ["Preference", "Attractiveness", "Feminine", "Cooperative", ...
    "Youth", "Healthy","Precise reproduction", "suit the environment or not", "white-skinned", "ruddy"];

[lastPart1]= gen_lastPart1(lastPart);
if strcmp(lastPart,"pre")
    lastPart1="f01i";
end
average_file=strcat("..\renderCode\aveSkinByHand2\",lastPart1,"\autoNhand_scaleoverLUT.mat");
average=load(average_file);
average=average.average_lab_all(:,1:3);

% 循环处理每个 attribute
startTime = datetime('now'); 
for attribute = attributes
    
    fprintf('Processing savesavttribute: %d\n', attribute);
    
    % 生成 attribute_serial
    attribute_serial = strcat(sprintf("%02d", attribute), attribute_names(attribute));
    
    Asian_lastPart = [ "female78i", "female41i", "femaleVIVOi", ...
        "male59i", "male39i", "maleVIVOi"];
    
    if ismember(lastPart1,Asian_lastPart)
        if attribute==10
            data_type="Asian_ruddy";  
            
        else
            data_type="Asian";
        end
    else
        data_type="not_Asian";
    end
    % data_type="Asian";
    % 获取所有格式为 obs%02d 的子文件夹
    if strcmp(data_type,"Asian_ruddy")
        lastPart_new=gen_lastPart_new(lastPart);
        source_folder1=fullfile("expRes",strcat(lastPart_new,"add"),obs_type);
        dir_res = findSpecificFiles(source_folder1, attribute);
        if strcmp(data_type,"Asian_ruddy")&&if_mix
            dir_res0 = findSpecificFiles(source_folder, attribute);
        end
    else
        dir_res = findSpecificFiles(source_folder, attribute);
    end
    

    if ifCAT==0
        save_folder='AnalyseResults';
    elseif ifCAT==1
        save_folder=fullfile('AnalyseResults',Dtype);
    end
    % 定义输出目录
    if group_type==1
        output_folder = fullfile(save_folder, 'ind_plot',lastPart,'non_model', ...
            attribute_serial);
    elseif group_type==2
        output_folder = fullfile(save_folder, 'ind_plot',lastPart, ...
        "model_group" ,attribute_serial);
    elseif group_type==3
        output_folder = fullfile(save_folder,'ind_plot', lastPart, ...
        "model" ,attribute_serial);
    elseif group_type==4
        output_folder = fullfile(save_folder, 'ind_plot',lastPart, ...
        "all" ,attribute_serial);
    elseif group_type==5
        output_folder = fullfile(save_folder, 'ind_plot',lastPart, ...
        "all_ruddy_normal",attribute_serial);
    end
    if strcmp(data_type,"Asian_ruddy")
        if if_mix==1
            output_folder=strcat(output_folder,"add_mixed");
        else
            output_folder=strcat(output_folder,"add");
        end
    end


    if ~exist(output_folder, 'dir')
        mkdir(output_folder);
    end
    for i_obs=1:length(dir_res)
        slash=find(dir_res(i_obs).name=='_');
        obs=dir_res(i_obs).name(1:slash-1);
        [lab_group_sing,MSV_group,picname_check]=process_data_ind(dir_res(i_obs), lastPart,Dtype,data_type);

        for i_group = 1:length(lab_group_sing)
          
            figure(1); 
            scatter(lab_group_sing{i_group,1}(:, 2), ...
                lab_group_sing{i_group,1}(:, 3), ...
                40, MSV_group{i_group,1}, 'filled');
            hold on;  
    
            lim_max = max(max(lab_group_sing{i_group,1}(:, 2)), max(lab_group_sing{i_group,1}(:, 3))) + 10;
            lim_min = min(min(lab_group_sing{i_group,1}(:, 2)), min(lab_group_sing{i_group,1}(:, 3))) - 10;
            line([0, 0], [lim_min, lim_max], 'Color', 'k', 'LineStyle', '--'); % x=0
            line([lim_min, lim_max], [0, 0], 'Color', 'k', 'LineStyle', '--'); % y=0
            refline(1, 0); % 45 度线    
            % 设置图形属性
            axis equal;
            xlim([lim_min, lim_max]);
            ylim([lim_min, lim_max]);
            xlabel('{\ita*}');
            ylabel('{\itb*}');
            title(picname_check{i_group, 1});
            if ~exist(fullfile(output_folder, obs),"dir")
                mkdir(fullfile(output_folder, obs));
            end
            exportgraphics(gcf, fullfile(output_folder, obs,...
                strcat(lastPart,picname_check{i_group, 1}, '.jpg')),'Resolution',150);
            clf;
        end


    end
end


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
