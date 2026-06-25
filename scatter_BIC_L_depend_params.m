%% scatter_BIC_L_depend_params.m
% 基于 scatter_L_depend_BIC.m，不再拟合而是直接用 Logarithmic BIC 结果画图
% 6个参数 (C, h, a_long, a_short, theta, alpha) 各一张子图
% L* vs 参数，4种人种颜色，拟合曲线+散点
% 一行6子图 + 底部手工legend
%
% 用法: 直接运行，输出到:
%   ellip_pic_p/efit_p/d65/BIC_L_depend_params/

close all; clc; clear;
addpath("utils\")

%% ========== 配置 ==========
targetFontSize = 12;
interpreter_type = "tex";

nations = ["AS", "CA", "SA", "AF"];
nation_names = ["亚洲人", "高加索人", "南亚人", "非洲人"];

% 6个参数: 名称 / 在par_reshaped中的列号（C和h由a,b计算得到）
param_ids = ["C", "h", "a_long", "a_short", "theta", "alpha"];
param_cols = [nan, nan, 1, 2, 3, 6];  % nan表示需要计算
xlabels = {'C^{*}_{ab}', '{\it h}', '{\it a}_{maj}', '{\it b}_{min}', '\theta', '\alpha'};
ylabels = {'L^{*}', 'L^{*}', 'L^{*}', 'L^{*}', 'L^{*}', 'L^{*}'};

% xlim for each parameter
xlims = {[0, 30], [30, 60], [0, 15], [0, 15], [0, 100], [0, 5]};
ylims = [0, 70];

% xtick/ytick interval (nan = default auto)
tick_intervals = [10, nan, 10, 10, nan, nan];

% filenames (用于保存和排序)
file_prefixes = ["01_C", "02_h", "03_a_long", "04_a_short", "05_theta", "06_alpha"];

%% ========== 颜色 ==========
num_colors = 4;
hue_values = linspace(0, 1, num_colors + 1);
hue_values = hue_values(1:end-1); 
hsv_matrix = [hue_values', 0.8 * ones(num_colors, 1), 0.8 * ones(num_colors, 1)];
colors = hsv2rgb(hsv_matrix);
colors(3,:) = [0 0 0];
colors(4,:) = [1 0.5 0];

%% ========== 加载 BIC 曲线参数（C vs L 的对数拟合） ==========
bic_file = fullfile('AnalyseResults_p', 'efit_p', 'unscaled', ...
    'model_fullpara', 'd65', 'new', 'i', 'non_model', 'BIC', ...
    'Logarithmic', '01Preference_BIC_curve_params.mat');
bic_data = load(bic_file);
a_val_all = bic_data.a_val_all;  % cell [5×1], 最后一个是"all"

%% ========== 加载散点数据 ==========
mat_data_file = fullfile("ellip_pic_p", "efit_p", "d65", ...
    "data_unscaled_reshaped_i.mat");
if exist(mat_data_file, 'file')
    fprintf('加载已有数据文件: %s\n', mat_data_file);
    data_loaded = load(mat_data_file);
    par_reshaped = data_loaded.par_reshaped;
    lab_fit_reshaped = data_loaded.lab_fit_reshaped;
else
    error('数据文件不存在: %s\n请先运行 scatter_L_depend_new.m 生成数据。', mat_data_file);
end

indices_target = [5, 12, 19];  % d65
attribute = 1;  % Preference
obs_idx = 1;    % non_model

%% ========== 提取散点数据并拟合 ==========
% 对每个参数和每个人种，提取 (L*, param) 散点并拟合: param = a1*log(L) + a2
% stored_params{i_param, i_nation} = [a1, a2]  (i_nation=1:4 对应 AS,CA,SA,AF)
stored_params = cell(6, 4);

for i_param = 1:6
    for i_nation = 1:4
        % 提取 L* 和 par 数据
        lab_data = lab_fit_reshaped{obs_idx, i_nation}(indices_target, :, :, attribute);
        par_data = par_reshaped{obs_idx, i_nation}(indices_target, :, :, attribute);

        [n_targets, ~, n_subjects] = size(lab_data);
        L_all = reshape(permute(lab_data(:, 1, :), [1 3 2]), n_targets * n_subjects, 1);

        if i_param == 1  % C = sqrt(a^2 + b^2)
            col4 = reshape(permute(par_data(:, 4, :), [1 3 2]), n_targets * n_subjects, 1);
            col5 = reshape(permute(par_data(:, 5, :), [1 3 2]), n_targets * n_subjects, 1);
            param_all = sqrt(col4.^2 + col5.^2);
        elseif i_param == 2  % h = atan2d(b, a)
            col4 = reshape(permute(par_data(:, 4, :), [1 3 2]), n_targets * n_subjects, 1);
            col5 = reshape(permute(par_data(:, 5, :), [1 3 2]), n_targets * n_subjects, 1);
            param_all = atan2d(col5, col4);
        else
            param_all = reshape(permute(par_data(:, param_cols(i_param), :), [1 3 2]), n_targets * n_subjects, 1);
        end

        % 移除无效数据
        valid = ~isnan(L_all) & ~isnan(param_all) & L_all > 0;
        L_valid = L_all(valid);
        param_valid = param_all(valid);

        if i_param == 5  % theta: -360 + 90
            param_valid = param_valid - 360 + 90;
        end

        % 保存散点数据
        scatter_L{i_param, i_nation} = L_valid;
        scatter_param{i_param, i_nation} = param_valid;

        % 对数拟合: param = a1*log(L) + a2
        if i_param == 1
            % C 参数: 直接使用 BIC 结果（跳过末尾的"all"）
            stored_params{i_param, i_nation} = a_val_all{i_nation};
        else
            % 其他参数: 最小二乘拟合
            if length(L_valid) >= 3
                X = [log(L_valid), ones(size(L_valid))];
                a_fit = X \ param_valid;  % 线性最小二乘
                stored_params{i_param, i_nation} = a_fit(:)';  % [a1, a2]
            else
                stored_params{i_param, i_nation} = [NaN, NaN];
            end
        end
    end
end

%% ========== 输出文件夹 ==========
save_folder = fullfile('ellip_pic_p', 'efit_p', 'd65', 'BIC_L_depend_params');
if ~exist(save_folder, 'dir')
    mkdir(save_folder);
end

%% ========== 画6张子图并保存为 .fig ==========
for i_param = 1:6
    hFig = figure('Visible', 'off');
    set(hFig, 'Color', 'white');
    hold on;

    for i_nation = 1:4
        color = colors(i_nation, :);

        % --- 散点 ---
        L_scat = scatter_L{i_param, i_nation};
        p_scat = scatter_param{i_param, i_nation};
        plot(p_scat, L_scat, '.', 'Color', color, 'MarkerSize', 8);

        % --- 拟合曲线 ---
        a_fit = stored_params{i_param, i_nation};
        if ~any(isnan(a_fit))
            L_fine = linspace(max(1, min(L_scat)), max(L_scat), 200)';
            p_fit = a_fit(1) * log(L_fine) + a_fit(2);
            plot(p_fit, L_fine, '-', 'Color', color, 'LineWidth', 1.5);
        end
    end

    % --- 坐标轴设置 ---
    ax = gca;
    set(ax, 'FontSize', targetFontSize);
    xlim(xlims{i_param});
    ylim(ylims);
    box on; 
    grid off;

    % xticks / yticks
    if ~isnan(tick_intervals(i_param))
        xTickVal = round(xlims{i_param}(1)) : tick_intervals(i_param) : round(xlims{i_param}(2));
        xTickVal = xTickVal(xTickVal >= xlims{i_param}(1) & xTickVal <= xlims{i_param}(2));
        ax.XTick = xTickVal;

        yTickVal = round(ylims(1)) : tick_intervals(i_param) : round(ylims(2));
        yTickVal = yTickVal(yTickVal >= ylims(1) & yTickVal <= ylims(2));
        ax.YTick = yTickVal;
    end

    % 宽高比: equal_tick子图用axis equal, 否则用pbaspect 20:70
    if ~isnan(tick_intervals(i_param))
        axis equal;
    else
        pbaspect([20, 70, 1]);
    end

    % --- xlabel / ylabel ---
    if strcmp(interpreter_type, "tex")
        xlabel(xlabels(i_param), 'Interpreter', 'tex', ...
            'FontName', 'Arial', 'FontSize', 2*targetFontSize);
        ylabel(ylabels(i_param), 'Interpreter', 'tex', ...
            'FontName', 'Arial', 'FontSize', 2*targetFontSize);
    end

    % --- xlabel靠近坐标轴0.5*fontSize, ylabel远离0.8*fontSize ---
    drawnow;
    xPos = ax.XLabel.Position;
    % xPos(2) < 0 (在x轴下方), +0.5*FS = 向上靠近坐标轴
    ax.XLabel.Position = [xPos(1), xPos(2) + 0.5*targetFontSize, xPos(3)];
    yPos = ax.YLabel.Position;
    % yPos(1) < 0 (在y轴左侧), -0.8*FS = 更左远离坐标轴
    ax.YLabel.Position = [yPos(1) - 0.8*targetFontSize, yPos(2), yPos(3)];

    % 保存 .fig
    fig_name = strcat(file_prefixes(i_param), '.fig');
    savefig(hFig, fullfile(save_folder, fig_name));
    close(hFig);
end

fprintf('6张 .fig 已保存到: %s\n', fullfile(pwd, save_folder));

%% ========== concatenate_figs_legend1 ==========
% 直接收集原始 .fig 文件（已在绘图时设置好所有属性）
dir_figs = dir(fullfile(save_folder, "*.fig"));
figFiles = cell(1, length(dir_figs));
for i_fig = 1:length(dir_figs)
    figFiles{i_fig} = dir_figs(i_fig).name;
end

s = struct();
s.labels_row1 = {'亚洲人', '高加索人', '南亚人', '非洲人'};
s.labels_row2 = {};
s.markers_row2 = {};
s.markers_colors = [];
s.markers_face_colors = [];
s.colors_row1 = colors;
s.n_col1 = 4;  % legend 中第一行 4 项
s.n_col2 = 0;
s.if_label = false;  % 不需要 (a)(b) 子母标签

s.fontSizeScale = 1.0;
s.tickFontSize = targetFontSize;
s.interpreter_type = interpreter_type;
s.marginL = 0.12;
s.leg_x_shift = -0.02;
s.colGap1_scale = 1.2;
s.iconTextGap = 0.015;
s.rowStep = 0.17;

% 增大 figHeight 以避免 legend 与 sub figures 重叠
s.fig_wh_base = [700, 800];  

% label偏移已在单独fig中设置，此处不再重复
s.label_x_offset = 0;
s.label_y_offset = 0;

% 手工legend远离sub figures一个fontsize: 减小label_Y使legend内容下移
concatenate_figs_legend1(save_folder, figFiles, 6, "", "draw", s, 0.04, 0.70);

fprintf('\n========== 完成！==========\n');
fprintf('输出路径: %s\n', fullfile(pwd, save_folder));
fprintf('拼接结果: %s\n', fullfile(pwd, save_folder, 'concatenated'));
