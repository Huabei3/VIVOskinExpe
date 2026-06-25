% 调试特定 NaN 案例
addpath("utils\");
close all; clc;

n_drop = 1;
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

nations = ["AS", "CA", "SA", "AF", "all"];
nation_indices = cell(5, 1);
nation_indices{1} = 1:6;
nation_indices{2} = 7:12;
nation_indices{3} = 13:16;
nation_indices{4} = 17:20;
nation_indices{5} = 1:20;

obs_types = ["non_model", "model_group", "model"];

% 预加载数据（仅加载 non_model）
fprintf('预加载数据...\n');
par_reshaped = cell(3, 5, 1);
lab_fit_reshaped = cell(3, 5, 1);
average_reshaped = cell(5, 1);

for i_obs = 1:length(obs_types)
    obs_type = obs_types(i_obs);
    for i_nation = 1:length(nations)
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
                src_file = fullfile('AnalyseResults_p', 'efit_p', 'unscaled', ...
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
end

% 选择一个案例：CA nation (i_nation=2), val_combo_idx=1 (f01i), attribute=2 (Attractiveness)
i_nation = 2;
nation = nations(i_nation);
curr_nation_indices = nation_indices{i_nation};
n_subjects_nation = length(curr_nation_indices);
val_combo_idx = 1; % f01i 作为验证集
train_indices = setdiff(1:n_subjects_nation, val_combo_idx);
dropped_subject_idx = curr_nation_indices(val_combo_idx);
dropped_lastPart = lastParts{dropped_subject_idx};

attribute = 2; % Attractiveness
attr_name = attribute_names_new(attribute);
attribute_serial = strcat(sprintf("%02d", attribute), attr_name);

if attribute == 7
    i_obs_used = 2;
else
    i_obs_used = 1;
end

% 训练集数据
lab_data_full = lab_fit_reshaped{i_obs_used, i_nation}(indices_target, :, :, attribute);
par_data_full = par_reshaped{i_obs_used, i_nation}(indices_target, :, :, attribute);

[n_targets, n_channels_lab, ~] = size(lab_data_full);
[~, n_channels_par, ~]          = size(par_data_full);

lab_train_raw = lab_data_full(:, :, train_indices);
par_train_raw = par_data_full(:, :, train_indices);
lab_train_g   = reshape(permute(lab_train_raw, [1 3 2]), n_targets * length(train_indices), n_channels_lab);
par_train_g   = reshape(permute(par_train_raw, [1 3 2]), n_targets * length(train_indices), n_channels_par);

valid_tr_mask  = ~any(isnan(lab_train_g), 2) & ~any(isnan(par_train_g), 2);
L_train        = lab_train_g(valid_tr_mask, 1);
par_train_valid= par_train_g(valid_tr_mask, :);

fprintf('\n=== 案例: %s nation, dropped=%s, attr=%s ===\n', nation, dropped_lastPart, attr_name);
fprintf('lab_train_g size=%s, valid_tr_mask=%d/%d\n', mat2str(size(lab_train_g)), sum(valid_tr_mask), length(valid_tr_mask));
fprintf('L_train size=%d, NaN count=%d\n', length(L_train), sum(isnan(L_train)));
fprintf('par_train_valid size=%s, NaN in col4=%d, col5=%d, col6=%d\n', ...
    mat2str(size(par_train_valid)), sum(isnan(par_train_valid(:,4))), sum(isnan(par_train_valid(:,5))), sum(isnan(par_train_valid(:,6))));

% 检查第6列的值
if any(~isnan(par_train_valid(:,6)))
    fprintf('par_train_valid(:,6) range=[%.6f, %.6f]\n', ...
        min(par_train_valid(~isnan(par_train_valid(:,6)),6)), max(par_train_valid(~isnan(par_train_valid(:,6)),6)));
else
    fprintf('par_train_valid(:,6) 全是 NaN\n');
end

C_train = sqrt(par_train_valid(:,4).^2 + par_train_valid(:,5).^2);
fprintf('C_train size=%d, NaN count=%d\n', length(C_train), sum(isnan(C_train)));

% 检查 valid_for_C
valid_for_C = ~isnan(L_train) & ~isnan(C_train) & L_train > 0;
n_valid = sum(valid_for_C);
fprintf('valid_for_C=%d, L_range=[%.2f,%.2f], C_range=[%.2f,%.2f]\n', ...
    n_valid, min(L_train(valid_for_C)), max(L_train(valid_for_C)), ...
    min(C_train(valid_for_C)), max(C_train(valid_for_C)));

% 调用 model_C_L_BIC
[a_C_L, RSS, BIC, k] = model_C_L_BIC(L_train, C_train, 4);
fprintf('model_C_L_BIC 输出: a_C_L=[%f, %f], RSS=%f, BIC=%f, k=%d\n', a_C_L(1), a_C_L(2), RSS, BIC, k);

% 检查函数内部可能的提前返回
% 查看 valid_indices 的数量
valid_indices = ~isnan(L_train) & ~isnan(C_train) & L_train > 0;
L_valid = L_train(valid_indices);
C_valid = C_train(valid_indices);
n = length(L_valid);
fprintf('内部检查: n=%d, k_minimum(4)=%d\n', n, k_minimum(4));

if n < k_minimum(4)
    fprintf('数据不足！需要至少 %d 个点，只有 %d 个。\n', k_minimum(4), n);
else
    fprintf('数据量足够。\n');
end

% 显示 L_valid 和 C_valid 的值
fprintf('L_valid (size %d): ', length(L_valid));
for i=1:min(10, length(L_valid))
    fprintf('%.2f ', L_valid(i));
end
fprintf('\nC_valid (size %d): ', length(C_valid));
for i=1:min(10, length(C_valid))
    fprintf('%.2f ', C_valid(i));
end
fprintf('\n');