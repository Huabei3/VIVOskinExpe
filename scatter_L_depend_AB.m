% 主脚本开始
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
'f09i', 'f10i','m09i', 'm10i'};n_para = 21;iOr='i';
% lastParts = {'f04r', 'f05r', 'f06r', 'm04r', 'm05r', 'm06r',...
% 'f01r', 'f02r', 'f03r', 'm01r', 'm02r', 'm03r',...
% 'f07r', 'f08r','m07r', 'm08r',...
% 'f09r', 'f10r','m09r', 'm10r'};n_para = 14;iOr='r';
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
    nation_indices{1} = 1:6;
    nation_indices{2} = 7:12;
    nation_indices{3} = 13:16;
    nation_indices{4} = 17:20;
    nation_indices{5} = 1:20;
    label_type="nation";
end

% 定义每个 nation 的 groupA 和 groupB 索引
% 对于每个 nation，我们将其模特分为两组
% 示例：Asian (AS) 可以 f04,m05,f05 为 A组，m04,f06,m06 为 B组
groupA_indices = cell(length(nations), 1);
groupB_indices = cell(length(nations), 1);

% AS (Asian): 索引1-6 对应 f04i, f05i, f06i, m04i, m05i, m06i
% 分组示例：A组: f04i(1), m05i(5), f05i(2) 
%          B组: m04i(4), f06i(3), m06i(6)
groupA_indices{1} = [1, 5, 2];  % f04i, m05i, f05i
groupB_indices{1} = [4, 3, 6];  % m04i, f06i, m06i

% CA (Caucasian): 索引7-12 对应 f01i, f02i, f03i, m01i, m02i, m03i
% 分组示例：A组: f01i(7), m02i(11), f03i(9)
%          B组: m01i(10), f02i(8), m03i(12)
groupA_indices{2} = [7, 11, 9];   % f01i, m02i, f03i
groupB_indices{2} = [10, 8, 12];  % m01i, f02i, m03i

% SA (South Asian): 索引13-16 对应 f07i, f08i, m07i, m08i
% 分组示例：A组: f07i(13), m08i(16)
%          B组: f08i(14), m07i(15)
groupA_indices{3} = [13, 16];  % f07i, m08i
groupB_indices{3} = [14, 15];  % f08i, m07i

% AF (African): 索引17-20 对应 f09i, f10i, m09i, m10i
% 分组示例：A组: f09i(17), m10i(20)
%          B组: f10i(18), m09i(19)
groupA_indices{4} = [17, 20];  % f09i, m10i
groupB_indices{4} = [18, 19];  % f10i, m09i

% all: 所有索引1-20，可以随机分为两组或按奇偶分组
all_indices = 1:20;
half = floor(length(all_indices)/2);
groupA_indices{5} = all_indices(1:2:end);  % 奇数索引
groupB_indices{5} = all_indices(2:2:end);  % 偶数索引

% 生成色相值（H），范围从0到1
% 现在我们需要为每个 nation 的两组分别生成颜色
% 每组使用相同色相但不同饱和度或亮度
hue_values = linspace(0, 1, length(nations) + 1);hue_values = hue_values(1:end-1);
% 为 groupA 和 groupB 创建不同的颜色
colors_A = cell(length(nations), 1);
colors_B = cell(length(nations), 1);
for i_nation = 1:length(nations)
    % groupA 使用较高饱和度
    hsv_A = [hue_values(i_nation), 0.8, 0.9];  % 高亮度
    colors_A{i_nation} = hsv2rgb(hsv_A);
    % groupB 使用较低饱和度
    hsv_B = [hue_values(i_nation), 0.6, 0.7];  % 较低亮度
    colors_B{i_nation} = hsv2rgb(hsv_B);
end

% 初始化重塑后的数据结构
% 现在我们需要为每个 nation 的 groupA 和 groupB 分别存储数据
average_reshaped_A = cell(length(nations), 1);
average_reshaped_B = cell(length(nations), 1);
par_reshaped_A = cell(3, length(nations), 1);  % 3种观察者类型 × 5个人种 × groupA
par_reshaped_B = cell(3, length(nations), 1);  % 3种观察者类型 × 5个人种 × groupB
lab_fit_reshaped_A = cell(3, length(nations), 1);
lab_fit_reshaped_B = cell(3, length(nations), 1);
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

