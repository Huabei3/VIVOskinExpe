%% gen_BIC_xlsx_fr_para.m
% 基于 scatter_L_depend_BIC.m 保存的拟合参数，重新计算 RSS、BIC、Pearson r
% 并保存每个样本点的预测值与目标值到 .mat，生成 Table 6.1 风格 xlsx
%
% 用法: 直接运行即可
% 输出:
%   AnalyseResults_p/efit_p/unscaled/model_fullpara/d65/new/i/non_model/
%     BIC_recomputed_from_para.xlsx     — 表 6.1 风格，仅 Preference
%     BIC_recomputed_pred_points.mat    — 每样本点预测值 & 目标值
%
% 说明:
%   (a) scatter_L_depend_BIC.m 拟合了全部 10 个 attribute（不止 Preference）
%   (b) 本脚本仅生成 Preference 的表格（与论文表 6.1 对应）

close all; clc; clear;
addpath("utils\");

%% ========== 配置 ==========
Dtype = 'efit_p';
scale_type_origin = "unscaled";
CT_type = "d65";
iOr = 'i';
obs_type = "non_model";

% 候选公式（与 scatter_L_depend_BIC.m 一致）
formula_names = {"Constant", "Linear", "Quadratic", "Logarithmic", "Piecewise-Lin-Con"};
n_formulas = length(formula_names);

% 每个公式的参数名
param_names_cell = {
    {'a1'};
    {'a1', 'a2'};
    {'a1', 'a2', 'a3'};
    {'a1', 'a2'};
    {'a1', 'a2', 'a3', 'L0'}
};

% 仅 Preference (attribute=1)
attribute = 1;
attr_name = "Preference";
attr_serial = sprintf("01%s", attr_name);

% 人种分组（与 scatter_L_depend_BIC.m 一致）
nations = ["AS", "CA", "SA", "AF", "all"];
nations_long = ["Asian (AS)", "Caucasian (CA)", "South Asian (SA)", "African (AF)", "All"];
nation_indices = cell(5, 1);
nation_indices{1} = 1:6;
nation_indices{2} = 7:12;
nation_indices{3} = 13:16;
nation_indices{4} = 17:20;
nation_indices{5} = 1:20;
n_nations = length(nations);

% CT_type 对应的目标索引
indices_target = [5, 12, 19];

%% ========== 加载 L* 和 C* 原始数据 ==========
mat_data_file = fullfile("ellip_pic_p", Dtype, CT_type, ...
    strcat("data_unscaled_reshaped_", iOr, ".mat"));

if ~exist(mat_data_file, 'file')
    error('数据文件不存在: %s\n请先运行 scatter_L_depend_new.m 生成数据。', mat_data_file);
end

fprintf('=== 加载原始数据: %s ===\n', mat_data_file);
data_loaded = load(mat_data_file);
par_reshaped = data_loaded.par_reshaped;
lab_fit_reshaped = data_loaded.lab_fit_reshaped;
fprintf('数据加载完成。\n');

%% ========== BIC 参数文件路径 ==========
BIC_base_folder = fullfile('AnalyseResults_p', Dtype, scale_type_origin, ...
    "model_fullpara", CT_type, "new", iOr, obs_type, "BIC");

%% ========== 输出路径 ==========
output_folder = fullfile('AnalyseResults_p', Dtype, scale_type_origin, ...
    "model_fullpara", CT_type, "new", iOr, obs_type);
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end

%% ========== 初始化结果存储 ==========
% 每公式 × 每 nation: RSS, BIC, r, k, n
RSS_arr = NaN(n_nations, n_formulas);
BIC_arr = NaN(n_nations, n_formulas);
r_arr   = NaN(n_nations, n_formulas);
k_arr   = NaN(n_nations, n_formulas);
n_arr   = NaN(n_nations, n_formulas);

% 存储每样本点的预测值 & 目标值（用于调试/验证）
% pred_points{j, i_nat} 包含 formula j × nation i_nat 的 [L, C_target, C_pred]
pred_points = cell(n_formulas, n_nations);

%% ========================================================================
%%  遍历 5 个 formula，从 saved paras 重算 RSS/BIC/r
%% ========================================================================
fprintf('\n========== 处理 Preference (attribute 1) ==========\n\n');

for j = 1:n_formulas
    formula_name = formula_names{j};
    formula_folder = fullfile(BIC_base_folder, formula_name);
    param_names = param_names_cell{j};
    n_params = length(param_names);
    
    fprintf('--- 公式: %s (%d/%d) ---\n', formula_name, j, n_formulas);
    
    % 加载该 formula 的 Preference 拟合参数
    mat_file = fullfile(formula_folder, strcat(attr_serial, '_BIC_curve_params.mat'));
    
    if ~exist(mat_file, 'file')
        warning('  文件不存在，跳过: %s', mat_file);
        continue;
    end
    
    data = load(mat_file);
    a_val_all = data.a_val_all;   % cell [5×1]
    
    for i_nat = 1:n_nations
        nation = nations(i_nat);
        
        % 跳过参数为 NaN 的 nation
        params = a_val_all{i_nat};
        if isempty(params) || all(isnan(params))
            fprintf('  %s: 参数为空，跳过\n', nation);
            continue;
        end
        
        % 提取 L* 和 C* 数据（Fidelity 用 model_group，Preference 用 i_obs=1）
        i_obs_used = 1;
        
        lab_data = lab_fit_reshaped{i_obs_used, i_nat}(indices_target, :, :, attribute);
        par_data = par_reshaped{i_obs_used, i_nat}(indices_target, :, :, attribute);
        
        [n_targets, ~, n_subjects] = size(lab_data);
        lab_g = reshape(permute(lab_data, [1 3 2]), n_targets * n_subjects, 3);
        par_g = reshape(permute(par_data, [1 3 2]), n_targets * n_subjects, size(par_data, 2));
        
        valid_rows = ~any(isnan(lab_g), 2) & ~any(isnan(par_g), 2);
        
        L_valid = lab_g(valid_rows, 1);
        C_target = sqrt(par_g(valid_rows, 4).^2 + par_g(valid_rows, 5).^2);
        
        % 用拟合参数预测 C*
        C_pred = predict_chroma(L_valid, params, j);
        
        % 保存每样本点数据
        pred_points{j, i_nat} = struct(...
            'L', L_valid, ...
            'C_target', C_target, ...
            'C_pred', C_pred, ...
            'formula', formula_name, ...
            'nation', nation, ...
            'params', params);
        
        % 计算 RSS
        residuals = C_target - C_pred;
        RSS = sum(residuals .^ 2);
        RSS_arr(i_nat, j) = RSS;
        
        % 样本量
        n_val = length(C_target);
        n_arr(i_nat, j) = n_val;
        
        % 计算 BIC: BIC = n * log(RSS/n) + k * log(n)
        k = length(params);
        k_arr(i_nat, j) = k;
        
        BIC = NaN;
        if RSS > 0 && n_val > 0
            BIC = n_val * log(RSS / n_val) + k * log(n_val);
        end
        BIC_arr(i_nat, j) = BIC;
        
        % 计算 Pearson r
        r_val = NaN;
        if length(C_target) >= 3
            r_val = corr(C_target, C_pred, 'Type', 'Pearson');
        end
        r_arr(i_nat, j) = r_val;
        
        fprintf('  %s: n=%d, k=%d, RSS=%.4f, BIC=%.2f, r=%.4f\n', ...
            nation, n_val, k, RSS, BIC, r_val);
    end
end

%% ========== 保存每样本点预测数据到 .mat ==========
mat_output_path = fullfile(output_folder, 'BIC_recomputed_pred_points.mat');
save(mat_output_path, 'pred_points', 'formula_names', 'nations', 'nations_long', ...
    'attribute', 'attr_name');
fprintf('\n每样本点预测数据已保存: %s\n', mat_output_path);

%% ========================================================================
%%  生成 Table 6.1 风格 xlsx（行=指标, 列=公式）
%%  指标顺序: k, AS RSS, AS BIC, AS r, CA RSS, CA BIC, CA r, ...
%% ========================================================================
fprintf('\n========== 生成 Table 6.1 风格 xlsx ==========\n');

% 构建行标题
row_headers = {"k"};
for i_nat = 1:n_nations
    row_headers{end + 1} = sprintf("%s RSS", nations(i_nat));
    row_headers{end + 1} = sprintf("%s BIC", nations(i_nat));
    row_headers{end + 1} = sprintf("%s r", nations(i_nat));
end
n_rows = length(row_headers);

% 构建表格: (n_rows+1) × (n_formulas+1)，+1 为表头
sheet_cell = cell(n_rows + 1, n_formulas + 1);

% 第一行：列标题
sheet_cell{1, 1} = 'Metric \\ Formula';
for j = 1:n_formulas
    sheet_cell{1, j + 1} = formula_names{j};
end

% 数据行
for row_i = 1:n_rows
    sheet_cell{row_i + 1, 1} = row_headers{row_i};
    
    if row_i == 1
        % k 行
        for j = 1:n_formulas
            sheet_cell{row_i + 1, j + 1} = k_arr(1, j);  % k 不随 nation 变化, 取 AS 的
        end
    else
        % 其余行: RSS / BIC / r
        % row_i = 2 → AS RSS, row_i = 3 → AS BIC, row_i = 4 → AS r, ...
        metric_row = row_i - 1;                   % 1-based metric index: 1=RSS,2=BIC,3=r,4=RSS,5=BIC,...
        nation_idx = ceil(metric_row / 3);        % 第几个 nation
        metric_type = mod(metric_row - 1, 3) + 1; % 1=RSS, 2=BIC, 3=r
        
        for j = 1:n_formulas
            if metric_type == 1
                val = RSS_arr(nation_idx, j);
            elseif metric_type == 2
                val = BIC_arr(nation_idx, j);
            else
                val = r_arr(nation_idx, j);
            end
            sheet_cell{row_i + 1, j + 1} = val;
        end
    end
end

% 写入 xlsx（仅一个 sheet: 01Preference）
xlsx_output_path = fullfile(output_folder, 'BIC_recomputed_from_para.xlsx');
if exist(xlsx_output_path, 'file')
    delete(xlsx_output_path);
end

sheet_name = sprintf("%02d_%s", attribute, attr_name);
writecell(sheet_cell, xlsx_output_path, 'Sheet', sheet_name);

fprintf('已写入 sheet: %s\n', sheet_name);
fprintf('xlsx 已保存: %s\n', xlsx_output_path);

%% ========================================================================
%%  摘要打印（方便直接复制到论文）
%% ========================================================================
fprintf('\n========== Table 6.1 摘要（Preference only）==========\n');
fprintf('%-20s', 'Formula');
for i_nat = 1:n_nations
    fprintf('%10s BIC', nations(i_nat));
    fprintf('%10s r', nations(i_nat));
end
fprintf('\n');

for j = 1:n_formulas
    fprintf('%-20s', formula_names{j});
    for i_nat = 1:n_nations
        fprintf('%10.2f', BIC_arr(i_nat, j));
        fprintf('%10.4f', r_arr(i_nat, j));
    end
    fprintf('\n');
end

fprintf('\n========== 全部完成！==========\n');
fprintf('输出文件:\n');
fprintf('  1. %s\n', mat_output_path);
fprintf('  2. %s\n', xlsx_output_path);

%% ========================================================================
%%  辅助函数：根据公式编号和参数从 L* 预测 C*
%% ========================================================================
function C_pred = predict_chroma(L, a, formula_idx)
    % predict_chroma  根据 L* 和拟合参数 a 计算预测的 C* 值
    %
    % 公式定义（与 model_C_L_BIC.m 一致）:
    %   1 = Constant:       C = a1
    %   2 = Linear:         C = a1*L + a2
    %   3 = Quadratic:      C = a1*L^2 + a2*L + a3
    %   4 = Logarithmic:    C = a1*log(L) + a2
    %   5 = Piecewise-Lin:  C = a1*L + a2 (L<=L0), C = a3 (L>L0)

    switch formula_idx
        case 1  % Constant: C = a1
            C_pred = a(1) * ones(size(L));

        case 2  % Linear: C = a1*L + a2
            C_pred = a(1) * L + a(2);

        case 3  % Quadratic: C = a1*L^2 + a2*L + a3
            C_pred = a(1) * L.^2 + a(2) * L + a(3);

        case 4  % Logarithmic: C = a1*log(L) + a2
            C_pred = a(1) * log(L) + a(2);

        case 5  % Piecewise Linear-Constant: C = a1*L+a2 (L<=L0), C = a3 (L>L0)
            L0 = a(4);
            C_pred = zeros(size(L));
            low = L <= L0;
            high = ~low;
            C_pred(low)  = a(1) * L(low) + a(2);
            C_pred(high) = a(3);

        otherwise
            error('未知的 formula_idx: %d（应为 1~5）', formula_idx);
    end
end
