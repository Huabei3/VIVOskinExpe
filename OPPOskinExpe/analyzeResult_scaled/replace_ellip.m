close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量


%%
load("documents\CATedPre.mat","picname");
load("neutral24\white.mat","CCT","XYZ_gray");
load("OPPOskin\matchTable.mat");
lastParts=["inLab","indoorAdd","nightAdd","outdoorAdd","sunsetAdd"];
load('documents\group_Lab.mat','cellMatrix');
wd65=[94.811 100.00 107.304];   
XYZw_pre_all=XYZ_gray./XYZ_gray(:,2).*100;
Dtype="OPPO_CAT16";
rpl_folder=fullfile('AnalyseResults',Dtype,"recen",'ellipPara_scaled');
rpl_file=fullfile(rpl_folder,"fitRes_level.mat");
rpl_data=load(rpl_file);
for i_lastPart=1:length(lastParts)
    clear("picname_check1")
    lastPart=lastParts(i_lastPart);
    source_folder=fullfile('AnalyseResults',Dtype,lastPart,'ellipPara_scaled');
    source_file=fullfile(source_folder,"fitRes_level.mat");
    load(source_file,"MSV_group_all","XYZ_bf","lab_group_all", ...
        "list_table","par","parNr","par_ind","r","r_ind","y","y_ind", ...
        "picname_check");
    for i_pic=1:size(picname_check,1)
        picname_check1{i_pic,1}=picname_check{i_pic,1};
        for i_match =1:size(rpl_data.picname_check,1)
            if strcmp(strcat("zrecen",picname_check{i_pic,1}), ...
                    rpl_data.picname_check{i_match,1})
                par_ind(i_pic,:)=rpl_data.par_ind(i_match,:);
                r_ind(i_pic,:)=rpl_data.r_ind(i_match,:);
                picname_check1{i_pic,1}=rpl_data.picname_check{i_match,1};
            end
        end
    end
    save(source_file,"MSV_group_all","XYZ_bf","lab_group_all", ...
    "list_table","par","parNr","par_ind","r","r_ind","y","y_ind", ...
    "picname_check","picname_check1");    
    

end