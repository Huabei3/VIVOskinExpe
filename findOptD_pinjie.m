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


obs_types=["non_model","model_group","model","all"];
obs_types_new=["stranger","acquaintance","self","all"];

wd65 = [94.811, 100.00, 107.304];

load("optmizedD\light_i.mat","CCT_light","XYZ_light","ct");
CT=CCT_light;




% save(fullfile(save_folder,"Asian_i.mat"),"CT_inds","XYZwpre_inds");
lab_PMCC = [62.11, 18.96, 19.76];
labC_PMCC = [lab_PMCC, sqrt(lab_PMCC(1, 2)^2 + lab_PMCC(1, 3)^2)];

Dtype='noCAT';
for i_obstype=1:1
    save_folder = fullfile("optmizedD","pinjie","3spl");
    % 创建保存文件夹
    if ~exist(save_folder, "dir")
        mkdir(save_folder);
    end
    
    % 定义色环上的 7 种颜色
    colors = hsv(7); % 使用 hsv 色图生成 7 种颜色
    
    for i_lastPart = 1:length(lastParts)
        lastPart = lastParts{i_lastPart};
        model = lastPart(1:end-1);
        
        [lastPart1, model1] = gen_lastPart1(lastPart);
        lastPart_new=gen_lastPart_new(lastPart1);
        disp([lastPart,lastPart_new])
        average_file = fullfile("aveSkin", strrep(lastPart_new,"add",""), "autoNhand_scaleoverLUT.mat");
        average_data = load(average_file);
        average_inds(:,:,i_lastPart) = average_data.average_lab_all(:, 1:3);

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
            par_inds(:,:,i_lastPart,attribute)=par_all4;
        end
    end

    %% 循环处理每个 attribute
    % % for attribute = [10]
    %a-b
    average=average_inds;
    par_all4=par_inds(:,:,:,1);

    % 循环处理每个 attribute
    D_CCT=[];
    for i_lastPart = 1:length(lastParts)
        lastPart = lastParts{i_lastPart};
        for attribute = [1]
                par = par_all4(:, :,i_lastPart,attribute);
                lab_fit=[average(:,1),par(:,4),par(:,5)];
                lab_D65=lab_fit(5,:);
                XYZ_bf=lab2xyz2(lab_fit,'d65_64');
    
                for i_para=1:size(par,1)
                    if i_para<=7
                        i_target=5;
                    elseif i_para<=14
                        i_target=12;
                    else
                        i_target=19;
                    end
                    Labtarget=lab_fit(i_target,:);
                    XYZw_target=XYZ_light(i_target,:)./XYZ_light(i_target,2).*100;
    
                    XYZw(i_para,:)=XYZ_light(i_para,:)./XYZ_light(i_para,2).*100;
                    D_optimal(i_para,1) = optimize_D(XYZ_bf(i_para,:), ...
                        XYZw(i_para,:), XYZw_target, Labtarget);
                    XYZt = CAT16_D(XYZ_bf(i_para,:), XYZw(i_para,:), XYZw_target, D_optimal(i_para,1));
                    Labt(i_para,:) = xyz2lab(XYZt, 'd65_64');
    
                    figure(1)
                    hold on;
                    scatter(par(i_para,4), par(i_para,5),  50, 'o', 'filled');
                    scatter(Labt(i_para,2), Labt(i_para,3),  50, '^', 'filled');
                    scatter(Labtarget(2), Labtarget(3), 80, 'p', 'filled');
                    axis equal;      
    
                    D = linspace(0,1,1000);
                    for i_D=1:length(D)
                        XYZ_aft(i_D,:) = CAT16_D(XYZ_bf(i_para,:), XYZw(i_para,:), XYZw_target, D(i_D));
                    end
                    lab_aft=xyz2lab(XYZ_aft,'d65_64');
                    plot(lab_aft(:,2),lab_aft(:,3));
                    scatter(lab_aft(1,2),lab_aft(1,3));
    
                    % xlim([lim_min_x, lim_max_x]);
                    % ylim([lim_min_y, lim_max_y]);
                    title(picname_group(i_para));
                    exportgraphics(gcf, fullfile(save_folder, ...
                        strcat(picname_group(i_para),  '.jpg')), 'Resolution', 150);
                    close(gcf);
                end
                D_CCT_temp=[D_optimal,CT];
                D_CCT=[D_CCT;D_CCT_temp];
                % 添加图例、标签和标题
                xlabel('{\ita*}');
                ylabel('{\itb*}');
                title(strcat(obs_types_new(i_obstype),attribute_names_new(attribute),'a-b'));
        
                % 设置坐标轴范围
                x = linspace(0, 25, 100); % 从 -10 到 10，生成 100 个点
                plot(x, x); % 'r-' 表示红色实线
                axis equal;      
                % xlim([lim_min_x, lim_max_x]);
                % ylim([lim_min_y, lim_max_y]);
        
                attribute_serial = strcat(sprintf("%02d", attribute), attribute_names_new(attribute));
                if ~exist(fullfile(save_folder, 'a_b'),"dir")
                    mkdir(fullfile(save_folder, 'a_b'));
                end
                exportgraphics(gcf, fullfile(save_folder, 'a_b',strcat(attribute_serial,  'a-b.jpg')), 'Resolution', 300);
                close(gcf);           
    
    
        end
    end
    concatenate_images1(fullfile(save_folder, 'a_b') ,5);
    
