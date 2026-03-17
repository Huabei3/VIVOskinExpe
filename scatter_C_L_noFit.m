close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量

%% 定义所有需要处理的 attribute
attributes = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
attribute_names_new = ["Preference", "Attractiveness", "Feminine", "Cooperative", ...
    "Youth", "Healthy", "Fidelity", "Harmony", "Fair", "Ruddy"];
nations = ["AS", "CA", "SA", "AF"];
lastParts = {'f04i', 'f05i', 'f06i', 'm04i', 'm05i', 'm06i',...
'f01i', 'f02i', 'f03i', 'm01i', 'm02i', 'm03i',...
'f07i', 'f08i','m07i', 'm08i',...
'f09i', 'f10i','m09i', 'm10i'};n_para = 21;iOr='i';
% lastParts = {'f04r', 'f05r', 'f06r', 'm04r', 'm05r', 'm06r',...
% 'f01r', 'f02r', 'f03r', 'm01r', 'm02r', 'm03r',...
% 'f07r', 'f08r','m07r', 'm08r',...
% 'f09r', 'f10r','m09r', 'm10r'};n_para = 14;iOr='r';

if iOr == 'i'
    indices_target = [5, 12, 19];
else
    indices_target = 1:14;
end

load("documents\valid_attr.mat","map");
wd65 = [94.811, 100.00, 107.304];
datai_file = 'D:\work\VIVOskinExpe\renderCode\calibResults\datai_ipv18_3.mat';
LUT=load(datai_file);
XYZw_LUT=LUT.XYZw;

% 定义线条样式和散点样式（根据i_obs索引选择）
line_styles = {'-', '--', ':', '-.'};  % 为不同i_obs设置不同线条样式
plot_styles = {'o', '+', 'd', '^'};    % 为不同i_obs设置不同散点样式
genders = ["f", "m"]; % 定义性别数组

