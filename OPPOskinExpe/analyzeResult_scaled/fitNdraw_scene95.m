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
lab_all_scene=[];
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
    lab_group=fit_data.par_ind(:,5:7);    
    
    slashes = strfind(source_folder, '\');
    
    wd65=[94.811 100.00 107.304];
    lab_PMCC=[62.11,18.96,19.76];
    
    %%
    if strcmp(lastPart,"indoorAdd")
        lab_group(5,:)=[];
        ori_labs(5,:)=[];
        picname_check(5,:)=[];
    elseif strcmp(lastPart,"sunsetAdd")
        lab_group([1,2,3,8],:)=[];
        ori_labs([1,2,3,8],:)=[];
        picname_check([1,2,3,8],:)=[];
    end
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
    
    [center,mu,chi2_val,List,cov_mat,cov_mat_r] =fit95ellip_my(lab_group, 0.05, 3);
    %------保存参数------
    sori_labs_folder=fullfile(sourceFolder,Dtype,'scene','95');
    output_folder=fullfile(sori_labs_folder,'ellipPara');
    if ~exist(output_folder, 'dir')
        mkdir(output_folder);
    end
    save(fullfile(output_folder, strcat(lastPart,"fitRes_level.mat")), ...
        'center', 'mu','List');
    
    %--------画椭圆------------
    output_folder=fullfile(sori_labs_folder,'ellipsoid_sections');
    if ~exist(output_folder, 'dir')
        mkdir(output_folder);
    end
    labCh_ori=mean(ori_labs,1);

    % fitRes50_folder=fullfile(strrep(sori_labs_folder,"scene\95",lastPart),"ellipPara_scaled");
    % fitRes50_file=fullfile(fitRes50_folder,"fitRes_level.mat");
    % fitRes50_data=load(fitRes50_file);
    % contour50ellip(fitRes50_data.par, colors(i_lastPart,:));

    contour95ellip(center,mu,lab_group,chi2_val, ...
        output_folder,lastPart,colors(i_lastPart,:),"scene",labCh_ori); 

    

    labCh_center=center;
    labCh_center(4)=sqrt(labCh_center(:,2).^2+labCh_center(:,3).^2);
    labCh_center(5)=atan2d(labCh_center(:,3),labCh_center(:,2));
    labCh_ori(4)=sqrt(labCh_ori(:,2).^2+labCh_ori(:,3).^2);
    labCh_ori(5)=atan2d(labCh_ori(:,3),labCh_ori(:,2));
    dE_fr_ori{i_lastPart,1}=labCh_center(1);
    dE_fr_ori{i_lastPart,2}=labCh_center(4);
    dE_fr_ori{i_lastPart,3}=labCh_center(5);
    dE_fr_ori{i_lastPart,4}=labCh_center(1)-labCh_ori(1);
    dE_fr_ori{i_lastPart,5}=labCh_center(4)-labCh_ori(4);
    dE_fr_ori{i_lastPart,6}=labCh_center(5)-labCh_ori(5);
    dE_fr_ori{i_lastPart,7}=CCT_mean;
    dE_fr_ori{i_lastPart,8}=xyz_ratio_mean;


    %------计算色差-----------
    for i_para=1:size(lab_group,1)
        for j_para=1:size(lab_group,1)
            dE_mat(i_para,j_para)=...
                deltaE2000(lab_group(i_para,:),lab_group(j_para,:));
        end
    end
    dE_intra{i_lastPart,1}=dE_mat;
    dE_mat(dE_mat == 0) = NaN;
    dE_intra_mean(i_lastPart,1)=nanmean(nanmean(dE_mat));

    center_labels(i_lastPart,:)=center;
end
concatenate_images1(output_folder,2);
for i_label=1:length(lastParts)
    for j_label=1:length(lastParts)
        dE_inter95(i_label,j_label)=...
            deltaE2000(center_labels(i_label,:),center_labels(j_label,:));
    end
end
dE_inter95(dE_inter95 == 0) = NaN;
dE_inter95_mean=nanmean(nanmean(dE_inter95));
% for i_label=1:length(lastParts)
%     for j_label=1:length(lastParts)
%         dE_inter50(i_label,j_label)=...
%             deltaE2000(lab_50cen(i_label,:),lab_50cen(j_label,:));
%     end
% end
% dE_inter50(dE_inter50 == 0) = NaN;
% dE_inter50_mean=nanmean(nanmean(dE_inter50));

dE{1,1}="dE_inter95";dE{1,2}="dE_intra";
dE{2,1}=dE_inter95_mean;dE{2,2}=mean(dE_intra_mean);
save(fullfile(output_folder, strcat("dE.mat")), ...
    'dE_intra', 'dE_intra_mean',"dE_inter95", ...
    "center_labels","dE_inter95_mean");
% dE{1,1}="dE_inter50";dE{1,2}="dE_inter95";dE{1,3}="dE_intra";
% dE{2,1}=dE_inter50_mean;dE{2,2}=dE_inter95_mean;dE{2,3}=mean(dE_intra_mean);
% sori_labs(fullfile(output_folder, strcat("dE.mat")), ...
%     'dE_intra', 'dE_intra_mean',"dE_inter50","dE_inter95", ...
%     'lab_50cen',"center_labels","dE_inter50_mean","dE_inter95_mean");
%%



%%

% % 将数据按维度展开
% lab_all_scene(:,4) = sqrt(lab_all_scene(:,2).^2 + lab_all_scene(:,3).^2); % 计算模
% lab_all_scene(:,5) = atan2d(lab_all_scene(:,3), lab_all_scene(:,2)); % 计算角度
% 
% % 提取每个维度的数据
% dim1 = lab_all_scene(:,1); % 第一维度
% dim2 = lab_all_scene(:,2); % 第二维度
% dim3 = lab_all_scene(:,3); % 第三维度
% dim4 = lab_all_scene(:,4); % 第四维度（模）
% dim5 = lab_all_scene(:,5); % 第五维度（角度）
% 
% % 创建分组变量
% groups = [repmat({'Group1'}, size(lab_group_inds{1}, 1), 1); ...
%           repmat({'Group2'}, size(lab_group_inds{2}, 1), 1); ...
%           repmat({'Group3'}, size(lab_group_inds{3}, 1), 1); ...
%           repmat({'Group4'}, size(lab_group_inds{4}, 1), 1); ...
%           repmat({'Group5'}, size(lab_group_inds{5}, 1), 1)];
% 
% % 对每个维度进行 Kruskal-Wallis 检验
% [p(1), tbl1, stats1] = kruskalwallis(dim1, groups);
% [p(2), tbl2, stats2] = kruskalwallis(dim2, groups);
% [p(3), tbl3, stats3] = kruskalwallis(dim3, groups);
% [p(4), tbl4, stats4] = kruskalwallis(dim4, groups); % 第四维度
% [p(5), tbl5, stats5] = kruskalwallis(dim5, groups); % 第五维度
% 
% 
% 
% %%
% 
% % 创建设计矩阵
% lab_all_scene=[];
% for i_lastPart=1:length(lastParts)
%     lab_all_scene=[lab_all_scene;lab_group_inds{i_lastPart}];
% end
% group = [repmat(1, size(lab_group_inds{1}, 1), 1); ...
%          repmat(2, size(lab_group_inds{2}, 1), 1); ...
%          repmat(3, size(lab_group_inds{3}, 1), 1);
%          repmat(4, size(lab_group_inds{4}, 1), 1);
%          repmat(5, size(lab_group_inds{5}, 1), 1)];
% % 将所有数据合并为一个矩阵
% data = lab_all_scene;
% 
% % 执行 MANOVA
% [p, tbl, stats] = manova1(data, group);
% 
% % 输出结果
% disp(tbl);
% % p 值：如果 Wilks' Lambda 的 p 值小于显著性水平（通常为 0.05），
% % 则可以认为不同组之间存在显著差异，即数据与组别相关。