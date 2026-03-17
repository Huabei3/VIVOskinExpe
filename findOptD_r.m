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



picname_group = ["rs01", "rs02", "rs03", "rs04", "rs05",...
"rs06", "rs07", "rs08", "rs09", "rs10",...
  "rs11", "rs12", "rs13", "rs14"];
lastParts = {'f04r', 'f05r', 'f06r', ...
'm04r', 'm05r', 'm06r'};

n_para=length(picname_group);
obs_types=["non_model"];
% obs_types=["non_model","model_group","model","all"];
obs_types_new=["stranger","acquaintance","self","all"];

wd65 = [94.811, 100.00, 107.304];


lab_PMCC = [62.11, 18.96, 19.76];
labC_PMCC = [lab_PMCC, sqrt(lab_PMCC(1, 2)^2 + lab_PMCC(1, 3)^2)];

Dtype='noCAT';optimize_type="dE";
for i_obstype=1:1
    save_folder = fullfile("optimizedD",optimize_type,"r");
    % 创建保存文件夹
    if ~exist(save_folder, "dir")
        mkdir(save_folder);
    end
    
    % 定义色环上的 7 种颜色
    colors = hsv(7); % 使用 hsv 色图生成 7 种颜色
    load("optimizedD\neutral_gray\i\gray_patch4\XYZw_all.mat", ...
        "CCTest_mean","XYZw_mean");
    XYZw_mean=XYZw_mean./XYZw_mean(:,2).*100;
    line_style = {'-','-.',':'};
    for lastPart_idx = 1:length(lastParts)
        lastPart = lastParts{lastPart_idx};
        model = lastPart(1:end-1);


        lastPart=char(lastPart);
        average_file = fullfile("aveSkin", lastPart, "autoNhand_scaleoverLUT.mat");
        average_data = load(average_file);
        average_inds(:,:,lastPart_idx) = average_data.average_lab_all(:, 1:3);
        average_file_i = fullfile("aveSkin", strrep(lastPart,"r","i"), "autoNhand_scaleoverLUT.mat");
        average_data_i = load(average_file_i);
        average_inds_i(:,:,lastPart_idx) = average_data_i.average_lab_all(:, 1:3);
    
    
        for attribute = [1]
            fprintf('Processing attribute: %d\n', attribute);
            
            % 生成 attribute_serial
            attribute_serial = strcat(sprintf("%02d", attribute), attribute_names_new(attribute));
        
            source_file_used = fullfile('AnalyseResults1', Dtype, lastPart, ...
                obs_types(i_obstype), attribute_serial, ...
                'ellipPara', 'fitRes.mat'); % 新增 source_file_used
            source_file_used1 = fullfile('AnalyseResults1', Dtype, ...
                strrep(lastPart,"r","i"), ...
                obs_types(i_obstype), attribute_serial, ...
                'ellipPara', 'fitRes.mat'); % 新增 source_file_used
            % 加载数据
            par_all4=[];
            if exist(source_file_used, 'file') % 新增 source_file_used 的加载
                load(source_file_used);
                par_all4 = par_all;
                data_i=load(source_file_used1,"par_all");
                par_all4_i=data_i.par_all;
            else
                par_all4(1:n_para,1:6)=NaN;
            end
            par_inds(:,:,lastPart_idx,attribute)=par_all4;
            par_inds_i(:,:,lastPart_idx,attribute)=par_all4_i;
        end
    end
    %%

    %% 循环处理每个 attribute
        %a-b
    lim_min_x=min(min(min(par_all4(1:7,4,:,:))));
    lim_max_x=max(max(max(par_all4(1:7,4,:,:))));
    lim_min_y=min(min(min(par_all4(1:7,5,:,:))));
    lim_max_y=max(max(max(par_all4(1:7,5,:,:))));
    cmap = colormap('jet');
    cmap = flipud(cmap);  % 翻转颜色映射，使蓝色对应高色温，红色对应低色温
    
    for lastPart_idx = 1:length(lastParts)
        lastPart = lastParts{lastPart_idx};
        model = lastPart(1:end-1);
        load(fullfile("optimizedD\neutral_gray\r\gray_patch4",strcat(model,"r.mat")), ...
        "CCTest","XYZw");
        load(fullfile("..\renderCode\light_r\model_light_mean",strcat(model,".mat")), ...
            "model_tcp_mean","XYZwpre_mea");
        CT=model_tcp_mean;
        % for i_para=1:length(CT)
        % XYZw(i_para,:)=CCT2xyz(CT(i_para));
        % end
        XYZw=XYZwpre_mea;
        CT_norm = (CT - min(CT)) / (max(CT) - min(CT));
        for attribute = 1
                average=average_inds(:,:,lastPart_idx);
                average_i=average_inds_i(:,:,lastPart_idx);
                par_all4_i=par_inds_i(:,:,lastPart_idx,attribute);
                par_all4=par_inds(:,:,lastPart_idx,attribute);
                par = par_all4(:, :,1,attribute);
                lab_fit=[average(:,1),par(:,4),par(:,5)];
    
                par_i = par_all4_i(:, :,1,attribute);
                lab_fit_i=[average_i(:,1),par_i(:,4),par_i(:,5)];
    
    
                XYZ_bf=lab2xyz2(lab_fit,'d65_64');
    
                Labtarget=mean(lab_fit_i([5,12,19],:),1);
                XYZ_target=lab2xyz2(Labtarget,'d65_64');
                XYZw=XYZw./XYZw(:,2).*100;
                for i_para=1:size(par,1)

                    XYZ_target_scaled(i_para,:)=XYZ_target./XYZ_target(2).*XYZ_bf(i_para,2);
                    Labtarget_scaled(i_para,:)=xyz2lab(XYZ_target_scaled(i_para,:),'d65_64');
                    XYZw_target=mean(XYZw_mean([5,12,19],:),1);
                    if strcmp(optimize_type,"dE")
                        D_optimal(i_para,1) = optimize_D(XYZ_bf(i_para,:), ...
                            XYZw(i_para,:), XYZw_target, Labtarget_scaled(i_para,:));
                    elseif strcmp(optimize_type,"h")
                        D_optimal(i_para,1) = optimize_D_h(XYZ_bf(i_para,:), ...
                            XYZw(i_para,:), XYZw_target, Labtarget_scaled(i_para,:));
                    end
                    XYZt = CAT16_D(XYZ_bf(i_para,:), XYZw(i_para,:), XYZw_target, D_optimal(i_para,1));
                    [Labt] = xyz2lab(XYZt, 'd65_64');
    
                    figure(1)
                    hold on;
                    scatter(par(i_para,4), par(i_para,5),  50, 'o', 'filled');
                    scatter(Labt(2), Labt(3),  50, '^', 'filled');
                    scatter(Labtarget(2), Labtarget(3), 80, 'p', 'filled');
                    axis equal;      
    
                    D = linspace(0,1,1000);
                    for i_D=1:length(D)
                        XYZ_aft(i_D,:) = CAT16_D(XYZ_bf(i_para,:), XYZw, XYZw_target, D(i_D));
                    end
                    lab_aft=xyz2lab(XYZ_aft,'d65_64');
                    if strcmp(optimize_type,"dE")
                        dE_aft=deltaE2000(lab_aft,repmat(Labtarget,size(lab_aft,1),1));
                    elseif strcmp(optimize_type,"h")
                        dh_aft=abs(atan2d(lab_aft(:, 3), lab_aft(:, 2))- ...
                            atan2d(Labtarget(:, 3), Labtarget(:, 2)));
                    end
    
                    plot(lab_aft(:,2),lab_aft(:,3));
                    scatter(lab_aft(1,2),lab_aft(1,3));
                    title(picname_group(i_para));
                    if ~exist(fullfile(save_folder, lastPart),"dir")
                        mkdir(fullfile(save_folder, lastPart));
                    end
                    exportgraphics(gcf, fullfile(save_folder, lastPart,...
                        strcat(picname_group(i_para),  '.jpg')), 'Resolution', 150);
                    close(gcf);
                    %画dE-D图
                    color_idx = round(CT_norm(i_para) * (size(cmap, 1) - 1)) + 1;
                    point_color = cmap(color_idx, :);
                    h2=figure(2);hold on;
                    if strcmp(optimize_type,"dE")
                        plot(D,dE_aft,'Color', point_color,'LineStyle',line_style{1});
                    elseif strcmp(optimize_type,"h")
                        plot(D,dh_aft,'Color', point_color,'LineStyle',line_style{1});
                    end
    
                end
                % 添加颜色条表示色温
                cb = colorbar;
                cb.Label.String = 'Color Temperature (K)';
                cb.Label.FontSize = 10;
                clim([min(CT), max(CT)]);
                colormap(cmap);
                % 设置标题为斜体
                if strcmp(optimize_type,"dE")
                    title([lastPart,"dE-D"],  'FontSize', 12*2);
                    xlabel('\textit{D}', 'Interpreter', 'latex', 'FontSize', 12*2);
                    ylabel('\textit{dE}', 'Interpreter', 'latex', 'FontSize', 12*2);
                elseif strcmp(optimize_type,"h")
                    title([lastPart,"dh-D"],  'FontSize', 12*2);
                    xlabel('\textit{D}', 'Interpreter', 'latex', 'FontSize', 12*2);
                    ylabel('\textit{dh}', 'Interpreter', 'latex', 'FontSize', 12*2);
                end
                if ~exist(fullfile(save_folder, "dE_D"),"dir")
                    mkdir(fullfile(save_folder, "dE_D"));
                end
                exportgraphics(h2, fullfile(save_folder,"dE_D",...
                strcat(lastPart,".jpg")), 'Resolution', 150);
                close(gcf);
                
    
                D_CCT=[D_optimal,CT];
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
                output_folder=fullfile(save_folder,lastPart);
                if ~exist(output_folder,"dir")
                    mkdir(output_folder);
                end
                exportgraphics(gcf, fullfile(output_folder,strcat(attribute_serial,  'a-b.jpg')), 'Resolution', 300);
                close(gcf);
    
        end
        concatenate_images1(fullfile(save_folder,"dE_D"), 3);   
        D_CCT_inds(:,:,lastPart_idx)=D_CCT;
    end
