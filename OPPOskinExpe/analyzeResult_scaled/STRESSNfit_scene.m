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
output_folder=fullfile(sourceFolder,Dtype);
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end
%%
H = linspace(0, 1, length(lastParts) + 1); % 加1是为了避免最后一个值为1（和0重复）
H = H(1:end-1); % 去掉最后一个值
S = 0.9 * ones(1, length(lastParts));
V = 0.7 * ones(1, length(lastParts));
colors = hsv2rgb([H; S; V]');
%%
lab_all_scene=[];
par_all=[];r_all=[];parNr_all=[];

for i_lastPart=1:length(lastParts)
    lastPart=lastParts(i_lastPart);
    source_folder=fullfile(sourceFolder,Dtype,lastPart,'ellipPara_scaled');
    source_file=fullfile(source_folder,"fitRes_level.mat");
    fit_data=load(source_file);
    %提取ori_labs %这里要小心顺序，没有check机制改一改就可能出错
    n_render=49;
    rows_used=49:n_render:size(fit_data.lab_group_all,1);
    ori_labs=fit_data.lab_group_all(rows_used,:);%这里的ori_labs已经经历过CAT了
    picname_check=fit_data.picname_check(:,1);
    lab_group=fit_data.lab_group_all;    
    p_group=fit_data.p_group_all;    
    
    slashes = strfind(source_folder, '\');
    
    wd65=[94.811 100.00 107.304];
    lab_PMCC=[62.11,18.96,19.76];
    
    %%
    del_ids=[];
    if strcmp(lastPart,"indoorAdd")
        del_ids=[5];
        ori_labs(5,:)=[];
        picname_check(5,:)=[];
    elseif strcmp(lastPart,"sunsetAdd")
        del_ids=[1,2,3,8];
        ori_labs([1,2,3,8],:)=[];
        picname_check([1,2,3,8],:)=[];
    end
    labCh_ori=mean(ori_labs,1);
    del_rows=[];
    for i_del_id=del_ids
        del_rows=[del_rows;(i_del_id-1)*49+1:i_del_id*49];
    end
    lab_group(del_rows,:)=[];
    p_group(del_rows,:)=[];

    lab_group_inds{i_lastPart}=lab_group;
    lab_all_scene=[lab_all_scene;lab_group];
    lab_50cen(i_lastPart,:)=fit_data.par(:,5:7);
    CCT_scene=[];xyz_ratio_scene=[];
    for i_pic=1:length(picname_check)
        CCT_scene=[CCT_scene;CCT_map(picname_check{i_pic,1})];
        xyz_ratio_scene=[xyz_ratio_scene;xyz_ratio_map(picname_check{i_pic,1})];
    end
    CCT_mean=mean(CCT_scene);xyz_ratio_mean=mean(xyz_ratio_scene(:,2));
    %%
    % 拟合椭球并保存结果
    
    outputFolder=fullfile(output_folder, "scene",lastPart,'labNscore');
    if ~exist(outputFolder, 'dir')
        mkdir(outputFolder);
    end
    save(fullfile(outputFolder, strcat("labNscore_groupAdd_scene.mat")), ...
        'lab_group', 'p_group','picname_check',"ori_labs","labCh_ori");


    %拟合
    [cen,~] = calculate_weighted_or_simple_mean(p_group, lab_group);
    [par, r, y]=my_ellipsoidfit_fixed(lab_group, p_group,cen);

    %保存参数
    outputFolder=fullfile(output_folder, "scene",lastPart,'ellipPara_scaled');
    if ~exist(outputFolder, 'dir')
        mkdir(outputFolder);
    end
    save(fullfile(outputFolder, "fitRes_level.mat"),...
        "par","r",'picname_check',"ori_labs","labCh_ori");

    %画图
    pic_folder = fullfile(output_folder, "scene",'ellipsoid_sections');
    if ~exist(pic_folder, 'dir')
        mkdir(pic_folder);
    end
    contour50ellip(par, colors(i_lastPart,:), ...
    pic_folder,"scene", labCh_ori);
    % plot_contour_with_scatter(par, lab_group, p_group);
    % exportgraphics(gcf, fullfile(pic_folder,strcat(lastPart, '.jpg')),'Resolution',150);


    par_all = [par_all; par];
    r_all = [r_all; r];
    parNr_all = [parNr_all; [par, r]];        
end
concatenate_images1(pic_folder,2);
outputFolder=fullfile(output_folder, "scene",'ellipPara_scaled');
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end
save(fullfile(outputFolder, "fitRes_level.mat"),...
    "par_all","r_all","lastParts");