% 生成色相值（H），范围从0到1
hue_values = linspace(0, 1, length(nations) + 1);hue_values = hue_values(1:end-1); 
hsv_matrix = [hue_values', 0.8 * ones(length(nations), 1), 0.8 * ones(length(nations), 1)];
colors = hsv2rgb(hsv_matrix);

obs_types = ["non_model", "model_group", "model"]; % 初始定义所有观察者类型

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

% 初始化重塑后的数据结构
average_reshaped = cell(5, 1); % 5个人种
par_reshaped = cell(3, 5, 1);  % 3种观察者类型 × 5个人种
lab_fit_reshaped = cell(3, 5, 1); % 3种观察者类型 × 5个人种
labCh_PMCC=[[62.11	18.96	19.76	27.39	46.18];...
            [64.15	19.56	19.63	27.71	45.10];...
            [56.01	18.25	18.72	26.14	45.72];...
            [41.06	17.37	17.94	24.97	45.93]];
labCh_PMCC(end+1,:)=mean(labCh_PMCC,1);
file_missing={};
Dtype = 'efit2';

%%
output_folder_base = fullfile("ellip_pic", Dtype);
% 仅当iOr为'i'时加载'r'数据
r_data_loaded = []; % 初始化为空
if iOr == 'i'
    r_data_file_path = fullfile(output_folder_base, strcat("data_unscaled_reshaped_r.mat"));
    if exist(r_data_file_path, 'file')
        r_data_loaded = load(r_data_file_path, ...
            "par_mean", "average_mean", ...
            "lab_fit_reshaped", "file_missing", "par_reshaped", "average_reshaped");
    else
        warning('Warning: data_unscaled_reshaped_r.mat not found for iOr=''i''. ''r'' data will not be plotted or analyzed.');
    end
end

%% 直接按重塑后的结构加载和存储数据
for i_obs = 1:length(obs_types)
    obs_type = obs_types(i_obs);    
    

    for i_attr = 1:length(attributes)
        figure(i_attr);hold on;
        attribute = attributes(i_attr);
        attribute_serial = strcat(sprintf("%02d", attribute), attribute_names_new(attribute));
        
        file_C_Lpara_i=fullfile("ellip_pic\efit2\C_L\i",obs_type, ...
            strcat(attribute_serial,"_curve_params.mat"));
        data_C_Lpara_i=load(file_C_Lpara_i);
        a_i=data_C_Lpara_i.a_CL_all;

        file_C_Lpara_r=fullfile("ellip_pic\efit2\C_L\r",obs_type, ...
            strcat(attribute_serial,"_curve_params.mat"));
        data_C_Lpara_r=load(file_C_Lpara_r);        
        a_r=data_C_Lpara_r.a_CL_all;

        if attribute==7
            i_obs_used=2; % For attribute 7, use model_group observer type
        else
            i_obs_used=i_obs; % Otherwise, use the current observer type
        end



        for i_nation = 1:length(nations)
            % 获取当前人种的所有索引
            nation=nations(i_nation);
            curr_nation_indices = nation_indices{i_nation};

            lab_data_r = r_data_loaded.lab_fit_reshaped{i_obs_used, i_nation}(1:14, :, :, attribute);
            [n_targets_r, ~, n_subjects_r] = size(lab_data_r);
            lab_g_r = reshape(permute(lab_data_r, [1 3 2]), n_targets_r * n_subjects_r, 3);
            valid_rows_r = ~any(isnan(lab_g_r), 2);
            lab_g_valid_r = lab_g_r(valid_rows_r, :);

            L_r = lab_g_valid_r(:, 1);
            C_r = sqrt(lab_g_valid_r(:, 2).^2 + lab_g_valid_r(:, 3).^2);
            valid_indices_r = ~isnan(L_r) & ~isnan(C_r) & L_r > 0;
            L_valid_r = L_r(valid_indices_r);
            C_valid_r = C_r(valid_indices_r);

            x = 10:0.1:70;
            y_i = a_i(i_nation,1)*log(x)+a_i(i_nation,2);
            y_i=y_i';
            plot(y_i, x, 'Color',colors(i_nation,:), 'LineWidth', 1);
            y_r = a_r(i_nation,1)*log(x)+a_r(i_nation,2);
            y_r=y_r';
            plot(y_r, x, 'Color', colors(i_nation,:), 'LineWidth', 1, 'LineStyle', ':');

            scatter(C_valid_r, L_valid_r, 8, colors(i_nation, :), 'o', 'filled', 'MarkerFaceAlpha', 0.6); 
            % corr_iNi(i_nation,i_attr)=corr(C_valid_i,y_i);
            corr_iNr(i_nation,i_attr)=corr(C_valid_r,y_i);
            corr_rNr(i_nation,i_attr)=corr(C_valid_r,y_r);

            y_from_i_fit_for_r_data = f(afinal_i, L_valid_r);
            
            % 计算r数据散点与i拟合曲线的相关性
            r_val_r_vs_i = corr(y_from_i_fit_for_r_data, C_valid_r);
            r_CL_all_r_vs_i(i_nation) = r_val_r_vs_i;
            
            % 计算RMSE
            rmse_val_r_vs_i = sqrt(mean((C_valid_r - y_from_i_fit_for_r_data).^2))./mean(C_valid_r,1,"omitnan");
            RMSE_CL_all_r_vs_i(i_nation) = rmse_val_r_vs_i;
        end

        % 设置图表属性
        ylabel('L^*', 'FontSize', 12, 'FontAngle', 'italic');
        xlabel('C^*', 'FontSize', 12, 'FontAngle', 'italic');
        title(attribute_names_new(i_attr), 'FontSize', 14); 
        grid on;
        
        % 设置坐标轴范围和刻度间隔
        axis equal; % 保持坐标轴比例一致
        interval = 10;  
        xticks(0:interval:35);
        yticks(0:interval:80);
        ylim([0, 80]);
        xlim([0, 35]);

        output_folder_curves = fullfile(output_folder_base, 'C_L_contra', obs_type,iOr, 'curve_fit');
        if ~exist(output_folder_curves, 'dir')
            mkdir(output_folder_curves);
        end
        exportgraphics(gcf, fullfile(output_folder_curves, strcat(attribute_serial, '.jpg')), 'Resolution', 300);
    end
end % end for i_obs