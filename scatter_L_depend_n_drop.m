% scatter_L_depend_n_drop.m
% Leave-One-Subject-Out N-Drop 交叉验证版本
% 每次留 n_drop 个 subject 作为验证集，其余作为训练集
% 验证指标：参考 predict_fullpara_ablation.m
%   average(i_par,1) + 拟合参数 → calculate_par_from_ellipse → calculate_y → corr(y, p_group)
% 每组参数拟合完立即打印并追加写 xlsx
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

            average_file = fullfile("aveSkin", lastPart, "autoNhand_scaleoverLUT.mat");
            if exist(average_file, 'file')
                average_data = load(average_file);
                average_current(:, :, i_subject) = average_data.average_lab_all(:, 1:3);
            else
                average_current(:, :, i_subject) = NaN(n_para, 3);
            end

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

%% ===== N-Drop 交叉验证核心循环（每组参数立即打印+写 xlsx）=====
% 验证指标（参考 predict_fullpara_ablation.m）：
%   1. 训练集拟合曲线参数
%   2. 用 dropped subject 的 average(i_par,1) + 拟合参数计算模型椭圆
%   3. calculate_par_from_ellipse → calculate_y → corr(y, p_group)
obs_types_use = ["non_model"];

for i_obs = 1:length(obs_types_use)
    obs_type = obs_types_use(i_obs);
    % 注意：文件夹名不能以 \n 开头（MATLAB 把 \n 当换行符处理）
    obs_folder_name = strrep(obs_type, '\n', '_');   % "non_model" → "non_model"（无\n则不变）
    drop_folder_name = sprintf('drop_%d', n_drop);   % 不用 "n_drop_%d"，避免 \n 变换行符
    r_excel_output_folder = fullfile("AnalyseResults_p", Dtype, scale_type_origin, ...
        "model_fullpara_n_drop", CT_type, "new", iOr, obs_folder_name, drop_folder_name);
    if ~exist(r_excel_output_folder, 'dir')
        mkdir(r_excel_output_folder);
    end
    excel_filename = fullfile(r_excel_output_folder, sprintf('n_drop_cv_results_n%d.xlsx', n_drop));

    % ---- xlsx 只建一次（写到 nation 循环外面）----
    if exist(excel_filename, 'file')
        try delete(excel_filename); end
    end
    % 先为每个 nation 写好 header（每个 sheet 建立一次）
    for i_nation = 1:length(nations)
        nation = nations(i_nation);
        sheet_name = strrep(nation, ' ', '_');
        col_header = {'Attr', 'Drop_subj', 'Drop_LP', ...
            'r_model_y', 'rmse_y', 'r_C_mod', 'r_C_exp', ...
            'a_C1', 'a_C2', ...
            'a_la1', 'a_la2', 'a_la3', 'a_la4', ...
            'a_sa1', 'a_sa2', 'a_sa3', 'a_sa4', ...
            'hue_angle', 'theta', 'alpha'};
        writecell(col_header, excel_filename, 'Sheet', sheet_name, 'WriteMode', 'overwritesheet');
    end

    % ---- 正式计算循环：追加写 xlsx ----
    for i_nation = 1:length(nations)
        nation = nations(i_nation);
        curr_nation_indices = nation_indices{i_nation};
        n_subjects_nation = length(curr_nation_indices);

        if n_subjects_nation <= n_drop
            warning('人种 %s 只有 %d 个 subject，少于 n_drop=%d，跳过！', ...
                nation, n_subjects_nation, n_drop);
            continue;
        end

        sheet_name = strrep(nation, ' ', '_');

        % ---- 每人轮流当验证集 ----
        for val_combo_idx = 1:n_subjects_nation
            val_indices = val_combo_idx;   % n_drop=1 时为标量
            train_indices = setdiff(1:n_subjects_nation, val_indices);

            % dropped subject 信息
            dropped_subject_idx = curr_nation_indices(val_indices);
            dropped_lastPart = lastParts{dropped_subject_idx};

            % 加载 dropped subject 的 average_lab_all（用于模型预测 L* 输入）
            avg_drop_file = fullfile("aveSkin", dropped_lastPart, "autoNhand_scaleoverLUT.mat");
            if exist(avg_drop_file, 'file')
                avg_drop_data = load(avg_drop_file);
                avg_drop_all = avg_drop_data.average_lab_all(:, 1:3);  % (21,3): L*,a*,b*
            else
                avg_drop_all = NaN(21, 3);
            end

            for idx_attribute = 1:length(attributes)
                attribute = attributes(idx_attribute);
                attr_name = attribute_names_new(attribute);

                % attribute==7 用 model_group
                if attribute == 7
                    i_obs_used = 2;
                else
                    i_obs_used = i_obs;
                end

                % ===== 训练集数据 =====
                lab_data_full = lab_fit_reshaped{i_obs_used, i_nation}(indices_target, :, :, attribute);
                par_data_full = par_reshaped{i_obs_used, i_nation}(indices_target, :, :, attribute);

                [n_targets, n_channels_lab, ~] = size(lab_data_full);
                [~, n_channels_par, ~] = size(par_data_full);

                lab_train_raw = lab_data_full(:, :, train_indices);
                par_train_raw = par_data_full(:, :, train_indices);
                lab_train_g = reshape(permute(lab_train_raw, [1 3 2]), n_targets * length(train_indices), n_channels_lab);
                par_train_g = reshape(permute(par_train_raw, [1 3 2]), n_targets * length(train_indices), n_channels_par);

                valid_tr_mask = ~any(isnan(lab_train_g), 2) & ~any(isnan(par_train_g), 2);
                L_train = lab_train_g(valid_tr_mask, 1);
                par_train_valid = par_train_g(valid_tr_mask, :);

                % ===== 训练集派生量 =====
                C_train = sqrt(par_train_valid(:,4).^2 + par_train_valid(:,5).^2);
                alpha_tr = -log(par_train_valid(:,6));
                alpha_tr(isinf(alpha_tr) | isnan(alpha_tr)) = NaN;
                lambda00_tr = par_train_valid(:,1) ./ alpha_tr.^2;
                lambda01_tr = par_train_valid(:,3) ./ alpha_tr.^2 ./ 2;
                lambda11_tr = par_train_valid(:,2) ./ alpha_tr.^2;
                theta_tr = 0.5 * atan2d(2 * lambda01_tr, (lambda00_tr - lambda11_tr));
                theta_tr = mod(theta_tr, 360);
                A_tr = lambda00_tr .* cosd(theta_tr).^2 - lambda01_tr .* sind(2*theta_tr) + lambda11_tr .* sind(theta_tr).^2;
                B_tr = lambda00_tr .* sind(theta_tr).^2 + lambda01_tr .* sind(2*theta_tr) + lambda11_tr .* cosd(theta_tr).^2;
                A_tr(A_tr <= 0) = NaN;  B_tr(B_tr <= 0) = NaN;
                long_axis_tr = sqrt(1 ./ A_tr);
                short_axis_tr = sqrt(1 ./ B_tr);

                % ===== 拟合：a_C_L（对数模型）=====
                f_log = @(a, x) a(1)*log(x) + a(2);
                [a_C_L, RSS_C_L_tr, ~, ~] = model_C_L_BIC(L_train, C_train, 4);
                if ~any(isnan(a_C_L))
                    valid_train_C = ~isnan(L_train) & ~isnan(C_train) & L_train > 0;
                    C_pred_train = f_log(a_C_L, L_train(valid_train_C));
                    C_true_train = C_train(valid_train_C);
                    r_C_L_train = corr(C_pred_train, C_true_train);
                else
                    a_C_L = [NaN, NaN];  r_C_L_train = NaN;
                end

                % ===== 拟合：a_long_axis（三次函数）=====
                f_cubic = @(a, x) a(1).*x.^3 + a(2).*x.^2 + a(3).*x + a(4);
                options = optimset('MaxFunEvals', 200000, 'Display', 'off');
                valid_la = ~isnan(L_train) & ~isnan(long_axis_tr);
                if sum(valid_la) >= 4
                    rmax = -inf;  a_la_best = [NaN, NaN, NaN, NaN];
                    for t = 1:200
                        try
                            a_la = lsqcurvefit(f_cubic, rand(1,4), L_train(valid_la), long_axis_tr(valid_la), ...
                                [-inf,-inf,-inf,-inf], [inf,inf,inf,inf], options);
                            r = corr(f_cubic(a_la, L_train(valid_la)), long_axis_tr(valid_la));
                            if r > rmax,  rmax = r;  a_la_best = a_la;  end
                        catch,  continue;  end
                    end
                    a_long_axis = a_la_best;
                else
                    a_long_axis = [NaN, NaN, NaN, NaN];
                end

                % ===== 拟合：a_short_axis（三次函数）=====
                valid_sa = ~isnan(L_train) & ~isnan(short_axis_tr);
                if sum(valid_sa) >= 4
                    rmax = -inf;  a_sa_best = [NaN, NaN, NaN, NaN];
                    for t = 1:200
                        try
                            a_sa = lsqcurvefit(f_cubic, rand(1,4), L_train(valid_sa), short_axis_tr(valid_sa), ...
                                [-inf,-inf,-inf,-inf], [inf,inf,inf,inf], options);
                            r = corr(f_cubic(a_sa, L_train(valid_sa)), short_axis_tr(valid_sa));
                            if r > rmax,  rmax = r;  a_sa_best = a_sa;  end
                        catch,  continue;  end
                    end
                    a_short_axis = a_sa_best;
                else
                    a_short_axis = [NaN, NaN, NaN, NaN];
                end

                % ===== 常数参数 =====
                a_hue_angle = mean(theta_tr);
                a_theta = mean(theta_tr);
                a_alpha = mean(alpha_tr);

                % ===== 验证 r（用 dropped subject 的 labNscore）=====
                r_model_y = NaN;  rmse_model_y = NaN;
                r_C_model = NaN;   r_C_exp = NaN;

                obs_type_used = obs_type;
                if attribute == 7,  obs_type_used = "model_group";  end

                % pcn 列表（与 iOr 对应）
                if iOr == 'i'
                    pcn = ["H3K", "H4K", "H5K", "H6K", "HD65", "H7K", "H8K", ...
                           "M3K", "M4K", "M5K", "M6K", "MD65", "M7K", "M8K", ...
                           "L3K", "L4K", "L5K", "L6K", "LD65", "L7K", "L8K"];
                else
                    pcn = ["rs01","rs02","rs03","rs04","rs05","rs06","rs07", ...
                                 "rs08","rs09","rs10","rs11","rs12","rs13","rs14"];
                end

                model_C_list = [];  exp_C_list = [];
                y_all = [];  p_all = [];

                for i_tgt = 1:length(indices_target)
                    i_par = indices_target(i_tgt);  % average_lab_all 中的行索引

                    % 对应 pcn 的 labNscore
                    pcn_lower = lower(pcn(i_par));
                    labNscore_file = fullfile("AnalyseResults_p", Dtype, scale_type_origin, ...
                        dropped_lastPart, obs_type_used, sprintf("%02d%s", attribute, attr_name), "labNscore", ...
                        strcat("labNscore_group", lower(dropped_lastPart), pcn_lower, ".mat"));

                    % dropped subject 在该 target 的 L*
                    if size(avg_drop_all, 1) >= i_par && ~any(isnan(avg_drop_all(i_par, :)))
                        L_val_model = avg_drop_all(i_par, 1);
                    else
                        L_val_model = NaN;
                    end

                    if isnan(L_val_model) || L_val_model <= 0,  continue;  end

                    % === 加载该 target 对应 pcn 的 lab_group / p_group ===
                    loaded_this = false;
                    if exist(labNscore_file, 'file')
                        ld_tgt = load(labNscore_file, 'lab_group', 'p_group');
                        if isfield(ld_tgt,'lab_group') && isfield(ld_tgt,'p_group') ...
                                && ~isempty(ld_tgt.lab_group) && ~isempty(ld_tgt.p_group)
                            lab_group_tgt = ld_tgt.lab_group;
                            p_group_tgt   = ld_tgt.p_group;
                            loaded_this = true;
                        end
                    end

                    % === 用拟合参数计算模型椭圆参数 ===
                    chroma_m = a_C_L(1) * log(L_val_model) + a_C_L(2);
                    long_m   = a_long_axis(1)*L_val_model^3 + a_long_axis(2)*L_val_model^2 ...
                             + a_long_axis(3)*L_val_model + a_long_axis(4);
                    short_m  = a_short_axis(1)*L_val_model^3 + a_short_axis(2)*L_val_model^2 ...
                             + a_short_axis(3)*L_val_model + a_short_axis(4);
                    hue_m = a_hue_angle;  theta_m = a_theta;  alpha_m = a_alpha;
                    hue_m=hue_m+90-360;

                    % NaN 过滤
                    if ~isnan(chroma_m) && ~isinf(chroma_m)
                        model_C_list = [model_C_list; chroma_m];
                    end
                    if ~isnan(chroma_m) && ~isnan(long_m) && ~isnan(short_m) ...
                            && ~isnan(alpha_m) && loaded_this && long_m > 0 && short_m > 0
                        [par_ell] = calculate_par_from_ellipse(hue_m, chroma_m, long_m, short_m, theta_m, alpha_m);
                        vp = ~any(isnan(lab_group_tgt(:,2:3)), 2);
                        if sum(vp) > 2
                            y_pred = calculate_y(lab_group_tgt(vp, 2), lab_group_tgt(vp, 3), par_ell);
                            y_all = [y_all; y_pred];
                            p_all = [p_all; p_group_tgt(vp)];
                        end
                    end

                    % === 实验 C*（从 dropped subject 的 par_data 中取）===
                    par_exp = squeeze(par_data_full(i_tgt, :, val_indices, 1));
                    if ~any(isnan(par_exp)) && ~any(isinf(par_exp))
                        C_exp = sqrt(par_exp(4)^2 + par_exp(5)^2);
                        exp_C_list = [exp_C_list; C_exp];
                    end
                end  % end i_tgt

                % === 汇总验证 r ===
                % r(C_model, C_exp)
                if length(model_C_list) >= 3 && length(exp_C_list) >= 3 ...
                        && std(model_C_list) > 0 && std(exp_C_list) > 0
                    r_C_model = corr(model_C_list, exp_C_list);
                end
                % r(C_exp) vs L*
                if length(exp_C_list) >= 3 && std(exp_C_list) > 0
                    L_exp_v = avg_drop_all(indices_target, 1);
                    L_exp_v = L_exp_v(~isnan(exp_C_list));
                    exp_C_v = exp_C_list(~isnan(exp_C_list));
                    if length(L_exp_v) >= 3 && std(L_exp_v) > 0
                        r_C_exp = corr(L_exp_v, exp_C_v);
                    end
                end
                % r(y_model, p_group) — 核心验证指标
                if length(y_all) >= 3 && std(y_all) > 0 && std(p_all) > 0
                    r_model_y = corr(y_all, p_all, 'Type', 'Pearson');
                    rmse_model_y = sqrt(mean((y_all - p_all).^2));
                end

                % ===== 打印（每组参数立即输出）=====
                fprintf('[%s|%s] drop=%s attr=%s | r(y)=%.4f rmse=%.4f | r(Cm)=%.4f | r(Ce)=%.4f\n', ...
                    nation, obs_type, dropped_lastPart, attr_name, ...
                    r_model_y, rmse_model_y, r_C_model, r_C_exp);

                % ===== 追加写 xlsx（当前行）=====
                row_data = {attr_name, dropped_lastPart, sprintf('%d', dropped_subject_idx), ...
                    r_model_y, rmse_model_y, r_C_model, r_C_exp, ...
                    a_C_L(1), a_C_L(2), ...
                    a_long_axis(1), a_long_axis(2), a_long_axis(3), a_long_axis(4), ...
                    a_short_axis(1), a_short_axis(2), a_short_axis(3), a_short_axis(4), ...
                    a_hue_angle, a_theta, a_alpha};
                writecell(row_data, excel_filename, 'Sheet', sheet_name, 'WriteMode', 'append');
            end  % end attribute
        end  % end val_combo_idx

        fprintf('--- [%s] N-Drop 完成: %d subject x %d attr = %d 行已写入 ---\n', ...
            nation, n_subjects_nation, length(attributes), n_subjects_nation * length(attributes));
    end  % end nation

    fprintf('\n文件已写入: %s\n', excel_filename);
