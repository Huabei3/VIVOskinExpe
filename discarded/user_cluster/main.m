% rehash toolboxcache % 解决无法访问以前可以访问的文件，重新处理工具箱缓存
close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量
addpath("utils\")
addpath("..\utils\")
addpath("..\")
%% 生成目录
% 
lastParts = {'f04i', 'f05i', 'f06i', 'm04i', 'm05i', 'm06i',...
'f01i', 'f02i', 'f03i', 'm01i', 'm02i', 'm03i',...
'f07i', 'f08i','m07i', 'm08i',...
'f09i', 'f10i','m09i', 'm10i'};iOr='i';n_para=21;

% lastParts = {'f04r', 'f05r', 'f06r', 'm04r', 'm05r', 'm06r',...
% 'f01r', 'f02r', 'f03r', 'm01r', 'm02r', 'm03r',...
% 'f07r', 'f08r','m07r', 'm08r',...
% 'f09r', 'f10r','m09r', 'm10r'};iOr='r';n_para=14;

if strcmp(iOr ,'i' )
    picnames_groups = ["h3k","h4k","h5k","h6k","hd65","h7k","h8k", ...
                    "m3k","m4k","m5k","m6k","md65","m7k","m8k",...
                     "l3k","l4k","l5k","l6k","ld65","l7k","l8k"];
elseif strcmp(iOr,'r') 
    picnames_groups = ["rs01","rs02","rs03","rs04","rs05","rs06","rs07", ...
                 "rs08","rs09","rs10","rs11","rs12","rs13","rs14"];
end
% Dtype='noCAT';
Dtype='efit_p';
folder='D:\work\VIVOskinExpe\analyze\expRes\renamed';
scale_type_origin="unscaled";
% for i_lastPart = [19]
for i_lastPart = 7:length(lastParts)
% for i_lastPart = 1:length(lastParts)
    lastPart = lastParts{i_lastPart};
    model=lastPart(1:end-1);
    %--------non-model-group-------------

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
    attributes(attributes==7)=[];



    % 定义所有需要处理的 attribute
    attribute_names_new = ["Preference", "Attractiveness", "Feminine", "Cooperative", ...
        "Youth", "Healthy", "Fidelity","Harmony", "Fair", "Ruddy"];
    
    [lastPart1]= gen_lastPart1(lastPart);
    
    average_file=fullfile("..\aveSkin",strrep(lastPart1,"add",""),"autoNhand_scaleoverLUT.mat");
    average=load(average_file);
    average=average.average_lab_all(:,1:3);
    
    % 循环处理每个 attribute
    startTime = datetime('now'); 
    for attribute = attributes


        fprintf('Processing savesavttribute: %d\n', attribute);
        
        % 生成 attribute_serial
        attribute_serial = strcat(sprintf("%02d", attribute), attribute_names_new(attribute));
        
       
        % 获取所有格式为 obs%02d 的子文件夹
        source_folder = fullfile(folder,lastPart,'non_model'); 
        dir_res = findSpecificFiles(source_folder, attribute);
        source_folder = fullfile(folder,lastPart,'model_group'); 
        dir_res = [dir_res;findSpecificFiles(source_folder, attribute)];

        if isempty(dir_res)
            continue
        end
        
    
        save_folder=fullfile('AnalyseResults_p',Dtype,scale_type_origin);
    
        % 定义输出目录
        
        output_folder = fullfile(save_folder, strrep(lastPart,"add",""), attribute_serial);        

    
        if ~exist(output_folder, 'dir')
            mkdir(output_folder);
        end
    
        % 处理数据并保存
        [score_all,centers_all]=process_data_CAT_cluster(dir_res, output_folder, strrep(lastPart,"add",""),Dtype,scale_type_origin);
        
        % res = cluster_user_pointclouds(centers_all, ...
        %     'distance_method','Wasserstein', ...
        %     'clust_method','kmedoids', ...
        %     'K',3, 'verbose', true);
        res = cluster_user_pointclouds(centers_all, ...
        'distance_method','Wasserstein', ...
        'clust_method','spectral', ...
        'K',3, 'verbose', true);
        disp(res.sil_mean);
        

    
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