%% 直接按重塑后的结构加载和存储数据，分别处理 groupA 和 groupB
for i_obs = 1:length(obs_types)
    obs_type = obs_types(i_obs);
    for i_nation = 1:length(nations)
        nation = nations(i_nation);
        
        % 处理 groupA
        curr_groupA_indices = groupA_indices{i_nation};
        n_subjects_A = length(curr_groupA_indices);
        par_current_A = zeros(n_para, 6, n_subjects_A, length(attributes));
        lab_fit_current_A = zeros(n_para, 3, n_subjects_A, length(attributes));
        average_current_A = zeros(n_para, 3, n_subjects_A);
        
        % 处理 groupB
        curr_groupB_indices = groupB_indices{i_nation};
        n_subjects_B = length(curr_groupB_indices);
        par_current_B = zeros(n_para, 6, n_subjects_B, length(attributes));
        lab_fit_current_B = zeros(n_para, 3, n_subjects_B, length(attributes));
        average_current_B = zeros(n_para, 3, n_subjects_B);
        
        % 为 groupA 的每个subject加载数据
        for i_subject = 1:n_subjects_A
            subject_idx = curr_groupA_indices(i_subject);
            lastPart = lastParts{subject_idx};
            iOr = lastPart(end);
            % 加载平均肤色数据
            average_file = fullfile("aveSkin", lastPart, "autoNhand_scaleoverLUT.mat");
            if exist(average_file, 'file')
                average_data = load(average_file);
                average_current_A(:, :, i_subject) = average_data.average_lab_all(:, 1:3);
            else
                average_current_A(:, :, i_subject) = NaN(n_para, 3);
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
                    par_all=[par_all;nan(size(par_current_A,1)-size(par_all,1),size(par_all,2))];
                    par_current_A(:, :, i_subject, i_attr) = par_all;
                    lab_bf=[average_current_A(:, 1, i_subject), par_all(:,4:5)];
                    lab_fit_current_A(:, :, i_subject, i_attr) = lab_bf;
                else
                    par_current_A(:, :, i_subject, i_attr) = NaN(n_para, 6);
                    lab_fit_current_A(:, :, i_subject, i_attr) = NaN(n_para, 3);
                    file_missing{end+1,1}=lastPart;
                    file_missing{end,2}=obs_type;
                    file_missing{end,3}=attribute_serial;
                end
            end
        end
        
        % 为 groupB 的每个subject加载数据
        for i_subject = 1:n_subjects_B
            subject_idx = curr_groupB_indices(i_subject);
            lastPart = lastParts{subject_idx};
            iOr = lastPart(end);
            % 加载平均肤色数据
            average_file = fullfile("aveSkin", lastPart, "autoNhand_scaleoverLUT.mat");
            if exist(average_file, 'file')
                average_data = load(average_file);
                average_current_B(:, :, i_subject) = average_data.average_lab_all(:, 1:3);
            else
                average_current_B(:, :, i_subject) = NaN(n_para, 3);
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
                    par_all=[par_all;nan(size(par_current_B,1)-size(par_all,1),size(par_all,2))];
                    par_current_B(:, :, i_subject, i_attr) = par_all;
                    lab_bf=[average_current_B(:, 1, i_subject), par_all(:,4:5)];
                    lab_fit_current_B(:, :, i_subject, i_attr) = lab_bf;
                else
                    par_current_B(:, :, i_subject, i_attr) = NaN(n_para, 6);
                    lab_fit_current_B(:, :, i_subject, i_attr) = NaN(n_para, 3);
                    file_missing{end+1,1}=lastPart;
                    file_missing{end,2}=obs_type;
                    file_missing{end,3}=attribute_serial;
                end
            end
        end
        
        % 存储到重塑后的数据结构中
        par_reshaped_A{i_obs, i_nation} = par_current_A;
        par_reshaped_B{i_obs, i_nation} = par_current_B;
        lab_fit_reshaped_A{i_obs, i_nation} = lab_fit_current_A;
        lab_fit_reshaped_B{i_obs, i_nation} = lab_fit_current_B;
        
        % average_reshaped只需要存储一次（不依赖于观察者类型）
        if i_obs == 1
            average_reshaped_A{i_nation} = average_current_A;
            average_reshaped_B{i_nation} = average_current_B;
        end
        
        % 计算平均值
        average_mean_A{i_obs, i_nation} = nanmean(average_reshaped_A{i_nation}, 3);
        average_mean_B{i_obs, i_nation} = nanmean(average_reshaped_B{i_nation}, 3);
        par_mean_A{i_obs, i_nation} = nanmean(par_reshaped_A{i_obs, i_nation}, 3);
        par_mean_B{i_obs, i_nation} = nanmean(par_reshaped_B{i_obs, i_nation}, 3);
        
        average_nation_temp_A(i_nation,:) = mean(average_mean_A{i_obs, i_nation}(indices_target,:));
        average_nation_temp_B(i_nation,:) = mean(average_mean_B{i_obs, i_nation}(indices_target,:));
    end
    average_nations_A{i_obs} = average_nation_temp_A;
    average_nations_B{i_obs} = average_nation_temp_B;
end

%% 保存
output_folder = fullfile("ellip_pic_p", Dtype, CT_type, "AB_groups");
if ~exist(output_folder, "dir")
    mkdir(output_folder);
end
save(fullfile(output_folder, strcat("data_unscaled_reshaped_", iOr, "_AB.mat")), ...
    "par_mean_A", "par_mean_B", "average_mean_A", "average_mean_B", ...
    "lab_fit_reshaped_A", "lab_fit_reshaped_B", "file_missing", ...
    "par_reshaped_A", "par_reshaped_B", "average_reshaped_A", "average_reshaped_B", ...
    "groupA_indices", "groupB_indices");

%% 为每个观察者类型、人种和属性分别处理数据（按人种分组拟合，分别处理 groupA 和 groupB）
obs_types = ["non_model"]; % 恢复所有观察者类型
% obs_types = ["non_model", "model_group"]; % 恢复所有观察者类型
dE = {};

