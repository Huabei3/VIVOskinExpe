% 调试脚本，检查 scatter_L_depend_n_drop1.m 中 a_C_L 为 NaN 的问题
close all; clc; clear;

% 加载一个具体的 nation 和 attribute 的数据来测试
n_drop = 1;
if_draw = "false";

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
fit_type = "new1";

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

load("documents\valid_attr.mat", "map");
wd65 = [94.811, 100.00, 107.304];
datai_file = 'D:\work\VIVOskinExpe\renderCode\calibResults\datai_ipv18_3.mat';
LUT = load(datai_file);
XYZw_LUT = LUT.XYZw;

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

% 选择第一个 nation 和 attribute 进行调试
i_nation = 1; % AS
i_attr = 1; % Preference
i_obs_used = 1; % non_model

% 加载数据
par_reshaped = cell(3, 5, 1);
lab_fit_reshaped = cell(3, 5, 1);
average_reshaped = cell(5, 1);

for i_obs = 1:length(obs_types)
    obs_type = obs_types(i_obs);
    nation = nations(i_nation);
    curr_nation_indices = nation_indices{i_nation};
    n_subjects = length(curr_nation_indices);
    par_current      = zeros(n_para, 6, n_subjects, length(attributes));
    lab_fit_current  = zeros(n_para, 3, n_subjects, length(attributes));
    average_current  = zeros(n_para, 3, n_subjects);

    for i_subject = 1:n_subjects
        subject_idx = curr_nation_indices(i_subject);
        lastPart = lastParts{subject_idx};

        avg_file = fullfile("aveSkin", lastPart, "autoNhand_scaleoverLUT.mat");
        if exist(avg_file, 'file')
            avg_d = load(avg_file);
            average_current(:, :, i_subject) = avg_d.average_lab_all(:, 1:3);
        else
            average_current(:, :, i_subject) = NaN(n_para, 3);
        end

        for i_attr = 1:length(attributes)
            attribute = attributes(i_attr);
            attribute_serial = strcat(sprintf("%02d", attribute), attribute_names_new(attribute));
            src_file = fullfile('AnalyseResults_p', Dtype, scale_type_origin, ...
                lastPart, obs_type, attribute_serial, 'ellipPara', 'fitRes.mat');

            if exist(src_file, 'file')
                pd = load(src_file);
                par_all = pd.par_all;
                par_all = [par_all; nan(size(par_current,1)-size(par_all,1), size(par_all,2))];
                par_current(:, :, i_subject, i_attr) = par_all;
                lab_bf = [average_current(:, 1, i_subject), par_all(:, 4:5)];
                lab_fit_current(:, :, i_subject, i_attr) = lab_bf;
            else
                par_current(:, :, i_subject, i_attr) = NaN(n_para, 6);
                lab_fit_current(:, :, i_subject, i_attr) = NaN(n_para, 3);
            end
        end
    end

    par_reshaped{i_obs, i_nation}      = par_current;
    lab_fit_reshaped{i_obs, i_nation}  = lab_fit_current;
    if i_obs == 1
        average_reshaped{i_nation} = average_current;
    end
end

fprintf('数据加载完成。\n');

% 现在进行 N-Drop 测试
curr_nation_indices = nation_indices{i_nation};
n_subjects_nation = length(curr_nation_indices);

% 选择第一个 subject 作为验证集
val_combo_idx = 1;
val_indices = val_combo_idx;
train_indices = setdiff(1:n_subjects_nation, val_indices);

dropped_subject_idx = curr_nation_indices(val_indices);
dropped_lastPart   = lastParts{dropped_subject_idx};

% 训练集数据
lab_data_full = lab_fit_reshaped{i_obs_used, i_nation}(indices_target, :, :, i_attr);
par_data_full = par_reshaped{i_obs_used, i_nation}(indices_target, :, :, i_attr);

[n_targets, n_channels_lab, ~] = size(lab_data_full);
[~, n_channels_par, ~]          = size(par_data_full);

