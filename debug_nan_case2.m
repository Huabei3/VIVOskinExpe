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

[n_targets, n_channels_lab, n_subjects_full] = size(lab_data_full);
fprintf('lab_data_full size: %d %d %d\n', n_targets, n_channels_lab, n_subjects_full);
fprintf('train_indices: %s\n', mat2str(train_indices));

lab_train_raw = lab_data_full(:, :, train_indices);
par_train_raw = par_data_full(:, :, train_indices);
fprintf('lab_train_raw size: %s\n', mat2str(size(lab_train_raw)));
fprintf('par_train_raw size: %s\n', mat2str(size(par_train_raw)));

% 检查是否存在 NaN
lab_train_raw_nans = sum(isnan(lab_train_raw(:)));
par_train_raw_nans = sum(isnan(par_train_raw(:)));
fprintf('NaN counts: lab_train_raw=%d, par_train_raw=%d\n', lab_train_raw_nans, par_train_raw_nans);

lab_train_g   = reshape(permute(lab_train_raw, [1 3 2]), n_targets * length(train_indices), n_channels_lab);
par_train_g   = reshape(permute(par_train_raw, [1 3 2]), n_targets * length(train_indices), n_channels_par);
fprintf('lab_train_g size: %s\n', mat2str(size(lab_train_g)));
fprintf('par_train_g size: %s\n', mat2str(size(par_train_g)));

% 检查 lab_train_g 中的值
fprintf('lab_train_g first row: %s\n', mat2str(lab_train_g(1,:)));
fprintf('lab_train_g second row: %s\n', mat2str(lab_train_g(2,:)));
fprintf('lab_train_g third row: %s\n', mat2str(lab_train_g(3,:)));

valid_tr_mask  = ~any(isnan(lab_train_g), 2) & ~any(isnan(par_train_g), 2);
fprintf('valid_tr_mask: %s\n', mat2str(valid_tr_mask));
fprintf('valid_tr_mask true count: %d\n', sum(valid_tr_mask));

if sum(valid_tr_mask) == 0
    fprintf('ERROR: 没有有效数据，所有行都包含 NaN\n');
    fprintf('检查 lab_train_g 的每一列是否存在 NaN:\n');
    for i = 1:size(lab_train_g, 1)
        fprintf('row %d: %s\n', i, mat2str(any(isnan(lab_train_g(i,:)))));
    end
    fprintf('检查 par_train_g 的每一列是否存在 NaN:\n');
    for i = 1:size(par_train_g, 1)
        fprintf('row %d: %s\n', i, mat2str(any(isnan(par_train_g(i,:)))));
    end
    
    % 检查原始 fitRes.mat 文件是否存在数据
    fprintf('\n检查源文件是否存在:\n');
    subject_idx = curr_nation_indices(train_indices(1));
    lastPart = lastParts{subject_idx};
    src_file = fullfile('AnalyseResults_p', 'efit_p', 'unscaled', ...
        lastPart, 'non_model', attribute_serial, 'ellipPara', 'fitRes.mat');
    fprintf('源文件1: %s\n', src_file);
    if exist(src_file, 'file')
        pd = load(src_file);
        fprintf('  par_all size: %s\n', mat2str(size(pd.par_all)));
        fprintf('  par_all first few rows:\n');
        for i = 1:min(3, size(pd.par_all, 1))
            fprintf('    %d: %s\n', i, mat2str(pd.par_all(i,:)));
        end
    else
        fprintf('  文件不存在\n');
    end
end