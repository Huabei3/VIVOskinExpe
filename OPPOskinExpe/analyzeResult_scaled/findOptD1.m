clear;
addpath("utils\")
%%
%-------------
% 让所有拟合结果hue尽可能接近
%-------------
scene_name=["inLab","indoorAdd","nightAdd","outdoorAdd","sunsetAdd"];



ave_All=[];
for i_scene=1:length(scene_name)
    [picname_groups] = gen_picname_groups(scene_name(i_scene));
    save_folder = fullfile('AnalyseResults\noCAT', ...
        scene_name(i_scene),"labNscore");
    for i_pic = 1:length(picname_groups)
        load(fullfile(save_folder ,strcat("labNscore_groupAdd", ...
            picname_groups(i_pic),".mat")),"lab_group");
        ave_All=[ave_All;[lab_group(end,:),{picname_groups(i_pic)}]];
    end
    
end

save("documents\Averages","ave_All");
%%
load("OPPOskin\matchTable.mat","match_table");
load("documents\CATedPre.mat","XYZw_pre_all","picname");
XYZw_inLab=mean(XYZw_pre_all(1:14,:));
scene_name=["inLab","indoorAdd","nightAdd","outdoorAdd","sunsetAdd"];
par_All=[];picname_check_All=[];
for i_scene=1:length(scene_name)
    save_folder = fullfile('AnalyseResults\noCAT', ...
        scene_name(i_scene),"ellipPara_scaled");
    load(fullfile(save_folder ,"fitRes_level.mat"),"picname_check","par_ind");
    par_All=[par_All;par_ind];
    picname_check_All=[picname_check_All;picname_check(:,1)];
    
end

XYZw_pre_cell=num2cell(XYZw_pre_all);
XYZw_pre_cell = horzcat(XYZw_pre_cell, picname_check_All);


wd65=[94.811 100.00 107.304];
datai_file = '..\display_calibration\datai_sorted40_3.mat';
XYZw=load(datai_file);
XYZw=XYZw.XYZw;
XYZw_scaled=XYZw./XYZw(2).*wd65(2);
save_folder="Optimize_D";
if ~exist(save_folder,"dir")
    mkdir(save_folder);
end
check_folder=fullfile(save_folder,"check_pic");
if ~exist(check_folder,"dir")
    mkdir(check_folder);
end
% figure("Visible","off");

hold on;

for i_row=1:size(par_All,1)
    lab_row(i_row,:)=[ave_All{i_row,1}(1,1),par_All(i_row,4:5)];   
    XYZ_row(i_row,:)=lab2xyz2(lab_row(i_row,:),'user',XYZw_scaled);
    XYZw(i_row,:)=XYZw_pre_all(i_row,:);
    [CCT(i_row,1),duv(i_row,1),S_out{i_row,1}] = ...
        xyz2CCT(XYZw(i_row,:)./XYZw(i_row,2).*100,10);
    
    idx_inLab = find(strcmp(XYZw_pre_cell(:,4), match_table{i_row,3}));
    a_CL=[6.7421,-9.9816];
    C_pre=a_CL(1)*log(lab_row(idx_inLab,1))+a_CL(2);%亮度实验
    C_bf=sqrt(lab_row(i_row,2).^2+lab_row(i_row,3).^2);
    XYZ_bf(i_row,:)=XYZ_row(i_row,:);
    XYZwt=XYZw_pre_all(idx_inLab,:);
end
XYZwt=repmat(wd65,size(XYZw,1),1);
[a_optimal,D_optimal] = optimize_D(XYZ_bf, XYZw, XYZwt, CCT);





% figure;
scatter(CCT, D_optimal, 30, 'filled');
% D_CCT=[D_optimal,CCT];
% D_CCT_duv=[D_optimal,CCT,duv];
% idx_del=(D_CCT(:,1)>0.99|D_CCT(:,1)<0.01);
% D_CCT(idx_del,:)=[];
% D_CCT_duv(idx_del,:)=[];
% lab_bf_target=[lab_row,Labtarget,CCT];







%%
function [a_optimal,D_optimal] = optimize_D(XYZ, XYZw, XYZwt, CCT)
    % 定义目标函数，计算 deltaE2000
    % XYZ, XYZw, XYZwt 为 n*3 double，CCT 为 n*1 列向量
    % D 和 CCT 都为 n*1 列向量
    % 定义目标函数句柄
    objectiveFunction = @(a) cal_h_std(XYZ, XYZw, XYZwt, a(1) .* CCT + a(2));
    
    % 使用 fminsearch 搜索最优的 a(1) 和 a(2) 值
    % 初始猜测值
    a0 = [0.5, 0.5]; % 初始猜测值可以根据实际情况调整
    options = optimset('Display', 'iter', 'TolX', 1e-6, 'TolFun', 1e-6); % 设置优化参数[^3^]
    a_optimal = fminsearch(objectiveFunction, a0, options);
    
    % 计算最优的 D 值
    D_optimal = a_optimal(1) .* CCT + a_optimal(2);
    
    % 输出最优 D 值
    fprintf('Optimal D values:\n');
    disp(D_optimal);
end


function h_std = cal_h_std(XYZ, XYZw, XYZwt, D)
    % 调用 CAT16_D 函数计算 XYZt
    XYZt = zeros(size(XYZ)); % 初始化 XYZt
    for i_row = 1:size(XYZ, 1)
        XYZt(i_row, :) = CAT16_D(XYZ(i_row, :), XYZw(i_row, :), XYZwt(i_row, :), D(i_row));
    end
    
    % 将 XYZt 转换为 Lab
    wd65 = [94.811, 100.00, 107.304];
    datai_file = '..\display_calibration\datai_sorted40_3.mat';
    XYZw = load(datai_file);
    XYZw = XYZw.XYZw;
    XYZw_scaled = XYZw ./ XYZw(2) * wd65(2);
    [Labt] = xyz2lab(XYZt, 'user', XYZw_scaled);
    h_t = atan2d(Labt(:, 3), Labt(:, 2));
    
    % 计算 h_std
    h_std = std(h_t);
end