end
    
%%

D_CCT_mean=nanmean(D_CCT_inds,3);
scatter(D_CCT_mean(:,2),D_CCT_mean(:,1));
% figure()
% D_CCT_reversed=[D_optimal,1116./CT];
% D_CCT_reversed(D_CCT_reversed(:,1)<0.001|D_CCT_reversed(:,1)>0.99,:)=[];
% scatter(D_CCT_reversed(:,2),D_CCT_reversed(:,1));
%% 拟合曲线，取倒数

figure(3)
hold on
axis equal;

scatter(D_CCT_mean(:,2),D_CCT_mean(:,1),30, 'filled');
% [par2, r2, y2] = splineModel(D_CCT, 2);
% [par3, r3, y3] = splineModel(D_CCT, 3);
[par_l, r_l, y_l] = linearSplineModel(D_CCT_mean);
D_CCT_del=D_CCT_mean;
D_CCT_del(D_CCT_del(:,1)<0.001|D_CCT_del(:,1)>0.99,:)=[];
[par, r, y] = quadraticFitModel(D_CCT_del);
[par_ex, r_ex, y_ex] = exponentialFitModel(D_CCT_del);
%[5000,6500,0.717419298173960,-1.725932497982749e-05,-3.872027060205368e-04,3.753528225261554e-04]
x=1:0.001:10;y=1-1*exp(x);plot(x,y);

save(fullfile(save_folder,"D_3sec_theo.mat"),"par_l","y_l","r_l");
exportgraphics(gcf,fullfile(save_folder,strcat('D_3sec_theo.jpg')), ...
    "Resolution",150);



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

%% 用h

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
