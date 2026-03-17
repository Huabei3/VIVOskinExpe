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
load(fullfile("optimizedD\backGroundGray\XYZ_gray.mat"),"xyz_gray");
E=mean(xyz_gray(1:7,2));
E_light=xyz_gray(:,2);
F=0.8;
omega=2*pi*(1-cos(pi/36));
S=0.0124; %164.07*75.57*(10^(-6))
LA=E_light./S.*omega;


picname_group = ["rs01", "rs02", "rs03", "rs04", "rs05",...
"rs06", "rs07", "rs08", "rs09", "rs10",...
  "rs11", "rs12", "rs13", "rs14"];
lastParts = {'f04r', 'f05r', 'f06r', 'm04r', 'm05r', 'm06r',...
'f01r', 'f02r', 'f03r', 'm01r', 'm02r', 'm03r',...
'f07r', 'f08r','m07r', 'm08r',...
'f09r', 'f10r','m09r', 'm10r'};n_para = 14;iOr='r';
nations = ["AS", "CA", "SA", "AF","all"];

use3para=false;
% 定义人种对应的lastParts索引
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

indices_target = 1:14;    
for i_nation=1:length(nations)
    model_tcp_mean_inds=[];
    for i_lastPart=nation_indices{i_nation}
        lastPart=lastParts{i_lastPart};
        load(fullfile("..\renderCode\light_r\model_light_mean", ...
            strcat(strrep(lastPart,"r",""),".mat")), ...
        "model_tcp_mean","XYZwpre_mea");
        XYZwpre_mea_inds(:,:,i_lastPart)=XYZwpre_mea;
        model_tcp_mean_inds=[model_tcp_mean_inds,model_tcp_mean];
    end    
    XYZw_mean_nation{i_nation}=nanmean(XYZwpre_mea_inds,3);
    CT_nations{i_nation}=nanmean(model_tcp_mean_inds,2);
end

n_para=length(picname_group);
obs_types=["non_model"];
% obs_types=["non_model","model_group","model","all"];
obs_types_new=["stranger","acquaintance","self","all"];

wd65 = [94.811, 100.00, 107.304];


lab_PMCC = [62.11, 18.96, 19.76];
labC_PMCC = [lab_PMCC, sqrt(lab_PMCC(1, 2)^2 + lab_PMCC(1, 3)^2)];

Dtype='noCAT';optimize_type="h";

