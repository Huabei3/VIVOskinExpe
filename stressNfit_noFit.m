% rehash toolboxcache % 解决无法访问以前可以访问的文件，重新处理工具箱缓存
close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量
addpath("utils\")
%% 生成目录
% 
lastParts = {'f04i', 'f05i', 'f06i', 'm04i', 'm05i', 'm06i',...
'f01i', 'f02i', 'f03i', 'm01i', 'm02i', 'm03i',...
'f07i', 'f08i','m07i', 'm08i',...
'f09i', 'f10i','m09i', 'm10i'};

% lastParts = {'f04r', 'f05r', 'f06r', 'm04r', 'm05r', 'm06r',...
% 'f01r', 'f02r', 'f03r', 'm01r', 'm02r', 'm03r',...
% 'f07r', 'f08r','m07r', 'm08r',...
% 'f09r', 'f10r','m09r', 'm10r'};

% Dtype='noCAT';
Dtype='efit_p';
scale_type_origin="unscaled";
% for i_lastPart = [19]
for i_lastPart = 1:length(lastParts)
    lastPart = lastParts{i_lastPart};
    %--------non-model-group-------------
    source_folder = fullfile('D:\work\VIVOskinExpe\analyze\expRes\renamed', ...
        lastPart,'non_model'); 
    group_type=1;
    
    %--------model-group-------------
    % source_folder =  fullfile('D:\work\VIVOskinExpe\analyze\expRes\renamed', ...
    %     lastPart,'model_group');
    % group_type=2;
    %--------model-------------
    % source_folder =  fullfile('D:\work\VIVOskinExpe\analyze\expRes\renamed', ...
    %     lastPart,'model');    
    % group_type=3;
    % %--------model-------------
    % source_folder = 'D:\work\VIVOskinExpe\analyze\expRes\female41i\all'; 
    % group_type=4;
    %--------all_ruddy_normal-------------
    % source_folder = 'D:\work\VIVOskinExpe\analyze\expRes\female78i\all_ruddy_normal'; 
    % group_type=5;
    %------------------------
    
    

    
    source_folder1 = char(strrep(source_folder,"renamed\",""));
    slashes = strfind(source_folder1, '\');
    obs_type=source_folder1(slashes(end) + 1:end);
    model=lastPart(1:end-1);
    nations=["AS","CA","SA","AF"];
    if ismember(model,["f04", "f05", "f06","m04", "m05", "m06"])
        nation=nations(1);
    elseif ismember(model,["f01", "f02", "f03","m01", "m02", "m03"])
        nation=nations(2);
    elseif ismember(model,["f07", "f08","m07", "m08"])
        nation=nations(3);
    elseif ismember(model,["f09", "f10", "m09", "m10"])
        nation=nations(4);
    end

    if strcmp(nation,"AS")
        attributes = [1, 2, 3, 4, 5, 6, 7,8, 9,10];
    elseif strcmp(nation,"CA")
        attributes = [1, 3, 5, 6, 7,8, 9,10];
    else
        attributes = [1, 3, 5, 6,7, 8];
    end
    if ~strcmp(nation,"AS")&&strcmp(lastPart(1),'m')
        attributes(attributes==3)=[];
    end
    if strcmp(obs_type,"non_model")
        attributes(attributes==7)=[];
    end
    % attributes = [1];


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

        if isempty(dir_res)
            continue
        end
        
        if strcmp(Dtype,"efit_p")
            save_folder=fullfile('AnalyseResults_p',Dtype,scale_type_origin);
        elseif strcmp(Dtype,"efit_p_free")
            save_folder=fullfile('AnalyseResults_p_free',Dtype,scale_type_origin);
        end
    
        % 定义输出目录
        
        if group_type==1        
            output_folder = fullfile(save_folder, strrep(lastPart,"add",""), ...
            'non_model', attribute_serial);        
        elseif group_type==2
            output_folder = fullfile(save_folder, strrep(lastPart,"add",""), ...
            "model_group" ,attribute_serial);
        elseif group_type==3
            output_folder = fullfile(save_folder, strrep(lastPart,"add",""), ...
            "model" ,attribute_serial);
        elseif group_type==4
            output_folder = fullfile(save_folder, strrep(lastPart,"add",""), ...
            "all" ,attribute_serial);
        end
    
    
        if ~exist(output_folder, 'dir')
            mkdir(output_folder);
        end
    
        % 处理数据并保存
        process_data_CAT_p(dir_res, output_folder, strrep(lastPart,"add",""),Dtype,scale_type_origin);
        
    
        
  
    end
    currentTime = datetime('now');    
    time_diff = currentTime - startTime;
    fprintf('时间差: %s\n', time_diff);
    disp('All attributes and i_groups processed successfully.');
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




