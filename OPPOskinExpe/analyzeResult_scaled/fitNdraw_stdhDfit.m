close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量

%%
load("OPPOskin\matchTable_map.mat", ...
    "CCT_map","XYZ_gray_map","match_serial_map","match_table_map");
lastParts=["inLab","indoorAdd","nightAdd","outdoorAdd","sunsetAdd"];
Dtype="zhai_adjusted";
colors=hsv(length(lastParts));
lab_group_all=[];picname_check_all=[];
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
    lab_group_all=[lab_group_all;lab_group];
    picname_check_all=[picname_check_all;picname_check];
    lab_50cen(i_lastPart,:)=fit_data.par(:,5:7);

        

end
save("Optimize_D\optimize_data.mat","lab_group_all","picname_check_all");



%% lcat
% load("Optimize_D\optimize_data.mat","lab_group_all","picname_check_all");
% wd65=[94.811 100.00 107.304];
% xyz_group=lab2xyz2(lab_group_all,"d65_64");
% for i_nog=1:size(lab_group_all,1)  
%     XYZw_pre(i_nog,:)=XYZ_gray_map(strrep(picname_check_all{i_nog,1},"zrecen",""));
%     [CCT(i_nog,1),duv(i_nog,1),S_out{i_nog,1}] = xyz2CCT(XYZw_pre(i_nog,:),10);
% end
% 
% adjust_factor=0.2;
% for i_nog=1:size(lab_group_all,1)   
% 
%     D3(i_nog,1) = calculateD_adj(CCT(i_nog,1),duv(i_nog,1), Dtype,adjust_factor);
%     XYZ_aft(i_nog,:) = CAT16_D(xyz_group(i_nog,:), ...
%         XYZw_pre(i_nog,:), ...
%         wd65, D3(i_nog,1));     
% end
% lab_aft_all = xyz2lab(XYZ_aft,'d65_64');
% h_all=lab_aft_all(:,3)./lab_aft_all(:,2);
% h_std=std(h_all);
%%
% mean(CCT(1:14,:)),mean(CCT(15:23,:))
% mean(CCT(24:34,:)),mean(CCT(34:44,:))
% mean(CCT(44:47,:))
%%
load("Optimize_D\optimize_data.mat","lab_group_all","picname_check_all");
wd65=[94.811 100.00 107.304];
xyz_group=lab2xyz2(lab_group_all,"d65_64");
for i_nog=1:size(lab_group_all,1)  
    XYZw_pre(i_nog,:)=XYZ_gray_map(strrep(picname_check_all{i_nog,1},"zrecen",""));
    [CCT(i_nog,1),duv(i_nog,1),S_out{i_nog,1}] = xyz2CCT(XYZw_pre(i_nog,:),10);
end

% 初始化变量
adj_values = linspace(0, 2, 100); % D从0到1，分成100个点
h_std_values = zeros(size(adj_values)); % 用于存储每个D对应的h_std

for i_D = 1:length(adj_values)
    adj = adj_values(i_D);
    for i_nog=1:size(lab_group_all,1)   
        D3(i_nog,1) = calculateD_adj(CCT(i_nog,1),duv(i_nog,1), Dtype, adj);
        XYZ_aft(i_nog,:) = CAT16_D(xyz_group(i_nog,:), ...
            XYZw_pre(i_nog,:), ...
            wd65, D3(i_nog,1));     
    end
    lab_aft_all = xyz2lab(XYZ_aft,'d65_64');
    h_all=atan2d(lab_aft_all(:,3),lab_aft_all(:,2));
    h_std_values(i_D) = std(h_all); % 计算当前D的h_std
end
plot(adj_values,h_std_values);
% 找到h_std最小值对应的D
[~, opt_adj_index] = min(h_std_values);
opt_adj = adj_values(opt_adj_index);

fprintf('最优D值为: %f\n', opt_adj);