% 主脚本开始 - 按人种划分验证集和拟合集
close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量
addpath("utils\")
%% 定义所有需要处理的 attribute
attributes = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
attribute_names_new = ["Preference", "Attractiveness", "Feminine", "Cooperative", ...
    "Youth", "Healthy", "Fidelity", "Harmony", "Fair", "Ruddy"];

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
CT_type="d65";
fit_type="new1";
% fit_type="new";
if iOr == 'i'
    if strcmp(CT_type,"3k")
        indices_target = [1, 8, 15];
    elseif strcmp(CT_type,"4k")
        indices_target = [2, 9, 19];
    elseif strcmp(CT_type,"d65")
        indices_target = [5, 12, 19];
    end

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

obs_types = ["non_model", "model_group", "model"];
% 定义人种对应的lastParts索引
enable_plotting = false; % true=正常出图, false=只算数据不出图
max_classify=0;
if max_classify==1
    nations = ["AS", "CA", "DA", "all"];
    nation_indices = cell(5, 1); % 5个人种（包括"all"）
    % AS (Asian): f04i, f05i, f06i, m04i, m05i, m06i (索引1-6)
    nation_indices{1} = 1:6;
    % CA (Caucasian): f01i, f02i, f03i, m01i, m02i, m03i (索引7-12)  
    nation_indices{2} = 7:12;
    % DA (South Asian & African): f07i, f08i, m07i, m08i (索引13-20)
    nation_indices{3} = 13:20;
    % all: 所有索引 (索引1-20)
    nation_indices{4} = 1:20;
    label_type="nation_max";
else
    nations = ["AS", "CA", "SA", "AF","all"];
    nation_indices = cell(5, 1); % 5个人种（包括"all"）
    nation_indices{1} = 1:6;      % AS: f04i, f05i, f06i, m04i, m05i, m06i
    nation_indices{2} = 7:12;     % CA: f01i, f02i, f03i, m01i, m02i, m03i
    nation_indices{3} = 13:16;    % SA: f07i, f08i, m07i, m08i
    nation_indices{4} = 17:20;    % AF: f09i, f10i, m09i, m10i
    nation_indices{5} = 1:20;     % all
    label_type="nation";
end

% 定义验证模特：每个人种取一个模特用于验证
% m02(CA), m05(AS), m08(SA), m09(AF)
validation_subjects = cell(length(nations), 1);
% AS (Asian): 索引5 对应 m05i
validation_subjects{1} = 5;  % m05i
% CA (Caucasian): 索引11 对应 m02i
validation_subjects{2} = 11;  % m02i
% SA (South Asian): 索引16 对应 m08i
validation_subjects{3} = 16;  % m08i
% AF (African): 索引19 对应 m09i
validation_subjects{4} = 19;  % m09i
% all: 使用全部验证模特
validation_subjects{5} = [5, 11, 16, 19];  % m05i, m02i, m08i, m09i

% 计算每个人种的拟合集索引（排除验证模特）
fit_indices = cell(length(nations), 1);
for i_nation = 1:length(nations)
    curr_nation_indices = nation_indices{i_nation};
    val_indices = validation_subjects{i_nation};
    % 确保验证索引在这个nation的范围内
    val_in_nation = val_indices(ismember(val_indices, curr_nation_indices));
    fit_indices{i_nation} = setdiff(curr_nation_indices, val_in_nation);
end

% 生成色相值（H），范围从0到1
hue_values = linspace(0, 1, length(nations) + 1);
hue_values = hue_values(1:end-1);
% 为验证集和拟合集创建不同的颜色
colors_val = cell(length(nations), 1);
colors_fit = cell(length(nations), 1);
for i_nation = 1:length(nations)
    % 验证集使用实心圆
    hsv_val = [hue_values(i_nation), 0.9, 0.9];
    colors_val{i_nation} = hsv2rgb(hsv_val);
    % 拟合集使用空心形状
    hsv_fit = [hue_values(i_nation), 0.6, 0.7];
    colors_fit{i_nation} = hsv2rgb(hsv_fit);
end

% 初始化重塑后的数据结构
average_reshaped_val = cell(length(nations), 1);
average_reshaped_fit = cell(length(nations), 1);
par_reshaped_val = cell(3, length(nations), 1);  % 3种观察者类型 × 5个人种 × 验证集
par_reshaped_fit = cell(3, length(nations), 1);  % 3种观察者类型 × 5个人种 × 拟合集
lab_fit_reshaped_val = cell(3, length(nations), 1);
lab_fit_reshaped_fit = cell(3, length(nations), 1);
labCh_PMCC=[[62.11	18.96	19.76	27.39	46.18];...
            [64.15	19.56	19.63	27.71	45.10];...
            [56.01	18.25	18.72	26.14	45.72];...
            [41.06	17.37	17.94	24.97	45.93]];
labCh_PMCC(end+1,:)=mean(labCh_PMCC,1);
file_missing={};
Dtype = 'efit_p';
% Dtype = 'noCAT';
scale_type_origin="unscaled";

pic_folder = fullfile('ellip_pic_p', Dtype, "fullpara",CT_type,fit_type);
if ~exist(pic_folder, 'dir')
    mkdir(pic_folder);
end
fullfile(pwd,pic_folder)


% 定义一个函数来分离性别索引
function gender_indices = separate_genders(n_subjects, curr_nation_indices, lastParts)
    gender_indices = cell(2, 1); % f和m的索引
    for i_subject = 1:n_subjects
        subject_idx = curr_nation_indices(i_subject);
        lastPart = lastParts{subject_idx};
        if lastPart(1) == 'f'
            gender_indices{1} = [gender_indices{1}, i_subject];
        elseif lastPart(1) == 'm'
            gender_indices{2} = [gender_indices{2}, i_subject];
        end
    end
end

%% 直接按重塑后的结构加载和存储数据，分别处理验证集和拟合集
for i_obs = 1:length(obs_types)
    obs_type = obs_types(i_obs);
    for i_nation = 1:length(nations)
        nation = nations(i_nation);
        
        % 处理验证集
        curr_val_indices = validation_subjects{i_nation};
        % 确保索引在当前nation范围内
        curr_val_indices = curr_val_indices(ismember(curr_val_indices, nation_indices{i_nation}));
        n_subjects_val = length(curr_val_indices);
        par_current_val = zeros(n_para, 6, n_subjects_val, length(attributes));
        lab_fit_current_val = zeros(n_para, 3, n_subjects_val, length(attributes));
        average_current_val = zeros(n_para, 3, n_subjects_val);
        
        % 处理拟合集
        curr_fit_indices = fit_indices{i_nation};
        n_subjects_fit = length(curr_fit_indices);
        par_current_fit = zeros(n_para, 6, n_subjects_fit, length(attributes));
        lab_fit_current_fit = zeros(n_para, 3, n_subjects_fit, length(attributes));
        average_current_fit = zeros(n_para, 3, n_subjects_fit);
        
        % 为验证集的每个subject加载数据
        for i_subject = 1:n_subjects_val
            subject_idx = curr_val_indices(i_subject);
            lastPart = lastParts{subject_idx};
            iOr = lastPart(end);
            % 加载平均肤色数据
            average_file = fullfile("aveSkin", lastPart, "autoNhand_scaleoverLUT.mat");
            if exist(average_file, 'file')
                average_data = load(average_file);
                average_current_val(:, :, i_subject) = average_data.average_lab_all(:, 1:3);
            else
                average_current_val(:, :, i_subject) = NaN(n_para, 3);
            end
            white_file = fullfile("optimizedD\whiteSquare\XYZw_white", ...
                strcat(lastPart, ".mat"));
            load(white_file,"XYZw_white");
            % 循环处理每个 attribute
            for i_attr = 1:length(attributes)
                attribute = attributes(i_attr);
                attribute_serial = strcat(sprintf("%02d", attribute), attribute_names_new(attribute));
                % 定义路径
                source_file = fullfile('AnalyseResults_p', Dtype,scale_type_origin, ...
                    lastPart, obs_type, attribute_serial, 'ellipPara', 'fitRes.mat');
                % 加载数据
                if exist(source_file, 'file')
                    par_all_data = load(source_file);
                    par_all = par_all_data.par_all;
                    par_all=[par_all;nan(size(par_current_val,1)-size(par_all,1),size(par_all,2))];
                    par_current_val(:, :, i_subject, i_attr) = par_all;
                    lab_bf=[average_current_val(:, 1, i_subject), par_all(:,4:5)];
                    lab_fit_current_val(:, :, i_subject, i_attr) = lab_bf;
                else
                    par_current_val(:, :, i_subject, i_attr) = NaN(n_para, 6);
                    lab_fit_current_val(:, :, i_subject, i_attr) = NaN(n_para, 3);
                    file_missing{end+1,1}=lastPart;
                    file_missing{end,2}=obs_type;
                    file_missing{end,3}=attribute_serial;
                end
            end
        end
        
        % 为拟合集的每个subject加载数据
        for i_subject = 1:n_subjects_fit
            subject_idx = curr_fit_indices(i_subject);
            lastPart = lastParts{subject_idx};
            iOr = lastPart(end);
            % 加载平均肤色数据
            average_file = fullfile("aveSkin", lastPart, "autoNhand_scaleoverLUT.mat");
            if exist(average_file, 'file')
                average_data = load(average_file);
                average_current_fit(:, :, i_subject) = average_data.average_lab_all(:, 1:3);
            else
                average_current_fit(:, :, i_subject) = NaN(n_para, 3);
            end
            white_file = fullfile("optimizedD\whiteSquare\XYZw_white", ...
                strcat(lastPart, ".mat"));
            load(white_file,"XYZw_white");
            % 循环处理每个 attribute
            for i_attr = 1:length(attributes)
                attribute = attributes(i_attr);
                attribute_serial = strcat(sprintf("%02d", attribute), attribute_names_new(attribute));
                % 定义路径
                source_file = fullfile('AnalyseResults_p', Dtype,scale_type_origin, ...
                    lastPart, obs_type, attribute_serial, 'ellipPara', 'fitRes.mat');
                % 加载数据
                if exist(source_file, 'file')
                    par_all_data = load(source_file);
                    par_all = par_all_data.par_all;
                    par_all=[par_all;nan(size(par_current_fit,1)-size(par_all,1),size(par_all,2))];
                    par_current_fit(:, :, i_subject, i_attr) = par_all;
                    lab_bf=[average_current_fit(:, 1, i_subject), par_all(:,4:5)];
                    lab_fit_current_fit(:, :, i_subject, i_attr) = lab_bf;
                else
                    par_current_fit(:, :, i_subject, i_attr) = NaN(n_para, 6);
                    lab_fit_current_fit(:, :, i_subject, i_attr) = NaN(n_para, 3);
                    file_missing{end+1,1}=lastPart;
                    file_missing{end,2}=obs_type;
                    file_missing{end,3}=attribute_serial;
                end
            end
        end
        
        % 存储到重塑后的数据结构中
        par_reshaped_val{i_obs, i_nation} = par_current_val;
        par_reshaped_fit{i_obs, i_nation} = par_current_fit;
        lab_fit_reshaped_val{i_obs, i_nation} = lab_fit_current_val;
        lab_fit_reshaped_fit{i_obs, i_nation} = lab_fit_current_fit;
        
        % average_reshaped只需要存储一次（不依赖于观察者类型）
        if i_obs == 1
            average_reshaped_val{i_nation} = average_current_val;
            average_reshaped_fit{i_nation} = average_current_fit;
        end
        
        % 计算平均值
        average_mean_val{i_obs, i_nation} = nanmean(average_reshaped_val{i_nation}, 3);
        average_mean_fit{i_obs, i_nation} = nanmean(average_reshaped_fit{i_nation}, 3);
        par_mean_val{i_obs, i_nation} = nanmean(par_reshaped_val{i_obs, i_nation}, 3);
        par_mean_fit{i_obs, i_nation} = nanmean(par_reshaped_fit{i_obs, i_nation}, 3);
        
        average_nation_temp_val(i_nation,:) = mean(average_mean_val{i_obs, i_nation}(indices_target,:));
        average_nation_temp_fit(i_nation,:) = mean(average_mean_fit{i_obs, i_nation}(indices_target,:));
    end
    average_nations_val{i_obs} = average_nation_temp_val;
    average_nations_fit{i_obs} = average_nation_temp_fit;
end

%% 保存
output_folder = fullfile("ellip_pic_p", Dtype, CT_type, "devide_validation");
if ~exist(output_folder, "dir")
    mkdir(output_folder);
end
save(fullfile(output_folder, strcat("data_unscaled_reshaped_", iOr, "_devide.mat")), ...
    "par_mean_val", "par_mean_fit", "average_mean_val", "average_mean_fit", ...
    "lab_fit_reshaped_val", "lab_fit_reshaped_fit", "file_missing", ...
    "par_reshaped_val", "par_reshaped_fit", "average_reshaped_val", "average_reshaped_fit", ...
    "validation_subjects", "fit_indices", "nation_indices");

%% 为每个观察者类型、人种和属性分别处理数据（按人种分组拟合，使用拟合集，验证集用于验证）
obs_types = ["non_model"]; % 恢复所有观察者类型
% obs_types = ["non_model", "model_group"]; % 恢复所有观察者类型
dE = {};

% 遍历观察者类型
for i_obs = 1:length(obs_types)
    obs_type = obs_types(i_obs);
    r_excel_output_folder = fullfile("AnalyseResults_p", Dtype, scale_type_origin, "model_fullpara", CT_type, "new", iOr, obs_type, "devide_validation");
    if ~exist(r_excel_output_folder, 'dir')
        mkdir(r_excel_output_folder);
    end

    % 用于存储当前 obs_type 下所有 attribute 的 r 和 rmse 值，以便写入 Excel
    % 验证集和拟合集分开存储
    n_n = length(nations);
    
    % 拟合集的拟合参数
    r_values_for_excel_C_L_fit = zeros(length(attributes), n_n);
    rmse_values_for_excel_C_L_fit = zeros(length(attributes), n_n);
    r_values_for_excel_long_axis_fit = zeros(length(attributes), n_n);
    rmse_values_for_excel_long_axis_fit = zeros(length(attributes), n_n);
    r_values_for_excel_short_axis_fit = zeros(length(attributes), n_n);
    rmse_values_for_excel_short_axis_fit = zeros(length(attributes), n_n);
    r_values_for_excel_hue_angle_fit = zeros(length(attributes), n_n);
    rmse_values_for_excel_hue_angle_fit = zeros(length(attributes), n_n);
    r_values_for_excel_theta_fit = zeros(length(attributes), n_n);
    rmse_values_for_excel_theta_fit = zeros(length(attributes), n_n);
    r_values_for_excel_alpha_fit = zeros(length(attributes), n_n);
    rmse_values_for_excel_alpha_fit = zeros(length(attributes), n_n);
    
    % 验证集的验证误差
    r_values_for_excel_C_L_val = zeros(length(attributes), n_n);
    rmse_values_for_excel_C_L_val = zeros(length(attributes), n_n);
    r_values_for_excel_long_axis_val = zeros(length(attributes), n_n);
    rmse_values_for_excel_long_axis_val = zeros(length(attributes), n_n);
    r_values_for_excel_short_axis_val = zeros(length(attributes), n_n);
    rmse_values_for_excel_short_axis_val = zeros(length(attributes), n_n);
    r_values_for_excel_hue_angle_val = zeros(length(attributes), n_n);
    rmse_values_for_excel_hue_angle_val = zeros(length(attributes), n_n);
    r_values_for_excel_theta_val = zeros(length(attributes), n_n);
    rmse_values_for_excel_theta_val = zeros(length(attributes), n_n);
    r_values_for_excel_alpha_val = zeros(length(attributes), n_n);
    rmse_values_for_excel_alpha_val = zeros(length(attributes), n_n);
    
    % ===== 回退记录：记录 (nation, attribute, 原因) =====
    fallback_records = {};
    
    % 确保线条样式和散点样式索引在有效范围内
    line_style_idx = min(i_obs, length(line_styles));
    plot_style_idx = min(i_obs, length(plot_styles));
    
    % 遍历属性
    for idx_attribute = 1:length(attributes) % 使用新的索引来遍历 attributes 数组
        attribute = attributes(idx_attribute);
        attribute_serial = strcat(sprintf("%02d", attribute), attribute_names_new(attribute));
        % 假设此函数已定义
        attribute_serial = gen_attribute_new(attribute_serial);
        
        % 初始化拟合参数存储（列数根据 nation 数量动态确定）
        n_n = length(nations);
        
        % 拟合集的拟合参数
        a_CL_all_fit = zeros(n_n, 2);
        r_CL_all_fit = zeros(n_n, 1);
        rmse_CL_all_fit = zeros(n_n, 1);
        a_long_axis_all_fit = zeros(n_n, 4);
        r_long_axis_all_fit = zeros(n_n, 1);
        rmse_long_axis_all_fit = zeros(n_n, 1);
        a_short_axis_all_fit = zeros(n_n, 4);
        r_short_axis_all_fit = zeros(n_n, 1);
        rmse_short_axis_all_fit = zeros(n_n, 1);
        a_hue_angle_all_fit = zeros(n_n, 2);
        r_hue_angle_all_fit = zeros(n_n, 1);
        rmse_hue_angle_all_fit = zeros(n_n, 1);
        a_theta_all_fit = zeros(n_n, 2);
        r_theta_all_fit = zeros(n_n, 1);
        rmse_theta_all_fit = zeros(n_n, 1);
        a_alpha_all_fit = zeros(n_n, 2);
        r_alpha_all_fit = zeros(n_n, 1);
        rmse_alpha_all_fit = zeros(n_n, 1);
        
        % 按人种分组处理
        for i_nation = 1:length(nations)
            nation = nations(i_nation);
            
            if attribute == 7
                i_obs_used = 2;
            else
                i_obs_used = i_obs;
            end
            
            % ===== 处理拟合集数据 =====
            lab_data_fit = lab_fit_reshaped_fit{i_obs_used, i_nation}(indices_target, :, :, attribute);
            par_data_fit = par_reshaped_fit{i_obs_used, i_nation}(indices_target, :, :, attribute);
            [n_targets_fit, n_channels_lab_fit, n_subjects_fit] = size(lab_data_fit);
            [~, n_channels_par_fit, ~] = size(par_data_fit);
            lab_g_fit = reshape(permute(lab_data_fit, [1 3 2]), n_targets_fit * n_subjects_fit, n_channels_lab_fit);
            par_g_fit = reshape(permute(par_data_fit, [1 3 2]), n_targets_fit * n_subjects_fit, n_channels_par_fit);
            valid_rows_lab_fit = ~any(isnan(lab_g_fit), 2);
            valid_rows_par_fit = ~any(isnan(par_g_fit), 2);
            valid_overall_rows_fit = valid_rows_lab_fit & valid_rows_par_fit;
            L_all_fit = lab_g_fit(valid_overall_rows_fit, 1);
            par_all_valid_fit = par_g_fit(valid_overall_rows_fit, :);
            C_all_fit = sqrt(par_all_valid_fit(:,4).^2 + par_all_valid_fit(:,5).^2);
            alpha_values_fit = -log(par_all_valid_fit(:,6));
            alpha_values_fit(isinf(alpha_values_fit) | isnan(alpha_values_fit)) = NaN;
            
            % ===== 处理验证集数据 =====
            lab_data_val = lab_fit_reshaped_val{i_obs_used, i_nation}(indices_target, :, :, attribute);
            par_data_val = par_reshaped_val{i_obs_used, i_nation}(indices_target, :, :, attribute);
            [n_targets_val, n_channels_lab_val, n_subjects_val] = size(lab_data_val);
            [~, n_channels_par_val, ~] = size(par_data_val);
            lab_g_val = reshape(permute(lab_data_val, [1 3 2]), n_targets_val * n_subjects_val, n_channels_lab_val);
            par_g_val = reshape(permute(par_data_val, [1 3 2]), n_targets_val * n_subjects_val, n_channels_par_val);
            valid_rows_lab_val = ~any(isnan(lab_g_val), 2);
            valid_rows_par_val = ~any(isnan(par_g_val), 2);
            valid_overall_rows_val = valid_rows_lab_val & valid_rows_par_val;
            L_all_val = lab_g_val(valid_overall_rows_val, 1);
            par_all_valid_val = par_g_val(valid_overall_rows_val, :);
            C_all_val = sqrt(par_all_valid_val(:,4).^2 + par_all_valid_val(:,5).^2);
            alpha_values_val = -log(par_all_valid_val(:,6));
            alpha_values_val(isinf(alpha_values_val) | isnan(alpha_values_val)) = NaN;
            
            % 计算拟合集椭圆参数
            lambda00_fit = par_all_valid_fit(:, 1) ./ alpha_values_fit.^2;
            lambda01_fit = par_all_valid_fit(:, 3) ./ alpha_values_fit.^2 ./ 2;
            lambda10_fit = lambda01_fit;
            lambda11_fit = par_all_valid_fit(:, 2) ./ alpha_values_fit.^2;
            theta_fit = 0.5 * atan2d(2 * lambda01_fit, (lambda00_fit - lambda11_fit));
            theta_fit = mod(theta_fit, 360);
            A_fit = lambda00_fit .* cosd(theta_fit).^2 - lambda01_fit .* sind(2 * theta_fit) + lambda11_fit .* sind(theta_fit).^2;
            B_fit = lambda00_fit .* sind(theta_fit).^2 + lambda01_fit .* sind(2 * theta_fit) + lambda11_fit .* cosd(theta_fit).^2;
            A_fit(A_fit <= 0) = NaN;
            B_fit(B_fit <= 0) = NaN;
            long_axis_fit = sqrt(1 ./ A_fit);
            short_axis_fit = sqrt(1 ./ B_fit);
            hue_angle_fit = atan2d(par_all_valid_fit(:, 5), par_all_valid_fit(:, 4));
            hue_angle_fit = mod(hue_angle_fit, 360);
            
            % 计算验证集椭圆参数
            lambda00_val = par_all_valid_val(:, 1) ./ alpha_values_val.^2;
            lambda01_val = par_all_valid_val(:, 3) ./ alpha_values_val.^2 ./ 2;
            lambda10_val = lambda01_val;
            lambda11_val = par_all_valid_val(:, 2) ./ alpha_values_val.^2;
            theta_val = 0.5 * atan2d(2 * lambda01_val, (lambda00_val - lambda11_val));
            theta_val = mod(theta_val, 360);
            A_val = lambda00_val .* cosd(theta_val).^2 - lambda01_val .* sind(2 * theta_val) + lambda11_val .* sind(theta_val).^2;
            B_val = lambda00_val .* sind(theta_val).^2 + lambda01_val .* sind(2 * theta_val) + lambda11_val .* cosd(theta_val).^2;
            A_val(A_val <= 0) = NaN;
            B_val(B_val <= 0) = NaN;
            long_axis_val = sqrt(1 ./ A_val);
            short_axis_val = sqrt(1 ./ B_val);
            hue_angle_val = atan2d(par_all_valid_val(:, 5), par_all_valid_val(:, 4));
            hue_angle_val = mod(hue_angle_val, 360);

            % ========== 拟合集 C_L 建模 ==========
            if strcmp(fit_type, "new1")
                [a_C_L_fit, RSS_C_L_fit, ~, ~] = model_C_L_BIC(L_all_fit, C_all_fit, 4);
                if ~any(isnan(a_C_L_fit))
                    f_log = @(a, x) a(1)*log(x) + a(2);
                    valid_idx_fit = ~isnan(L_all_fit) & ~isnan(C_all_fit) & L_all_fit > 0;
                    C_pred_fit = f_log(a_C_L_fit, L_all_fit(valid_idx_fit));
                    C_true_fit = C_all_fit(valid_idx_fit);
                    r_C_L_fit = corr(C_pred_fit, C_true_fit);
                    RMSE_C_L_fit = sqrt(RSS_C_L_fit / sum(valid_idx_fit)) / mean(C_true_fit);
                else
                    a_C_L_fit = [NaN, NaN];
                    r_C_L_fit = NaN;
                    RMSE_C_L_fit = NaN;
                    fallback_records{end+1, 1} = nation;
                    fallback_records{end, 2} = attribute_names_new(attribute);
                    fallback_records{end, 3} = 'C_L fit NaN';
                end
            else
                % 线性模型
                [r_C_L_fit, a_C_L_fit, RMSE_C_L_fit] = model_C_L_new([], L_all_fit, C_all_fit, attribute_serial, [], [], Dtype, iOr, i_nation);
            end
            r_CL_all_fit(i_nation) = r_C_L_fit;
            rmse_CL_all_fit(i_nation) = RMSE_C_L_fit;
            a_CL_all_fit(i_nation, :) = a_C_L_fit;
            
            % ========== 使用拟合参数验证验证集 ==========
            if ~any(isnan(a_C_L_fit))
                f_log = @(a, x) a(1)*log(x) + a(2);
                valid_idx_val = ~isnan(L_all_val) & ~isnan(C_all_val) & L_all_val > 0;
                C_pred_val = f_log(a_C_L_fit, L_all_val(valid_idx_val));
                C_true_val = C_all_val(valid_idx_val);
                if sum(valid_idx_val) > 2 && std(C_pred_val) > 0 && std(C_true_val) > 0
                    r_C_L_val = corr(C_pred_val, C_true_val);
                    RMSE_C_L_val = sqrt(mean((C_pred_val - C_true_val).^2)) / mean(C_true_val);
                else
                    r_C_L_val = NaN;
                    RMSE_C_L_val = NaN;
                end
            else
                r_C_L_val = NaN;
                RMSE_C_L_val = NaN;
            end
            r_CL_all_val(i_nation) = r_C_L_val;
            rmse_CL_all_val(i_nation) = RMSE_C_L_val;
            
            % 长轴建模（拟合集）
            [r_long_axis_fit, a_long_axis_fit, RMSE_long_axis_fit] = model_long_axis([], L_all_fit, long_axis_fit, attribute_serial, [], [], Dtype, iOr, i_nation);
            r_long_axis_all_fit(i_nation) = r_long_axis_fit;
            rmse_long_axis_all_fit(i_nation) = RMSE_long_axis_fit;
            a_long_axis_all_fit(i_nation, :) = a_long_axis_fit;
            
            % 长轴验证（验证集）
            if ~any(isnan(a_long_axis_fit))
                valid_idx_val = ~isnan(L_all_val) & ~isnan(long_axis_val) & L_all_val > 0;
                if sum(valid_idx_val) > 2
                    long_pred_val = polyval(a_long_axis_fit, L_all_val(valid_idx_val));
                    long_true_val = long_axis_val(valid_idx_val);
                    if std(long_pred_val) > 0 && std(long_true_val) > 0
                        r_long_axis_val = corr(long_pred_val, long_true_val);
                        RMSE_long_axis_val = sqrt(mean((long_pred_val - long_true_val).^2)) / mean(long_true_val);
                    else
                        r_long_axis_val = NaN;
                        RMSE_long_axis_val = NaN;
                    end
                else
                    r_long_axis_val = NaN;
                    RMSE_long_axis_val = NaN;
                end
            else
                r_long_axis_val = NaN;
                RMSE_long_axis_val = NaN;
            end
            r_long_axis_all_val(i_nation) = r_long_axis_val;
            rmse_long_axis_all_val(i_nation) = RMSE_long_axis_val;
            
            % 短轴建模（拟合集）
            [r_short_axis_fit, a_short_axis_fit, RMSE_axis_fit] = model_short_axis([], L_all_fit, short_axis_fit, attribute_serial, [], [], Dtype, iOr, i_nation);
            r_short_axis_all_fit(i_nation) = r_short_axis_fit;
            rmse_short_axis_all_fit(i_nation) = RMSE_axis_fit;
            a_short_axis_all_fit(i_nation, :) = a_short_axis_fit;
            
            % 短轴验证（验证集）
            if ~any(isnan(a_short_axis_fit))
                valid_idx_val = ~isnan(L_all_val) & ~isnan(short_axis_val) & L_all_val > 0;
                if sum(valid_idx_val) > 2
                    short_pred_val = polyval(a_short_axis_fit, L_all_val(valid_idx_val));
                    short_true_val = short_axis_val(valid_idx_val);
                    if std(short_pred_val) > 0 && std(short_true_val) > 0
                        r_short_axis_val = corr(short_pred_val, short_true_val);
                        RMSE_short_axis_val = sqrt(mean((short_pred_val - short_true_val).^2)) / mean(short_true_val);
                    else
                        r_short_axis_val = NaN;
                        RMSE_short_axis_val = NaN;
                    end
                else
                    r_short_axis_val = NaN;
                    RMSE_short_axis_val = NaN;
                end
            else
                r_short_axis_val = NaN;
                RMSE_short_axis_val = NaN;
            end
            r_short_axis_all_val(i_nation) = r_short_axis_val;
            rmse_short_axis_all_val(i_nation) = RMSE_short_axis_val;
            
            % 色调角建模（常数，拟合集）
            a_hue_angle_fit = mean(hue_angle_fit);
            r_hue_angle_fit = NaN;
            RMSE_angle_fit = NaN;
            r_hue_angle_all_fit(i_nation) = r_hue_angle_fit;
            rmse_hue_angle_all_fit(i_nation) = RMSE_angle_fit;
            a_hue_angle_all_fit(i_nation, :) = a_hue_angle_fit;
            
            % 色调角验证（验证集）
            if ~isnan(a_hue_angle_fit)
                valid_idx_val = ~isnan(hue_angle_val);
                if sum(valid_idx_val) > 0
                    hue_pred_val = repmat(a_hue_angle_fit, sum(valid_idx_val), 1);
                    hue_true_val = hue_angle_val(valid_idx_val);
                    if std(hue_pred_val) > 0 && std(hue_true_val) > 0
                        r_hue_angle_val = corr(hue_pred_val, hue_true_val);
                        RMSE_hue_angle_val = sqrt(mean((hue_pred_val - hue_true_val).^2)) / mean(hue_true_val);
                    else
                        r_hue_angle_val = NaN;
                        RMSE_hue_angle_val = NaN;
                    end
                else
                    r_hue_angle_val = NaN;
                    RMSE_hue_angle_val = NaN;
                end
            else
                r_hue_angle_val = NaN;
                RMSE_hue_angle_val = NaN;
            end
            r_hue_angle_all_val(i_nation) = r_hue_angle_val;
            rmse_hue_angle_all_val(i_nation) = RMSE_hue_angle_val;
            
            % 椭圆倾角 theta 建模（常数，拟合集）
            a_theta_fit = mean(theta_fit,1,'omitnan');
            r_theta_fit = NaN;
            RMSE_theta_fit = NaN;
            r_theta_all_fit(i_nation) = r_theta_fit;
            rmse_theta_all_fit(i_nation) = RMSE_theta_fit;
            a_theta_all_fit(i_nation,:) = a_theta_fit;
            
            % 椭圆倾角验证（验证集）
            if ~isnan(a_theta_fit)
                valid_idx_val = ~isnan(theta_val);
                if sum(valid_idx_val) > 0
                    theta_pred_val = repmat(a_theta_fit, sum(valid_idx_val), 1);
                    theta_true_val = theta_val(valid_idx_val);
                    if std(theta_pred_val) > 0 && std(theta_true_val) > 0
                        r_theta_val = corr(theta_pred_val, theta_true_val);
                        RMSE_theta_val = sqrt(mean((theta_pred_val - theta_true_val).^2)) / mean(theta_true_val);
                    else
                        r_theta_val = NaN;
                        RMSE_theta_val = NaN;
                    end
                else
                    r_theta_val = NaN;
                    RMSE_theta_val = NaN;
                end
            else
                r_theta_val = NaN;
                RMSE_theta_val = NaN;
            end
            r_theta_all_val(i_nation) = r_theta_val;
            rmse_theta_all_val(i_nation) = RMSE_theta_val;
            
            % alpha 建模（常数，拟合集）
            a_alpha_fit = mean(alpha_values_fit,1,'omitnan');
            r_alpha_fit = NaN;
            RMSE_alpha_fit = NaN;
            r_alpha_all_fit(i_nation) = r_alpha_fit;
            rmse_alpha_all_fit(i_nation) = RMSE_alpha_fit;
            a_alpha_all_fit(i_nation, :) = a_alpha_fit;
            
            % alpha 验证（验证集）
            if ~isnan(a_alpha_fit)
                valid_idx_val = ~isnan(alpha_values_val);
                if sum(valid_idx_val) > 0
                    alpha_pred_val = repmat(a_alpha_fit, sum(valid_idx_val), 1);
                    alpha_true_val = alpha_values_val(valid_idx_val);
                    if std(alpha_pred_val) > 0 && std(alpha_true_val) > 0
                        r_alpha_val = corr(alpha_pred_val, alpha_true_val);
                        RMSE_alpha_val = sqrt(mean((alpha_pred_val - alpha_true_val).^2)) / mean(alpha_true_val);
                    else
                        r_alpha_val = NaN;
                        RMSE_alpha_val = NaN;
                    end
                else
                    r_alpha_val = NaN;
                    RMSE_alpha_val = NaN;
                end
            else
                r_alpha_val = NaN;
                RMSE_alpha_val = NaN;
            end

            if attribute==7 && ismember(i_nation, [ 4])
                disp("d")
            end

            r_alpha_all_val(i_nation) = r_alpha_val;
            rmse_alpha_all_val(i_nation) = RMSE_alpha_val;
        end
        
        % 将当前 attribute 的拟合集 r_all 和 rmse_all 值存入总的矩阵
        a_for_excel_C_L_fit(idx_attribute, :) = reshape(a_CL_all_fit', 1, []);
        r_values_for_excel_C_L_fit(idx_attribute, :) = r_CL_all_fit';
        rmse_values_for_excel_C_L_fit(idx_attribute, :) = rmse_CL_all_fit';

        a_for_excel_long_axis_fit(idx_attribute, :) = reshape(a_long_axis_all_fit', 1, []);
        r_values_for_excel_long_axis_fit(idx_attribute, :) = r_long_axis_all_fit';
        rmse_values_for_excel_long_axis_fit(idx_attribute, :) = rmse_long_axis_all_fit';

        a_for_excel_short_axis_fit(idx_attribute, :) = reshape(a_short_axis_all_fit', 1, []);
        r_values_for_excel_short_axis_fit(idx_attribute, :) = r_short_axis_all_fit';
        rmse_values_for_excel_short_axis_fit(idx_attribute, :) = rmse_short_axis_all_fit';

        a_for_excel_hue_angle_fit(idx_attribute, :) = reshape(a_hue_angle_all_fit', 1, []);
        r_values_for_excel_hue_angle_fit(idx_attribute, :) = r_hue_angle_all_fit';
        rmse_values_for_excel_hue_angle_fit(idx_attribute, :) = rmse_hue_angle_all_fit';

        a_for_excel_theta_fit(idx_attribute, :) = reshape(a_theta_all_fit', 1, []);
        r_values_for_excel_theta_fit(idx_attribute, :) = r_theta_all_fit';
        rmse_values_for_excel_theta_fit(idx_attribute, :) = rmse_theta_all_fit';

        a_for_excel_alpha_fit(idx_attribute, :) = reshape(a_alpha_all_fit', 1, []);
        r_values_for_excel_alpha_fit(idx_attribute, :) = r_alpha_all_fit';
        rmse_values_for_excel_alpha_fit(idx_attribute, :) = rmse_alpha_all_fit';
        
        % 验证集的结果
        r_values_for_excel_C_L_val(idx_attribute, :) = r_CL_all_val';
        rmse_values_for_excel_C_L_val(idx_attribute, :) = rmse_CL_all_val';
        r_values_for_excel_long_axis_val(idx_attribute, :) = r_long_axis_all_val';
        rmse_values_for_excel_long_axis_val(idx_attribute, :) = rmse_long_axis_all_val';
        r_values_for_excel_short_axis_val(idx_attribute, :) = r_short_axis_all_val';
        rmse_values_for_excel_short_axis_val(idx_attribute, :) = rmse_short_axis_all_val';
        r_values_for_excel_hue_angle_val(idx_attribute, :) = r_hue_angle_all_val';
        rmse_values_for_excel_hue_angle_val(idx_attribute, :) = rmse_hue_angle_all_val';
        r_values_for_excel_theta_val(idx_attribute, :) = r_theta_all_val';
        rmse_values_for_excel_theta_val(idx_attribute, :) = rmse_theta_all_val';
        r_values_for_excel_alpha_val(idx_attribute, :) = r_alpha_all_val';
        rmse_values_for_excel_alpha_val(idx_attribute, :) = rmse_alpha_all_val';
        
        % 保存拟合参数
        output_folder_params = fullfile('AnalyseResults_p', Dtype, scale_type_origin, "model_fullpara", CT_type, "new", iOr, obs_type, "devide_validation");
        if ~exist(output_folder_params, 'dir')
            mkdir(output_folder_params);
        end
        fullfile(pwd,output_folder_params)
        save(fullfile(output_folder_params, strcat(attribute_serial, '_all_curve_params_devide.mat')), ...
            'a_CL_all_fit', 'r_CL_all_fit', 'rmse_CL_all_fit', ...
            'a_long_axis_all_fit', 'r_long_axis_all_fit', 'rmse_long_axis_all_fit', ...
            'a_short_axis_all_fit', 'r_short_axis_all_fit', 'rmse_short_axis_all_fit', ...
            'a_hue_angle_all_fit', 'r_hue_angle_all_fit', 'rmse_hue_angle_all_fit', ...
            'a_theta_all_fit', 'r_theta_all_fit', 'rmse_theta_all_fit', ...
            'a_alpha_all_fit', 'r_alpha_all_fit', 'rmse_alpha_all_fit', ...
            'r_CL_all_val', 'rmse_CL_all_val', ...
            'r_long_axis_all_val', 'rmse_long_axis_all_val', ...
            'r_short_axis_all_val', 'rmse_short_axis_all_val', ...
            'r_hue_angle_all_val', 'rmse_hue_angle_all_val', ...
            'r_theta_all_val', 'rmse_theta_all_val', ...
            'r_alpha_all_val', 'rmse_alpha_all_val', ...
            'nations', 'attribute', 'obs_type', 'validation_subjects', 'fit_indices');
    end
    
    %% Excel 输出部分
    excel_col_names = nations;
    full_header = [{"Attribute"}, cellstr(excel_col_names)];
    
    % 拟合集的 C_L 相关性写入
    excel_filename_C_L_fit = fullfile(r_excel_output_folder, strcat('correlation_C_L_', iOr, '_', obs_type, '_fit.xlsx'));
    writecell([full_header; [cellstr(attribute_names_new(attributes))', num2cell(r_values_for_excel_C_L_fit)]], excel_filename_C_L_fit, 'Sheet', 'R_values');
    writecell([full_header; [cellstr(attribute_names_new(attributes))', num2cell(rmse_values_for_excel_C_L_fit)]], excel_filename_C_L_fit, 'Sheet', 'RMSE_values');
    
    % 验证集的 C_L 相关性写入
    excel_filename_C_L_val = fullfile(r_excel_output_folder, strcat('correlation_C_L_', iOr, '_', obs_type, '_val.xlsx'));
    writecell([full_header; [cellstr(attribute_names_new(attributes))', num2cell(r_values_for_excel_C_L_val)]], excel_filename_C_L_val, 'Sheet', 'R_values');
    writecell([full_header; [cellstr(attribute_names_new(attributes))', num2cell(rmse_values_for_excel_C_L_val)]], excel_filename_C_L_val, 'Sheet', 'RMSE_values');
    
    % 拟合集的长轴相关性写入
    excel_filename_long_axis_fit = fullfile(r_excel_output_folder, strcat('correlation_long_axis_', iOr, '_', obs_type, '_fit.xlsx'));
    writecell([full_header; [cellstr(attribute_names_new(attributes))', num2cell(r_values_for_excel_long_axis_fit)]], excel_filename_long_axis_fit, 'Sheet', 'R_values');
    writecell([full_header; [cellstr(attribute_names_new(attributes))', num2cell(rmse_values_for_excel_long_axis_fit)]], excel_filename_long_axis_fit, 'Sheet', 'RMSE_values');
    
    % 验证集的长轴相关性写入
    excel_filename_long_axis_val = fullfile(r_excel_output_folder, strcat('correlation_long_axis_', iOr, '_', obs_type, '_val.xlsx'));
    writecell([full_header; [cellstr(attribute_names_new(attributes))', num2cell(r_values_for_excel_long_axis_val)]], excel_filename_long_axis_val, 'Sheet', 'R_values');
    writecell([full_header; [cellstr(attribute_names_new(attributes))', num2cell(rmse_values_for_excel_long_axis_val)]], excel_filename_long_axis_val, 'Sheet', 'RMSE_values');
    
    % 拟合集的短轴相关性写入
    excel_filename_short_axis_fit = fullfile(r_excel_output_folder, strcat('correlation_short_axis_', iOr, '_', obs_type, '_fit.xlsx'));
    writecell([full_header; [cellstr(attribute_names_new(attributes))', num2cell(r_values_for_excel_short_axis_fit)]], excel_filename_short_axis_fit, 'Sheet', 'R_values');
    writecell([full_header; [cellstr(attribute_names_new(attributes))', num2cell(rmse_values_for_excel_short_axis_fit)]], excel_filename_short_axis_fit, 'Sheet', 'RMSE_values');
    
    % 验证集的短轴相关性写入
    excel_filename_short_axis_val = fullfile(r_excel_output_folder, strcat('correlation_short_axis_', iOr, '_', obs_type, '_val.xlsx'));
    writecell([full_header; [cellstr(attribute_names_new(attributes))', num2cell(r_values_for_excel_short_axis_val)]], excel_filename_short_axis_val, 'Sheet', 'R_values');
    writecell([full_header; [cellstr(attribute_names_new(attributes))', num2cell(rmse_values_for_excel_short_axis_val)]], excel_filename_short_axis_val, 'Sheet', 'RMSE_values');
    
    fprintf('已将 %s 的所有相关性矩阵和 RMSE 矩阵写入 Excel 文件（分别保存拟合集和验证集）。\n', obs_type);
    
    %% 输出回退记录 xlsx
    if ~isempty(fallback_records)
        fallback_header = {'Nation', 'Attribute', 'Reason'};
        fallback_sheet = [fallback_header; fallback_records];
        fallback_xlsx_file = fullfile(r_excel_output_folder, 'C_L_fallback_report.xlsx');
        writecell(fallback_sheet, fallback_xlsx_file);
        fprintf('  回退记录已写入: %s (%d 条)\n', fallback_xlsx_file, size(fallback_records, 1));
    else
        fprintf('  无 C_L 回退事件。\n');
    end
    
    %% 输出验证汇总表格
    validation_summary_header = {'Attribute', 'Nation', 'R_C_L_fit', 'RMSE_C_L_fit', 'R_C_L_val', 'RMSE_C_L_val', ...
        'R_long_fit', 'RMSE_long_fit', 'R_long_val', 'RMSE_long_val', ...
        'R_short_fit', 'RMSE_short_fit', 'R_short_val', 'RMSE_short_val'};
    validation_summary = {};
    for idx_attr = 1:length(attributes)
        for i_nation = 1:length(nations)
            row = idx_attr + (i_nation-1) * length(attributes);
            validation_summary{row, 1} = attribute_names_new(attributes(idx_attr));
            validation_summary{row, 2} = nations(i_nation);
            validation_summary{row, 3} = r_values_for_excel_C_L_fit(idx_attr, i_nation);
            validation_summary{row, 4} = rmse_values_for_excel_C_L_fit(idx_attr, i_nation);
            validation_summary{row, 5} = r_values_for_excel_C_L_val(idx_attr, i_nation);
            validation_summary{row, 6} = rmse_values_for_excel_C_L_val(idx_attr, i_nation);
            validation_summary{row, 7} = r_values_for_excel_long_axis_fit(idx_attr, i_nation);
            validation_summary{row, 8} = rmse_values_for_excel_long_axis_fit(idx_attr, i_nation);
            validation_summary{row, 9} = r_values_for_excel_long_axis_val(idx_attr, i_nation);
            validation_summary{row, 10} = rmse_values_for_excel_long_axis_val(idx_attr, i_nation);
            validation_summary{row, 11} = r_values_for_excel_short_axis_fit(idx_attr, i_nation);
            validation_summary{row, 12} = rmse_values_for_excel_short_axis_fit(idx_attr, i_nation);
            validation_summary{row, 13} = r_values_for_excel_short_axis_val(idx_attr, i_nation);
            validation_summary{row, 14} = rmse_values_for_excel_short_axis_val(idx_attr, i_nation);
        end
    end
    validation_summary_sheet = [validation_summary_header; validation_summary];
    validation_summary_xlsx = fullfile(r_excel_output_folder, 'validation_summary.xlsx');
    writecell(validation_summary_sheet, validation_summary_xlsx);
    fprintf('  验证汇总已写入: %s\n', validation_summary_xlsx);
end

fprintf('脚本执行完成！\n');
