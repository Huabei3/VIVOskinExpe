%% split_BIC_by_formula.m
%  从已有的 BIC_results_all.mat 中读取数据
%  按 formula 拆分，分别保存到子文件夹
%  保存格式参照 scatter_L_depend_new.m 的 _all_curve_params.mat:
%    每个 formula 一个子文件夹，每个 attribute 一个 mat 文件

clc; clear;

%% ========== 加载 BIC_results_all.mat ==========
Dtype = 'efit_p';
scale_type_origin = "unscaled";
CT_type = "d65";
iOr = 'i';
obs_type = "non_model";

base_dir = fullfile('D:\work\VIVOskinExpe\analyze\AnalyseResults_p', ...
    Dtype, scale_type_origin, "model_fullpara", CT_type, "new", iOr, obs_type);

mat_file = fullfile(base_dir, 'BIC_results_all.mat');
if ~exist(mat_file, 'file')
    error('文件不存在: %s', mat_file);
end

data = load(mat_file);
a_BIC = data.a_BIC;
RSS_BIC = data.RSS_BIC;
BIC_val = data.BIC_val;
k_val = data.k_val;
attributes = data.attributes;
attribute_names_new = data.attribute_names_new;
nations = data.nations;
fit_CL_types = data.fit_CL_types;
formula_names = data.formula_names;

n_attributes = length(attributes);
n_nations = length(nations);
n_formulas = length(fit_CL_types);

fprintf('a_BIC 维度: %s\n', mat2str(size(a_BIC)));
fprintf('  dim1 = %d (attributes)\n', n_attributes);
fprintf('  dim2 = %d (nations)\n', n_nations);
fprintf('  dim3 = %d (formulas)\n', n_formulas);

%% ========== 按 formula × attribute 拆分保存 ==========
for j = 1:n_formulas
    formula_name = formula_names{j};
    formula_folder = fullfile(base_dir, "BIC", formula_name);
    if ~exist(formula_folder, 'dir')
        mkdir(formula_folder);
    end

    for idx_attr = 1:n_attributes
        attribute = attributes(idx_attr);
        attr_name = attribute_names_new{idx_attr};
        attr_serial = sprintf("%02d%s", attribute, attr_name);

        % 提取当前 formula × attribute 的数据（跨 nation）
        a_val_all = squeeze(a_BIC(idx_attr, :, j));   % [n_nations × n_params] cell
        RSS_all   = RSS_BIC(idx_attr, :, j)';          % [n_nations × 1]
        BIC_all   = BIC_val(idx_attr, :, j)';           % [n_nations × 1]
        k_all     = k_val(idx_attr, :, j)';             % [n_nations × 1]

        % 保存格式与 scatter_L_depend_new.m 的 _all_curve_params.mat 对齐
        output_file = fullfile(formula_folder, ...
            strcat(attr_serial, '_BIC_curve_params.mat'));

        save(output_file, ...
            'a_val_all', 'RSS_all', 'BIC_all', 'k_all', ...
            'nations', 'attribute', 'attr_name', 'formula_name', ...
            'Dtype', 'CT_type', 'iOr', 'obs_type');
    end

    fprintf('已保存 formula: %s (%d attributes)\n', formula_name, n_attributes);
end

%% ========== 同时也保存一份汇总到 BIC 文件夹根目录 ==========
summary_file = fullfile(base_dir, "BIC", "BIC_results_all.mat");
save(summary_file, ...
    'a_BIC', 'RSS_BIC', 'BIC_val', 'k_val', ...
    'attributes', 'attribute_names_new', 'nations', ...
    'fit_CL_types', 'formula_names', 'Dtype', 'CT_type', 'iOr', 'obs_type');
fprintf('\n汇总文件也已保存: %s\n', summary_file);

fprintf('\n========== 完成！==========\n');
