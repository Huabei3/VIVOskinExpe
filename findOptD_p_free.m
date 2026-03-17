close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量
addpath("utils\")
%% 定义所有需要处理的 attribute
attributes = [1, 2, 3, 4, 5, 6,7, 8, 9,10];

attribute_names = ["Preference", "Attractiveness", "Feminine", "Cooperative", ...
    "Youth", "Healthy", "Fidelity","Harmony", "Fair", "Ruddy"];

picname_group=["h3k","h4k","h5k","h6k","hd65","h7k","h8k",...
        "m3k","m4k","m5k","m6k","md65","m7k","m8k",...
        "l3k","l4k","l5k","l6k","ld65","l7k","l8k"];

%%
nations=["AS","CA","SA","AF"];
nation_indices = cell(5, 1); % 5个人种（包括"all"）
% AS (Asian): f04i, f05i, f06i, m04i, m05i, m06i (索引1-6)
nation_indices{1} = 1:6;
% CA (Caucasian): f01i, f02i, f03i, m01i, m02i, m03i (索引7-12)  
nation_indices{2} = 7:12;
% SA (South Asian): f07i, f08i, m07i, m08i (索引13-16)
nation_indices{3} = 13:16;
% AF (African): f09i, f10i, m09i, m10i (索引17-20)
nation_indices{4} = 17:20;
% all: 所有索引 (索引1-20)
nation_indices{5} = 1:20;

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

% load("optimizedD\light_i.mat","CCT_light","XYZ_light","ct");
load("optimizedD\neutral_gray\i\gray_patch4\XYZw_all.mat", ...
    "CCT_white_mean","XYZw_mean");
CT=CCT_white_mean;
% CT=[3000,4000,5000,6000,6500,7000,8000,...
%     3000,4000,5000,6000,6500,7000,8000,...
%     3000,4000,5000,6000,6500,7000,8000];CT=CT';
for i_para=1:length(CT)
    XYZw_mean(i_para,:)=CCT2xyz(CT(i_para));
end
% save(fullfile(save_folder,"Asian_i.mat"),"CT_inds","XYZwpre_inds");
lab_PMCC = [62.11, 18.96, 19.76];
labC_PMCC = [lab_PMCC, sqrt(lab_PMCC(1, 2)^2 + lab_PMCC(1, 3)^2)];

Dtype='noCAT';optimize_type="dE";
scale_type_origin="unscaled";
for i_obstype=1:1
    save_folder = fullfile("optimizedD","efit_p_free");
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
            attribute_serial = strcat(sprintf("%02d", attribute), attribute_names(attribute));
        
            source_file_used = fullfile('AnalyseResults_p_free', Dtype, scale_type_origin,lastPart, ...
                obs_types(i_obstype), attribute_serial, ...
                'ellipPara', 'fitRes.mat'); % 新增 source_file_used
            for i_para=1:length(picname_group)
                labNgroup_file=fullfile("AnalyseResults_p_free",Dtype,scale_type_origin,lastPart, ...
                    obs_types(i_obstype),attribute_serial,"labNscore", ...
                    strcat("labNscore_group",lastPart,picname_group(i_para),".mat"));
                load(labNgroup_file,"lab_bfCAT");
                lab_ori(i_para,:)=lab_bfCAT(end,:);
            end
            
            % 加载数据
            par_all4=[];
            if exist(source_file_used, 'file') % 新增 source_file_used 的加载
                load(source_file_used);
                par_all4 = par_all;
            else
                par_all4(1:21,1:6)=NaN;
            end
            par_inds(:,:,lastPart_idx,attribute)=par_all4;
            lab_ori_inds(:,:,lastPart_idx)=lab_ori;
        end
    end
    %%
    average=nanmean(average_inds,3);
    par_all4=nanmean(par_inds,3);
    lab_ori_mean=nanmean(lab_ori_inds,3);
    XYZ_bf=lab2xyz2(lab_ori_mean,"d65_64");
    for i_para=1:length(XYZ_bf)
        if i_para<=7
            i_target=5;
        elseif i_para<=14
            i_target=12;
        else
            i_target=19;
        end
        XYZw_target=XYZw_mean(i_target,:);
        XYZ_aft(i_para,:) = CAT16_D(XYZ_bf(i_para,:), XYZw_mean(i_para,:), XYZw_target,1);
    end
    lab_ori_back=xyz2lab(XYZ_aft,"d65_64");



%%
    %分nation保存
    % for i_nation=1:length(nations)
    %     nation=nations(i_nation);
    %     disp(strcat("processing",nation))
    %     curr_nation_indices = nation_indices{i_nation};
    %     average_nation{i_nation}=nanmean(average_inds(:,:,curr_nation_indices),3);
    %     par_all_nation{i_nation}=nanmean(par_inds(:,:,curr_nation_indices,:),3);
    % 
    %     save_folder_nation{i_nation}=fullfile(save_folder,nation);
    %     cal_nation_D(par_all_nation{i_nation}, average_nation{i_nation}, ...
    %         save_folder_nation{i_nation},XYZ_light,picname_group,CT)
    % end
    %%
    
    %% 循环处理每个 attribute
    % % for attribute = [10]
    %a-b
    hue_values = linspace(0, 1, 7 + 1);hue_values = hue_values(1:end-1); 
    hsv_matrix = [hue_values', 0.8 * ones(7, 1), 0.8 * ones(7, 1)];
    colors = hsv2rgb(hsv_matrix);
    line_style = {'-','-.',':'};
    for attribute = [1]
            par = par_all4(:, :,1,attribute);
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
                XYZw_target=XYZw_mean(i_target,:)./XYZw_mean(i_target,2).*100;
                XYZw_used(i_para,:)=XYZw_mean(i_para,:)./XYZw_mean(i_para,2).*100;
                if strcmp(optimize_type,"dE")
                    D_optimal(i_para,1) = optimize_D(XYZ_bf(i_para,:), ...
                        XYZw_used(i_para,:), XYZw_target, Labtarget);
                elseif strcmp(optimize_type,"h")
                    D_optimal(i_para,1) = optimize_D_h(XYZ_bf(i_para,:), ...
                        XYZw_used(i_para,:), XYZw_target, Labtarget);
                end
                XYZt = CAT16_D(XYZ_bf(i_para,:), ...
                    XYZw_used(i_para,:), XYZw_target, D_optimal(i_para,1));

                Labt(i_para,:) = xyz2lab(XYZt, 'd65_64');

                figure()
                hold on;
                scatter(par(i_para,4), par(i_para,5),  50, 'o', 'filled');
                scatter(Labt(i_para,2), Labt(i_para,3),  50, '^', 'filled');
                scatter(Labtarget(2), Labtarget(3), 80, 'p', 'filled');
                axis equal;      

                D = linspace(0,1,1000);
                for i_D=1:length(D)
                    XYZ_aft(i_D,:) = CAT16_D(XYZ_bf(i_para,:), XYZw_used(i_para,:), XYZw_target, D(i_D));
                end
                lab_aft=xyz2lab(XYZ_aft,'d65_64');
                dE_aft=deltaE2000(lab_aft,repmat(Labtarget,size(lab_aft,1),1));
                figure(1)
                % plot(lab_aft(:,2),lab_aft(:,3));
                cmap = jet(length(D));  % 创建颜色映射
                hold on;                
                % 绘制带颜色渐变的轨迹
                for i = 1:length(D)-1
                    % 计算当前线段的颜色（使用 D 值的中间值）
                    color_idx = round((D(i) + D(i+1))/2 * (length(cmap)-1)) + 1;
                    line([lab_aft(i,2), lab_aft(i+1,2)], [lab_aft(i,3), lab_aft(i+1,3)], ...
                        'Color', cmap(color_idx,:), 'LineWidth', 1.5);
                end
                scatter(lab_aft(1,2),lab_aft(1,3));
                title(picname_group(i_para));
                exportgraphics(gcf, fullfile(save_folder, ...
                    strcat(picname_group(i_para),  '.jpg')), 'Resolution', 150);
                close(gcf);
                %画dE-D图
                h2=figure(2);hold on;
                i_nig=mod(i_para-1,7)+1;
                i_nog=floor((i_para-1)/7)+1;
                plot(D,dE_aft,'Color', colors(i_nig,:),'LineStyle',line_style{i_nog});
            end
            
        % 设置坐标轴标签和标题
            xlabel('\textit{D}', 'Interpreter', 'latex', 'FontSize', 12*2);
            ylabel('\textit{dE}', 'Interpreter', 'latex', 'FontSize', 12*2);
            % 设置标题为斜体
            title("dE-D",  'FontSize', 12*2);
            exportgraphics(h2, fullfile(save_folder, ...
            strcat("dE-D.jpg")), 'Resolution', 150);
            close(gcf);
            D_CCT=[D_optimal,CT];
            % 添加图例、标签和标题
            xlabel('{\ita*}');
            ylabel('{\itb*}');
            title(strcat(obs_types_new(i_obstype),attribute_names(attribute),'a-b'));
    
            % 设置坐标轴范围
            x = linspace(0, 25, 100); % 从 -10 到 10，生成 100 个点
            plot(x, x); % 'r-' 表示红色实线
            axis equal;      
            % xlim([lim_min_x, lim_max_x]);
            % ylim([lim_min_y, lim_max_y]);
    
            attribute_serial = strcat(sprintf("%02d", attribute), attribute_names(attribute));
            if ~exist(fullfile(save_folder, 'a_b'),"dir")
                mkdir(fullfile(save_folder, 'a_b'));
            end
            exportgraphics(gcf, fullfile(save_folder, 'a_b',strcat(attribute_serial,  'a-b.jpg')), 'Resolution', 300);
            close(gcf);           


    end
    concatenate_images1(fullfile(save_folder, 'a_b') ,5);

end
%% 看late cat情况
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
end
% 设置坐标轴范围
x = linspace(0, 25, 100);
plot(x, x);
axis equal;      
xlim([lim_min_x, lim_max_x]);
ylim([lim_min_y, lim_max_y]);
%% 画D和倒数色温关系
load(fullfile("optimizedD\backGroundGray\XYZ_gray.mat"),"xyz_gray");
E=mean(xyz_gray(1:7,2));

E_light=xyz_gray(:,2);
F=0.8;
omega=2*pi*(1-cos(pi/36));
S=0.0124; %164.07*75.57*(10^(-6))
LA=E_light./S.*omega;
%%
D_CCT=[D_optimal,CT,LA];
figure(3)
scatter(D_CCT(:,2),D_CCT(:,1));
%%
figure(4)
D_CCT_reversed=[D_optimal,1116./CT];
D_CCT_reversed(D_CCT_reversed(:,1)<0.001|D_CCT_reversed(:,1)>0.85,:)=[];
scatter(D_CCT_reversed(:,2),D_CCT_reversed(:,1));

%%

D_CCT_del=D_CCT;
D_CCT_del([5,6,12,13,19,20],:)=[];
x_fit=D_CCT_del(:,2);
x_fit=1116./x_fit;  % 转换为 1116/CCT
y_fit=D_CCT_del(:,1);

% 执行线性拟合 y = a(1) + a(2)*x_fit
A = [ones(size(x_fit)), x_fit];
a = A \ y_fit;  % 最小二乘解

fprintf('拟合参数: a(1) = %.6f, a(2) = %.6f\n', a(1), a(2));

% 计算拟合优度 R²
y_mean = mean(y_fit);
SS_tot = sum((y_fit - y_mean).^2);
SS_res = sum((y_fit - A*a).^2);
R_squared = 1 - SS_res/SS_tot;
fprintf('拟合优度 R² = %.6f\n', R_squared);

% 生成拟合曲线用于绘图
x_plot = linspace(min(x_fit), max(x_fit), 100);
y_plot = a(1) + a(2)*x_plot;

figure();hold on;

% corr_coef = corr(y_pre, y_fit);
tables = ["poly3", "cherry", "zhai", "summer","grace"];
hue_values = linspace(0, 1, length(tables) + 1);hue_values = hue_values(1:end-1); 
hsv_matrix = [hue_values', 0.8 * ones(length(tables), 1), 0.8 * ones(length(tables), 1)];
colors = hsv2rgb(hsv_matrix);
x=2000:10:9000;x=x';
for i_row=1:length(x)
    % 修改为使用线性拟合参数
    % 注意: x 是 CCT 值，需要转换为 1116/CCT
    D_poly3(i_row,:) = a(1) + a(2)*(1116./x(i_row,:));
    D_cherry(i_row,:) = calculateD(x(i_row,:), 0, "cherry",E);
    D_zhai(i_row,:) = calculateD(x(i_row,:), 0, "zhai",E);
    D_summer(i_row,:) = calculateD(x(i_row,:), 0, "summer",E);
    D_grace(i_row,:) = calculateD(x(i_row,:), 0, "grace",E);
end

% 绘制模型曲线
plot(x,D_poly3,'Color',colors(1,:));
plot(x,D_cherry,'Color',colors(2,:));
plot(x,D_zhai,'Color',colors(3,:));
plot(x,D_summer,'Color',colors(4,:));
plot(x,D_grace,'Color',colors(5,:));

% 绘制原始数据点 (转换回 1116/CCT 格式)
scatter(D_CCT_del(:,2), D_CCT_del(:,1), "filled");

% 添加图例和标签
legend('线性拟合', 'Cherry', 'Zhai', 'Summer', 'Grace', '数据点');
xlabel('CCT (K)');
ylabel('D 值');
title(sprintf('D 值模型比较 (线性拟合: D = %.4f + %.4f*(1116/CCT), R²=%.4f)', a(1), a(2), R_squared));

% 保存图形
exportgraphics(gcf,fullfile(save_folder,strcat(strcat('D_poly3.jpg'))), ...
    "Resolution",150);
%%  画根据曲线预测的点的late cat结果
lab_used=Labt;
lim_min_x=min(lab_used(:,2));
lim_max_x=max(lab_used(:,2));
lim_min_y=min(lab_used(:,3));
lim_max_y=max(lab_used(:,3));
figure(8);
hold on;
colors_light=hsv(8);
XYZ_refer=mean(XYZw_used([5,12,19],:));
XYZ_bf=lab2xyz2(lab_fit,'d65_64');
for i_para=1:size(lab_fit,1)
    D_pre(i_para,1)= a(1) + a(2)*(1116./CT(i_para,:));
    XYZt = CAT16_D(XYZ_bf(i_para,:), ...
        XYZw_used(i_para,:), wd65, D_pre(i_para,1));

    Labt(i_para,:) = xyz2lab(XYZt, 'd65_64');

    % scatter(lab_fit(i_para,2),lab_fit(i_para,3),'filled', 'Color',colors_light(mod((i_para-1),7)+1,:));
    text(Labt(i_para,2),Labt(i_para,3), picname_group(i_para), ...
    'FontSize', 8, 'VerticalAlignment', 'middle', ...
    'Color',colors_light(mod((i_para-1),7)+1,:));
end
% 设置坐标轴范围
x = linspace(0, 25, 100);
plot(x, x);
axis equal;      
exportgraphics(gcf,fullfile(save_folder,strcat(strcat('lateCAT_poly3.jpg'))), ...
    "Resolution",150);

function D_optimal = optimize_D_h(XYZ, XYZw, XYZwt, Labtarget)
    % 定义目标函数，计算 hue angle 差异
    objectiveFunction = @(D) cal_hue_angle_difference(XYZ, XYZw, XYZwt, D, Labtarget);

    % 使用 fminbnd 搜索最优的 D 值
    D_optimal = fminbnd(objectiveFunction, 0, 1);

    % 输出最优 D 值
    fprintf('Optimal D value: %.6f\n', D_optimal);
end

function hue_diff = cal_hue_angle_difference(XYZ, XYZw, XYZwt, D, Labtarget)
    % 调用 CAT16_D 函数计算 XYZt
    XYZt = CAT16_D(XYZ, XYZw, XYZwt, D);

    % 将 XYZt 和 XYZtarget 转换为 Lab
    [Labt] = xyz2lab(XYZt, 'd65_64');
    % 返回绝对差异的平均值作为优化目标
    hue_diff = abs(atan2d(Labt(:, 3), Labt(:, 2))- ...
        atan2d(Labtarget(:, 3), Labtarget(:, 2)));
end