% 遍历观察者类型
for i_obs = 1:length(obs_types)
    obs_type = obs_types(i_obs);
    r_excel_output_folder = fullfile("AnalyseResults_p", Dtype, scale_type_origin, "model_fullpara", CT_type, "new", iOr, obs_type, "AB_groups");
    if ~exist(r_excel_output_folder, 'dir')
        mkdir(r_excel_output_folder);
    end

    % 用于存储当前 obs_type 下所有 attribute 的 r 和 rmse 值，以便写入 Excel
    % 现在需要为 groupA 和 groupB 分别存储
    n_n = length(nations);
    r_values_for_excel_C_L_A = zeros(length(attributes), n_n);
    rmse_values_for_excel_C_L_A = zeros(length(attributes), n_n);
    r_values_for_excel_long_axis_A = zeros(length(attributes), n_n);
    rmse_values_for_excel_long_axis_A = zeros(length(attributes), n_n);
    r_values_for_excel_short_axis_A = zeros(length(attributes), n_n);
    rmse_values_for_excel_short_axis_A = zeros(length(attributes), n_n);
    r_values_for_excel_hue_angle_A = zeros(length(attributes), n_n);
    rmse_values_for_excel_hue_angle_A = zeros(length(attributes), n_n);
    r_values_for_excel_theta_A = zeros(length(attributes), n_n);
    rmse_values_for_excel_theta_A = zeros(length(attributes), n_n);
    r_values_for_excel_alpha_A = zeros(length(attributes), n_n);
    rmse_values_for_excel_alpha_A = zeros(length(attributes), n_n);
    
    r_values_for_excel_C_L_B = zeros(length(attributes), n_n);
    rmse_values_for_excel_C_L_B = zeros(length(attributes), n_n);
    r_values_for_excel_long_axis_B = zeros(length(attributes), n_n);
    rmse_values_for_excel_long_axis_B = zeros(length(attributes), n_n);
    r_values_for_excel_short_axis_B = zeros(length(attributes), n_n);
    rmse_values_for_excel_short_axis_B = zeros(length(attributes), n_n);
    r_values_for_excel_hue_angle_B = zeros(length(attributes), n_n);
    rmse_values_for_excel_hue_angle_B = zeros(length(attributes), n_n);
    r_values_for_excel_theta_B = zeros(length(attributes), n_n);
    rmse_values_for_excel_theta_B = zeros(length(attributes), n_n);
    r_values_for_excel_alpha_B = zeros(length(attributes), n_n);
    rmse_values_for_excel_alpha_B = zeros(length(attributes), n_n);
    
    % ===== 回退记录：记录 (nation, attribute, group, 原因) =====
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
        
        % groupA 的拟合参数
        a_CL_all_A = zeros(n_n, 2);
        r_CL_all_A = zeros(n_n, 1);
        rmse_CL_all_A = zeros(n_n, 1);
        a_long_axis_all_A = zeros(n_n, 4);
        r_long_axis_all_A = zeros(n_n, 1);
        rmse_long_axis_all_A = zeros(n_n, 1);
        a_short_axis_all_A = zeros(n_n, 4);
        r_short_axis_all_A = zeros(n_n, 1);
        rmse_short_axis_all_A = zeros(n_n, 1);
        a_hue_angle_all_A = zeros(n_n, 2);
        r_hue_angle_all_A = zeros(n_n, 1);
        rmse_hue_angle_all_A = zeros(n_n, 1);
        a_theta_all_A = zeros(n_n, 2);
        r_theta_all_A = zeros(n_n, 1);
        rmse_theta_all_A = zeros(n_n, 1);
        a_alpha_all_A = zeros(n_n, 2);
        r_alpha_all_A = zeros(n_n, 1);
        rmse_alpha_all_A = zeros(n_n, 1);
        
        % groupB 的拟合参数
        a_CL_all_B = zeros(n_n, 2);
        r_CL_all_B = zeros(n_n, 1);
        rmse_CL_all_B = zeros(n_n, 1);
        a_long_axis_all_B = zeros(n_n, 4);
        r_long_axis_all_B = zeros(n_n, 1);
        rmse_long_axis_all_B = zeros(n_n, 1);
        a_short_axis_all_B = zeros(n_n, 4);
        r_short_axis_all_B = zeros(n_n, 1);
        rmse_short_axis_all_B = zeros(n_n, 1);
        a_hue_angle_all_B = zeros(n_n, 2);
        r_hue_angle_all_B = zeros(n_n, 1);
        rmse_hue_angle_all_B = zeros(n_n, 1);
        a_theta_all_B = zeros(n_n, 2);
        r_theta_all_B = zeros(n_n, 1);
        rmse_theta_all_B = zeros(n_n, 1);
        a_alpha_all_B = zeros(n_n, 2);
        r_alpha_all_B = zeros(n_n, 1);
        rmse_alpha_all_B = zeros(n_n, 1);
        
        % 按人种分组处理
        for i_nation = 1:length(nations)
            nation = nations(i_nation);
            
            % 处理 groupA
            if attribute == 7
                i_obs_used = 2;
            else
                i_obs_used = i_obs;
            end
            
            % ===== 先计算 groupA 和 groupB 的基础数据（为 C_L fallback 准备）=====
            % groupA
            lab_data_A = lab_fit_reshaped_A{i_obs_used, i_nation}(indices_target, :, :, attribute);
            par_data_A = par_reshaped_A{i_obs_used, i_nation}(indices_target, :, :, attribute);
            [n_targets_A, n_channels_lab_A, n_subjects_A] = size(lab_data_A);
            [~, n_channels_par_A, ~] = size(par_data_A);
            lab_g_A = reshape(permute(lab_data_A, [1 3 2]), n_targets_A * n_subjects_A, n_channels_lab_A);
            par_g_A = reshape(permute(par_data_A, [1 3 2]), n_targets_A * n_subjects_A, n_channels_par_A);
            valid_rows_lab_A = ~any(isnan(lab_g_A), 2);
            valid_rows_par_A = ~any(isnan(par_g_A), 2);
            valid_overall_rows_A = valid_rows_lab_A & valid_rows_par_A;
            L_all_A = lab_g_A(valid_overall_rows_A, 1);
            par_all_valid_A = par_g_A(valid_overall_rows_A, :);
            C_all_A = sqrt(par_all_valid_A(:,4).^2 + par_all_valid_A(:,5).^2);
            alpha_values_A = -log(par_all_valid_A(:,6));
            alpha_values_A(isinf(alpha_values_A) | isnan(alpha_values_A)) = NaN;
            % 合并A+B数据（用于C_L fallback）
            lab_data_B = lab_fit_reshaped_B{i_obs_used, i_nation}(indices_target, :, :, attribute);
            par_data_B = par_reshaped_B{i_obs_used, i_nation}(indices_target, :, :, attribute);
            [n_targets_B, n_channels_lab_B, n_subjects_B] = size(lab_data_B);
            [~, n_channels_par_B, ~] = size(par_data_B);
            lab_g_B = reshape(permute(lab_data_B, [1 3 2]), n_targets_B * n_subjects_B, n_channels_lab_B);
            par_g_B = reshape(permute(par_data_B, [1 3 2]), n_targets_B * n_subjects_B, n_channels_par_B);
            valid_rows_lab_B = ~any(isnan(lab_g_B), 2);
            valid_rows_par_B = ~any(isnan(par_g_B), 2);
            valid_overall_rows_B = valid_rows_lab_B & valid_rows_par_B;
            L_all_B = lab_g_B(valid_overall_rows_B, 1);
            par_all_valid_B = par_g_B(valid_overall_rows_B, :);
            C_all_B = sqrt(par_all_valid_B(:,4).^2 + par_all_valid_B(:,5).^2);
            alpha_values_B = -log(par_all_valid_B(:,6));
            alpha_values_B(isinf(alpha_values_B) | isnan(alpha_values_B)) = NaN;
            L_all_AB = [L_all_A; L_all_B];
            C_all_AB = [C_all_A; C_all_B];
            
            % 计算 groupA 椭圆参数
            lambda00_A = par_all_valid_A(:, 1) ./ alpha_values_A.^2;
            lambda01_A = par_all_valid_A(:, 3) ./ alpha_values_A.^2 ./ 2;
            lambda10_A = lambda01_A;
            lambda11_A = par_all_valid_A(:, 2) ./ alpha_values_A.^2;
            theta_A = 0.5 * atan2d(2 * lambda01_A, (lambda00_A - lambda11_A));
            theta_A = mod(theta_A, 360);
            A_A = lambda00_A .* cosd(theta_A).^2 - lambda01_A .* sind(2 * theta_A) + lambda11_A .* sind(theta_A).^2;
            B_A = lambda00_A .* sind(theta_A).^2 + lambda01_A .* sind(2 * theta_A) + lambda11_A .* cosd(theta_A).^2;
            A_A(A_A <= 0) = NaN;
            B_A(B_A <= 0) = NaN;
            long_axis_A = sqrt(1 ./ A_A);
            short_axis_A = sqrt(1 ./ B_A);
            hue_angle_A = atan2d(par_all_valid_A(:, 5), par_all_valid_A(:, 4));
            hue_angle_A = mod(hue_angle_A, 360);
            
            % groupA 的 C_L 建模（带 fallback）
            if attribute==3&&ismember(i_nation,[3,4])
                disp("d")
            end
            if strcmp(fit_type, "new1")
                [a_C_L_A, RSS_C_L_A, ~, ~] = model_C_L_BIC(L_all_A, C_all_A, 4);
                if ~any(isnan(a_C_L_A))
                    f_log = @(a, x) a(1)*log(x) + a(2);
                    valid_idx_A = ~isnan(L_all_A) & ~isnan(C_all_A) & L_all_A > 0;
                    C_pred_A = f_log(a_C_L_A, L_all_A(valid_idx_A));
                    C_true_A = C_all_A(valid_idx_A);
                    r_C_L_A = corr(C_pred_A, C_true_A);
                    RMSE_C_L_A = sqrt(RSS_C_L_A / sum(valid_idx_A)) / mean(C_true_A);
                else
                    % ===== 回退：合并A+B全部数据再次拟合 =====
                    [a_C_L_A, RSS_C_L_A, ~, ~] = model_C_L_BIC(L_all_AB, C_all_AB, 4);
                    if ~any(isnan(a_C_L_A))
                        f_log = @(a, x) a(1)*log(x) + a(2);
                        valid_idx_AB = ~isnan(L_all_AB) & ~isnan(C_all_AB) & L_all_AB > 0;
                        C_pred_A = f_log(a_C_L_A, L_all_AB(valid_idx_AB));
                        C_true_A = C_all_AB(valid_idx_AB);
                        r_C_L_A = corr(C_pred_A, C_true_A);
                        RMSE_C_L_A = sqrt(RSS_C_L_A / sum(valid_idx_AB)) / mean(C_true_A);
                        fallback_records{end+1, 1} = nation;
                        fallback_records{end,   2} = attribute_names_new(attribute);
                        fallback_records{end,   3} = 'A';
                        fallback_records{end,   4} = 'C_L NaN → fallback to A+B combined';
                    else
                        a_C_L_A = [NaN, NaN];
                        r_C_L_A = NaN;
                        RMSE_C_L_A = NaN;
                        fallback_records{end+1, 1} = nation;
                        fallback_records{end,   2} = attribute_names_new(attribute);
                        fallback_records{end,   3} = 'A';
                        fallback_records{end,   4} = 'C_L NaN even after fallback';
                    end
                end
            else
                % 线性模型
                [r_C_L_A, a_C_L_A, RMSE_C_L_A] = model_C_L_new([], L_all_A, C_all_A, attribute_serial, [], [], Dtype, iOr, i_nation);
            end
            r_CL_all_A(i_nation) = r_C_L_A;
            rmse_CL_all_A(i_nation) = RMSE_C_L_A;
            a_CL_all_A(i_nation, :) = a_C_L_A;
            
            % 长轴建模（带 fallback）
            [r_long_axis_A, a_long_axis_A, RMSE_long_axis_A] = model_long_axis([], L_all_A, long_axis_A, attribute_serial, [], [], Dtype, iOr, i_nation);
            if ~any(isnan(a_long_axis_A))
                r_long_axis_all_A(i_nation) = r_long_axis_A;
                rmse_long_axis_all_A(i_nation) = RMSE_long_axis_A;
                a_long_axis_all_A(i_nation, :) = a_long_axis_A;
            else
                % ===== 回退：合并A+B全部数据再次拟合 =====
                L_all_AB = [L_all_A; L_all_B];
                long_axis_AB = [long_axis_A; long_axis_B];
                % 确保L和axis数据维度一致，重新过滤
                valid_AB = ~isnan(L_all_AB) & ~isnan(long_axis_AB);
                L_all_AB = L_all_AB(valid_AB);
                long_axis_AB = long_axis_AB(valid_AB);
                [r_long_axis_A, a_long_axis_A, RMSE_long_axis_A] = model_long_axis([], L_all_AB, long_axis_AB, attribute_serial, [], [], Dtype, iOr, i_nation);
                r_long_axis_all_A(i_nation) = r_long_axis_A;
                rmse_long_axis_all_A(i_nation) = RMSE_long_axis_A;
                a_long_axis_all_A(i_nation, :) = a_long_axis_A;
                fallback_records{end+1, 1} = nation;
                fallback_records{end, 2} = attribute_names_new(attribute);
                fallback_records{end, 3} = 'A';
                fallback_records{end, 4} = 'long_axis NaN → fallback to A+B combined';
            end

            % 短轴建模（带 fallback）
            [r_short_axis_A, a_short_axis_A, RMSE_axis_A] = model_short_axis([], L_all_A, short_axis_A, attribute_serial, [], [], Dtype, iOr, i_nation);
            if ~any(isnan(a_short_axis_A))
                r_short_axis_all_A(i_nation) = r_short_axis_A;
                rmse_short_axis_all_A(i_nation) = RMSE_axis_A;
                a_short_axis_all_A(i_nation, :) = a_short_axis_A;
            else
                % ===== 回退：合并A+B全部数据再次拟合 =====
                L_all_AB = [L_all_A; L_all_B];
                short_axis_AB = [short_axis_A; short_axis_B];
                % 确保L和axis数据维度一致，重新过滤
                valid_AB = ~isnan(L_all_AB) & ~isnan(short_axis_AB);
                L_all_AB = L_all_AB(valid_AB);
                short_axis_AB = short_axis_AB(valid_AB);
                [r_short_axis_A, a_short_axis_A, RMSE_axis_A] = model_short_axis([], L_all_AB, short_axis_AB, attribute_serial, [], [], Dtype, iOr, i_nation);
                r_short_axis_all_A(i_nation) = r_short_axis_A;
                rmse_short_axis_all_A(i_nation) = RMSE_axis_A;
                a_short_axis_all_A(i_nation, :) = a_short_axis_A;
                fallback_records{end+1, 1} = nation;
                fallback_records{end, 2} = attribute_names_new(attribute);
                fallback_records{end, 3} = 'A';
                fallback_records{end, 4} = 'short_axis NaN → fallback to A+B combined';
            end
            
            % 色调角建模（常数）
            a_hue_angle_A = mean(hue_angle_A);
            r_hue_angle_A = NaN;
            RMSE_angle_A = NaN;
            r_hue_angle_all_A(i_nation) = r_hue_angle_A;
            rmse_hue_angle_all_A(i_nation) = RMSE_angle_A;
            a_hue_angle_all_A(i_nation, :) = a_hue_angle_A;
            
            % 椭圆倾角 theta 建模（常数）
            a_theta_A = mean(theta_A);
            r_theta_A = NaN;
            RMSE_theta_A = NaN;
            r_theta_all_A(i_nation) = r_theta_A;
            rmse_theta_all_A(i_nation) = RMSE_theta_A;
            a_theta_all_A(i_nation,:) = a_theta_A;
            
            % alpha 建模（常数）
            a_alpha_A = mean(alpha_values_A);
            r_alpha_A = NaN;
            RMSE_alpha_A = NaN;
            r_alpha_all_A(i_nation) = r_alpha_A;
            rmse_alpha_all_A(i_nation) = RMSE_alpha_A;
            a_alpha_all_A(i_nation, :) = a_alpha_A;
            
            % groupB 椭圆参数（数据已在预计算块算出）
            
            % 计算 groupB 椭圆参数
            lambda00_B = par_all_valid_B(:, 1) ./ alpha_values_B.^2;
            lambda01_B = par_all_valid_B(:, 3) ./ alpha_values_B.^2 ./ 2;
            lambda10_B = lambda01_B;
            lambda11_B = par_all_valid_B(:, 2) ./ alpha_values_B.^2;
            theta_B = 0.5 * atan2d(2 * lambda01_B, (lambda00_B - lambda11_B));
            theta_B = mod(theta_B, 360);
            A_B = lambda00_B .* cosd(theta_B).^2 - lambda01_B .* sind(2 * theta_B) + lambda11_B .* sind(theta_B).^2;
            B_B = lambda00_B .* sind(theta_B).^2 + lambda01_B .* sind(2 * theta_B) + lambda11_B .* cosd(theta_B).^2;
            A_B(A_B <= 0) = NaN;
            B_B(B_B <= 0) = NaN;
            long_axis_B = sqrt(1 ./ A_B);
            short_axis_B = sqrt(1 ./ B_B);
            hue_angle_B = atan2d(par_all_valid_B(:, 5), par_all_valid_B(:, 4));
            hue_angle_B = mod(hue_angle_B, 360);
            
            % groupB 的建模
            if attribute==3&&ismember(i_nation,[3,4])
                disp("d")
            end
            if strcmp(fit_type, "new1")
                [a_C_L_B, RSS_C_L_B, ~, ~] = model_C_L_BIC(L_all_B, C_all_B, 4);
                if ~any(isnan(a_C_L_B))
                    f_log = @(a, x) a(1)*log(x) + a(2);
                    valid_idx_B = ~isnan(L_all_B) & ~isnan(C_all_B) & L_all_B > 0;
                    C_pred_B = f_log(a_C_L_B, L_all_B(valid_idx_B));
                    C_true_B = C_all_B(valid_idx_B);
                    r_C_L_B = corr(C_pred_B, C_true_B);
                    RMSE_C_L_B = sqrt(RSS_C_L_B / sum(valid_idx_B)) / mean(C_true_B);
                else
                    % ===== 回退：合并A+B全部数据再次拟合 =====
                    L_all_AB = [L_all_A; L_all_B];
                    C_all_AB = [C_all_A; C_all_B];
                    [a_C_L_B, RSS_C_L_B, ~, ~] = model_C_L_BIC(L_all_AB, C_all_AB, 4);
                    if ~any(isnan(a_C_L_B))
                        f_log = @(a, x) a(1)*log(x) + a(2);
                        valid_idx_AB = ~isnan(L_all_AB) & ~isnan(C_all_AB) & L_all_AB > 0;
                        C_pred_B = f_log(a_C_L_B, L_all_AB(valid_idx_AB));
                        C_true_B = C_all_AB(valid_idx_AB);
                        r_C_L_B = corr(C_pred_B, C_true_B);
                        RMSE_C_L_B = sqrt(RSS_C_L_B / sum(valid_idx_AB)) / mean(C_true_B);
                        fallback_records{end+1, 1} = nation;
                        fallback_records{end,   2} = attribute_names_new(attribute);
                        fallback_records{end,   3} = 'B';
                        fallback_records{end,   4} = 'C_L NaN → fallback to A+B combined';
                    else
                        a_C_L_B = [NaN, NaN];
                        r_C_L_B = NaN;
                        RMSE_C_L_B = NaN;
                        fallback_records{end+1, 1} = nation;
                        fallback_records{end,   2} = attribute_names_new(attribute);
                        fallback_records{end,   3} = 'B';
                        fallback_records{end,   4} = 'C_L NaN even after fallback';
                    end
                end
            else
                % 线性模型
                [r_C_L_B, a_C_L_B, RMSE_C_L_B] = model_C_L_new([], L_all_B, C_all_B, attribute_serial, [], [], Dtype, iOr, i_nation);
            end
            r_CL_all_B(i_nation) = r_C_L_B;
            rmse_CL_all_B(i_nation) = RMSE_C_L_B;
            a_CL_all_B(i_nation, :) = a_C_L_B;
            
            % 长轴建模（带 fallback）
            [r_long_axis_B, a_long_axis_B, RMSE_long_axis_B] = model_long_axis([], L_all_B, long_axis_B, attribute_serial, [], [], Dtype, iOr, i_nation);
            if ~any(isnan(a_long_axis_B))
                r_long_axis_all_B(i_nation) = r_long_axis_B;
                rmse_long_axis_all_B(i_nation) = RMSE_long_axis_B;
                a_long_axis_all_B(i_nation, :) = a_long_axis_B;
            else
                % ===== 回退：合并A+B全部数据再次拟合 =====
                L_all_AB = [L_all_A; L_all_B];
                long_axis_AB = [long_axis_A; long_axis_B];
                % 确保L和axis数据维度一致，重新过滤
                valid_AB = ~isnan(L_all_AB) & ~isnan(long_axis_AB);
                L_all_AB = L_all_AB(valid_AB);
                long_axis_AB = long_axis_AB(valid_AB);
                [r_long_axis_B, a_long_axis_B, RMSE_long_axis_B] = model_long_axis([], L_all_AB, long_axis_AB, attribute_serial, [], [], Dtype, iOr, i_nation);
                r_long_axis_all_B(i_nation) = r_long_axis_B;
                rmse_long_axis_all_B(i_nation) = RMSE_long_axis_B;
                a_long_axis_all_B(i_nation, :) = a_long_axis_B;
                fallback_records{end+1, 1} = nation;
                fallback_records{end, 2} = attribute_names_new(attribute);
                fallback_records{end, 3} = 'B';
                fallback_records{end, 4} = 'long_axis NaN → fallback to A+B combined';
            end

            % 短轴建模（带 fallback）
            [r_short_axis_B, a_short_axis_B, RMSE_axis_B] = model_short_axis([], L_all_B, short_axis_B, attribute_serial, [], [], Dtype, iOr, i_nation);
            if ~any(isnan(a_short_axis_B))
                r_short_axis_all_B(i_nation) = r_short_axis_B;
                rmse_short_axis_all_B(i_nation) = RMSE_axis_B;
                a_short_axis_all_B(i_nation, :) = a_short_axis_B;
            else
                % ===== 回退：合并A+B全部数据再次拟合 =====
                L_all_AB = [L_all_A; L_all_B];
                short_axis_AB = [short_axis_A; short_axis_B];
                % 确保L和axis数据维度一致，重新过滤
                valid_AB = ~isnan(L_all_AB) & ~isnan(short_axis_AB);
                L_all_AB = L_all_AB(valid_AB);
                short_axis_AB = short_axis_AB(valid_AB);
                [r_short_axis_B, a_short_axis_B, RMSE_axis_B] = model_short_axis([], L_all_AB, short_axis_AB, attribute_serial, [], [], Dtype, iOr, i_nation);
                r_short_axis_all_B(i_nation) = r_short_axis_B;
                rmse_short_axis_all_B(i_nation) = RMSE_axis_B;
                a_short_axis_all_B(i_nation, :) = a_short_axis_B;
                fallback_records{end+1, 1} = nation;
                fallback_records{end, 2} = attribute_names_new(attribute);
                fallback_records{end, 3} = 'B';
                fallback_records{end, 4} = 'short_axis NaN → fallback to A+B combined';
            end
            
            % 色调角建模（常数）
            a_hue_angle_B = mean(hue_angle_B);
            r_hue_angle_B = NaN;
            RMSE_angle_B = NaN;
            r_hue_angle_all_B(i_nation) = r_hue_angle_B;
            rmse_hue_angle_all_B(i_nation) = RMSE_angle_B;
            a_hue_angle_all_B(i_nation, :) = a_hue_angle_B;
            
            % 椭圆倾角 theta 建模（常数）
            a_theta_B = mean(theta_B);
            r_theta_B = NaN;
            RMSE_theta_B = NaN;
            r_theta_all_B(i_nation) = r_theta_B;
            rmse_theta_all_B(i_nation) = RMSE_theta_B;
            a_theta_all_B(i_nation,:) = a_theta_B;
            
            % alpha 建模（常数）
            a_alpha_B = mean(alpha_values_B);
            r_alpha_B = NaN;
            RMSE_alpha_B = NaN;
            r_alpha_all_B(i_nation) = r_alpha_B;
            rmse_alpha_all_B(i_nation) = RMSE_alpha_B;
            a_alpha_all_B(i_nation, :) = a_alpha_B;
        end
        
        % 将当前 attribute 的 r_all 和 rmse_all 值存入总的矩阵
        % groupA
        a_for_excel_C_L_A(idx_attribute, :) = reshape(a_CL_all_A', 1, []);
        r_values_for_excel_C_L_A(idx_attribute, :) = r_CL_all_A';
        rmse_values_for_excel_C_L_A(idx_attribute, :) = rmse_CL_all_A';

        a_for_excel_long_axis_A(idx_attribute, :) = reshape(a_long_axis_all_A', 1, []);
        r_values_for_excel_long_axis_A(idx_attribute, :) = r_long_axis_all_A';
        rmse_values_for_excel_long_axis_A(idx_attribute, :) = rmse_long_axis_all_A';

        a_for_excel_short_axis_A(idx_attribute, :) = reshape(a_short_axis_all_A', 1, []);
        r_values_for_excel_short_axis_A(idx_attribute, :) = r_short_axis_all_A';
        rmse_values_for_excel_short_axis_A(idx_attribute, :) = rmse_short_axis_all_A';

        a_for_excel_hue_angle_A(idx_attribute, :) = reshape(a_hue_angle_all_A', 1, []);
        r_values_for_excel_hue_angle_A(idx_attribute, :) = r_hue_angle_all_A';
        rmse_values_for_excel_hue_angle_A(idx_attribute, :) = rmse_hue_angle_all_A';

        a_for_excel_theta_A(idx_attribute, :) = reshape(a_theta_all_A', 1, []);
        r_values_for_excel_theta_A(idx_attribute, :) = r_theta_all_A';
        rmse_values_for_excel_theta_A(idx_attribute, :) = rmse_theta_all_A';

        a_for_excel_alpha_A(idx_attribute, :) = reshape(a_alpha_all_A', 1, []);
        r_values_for_excel_alpha_A(idx_attribute, :) = r_alpha_all_A';
        rmse_values_for_excel_alpha_A(idx_attribute, :) = rmse_alpha_all_A';
        
        % groupB
        a_for_excel_C_L_B(idx_attribute, :) = reshape(a_CL_all_B', 1, []);
        r_values_for_excel_C_L_B(idx_attribute, :) = r_CL_all_B';
        rmse_values_for_excel_C_L_B(idx_attribute, :) = rmse_CL_all_B';

        a_for_excel_long_axis_B(idx_attribute, :) = reshape(a_long_axis_all_B', 1, []);
        r_values_for_excel_long_axis_B(idx_attribute, :) = r_long_axis_all_B';
        rmse_values_for_excel_long_axis_B(idx_attribute, :) = rmse_long_axis_all_B';

        a_for_excel_short_axis_B(idx_attribute, :) = reshape(a_short_axis_all_B', 1, []);
        r_values_for_excel_short_axis_B(idx_attribute, :) = r_short_axis_all_B';
        rmse_values_for_excel_short_axis_B(idx_attribute, :) = rmse_short_axis_all_B';

        a_for_excel_hue_angle_B(idx_attribute, :) = reshape(a_hue_angle_all_B', 1, []);
        r_values_for_excel_hue_angle_B(idx_attribute, :) = r_hue_angle_all_B';
        rmse_values_for_excel_hue_angle_B(idx_attribute, :) = rmse_hue_angle_all_B';

        a_for_excel_theta_B(idx_attribute, :) = reshape(a_theta_all_B', 1, []);
        r_values_for_excel_theta_B(idx_attribute, :) = r_theta_all_B';
        rmse_values_for_excel_theta_B(idx_attribute, :) = rmse_theta_all_B';

        a_for_excel_alpha_B(idx_attribute, :) = reshape(a_alpha_all_B', 1, []);
        r_values_for_excel_alpha_B(idx_attribute, :) = r_alpha_all_B';
        rmse_values_for_excel_alpha_B(idx_attribute, :) = rmse_alpha_all_B';
        
        % 保存拟合参数
        output_folder_params = fullfile('AnalyseResults_p', Dtype, scale_type_origin, "model_fullpara", CT_type, "new", iOr, obs_type, "AB_groups");
        if ~exist(output_folder_params, 'dir')
            mkdir(output_folder_params);
        end
        fullfile(pwd,output_folder_params)
        save(fullfile(output_folder_params, strcat(attribute_serial, '_all_curve_params_AB.mat')), ...
            'a_CL_all_A', 'r_CL_all_A', 'rmse_CL_all_A', ...
            'a_long_axis_all_A', 'r_long_axis_all_A', 'rmse_long_axis_all_A', ...
            'a_short_axis_all_A', 'r_short_axis_all_A', 'rmse_short_axis_all_A', ...
            'a_hue_angle_all_A', 'r_hue_angle_all_A', 'rmse_hue_angle_all_A', ...
            'a_theta_all_A', 'r_theta_all_A', 'rmse_theta_all_A', ...
            'a_alpha_all_A', 'r_alpha_all_A', 'rmse_alpha_all_A', ...
            'a_CL_all_B', 'r_CL_all_B', 'rmse_CL_all_B', ...
            'a_long_axis_all_B', 'r_long_axis_all_B', 'rmse_long_axis_all_B', ...
            'a_short_axis_all_B', 'r_short_axis_all_B', 'rmse_short_axis_all_B', ...
            'a_hue_angle_all_B', 'r_hue_angle_all_B', 'rmse_hue_angle_all_B', ...
            'a_theta_all_B', 'r_theta_all_B', 'rmse_theta_all_B', ...
            'a_alpha_all_B', 'r_alpha_all_B', 'rmse_alpha_all_B', ...
            'nations', 'attribute', 'obs_type', 'groupA_indices', 'groupB_indices');
    end
    
    %% Excel 输出部分
    excel_col_names = nations;
    full_header = [{"Attribute"}, cellstr(excel_col_names)];
    
    % groupA 的 C_L 相关性写入
    excel_filename_C_L_A = fullfile(r_excel_output_folder, strcat('correlation_C_L_', iOr, '_', obs_type, '_groupA.xlsx'));
    writecell([full_header; [cellstr(attribute_names_new(attributes))', num2cell(r_values_for_excel_C_L_A)]], excel_filename_C_L_A, 'Sheet', 'R_values');
    writecell([full_header; [cellstr(attribute_names_new(attributes))', num2cell(rmse_values_for_excel_C_L_A)]], excel_filename_C_L_A, 'Sheet', 'RMSE_values');
    
    % groupB 的 C_L 相关性写入
    excel_filename_C_L_B = fullfile(r_excel_output_folder, strcat('correlation_C_L_', iOr, '_', obs_type, '_groupB.xlsx'));
    writecell([full_header; [cellstr(attribute_names_new(attributes))', num2cell(r_values_for_excel_C_L_B)]], excel_filename_C_L_B, 'Sheet', 'R_values');
    writecell([full_header; [cellstr(attribute_names_new(attributes))', num2cell(rmse_values_for_excel_C_L_B)]], excel_filename_C_L_B, 'Sheet', 'RMSE_values');
    
    % groupA 的长轴相关性写入
    excel_filename_long_axis_A = fullfile(r_excel_output_folder, strcat('correlation_long_axis_', iOr, '_', obs_type, '_groupA.xlsx'));
    writecell([full_header; [cellstr(attribute_names_new(attributes))', num2cell(r_values_for_excel_long_axis_A)]], excel_filename_long_axis_A, 'Sheet', 'R_values');
    writecell([full_header; [cellstr(attribute_names_new(attributes))', num2cell(rmse_values_for_excel_long_axis_A)]], excel_filename_long_axis_A, 'Sheet', 'RMSE_values');
    
    % groupB 的长轴相关性写入
    excel_filename_long_axis_B = fullfile(r_excel_output_folder, strcat('correlation_long_axis_', iOr, '_', obs_type, '_groupB.xlsx'));
    writecell([full_header; [cellstr(attribute_names_new(attributes))', num2cell(r_values_for_excel_long_axis_B)]], excel_filename_long_axis_B, 'Sheet', 'R_values');
    writecell([full_header; [cellstr(attribute_names_new(attributes))', num2cell(rmse_values_for_excel_long_axis_B)]], excel_filename_long_axis_B, 'Sheet', 'RMSE_values');
    
    % groupA 的短轴相关性写入
    excel_filename_short_axis_A = fullfile(r_excel_output_folder, strcat('correlation_short_axis_', iOr, '_', obs_type, '_groupA.xlsx'));
    writecell([full_header; [cellstr(attribute_names_new(attributes))', num2cell(r_values_for_excel_short_axis_A)]], excel_filename_short_axis_A, 'Sheet', 'R_values');
    writecell([full_header; [cellstr(attribute_names_new(attributes))', num2cell(rmse_values_for_excel_short_axis_A)]], excel_filename_short_axis_A, 'Sheet', 'RMSE_values');
    
    % groupB 的短轴相关性写入
    excel_filename_short_axis_B = fullfile(r_excel_output_folder, strcat('correlation_short_axis_', iOr, '_', obs_type, '_groupB.xlsx'));
    writecell([full_header; [cellstr(attribute_names_new(attributes))', num2cell(r_values_for_excel_short_axis_B)]], excel_filename_short_axis_B, 'Sheet', 'R_values');
    writecell([full_header; [cellstr(attribute_names_new(attributes))', num2cell(rmse_values_for_excel_short_axis_B)]], excel_filename_short_axis_B, 'Sheet', 'RMSE_values');
    
    fprintf('已将 %s 的所有相关性矩阵和 RMSE 矩阵写入 Excel 文件（分别保存 groupA 和 groupB）。\n', obs_type);
    
    %% 输出回退记录 xlsx
    if ~isempty(fallback_records)
        fallback_header = {'Nation', 'Attribute', 'Group', 'Reason'};
        fallback_sheet = [fallback_header; fallback_records];
        fallback_xlsx_file = fullfile(r_excel_output_folder, 'C_L_fallback_report.xlsx');
        writecell(fallback_sheet, fallback_xlsx_file);
        fprintf('  回退记录已写入: %s (%d 条)\n', fallback_xlsx_file, size(fallback_records, 1));
    else
        fprintf('  无 C_L 回退事件。\n');
    end
end

fprintf('脚本执行完成！\n');