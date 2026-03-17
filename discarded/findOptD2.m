close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量
addpath("utils\")
%% 定义所有需要处理的 attribute
attributes = [1, 2, 3, 4, 5, 6,7, 8, 9,10];
attribute_names = ["Preference", "Attractiveness", "Feminine", "Cooperative", ...
    "Youth", "Healthy", "Precise reproduction",...
    "suit the environment or not", "white-skinned", "ruddyadd"];
attribute_names_new = ["Preference", "Attractiveness", "Feminine", "Cooperative", ...
    "Youth", "Healthy", "Fidelity","Harmony", "Fair", "Ruddy"];



picname_group=["h3k","h4k","h5k","h6k","hd65","h7k","h8k",...
        "m3k","m4k","m5k","m6k","md65","m7k","m8k",...
        "l3k","l4k","l5k","l6k","ld65","l7k","l8k"];
%%
nations=["AS","CA","SA","AF"];

% lastParts = {'f04i', 'f05i', 'f06i', ...
% 'm04i', 'm05i', 'm06i'};nation=nations(1);

% lastParts = {'f01i', 'f02i', 'f03i', ...
% 'm01i', 'm02i', 'm03i'};nation=nations(2);

% lastParts = {'f07i', 'f08i', ...
% 'm07i', 'm08i'};nation=nations(3);
% 
% lastParts = {'f09i', 'f10i', ...
% 'm09i', 'm10i'};nation=nations(4);

lastParts = {'f04i', 'f05i', 'f06i', 'm04i', 'm05i', 'm06i',...
'f01i', 'f02i', 'f03i', 'm01i', 'm02i', 'm03i',...
'f07i', 'f08i','m07i', 'm08i',...
'f09i', 'f10i','m09i', 'm10i'};nation="all";
%--------------------------------
% lastParts = {'f04r', 'f05r', 'f06r', ...
% 'm04r', 'm05r', 'm06r'};nation=nations(1);

% lastParts = {'f04r', 'f05r', 'f06r', ...
% 'm04r', 'm05r', 'm06r'};nation=nations(1);

% lastParts = {'f04r', 'f05r', 'f06r', ...
% 'm04r', 'm05r', 'm06r'};nation=nations(1);
%%


obs_types=["non_model","model_group","model"];
obs_types_new=["stranger","acquaintance","self","all"];

wd65 = [94.811, 100.00, 107.304];

% load("optimizedD\light_i.mat","CCT_light","XYZ_light","ct");
% CT=CCT_light;
load("optimizedD\neutral_gray\i\gray_patch4\XYZw_all.mat", ...
    "CCTest_mean","XYZw_mean");
CT=CCTest_mean;




% save(fullfile(save_folder,"Asian_i.mat"),"CT_inds","XYZwpre_inds");
lab_PMCC = [62.11, 18.96, 19.76];
labC_PMCC = [lab_PMCC, sqrt(lab_PMCC(1, 2)^2 + lab_PMCC(1, 3)^2)];

Dtype='noCAT';
for i_obstype=1:1
    save_folder = fullfile("optmizedD","zhai_adjusted");
    % 创建保存文件夹
    if ~exist(save_folder, "dir")
        mkdir(save_folder);
    end
    
    % 定义色环上的 7 种颜色
    colors = hsv(7); % 使用 hsv 色图生成 7 种颜色
    
    for lastPart_idx = 1:length(lastParts)
        lastPart = lastParts{lastPart_idx};
        model = lastPart(1:end-1);
        
        [lastPart1, model1] = gen_lastPart1(lastPart);
        lastPart_new=gen_lastPart_new(lastPart1);
        disp([lastPart,lastPart_new])
        average_file = fullfile("aveSkin", strrep(lastPart_new,"add",""), "autoNhand_scaleoverLUT.mat");
        average_data = load(average_file);
        average_inds(:,:,lastPart_idx) = average_data.average_lab_all(:, 1:3);

        for attribute = [1]
            fprintf('Processing attribute: %d\n', attribute);
            
            % 生成 attribute_serial
            attribute_serial = strcat(sprintf("%02d", attribute), attribute_names_new(attribute));
        
            source_file_used = fullfile('AnalyseResults1', Dtype, lastPart, ...
                obs_types(i_obstype), attribute_serial, ...
                'ellipPara', 'fitRes.mat'); % 新增 source_file_used
            
            % 加载数据
            par_all4=[];
            if exist(source_file_used, 'file') % 新增 source_file_used 的加载
                load(source_file_used);
                par_all4 = par_all;
            else
                par_all4(1:21,1:6)=NaN;
            end
            par_inds(:,:,lastPart_idx,attribute)=par_all4;
        end
    end
    average=nanmean(average_inds,3);
    par_all4=nanmean(par_inds,3);
    %% 循环处理每个 attribute
    % % for attribute = [10]
    %a-b
    lim_min_x=min(min(min(par_all4(1:7,4,:,:))));
    lim_max_x=max(max(max(par_all4(1:7,4,:,:))));
    lim_min_y=min(min(min(par_all4(1:7,5,:,:))));
    lim_max_y=max(max(max(par_all4(1:7,5,:,:))));
    for attribute = [1]
            par = par_all4(:, :,1,attribute);
            lab_fit=[average(:,1),par(:,4),par(:,5)];
            lab_D65=lab_fit(5,:);
            XYZ_bf=lab2xyz2(lab_fit,'d65_64');
            XYZw=XYZ_light./XYZ_light(:,2).*100;
            XYZwt=repmat(wd65,size(XYZw,1),1);
            a_opt=fit_D_by_h(XYZ_bf, XYZw, XYZwt, CT);     
    end
    
end
%%

D_pre = (CT <= a_opt(1)) .* (a_opt(3) + a_opt(4)*(CT - a_opt(1))) + ...
    (CT > a_opt(1) & CT <= a_opt(2)) .* (a_opt(3) + a_opt(5)*(CT - a_opt(1))) + ...
    (CT > a_opt(2)) .* ((a_opt(3) + a_opt(5)*(a_opt(2) - a_opt(1))) + a_opt(6)*(CT - a_opt(2)));
figure()
D_CCT=[D_pre,CT];
scatter(D_CCT(:,2),D_CCT(:,1),30, 'filled');
save_folder="optmizedD\zhai_adjusted";
if ~exist(save_folder,"dir")
    mkdir(save_folder);
end
save("optmizedD\zhai_adjusted\D_zhai_adjusted.mat","a_opt");
exportgraphics(gcf,fullfile(save_folder,strcat(strcat(nation,'D_zhai_adjusted.jpg'))), ...
    "Resolution",150);
%% 拟合

% 计算XYZt
for i_row=1:size(XYZ_bf,1)
    XYZt(i_row,:) = CAT16_D(XYZ_bf(i_row,:), XYZw(i_row,:), XYZwt(i_row,:), D_pre(i_row,:));
end

% 转换为Lab空间
Labt = xyz2lab(XYZt, 'd65_64');
% 创建散点图
figure;hold on;
scatter(Labt(1:7,2), Labt(1:7,3),'o','filled');
scatter(Labt(8:14,2), Labt(8:14,3),'d','filled');
scatter(Labt(15:21,2), Labt(15:21,3),'^','filled');


% 设置相等的坐标轴比例
axis equal;

% 获取当前坐标轴范围
ax_limits = axis;
min_limit = min(ax_limits(1:2));
max_limit = max(ax_limits(3:4));
full_range = [min_limit, max_limit];

% 设置相等的刻度范围
xlim(full_range);
ylim(full_range);

% 添加45度参考线
plot(full_range, full_range, 'r--', 'LineWidth', 1.5);

% 设置图表标题和轴标签
title('a* vs b* 散点图');
xlabel('a*');
ylabel('b*');
grid on;
%%
function a_opt=fit_D_by_h(XYZ, XYZw, XYZwt, CCT)
    % 假设已有数据：XYZ, XYZw, XYZwt, CCT
    % 初始参数估计
    a0=[5769.31948248233	6000.01046360996	0.710373884951729	-3.74809458460063e-05	-0.000975692292996272	0.000158186564369972];
    
    % 定义优化问题
    options = optimset('Display', 'iter', 'MaxIter', 5000, 'MaxFunEvals', 10000);
    a_opt = fminsearch(@(a) objective_function(a, XYZ, XYZw, XYZwt, CCT), a0, options);

    
end


% 目标函数：计算ht的方差
function variance = objective_function(a, XYZ, XYZw, XYZwt, CCT)
    % 确保a(1) < a(2)
    if a(1) >= a(2)
        variance = inf;
        return;
    end
    
    % 计算D
    D = (CCT <= a(1)) .* (a(3) + a(4)*(CCT - a(1))) + ...
        (CCT > a(1) & CCT <= a(2)) .* (a(3) + a(5)*(CCT - a(1))) + ...
        (CCT > a(2)) .* ((a(3) + a(5)*(a(2) - a(1))) + a(6)*(CCT - a(2)));
    
    % 计算XYZt
    for i_row=1:size(XYZ,1)
        XYZt(i_row,:) = CAT16_D(XYZ(i_row,:), XYZw(i_row,:), XYZwt(i_row,:), D(i_row,:));
    end
    
    % 转换为Lab空间
    Labt = xyz2lab(XYZt, 'd65_64');
    
    % 计算色调角
    ht = atan2d(Labt(:,3), Labt(:,2));
    
    % 计算方差
    variance = var(ht);
end