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

%% 定义改进版的 plot_contour_with_scatter 函数
function plot_contour_with_scatter_styled(par, lab_group, MSV_group, color, plot_style_high, plot_style_low)
    % 绘制等高线
    check_data2 = par(4) + (-30:0.2:30);
    check_data3 = par(5) + (-30:0.2:30);
    [data2, data3] = meshgrid(check_data2, check_data3);

    a = par;
    y = (1./(1 + a(6) * exp(sqrt(a(1) * (data2 - a(4)).^2 + a(2) * (data3 - a(5)).^2 + ...
        a(3) * (data2 - a(4)) .* (data3 - a(5)))))) .* ((a(1) * (data2 - a(4)).^2 + ...
        a(2) * (data3 - a(5)).^2 + a(3) * (data2 - a(4)) .* (data3 - a(5))) >= 0);

    % 绘制等高线
    contour(data2, data3, y, [0.5, 1], 'Linewidth', 2, 'Color', color);
    hold on;

    % 根据 MSV_group 的值绘制不同样式的散点图
    idx_high = MSV_group > 0.5;
    idx_low = MSV_group <= 0.5;
    
    if any(idx_high)
        scatter(lab_group(idx_high, 2), lab_group(idx_high, 3), ...
            15, MSV_group(idx_high), 'filled', 'Marker', "o",'LineWidth',1);
        hold on;
    end
    
    if any(idx_low)
        % scatter(lab_group(idx_low, 2), lab_group(idx_low, 3), ...
        %     10, MSV_group(idx_low),  'Marker', "+",'LineWidth',2);
        scatter(lab_group(idx_low, 2), lab_group(idx_low, 3), ...
            10, MSV_group(idx_low),  'Marker', "o",'LineWidth',1);
        hold on;
    end

    % 绘制拟合中心点
    scatter(par(4), par(5), 30, 'filled', 'Marker', 'p', 'MarkerEdgeColor', 'k');
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
    title('Contour Plot with Scatter by Value');
    hold off;
end

%% 处理数据和绘图
obs_types = ["non_model"];
% obs_types = ["non_model", "model_group", "model"];

