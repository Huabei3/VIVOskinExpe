%% scatter_L_depend_BIC.m
% 基于 scatter_L_depend_new.m，对 C*-L* 关系进行多种候选公式拟合
% 保存每个 attribute × nation × formula 的 k/RSS/BIC 到 mat 文件
% 供 XLSX_BIC_res.m 读取并写入 XLSX
%
% 用法: 直接运行即可，输出保存到:
%   AnalyseResults_p/<Dtype>/<scale_type>/model_fullpara/<CT_type>/new/<iOr>/<obs_type>/
%   文件名: BIC_results_all.mat

close all; clc; clear;
addpath("utils\")
%% ========== 配置 ==========
% 拟合公式类型编号:
%   1 = 常数       C = a1                        (k=1)
%   2 = 线性       C = a1*L + a2                 (k=2)
%   3 = 二次       C = a1*L^2 + a2*L + a3        (k=3)
%   4 = 对数       C = a1*log(L) + a2            (k=2)
%   5 = 分段线性-常数 C = a1*L+a2 (L<=L0), C=a3 (L>L0) (k=4, L0拟合)
fit_CL_types = [1, 2, 3, 4, 5];

formula_names = { ...
    "Constant", ...       % 1
    "Linear", ...         % 2
    "Quadratic", ...      % 3
    "Logarithmic", ...    % 4
    "Piecewise-Lin-Con"   % 5
};

%% ========== 定义 attributes（与 scatter_L_depend_new.m 一致）==========
attributes = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
attribute_names_new = ["Preference", "Attractiveness", "Feminine", "Cooperative", ...
    "Youth", "Healthy", "Fidelity", "Harmony", "Fair", "Ruddy"];

lastParts = {'f04i', 'f05i', 'f06i', 'm04i', 'm05i', 'm06i',...
'f01i', 'f02i', 'f03i', 'm01i', 'm02i', 'm03i',...
'f07i', 'f08i','m07i', 'm08i',...
'f09i', 'f10i','m09i', 'm10i'}; n_para = 21; iOr='i';
% lastParts = {'f04r', 'f05r', 'f06r', 'm04r', 'm05r', 'm06r',...
% 'f01r', 'f02r', 'f03r', 'm01r', 'm02r', 'm03r',...
% 'f07r', 'f08r','m07r', 'm08r',...
% 'f09r', 'f10r','m09r', 'm10r'};n_para = 14;iOr='r';

CT_type = "d65";
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

wd65 = [94.811, 100.00, 107.304];
datai_file = 'D:\work\VIVOskinExpe\renderCode\calibResults\datai_ipv18_3.mat';
LUT = load(datai_file);
XYZw_LUT = LUT.XYZw;

%% ========== 人种分组（固定5组：AS, CA, SA, AF, all）==========
nations = ["AS", "CA", "SA", "AF", "all"];
nation_indices = cell(5, 1);
nation_indices{1} = 1:6;    % AS
nation_indices{2} = 7:12;   % CA
nation_indices{3} = 13:16;  % SA
nation_indices{4} = 17:20;  % AF
nation_indices{5} = 1:20;   % all
label_type = "nation";

%% ========== 加载数据（复用 scatter_L_depend_new.m 的 mat 文件）==========
Dtype = 'efit_p';
scale_type_origin = "unscaled";

% 尝试直接加载 scatter_L_depend_new.m 保存的 mat 文件
mat_data_file = fullfile("ellip_pic_p", Dtype, CT_type, ...
    strcat("data_unscaled_reshaped_", iOr, ".mat"));

if exist(mat_data_file, 'file')
    fprintf('加载已有数据文件: %s\n', mat_data_file);
    data_loaded = load(mat_data_file);
    par_reshaped = data_loaded.par_reshaped;
    lab_fit_reshaped = data_loaded.lab_fit_reshaped;
else
    error('数据文件不存在: %s\n请先运行 scatter_L_depend_new.m 生成数据。', mat_data_file);
end

%% ========== 初始化结果存储 ==========
% 维度: attribute × nation × formula
% 每个元素存储: a_val, RSS, BIC, k
n_attributes = length(attributes);
n_nations = length(nations);
n_formulas = length(fit_CL_types);

a_BIC = cell(n_attributes, n_nations, n_formulas);
RSS_BIC = NaN(n_attributes, n_nations, n_formulas);
BIC_val = NaN(n_attributes, n_nations, n_formulas);
k_val = NaN(n_attributes, n_nations, n_formulas);

%% ========== 遍历 attribute × nation × formula ==========
obs_type = "non_model";
for idx_attribute = 1:n_attributes
    attribute = attributes(idx_attribute);
    attribute_serial = strcat(sprintf("%02d", attribute), attribute_names_new(attribute));
    attribute_serial = gen_attribute_new(attribute_serial);
    fprintf('\n===== %s =====\n', attribute_serial);

    for i_nation = 1:n_nations
        nation = nations(i_nation);
        curr_nation_indices = nation_indices{i_nation};

        % Fidelity 用 model_group (i_obs=2)，其余用 non_model (i_obs=1)
        if attribute == 7
            i_obs_used = 2;
        else
            i_obs_used = 1;
        end

        % 提取 L* 和 C* 数据（与 scatter_L_depend_new.m 相同逻辑）
        lab_data = lab_fit_reshaped{i_obs_used, i_nation}(indices_target, :, :, attribute);
        par_data = par_reshaped{i_obs_used, i_nation}(indices_target, :, :, attribute);

        [n_targets, n_channels_lab, n_subjects] = size(lab_data);
        lab_g = reshape(permute(lab_data, [1 3 2]), n_targets * n_subjects, n_channels_lab);
        par_g = reshape(permute(par_data, [1 3 2]), n_targets * n_subjects, size(par_data, 2));

        valid_rows_lab = ~any(isnan(lab_g), 2);
        valid_rows_par = ~any(isnan(par_g), 2);
        valid_overall = valid_rows_lab & valid_rows_par;

        L_all = lab_g(valid_overall, 1);
        par_all_valid = par_g(valid_overall, :);
        C_all = sqrt(par_all_valid(:,4).^2 + par_all_valid(:,5).^2);

        fprintf('  %s: n=%d 数据点\n', nation, length(L_all));

        % 对每个候选公式进行拟合
        for j = 1:n_formulas
            fit_CL_type = fit_CL_types(j);
            [a_val, RSS, bic, k] = model_C_L_BIC(L_all, C_all, fit_CL_type);

            a_BIC{idx_attribute, i_nation, j} = a_val;
            RSS_BIC(idx_attribute, i_nation, j) = RSS;
            BIC_val(idx_attribute, i_nation, j) = bic;
            k_val(idx_attribute, i_nation, j) = k;

            fprintf('    %s (k=%d): BIC=%.2f, RSS=%.4f\n', ...
                formula_names{j}, k, bic, RSS);
        end
    end
end

%% ========== 保存结果 ==========
output_folder = fullfile('AnalyseResults_p', Dtype, scale_type_origin, ...
    "model_fullpara", CT_type, "new", iOr, obs_type);
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end

save(fullfile(output_folder, 'BIC_results_all.mat'), ...
    'a_BIC', 'RSS_BIC', 'BIC_val', 'k_val', ...
    'attributes', 'attribute_names_new', 'nations', ...
    'fit_CL_types', 'formula_names', 'Dtype', 'CT_type', 'iOr', 'obs_type');

fprintf('\n========== 完成！==========\n');
fprintf('结果已保存至: %s\n', fullfile(pwd, output_folder, 'BIC_results_all.mat'));
fprintf('运行 XLSX_BIC_res.m 可将结果写入 XLSX 文件。\n');