end  % end obs_type

%% ===== 汇总统计（从已写 xlsx 中读回计算均值）=====
fprintf('\n========== N-Drop CV 汇总 (n_drop=%d) ==========\n', n_drop);
for i_nation = 1:length(nations)
    nation = nations(i_nation);
    n_subj = length(nation_indices{i_nation});
    if n_subj <= n_drop, continue; end

    sheet_name = strrep(nation, ' ', '_');
    sheet_data = [];
    try
        [~, ~, sheet_data] = xlsread(excel_filename, sheet_name);
    catch,  end

    if ~isempty(sheet_data)
        n_rows = size(sheet_data, 1);
        if n_rows >= 2
            fprintf('\n[%s] (n_subj=%d)\n', nation, n_subj);
            fprintf('  Attribute    | r(y_model) | rmse(y) | r(C_mod) | r(C_exp) | N\n');
            fprintf('  ------------------------------------------------------\n');
            for ia = 1:length(attributes)
                attr_name = attribute_names_new(attributes(ia));
                r_y_list = []; rmse_y_list = []; r_Cmod_list = []; r_Cexp_list = [];
                for rr = 2:n_rows
                    if ischar(sheet_data{rr,1}) && strcmp(strtrim(sheet_data{rr,1}), attr_name)
                        v = sheet_data{rr,4};
                        if isnumeric(v) && ~isnan(v), r_y_list = [r_y_list; v]; end
                        v2 = sheet_data{rr,5};
                        if isnumeric(v2) && ~isnan(v2), rmse_y_list = [rmse_y_list; v2]; end
                        v3 = sheet_data{rr,6};
                        if isnumeric(v3) && ~isnan(v3), r_Cmod_list = [r_Cmod_list; v3]; end
                        v4 = sheet_data{rr,7};
                        if isnumeric(v4) && ~isnan(v4), r_Cexp_list = [r_Cexp_list; v4]; end
                    end
                end
                fprintf('  %-12s | %10.4f | %8.4f | %8.4f | %8.4f | %d\n', ...
                    attr_name, nanmean(r_y_list), nanmean(rmse_y_list), ...
                    nanmean(r_Cmod_list), nanmean(r_Cexp_list), length(r_y_list));
            end
        end
    end
end
fprintf('\n保存路径: %s\n', r_excel_output_folder);
fprintf('Done!\n');
