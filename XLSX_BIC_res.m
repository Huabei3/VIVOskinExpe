%% XLSX_BIC_res.m
% 读取 scatter_L_depend_BIC.m 输出的 BIC_results_all.mat
% 为每个 attribute 生成一个 sheet，写入 XLSX 文件
%
% 转置后的格式 (每个 sheet):
%   行 = 参数 (k, AS RSS, AS BIC, CA RSS, CA BIC, ...)
%   列 = 候选公式 (Constant, Linear, Quadratic, Logarithmic, Piecewise-Lin-Con)

clc; clear;
addpath("utils\");

%% ========== 加载 BIC 结果 ==========
Dtype = 'efit_p';
scale_type_origin = "unscaled";
CT_type = "d65";
iOr = 'i';
obs_type = "non_model";

mat_file = fullfile('AnalyseResults_p', Dtype, scale_type_origin, ...
    "model_fullpara", CT_type, "new", iOr, obs_type, 'BIC_results_all.mat');

if ~exist(mat_file, 'file')
    error('BIC 结果文件不存在: %s\n请先运行 scatter_L_depend_BIC.m', mat_file);
end

data = load(mat_file);
a_BIC = data.a_BIC;
RSS_BIC = data.RSS_BIC;
BIC_val = data.BIC_val;
k_val = data.k_val;
attributes = data.attributes;
attribute_names_new = data.attribute_names_new;
nations = data.nations;
formula_names = data.formula_names;

n_attributes = length(attributes);
n_nations = length(nations);
n_formulas = length(formula_names);

%% ========== 构建 XLSX 数据 (转置结构) ==========
% 参数行: k, <nation1> RSS, <nation1> BIC, <nation2> RSS, <nation2> BIC, ...
% 列: Formula1, Formula2, ..., FormulaN

% 构建行标题 (参数名)
row_headers = build_row_headers(nations);  % {'k', 'AS RSS', 'AS BIC', 'CA RSS', 'CA BIC', ...}
n_rows = length(row_headers);

% 初始化所有 sheet 数据 (转置: 行=参数, 列=公式)
all_sheet_data = cell(n_rows + 1, n_formulas + 1, n_attributes);  % +1 for headers

for idx_attribute = 1:n_attributes
    % 第一行：列标题 (公式名称)
    all_sheet_data{1, 1, idx_attribute} = 'Parameter';  % 左上角单元格
    for j = 1:n_formulas
        all_sheet_data{1, j + 1, idx_attribute} = formula_names{j};
    end

    % 填充数据行
    for row_param = 1:n_rows
        % 第一列：参数名称
        all_sheet_data{row_param + 1, 1, idx_attribute} = row_headers{row_param};

        % 填充各公式的数据
        for j = 1:n_formulas
            if row_param == 1
                % 第一行：k 值
                val = k_val(idx_attribute, 1, j);
                if isnan(val)
                    all_sheet_data{row_param + 1, j + 1, idx_attribute} = "N/A";
                else
                    all_sheet_data{row_param + 1, j + 1, idx_attribute} = val;
                end
            else
                % 其他行：RSS 或 BIC 值
                % row_param >= 2 对应 nations 的数据
                % row_param = 2 -> nation 1 RSS
                % row_param = 3 -> nation 1 BIC
                % row_param = 4 -> nation 2 RSS
                % row_param = 5 -> nation 2 BIC
                % ...

                nation_idx = ceil((row_param - 1) / 2);
                is_bic = mod(row_param - 1, 2) == 0;  % true for BIC, false for RSS

                if is_bic
                    val = BIC_val(idx_attribute, nation_idx, j);
                else
                    val = RSS_BIC(idx_attribute, nation_idx, j);
                end

                if isnan(val)
                    all_sheet_data{row_param + 1, j + 1, idx_attribute} = "N/A";
                else
                    all_sheet_data{row_param + 1, j + 1, idx_attribute} = val;
                end
            end
        end
    end
end

%% ========== 写入 XLSX ==========
output_folder = fullfile('AnalyseResults_p', Dtype, scale_type_origin, ...
    "model_fullpara", CT_type, "new", iOr, obs_type);
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end

xlsx_path = fullfile(output_folder, 'BIC_results.xlsx');

% 如果文件已存在，先删除（避免残留 sheet）
if exist(xlsx_path, 'file')
    delete(xlsx_path);
end

for idx_attribute = 1:n_attributes
    attribute = attributes(idx_attribute);
    sheet_name = sprintf("%02d%s", attribute, attribute_names_new{idx_attribute});

    % 组装该 sheet 的完整数据
    sheet_data = squeeze(all_sheet_data(:, :, idx_attribute));

    writecell(sheet_data, xlsx_path, 'Sheet', sheet_name);
    fprintf('已写入 sheet: %s\n', sheet_name);
end

fprintf('\n========== 完成！==========\n');
fprintf('XLSX 文件: %s\n', fullfile(pwd, xlsx_path));
fprintf('共 %d 个 attribute, 每个 attribute 一个 sheet\n', n_attributes);
fprintf('转置后: 每行=参数, 每列=公式\n');

%% ========== 辅助函数 ==========
function row_headers = build_row_headers(nation_names)
    % 构建行标题: {'k', 'AS RSS', 'AS BIC', 'CA RSS', 'CA BIC', ...}
    row_headers = {"k"};
    for i = 1:length(nation_names)
        row_headers{end+1} = sprintf("%s RSS", nation_names{i});
        row_headers{end+1} = sprintf("%s BIC", nation_names{i});
    end
end
