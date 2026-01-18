close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量

%%
load("OPPOskin\matchTable_map.mat", ...
    "CCT_map","XYZ_gray_map","match_serial_map","match_table_map");
lastParts=["inLab","indoorAdd","nightAdd","outdoorAdd","sunsetAdd"];
Dtype="OPPO_CAT16";adjust_factor=1;
colors=hsv(length(lastParts));
for i_lastPart=1:length(lastParts)
    lastPart=lastParts(i_lastPart);
    source_folder=fullfile('AnalyseResults',"noCAT",lastPart,'ellipPara_scaled');
    source_file=fullfile(source_folder,"fitRes_level.mat");
    fit_data=load(source_file);
    %提取ave %这里要小心顺序，没有check机制改一改就可能出错
    n_render=49;
    rows_used=49:n_render:size(fit_data.lab_group_all,1);
    ori_labs=fit_data.lab_group_all(rows_used,:);%这里的ori_labs已经经历过CAT了
    picname_check=fit_data.picname_check(:,1);
    for i_nog=1:size(picname_check,1)
        XYZw_pre(i_nog,:)=XYZ_gray_map(strrep(picname_check{i_nog,1},"zrecen",""));
        CCT(i_nog,1)=CCT_map(strrep(picname_check{i_nog,1},"zrecen",""));
    end
    
    lab_group=fit_data.par_ind(:,5:7);    
    
    
    slashes = strfind(source_folder, '\');
    
    wd65=[94.811 100.00 107.304];
    lab_PMCC=[62.11,18.96,19.76];
    
    
    %%
    if strcmp(lastPart,"indoorAdd")
        lab_group(5,:)=[];
        ori_labs(5,:)=[];
        XYZw_pre(5,:)=[];
        CCT(5,:)=[];
    elseif strcmp(lastPart,"sunsetAdd")
        lab_group([1,2,3,8],:)=[];
        ori_labs([1,2,3,8],:)=[];
        XYZw_pre([1,2,3,8],:)=[];
        CCT([1,2,3,8],:)=[];
    end
    lab_50cen(i_lastPart,:)=fit_data.par(:,5:7);
    %% lcat

    wd65=[94.811 100.00 107.304];
    xyz_group=lab2xyz2(lab_group,"d65_64");
    for i_nog=1:size(lab_group,1)   
        [CCT(i_nog,1),duv(i_nog,1),S_out{i_nog,1}] = xyz2CCT(XYZw_pre(i_nog,:),10);
        D3(i_nog,1) = calculateD_adj(CCT(i_nog,1),duv(i_nog,1), Dtype,adjust_factor);
        XYZ_aft(i_nog,:) = CAT16_D(xyz_group(i_nog,:), ...
            XYZw_pre(i_nog,:), ...
            wd65, D3(i_nog,1));     
    end
    lab_group = xyz2lab(XYZ_aft,'d65_64');
        

    %%
    % 拟合椭球并保存结果
    
    [center,mu,chi2_val,List,cov_mat,cov_mat_r] =fit95ellip_my(lab_group, 0.05, 3);
    %------保存参数------
    save_folder=fullfile('AnalyseResults',Dtype,'adj_D');
    output_folder=fullfile(save_folder,'ellipPara');
    if ~exist(output_folder, 'dir')
        mkdir(output_folder);
    end
    save(fullfile(output_folder, strcat(lastPart,"fitRes_level.mat")), ...
        'center', 'mu','List');
    
    %--------画椭圆------------
    output_folder=fullfile(save_folder,'ellipsoid_sections');
    if ~exist(output_folder, 'dir')
        mkdir(output_folder);
    end

    contour95ellip(center,mu,lab_group,chi2_val, ...
        output_folder,num2str(adjust_factor),colors(i_lastPart,:),"adj_D",mean(ori_labs,1)); 

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
concatenate_images(output_folder,3);
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
% save(fullfile(output_folder, strcat("dE.mat")), ...
%     'dE_intra', 'dE_intra_mean',"dE_inter50","dE_inter95", ...
%     'lab_50cen',"center_labels","dE_inter50_mean","dE_inter95_mean");
%%



