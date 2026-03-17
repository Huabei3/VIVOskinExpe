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
'f09i', 'f10i','m09i', 'm10i'};
n_para = 21;
iOr='i';

CT_type="3k";

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

% 定义线条样式和散点样式（根据i_obs索引选择）
line_styles = {'-', '--', ':', '-.'};  % 为不同i_obs设置不同线条样式
plot_styles = {'o', '+', 'd', '^'};    % 为不同i_obs设置不同散点样式
genders = ["f", "m"]; % 定义性别数组

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

Dtype = 'noCAT';
scale_type_origin="unscaled";

%% 直接按重塑后的结构加载和存储数据
i_obs = 1; % 只处理non_model
obs_type = "non_model";

% 初始化重塑后的数据结构
average_reshaped = cell(5, 1); % 5个人种
par_reshaped = cell(3, 5, 1);  % 3种观察者类型 × 5个人种
lab_fit_reshaped = cell(3, 5, 1); % 3种观察者类型 × 5个人种
file_missing={};

for i_nation = 1:length(nations)
    % 获取当前人种的所有索引
    nation=nations(i_nation);
    curr_nation_indices = nation_indices{i_nation};
    % 为当前人种组合初始化数据数组
    n_subjects = length(curr_nation_indices);
    par_current = zeros(n_para, 6, n_subjects, length(attributes));
    lab_fit_current = zeros(n_para, 3, n_subjects, length(attributes));
    average_current = zeros(n_para, 3, n_subjects);
    % 为每个subject加载数据
    for i_subject = 1:n_subjects
        subject_idx = curr_nation_indices(i_subject);
        lastPart = lastParts{subject_idx};
        iOr = lastPart(end);
        % 加载平均肤色数据
        average_file = fullfile("aveSkin", lastPart, "autoNhand_scaleoverLUT.mat");
        if exist(average_file, 'file')
            average_data = load(average_file);
            average_current(:, :, i_subject) = average_data.average_lab_all(:, 1:3);
        else
            average_current(:, :, i_subject) = NaN(n_para, 3);
        end
        % 循环处理每个 attribute
        for i_attr = 1:length(attributes)
            attribute = attributes(i_attr);
            attribute_serial = strcat(sprintf("%02d", attribute), attribute_names_new(attribute));
            % 定义路径
            source_file = fullfile('AnalyseResults_p_free', Dtype, scale_type_origin, lastPart, obs_type, attribute_serial, 'ellipPara', 'fitRes.mat');
            % 加载数据
            if exist(source_file, 'file')
                par_all_data = load(source_file);
                par_all = par_all_data.par_all;
                par_all=[par_all;nan(size(par_current,1)-size(par_all,1),size(par_all,2))];
                par_current(:, :, i_subject, i_attr) = par_all;
                lab_bf=[average_current(:, 1, i_subject), par_all(:,4:5)];
                lab_fit_current(:, :, i_subject, i_attr) = lab_bf;
            else
                par_current(:, :, i_subject, i_attr) = NaN(n_para, 6);
                lab_fit_current(:, :, i_subject, i_attr) = NaN(n_para, 3);
                file_missing{end+1,1}=lastPart;
                file_missing{end,2}=obs_type;
                file_missing{end,3}=attribute_serial;
            end
        end
    end
    % 存储到重塑后的数据结构中
    par_reshaped{i_obs, i_nation} = par_current;
    lab_fit_reshaped{i_obs, i_nation} = lab_fit_current;
    % average_reshaped只需要存储一次（不依赖于观察者类型）
    if i_obs == 1
        average_reshaped{i_nation} = average_current;
    end
end

%% 为每个属性处理数据，加载现有参数并计算rho和p值

% 初始化结果存储数组（循环外）
rho_values_for_excel = zeros(length(attributes), length(nations));
p_values_for_excel = zeros(length(attributes), length(nations));
r_values_for_excel = zeros(length(attributes), length(nations));
rmse_values_for_excel = zeros(length(attributes), length(nations));

