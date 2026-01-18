close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量
%%
load("neutral24\white.mat","CCT","XYZ_gray");
load("OPPOskin\matchTable_map.mat");
load("neutral24\global_ratio.mat");
XYZ_gray_scene{1}=XYZ_gray(1:14,:);
XYZ_gray_scene{2}=XYZ_gray(15:24,:);
XYZ_gray_scene{3}=XYZ_gray(25:34,:);
XYZ_gray_scene{4}=XYZ_gray(35:44,:);
XYZ_gray_scene{5}=XYZ_gray(44:52,:);
XYZ_gray_scene{2}(5,:)=[];
XYZ_gray_scene{5}([1,2,3,8],:)=[];
for i_lastPart=1:5
    CCTpre{i_lastPart,1}=xyz2CCT(XYZ_gray_scene{i_lastPart},10);
    CCTpre{i_lastPart,1}=CCTpre{i_lastPart,1}';
    CCT_mean(i_lastPart,1)=mean(CCTpre{i_lastPart,1},1);
end
%%
lastParts=["inLab","indoorAdd","nightAdd","outdoorAdd","sunsetAdd"];
% Dtype="OPPO_CAT16";
Dtype = "efit_p";
lightness_type="rela";
rgb2xyz_type="display";
if strcmp(Dtype,"efit_p")
    sourceFolder=fullfile('AnalyseResults_p',rgb2xyz_type,lightness_type);
else
    sourceFolder='AnalyseResults';
end
%%
H = linspace(0, 1, length(lastParts) + 1); % 加1是为了避免最后一个值为1（和0重复）
H = H(1:end-1); % 去掉最后一个值
S = 0.9 * ones(1, length(lastParts));
V = 0.7 * ones(1, length(lastParts));
colors = hsv2rgb([H; S; V]');
%%
output_folder=fullfile(sourceFolder,Dtype,"scene","ellipsoid_sections");
if ~exist(output_folder,"dir")
    mkdir(output_folder);
end

lab_all_scene=[];
for i_lastPart=1:length(lastParts)
    lastPart=lastParts(i_lastPart);
    source_folder=fullfile(sourceFolder,Dtype,"scene",lastPart,'ellipPara_scaled');
    fitRes50_file=fullfile(source_folder,"fitRes_level.mat");
    fitRes50_data=load(fitRes50_file);

    labNscore_folder=fullfile(sourceFolder,Dtype, "scene",lastPart,'labNscore');
    labNscore_data=load(fullfile(labNscore_folder, ...
        strcat("labNscore_groupAdd_scene.mat")));
        %提取ori_labs %这里要小心顺序，没有check机制改一改就可能出错
    n_render=49;
    rows_used=49:n_render:size(labNscore_data.lab_group,1);
    ori_labs=labNscore_data.lab_group(rows_used,:);%这里的ori_labs已经经历过CAT了
    picname_check=fitRes50_data.picname_check(:,1);
    %这里lab_group,picname_check已经删除不要的场景

    labCh_ori=mean(ori_labs,1);
    
    contour50ellip(fitRes50_data.par, colors(i_lastPart,:), ...
        output_folder,"scene", labCh_ori);

end
concatenate_images1(output_folder,2);