for i_obs = 1:length(obs_types)
    obs_type = obs_types(i_obs);
    
    % 为每个lastPart单独处理数据和绘图
    % for i_subject = 1:length(lastParts)
    for i_subject = 17:20
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
        subject_save_folder = fullfile("ellip_pic_p", Dtype,"50",scale_type, "lastPart_individual", lastPart);
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
                % 加载已保存的参数文件
                if strcmp(scale_time,"early")
                    source_file = fullfile('AnalyseResults_p', Dtype, scale_type_origin, "scaled", lastPart, ...
                        obs_type_used, attribute_serial, 'ellipPara', strcat( 'fitRes.mat'));
                else
                    source_file = fullfile('AnalyseResults_p', Dtype, scale_type_origin, lastPart, ...
                        obs_type_used, attribute_serial, 'ellipPara', strcat( 'fitRes.mat'));
                end
                
                % 加载lab和score数据文件
                lab_source_file = fullfile('AnalyseResults_p', Dtype, scale_type_origin, lastPart, ...
                    obs_type_used, attribute_serial, 'labNscore', ...
                    strcat('labNscore_group', lastPart, picnames_groups{i_para}, '.mat'));
                
                % 检查文件是否存在
                if exist(source_file, 'file') && exist(lab_source_file, 'file')
                    % 加载参数
                    par_data = load(source_file);
                    par = par_data.par_all(i_para,:);
                    
                    % 加载lab和score数据
                    if attribute==1
                        load(lab_source_file, "lab_group", "p_group");
                    else
                        load(lab_source_file, "p_group");
                        % 对于非偏好属性，我们仍然需要lab数据，可能需要从其他地方获取
                        % 这里假设对于非偏好属性，我们使用平均肤色作为lab数据
                    end
                    average_file = fullfile("aveSkin", lastPart, "autoNhand_scaleoverLUT.mat");
                    if exist(average_file, 'file')
                        average_data = load(average_file);

                    end
                    % 根据scale_type和scale_time进行缩放处理
                    % if strcmp(scale_type,"scaled") && strcmp(scale_time,"late")
                    %     % 对lab_group进行缩放
                    %     xyz_fit = lab2xyz2(lab_group, "user", wd65./wd65(2).*XYZw_LUT(2));
                    %     lab_group = xyz2lab(xyz_fit, "user", wd65./wd65(2).*XYZw_white(i_para,2));
                    % 
                    %     % 对par中的中心坐标进行缩放
                    %     lab_bf = [average_data.average_lab_all(i_para, 1), par(4:5)];
                    %     xyz_fit_par = lab2xyz2(lab_bf, "user", wd65./wd65(2).*XYZw_LUT(2));
                    %     lab_scaled_par = xyz2lab(xyz_fit_par, "user", wd65./wd65(2).*XYZw_white(i_para,2));
                    %     par(4:5) = lab_scaled_par(2:3);
                    % end
                    
                    % 过滤掉MSV_group中全是NaN的行
                    valid_rows = ~all(isnan(p_group), 2);  % 找出不全为NaN的行
                    p_group = p_group(valid_rows, :);     % 过滤p_group
                    lab_group = lab_group(valid_rows, :);     % 同步过滤lab_group
                    
                    % 检查数据有效性
                    if ~all(isnan(p_group(:)))
                        % 设置颜色
                        hue_values = linspace(0, 1, length(nations) + 1);
                        hue_values = hue_values(1:end-1); 
                        hsv_matrix = [hue_values', 0.8 * ones(length(nations), 1), 0.8 * ones(length(nations), 1)];
                        colors = hsv2rgb(hsv_matrix);
                        color = colors(nation_idx, :);
                        
                        % 创建图形并绘制
                        figure;
                        plot_contour_with_scatter_styled(par, lab_group, p_group, color, plot_style_high, plot_style_low);
                        
                        % 保存图形
                        output_folder = fullfile(subject_save_folder, attribute_serial);
                        if ~exist(output_folder, "dir")
                            mkdir(output_folder);
                        end
                        saveas(gcf, fullfile(output_folder, strcat(picnames_groups{i_para}, ".jpg")));
                        
                        % 保存拟合结果（如果需要）
                        fitRes_folder = fullfile("AnalyseResults_p", Dtype, "50", scale_type_origin, "lastPart_individual", scale_type, obs_type, iOr, attribute_serial, lastPart);
                        if ~exist(fitRes_folder, "dir")
                            mkdir(fitRes_folder);
                        end
                        
                        % 加载或计算平均肤色数据
                        average_file = fullfile("aveSkin", lastPart, "autoNhand_scaleoverLUT.mat");
                        if exist(average_file, 'file')
                            average_data = load(average_file);
                            if strcmp(scale_type,"scaled") && strcmp(scale_time,"late")
                                xyz_ave = lab2xyz2(average_data.average_lab_all(i_para,:), "user", wd65./wd65(2).*XYZw_LUT(2));
                                average_cur = xyz2lab(xyz_ave, "user", wd65./wd65(2).*XYZw_white(i_para,2));
                            else
                                average_cur = average_data.average_lab_all(i_para, :);
                            end
                        else
                            average_cur = NaN(1, 3);
                        end
                        
                        % 保存参数和平均肤色数据
                        save(fullfile(fitRes_folder, strcat(picnames_groups{i_para}, ".mat")), "par", "average_cur");
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

            concatenate_images1(output_folder,7);
        end
    end
    
    % 保存缺失文件的信息
    if ~isempty(file_missing)
        save(fullfile("ellip_pic_p", Dtype, "50", scale_type, "lastPart_individual", strcat("file_missing_", iOr, ".mat")), "file_missing");
    end
end

fprintf('所有 lastPart 单独绘图已完成！\n');
%%
output_folder="D:\work\VIVOskinExpe\analyze\ellip_pic_p\" + ...
    "efit_p\50\scaled\lastPart_individual\m10i\01Preference";
concatenate_images1(output_folder,7);