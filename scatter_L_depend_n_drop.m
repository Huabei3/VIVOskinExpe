% scatter_L_depend_n_drop.m
% Leave-One-Subject-Out N-Drop 交叉验证版本
% 每次留 n_drop 个 subject 作为验证集，其余作为训练集
% 拟合 + 验证结果输出到 xlsx
close all; clc; clear;
addpath("utils\")

%% ===== 用户可调参数 =====
n_drop = 1;          % 默认每次留 n_drop 个 subject 作为验证集
enable_plotting = false;  % true=出图, false=只算数据
%% ========================

%% 定义所有需要处理的 attribute
attributes = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
attribute_names_new = ["Preference", "Attractiveness", "Feminine", "Cooperative", ...
    "Youth", "Healthy", "Fidelity", "Harmony", "Fair", "Ruddy"];

lastParts = {'f04i', 'f05i', 'f06i', 'm04i', 'm05i', 'm06i',...
    'f01i', 'f02i', 'f03i', 'm01i', 'm02i', 'm03i',...
    'f07i', 'f08i','m07i', 'm08i',...
    'f09i', 'f10i','m09i', 'm10i'};
n_para = 21;
iOr = 'i';
CT_type = "d65";
fit_type = "new1";

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
LUT = load(datai_file);
XYZw_LUT = LUT.XYZw;

line_styles = {'-', '--', ':', '-.'};
plot_styles = {'o', '+', 'd', '^'};
genders = ["f", "m"];

obs_types = ["non_model", "model_group", "model"];
enable_plotting_orig = enable_plotting;  % 保存原始绘图开关

max_classify = 0;
if max_classify == 1
    nations = ["AS", "CA", "DA", "all"];
    nation_indices = cell(5, 1);
    nation_indices{1} = 1:6;
    nation_indices{2} = 7:12;
    nation_indices{3} = 13:20;
    nation_indices{4} = 1:20;
    label_type = "nation_max";
else
    nations = ["AS", "CA", "SA", "AF", "all"];
    nation_indices = cell(5, 1);
    nation_indices{1} = 1:6;
    nation_indices{2} = 7:12;
    nation_indices{3} = 13:16;
    nation_indices{4} = 17:20;
    nation_indices{5} = 1:20;
    label_type = "nation";
end

hue_values = linspace(0, 1, length(nations) + 1);
hue_values = hue_values(1:end-1);
hsv_matrix = [hue_values', 0.8 * ones(length(nations), 1), 0.8 * ones(length(nations), 1)];
colors = hsv2rgb(hsv_matrix);

average_reshaped = cell(5, 1);
par_reshaped = cell(3, 5, 1);
lab_fit_reshaped = cell(3, 5, 1);

labCh_PMCC = [[62.11, 18.96, 19.76, 27.39, 46.18];...
    [64.15, 19.56, 19.63, 27.71, 45.10];...
    [56.01, 18.25, 18.72, 26.14, 45.72];...
    [41.06, 17.37, 17.94, 24.97, 45.93]];
labCh_PMCC(end+1,:) = mean(labCh_PMCC, 1);
file_missing = {};
Dtype = 'efit_p';
scale_type_origin = "unscaled";

pic_folder = fullfile('ellip_pic_p', Dtype, "fullpara_n_drop", CT_type, fit_type);
if ~exist(pic_folder, 'dir')
    mkdir(pic_folder);
end

function gender_indices = separate_genders(n_subjects, curr_nation_indices, lastParts)
    gender_indices = cell(2, 1);
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

%% 直接按重塑后的结构加载和存储数据（与原脚本相同）
for i_obs = 1:length(obs_types)
    obs_type = obs_types(i_obs);
    for i_nation = 1:length(nations)
        nation = nations(i_nation);
        curr_nation_indices = nation_indices{i_nation};
        n_subjects = length(curr_nation_indices);
        par_current = zeros(n_para, 6, n_subjects, length(attributes));
        lab_fit_current = zeros(n_para, 3, n_subjects, length(attributes));
        average_current = zeros(n_para, 3, n_subjects);

        for i_subject = 1:n_subjects
            subject_idx = curr_nation_indices(i_subject);
            lastPart = lastParts{subject_idx};
            iOr_sub = lastPart(end);

            average_file = fullfile("aveSkin", lastPart, "autoNhand_scaleoverLUT.mat");
            if exist(average_file, 'file')
                average_data = load(average_file);
                average_current(:, :, i_subject) = average_data.average_lab_all(:, 1:3);
            else
                average_current(:, :, i_subject) = NaN(n_para, 3);
            end

            white_file = fullfile("optimizedD\whiteSquare\XYZw_white", strcat(lastPart, ".mat"));
            load(white_file, "XYZw_white");

            for i_attr = 1:length(attributes)
                attribute = attributes(i_attr);
                attribute_serial = strcat(sprintf("%02d", attribute), attribute_names_new(attribute));
                source_file = fullfile('AnalyseResults_p', Dtype, scale_type_origin, ...
                    lastPart, obs_type, attribute_serial, 'ellipPara', 'fitRes.mat');

                if exist(source_file, 'file')
                    par_all_data = load(source_file);
                    par_all = par_all_data.par_all;
                    par_all = [par_all; nan(size(par_current,1)-size(par_all,1), size(par_all,2))];
                    par_current(:, :, i_subject, i_attr) = par_all;
                    lab_bf = [average_current(:, 1, i_subject), par_all(:, 4:5)];
                    lab_fit_current(:, :, i_subject, i_attr) = lab_bf;
                else
                    par_current(:, :, i_subject, i_attr) = NaN(n_para, 6);
                    lab_fit_current(:, :, i_subject, i_attr) = NaN(n_para, 3);
                    file_missing{end+1,1} = lastPart;
                    file_missing{end,2} = obs_type;
                    file_missing{end,3} = attribute_serial;
                end
            end
        end

        par_reshaped{i_obs, i_nation} = par_current;
        lab_fit_reshaped{i_obs, i_nation} = lab_fit_current;
        if i_obs == 1
            average_reshaped{i_nation} = average_current;
        end
    end
end

%% 保存重塑数据
output_folder_data = fullfile("ellip_pic_p", Dtype, CT_type);
if ~exist(output_folder_data, "dir")
    mkdir(output_folder_data);
end
save(fullfile(output_folder_data, strcat("data_unscaled_reshaped_", iOr, ".mat")), ...
    "lab_fit_reshaped", "par_reshaped", "average_reshaped", "file_missing");

%% ===== N-Drop 交叉验证核心循环 =====
obs_types_use = ["non_model"];  % 可改为支持多 obs_type

% 存储所有验证结果
% result_n_drop{obs_idx}{nation_idx}{subject_idx}{attribute_idx} = struct(...)
result_n_drop = cell(length(obs_types_use), length(nations));
% 也存储训练集整体拟合结果（汇总用）
result_train_all = cell(length(obs_types_use), length(nations));

for i_obs = 1:length(obs_types_use)
    obs_type = obs_types_use(i_obs);
    r_excel_output_folder = fullfile("AnalyseResults_p", Dtype, scale_type_origin, ...
        "model_fullpara_n_drop", CT_type, "new", iOr, obs_type, ...
        sprintf("n_drop_%d", n_drop));
    if ~exist(r_excel_output_folder, 'dir')
        mkdir(r_excel_output_folder);
    end

    for i_nation = 1:length(nations)
        nation = nations(i_nation);
        curr_nation_indices = nation_indices{i_nation};
        n_subjects_nation = length(curr_nation_indices);

        if n_subjects_nation <= n_drop
            warning('人种 %s 只有 %d 个 subject，少于 n_drop=%d，跳过！', ...
                nation, n_subjects_nation, n_drop);
            continue;
        end

        % 遍历每个 held-out subject（验证集）
        % 生成所有 n_drop 组合（简化：按顺序每次留连续的 n_drop 个，
        % 也可改为 random 组合）
        n_val_combinations = n_subjects_nation;  % 每个人轮流当验证集

        for val_combo_idx = 1:n_val_combinations
            % 确定验证集 indices（按顺序取 n_drop 个）
            val_start = val_combo_idx;
            val_indices = [];
            cnt = 0;
            while cnt < n_drop
                idx = mod(val_start - 1 + cnt, n_subjects_nation) + 1;
                val_indices = [val_indices, idx];
                cnt = cnt + 1;
            end
            % 训练集 indices
            train_indices = setdiff(1:n_subjects_nation, val_indices);

            % 为训练集和验证集分别准备数据
            for idx_attribute = 1:length(attributes)
                attribute = attributes(idx_attribute);
                attribute_serial_orig = strcat(sprintf("%02d", attribute), attribute_names_new(attribute));

                % 特殊处理 attribute==7（使用 model_group）
                if attribute == 7
                    i_obs_used = 2;
                else
                    i_obs_used = i_obs;
                end

                % 加载完整数据
                lab_data_full = lab_fit_reshaped{i_obs_used, i_nation}(indices_target, :, :, attribute);
                par_data_full = par_reshaped{i_obs_used, i_nation}(indices_target, :, :, attribute);

                [n_targets, n_channels_lab, ~] = size(lab_data_full);
                [~, n_channels_par, ~] = size(par_data_full);

                % ===== 提取训练集数据 =====
                lab_train_raw = lab_data_full(:, :, train_indices);
                par_train_raw = par_data_full(:, :, train_indices);
                lab_train_g = reshape(permute(lab_train_raw, [1 3 2]), n_targets * length(train_indices), n_channels_lab);
                par_train_g = reshape(permute(par_train_raw, [1 3 2]), n_targets * length(train_indices), n_channels_par);

                valid_rows_lab_tr = ~any(isnan(lab_train_g), 2);
                valid_rows_par_tr = ~any(isnan(par_train_g), 2);
                valid_overall_tr = valid_rows_lab_tr & valid_rows_par_tr;
                L_train = lab_train_g(valid_overall_tr, 1);
                par_train_valid = par_train_g(valid_overall_tr, :);

                % ===== 提取验证集数据 =====
                lab_val_raw = lab_data_full(:, :, val_indices);
                par_val_raw = par_data_full(:, :, val_indices);
                lab_val_g = reshape(permute(lab_val_raw, [1 3 2]), n_targets * length(val_indices), n_channels_lab);
                par_val_g = reshape(permute(par_val_raw, [1 3 2]), n_targets * length(val_indices), n_channels_par);

                valid_rows_lab_va = ~any(isnan(lab_val_g), 2);
                valid_rows_par_va = ~any(isnan(par_val_g), 2);
                valid_overall_va = valid_rows_lab_va & valid_rows_par_va;
                L_val = lab_val_g(valid_overall_va, 1);
                par_val_valid = par_val_g(valid_overall_va, :);

                % === 计算派生量 ===
                % 训练集
                C_train = sqrt(par_train_valid(:,4).^2 + par_train_valid(:,5).^2);
                alpha_train = -log(par_train_valid(:,6));
                alpha_train(isinf(alpha_train) | isnan(alpha_train)) = NaN;
                lambda00_tr = par_train_valid(:,1) ./ alpha_train.^2;
                lambda01_tr = par_train_valid(:,3) ./ alpha_train.^2 ./ 2;
                lambda11_tr = par_train_valid(:,2) ./ alpha_train.^2;
                theta_tr = 0.5 * atan2d(2 * lambda01_tr, (lambda00_tr - lambda11_tr));
                theta_tr = mod(theta_tr, 360);
                A_tr = lambda00_tr .* cosd(theta_tr).^2 - lambda01_tr .* sind(2*theta_tr) + lambda11_tr .* sind(theta_tr).^2;
                B_tr = lambda00_tr .* sind(theta_tr).^2 + lambda01_tr .* sind(2*theta_tr) + lambda11_tr .* cosd(theta_tr).^2;
                A_tr(A_tr <= 0) = NaN;
                B_tr(B_tr <= 0) = NaN;
                long_axis_train = sqrt(1 ./ A_tr);
                short_axis_train = sqrt(1 ./ B_tr);
                hue_angle_train = atan2d(par_train_valid(:,5), par_train_valid(:,4));
                hue_angle_train = mod(hue_angle_train, 360);

                % 验证集
                C_val = sqrt(par_val_valid(:,4).^2 + par_val_valid(:,5).^2);
                alpha_val = -log(par_val_valid(:,6));
                alpha_val(isinf(alpha_val) | isnan(alpha_val)) = NaN;
                lambda00_va = par_val_valid(:,1) ./ alpha_val.^2;
                lambda01_va = par_val_valid(:,3) ./ alpha_val.^2 ./ 2;
                lambda11_va = par_val_valid(:,2) ./ alpha_val.^2;
                theta_va = 0.5 * atan2d(2 * lambda01_va, (lambda00_va - lambda11_va));
                theta_va = mod(theta_va, 360);
                A_va = lambda00_va .* cosd(theta_va).^2 - lambda01_va .* sind(2*theta_va) + lambda11_va .* sind(theta_va).^2;
                B_va = lambda00_va .* sind(theta_va).^2 + lambda01_va .* sind(2*theta_va) + lambda11_va .* cosd(theta_va).^2;
                A_va(A_va <= 0) = NaN;
                B_va(B_va <= 0) = NaN;
                long_axis_val = sqrt(1 ./ A_va);
                short_axis_val = sqrt(1 ./ B_va);
                hue_angle_val = atan2d(par_val_valid(:,5), par_val_valid(:,4));
                hue_angle_val = mod(hue_angle_val, 360);

                % === 训练集拟合 ===
                f_log = @(a, x) a(1)*log(x) + a(2);

                % C_L 拟合
                [a_C_L, RSS_C_L_tr, ~, ~] = model_C_L_BIC(L_train, C_train, 4);
                if ~any(isnan(a_C_L))
                    valid_tr = ~isnan(L_train) & ~isnan(C_train) & L_train > 0;
                    C_pred_tr = f_log(a_C_L, L_train(valid_tr));
                    C_true_tr = C_train(valid_tr);
                    r_C_L_train = corr(C_pred_tr, C_true_tr);
                    rmse_C_L_train = sqrt(RSS_C_L_tr / sum(valid_tr)) / mean(C_true_tr);
                    % 在验证集上预测
                    valid_va = ~isnan(L_val) & ~isnan(C_val) & L_val > 0;
                    C_pred_va = f_log(a_C_L, L_val(valid_va));
                    C_true_va = C_val(valid_va);
                    if sum(valid_va) > 2 && std(C_pred_va) > 0 && std(C_true_va) > 0
                        r_C_L_val = corr(C_pred_va, C_true_va);
                    else
                        r_C_L_val = NaN;
                    end
                    rmse_C_L_val = sqrt(mean((C_pred_va - C_true_va).^2)) / mean(C_true_va);
                else
                    a_C_L = [NaN, NaN];
                    r_C_L_train = NaN; rmse_C_L_train = NaN;
                    r_C_L_val = NaN;  rmse_C_L_val = NaN;
                end

                % 长轴拟合 (三次函数)
                valid_tr_la = ~isnan(L_train) & ~isnan(long_axis_train);
                if sum(valid_tr_la) >= 4
                    f_cubic = @(a, x) a(1).*x.^3 + a(2).*x.^2 + a(3).*x + a(4);
                    options = optimset('MaxFunEvals', 200000, 'Display', 'off');
                    rmax = -inf; a_la_best = [NaN, NaN, NaN, NaN];
                    for t = 1:200
                        a0 = rand(1, 4);
                        try
                            a_la = lsqcurvefit(f_cubic, a0, L_train(valid_tr_la), long_axis_train(valid_tr_la), ...
                                [-inf,-inf,-inf,-inf], [inf,inf,inf,inf], options);
                            y = f_cubic(a_la, L_train(valid_tr_la));
                            r = corr(y, long_axis_train(valid_tr_la));
                            if r > rmax
                                rmax = r; a_la_best = a_la;
                            end
                        catch, continue; end
                    end
                    a_long_axis = a_la_best;
                    r_long_axis_train = rmax;
                    rmse_long_axis_train = sqrt(mean((f_cubic(a_la_best, L_train(valid_tr_la)) - long_axis_train(valid_tr_la)).^2)) ...
                        / mean(long_axis_train(valid_tr_la));
                    % 验证集
                    valid_va_la = ~isnan(L_val) & ~isnan(long_axis_val);
                    if sum(valid_va_la) > 2 && ~any(isnan(a_la_best))
                        la_pred_va = f_cubic(a_la_best, L_val(valid_va_la));
                        la_true_va = long_axis_val(valid_va_la);
                        if std(la_pred_va) > 0 && std(la_true_va) > 0
                            r_long_axis_val = corr(la_pred_va, la_true_va);
                        else
                            r_long_axis_val = NaN;
                        end
                        rmse_long_axis_val = sqrt(mean((la_pred_va - la_true_va).^2)) / mean(la_true_va);
                    else
                        r_long_axis_val = NaN; rmse_long_axis_val = NaN;
                    end
                else
                    a_long_axis = [NaN, NaN, NaN, NaN];
                    r_long_axis_train = NaN; rmse_long_axis_train = NaN;
                    r_long_axis_val = NaN;   rmse_long_axis_val = NaN;
                end

                % 短轴拟合
                valid_tr_sa = ~isnan(L_train) & ~isnan(short_axis_train);
                if sum(valid_tr_sa) >= 4
                    rmax = -inf; a_sa_best = [NaN, NaN, NaN, NaN];
                    for t = 1:200
                        a0 = rand(1, 4);
                        try
                            a_sa = lsqcurvefit(f_cubic, a0, L_train(valid_tr_sa), short_axis_train(valid_tr_sa), ...
                                [-inf,-inf,-inf,-inf], [inf,inf,inf,inf], options);
                            y = f_cubic(a_sa, L_train(valid_tr_sa));
                            r = corr(y, short_axis_train(valid_tr_sa));
                            if r > rmax
                                rmax = r; a_sa_best = a_sa;
                            end
                        catch, continue; end
                    end
                    a_short_axis = a_sa_best;
                    r_short_axis_train = rmax;
                    rmse_short_axis_train = sqrt(mean((f_cubic(a_sa_best, L_train(valid_tr_sa)) - short_axis_train(valid_tr_sa)).^2)) ...
                        / mean(short_axis_train(valid_tr_sa));
                    valid_va_sa = ~isnan(L_val) & ~isnan(short_axis_val);
                    if sum(valid_va_sa) > 2 && ~any(isnan(a_sa_best))
                        sa_pred_va = f_cubic(a_sa_best, L_val(valid_va_sa));
                        sa_true_va = short_axis_val(valid_va_sa);
                        if std(sa_pred_va) > 0 && std(sa_true_va) > 0
                            r_short_axis_val = corr(sa_pred_va, sa_true_va);
                        else
                            r_short_axis_val = NaN;
                        end
                        rmse_short_axis_val = sqrt(mean((sa_pred_va - sa_true_va).^2)) / mean(sa_true_va);
                    else
                        r_short_axis_val = NaN; rmse_short_axis_val = NaN;
                    end
                else
                    a_short_axis = [NaN, NaN, NaN, NaN];
                    r_short_axis_train = NaN; rmse_short_axis_train = NaN;
                    r_short_axis_val = NaN;   rmse_short_axis_val = NaN;
                end

                % 色调角（常数）
                a_hue_angle_train = mean(hue_angle_train);
                r_hue_angle_train = NaN; rmse_hue_angle_train = NaN;
                a_hue_angle_val   = mean(hue_angle_val);
                r_hue_angle_val   = NaN; rmse_hue_angle_val   = NaN;

                % 椭圆倾角 theta（常数）
                a_theta_train = mean(theta_tr);
                r_theta_train = NaN; rmse_theta_train = NaN;
                a_theta_val   = mean(theta_va);
                r_theta_val   = NaN; rmse_theta_val   = NaN;

                % alpha（常数）
                a_alpha_train = mean(alpha_train);
                r_alpha_train = NaN; rmse_alpha_train = NaN;
                a_alpha_val   = mean(alpha_val);
                r_alpha_val   = NaN; rmse_alpha_val   = NaN;

                % ===== 存储结果 =====
                result_n_drop{i_obs}{i_nation}{val_combo_idx}{idx_attribute} = struct( ...
                    'val_indices', val_indices, ...
                    'train_indices', train_indices, ...
                    'a_C_L', a_C_L, ...
                    'r_C_L_train', r_C_L_train, 'rmse_C_L_train', rmse_C_L_train, ...
                    'r_C_L_val', r_C_L_val, 'rmse_C_L_val', rmse_C_L_val, ...
                    'a_long_axis', a_long_axis, ...
                    'r_long_axis_train', r_long_axis_train, 'rmse_long_axis_train', rmse_long_axis_train, ...
                    'r_long_axis_val', r_long_axis_val, 'rmse_long_axis_val', rmse_long_axis_val, ...
                    'a_short_axis', a_short_axis, ...
                    'r_short_axis_train', r_short_axis_train, 'rmse_short_axis_train', rmse_short_axis_train, ...
                    'r_short_axis_val', r_short_axis_val, 'rmse_short_axis_val', rmse_short_axis_val, ...
                    'a_hue_angle_train', a_hue_angle_train, 'r_hue_angle_train', r_hue_angle_train, ...
                    'a_hue_angle_val', a_hue_angle_val, 'r_hue_angle_val', r_hue_angle_val, ...
                    'a_theta_train', a_theta_train, 'r_theta_train', r_theta_train, ...
                    'a_theta_val', a_theta_val, 'r_theta_val', r_theta_val, ...
                    'a_alpha_train', a_alpha_train, 'r_alpha_train', r_alpha_train, ...
                    'a_alpha_val', a_alpha_val, 'r_alpha_val', r_alpha_val ...
                );

                % ===== 训练集整体拟合（用于汇总对比）=====
                % 这里把当前 val_combo_idx 的结果也存到 result_train_all，
                % 最终取平均
                result_train_all{i_obs}{i_nation}{val_combo_idx}{idx_attribute} = struct( ...
                    'a_C_L', a_C_L, ...
                    'r_C_L_train', r_C_L_train, 'rmse_C_L_train', rmse_C_L_train, ...
                    'a_long_axis', a_long_axis, ...
                    'r_long_axis_train', r_long_axis_train, 'rmse_long_axis_train', rmse_long_axis_train, ...
                    'a_short_axis', a_short_axis, ...
                    'r_short_axis_train', r_short_axis_train, 'rmse_short_axis_train', rmse_short_axis_train ...
                );
            end  % end attribute
        end  % end val_combo_idx
    end  % end nation
end  % end obs_type

%% ===== 输出 xlsx =====
% 按 nation × attribute 组织，汇总 n_drop 次验证的 r/rmse
for i_obs = 1:length(obs_types_use)
    obs_type = obs_types_use(i_obs);
    r_excel_output_folder = fullfile("AnalyseResults_p", Dtype, scale_type_origin, ...
        "model_fullpara_n_drop", CT_type, "new", iOr, obs_type, ...
        sprintf("n_drop_%d", n_drop));
    if ~exist(r_excel_output_folder, 'dir')
        mkdir(r_excel_output_folder);
    end

    excel_filename = fullfile(r_excel_output_folder, ...
        sprintf('n_drop_cv_results_n%d.xlsx', n_drop));

    % 为每种指标类型建一个 sheet
    metric_names = {'C_L', 'long_axis', 'short_axis', 'hue_angle', 'theta', 'alpha'};
    metric_fields_train = {'r_C_L_train', 'rmse_C_L_train'; ...
                           'r_long_axis_train', 'rmse_long_axis_train'; ...
                           'r_short_axis_train', 'rmse_short_axis_train'; ...
                           'r_hue_angle_train', []; ...
                           'r_theta_train', []; ...
                           'r_alpha_train', []};
    metric_fields_val = {'r_C_L_val', 'rmse_C_L_val'; ...
                         'r_long_axis_val', 'rmse_long_axis_val'; ...
                         'r_short_axis_val', 'rmse_short_axis_val'; ...
                         'r_hue_angle_val', []; ...
                         'r_theta_val', []; ...
                         'r_alpha_val', []};
    param_fields = {'a_C_L', []; ...
                    'a_long_axis', []; ...
                    'a_short_axis', []; ...
                    'a_hue_angle_train', []; ...
                    'a_theta_train', []; ...
                    'a_alpha_train', []};

    for i_nation = 1:length(nations)
        nation = nations(i_nation);
        n_subjects_nation = length(nation_indices{i_nation});
        n_val_combinations = n_subjects_nation;
        if n_subjects_nation <= n_drop, continue; end

        sheet_name = strrep(nation, ' ', '_');

        % 准备 sheet 数据
        % 列: Attribute | val_subject1_r | val_subject1_rmse | ... | val_mean_r | val_mean_rmse | train_mean_r | train_mean_rmse
        n_attr = length(attributes);
        col_header = [{'Attribute'}, cellfun(@(x) sprintf('Val_S%02d_r', x), num2cell(1:n_val_combinations), 'UniformOutput', false), ...
                      {'Val_mean_r'}, {'Val_mean_rmse'}, {'Train_mean_r'}, {'Train_mean_rmse'}];
        col_header = reshape(col_header, 1, []);

        data_table = cell(n_attr + 1, length(col_header));
        data_table{1, 1} = 'Attribute';
        data_table{1, 2:end-5} = cellfun(@(x) sprintf('Val_S%02d_r', x), num2cell(1:n_val_combinations), 'UniformOutput', false);
        data_table{1, end-4} = 'Val_mean_r';
        data_table{1, end-3} = 'Val_mean_rmse';
        data_table{1, end-2} = 'Train_mean_r';
        data_table{1, end-1} = 'Train_mean_rmse';

        % 参数列标题
        param_header_start = length(col_header) + 1;
        % a_C_L 有 2 个参数，long_axis 4 个，short_axis 4 个，其余 1 个
        param_headers = [{'a_C_L_1'}, {'a_C_L_2'}, ...
                         {'a_long_axis_1'}, {'a_long_axis_2'}, {'a_long_axis_3'}, {'a_long_axis_4'}, ...
                         {'a_short_axis_1'}, {'a_short_axis_2'}, {'a_short_axis_3'}, {'a_short_axis_4'}, ...
                         {'a_hue_angle'}, {'a_theta'}, {'a_alpha'}];
        % 对应 n_val_combinations 列（每次验证对应一套参数）
        param_cols_per_run = length(param_headers);
        total_cols = length(col_header) + n_val_combinations * param_cols_per_run;

        % 扩展 header
        param_col_headers = {};
        for vi = 1:n_val_combinations
            for pi = 1:length(param_headers)
                param_col_headers{end+1} = sprintf('S%02d_%s', vi, param_headers{pi});
            end
        end
        new_header = [col_header, param_col_headers];

        for ia = 1:n_attr
            data_table{ia+1, 1} = attribute_names_new(attributes(ia));

            val_r_all = zeros(n_val_combinations, 1) * NaN;
            val_rmse_all = zeros(n_val_combinations, 1) * NaN;
            train_r_all = zeros(n_val_combinations, 1) * NaN;
            train_rmse_all = zeros(n_val_combinations, 1) * NaN;

            % 参数存储
            param_vals_all = cell(n_val_combinations, 1);

            for vi = 1:n_val_combinations
                if isempty(result_n_drop{i_obs}{i_nation}{vi}) || ...
                   numel(fieldnames(result_n_drop{i_obs}{i_nation}{vi})) == 0
                    continue;
                end
                r_struct = result_n_drop{i_obs}{i_nation}{vi}{ia};
                if isempty(r_struct), continue; end

                % C_L
                val_r_all(vi) = r_struct.r_C_L_val;
                val_rmse_all(vi) = r_struct.rmse_C_L_val;
                train_r_all(vi) = r_struct.r_C_L_train;
                train_rmse_all(vi) = r_struct.rmse_C_L_train;
                param_vals_all{vi} = [r_struct.a_C_L, ...
                                      r_struct.a_long_axis, ...
                                      r_struct.a_short_axis, ...
                                      r_struct.a_hue_angle_train, ...
                                      r_struct.a_theta_train, ...
                                      r_struct.a_alpha_train];
            end

            % 填入 r 列
            for vi = 1:n_val_combinations
                data_table{ia+1, vi+1} = val_r_all(vi);
            end
            data_table{ia+1, end-4} = nanmean(val_r_all);
            data_table{ia+1, end-3} = nanmean(val_rmse_all);
            data_table{ia+1, end-2} = nanmean(train_r_all);
            data_table{ia+1, end-1} = nanmean(train_rmse_all);

            % 填入参数
            base_col = length(col_header) + 1;
            for vi = 1:n_val_combinations
                if ~isempty(param_vals_all{vi})
                    pv = param_vals_all{vi};
                    for pi = 1:length(pv)
                        data_table{ia+1, base_col + (vi-1)*param_cols_per_run + pi - 1} = pv(pi);
                    end
                end
            end
        end

        % 写 xlsx（数值格式保留两位小数，数字格式）
        try
            % 先写 header
            writecell(new_header, excel_filename, 'Sheet', sheet_name, 'WriteMode', 'overwritesheet');
            % 再写数据
            [~, ~, rawData] = xlsread(excel_filename, sheet_name);
            nRows = size(rawData, 1);
            nCols = length(new_header);
            for rr = 2:(n_attr + 1)
                for cc = 2:nCols
                    val = data_table{rr-1, cc};
                    if isnumeric(val) && ~isnan(val)
                        rawData{rr, cc} = val;
                    end
                end
            end
            % 用 writematrix / writecell 写回，带数值格式
            % 先把数据表扩展完整
            full_table = cell(n_attr + 1, length(new_header));
            full_table(1, :) = new_header;
            full_table(2:end, :) = data_table(2:end, :);
            writecell(full_table, excel_filename, 'Sheet', sheet_name, 'WriteMode', 'overwritesheet');

            % 格式化数值列（两位小数）
            % 读取刚写入的文件并转数值
            [numData, txtData, raw] = xlsread(excel_filename, sheet_name);
            [nR, nC] = size(numData);
            if nR > 0 && nC > 0
                % 将数值格式化为两位小数（字符串形式，写回 xlsx 时用 writecell）
                for rr = 2:(n_attr+1)
                    for cc = 1:nC
                        v = raw{rr, cc+1};  % +1 因为第一列是文本
                        if isnumeric(v) && ~isnan(v)
                            raw{rr, cc+1} = round(v, 4);
                        end
                    end
                end
                xlswrite(excel_filename, raw(2:end, :), sheet_name, 'A2');
            end
        catch ME
            warning('写入 xlsx 出错: %s', ME.message);
            % 备用：直接写
            writecell(data_table, excel_filename, 'Sheet', sheet_name, 'WriteMode', 'overwritesheet');
        end
    end  % end nations

    % 也写一份汇总 sheet
    summary_header = [{'Nation', 'Attribute', 'Val_mean_r', 'Val_mean_rmse', ...
                       'Train_mean_r', 'Train_mean_rmse', 'N_val', 'N_train'}];
    summary_data = {};
    for i_nation = 1:length(nations)
        nation = nations(i_nation);
        n_subjects_nation = length(nation_indices{i_nation});
        if n_subjects_nation <= n_drop, continue; end
        for ia = 1:n_attr
            val_r_list = []; val_rmse_list = [];
            train_r_list = []; train_rmse_list = [];
            for vi = 1:n_subjects_nation
                if isempty(result_n_drop{i_obs}{i_nation}{vi}), continue; end
                r_struct = result_n_drop{i_obs}{i_nation}{vi}{ia};
                if isempty(r_struct), continue; end
                val_r_list = [val_r_list; r_struct.r_C_L_val];
                val_rmse_list = [val_rmse_list; r_struct.rmse_C_L_val];
                train_r_list = [train_r_list; r_struct.r_C_L_train];
                train_rmse_list = [train_rmse_list; r_struct.rmse_C_L_train];
            end
            summary_data{end+1, 1} = nation;
            summary_data{end, 2} = attribute_names_new(attributes(ia));
            summary_data{end, 3} = nanmean(val_r_list);
            summary_data{end, 4} = nanmean(val_rmse_list);
            summary_data{end, 5} = nanmean(train_r_list);
            summary_data{end, 6} = nanmean(train_rmse_list);
            summary_data{end, 7} = sum(~isnan(val_r_list));
            summary_data{end, 8} = sum(~isnan(train_r_list));
        end
    end

    try
        writecell(summary_header, excel_filename, 'Sheet', 'Summary_C_L', 'WriteMode', 'overwritesheet');
        writecell(summary_data, excel_filename, 'Sheet', 'Summary_C_L', 'WriteMode', 'append');
    catch ME
        warning('写入 Summary sheet 出错: %s', ME.message);
    end

    fprintf('N-Drop CV 结果已写入: %s\n', excel_filename);
end

%% 打印简要统计
fprintf('\n========== N-Drop CV 摘要 (n_drop=%d) ==========\n', n_drop);
for i_nation = 1:length(nations)
    nation = nations(i_nation);
    n_subj = length(nation_indices{i_nation});
    if n_subj <= n_drop, continue; end
    fprintf('\n[%s] (n_subj=%d, n_val_runs=%d)\n', nation, n_subj, n_subj);
    fprintf('  Attribute     | Val_r(C_L) | Train_r(C_L) | Val_rmse | Train_rmse\n');
    fprintf('  --------------------------------------------------\n');
    for ia = 1:length(attributes)
        vr = []; tr = []; vrmse = []; trmse = [];
        for vi = 1:n_subj
            if isempty(result_n_drop{1}{i_nation}{vi}), continue; end
            s = result_n_drop{1}{i_nation}{vi}{ia};
            if isempty(s), continue; end
            vr = [vr; s.r_C_L_val];
            tr = [tr; s.r_C_L_train];
            vrmse = [vrmse; s.rmse_C_L_val];
            trmse = [trmse; s.rmse_C_L_train];
        end
        fprintf('  %-12s | %9.4f | %12.4f | %8.4f | %9.4f\n', ...
            attribute_names_new(attributes(ia)), ...
            nanmean(vr), nanmean(tr), nanmean(vrmse), nanmean(trmse));
    end
end

fprintf('\n保存路径: %s\n', r_excel_output_folder);
fprintf('Done!\n');