lab_train_raw = lab_data_full(:, :, train_indices);
par_train_raw = par_data_full(:, :, train_indices);
lab_train_g   = reshape(permute(lab_train_raw, [1 3 2]), n_targets * length(train_indices), n_channels_lab);
par_train_g   = reshape(permute(par_train_raw, [1 3 2]), n_targets * length(train_indices), n_channels_par);

valid_tr_mask  = ~any(isnan(lab_train_g), 2) & ~any(isnan(par_train_g), 2);
L_train        = lab_train_g(valid_tr_mask, 1);
par_train_valid= par_train_g(valid_tr_mask, :);

fprintf('训练数据统计:\n');
fprintf('  lab_train_g 原始大小: %s\n', mat2str(size(lab_train_g)));
fprintf('  valid_tr_mask: %d/%d\n', sum(valid_tr_mask), length(valid_tr_mask));
fprintf('  L_train 大小: %d, NaN数量: %d\n', length(L_train), sum(isnan(L_train)));
if ~isempty(L_train) && any(~isnan(L_train))
    fprintf('  L_train 范围: [%.2f, %.2f]\n', min(L_train(~isnan(L_train))), max(L_train(~isnan(L_train))));
end
fprintf('  par_train_valid 大小: %s\n', mat2str(size(par_train_valid)));

% 计算 C_train
C_train     = sqrt(par_train_valid(:,4).^2 + par_train_valid(:,5).^2);
fprintf('  C_train 大小: %d, NaN数量: %d\n', length(C_train), sum(isnan(C_train)));
if ~isempty(C_train) && any(~isnan(C_train))
    fprintf('  C_train 范围: [%.2f, %.2f]\n', min(C_train(~isnan(C_train))), max(C_train(~isnan(C_train))));
end

% 检查是否有足够数据
valid_for_C = ~isnan(L_train) & ~isnan(C_train) & L_train > 0;
fprintf('  valid_for_C: %d/%d\n', sum(valid_for_C), length(L_train));

% 调用 model_C_L_BIC
fprintf('\n调用 model_C_L_BIC...\n');
[a_C_L, RSS, BIC, k] = model_C_L_BIC(L_train, C_train, 4);
fprintf('  结果: a_C_L = [%s]\n', mat2str(a_C_L));
fprintf('  RSS = %s, BIC = %s, k = %s\n', mat2str(RSS), mat2str(BIC), mat2str(k));

% 检查 model_C_L_BIC 内部
fprintf('\n手动检查 model_C_L_BIC 内部逻辑:\n');
valid_indices = ~isnan(L_train) & ~isnan(C_train) & L_train > 0;
L_valid = L_train(valid_indices);
C_valid = C_train(valid_indices);
n = length(L_valid);
fprintf('  valid_indices: %d/%d\n', sum(valid_indices), length(L_train));
fprintf('  L_valid 大小: %d, 范围: [%.2f, %.2f]\n', n, min(L_valid), max(L_valid));
fprintf('  C_valid 大小: %d, 范围: [%.2f, %.2f]\n', n, min(C_valid), max(C_valid));

if n < 3  % 对数模型需要至少3个点
    fprintf('  警告: 数据点不足 (n=%d < 3)\n', n);
else
    fprintf('  数据点足够 (n=%d >= 3)\n', n);
end

% 检查原始文件是否存在问题
fprintf('\n检查原始 fitRes.mat 文件...\n');
for i_subject = 1:n_subjects_nation
    subject_idx = curr_nation_indices(i_subject);
    lastPart = lastParts{subject_idx};
    attribute_serial = strcat(sprintf("%02d", i_attr), attribute_names_new(i_attr));
    src_file = fullfile('AnalyseResults_p', Dtype, scale_type_origin, ...
        lastPart, obs_types{i_obs_used}, attribute_serial, 'ellipPara', 'fitRes.mat');
    
    if exist(src_file, 'file')
        pd = load(src_file);
        fprintf('  %s: par_all 大小 %s, NaN数量: %d\n', ...
            lastPart, mat2str(size(pd.par_all)), sum(isnan(pd.par_all(:))));
    else
        fprintf('  %s: 文件不存在\n', lastPart);
    end
end