end
%%
lab_used=Labt;
lim_min_x=min(lab_used(:,2));
lim_max_x=max(lab_used(:,2));
lim_min_y=min(lab_used(:,3));
lim_max_y=max(lab_used(:,3));
figure(7);
hold on;
colors_light=hsv(7);
for i_para=1:size(lab_fit,1)
    text(Labt(i_para,2),Labt(i_para,3), picname_group(i_para), ...
    'FontSize', 8, 'VerticalAlignment', 'middle', ...
    'Color',colors_light(mod((i_para-1),7)+1,:));
    % scatter(lab_fit(i_para,2),lab_fit(i_para,3), 30, 'o', 'filled', ...
    % 'MarkerFaceColor', colors_light(round((i_para-1)./7)+1,:), ...
    % 'MarkerEdgeColor', colors_light(round((i_para-1)./7)+1,:));
end
% 设置坐标轴范围
x = linspace(0, 25, 100);
plot(x, x);
axis equal;      
xlim([lim_min_x, lim_max_x]);
ylim([lim_min_y, lim_max_y]);
        %%

scatter(D_CCT(:,2),D_CCT(:,1));
figure(4)
D_CCT_reversed=[D_optimal,1116./CT];
D_CCT_reversed(D_CCT_reversed(:,1)<0.001|D_CCT_reversed(:,1)>0.85,:)=[];
scatter(D_CCT_reversed(:,2),D_CCT_reversed(:,1));
%% 拟合曲线，取倒数

figure(3)
hold on
axis equal;

D_CCT_del=D_CCT;
D_CCT_del(D_CCT_del(:,1)<0.001|D_CCT_del(:,1)>0.85,:)=[];
% D_CCT_del([5,12,19],:)=[];
[par_l, r_l, y_l] = linearSplineModel(D_CCT_del);
% [par_q, r_q, y_q] = quadraticSplineModel(D_CCT_del);
% [par, r, y] = quadraticFitModel(D_CCT_del);
% [par_ex, r_ex, y_ex] = exponentialFitModel(D_CCT_del);
%%

[~,duv,~]=xyz2CCT(XYZw,10);
duv=duv';
load(fullfile("optmizedD\backGroundGray\XYZ_gray.mat"),"xyz_gray");
E=mean(xyz_gray(1:7,2));

x=2000:10:8000;x=x';
for i_row=1:length(x)
    D_3spl(i_row,:) = calculateD(x(i_row,:), 0, "VIVO_spl",E);
    D_cherry(i_row,:) = calculateD(x(i_row,:), 0, "cherry",E);
    D_zhai(i_row,:) = calculateD(x(i_row,:), 0, "zhai",E);
    D_summer(i_row,:) = calculateD(x(i_row,:), 0, "summer",E);
end
figure();hold on;
colors=hsv(6);
plot(x,D_3spl,'Color',colors(1,:));
plot(x,D_cherry,'Color',colors(2,:));
plot(x,D_zhai,'Color',colors(3,:));
plot(x,D_summer,'Color',colors(4,:));
scatter(D_CCT(:,2),D_CCT(:,1));

save(fullfile(save_folder,strcat(nation,"D_3spl.mat")),"par_l","y_l","r_l");
exportgraphics(gcf,fullfile(save_folder,strcat(strcat(nation,'D_3spl.jpg'))), ...
    "Resolution",150);
%% 插值


% figure()
% scatter(D_CCT(:,2),D_CCT(:,1),30, 'filled');
% figure()
% scatter(D_CCT_del(:,2),D_CCT_del(:,1),30, 'filled');
%%
function D_optimal = optimize_D(XYZ, XYZw, XYZwt, Labtarget)
    % 定义目标函数，计算 deltaE2000
    objectiveFunction = @(D) cal_deltaE2000(XYZ, XYZw, XYZwt, D, Labtarget);

    % 使用 fminbnd 或 fminsearch 搜索最优的 D 值
    % 假设 D 的合理范围是 [0, 1]
    D_optimal = fminbnd(objectiveFunction, 0, 1);

    % 输出最优 D 值
    fprintf('Optimal D value: %.6f\n', D_optimal);
end

function deltaE = cal_deltaE2000(XYZ, XYZw, XYZwt, D, Labtarget)
    % 调用 CAT16_D 函数计算 XYZt
    XYZt = CAT16_D(XYZ, XYZw, XYZwt, D);

    % 将 XYZt 和 XYZtarget 转换为 Lab
    [Labt] = xyz2lab(XYZt, 'd65_64');

    % 计算 deltaE2000
    deltaE = deltaE2000(Labt, Labtarget);
end
