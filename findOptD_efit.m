close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量
addpath("utils\")

%% 参数设置：选择使用两个参数还是三个参数模型
useThreeParameters = false; % true 表示使用三个参数，false 表示使用两个参数

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

lastParts = {'f04i', 'f05i', 'f06i', 'm04i', 'm05i', 'm06i',...
'f01i', 'f02i', 'f03i', 'm01i', 'm02i', 'm03i',...
'f07i', 'f08i','m07i', 'm08i',...
'f09i', 'f10i','m09i', 'm10i'};nation="all";

%%
obs_types=["non_model","model_group","model","all"];
obs_types_new=["stranger","acquaintance","self","all"];

wd65 = [94.811, 100.00, 107.304];

% 加载中性灰数据
load("optimizedD\neutral_gray\i\gray_patch4\XYZw_all.mat", ...
    "XYZw_mean","CCT_white_mean");
CT = CCT_white_mean;
load(fullfile("optimizedD\backGroundGray\XYZ_gray.mat"),"xyz_gray");
E=xyz_gray(:,2);
F=0.8;
omega=2*pi*(1-cos(pi/36));
S=0.0124; %164.07*75.57*(10^(-6))
LA=E./S.*omega;
% CT=[3000,4000,5000,6000,6500,7000,8000,...
%     3000,4000,5000,6000,6500,7000,8000,...
%     3000,4000,5000,6000,6500,7000,8000];
for i_para=1:length(CT)
    XYZw_mean(i_para,:)=CCT2xyz(CT(i_para));
    [~,duv(i_para,1),~] = xyz2CCT(XYZw_mean(i_para,:),10);
end

lab_PMCC = [62.11, 18.96, 19.76];
labC_PMCC = [lab_PMCC, sqrt(lab_PMCC(1, 2)^2 + lab_PMCC(1, 3)^2)];

Dtype='noCAT';
for i_obstype=1:1
    save_folder = fullfile("optimizedD","poly3");
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
    %%
    average=nanmean(average_inds,3);
    par_all4=nanmean(par_inds,3);

    %%
    
    %% 循环处理每个 attribute
    for attribute = [1]

        % 定义优化的目标函数：计算给定a值时的平均色差
        objective_func = @(a_val) calculate_mean_dE(a_val, par_all4, average, CT, XYZw_mean, LA, useThreeParameters);
        
        % 根据选择设置参数边界和初始值
        if useThreeParameters
            lb = [0.1, 500, 0.1];  % 三个参数的下界 [a1, a2, a3]
            ub = [2.0, 2000, 2.0]; % 三个参数的上界 [a1, a2, a3]
            initial_a = [0.723, 1116, 0.8]; % 三个参数的初始猜测值
        else
            lb = [0.1, 500];  % 两个参数的下界 [a1, a2]
            ub = [2.0, 2000]; % 两个参数的上界 [a1, a2]
            initial_a = [0.723, 1116]; % 两个参数的初始猜测值
        end
        
        % 使用fmincon进行带约束的优化，确保参数在合理范围内
        options = optimoptions('fmincon', 'Display', 'iter', 'TolX', 1e-6);
        [optimal_a, min_mean_dE] = fmincon(objective_func, initial_a, [], [], [], [], lb, ub, [], options);
        
        if useThreeParameters
            fprintf('Attribute %d: 最优a值 = [%.6f, %.6f, %.6f], 最小平均dE = %.4f\n', ...
                    attribute, optimal_a(1), optimal_a(2), optimal_a(3), min_mean_dE);
        else
            fprintf('Attribute %d: 最优a值 = [%.6f, %.6f], 最小平均dE = %.4f\n', ...
                    attribute, optimal_a(1), optimal_a(2), min_mean_dE);
        end
        
        % 使用最优a值重新计算
        par = par_all4(:, :, 1, attribute);
        lab_fit = [average(:, 1), par(:, 4), par(:, 5)];
        lab_D65 = lab_fit(5, :);
        XYZ_bf = lab2xyz2(lab_fit, 'd65_64');

        for i_para=1:size(par, 1)
            if i_para<=7
                i_target=5;
            elseif i_para<=14
                i_target=12;
            else
                i_target=19;
            end
            Labtarget(i_para,:)=lab_fit(i_target,:);
            XYZw_target(i_para,:)=XYZw_mean(i_target,:)./XYZw_mean(i_target,2).*100;

            XYZw(i_para,:)=XYZw_mean(i_para,:)./XYZw_mean(i_para,2).*100;
            XYZw_used(i_para,:)=XYZw(i_para,:);

            % 使用最优a值计算D_pre - 根据选择使用两个或三个参数
            if useThreeParameters
                D_pre(i_para, 1)=optimal_a(1).*(1-optimal_a(2)./CT(i_para)).*optimal_a(3)*log(LA(i_para));
            else
                D_pre(i_para, 1)=optimal_a(1).*(1-optimal_a(2)./CT(i_para));
            end
            
            XYZt(i_para,:) = CAT16_D(XYZ_bf(i_para,:), ...
                XYZw_used(i_para,:), XYZw_target(i_para,:), D_pre(i_para,1));
            Labt(i_para,:) = xyz2lab(XYZt(i_para,:), 'd65_64');
            
        end

        dE = deltaE2000(Labt, Labtarget);
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
            scatter(Labt(i_para, 2), Labt(i_para, 3), 50, colors(mod((i_para-1),7)+1,:), 'filled');
            text(Labt(i_para,2), Labt(i_para,3), picname_group(i_para), ...
                'FontSize', 8, 'VerticalAlignment', 'middle', ...
                'Color', 'k');
        end
        
        % 绘制y=x线
        x = linspace(min(Labt(:,2))-5, max(Labt(:,2))+5, 100);
        plot(x, x, 'k--', 'LineWidth', 1);
        
        % 添加图例、标签和标题
        xlabel('{\ita*}', 'FontSize', 12);
        ylabel('{\itb*}', 'FontSize', 12);
        
        if useThreeParameters
            title(sprintf('%s %s a-b (优化后a=[%.4f, %.4f, %.4f], mean(dE)=%.4f)', ...
                obs_types_new(i_obstype), attribute_names(attribute), ...
                optimal_a(1), optimal_a(2), optimal_a(3), mean_dE), 'FontSize', 14);
        else
            title(sprintf('%s %s a-b (优化后a=[%.4f, %.4f], mean(dE)=%.4f)', ...
                obs_types_new(i_obstype), attribute_names(attribute), ...
                optimal_a(1), optimal_a(2), mean_dE), 'FontSize', 14);
        end
        
        % 设置坐标轴范围
        xlim([min(Labt(:,2))-5, max(Labt(:,2))+5]);
        ylim([min(Labt(:,3))-5, max(Labt(:,3))+5]);
        axis equal;      
        
        % 保存图像
        attribute_serial = strcat(sprintf("%02d", attribute), attribute_names(attribute));
        save_dir = fullfile(save_folder, 'a_b');
        if ~exist(save_dir, "dir")
            mkdir(save_dir);
        end
        
        if useThreeParameters
            img_name = sprintf('%s_a-b_optimized_a=%.4f_%.4f_%.4f.jpg', ...
                attribute_serial, optimal_a(1), optimal_a(2), optimal_a(3));
        else
            img_name = sprintf('%s_a-b_optimized_a=%.4f_%.4f.jpg', ...
                attribute_serial, optimal_a(1), optimal_a(2));
        end
        
        exportgraphics(gcf, fullfile(save_dir, img_name), 'Resolution', 300);
        close(gcf);           

        % 保存优化结果
        optimization_results.a = optimal_a;
        optimization_results.mean_dE = mean_dE;
        optimization_results.dE = dE;
        optimization_results.useThreeParameters = useThreeParameters;
        save(fullfile(save_folder, sprintf('optimization_results_attr_%d.mat', attribute)), 'optimization_results');
    end
    concatenate_images1(fullfile(save_folder, 'a_b') ,5);

end
%%
load(fullfile("optimizedD\backGroundGray\XYZ_gray.mat"),"xyz_gray");
E=mean(xyz_gray(1:7,2));

E_light=xyz_gray(:,2);
F=0.8;
omega=2*pi*(1-cos(pi/36));
S=0.0124; %164.07*75.57*(10^(-6))
LA=E_light./S.*omega;
tables = ["poly3", "cherry", "zhai", "summer","grace"];
hue_values = linspace(0, 1, length(tables) + 1);hue_values = hue_values(1:end-1); 
hsv_matrix = [hue_values', 0.8 * ones(length(tables), 1), 0.8 * ones(length(tables), 1)];
colors = hsv2rgb(hsv_matrix);
x=2000:10:9000;x=x';
figure(2);hold on;
for i_row=1:length(x)
    % 使用优化得到的参数计算D值
    if useThreeParameters
        D_zhai_adj(i_row,:) = optimal_a(1).*(1-optimal_a(2)./x(i_row,:)).*optimal_a(3)*log(LA(1));
    else
        D_zhai_adj(i_row,:) = optimal_a(1).*(1-optimal_a(2)./x(i_row,:));
    end
    
    D_cherry(i_row,:) = calculateD(x(i_row,:), 0, "cherry",E);
    D_zhai(i_row,:) = calculateD(x(i_row,:), 0, "zhai",E);
    D_summer(i_row,:) = calculateD(x(i_row,:), 0, "summer",E);
    D_grace(i_row,:) = calculateD(x(i_row,:), 0, "grace",E);
end


plot(x,D_zhai_adj,'Color',colors(1,:));
plot(x,D_cherry,'Color',colors(2,:));
plot(x,D_zhai,'Color',colors(3,:));
plot(x,D_summer,'Color',colors(4,:));
plot(x,D_grace,'Color',colors(5,:));
shapes={'p','s','o'};
hold on;


% 目标函数定义：计算给定a值时的平均色差
function mean_dE = calculate_mean_dE(a_val, par_all4, average, CT, XYZw_mean, LA, useThreeParameters)
    % 确保a_val包含足够的参数
    if useThreeParameters && length(a_val) < 3
        error('使用三个参数模型时，优化参数a需要包含三个值: a(1), a(2)和a(3)');
    elseif ~useThreeParameters && length(a_val) < 2
        error('使用两个参数模型时，优化参数a需要包含两个值: a(1)和a(2)');
    end
    
    par = par_all4(:, :, 1, 1); % 假设attribute=1
    lab_fit = [average(:, 1), par(:, 4), par(:, 5)];
    XYZ_bf = lab2xyz2(lab_fit, 'd65_64');
    
    num_samples = size(lab_fit,1);
    Labtarget = zeros(num_samples, 3);
    XYZw_target = zeros(num_samples, 3);
    XYZw = zeros(num_samples, 3);
    XYZw_used = zeros(num_samples, 3);
    D_pre = zeros(num_samples, 1);
    XYZt = zeros(num_samples, 3);
    Labt = zeros(num_samples, 3);
    
    % 计算每个样本的目标值和转换结果
    for i_para = 1:num_samples
        if i_para <= 7
            i_target = 5;
        elseif i_para <= 14
            i_target = 12;
        else
            i_target = 19;
        end
        
        Labtarget(i_para, :) = lab_fit(i_target, :);
        XYZw_target(i_para, :) = XYZw_mean(i_target, :) ./ XYZw_mean(i_target, 2) .* 100;
        XYZw_used(i_para, :) = XYZw_mean(i_para, :) ./ XYZw_mean(i_para, 2) .* 100;
       
        % 使用传入的参数计算D_pre
        if useThreeParameters
            D_pre(i_para, 1)=a_val(1).*(1-a_val(2)./CT(i_para)).*a_val(3)*log(LA(i_para));
        else
            D_pre(i_para, 1)=a_val(1).*(1-a_val(2)./CT(i_para));
        end
        
        % 执行色适应变换
        XYZt(i_para, :) = CAT16_D(XYZ_bf(i_para, :), ...
            XYZw_used(i_para, :), XYZw_target(i_para, :), D_pre(i_para, 1));
        
        % 转换回Lab色彩空间
        Labt(i_para, :) = xyz2lab(XYZt(i_para, :), 'd65_64');
    end
    
    % 计算色差
    dE = deltaE2000(Labt, Labtarget);
    dE_del=dE;
    dE_del([1,8,15])=[];
    
    % 返回平均色差
    mean_dE = mean(dE_del);
    % mean_dE = mean(dE);
end