% 遍历属性
for idx_attribute = 1:length(attributes)
    attribute = attributes(idx_attribute);
    attribute_serial = strcat(sprintf("%02d", attribute), attribute_names_new(attribute));
    
    % 按人种分组处理
    for i_nation = 1:length(nations)
        nation = nations(i_nation);
        
        % 加载现有拟合参数
        params_file_path = fullfile('AnalyseResults_p_free', Dtype, scale_type_origin, "model_fullpara", CT_type, iOr, obs_type, strcat(attribute_serial, '_all_curve_params.mat'));
        
        if exist(params_file_path, 'file')
            params_data = load(params_file_path);
            a_C_L = params_data.a_CL_all(i_nation, :);
            
            % 获取当前数据
            lab_data = lab_fit_reshaped{i_obs, i_nation}(indices_target, :, :, attribute);
            par_data = par_reshaped{i_obs, i_nation}(indices_target, :, :, attribute);
            
            % 重组数据
            [n_targets, n_channels_lab, n_subjects] = size(lab_data);
            [~, n_channels_par, ~] = size(par_data);
            lab_g = reshape(permute(lab_data, [1 3 2]), n_targets * n_subjects, n_channels_lab);
            par_g = reshape(permute(par_data, [1 3 2]), n_targets * n_subjects, n_channels_par);
            
            % 检查并移除包含NaN的行
            valid_rows_lab = ~any(isnan(lab_g), 2);
            valid_rows_par = ~any(isnan(par_g), 2);
            valid_overall_rows = valid_rows_lab & valid_rows_par;
            L_all = lab_g(valid_overall_rows, 1);
            
            % 计算C_all
            par_all_valid = par_g(valid_overall_rows, :);
            C_all = sqrt(par_all_valid(:,4).^2 + par_all_valid(:,5).^2);
            
            % 使用加载的参数计算拟合值
            y_fit = a_C_L(1) .* log(L_all) + a_C_L(2);
            
            % 计算Pearson相关系数r
            r = corr(L_all, C_all, 'Type', 'Pearson');
            r_values_for_excel(idx_attribute, i_nation) = r;
            
            % 计算RMSE
            rmse = sqrt(mean((C_all - y_fit).^2));
            rmse_values_for_excel(idx_attribute, i_nation) = rmse;
            
            % 计算Spearman相关系数rho和p值
            [rho, p] = corr(L_all, C_all, 'Type', 'Spearman');
            rho_values_for_excel(idx_attribute, i_nation) = rho;
            p_values_for_excel(idx_attribute, i_nation) = p;
            
        else
            warning('无法找到参数文件: %s', params_file_path);
            rho_values_for_excel(idx_attribute, i_nation) = NaN;
            p_values_for_excel(idx_attribute, i_nation) = NaN;
            r_values_for_excel(idx_attribute, i_nation) = NaN;
            rmse_values_for_excel(idx_attribute, i_nation) = NaN;
        end
    end
end

%% 将所有结果一次性写入Excel（循环外）
r_excel_output_folder = fullfile("AnalyseResults_p_free", Dtype, scale_type_origin, "model_fullpara", CT_type, iOr, obs_type);
if ~exist(r_excel_output_folder, 'dir')
    mkdir(r_excel_output_folder);
end

excel_col_names = nations;
full_header = ["Attribute", excel_col_names];

% 将rho和p值写入Excel
excel_filename_rho = fullfile(r_excel_output_folder, strcat('correlation_rho_C_L_', iOr, '_', obs_type, '.xlsx'));
writematrix([full_header; [cellstr(attribute_names_new(attributes))', num2cell(rho_values_for_excel)]], excel_filename_rho, 'Sheet', 'Rho_values');
writematrix([full_header; [cellstr(attribute_names_new(attributes))', num2cell(p_values_for_excel)]], excel_filename_rho, 'Sheet', 'P_values');

% 同时保存r和RMSE值，保持与原脚本一致性
excel_filename_C_L = fullfile(r_excel_output_folder, strcat('correlation_C_L_', iOr, '_', obs_type, '.xlsx'));
% 检查文件是否存在
if exist(excel_filename_C_L, 'file')
    % 如果文件存在，读取现有的a参数sheet
    try
        a_for_excel_C_L = readmatrix(excel_filename_C_L, 'Sheet', 'a');
        % 将r和RMSE数据追加到现有文件
        writematrix([full_header; [cellstr(attribute_names_new(attributes))', num2cell(r_values_for_excel)]], excel_filename_C_L, 'Sheet', 'R_values');
        writematrix([full_header; [cellstr(attribute_names_new(attributes))', num2cell(rmse_values_for_excel)]], excel_filename_C_L, 'Sheet', 'RMSE_values');
    catch
        % 如果读取失败，只写入r和RMSE数据
        writematrix([full_header; [cellstr(attribute_names_new(attributes))', num2cell(r_values_for_excel)]], excel_filename_C_L, 'Sheet', 'R_values');
        writematrix([full_header; [cellstr(attribute_names_new(attributes))', num2cell(rmse_values_for_excel)]], excel_filename_C_L, 'Sheet', 'RMSE_values');
    end
else
    % 如果文件不存在，创建新文件但不包含a参数sheet
    writematrix([full_header; [cellstr(attribute_names_new(attributes))', num2cell(r_values_for_excel)]], excel_filename_C_L, 'Sheet', 'R_values');
    writematrix([full_header; [cellstr(attribute_names_new(attributes))', num2cell(rmse_values_for_excel)]], excel_filename_C_L, 'Sheet', 'RMSE_values');
end

fprintf('已将所有属性的 Spearman 相关系数 rho、p 值、Pearson 相关系数 r 和 RMSE 写入 Excel 文件。\n');

%% 主脚本结束