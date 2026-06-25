% 测试数据加载过程
close all; clc; clear;

% 基本设置
attributes = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
attribute_names_new = ["Preference", "Attractiveness", "Feminine", "Cooperative", ...
    "Youth", "Healthy", "Fidelity", "Harmony", "Fair", "Ruddy"];

lastParts = {'f04i', 'f05i', 'f06i', 'm04i', 'm05i', 'm06i', ...
    'f01i', 'f02i', 'f03i', 'm01i', 'm02i', 'm03i', ...
    'f07i', 'f08i', 'm07i', 'm08i', ...
    'f09i', 'f10i', 'm09i', 'm10i'};
n_para = 21;
iOr = 'i';
CT_type = "d65";

if iOr == 'i'
    if strcmp(CT_type, "3k")
        indices_target = [1, 8, 15];
    elseif strcmp(CT_type, "4k")
        indices_target = [2, 9, 19];
    elseif strcmp(CT_type, "d65")
        indices_target = [5, 14, 19];   % H3K=5, M3K=14, L6K=19
    end
else
    indices_target = 1:14;
end

obs_types = ["non_model", "model_group", "model"];
nations = ["AS", "CA", "SA", "AF", "all"];
nation_indices = cell(5, 1);
nation_indices{1} = 1:6;
nation_indices{2} = 7:12;
nation_indices{3} = 13:16;
nation_indices{4} = 17:20;
nation_indices{5} = 1:20;

Dtype = 'efit_p';
scale_type_origin = "unscaled";

% 只检查第一个 nation (AS) 的第一个 attribute (Preference)
i_nation = 1;
i_attr = 1;
obs_type = "non_model";

nation = nations(i_nation);
curr_nation_indices = nation_indices{i_nation};
n_subjects = length(curr_nation_indices);

fprintf('检查 nation: %s (subjects: %s)\n', nation, mat2str(curr_nation_indices));
fprintf('attribute: %s (%s)\n', attribute_names_new(i_attr), obs_type);
fprintf('使用的 pcn indices: %s\n', mat2str(indices_target));
fprintf('对应的 pcn: H3K(%d), M3K(%d), L6K(%d)\n', indices_target(1), indices_target(2), indices_target(3));

% 检查每个 subject 的数据文件
for i_subject = 1:n_subjects
    subject_idx = curr_nation_indices(i_subject);
    lastPart = lastParts{subject_idx};
    
    attribute_serial = strcat(sprintf("%02d", i_attr), attribute_names_new(i_attr));
    src_file = fullfile('AnalyseResults_p', Dtype, scale_type_origin, ...
        lastPart, obs_type, attribute_serial, 'ellipPara', 'fitRes.mat');
    
    fprintf('\nSubject %d (%s):\n', subject_idx, lastPart);
    fprintf('  文件路径: %s\n', src_file);
    
    if exist(src_file, 'file')
        pd = load(src_file);
        par_all = pd.par_all;
        
        % 检查 indices_target 对应的行
        fprintf('  par_all 大小: %s\n', mat2str(size(par_all)));
        fprintf('  检查 indices_target 行:\n');
        for i = 1:length(indices_target)
            idx = indices_target(i);
            row = par_all(idx, :);
            fprintf('    行 %d: [%s]', idx, sprintf('%.4f ', row));
            if any(isnan(row))
                fprintf(' ← 包含 NaN');
            end
            fprintf('\n');
        end
    else
        fprintf('  文件不存在\n');
    end
end

% 现在模拟训练过程
fprintf('\n\n=== 模拟训练过程 ===\n');

% 假设 drop 第一个 subject (f04i)
dropped_idx = 1;
train_indices = setdiff(1:n_subjects, dropped_idx);
fprintf('Drop subject: %d (%s)\n', dropped_idx, lastParts{curr_nation_indices(dropped_idx)});
fprintf('Train subjects: %s\n', mat2str(train_indices));

% 加载训练数据
par_train_data = [];
lab_train_data = [];

for i_train = 1:length(train_indices)
    train_subj_idx = train_indices(i_train);
    subject_idx = curr_nation_indices(train_subj_idx);
    lastPart = lastParts{subject_idx};
    
    attribute_serial = strcat(sprintf("%02d", i_attr), attribute_names_new(i_attr));
    src_file = fullfile('AnalyseResults_p', Dtype, scale_type_origin, ...
        lastPart, obs_type, attribute_serial, 'ellipPara', 'fitRes.mat');
    
    if exist(src_file, 'file')
        pd = load(src_file);
        par_all = pd.par_all;
        
        % 只取 indices_target 对应的行
        par_target = par_all(indices_target, :);
        fprintf('  %s: 加载 %d 行数据\n', lastPart, size(par_target, 1));
        
        par_train_data = [par_train_data; par_target]; %#ok<AGROW>
    else
        fprintf('  %s: 文件不存在，使用 NaN\n', lastPart);
        par_train_data = [par_train_data; nan(length(indices_target), 6)]; %#ok<AGROW>
    end
end

fprintf('\n训练数据总计: %d 行\n', size(par_train_data, 1));

% 检查数据质量
fprintf('\n训练数据统计:\n');
for col = 1:6
    col_data = par_train_data(:, col);
    fprintf('  第%d列: 有效值=%d/%d, NaN=%d, 范围=[%.4f, %.4f]\n', ...
        col, sum(~isnan(col_data)), length(col_data), sum(isnan(col_data)), ...
        min(col_data(~isnan(col_data))), max(col_data(~isnan(col_data))));
end

% 计算派生量
C_train = sqrt(par_train_data(:,4).^2 + par_train_data(:,5).^2);
alpha_tr = -log(par_train_data(:,6));

fprintf('\n派生量统计:\n');
fprintf('  C_train: 有效值=%d/%d, 范围=[%.4f, %.4f]\n', ...
    sum(~isnan(C_train)), length(C_train), min(C_train(~isnan(C_train))), max(C_train(~isnan(C_train))));
fprintf('  alpha_tr: 有效值=%d/%d, 范围=[%.4f, %.4f]\n', ...
    sum(~isnan(alpha_tr)), length(alpha_tr), min(alpha_tr(~isnan(alpha_tr))), max(alpha_tr(~isnan(alpha_tr))));

% 检查 alpha_tr 中是否有 NaN 或 Inf
invalid_alpha = isnan(alpha_tr) | isinf(alpha_tr);
if any(invalid_alpha)
    fprintf('\n警告: alpha_tr 中有 %d 个无效值\n', sum(invalid_alpha));
    % 检查对应的 par_train_data(:,6)
    invalid_rows = find(invalid_alpha);
    for i = 1:min(5, length(invalid_rows))
        row = invalid_rows(i);
        fprintf('  行 %d: par_train_data(:,6)=%.10f\n', row, par_train_data(row,6));
    end
end