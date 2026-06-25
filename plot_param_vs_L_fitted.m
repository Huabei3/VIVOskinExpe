%% plot_param_vs_L_fitted.m
%  参考 scatter_L_depend_BIC.m，不再重新拟合，直接用已保存的拟合参数
%  画 6 张图（C*, h, a_long, a_short, θ, α），每张图 4 种人种
%  每张图包含：拟合曲线 + 散点

close all; clc; clear;
addpath("utils\")

%% ========== 配置 ==========
attribute_idx  = 1;
attribute      = 1;
attr_name      = "Preference";
attr_serial    = "01Preference";

iOr            = 'i';
CT_type        = "d65";
Dtype          = 'efit_p';
obs_type       = "non_model";

% 人种（画4个，不含 "all"）
nations_plot   = ["AS", "CA", "SA", "AF"];
n_nations      = length(nations_plot);
nation_indices = {1:6, 7:12, 13:16, 17:20};

indices_target = [5, 12, 19];

%% ========== 加载已有拟合参数 ==========
params_file = fullfile('AnalyseResults_p', Dtype, "unscaled", ...
    "model_fullpara", CT_type, "new", iOr, obs_type, ...
    strcat(attr_serial, '_all_curve_params.mat'));

if ~exist(params_file, 'file')
    error('拟合参数文件不存在: %s\n请先运行 scatter_L_depend_new.m', params_file);
end
fprintf('加载拟合参数: %s\n', params_file);
load(params_file);  % a_CL_all, a_long_axis_all, a_short_axis_all, a_hue_angle_all, a_theta_all, a_alpha_all

%% ========== 加载原始数据 ==========
mat_data_file = fullfile("ellip_pic_p", Dtype, CT_type, ...
    strcat("data_unscaled_reshaped_", iOr, ".mat"));
if ~exist(mat_data_file, 'file')
    error('原始数据文件不存在: %s\n请先运行 scatter_L_depend_new.m', mat_data_file);
end
fprintf('加载原始数据: %s\n', mat_data_file);
data_loaded = load(mat_data_file);
par_reshaped     = data_loaded.par_reshaped;
lab_fit_reshaped = data_loaded.lab_fit_reshaped;

%% ========== 提取原始散点数据（只取 attribute=1 即 01Preference）==========
L_by_nation   = cell(n_nations, 1);
C_by_nation   = cell(n_nations, 1);
h_by_nation   = cell(n_nations, 1);
along_by_nation  = cell(n_nations, 1);
ashort_by_nation = cell(n_nations, 1);
theta_by_nation  = cell(n_nations, 1);
alpha_by_nation  = cell(n_nations, 1);

for i_nation = 1:n_nations
    i_obs_used = 1;

    lab_data = lab_fit_reshaped{i_obs_used, i_nation}(indices_target, :, :, attribute);
    par_data = par_reshaped{i_obs_used, i_nation}(indices_target, :, :, attribute);

    [n_targets, ~, n_subjects] = size(lab_data);
    lab_g = reshape(permute(lab_data, [1 3 2]), n_targets * n_subjects, 3);
    par_g = reshape(permute(par_data, [1 3 2]), n_targets * n_subjects, 6);

    valid = ~any(isnan(lab_g), 2) & ~any(isnan(par_g), 2);
    L_valid   = lab_g(valid, 1);
    par_valid = par_g(valid, :);

    % --- C* (chroma) ---
    C_valid = sqrt(par_valid(:,4).^2 + par_valid(:,5).^2);

    % --- h (hue angle) ---
    h_valid = mod(atan2d(par_valid(:,5), par_valid(:,4)), 360);

    % --- α ---
    alpha_vals = -log(par_valid(:,6));
    alpha_vals(isinf(alpha_vals) | isnan(alpha_vals)) = NaN;

    % --- 椭圆参数: theta, a_long, a_short ---
    lambda00 = par_valid(:,1) ./ alpha_vals.^2;
    lambda01 = par_valid(:,3) ./ alpha_vals.^2 ./ 2;
    lambda11 = par_valid(:,2) ./ alpha_vals.^2;

    theta_vals = 0.5 * atan2d(2 * lambda01, lambda00 - lambda11);
    theta_vals = mod(theta_vals, 360);
    theta_raw = theta_vals;  % 原始 theta，用于计算 a_long/a_short

    A = lambda00 .* cosd(theta_raw).^2 - lambda01 .* sind(2*theta_raw) + lambda11 .* sind(theta_raw).^2;
    B = lambda00 .* sind(theta_raw).^2 + lambda01 .* sind(2*theta_raw) + lambda11 .* cosd(theta_raw).^2;
    A(A <= 0) = NaN;
    B(B <= 0) = NaN;
    along_vals  = sqrt(1 ./ A);
    ashort_vals = sqrt(1 ./ B);

    % 存储
    L_by_nation{i_nation}   = L_valid;
    C_by_nation{i_nation}   = C_valid;
    h_by_nation{i_nation}   = h_valid;
    along_by_nation{i_nation}  = along_vals;
    ashort_by_nation{i_nation} = ashort_vals;
    theta_by_nation{i_nation}  = theta_vals - 360 + 90;   % 画图前变换：-360+90（只影响 theta 自身）
    alpha_by_nation{i_nation}  = alpha_vals;
end

%% ========== 颜色和标签 ==========
% 4 种人种：HSV 均匀分布 + SA→黑 AF→橙（参考 drawVIVOskin.m）
num_colors = 4;
hue_values = linspace(0, 1, num_colors + 1);
hue_values = hue_values(1:end-1);
hsv_matrix = [hue_values', 0.8 * ones(num_colors, 1), 0.8 * ones(num_colors, 1)];
colors = hsv2rgb(hsv_matrix);
colors(3,:) = [0 0 0];
colors(4,:) = [1 0.5 0];

output_dir = fullfile('ellip_pic_p', Dtype, CT_type, 'param_vs_L_fitted');
if ~exist(output_dir, 'dir')
    mkdir(output_dir);
end

%% ========== 辅助函数：画单张图 ==========
function h_fig = plot_one_param(L_cell, Y_cell, a_fit, fit_func, ...
    param_name, x_label, colors, output_dir, attr_serial, xlim_val, tick_step)
    n_nations = length(L_cell);
    % 文件名安全化（去除 * ^ { } 等非法字符）
    safe_name = regexprep(param_name, '[*^{}\\]', '');
    safe_name = strrep(safe_name, '_', '');  % 之后重建显示名
    if isempty(safe_name), safe_name = 'param'; end

    h_fig = figure('Name', ['Fitted ', param_name], ...
                   'Position', [100, 100, 800, 600], ...
                   'Visible', 'on');
    hold on;

    for i_n = 1:n_nations
        L_valid = L_cell{i_n};
        Y_valid = Y_cell{i_n};

        % 散点：横轴=参数, 纵轴=L*
        scatter(Y_valid, L_valid, 18, colors(i_n, :), ...
                'filled', 'MarkerFaceAlpha', 0.3, ...
                'MarkerEdgeColor', colors(i_n, :));

        % 拟合曲线：横轴=Y_fit, 纵轴=L_fit
        L_fit = linspace(min(L_valid), max(L_valid), 200)';
        Y_fit = fit_func(a_fit(i_n, :), L_fit);

        plot(Y_fit, L_fit, '-', 'Color', colors(i_n, :), 'LineWidth', 2);
    end

    grid off;
    box on;

    if tick_step > 0
        xticks(xlim_val(1):tick_step:xlim_val(2));
        yticks(0:tick_step:70);
        axis equal;
    else
        pbaspect([20 70 1]);
    end
    axis equal;
    xlim(xlim_val);
    ylim([0, 70]);

    hold off;

    xlabel(x_label, 'FontSize', 12);
    ylabel('L^*', 'FontSize', 12, 'FontAngle', 'italic');

    % xlabel 靠近坐标轴半 fontsize，ylabel 远离坐标轴 0.8 fontsize
    ax = gca;
    xl = ax.XLabel;
    yl = ax.YLabel;
    xRange = diff(xlim_val);
    yRange = 70;
    xl_pos = xl.Position;
    xl.Position = [xl_pos(1), xl_pos(2) - 0.04 * yRange, xl_pos(3)];
    yl_pos = yl.Position;
    yl.Position = [yl_pos(1) - 0.16 * xRange, yl_pos(2), yl_pos(3)];

    out_name = sprintf('%s_vs_L_fitted', safe_name);
    savefig(h_fig, fullfile(output_dir, strcat(out_name, '.fig')));
    fprintf('  已保存: %s\n', fullfile(output_dir, strcat(out_name, '.fig')));
    close(h_fig);
end

%% ========== Figure 1: C* vs L*  (Logarithmic: C = a1*log(L) + a2) ==========
fprintf('\n===== 1/6: C^* (chroma) =====\n');
plot_one_param(L_by_nation, C_by_nation, a_CL_all(1:4, :), ...
    @(a, L) a(1)*log(L) + a(2), ...
    'C^*', '\itC^*_{\rmab}', colors, output_dir, attr_serial, [0, 30], 10);

%% ========== Figure 2: h (hue angle) vs L*  (常数 = mean) ==========
fprintf('===== 2/6: h (hue angle) =====\n');
plot_one_param(L_by_nation, h_by_nation, a_hue_angle_all(1:4, :), ...
    @(a, L) a(1) * ones(size(L)), ...
    'h', '\ith \rm(°)', colors, output_dir, attr_serial, [30, 60], -1);

%% ========== Figure 3: a_long vs L*  (Cubic) ==========
fprintf('===== 3/6: a_{long} =====\n');
plot_one_param(L_by_nation, along_by_nation, a_long_axis_all(1:4, :), ...
    @(a, L) a(1)*L.^3 + a(2)*L.^2 + a(3)*L + a(4), ...
    'a_{long}', '\ita_{\rmmaj}', colors, output_dir, attr_serial, [0, 20], 10);

%% ========== Figure 4: a_short vs L*  (Cubic) ==========
fprintf('===== 4/6: a_{short} =====\n');
plot_one_param(L_by_nation, ashort_by_nation, a_short_axis_all(1:4, :), ...
    @(a, L) a(1)*L.^3 + a(2)*L.^2 + a(3)*L + a(4), ...
    'a_{short}', '\itb_{\rmmin}', colors, output_dir, attr_serial, [0, 20], 10);

%% ========== Figure 5: θ vs L*  (常数 = mean) ==========
fprintf('===== 5/6: θ (theta) =====\n');
plot_one_param(L_by_nation, theta_by_nation, a_theta_all(1:4, :), ...
    @(a, L) (a(1) - 270) * ones(size(L)), ...   % 拟合常数也做 -360+90
    'θ', '\itθ \rm(°)', colors, output_dir, attr_serial, [0, 100], -1);

%% ========== Figure 6: α vs L*  (常数 = mean) ==========
fprintf('===== 6/6: α (alpha) =====\n');
plot_one_param(L_by_nation, alpha_by_nation, a_alpha_all(1:4, :), ...
    @(a, L) a(1) * ones(size(L)), ...
    'α', '\itα', colors, output_dir, attr_serial, [-5, 10], -1);

fprintf('\n========== 完成！共 6 张图，输出目录: %s ==========\n', fullfile(pwd, output_dir));

%% ========== 合并所有子图为一张大图（参考 drawVIVOskin.m）==========
fprintf('\n===== 合并 6 张子图为一张图 =====\n');

% 按原始绘图顺序排列文件名
fig_order = {'C_vs_L_fitted.fig', 'h_vs_L_fitted.fig', ...
             'along_vs_L_fitted.fig', 'ashort_vs_L_fitted.fig', ...
             'θ_vs_L_fitted.fig', 'α_vs_L_fitted.fig'};

% 检查文件是否都存在
exist_flags = false(size(fig_order));
for i = 1:length(fig_order)
    exist_flags(i) = isfile(fullfile(output_dir, fig_order{i}));
end
fig_order = fig_order(exist_flags);
n_figs = length(fig_order);

if n_figs > 0
    n_cols = 6;
    n_rows = 1;

    fig_main = figure('Name', 'All Params vs L* (merged)', ...
                      'Units', 'pixels', ...
                      'Position', [100, 100, 2000, 420], ...
                      'Visible', 'off');

    marginL = 0.05;
    marginR = 0.02;
    marginTop = 0.08;
    legendHeightNorm = 0.25;
    availableH = 1 - marginTop - legendHeightNorm;
    baseWidth = (1 - marginL - marginR) / n_cols;

    for i = 1:n_figs
        tempFig = openfig(fullfile(output_dir, fig_order{i}), 'invisible');
        ax_old = gca;

        w = baseWidth * 0.85;
        left = marginL + (i - 1) * baseWidth + (baseWidth - w) / 2;
        bottom = legendHeightNorm + 0.02;

        ax_new = axes('Parent', fig_main, 'Units', 'normalized', ...
                      'Position', [left, bottom, w, availableH]);
        copyobj(allchild(ax_old), ax_new);

        ax_new.XLim = ax_old.XLim;
        ax_new.YLim = ax_old.YLim;
        ax_new.XTick = ax_old.XTick;
        ax_new.YTick = ax_old.YTick;
        ax_new.XTickLabel = ax_old.XTickLabel;
        ax_new.YTickLabel = ax_old.YTickLabel;
        ax_new.DataAspectRatio = ax_old.DataAspectRatio;
        ax_new.PlotBoxAspectRatio = ax_old.PlotBoxAspectRatio;
        ax_new.Box = 'on';
        ax_new.FontSize = 10;

        % copy labels (no title)
        copyobj(ax_old.XLabel, ax_new);
        copyobj(ax_old.YLabel, ax_new);

        close(tempFig);
    end

    % ========== 手动 legend（参考 drawVIVOskin.m: plot + text）==========
    legAx = axes('Parent', fig_main, 'Units', 'normalized', ...
                 'Position', [0.08, 0.0, 0.84, legendHeightNorm - 0.06], ...
                 'Color', 'none', 'Visible', 'off');
    hold(legAx, 'on');
    xlim(legAx, [0, 1]);
    ylim(legAx, [0, 1]);

    nations_legend = {"亚洲人", "高加索人", "南亚人", "非洲人"};
    n_leg = length(nations_legend);
    sidePad = 0.10;
    colGap = 1 / (n_leg + 0.3);
    iconTextGap = 0.025;

    for k = 1:n_leg
        tx = sidePad + (k - 1) * colGap;
        ty = 0.5;
        plot(legAx, tx, ty, 'o', ...
             'MarkerFaceColor', colors(k, :), ...
             'MarkerEdgeColor', 'none', ...
             'MarkerSize', 10, 'Clipping', 'off');
        text(legAx, tx + iconTextGap, ty, nations_legend{k}, ...
             'FontSize', 12, 'VerticalAlignment', 'middle', ...
             'Interpreter', 'none');
    end
    hold(legAx, 'off');

    % 保存合并图
    merged_name = fullfile(output_dir, 'all_params_vs_L_merged');
    savefig(fig_main, strcat(merged_name, '.fig'));
    exportgraphics(fig_main, strcat(merged_name, '.png'), 'Resolution', 150);
    fprintf('  合并图已保存: %s\n', strcat(merged_name, '.fig'));
    close(fig_main);
end