for i_obstype=1:1
    save_folder = fullfile("optimizedD",optimize_type,"r");
    % 创建保存文件夹
    if ~exist(save_folder, "dir")
        mkdir(save_folder);
    end
    
    % 定义色环上的 7 种颜色
    colors = hsv(7); % 使用 hsv 色图生成 7 种颜色

    line_style = {'-','-.',':'};

    %% 加载数据
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


    %% 开始拟合
    cmap = colormap('jet');
    cmap = flipud(cmap);  % 翻转颜色映射，使蓝色对应高色温，红色对应低色温
    data_light_i=load("optimizedD\neutral_gray\i\gray_patch4\XYZw_all.mat", ...
    "XYZw_mean","CCT_white_mean");
    XYZw_mean_i=data_light_i.XYZw_mean;
    XYZw_mean_i=XYZw_mean_i./XYZw_mean_i(2).*100;
    for lastPart_idx = 1:length(lastParts)
        lastPart = lastParts{lastPart_idx};
        model = lastPart(1:end-1);
        % load(fullfile("optimizedD\neutral_gray\r\gray_patch4",strcat(model,"r.mat")), ...
        % "CCTest","XYZw");
        load(fullfile("..\renderCode\light_r\model_light_mean",strcat(model,".mat")), ...
            "model_tcp_mean","XYZwpre_mea");
        CT=model_tcp_mean;
        XYZw=XYZwpre_mea;
        XYZw=XYZw./XYZw(:,2).*100;
        CT_norm = (CT - min(CT)) / (max(CT) - min(CT));
        for attribute = 1
            average=average_inds(:,:,lastPart_idx);
            par_all4=par_inds(:,:,lastPart_idx,attribute);
            par = par_all4(:, :,1,attribute);
            lab_fit=[average(:,1),par(:,4),par(:,5)];

            XYZ_bf=lab2xyz2(lab_fit,'d65_64');
            XYZw_target=mean(XYZw_mean_i([5,12,19],:),1);

            average_i=average_inds_i(:,:,lastPart_idx);
            par_all4_i=par_inds_i(:,:,lastPart_idx,attribute);
            par_i = par_all4_i(:, :,1,attribute);
            lab_fit_i=[average_i(:,1),par_i(:,4),par_i(:,5)];
            Labtarget=mean(lab_fit_i([5,12,19],:),1);

            XYZtarget=lab2xyz2(Labtarget,"d65_64");
            XYZtarget=repmat(XYZtarget,n_para,1);
            XYZtarget_scaled=XYZtarget./XYZtarget(:,2).*XYZ_bf(:,2);
            Labtarget_scaled=xyz2lab(XYZtarget_scaled,"d65_64");
            
            load(fullfile("optimizedD\neutral_gray\r\gray_patch4", ...
                strcat(lastPart,".mat")),"XYZw");
            load(fullfile("..\renderCode\light_r\model_light_mean", ...
            strcat(strrep(lastPart,"r",""),".mat")), ...
            "model_tcp_mean","XYZwpre_mea");
            XYZw_used=XYZwpre_mea;
            % XYZw_used=XYZw;
            % for i_para=1:length(CT)
            % XYZw_used(i_para,:)=CCT2xyz(CT(i_para));
            % end
            CT=model_tcp_mean;
            % 根据optimize_type选择目标函数
            if strcmp(optimize_type, "dE")
                objective_func = @(a_val) calculate_mean_dE(a_val, lab_fit, ...
                    XYZw_used,CT, Labtarget_scaled,XYZw_target, LA, use3para);
            else
                objective_func = @(a_val) calculate_mean_h(a_val, lab_fit, ...
                     XYZw_used,CT, Labtarget_scaled,XYZw_target, LA, use3para);
            end

            if use3para
                lb = [0.1, 500, 0.1];  % 三个参数的下界 [a1, a2, a3]
                ub = [2.0, 2000, 2.0]; % 三个参数的上界 [a1, a2, a3]
                initial_a = [0.723, 1116, 0.8]; % 三个参数的初始猜测值
            else
                lb = [0, -inf];  % 两个参数的下界 [a1, a2]
                ub = [2.0, inf]; % 两个参数的上界 [a1, a2]
                initial_a = [0.723, 1116]; % 两个参数的初始猜测值
            end
            options = optimoptions('fmincon', 'Display', 'iter', 'TolX', 1e-6);
            [optimal_a, min_obj] = fmincon(objective_func, initial_a, [], [], [], [], lb, ub, [], options);
            if use3para
                fprintf('最优a值 = [%.6f, %.6f, %.6f], 最小目标值 = %.4f\n', optimal_a(1), optimal_a(2), optimal_a(3), min_obj);
            else
                fprintf('最优a值 = [%.6f, %.6f], 最小目标值 = %.4f\n', optimal_a(1), optimal_a(2), min_obj);
            end
            
            % 使用最优a值重新计算
            par = par_all4(:, :, 1, attribute);
            lab_fit = [average(:, 1), par(:, 4), par(:, 5)];
            lab_D65 = lab_fit(5, :);
            XYZ_bf = lab2xyz2(lab_fit, 'd65_64');
            Labtarget=mean(lab_fit_i([5,12,19],:),1);
            XYZw_target=mean(XYZw_mean_i([5,12,19],:),1);    
            for i_para=1:size(par, 1)
                % 使用最优a值计算D_pre - 根据选择使用两个或三个参数
                if use3para
                    D_pre(i_para, 1)=optimal_a(1).*(1-optimal_a(2)./CT(i_para)).*optimal_a(3)*log(LA(i_para));
                else
                    D_pre(i_para, 1)=optimal_a(1).*(1-optimal_a(2)./CT(i_para));
                end
                
                XYZt(i_para,:) = CAT16_D(XYZ_bf(i_para,:), ...
                    XYZw(i_para,:), XYZw_target, D_pre(i_para,1));
                Labt(i_para,:) = xyz2lab(XYZt(i_para,:), 'd65_64');
                
            end
            optimal_a_inds(i_lastPart,:)=optimal_a;
    
            dE = deltaE2000(Labt, Labtarget_scaled);
            mean_dE = mean(dE);
            fprintf('使用最优a值后的平均dE: %.4f\n', mean_dE);
    
            % 绘制a-b图
            hue_values = linspace(0, 1, 7 + 1);
            hue_values = hue_values(1:end-1); 
            hsv_matrix = [hue_values', 0.8 * ones(7, 1), 0.8 * ones(7, 1)];
            colors = hsv2rgb(hsv_matrix);
            line_style = {'-','-.',':'};
            
            figure;
            hold on;
            
            % 绘制样本点
            for i_para = 1:size(lab_fit, 1)
                color_idx = round(CT_norm(i_para) * (size(cmap, 1) - 1)) + 1;
                point_color = cmap(color_idx, :);

                scatter(Labt(i_para, 2), Labt(i_para, 3), 50, point_color, 'filled');
                text(Labt(i_para,2), Labt(i_para,3), num2str(D_pre(i_para)), ...
                    'FontSize', 8, 'VerticalAlignment', 'middle', ...
                    'Color', 'k');
                D = linspace(0,1,1000);
                for i_D=1:length(D)
                    XYZ_aft(i_D,:) = CAT16_D(XYZ_bf(i_para,:), XYZw(i_para,:), XYZw_target, D(i_D));
                end
                lab_aft=xyz2lab(XYZ_aft,'d65_64');
                plot(lab_aft(:,2),lab_aft(:,3));
                scatter(lab_fit(i_para, 2), lab_fit(i_para, 3), 50, point_color, 'filled','^');
            end
            scatter(Labtarget(1, 2), Labtarget(1, 3), 50, 'r', 'filled','p');
            
            % 绘制y=x线
            x = linspace(min(Labt(:,2))-5, max(Labt(:,2))+5, 100);
            plot(x, x, 'k--', 'LineWidth', 1);
            
            % 添加图例、标签和标题
            xlabel('{\ita*}', 'FontSize', 12);
            ylabel('{\itb*}', 'FontSize', 12);
        
            % 设置坐标轴范围
            xlim([min(Labt(:,2))-5, max(Labt(:,2))+5]);
            ylim([min(Labt(:,3))-5, max(Labt(:,3))+5]);
            axis equal;      
            
            % 保存图像
            save_dir = fullfile(save_folder, "check_pic");
            if ~exist(save_dir, "dir")
                mkdir(save_dir);
            end
            
            exportgraphics(gcf, fullfile(save_dir, ...
                strcat(lastPart,".jpg")), 'Resolution', 300);
            close(gcf);           
    
            % 保存优化结果
            optimization_results.a = optimal_a;
            optimization_results.mean_dE = mean_dE;
            optimization_results.dE = dE;
            optimization_results.use3para = use3para;
            save(fullfile(save_folder, sprintf('optimization_results_attr_%d.mat', attribute)), 'optimization_results');
  
        end

    end
%% 对每个nation进行验证

    for attribute = [1]
       
        nations_save_dir = fullfile(save_folder, 'nations');
        if ~exist(nations_save_dir, "dir")
            mkdir(nations_save_dir);
        end
        
        % 为每个nation创建子文件夹
        for i_nation = 1:length(nations)
            nation = nations(i_nation);
            nation_dir = fullfile(nations_save_dir, nation);
            if ~exist(nation_dir, "dir")
                mkdir(nation_dir);
            end
            
            % 获取当前nation对应的lastPart索引
            curr_nation_indices = nation_indices{i_nation};
            optimal_a=nanmean(optimal_a_inds,1);
            
            % 计算当前nation的平均参数
            par_nation = nanmean(par_inds(:,:,curr_nation_indices,attribute),3);
            average_nation=nanmean(average_inds(:,:,curr_nation_indices,attribute),3);
            lab_fit_nation = [average_nation(:, 1), par_nation(:, 4), par_nation(:, 5)];
            XYZ_bf_nation = lab2xyz2(lab_fit_nation, 'd65_64');
            
            average_i=average_inds_i(:,:,curr_nation_indices);
            par_all4_i=par_inds_i(:,:,curr_nation_indices,attribute);
            par_i = par_all4_i(:, :,1,attribute);
            lab_fit_i=[average_i(:,1),par_i(:,4),par_i(:,5)];
            Labtarget=mean(lab_fit_i([5,12,19],:),1);

            XYZw_used=XYZw_mean_nation{i_nation};
            CT=CT_nations{i_nation};
            
            for i_para=1:size(par_nation, 1)
                
                % 使用全局最优a值计算D_pre
                if use3para
                    D_pre_nation(i_para,1) = optimal_a(1).*(1-optimal_a(2)./CT(i_para)).*optimal_a(3)*log(LA(i_para));
                else
                    D_pre_nation(i_para,1) = optimal_a(1).*(1-optimal_a(2)./CT(i_para));
                end
                
                % 执行色适应变换

                XYZt_nation = CAT16_D(XYZ_bf_nation(i_para,:), ...
                    XYZw_used(i_para,:), wd65, ...
                    D_pre_nation(i_para,1));
                
                % 转换回Lab色彩空间
                Labt_nation(i_para,:) = xyz2lab(XYZt_nation, 'd65_64');
            end
            XYZtarget=lab2xyz2(Labtarget,"d65_64");
            XYZtarget=repmat(XYZtarget,n_para,1);
            XYZtarget_scaled=XYZtarget./XYZtarget(:,2).*XYZ_bf_nation(:,2);
            Labtarget_scaled=xyz2lab(XYZtarget_scaled,"d65_64");
            dE_nation=deltaE2000(Labt_nation,Labtarget_scaled);
            
            
            % 绘制当前nation的a-b图
            figure;
            hold on;
            XYZt_nation=lab2xyz2(Labt_nation,"d65_64");
            XYZt_nation=repmat(XYZt_nation,n_para,1);
            XYZt_nation_scaled=XYZt_nation./XYZt_nation(:,2).*mean(XYZt_nation(:,2));
            Labt_nation_scaled=xyz2lab(XYZt_nation_scaled,"d65_64");
            % 绘制样本点
            for i_para = 1:size(lab_fit_nation, 1)
                scatter(Labt_nation_scaled(i_para, 2), Labt_nation_scaled(i_para, 3), 50, ...
                    colors(mod((i_para-1),7)+1,:), 'filled');
                text(Labt_nation_scaled(i_para,2), Labt_nation_scaled(i_para,3), picname_group(i_para), ...
                    'FontSize', 8, 'VerticalAlignment', 'middle', ...
                    'Color', 'k');
            end
            mean(atan2d(Labt_nation_scaled(:,3), Labt_nation_scaled(:,2)))
            max(atan2d(Labt_nation_scaled(:,3),Labt_nation_scaled(:,2)))
            min(atan2d(Labt_nation_scaled(:,3),Labt_nation_scaled(:,2)))
            
            % 绘制y=x线
            x = linspace(min(Labt_nation_scaled(:,2))-5, max(Labt_nation_scaled(:,2))+5, 100);
            plot(x, x, 'k--', 'LineWidth', 1);
            
            % 添加图例、标签和标题
            xlabel('{\ita*}', 'FontSize', 12);
            ylabel('{\itb*}', 'FontSize', 12);

            % 设置坐标轴范围
            Labt_h_nation(i_nation,1)=nanmean(atan2d(Labt_nation(:,3),Labt_nation(:,2)));
            xlim([min(Labt_nation(:,2))-5, max(Labt_nation(:,2))+5]);
            ylim([min(Labt_nation(:,3))-5, max(Labt_nation(:,3))+5]);
            axis equal;
            
            exportgraphics(gcf, fullfile(nations_save_dir, strcat(nation,".jpg")), ...
                'Resolution', 300);
            close(gcf);
            
            % 保存当前nation的结果
            nation_results.par = par_nation;
            nation_results.lab_fit = lab_fit_nation;
            nation_results.Labt = Labt_nation;
            nation_results.dE = dE_nation;
            
            save(fullfile(nations_save_dir, sprintf('nation_results_%s.mat', nation)), 'nation_results');
        end
    end




end
    




%%
% 目标函数定义：计算给定a值时的平均色差
function mean_dE = calculate_mean_dE(a_val, lab_fit, ...
                    XYZw_used,CT, Labtarget_scaled,XYZw_target, LA, use3para)
    % 确保a_val包含足够的参数
    if use3para && length(a_val) < 3
        error('使用三个参数模型时，优化参数a需要包含三个值: a(1), a(2)和a(3)');
    elseif ~use3para && length(a_val) < 2
        error('使用两个参数模型时，优化参数a需要包含两个值: a(1)和a(2)');
    end
    
    XYZ_bf = lab2xyz2(lab_fit, 'd65_64');
    

    for i_para = 1:size(lab_fit,1)
      
        % 使用传入的参数计算D_pre
        if use3para
            D_pre(i_para, 1)=a_val(1).*(1-a_val(2)./CT(i_para)).*a_val(3)*log(LA(i_para));
        else
            D_pre(i_para, 1)=a_val(1).*(1-a_val(2)./CT(i_para));
        end
        
        % 执行色适应变换
        XYZt(i_para, :) = CAT16_D(XYZ_bf(i_para, :), ...
            XYZw_used(i_para, :), XYZw_target, D_pre(i_para, 1));
        
        % 转换回Lab色彩空间
        Labt(i_para, :) = xyz2lab(XYZt(i_para, :), 'd65_64');
    end
    
    % 计算色差
    dE = deltaE2000(Labt, Labtarget_scaled);dE=dE';

    
    % 返回平均色差
    mean_dE = mean(dE);
    % mean_dE = mean(dE);
end

% 新增：calculate_mean_h函数
function mean_h = calculate_mean_h(a_val, lab_fit, ...
                    XYZw_used,CT, Labtarget_scaled,XYZw_target, LA, use3para)
    % 确保a_val包含足够的参数
    if use3para && length(a_val) < 3
        error('使用三个参数模型时，优化参数a需要包含三个值: a(1), a(2)和a(3)');
    elseif ~use3para && length(a_val) < 2
        error('使用两个参数模型时，优化参数a需要包含两个值: a(1)和a(2)');
    end

    XYZ_bf = lab2xyz2(lab_fit, 'd65_64');
    
    for i_para = 1:size(lab_fit,1)
       
        % 使用传入的参数计算D_pre
        if use3para
            D_pre(i_para, 1)=a_val(1).*(1-a_val(2)./CT(i_para)).*a_val(3)*log(LA(i_para));
        else
            D_pre(i_para, 1)=a_val(1).*(1-a_val(2)./CT(i_para));
        end
        
        % 执行色适应变换
        XYZt(i_para, :) = CAT16_D(XYZ_bf(i_para, :), ...
            XYZw_used(i_para, :), XYZw_target, D_pre(i_para, 1));
        
        % 转换回Lab色彩空间
        Labt(i_para, :) = xyz2lab(XYZt(i_para, :), 'd65_64');
    end
    
    % 计算色相角的方差
    h_angles = atan2d(Labt(:, 3), Labt(:, 2));
    mean_h = var(h_angles); % 返回色相角的方差
end