clc;       % 清空命令窗口
clear;     % 清除工作区所有变量
addpath("utils\")
%% 定义所有需要处理的 attribute
attributes = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

attribute_names_new = ["Preference", "Attractiveness", "Feminine", "Cooperative", ...
    "Youth", "Healthy", "Fidelity", "Harmony", "Fair", "Ruddy"];
nations = ["AS", "CA", "SA", "AF"];

lastParts = {'f04i', 'f05i', 'f06i', 'm04i', 'm05i', 'm06i',...
'f01i', 'f02i', 'f03i', 'm01i', 'm02i', 'm03i',...
'f07i', 'f08i','m07i', 'm08i',...
'f09i', 'f10i','m09i', 'm10i'};
n_para = 21;
iOr='i';

% lastParts = {'f04r', 'f05r', 'f06r', 'm04r', 'm05r', 'm06r',...
% 'f01r', 'f02r', 'f03r', 'm01r', 'm02r', 'm03r',...
% 'f07r', 'f08r','m07r', 'm08r',...
% 'f09r', 'f10r','m09r', 'm10r'};
% n_para = 14;
% iOr='r';


load("documents\valid_attr.mat","map");


wd65 = [94.811, 100.00, 107.304];
datai_file = 'D:\work\VIVOskinExpe\renderCode\calibResults\datai_ipv18_3.mat';
LUT=load(datai_file);
XYZw_LUT=LUT.XYZw;
line_style = {'-',':','-.'};
plot_style_high = 'x'; % 用于 lab_group>0.5 的点
plot_style_low = 'o';  % 用于 lab_group<0.5 的点

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

file_missing={};
Dtype = 'efit_p';
scale_type_origin="unscaled";
scale_type="scaled";
scale_time="late"; % 设置为late，表示从已保存的文件中加载参数

if iOr=='i'
    picnames_groups = ["h3k","h4k","h5k","h6k","hd65","h7k","h8k",...
            "m3k","m4k","m5k","m6k","md65","m7k","m8k",...
             "l3k","l4k","l5k","l6k","ld65","l7k","l8k"];
elseif iOr=='r'
    picnames_groups = ["rs01","rs02","rs03","rs04","rs05","rs06","rs07", ...
             "rs08","rs09","rs10","rs11","rs12","rs13","rs14"];
end

if iOr=='i'
    target_indices{1}=5;
    target_indices{2}=12;
    target_indices{3}=19;
    target_indices{4}=[1,8,15];
    target_indices{5}=[2,9,16];
else
    target_indices{1}=[1,2,4,5];
    target_indices{2}=[7,8,9,10];
    target_indices{3}=[11,12];
    target_indices{4}=[13,14];
    target_indices{5}=[6];
end

%% 定义双高斯模型拟合函数
function [par, r] = double_gaussian_fit(lab_group, p_group)
    % 双高斯模型拟合函数
    % lab_group: lab数据点
    % p_group: 对应的评分值
    % 返回拟合参数par和相关系数r
    
    % 初始化双高斯模型参数
    % 第一个高斯分布参数: mu1_x, mu1_y, sigma1_x, sigma1_y, rho1, weight1
    % 第二个高斯分布参数: mu2_x, mu2_y, sigma2_x, sigma2_y, rho2, weight2
    % 总参数: a0, a1
    init_par = [mean(lab_group(:,2)), mean(lab_group(:,3)), 10, 10, 0, 0.5, ...
                mean(lab_group(:,2))+5, mean(lab_group(:,3))-5, 10, 10, 0, 0.5, ...
                0.5, 1];
    
    % 设置优化选项
    options = optimoptions('fminunc', 'Algorithm', 'quasi-newton', 'MaxIter', 1000);
    
    % 使用fminunc进行优化
    [par, ~] = fminunc(@(x) objective_function(x, lab_group, p_group), init_par, options);
    
    % 计算拟合值
    y_fit = double_gaussian_model(par, lab_group);
    
    % 计算相关系数
    r = corr(p_group, y_fit);
end

function y = double_gaussian_model(par, lab_group)
    % 双高斯模型
    % par: 模型参数
    % lab_group: lab数据点
    % 返回预测值y
    
    mu1_x = par(1);
    mu1_y = par(2);
    sigma1_x = exp(par(3)); % 使用指数确保正数
    sigma1_y = exp(par(4));
    rho1 = tanh(par(5));    % 使用tanh确保在-1到1之间
    weight1 = sigmoid(par(6)); % 使用sigmoid确保在0到1之间
    
    mu2_x = par(7);
    mu2_y = par(8);
    sigma2_x = exp(par(9));
    sigma2_y = exp(par(10));
    rho2 = tanh(par(11));
    weight2 = sigmoid(par(12));
    
    a0 = par(13);
    a1 = par(14);
    
    % 归一化权重
    weight1 = weight1 / (weight1 + weight2);
    weight2 = 1 - weight1;
    
    % 计算第一个高斯分布
    z1 = ((lab_group(:,2) - mu1_x).^2)/(sigma1_x^2) + ...
         ((lab_group(:,3) - mu1_y).^2)/(sigma1_y^2) - ...
         2*rho1*((lab_group(:,2) - mu1_x).*(lab_group(:,3) - mu1_y))/(sigma1_x*sigma1_y);
    gauss1 = exp(-z1/(2*(1 - rho1^2)));
    
    % 计算第二个高斯分布
    z2 = ((lab_group(:,2) - mu2_x).^2)/(sigma2_x^2) + ...
         ((lab_group(:,3) - mu2_y).^2)/(sigma2_y^2) - ...
         2*rho2*((lab_group(:,2) - mu2_x).*(lab_group(:,3) - mu2_y))/(sigma2_x*sigma2_y);
    gauss2 = exp(-z2/(2*(1 - rho2^2)));
    
    % 组合双高斯分布并应用sigmoid函数
    y = sigmoid(a0 + a1*(weight1*gauss1 + weight2*gauss2));
end

function y = objective_function(par, lab_group, p_group)
    % 目标函数：计算预测值与实际值之间的均方误差
    y_fit = double_gaussian_model(par, lab_group);
    y = mean((y_fit - p_group).^2);
end

function y = sigmoid(x)
    % Sigmoid函数
    y = 1 ./ (1 + exp(-x));
end

function plot_contour_with_scatter_styled_double_gaussian(par, lab_group, p_group, color, plot_style_high, plot_style_low)
    % 绘制等高线
    check_data2 = linspace(min(lab_group(:,2))-10, max(lab_group(:,2))+10, 100);
    check_data3 = linspace(min(lab_group(:,3))-10, max(lab_group(:,3))+10, 100);
    [data2, data3] = meshgrid(check_data2, check_data3);
    
    % 准备数据进行预测
    n_points = numel(data2);
    lab_grid = [ones(n_points,1), reshape(data2, n_points, 1), reshape(data3, n_points, 1)];
    
    % 计算预测值
    y = double_gaussian_model(par, lab_grid);
    y = reshape(y, size(data2));
    
    % 绘制等高线
    contour(data2, data3, y, [0.5, 1], 'Linewidth', 2, 'Color', color);
    hold on;

    % 根据 p_group 的值绘制不同样式的散点图
    idx_high = p_group > 0.5;
    idx_low = p_group <= 0.5;
    
    if any(idx_high)
        scatter(lab_group(idx_high, 2), lab_group(idx_high, 3), ...
            15, p_group(idx_high), 'filled', 'Marker', "o",'LineWidth',1);
        hold on;
    end
    
    if any(idx_low)
        scatter(lab_group(idx_low, 2), lab_group(idx_low, 3), ...
            10, p_group(idx_low),  'Marker', "o",'LineWidth',1);
        hold on;
    end

    % 绘制拟合中心点
    % 双高斯模型有两个中心点
    scatter(par(1), par(2), 30, 'filled', 'Marker', 'p', 'MarkerEdgeColor', 'r');
    scatter(par(7), par(8), 30, 'filled', 'Marker', 'p', 'MarkerEdgeColor', 'b');
    hold on;

    % 添加坐标轴和参考线
    lim_max = max(max(lab_group(:, 2)), max(lab_group(:, 3))) + 10;
    lim_min = min(min(lab_group(:, 2)), min(lab_group(:, 3))) - 10;
    line([0, 0], [lim_min, lim_max], 'Color', 'k', 'LineStyle', '--'); % x=0
    line([lim_min, lim_max], [0, 0], 'Color', 'k', 'LineStyle', '--'); % y=0
    refline(1, 0); % 45 度线

    % 设置图形属性
    axis equal;
    xlim([lim_min, lim_max]);
    ylim([lim_min, lim_max]);
    xlabel('{\ita*}');
    ylabel('{\itb*}');
    title('Double Gaussian Model Contour Plot with Scatter by Value');
    hold off;
end

%% 处理数据和绘图
obs_types = ["non_model"];
% obs_types = ["non_model", "model_group", "model"];

for i_obs = 1:length(obs_types)
    obs_type = obs_types(i_obs);
    
    % 为每个lastPart单独处理数据和绘图
    for i_subject = 17:20
    % for i_subject = 1:length(lastParts)
        lastPart = lastParts{i_subject};
        iOr = lastPart(end);
        
        % 获取当前subject所属的人种
        nation_idx = 0;
        for i_nation = 1:length(nations)
            if ismember(i_subject, nation_indices{i_nation})
                nation_idx = i_nation;
                nation = nations(i_nation);
                break;
            end
        end
        
        if nation_idx == 0
            continue; % 不属于任何已知人种，跳过
        end
        
        % 为当前subject创建目录
        subject_save_folder = fullfile("ellip_pic_p", Dtype,"50",scale_type, "lastPart_individual_double_gaussian", lastPart);
        if ~exist(subject_save_folder, "dir")
            mkdir(subject_save_folder);
        end
        
        % 加载白色平衡数据
        white_file = fullfile("optimizedD\whiteSquare\XYZw_white", ...
            strcat(lastPart, ".mat"));
        if exist(white_file, 'file')
            load(white_file,"XYZw_white");
        else
            XYZw_white = wd65; % 使用默认值
            file_missing{end+1,1} = lastPart;
            file_missing{end,2} = 'white_file';
        end
        
        % 循环处理每个 attribute
        for attribute = 1:length(attributes)
            attribute_serial = strcat(sprintf("%02d", attribute), attribute_names_new(attribute));
            
            % 定义源文件路径
            if attribute==7
                obs_type_used="model_group";
            else
                obs_type_used=obs_type;
            end
            
            % 循环处理每个参数
            for i_para = 1:n_para
                % 加载lab和score数据文件
                lab_source_file = fullfile('AnalyseResults_p', Dtype, scale_type_origin, lastPart, ...
                    obs_type_used, attribute_serial, 'labNscore', ...
                    strcat('labNscore_group', lastPart, picnames_groups{i_para}, '.mat'));
                
                % 检查文件是否存在
                if exist(lab_source_file, 'file')
                    % 加载lab和score数据
                    if attribute==1
                        load(lab_source_file, "lab_group", "p_group");
                    else
                        load(lab_source_file, "p_group");
                        % 对于非偏好属性，我们仍然需要lab数据，可能需要从其他地方获取
                        % 这里假设对于非偏好属性，我们使用平均肤色作为lab数据
                        average_file = fullfile("aveSkin", lastPart, "autoNhand_scaleoverLUT.mat");
                        if exist(average_file, 'file')
                            average_data = load(average_file);
                            lab_group = repmat(average_data.average_lab_all(i_para, :), size(p_group, 1), 1);
                        else
                            lab_group = NaN(size(p_group, 1), 3);
                        end
                    end
                    
                    % 过滤掉p_group中全是NaN的行
                    valid_rows = ~all(isnan(p_group), 2);  % 找出不全为NaN的行
                    p_group = p_group(valid_rows, :);     % 过滤p_group
                    lab_group = lab_group(valid_rows, :);     % 同步过滤lab_group
                    
                    % 检查数据有效性
                    if ~all(isnan(p_group(:)))
                        % 使用双高斯模型拟合
                        [par_dg, r_dg] = double_gaussian_fit(lab_group, p_group);
                        
                        % 设置颜色
                        hue_values = linspace(0, 1, length(nations) + 1);
                        hue_values = hue_values(1:end-1); 
                        hsv_matrix = [hue_values', 0.8 * ones(length(nations), 1), 0.8 * ones(length(nations), 1)];
                        colors = hsv2rgb(hsv_matrix);
                        color = colors(nation_idx, :);
                        
                        % 创建图形并绘制
                        figure;
                        plot_contour_with_scatter_styled_double_gaussian(par_dg, lab_group, p_group, color, plot_style_high, plot_style_low);
                        
                        % 保存图形
                        output_folder = fullfile(subject_save_folder, attribute_serial);
                        if ~exist(output_folder, "dir")
                            mkdir(output_folder);
                        end
                        saveas(gcf, fullfile(output_folder, strcat(picnames_groups{i_para}, ".jpg")));
                        
                        % 保存拟合结果
                        fitRes_folder = fullfile("AnalyseResults_p", Dtype, "50", scale_type_origin, "lastPart_individual_double_gaussian", scale_type, obs_type, iOr, attribute_serial, lastPart);
                        if ~exist(fitRes_folder, "dir")
                            mkdir(fitRes_folder);
                        end
                        
                        % 加载或计算平均肤色数据
                        average_file = fullfile("aveSkin", lastPart, "autoNhand_scaleoverLUT.mat");
                        if exist(average_file, 'file')
                            average_data = load(average_file);
                            average_cur = average_data.average_lab_all(i_para, :);
                        else
                            average_cur = NaN(1, 3);
                        end
                        
                        % 保存参数和平均肤色数据
                        save(fullfile(fitRes_folder, strcat(picnames_groups{i_para}, ".mat")), "par_dg", "r_dg", "average_cur");
                        close all;
                    end
                else
                    % 如果文件不存在，记录缺失的文件
                    file_missing{end+1,1} = lastPart;
                    file_missing{end,2} = obs_type;
                    file_missing{end,3} = attribute_serial;
                    file_missing{end,4} = picnames_groups{i_para};
                end
            end
        end
    end
    
    % 保存缺失文件的信息
    if ~isempty(file_missing)
        save(fullfile("ellip_pic_p", Dtype, "50", scale_type, "lastPart_individual_double_gaussian", strcat("file_missing_", iOr, ".mat")), "file_missing");
    end
end

fprintf('所有 lastPart 单独绘图已完成！\n');