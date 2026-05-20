% scatter_L_depend_n_drop1.m
% Leave-One-Subject-Out N-Drop 交叉验证版本
% 基于 scatter_L_depend_n_drop.m 修改：
%   ① xlsx + .mat 双重保存拟合参数
%   ② 对每个 nation/attribute/i_par/val_combo_idx 绘制一张 contour+scatter 图
%       - scatter: dropped subject 的 lab_group_tgt / p_group_tgt
%       - contour: par_ell（拟合椭圆，红实线）vs par_all(i_par,:)（dropped 原椭圆，黑虚线）
close all; clc; clear;
addpath("utils\");

%% ===== 用户可调参数 =====
n_drop = 1;
if_draw = "true";   % "true"=出图, "false"=只算数据不出图

%% ===== 基本定义 =====
attributes = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
attribute_names_new = ["Preference", "Attractiveness", "Feminine", "Cooperative", ...
    "Youth", "Healthy", "Fidelity", "Harmony", "Fair", "Ruddy"];

lastParts = {'f04i', 'f05i', 'f06i', 'm04i', 'm05i', 'm06i', ...
    'f01i', 'f02i', 'm01i', 'm02i', 'm03i', ...
    'f07i', 'f08i', 'm07i', 'm08i', ...
    'f09i', 'f10i', 'm09i', 'm10i'};
% 修正: f01, f02, f03, f04 顺序与原脚本一致
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
nation_names = ["Asian", "Caucasian", "South Asian", "African"];

hue_values = linspace(0, 1, length(nations) + 1);
hue_values = hue_values(1:end-1);
hsv_matrix = [hue_values', 0.8 * ones(length(nations), 1), 0.8 * ones(length(nations), 1)];
colors = hsv2rgb(hsv_matrix);

average_reshaped = cell(5, 1);
par_reshaped = cell(3, 5, 1);
lab_fit_reshaped = cell(3, 5, 1);

Dtype = 'efit_p';
scale_type_origin = "unscaled";

%% ===== 输出目录 =====
pic_folder = fullfile('ellip_pic_p', Dtype, "fullpara_n_drop", CT_type, fit_type);
if ~exist(pic_folder, 'dir'), mkdir(pic_folder); end

obs_folder_name = "non_model";
drop_folder_name = sprintf('drop_%d', n_drop);
r_output_folder = fullfile("AnalyseResults_p", Dtype, scale_type_origin, ...
    "model_fullpara_n_drop", CT_type, "new", iOr, obs_folder_name, drop_folder_name);
if ~exist(r_output_folder, 'dir'), mkdir(r_output_folder); end

excel_filename = fullfile(r_output_folder, sprintf('n_drop_cv_results_n%d.xlsx', n_drop));
mat_filename   = fullfile(r_output_folder, sprintf('n_drop_cv_results_n%d.mat', n_drop));

%% ===== 预加载所有 par / lab数据 =====
fprintf('========== 预加载数据 ...\n');
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
end
fprintf('预加载完成.\n\n');

%% ===== N-Drop 交叉验证 + 绘图 =====
% pcn 列表
if iOr == 'i'
    pcn = ["H3K", "H4K", "H5K", "H6K", "HD65", "H7K", "H8K", ...
           "M3K", "M4K", "M5K", "M6K", "MD65", "M7K", "M8K", ...
           "L3K", "L4K", "L5K", "L6K", "LD65", "L7K", "L8K"];
else
    pcn = ["rs01","rs02","rs03","rs04","rs05","rs06","rs07", ...
           "rs08","rs09","rs10","rs11","rs12","rs13","rs14"];
end

% 颜色列表（drop 循环用）
drop_colors = lines(20);

% 所有结果的 accumulator
all_results = struct();

% ---- 初始化 xlsx sheet header ----
if exist(excel_filename, 'file'), try delete(excel_filename); end; end
for i_n = 1:length(nations)
    nation = nations(i_n);
    sheet_name = strrep(nation, ' ', '_');
    col_header = {'Attr', 'Drop_subj', 'Drop_LP', ...
        'r_model_y', 'rmse_y', 'r_C_mod', 'r_C_exp', ...
        'a_C1', 'a_C2', ...
        'a_la1', 'a_la2', 'a_la3', 'a_la4', ...
        'a_sa1', 'a_sa2', 'a_sa3', 'a_sa4', ...
        'hue_angle', 'theta', 'alpha', ...
        'fp_a_C1', 'fp_a_C2', ...
        'fp_a_la1', 'fp_a_la2', 'fp_a_la3', 'fp_a_la4', ...
        'fp_a_sa1', 'fp_a_sa2', 'fp_a_sa3', 'fp_a_sa4', ...
        'fp_hue_angle', 'fp_theta', 'fp_alpha', ...
        'delta_a4', 'delta_a5', ...
        'delta_C', 'delta_la', 'delta_sa', ...
        'delta_hue', 'delta_theta', 'delta_alpha'};
    writecell(col_header, excel_filename, 'Sheet', sheet_name, 'WriteMode', 'overwritesheet');
end

%% ===== 主循环：nation → val_combo_idx → attribute → i_par =====
for i_nation = 1:length(nations)
    nation = nations(i_nation);
    curr_nation_indices = nation_indices{i_nation};
    n_subjects_nation = length(curr_nation_indices);
    nation_serial = sprintf("%02d%s", i_nation, nation_names(i_nation));

    if n_subjects_nation <= n_drop
        warning('Nation %s 只有 %d 个 subject，跳过.', nation, n_subjects_nation);
        continue;
    end

    % nation 结果容器
    nation_result = struct();
    nation_result.nation   = nation;
    nation_result.val_results = {};

    sheet_name = strrep(nation, ' ', '_');

    % 每人轮流当验证集
    for val_combo_idx = 1:n_subjects_nation
        val_indices = val_combo_idx;    % n_drop=1 时为标量
        train_indices = setdiff(1:n_subjects_nation, val_indices);

        dropped_subject_idx = curr_nation_indices(val_indices);
        dropped_lastPart   = lastParts{dropped_subject_idx};

        % 加载 dropped subject 的 average_lab_all
        avg_drop_file = fullfile("aveSkin", dropped_lastPart, "autoNhand_scaleoverLUT.mat");
        if exist(avg_drop_file, 'file')
            avg_drop_d  = load(avg_drop_file);
            avg_drop_all = avg_drop_d.average_lab_all(:, 1:3);
        else
            avg_drop_all = NaN(21, 3);
        end

        val_result = struct();
        val_result.val_combo_idx = val_combo_idx;
        val_result.dropped_lastPart = dropped_lastPart;
        val_result.dropped_subject_idx = dropped_subject_idx;
        val_result.attr_results = {};

        for idx_attribute = 1:length(attributes)
            attribute = attributes(idx_attribute);
            attr_name = attribute_names_new(attribute);
            attribute_serial = strcat(sprintf("%02d", attribute), attr_name);

            if attribute == 7
                i_obs_used = 2;
            else
                i_obs_used = 1;
            end

            % ===== 训练集数据 =====
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

            % ===== 训练集派生量 =====
            C_train     = sqrt(par_train_valid(:,4).^2 + par_train_valid(:,5).^2);
            hue_train=atan2d( par_train_valid(:,5),par_train_valid(:,4));
            alpha_tr    = -log(par_train_valid(:,6));
            alpha_tr(isinf(alpha_tr) | isnan(alpha_tr)) = NaN;
            lambda00_tr = par_train_valid(:,1) ./ alpha_tr.^2;
            lambda01_tr = par_train_valid(:,3) ./ alpha_tr.^2 ./ 2;
            lambda11_tr = par_train_valid(:,2) ./ alpha_tr.^2;
            theta_tr    = 0.5 * atan2d(2 * lambda01_tr, (lambda00_tr - lambda11_tr));
            theta_tr    = mod(theta_tr, 360);
            A_tr = lambda00_tr .* cosd(theta_tr).^2 - lambda01_tr .* sind(2*theta_tr) + lambda11_tr .* sind(theta_tr).^2;
            B_tr = lambda00_tr .* sind(theta_tr).^2 + lambda01_tr .* sind(2*theta_tr) + lambda11_tr .* cosd(theta_tr).^2;
            A_tr(A_tr <= 0) = NaN;  B_tr(B_tr <= 0) = NaN;
            long_axis_tr  = sqrt(1 ./ A_tr);
            short_axis_tr = sqrt(1 ./ B_tr);

            % ===== 拟合 a_C_L（对数模型）=====
            [a_C_L, ~, ~, ~] = model_C_L_BIC(L_train, C_train, 4);
            if ~any(isnan(a_C_L))
                valid_train_C = ~isnan(L_train) & ~isnan(C_train) & L_train > 0;
                C_pred_train  = a_C_L(1)*log(L_train(valid_train_C)) + a_C_L(2);
                r_C_L_train   = corr(C_pred_train, C_train(valid_train_C));
            else
                a_C_L = [NaN, NaN];  r_C_L_train = NaN;
            end

            % ===== 拟合 a_long_axis（三次函数）=====
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

            % ===== 拟合 a_short_axis（三次函数）=====
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
            a_hue_angle = mean(hue_train);
            a_theta     = mean(theta_tr);
            a_alpha     = mean(alpha_tr);

            % ===== 收集结果（跨 i_par 汇总）=====
            r_model_y_list = [];  rmse_y_list = [];
            model_C_list = [];    exp_C_list  = [];
            y_all = [];           p_all = [];

            % ===== obs_type_used =====
            obs_type_used = "non_model";
            if attribute == 7,  obs_type_used = "model_group";  end

            % ===== 加载 fullpara 参数（固定公式，一次算完整个 attribute）=====
            model_fp_file = fullfile("D:\work\VIVOskinExpe\analyze\AnalyseResults_p", ...
                "efit_p\unscaled\model_fullpara\d65", "new", "i", char(obs_type_used), ...
                strcat(attribute_serial, "_all_curve_params.mat"));
            if exist(model_fp_file, 'file')
                fp_data = load(model_fp_file);
                fp_a_alpha_all     = fp_data.a_alpha_all(i_nation, :);
                fp_a_CL_all        = fp_data.a_CL_all(i_nation, :);
                fp_a_hue_angle_all = fp_data.a_hue_angle_all(i_nation, :);
                fp_a_long_axis_all = fp_data.a_long_axis_all(i_nation, :);
                fp_a_short_axis_all= fp_data.a_short_axis_all(i_nation, :);
                fp_a_theta_all     = fp_data.a_theta_all(i_nation, :);
            else
                fp_a_alpha_all = NaN; fp_a_CL_all = NaN(1,2);
                fp_a_hue_angle_all = NaN; fp_a_long_axis_all = NaN(1,4);
                fp_a_short_axis_all = NaN(1,4); fp_a_theta_all = NaN;
            end

            % ===== 每个 i_par 单独记录（用于绘图）=====
            i_par_results = struct();  % field name = pcn_name

            for i_tgt = 1:length(indices_target)
                i_par = indices_target(i_tgt);
                pcn_lower = lower(pcn(i_par));
                current_pcn_name = pcn(i_par);

                % --- 加载 dropped subject 的 lab_group / p_group ---
                labNscore_file = fullfile("AnalyseResults_p", Dtype, scale_type_origin, ...
                    dropped_lastPart, obs_type_used, sprintf("%02d%s", attribute, attr_name), "labNscore", ...
                    strcat("labNscore_group", lower(dropped_lastPart), pcn_lower, ".mat"));

                lab_group_tgt = [];  p_group_tgt = [];
                if exist(labNscore_file, 'file')
                    ld_tgt = load(labNscore_file, 'lab_group', 'p_group');
                    if isfield(ld_tgt,'lab_group') && isfield(ld_tgt,'p_group') ...
                            && ~isempty(ld_tgt.lab_group) && ~isempty(ld_tgt.p_group)
                        lab_group_tgt = ld_tgt.lab_group;
                        p_group_tgt   = ld_tgt.p_group;
                    end
                end

                % --- dropped subject 在该 target 的 L* ---
                if size(avg_drop_all, 1) >= i_par && ~any(isnan(avg_drop_all(i_par, :)))
                    L_val_model = avg_drop_all(i_par, 1);
                else
                    L_val_model = NaN;
                end
                if isnan(L_val_model) || L_val_model <= 0,  continue;  end

                % --- 计算拟合椭圆 par_ell ---
                chroma_m  = a_C_L(1) * log(L_val_model) + a_C_L(2);
                long_m    = a_long_axis(1)*L_val_model^3  + a_long_axis(2)*L_val_model^2 ...
                          + a_long_axis(3)*L_val_model   + a_long_axis(4);
                short_m   = a_short_axis(1)*L_val_model^3 + a_short_axis(2)*L_val_model^2 ...
                          + a_short_axis(3)*L_val_model    + a_short_axis(4);
                hue_m     = a_hue_angle;
                theta_m   = a_theta;  alpha_m = a_alpha;

                par_ell = [];
                if ~isnan(chroma_m) && ~isnan(long_m) && ~isnan(short_m) ...
                        && ~isnan(alpha_m) && long_m > 0 && short_m > 0
                    par_ell = calculate_par_from_ellipse(hue_m, chroma_m, long_m, short_m, theta_m, alpha_m);
                end

                % --- 计算 fullpara 椭圆（在同一 L_val_model 下）---
                par_fullpara = [];
                if ~any(isnan(fp_a_CL_all)) && ~any(isnan(fp_a_long_axis_all))
                    fp_hue_angle = fp_a_hue_angle_all(1);
                    fp_chroma    = fp_a_CL_all(1) * log(L_val_model) + fp_a_CL_all(2);
                    fp_long_m    = fp_a_long_axis_all(1)*L_val_model^3 + fp_a_long_axis_all(2)*L_val_model^2 ...
                                 + fp_a_long_axis_all(3)*L_val_model + fp_a_long_axis_all(4);
                    fp_short_m   = fp_a_short_axis_all(1)*L_val_model^3 + fp_a_short_axis_all(2)*L_val_model^2 ...
                                 + fp_a_short_axis_all(3)*L_val_model + fp_a_short_axis_all(4);
                    fp_theta     = fp_a_theta_all(1);
                    fp_alpha     = fp_a_alpha_all(1);
                    if ~isnan(fp_chroma) && ~isnan(fp_long_m) && ~isnan(fp_short_m) ...
                            && ~isnan(fp_alpha) && fp_long_m > 0 && fp_short_m > 0
                        par_fullpara = calculate_par_from_ellipse(fp_hue_angle, ...
                            fp_chroma, fp_long_m, fp_short_m, fp_theta, fp_alpha);
                    end
                end

                % --- 加载 dropped subject 原椭圆 par_all(i_par,:) ---
                par_exp_full = squeeze(par_data_full(i_tgt, :, val_indices, 1));
                par_exp = [];
                if ~any(isnan(par_exp_full)) && ~any(isinf(par_exp_full))
                    par_exp = par_exp_full;
                end

                % --- 汇总验证指标 ---
                if ~isnan(chroma_m) && ~isinf(chroma_m)
                    model_C_list = [model_C_list; chroma_m];
                end
                if ~any(isnan(par_exp)) && length(par_exp) >= 6
                    C_exp = sqrt(par_exp(4)^2 + par_exp(5)^2);
                    exp_C_list = [exp_C_list; C_exp];
                end
                if ~isempty(par_ell) && ~isempty(lab_group_tgt) && ~isempty(p_group_tgt)
                    vp = ~any(isnan(lab_group_tgt(:,2:3)), 2);
                    if sum(vp) > 2
                        y_pred = calculate_y(lab_group_tgt(vp, 2), lab_group_tgt(vp, 3), par_ell);
                        y_all = [y_all; y_pred];
                        p_all = [p_all; p_group_tgt(vp)];
                    end
                end

                % --- 加载 undropped subjects 的 lab_group / p_group ---
                lab_undrop_all = [];  p_undrop_all = [];
                for i_undrop = 1:length(train_indices)
                    undrop_subj_idx = curr_nation_indices(train_indices(i_undrop));
                    undrop_lastPart = lastParts{undrop_subj_idx};
                    labNscore_undrop = fullfile("AnalyseResults_p", Dtype, scale_type_origin, ...
                        undrop_lastPart, obs_type_used, sprintf("%02d%s", attribute, attr_name), "labNscore", ...
                        strcat("labNscore_group", lower(undrop_lastPart), pcn_lower, ".mat"));
                    if exist(labNscore_undrop, 'file')
                        ld_u = load(labNscore_undrop, 'lab_group', 'p_group');
                        if isfield(ld_u,'lab_group') && isfield(ld_u,'p_group') ...
                                && ~isempty(ld_u.lab_group) && ~isempty(ld_u.p_group)
                            lab_undrop_all = [lab_undrop_all; ld_u.lab_group]; %#ok<AGROW>
                            p_undrop_all   = [p_undrop_all;   ld_u.p_group];   %#ok<AGROW>
                        end
                    end
                end

                % --- 记录单个 i_par 结果（用于绘图）---
                ipr = struct();
                ipr.i_par       = i_par;
                ipr.pcn_name    = current_pcn_name;
                ipr.lab_group   = lab_group_tgt;
                ipr.p_group     = p_group_tgt;
                ipr.lab_undrop  = lab_undrop_all;
                ipr.p_undrop    = p_undrop_all;
                ipr.par_ell     = par_ell;
                ipr.par_exp     = par_exp;
                ipr.par_fullpara= par_fullpara;
                ipr.L_val_model = L_val_model;
                ipr.r_y         = NaN;
                ipr.rmse_y      = NaN;
                % 如果有足够数据计算 r
                if ~isempty(y_all) && numel(y_all) >= 3 && std(y_all) > 0 && std(p_all) > 0
                    ipr.r_y    = corr(y_all, p_all, 'Type', 'Pearson');
                    ipr.rmse_y = sqrt(mean((y_all - p_all).^2));
                end
                % --- 计算 par_ell vs par_fullpara 的 delta（在同一个 L_val_model 下）---
                delta_a4 = NaN; delta_a5 = NaN;
                delta_C = NaN; delta_la = NaN; delta_sa = NaN;
                delta_hue = NaN; delta_theta = NaN; delta_alpha = NaN;
                if ~isempty(par_ell) && ~isempty(par_fullpara) && length(par_ell) >= 6 && length(par_fullpara) >= 6
                    % (4:5) 中心点差
                    delta_a4 = par_ell(4) - par_fullpara(4);
                    delta_a5 = par_ell(5) - par_fullpara(5);
                    % derived 参数差（在同一 L_val_model 下）
                    C_ell    = a_C_L(1)*log(L_val_model) + a_C_L(2);
                    C_fp     = fp_a_CL_all(1)*log(L_val_model) + fp_a_CL_all(2);
                    la_ell   = a_long_axis(1)*L_val_model^3  + a_long_axis(2)*L_val_model^2 ...
                             + a_long_axis(3)*L_val_model   + a_long_axis(4);
                    la_fp    = fp_a_long_axis_all(1)*L_val_model^3 + fp_a_long_axis_all(2)*L_val_model^2 ...
                             + fp_a_long_axis_all(3)*L_val_model + fp_a_long_axis_all(4);
                    sa_ell   = a_short_axis(1)*L_val_model^3 + a_short_axis(2)*L_val_model^2 ...
                             + a_short_axis(3)*L_val_model  + a_short_axis(4);
                    sa_fp    = fp_a_short_axis_all(1)*L_val_model^3 + fp_a_short_axis_all(2)*L_val_model^2 ...
                             + fp_a_short_axis_all(3)*L_val_model + fp_a_short_axis_all(4);
                    delta_C    = C_ell  - C_fp;
                    delta_la   = la_ell - la_fp;
                    delta_sa   = sa_ell - sa_fp;
                    delta_hue  = a_hue_angle - fp_a_hue_angle_all(1);
                    delta_theta= a_theta     - fp_a_theta_all(1);
                    delta_alpha= a_alpha     - fp_a_alpha_all(1);
                end
                ipr.delta_a4 = delta_a4; ipr.delta_a5 = delta_a5;
                ipr.delta_C = delta_C;   ipr.delta_la = delta_la;
                ipr.delta_sa = delta_sa; ipr.delta_hue = delta_hue;
                ipr.delta_theta = delta_theta; ipr.delta_alpha = delta_alpha;
                i_par_results.(current_pcn_name) = ipr;

            end  % end i_tgt (i_par)

            % ===== 汇总 val_combo_idx × attribute 的 r =====
            if length(y_all) >= 3 && std(y_all) > 0 && std(p_all) > 0
                r_model_y = corr(y_all, p_all, 'Type', 'Pearson');
                rmse_model_y = sqrt(mean((y_all - p_all).^2));
            else
                r_model_y = NaN;  rmse_model_y = NaN;
            end
            if length(model_C_list) >= 3 && std(model_C_list) > 0 && std(exp_C_list) > 0
                r_C_model = corr(model_C_list, exp_C_list);
            else
                r_C_model = NaN;
            end
            if length(exp_C_list) >= 3 && std(exp_C_list) > 0
                L_exp_v = avg_drop_all(indices_target, 1);
                exp_C_v = exp_C_list;
                mask_exp = ~isnan(L_exp_v) & ~isnan(exp_C_v);
                if sum(mask_exp) >= 3 && std(L_exp_v(mask_exp)) > 0
                    r_C_exp = corr(L_exp_v(mask_exp)', exp_C_v(mask_exp)');
                else
                    r_C_exp = NaN;
                end
            else
                r_C_exp = NaN;
            end

            fprintf('[%s|%s] drop=%s attr=%s | r(y)=%.4f rmse=%.4f | r(Cm)=%.4f | r(Ce)=%.4f\n', ...
                nation, obs_type_used, dropped_lastPart, attr_name, ...
                r_model_y, rmse_model_y, r_C_model, r_C_exp);

            % ===== 计算 delta 均值（跨所有 i_par）=====
            fn_pcn_avg = fieldnames(i_par_results);
            d_a4=[]; d_a5=[]; d_C=[]; d_la=[]; d_sa=[]; d_hue=[]; d_th=[]; d_al=[];
            for ii = 1:length(fn_pcn_avg)
                ipr_tmp = i_par_results.(fn_pcn_avg{ii});
                d_a4  = [d_a4;  ipr_tmp.delta_a4];   %#ok<AGROW>
                d_a5  = [d_a5;  ipr_tmp.delta_a5];   %#ok<AGROW>
                d_C   = [d_C;   ipr_tmp.delta_C];    %#ok<AGROW>
                d_la  = [d_la;  ipr_tmp.delta_la];   %#ok<AGROW>
                d_sa  = [d_sa;  ipr_tmp.delta_sa];   %#ok<AGROW>
                d_hue = [d_hue; ipr_tmp.delta_hue];  %#ok<AGROW>
                d_th  = [d_th;  ipr_tmp.delta_theta]; %#ok<AGROW>
                d_al  = [d_al;  ipr_tmp.delta_alpha]; %#ok<AGROW>
            end
            delta_a4_avg  = nanmean(d_a4);  delta_a5_avg  = nanmean(d_a5);
            delta_C_avg   = nanmean(d_C);   delta_la_avg  = nanmean(d_la);
            delta_sa_avg  = nanmean(d_sa);  delta_hue_avg = nanmean(d_hue);
            delta_th_avg  = nanmean(d_th);  delta_al_avg  = nanmean(d_al);

            % ===== 追加写 xlsx =====
            row_data = {attr_name, dropped_lastPart, sprintf('%d', dropped_subject_idx), ...
                r_model_y, rmse_model_y, r_C_model, r_C_exp, ...
                a_C_L(1), a_C_L(2), ...
                a_long_axis(1), a_long_axis(2), a_long_axis(3), a_long_axis(4), ...
                a_short_axis(1), a_short_axis(2), a_short_axis(3), a_short_axis(4), ...
                a_hue_angle, a_theta, a_alpha, ...
                fp_a_CL_all(1), fp_a_CL_all(2), ...
                fp_a_long_axis_all(1), fp_a_long_axis_all(2), fp_a_long_axis_all(3), fp_a_long_axis_all(4), ...
                fp_a_short_axis_all(1), fp_a_short_axis_all(2), fp_a_short_axis_all(3), fp_a_short_axis_all(4), ...
                fp_a_hue_angle_all(1), fp_a_theta_all(1), fp_a_alpha_all(1), ...
                delta_a4_avg, delta_a5_avg, ...
                delta_C_avg, delta_la_avg, delta_sa_avg, ...
                delta_hue_avg, delta_th_avg, delta_al_avg};
            writecell(row_data, excel_filename, 'Sheet', sheet_name, 'WriteMode', 'append');

            % ===== 保存 .mat（参数 + i_par_results）=====
            mat_row = struct();
            mat_row.attr_name       = attr_name;
            mat_row.dropped_lastPart= dropped_lastPart;
            mat_row.dropped_subject_idx = dropped_subject_idx;
            mat_row.r_model_y       = r_model_y;
            mat_row.rmse_y          = rmse_model_y;
            mat_row.r_C_model       = r_C_model;
            mat_row.r_C_exp         = r_C_exp;
            mat_row.a_C_L           = a_C_L;
            mat_row.a_long_axis     = a_long_axis;
            mat_row.a_short_axis    = a_short_axis;
            mat_row.a_hue_angle     = a_hue_angle;
            mat_row.a_theta         = a_theta;
            mat_row.a_alpha         = a_alpha;
            % fullpara 参数
            mat_row.fp_a_CL         = fp_a_CL_all;
            mat_row.fp_a_long_axis  = fp_a_long_axis_all;
            mat_row.fp_a_short_axis= fp_a_short_axis_all;
            mat_row.fp_a_hue_angle = fp_a_hue_angle_all;
            mat_row.fp_a_theta     = fp_a_theta_all;
            mat_row.fp_a_alpha     = fp_a_alpha_all;
            % delta 均值
            mat_row.delta_a4_avg  = delta_a4_avg;  mat_row.delta_a5_avg  = delta_a5_avg;
            mat_row.delta_C_avg   = delta_C_avg;   mat_row.delta_la_avg  = delta_la_avg;
            mat_row.delta_sa_avg  = delta_sa_avg;  mat_row.delta_hue_avg = delta_hue_avg;
            mat_row.delta_th_avg  = delta_th_avg;  mat_row.delta_al_avg  = delta_al_avg;
            mat_row.i_par_results = i_par_results;   % struct, field = pcn_name

            val_result.attr_results{end+1} = mat_row; %#ok<AGROW>

            % ===== 绘图：每个 i_par 画一张 =====
            if enable_plotting
                fn_pcn = fieldnames(i_par_results);
                for ip_fig = 1:length(fn_pcn)
                    pcn_n = fn_pcn{ip_fig};
                    ipr_fig = i_par_results.(pcn_n);

                    if isempty(ipr_fig.lab_group) || isempty(ipr_fig.p_group)
                        continue;   % 无散点数据则跳过
                    end

                    fig = figure('Visible', 'on');
                    hold on;

                    % --- scatter: dropped subject（实心圆）---
                    scatter(ipr_fig.lab_group(:, 2), ipr_fig.lab_group(:, 3), ...
                        40, ipr_fig.p_group, 'filled');

                    % --- scatter: undropped subjects（空心圆，灰色边缘）---
                    if ~isempty(ipr_fig.lab_undrop) && ~isempty(ipr_fig.p_undrop)
                        scatter(ipr_fig.lab_undrop(:, 2), ipr_fig.lab_undrop(:, 3), ...
                            25, ipr_fig.p_undrop, ...
                            'MarkerFaceColor', 'none', 'MarkerEdgeColor', [0.5 0.5 0.5], 'LineWidth', 0.8);
                    end

                    % --- contour: par_ell（红色实线）---
                    if ~isempty(ipr_fig.par_ell)
                        par = ipr_fig.par_ell;
                        check_d2 = par(4) + (-30:0.2:30);
                        check_d3 = par(5) + (-30:0.2:30);
                        [d2, d3] = meshgrid(check_d2, check_d3);
                        y_c = (1./(1 + par(6) * exp(sqrt(par(1)*(d2-par(4)).^2 + par(2)*(d3-par(5)).^2 ...
                            + par(3)*(d2-par(4)).*(d3-par(5)))))) .* ...
                            ((par(1)*(d2-par(4)).^2 + par(2)*(d3-par(5)).^2 ...
                            + par(3)*(d2-par(4)).*(d3-par(5))) >= 0);
                        contour(d2, d3, y_c, [0.5, 1], ...
                            'LineStyle', '-', 'LineColor', 'r', 'LineWidth', 2);
                        scatter(par(4), par(5), 60, 'r', 'filled', 'Marker', 'x');
                    end

                    % --- contour: par_exp（黑色虚线）---
                    if ~isempty(ipr_fig.par_exp) && length(ipr_fig.par_exp) >= 6
                        par_e = ipr_fig.par_exp;
                        check_d2_e = par_e(4) + (-30:0.2:30);
                        check_d3_e = par_e(5) + (-30:0.2:30);
                        [d2e, d3e] = meshgrid(check_d2_e, check_d3_e);
                        y_e = (1./(1 + par_e(6) * exp(sqrt(par_e(1)*(d2e-par_e(4)).^2 + par_e(2)*(d3e-par_e(5)).^2 ...
                            + par_e(3)*(d2e-par_e(4)).*(d3e-par_e(5)))))) .* ...
                            ((par_e(1)*(d2e-par_e(4)).^2 + par_e(2)*(d3e-par_e(5)).^2 ...
                            + par_e(3)*(d2e-par_e(4)).*(d3e-par_e(5))) >= 0);
                        contour(d2e, d3e, y_e, [0.5, 1], ...
                            'LineStyle', '--', 'LineColor', 'k', 'LineWidth', 1.5);
                    end

                    % --- contour: par_fullpara（蓝色实线）---
                    if ~isempty(ipr_fig.par_fullpara) && length(ipr_fig.par_fullpara) >= 6
                        par_fp = ipr_fig.par_fullpara;
                        check_d2_fp = par_fp(4) + (-30:0.2:30);
                        check_d3_fp = par_fp(5) + (-30:0.2:30);
                        [d2fp, d3fp] = meshgrid(check_d2_fp, check_d3_fp);
                        y_fp = (1./(1 + par_fp(6) * exp(sqrt(par_fp(1)*(d2fp-par_fp(4)).^2 + par_fp(2)*(d3fp-par_fp(5)).^2 ...
                            + par_fp(3)*(d2fp-par_fp(4)).*(d3fp-par_fp(5)))))) .* ...
                            ((par_fp(1)*(d2fp-par_fp(4)).^2 + par_fp(2)*(d3fp-par_fp(5)).^2 ...
                            + par_fp(3)*(d2fp-par_fp(4)).*(d3fp-par_fp(5))) >= 0);
                        contour(d2fp, d3fp, y_fp, [0.5, 1], ...
                            'LineStyle', '-', 'LineColor', 'b', 'LineWidth', 2);
                    end

                    % --- 参考线 ---
                    all_a = ipr_fig.lab_group(:, 2);
                    all_b = ipr_fig.lab_group(:, 3);
                    lim_max = max(max(all_a), max(all_b)) + 10;
                    lim_min = min(min(all_a), min(all_b)) - 10;
                    line([0, 0], [lim_min, lim_max], 'Color', [0.5 0.5 0.5], 'LineStyle', '--');
                    line([lim_min, lim_max], [0, 0], 'Color', [0.5 0.5 0.5], 'LineStyle', '--');
                    refline(1, 0);

                    axis equal;
                    xlim([lim_min, lim_max]);
                    ylim([lim_min, lim_max]);
                    xlabel('{\ita*}');  ylabel('{\itb*}');
                    n_undrop = length(train_indices);
                    title_str = sprintf('%s | %s | drop=%s | undrop=%d | attr=%s | L=%.1f', ...
                        nation_serial, pcn_n, dropped_lastPart, n_undrop, attr_name, ipr_fig.L_val_model);
                    title(title_str, 'Interpreter', 'none');
                    colorbar;

                    % 图例
                    lgd_h = [];
                    lgd_l = {};
                    if ~isempty(ipr_fig.par_ell)
                        [~, h1] = contour(d2, d3, y_c, [0.5, 1], ...
                            'LineStyle', '-', 'LineColor', 'r', 'LineWidth', 2);
                        lgd_h(end+1) = h1; lgd_l{end+1} = 'par_{ell} (fit)'; %#ok<AGROW>
                    end
                    if ~isempty(ipr_fig.par_exp) && length(ipr_fig.par_exp) >= 6
                        [~, h2] = contour(d2e, d3e, y_e, [0.5, 1], ...
                            'LineStyle', '--', 'LineColor', 'k', 'LineWidth', 1.5);
                        lgd_h(end+1) = h2; lgd_l{end+1} = 'par_{all} (orig)'; %#ok<AGROW>
                    end
                    if ~isempty(ipr_fig.par_fullpara) && length(ipr_fig.par_fullpara) >= 6
                        [~, h3] = contour(d2fp, d3fp, y_fp, [0.5, 1], ...
                            'LineStyle', '-', 'LineColor', 'b', 'LineWidth', 2);
                        lgd_h(end+1) = h3; lgd_l{end+1} = 'par_{fullpara}'; %#ok<AGROW>
                    end
                    % 实心/空心散点的图例占位符
                    ph1 = plot(NaN, NaN, 'o', 'MarkerSize', 6, ...
                        'MarkerFaceColor', [0.8 0.4 0.4], 'MarkerEdgeColor', 'none');
                    ph2 = plot(NaN, NaN, 'o', 'MarkerSize', 6, ...
                        'MarkerFaceColor', 'none', 'MarkerEdgeColor', [0.5 0.5 0.5], 'LineWidth', 0.8);
                    lgd_h = [lgd_h, ph1, ph2]; %#ok<AGROW>
                    lgd_l = [lgd_l, {'o solid : dropped subj'}, {'o hollow: undropped'}]; %#ok<AGROW>
                    if ~isempty(lgd_h)
                        legend(lgd_h, lgd_l, 'Location', 'best', 'FontSize', 7);
                    end

                    hold off;

                    % --- 保存图片 ---
                    pic_subdir = fullfile(pic_folder, nation, dropped_lastPart);
                    if ~exist(pic_subdir, 'dir'), mkdir(pic_subdir); end
                    pic_name = sprintf('%s_%s_%s_%s.png', ...
                        nation_serial, dropped_lastPart, attr_name, pcn_n);
                    pic_path = fullfile(pic_subdir, pic_name);
                    saveas(fig, pic_path);
                    close(fig);
                end  % end i_par loop
            end  % end enable_plotting

        end  % end attribute

        val_result.r_model_y_summary = r_model_y;   % 注：此处用的是最后一个 attr 的汇总
        nation_result.val_results{end+1} = val_result; %#ok<AGROW>
    end  % end val_combo_idx

    all_results.(nation) = nation_result;
    fprintf('--- [%s] 完成: %d subject x %d attr\n', nation, n_subjects_nation, length(attributes));
end  % end nation

%% ===== 保存 .mat（包含所有参数 + i_par_results）=====
fprintf('\n正在保存 .mat ...\n');
save(mat_filename, 'all_results');
fprintf('已保存: %s\n', mat_filename);

%% ===== 汇总打印 =====
fprintf('\n========== N-Drop CV 汇总 (n_drop=%d) ==========\n', n_drop);
for i_n = 1:length(nations)
    nation = nations(i_n);
    sheet_name = strrep(nation, ' ', '_');
    try
        [~, ~, sheet_data] = xlsread(excel_filename, sheet_name);
    catch,  continue;  end
    if isempty(sheet_data) || size(sheet_data, 1) < 2, continue; end

    fprintf('\n[%s]\n', nation);
    fprintf('  Attribute    | r(y_model) | rmse(y) | r(C_mod) | r(C_exp) | N\n');
    fprintf('  ------------------------------------------------------\n');
    for ia = 1:length(attributes)
        attr_name = attribute_names_new(attributes(ia));
        r_y_list = []; rmse_y_list = []; r_Cmod_list = []; r_Cexp_list = [];
        for rr = 2:size(sheet_data, 1)
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
        if ~isempty(r_y_list)
            fprintf('  %-12s | %10.4f | %8.4f | %8.4f | %8.4f | %d\n', ...
                attr_name, nanmean(r_y_list), nanmean(rmse_y_list), ...
                nanmean(r_Cmod_list), nanmean(r_Cexp_list), length(r_y_list));
        end
    end
end
fprintf('\n输出:\n  xlsx: %s\n  mat:  %s\n  pics: %s\n', excel_filename, mat_filename, pic_folder);
fprintf('\n========== Done! ==========\n');
