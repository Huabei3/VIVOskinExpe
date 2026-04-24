close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量
addpath("utils\")
%%
% VIVO
VIVO_table_folder = "D:\work\VIVOskinExpe\analyze\AnalyseResults_p\efit_p\scaled\resTable";
VIVO_table_file   = fullfile(VIVO_table_folder, "Peggy_VIVO_table.mat");
VIVO_table_data   = load(VIVO_table_file);
VIVO_table        = VIVO_table_data.fit_table;

nations = ["Asian", "Caucasian", "South Asian", "African"];

attributes = ["Preference", "Attractiveness", "Feminine", "Cooperative", ...
"Youth", "Healthy", "Fidelity", "Harmony", "Fair", "Ruddy"];

nation_indices = cell(5, 1);
% AS (Asian): f04i, f05i, f06i, m04i, m05i, m06i (索引1-6)
nation_indices{1} = 1:6;
% CA (Caucasian): f01i, f02i, f03i, m01i, m02i, m03i (索引7-12)
nation_indices{2} = 7:12;
% SA (South Asian): f07i, f08i, m07i, m08i (索引13-16)
nation_indices{3} = 13:16;
% AF (African): f09i, f10i, m09i, m10i (索引17-20)
nation_indices{4} = 17:20;
% all: 所有索引 (索引1-20)
nation_indices{5} = 1:20;

% iOr='r' 的 scene_type 分组定义
scene_type_indices{1} = [1, 2, 4, 5, 6];   % indoor
scene_type_indices{2} = [3, 7, 8, 10, 12]; % outdoor
scene_type_indices{3} = [13, 14];           % night
scene_type_indices{4} = [9, 11];            % 另一分组
n_scene_type = length(scene_type_indices);

% iOr='i' 的 D65 scene 索引（hd65=5, md65=12, ld65=19）
scene_indices_d65_i = [5, 12, 19];

% iOr='i' 的 picnames_groups（21个场景）
picnames_groups_i = ["h3k","h4k","h5k","h6k","hd65","h7k","h8k",...
                    "m3k","m4k","m5k","m6k","md65","m7k","m8k",...
                     "l3k","l4k","l5k","l6k","ld65","l7k","l8k"];

% iOr='r' 的 picnames_groups（14个场景）
picnames_groups_r = ["rs01","rs02","rs03","rs04","rs05","rs06","rs07", ...
             "rs08","rs09","rs10","rs11","rs12","rs13","rs14"];

% 'i' 组的 lastParts（仅在 iOr='r' 时用到，但不影响计算）
lastParts = {'f04r', 'f05r', 'f06r', 'm04r', 'm05r', 'm06r',...
'f01r', 'f02r', 'f03r', 'm01r', 'm02r', 'm03r',...
'f07r', 'f08r','m07r', 'm08r',...
'f09r', 'f10r','m09r', 'm10r'};

wd65 = [94.811, 100.00, 107.304];
datai_file = 'D:\work\VIVOskinExpe\renderCode\calibResults\datai_ipv18_3.mat';
LUT = load(datai_file);
XYZw_LUT = LUT.XYZw;
labCh_PMCC=[[62.11	18.96	19.76	27.39	46.18];...
            [64.15	19.56	19.63	27.71	45.10];...
            [56.01	18.25	18.72	26.14	45.72];...
            [41.06	17.37	17.94	24.97	45.93]];

obs_type_used = "non_model";
scale_type    = "scaled";
Dtype         = 'efit_p';

% 绘图开关: "scene_types", "scenes", "none"
draw_pic_type = "scene_types";

save_folder = fullfile('AnalyseResults_p', Dtype, scale_type, ...
    "contour_scene_type", obs_type_used);
if ~exist(save_folder, "dir")
    mkdir(save_folder);
end

%% =========================================================
%  外层循环：依次处理 iOr='i'（i_iOr=1）和 iOr='r'（i_iOr=2）
%  参考 scatter_scene2_CT 的 iOr_flag 写法
%% =========================================================
for i_iOr = 1:2

    if i_iOr == 1
        iOr = 'i';
        picnames_groups = picnames_groups_i;
    else
        iOr = 'r';
        picnames_groups = picnames_groups_r;
    end

    fprintf('\n========== Processing iOr = ''%s'' ==========\n', iOr);

    % ---- 逐人种计算 ----
    for i_nation = 1:length(nations)

        nation = nations(i_nation);
        nation_serial = sprintf("%02d%s", i_nation, nation);

        all_scenes          = string(VIVO_table.scene);
        all_ethnicities     = string(VIVO_table.model_ethnicity);
        all_attributes      = string(VIVO_table.attribute);
        all_observer_types  = string(VIVO_table.observer_type);

        for i_attr = 1:1

            attribute = attributes(i_attr);

            % ---- 第一步：逐 scene 计算 mean_cen ----
            mean_cen_all = nan(length(picnames_groups), 3);

            for i_scene = 1:length(picnames_groups)
                [lab_g, p_g] = get_scene_data(picnames_groups(i_scene), ...
                    all_scenes, all_ethnicities, nation, ...
                    all_attributes, attribute, ...
                    all_observer_types, VIVO_table, scale_type, wd65, XYZw_LUT);
                if ~isempty(lab_g)
                    mean_cen_all(i_scene, :) = calc_mean_cen(lab_g, p_g);
                end
            end % end i_scene

            % ---- 第二步：计算 scene_type 中心 ----
            if i_iOr == 2   % iOr = 'r'
                % 按 scene_type_indices 分组拼接
                mean_cen_scene_type_all = nan(n_scene_type, 3);

                for i_scene_type = 1:n_scene_type
                    lab_group_type = [];
                    p_group_type   = [];

                    for i_scene = scene_type_indices{i_scene_type}
                        if i_scene > length(picnames_groups)
                            continue;
                        end
                        [lab_this, p_this] = get_scene_data(picnames_groups(i_scene), ...
                            all_scenes, all_ethnicities, nation, ...
                            all_attributes, attribute, ...
                            all_observer_types, VIVO_table, scale_type, wd65, XYZw_LUT);
                        lab_group_type = [lab_group_type; lab_this]; %#ok<AGROW>
                        p_group_type   = [p_group_type;   p_this];   %#ok<AGROW>
                    end
                    mean_cen_scene_type_all(i_scene_type, :) = calc_mean_cen(lab_group_type, p_group_type);
                end % end i_scene_type

                % 保存 _r 结果
                save_file = fullfile(save_folder, strcat(nation_serial, "_contour_scene_type.mat"));
                save(save_file, "mean_cen_all", "mean_cen_scene_type_all", "scene_type_indices");
                fprintf('  [%s] Saved (r): %s\n', nation, save_file);

            else              % i_iOr == 1, iOr = 'i'
                % 拼接 i_scene=[5,12,19]（hd65/md65/ld65）数据
                lab_group_d65 = [];
                p_group_d65   = [];

                for i_scene = scene_indices_d65_i
                    if i_scene > length(picnames_groups)
                        continue;
                    end
                    [lab_this, p_this] = get_scene_data(picnames_groups(i_scene), ...
                        all_scenes, all_ethnicities, nation, ...
                        all_attributes, attribute, ...
                        all_observer_types, VIVO_table, scale_type, wd65, XYZw_LUT);
                    lab_group_d65 = [lab_group_d65; lab_this]; %#ok<AGROW>
                    p_group_d65   = [p_group_d65;   p_this];   %#ok<AGROW>
                end
                mean_cen_scene_type_i = calc_mean_cen(lab_group_d65, p_group_d65);

                % 保存 _i 结果
                save_file = fullfile(save_folder, strcat(nation_serial, "_contour_scene_type_i.mat"));
                save(save_file, "mean_cen_all", "mean_cen_scene_type_i", "scene_indices_d65_i");
                fprintf('  [%s] Saved (i): %s\n', nation, save_file);

            end % end i_iOr branch

        end % end i_attr
    end % end i_nation
end % end i_iOr

%% =========================================================
%  第三步：计算 rela_incre
%  对每个 nation，加载 _r 和 _i 两份 .mat，
%  计算 mean_cen_scene_type_all（r，n_scene_type×3）相对
%  mean_cen_scene_type_i（i，1×3）在每个维度的增长百分比。
%
%  rela_incre(scene_type, dim) =
%      (cen_r(scene_type, dim) - cen_i(dim)) / abs(cen_i(dim)) * 100   [单位：%]
%
%  保存到 _contour_scene_type_rela.mat
%% =========================================================
%% =========================================================
%  颜色定义（参考 scatter_scene2_CT.m）
%% =========================================================
% scene_colors 用于 scene_types 模式
n_scenetype = 3;
hue_values = linspace(0, 1, n_scenetype + 1);
hue_values = hue_values(1:end-1);
hsv_matrix = [hue_values', 0.8*ones(n_scenetype, 1), 0.8*ones(n_scenetype, 1)];
scene_colors = hsv2rgb(hsv_matrix);
scene_colors([2,3],:) = scene_colors([3,2],:);  % 交换第2和第3行

% 每一行的3个点用同一颜色，区分scene_type
% scene_colors(1,:) = indoor, scene_colors(2,:) = outdoor, scene_colors(3,:) = night

% scene_colors_scenes 用于 scenes 模式（14个scene各一个颜色）
n_scene_r = 14;
scene_step = 1 / (n_scene_r + 1);
scene_hue_values = linspace(0, 1 - scene_step, n_scene_r);
scene_hsv_scenes = [scene_hue_values', 0.8*ones(n_scene_r, 1), 0.8*ones(n_scene_r, 1)];
scene_colors_scenes = hsv2rgb(scene_hsv_scenes);

%% =========================================================
%  第三步：计算 rela_incre
%  1) 对 cen_r 等比放缩，使其第一个维度(L*)与 cen_i 相等
%  2) 对 scene_type 和 scenes 分别计算 rela_incre
%% =========================================================
fprintf('\n========== Computing rela_incre ==========\n');
for i_nation = 1:length(nations)

    nation = nations(i_nation);
    nation_serial = sprintf("%02d%s", i_nation, nation);

    file_r = fullfile(save_folder, strcat(nation_serial, "_contour_scene_type.mat"));
    file_i = fullfile(save_folder, strcat(nation_serial, "_contour_scene_type_i.mat"));

    if ~exist(file_r, 'file') || ~exist(file_i, 'file')
        fprintf('  [Warning] %s: missing file, skipping.\n', nation_serial);
        continue;
    end

    data_r = load(file_r, 'mean_cen_scene_type_all', 'mean_cen_all');
    data_i = load(file_i, 'mean_cen_scene_type_i');

    cen_r        = data_r.mean_cen_scene_type_all;  % n_scene_type × 3
    mean_cen_all = data_r.mean_cen_all;             % n_scenes × 3 (14 scenes)
    cen_i        = data_i.mean_cen_scene_type_i;    % 1 × 3

    % ---- 1) 等比放缩 cen_r ----
    % scale_factor = cen_i(1) / cen_r(1)，使 L* 对齐
    scale_factor = cen_i(1) / cen_r(1);
    cen_r_scaled = cen_r * scale_factor;

    % ---- 2) 等比放缩 mean_cen_all (每个scene) ----
    mean_cen_all_scaled = mean_cen_all * scale_factor;

    % ---- 3) 计算 scene_type 的 rela_incre ----
    rela_incre = (cen_r_scaled - cen_i) ./ abs(cen_i) * 100;  % n_scene_type × 3 (%)

    % ---- 4) 计算每个 scene 的 rela_incre ----
    % mean_cen_all_scaled: n_scenes × 3, cen_i: 1 × 3
    rela_incre_scenes = (mean_cen_all_scaled - cen_i) ./ abs(cen_i) * 100;  % n_scenes × 3 (%)

    save_file_rela = fullfile(save_folder, strcat(nation_serial, "_contour_scene_type_rela.mat"));
    save(save_file_rela, "rela_incre", "rela_incre_scenes", ...
        "cen_r", "cen_r_scaled", "cen_i", ...
        "mean_cen_all", "mean_cen_all_scaled", ...
        "scene_type_indices", "scene_indices_d65_i", "scale_factor");
    fprintf('  [%s] rela_incre saved → %s\n', nation, save_file_rela);

    %% =========================================================
    %  绘图部分（根据 draw_pic_type 开关）
    %  参考 scatter_scene2_CT.m 的颜色逻辑
    %% =========================================================
    if ~strcmp(draw_pic_type, "none")
        for i_attr = 1:1  % 当前只支持 i_attr = 1
            fig_h = figure('Units', 'normalized', 'OuterPosition', [0, 0, 1, 1]);
            hold on;
            set(gcf, 'Color', 'white');

            if strcmp(draw_pic_type, "scene_types")
                % ---- scene_types 模式：绘制 n_scene_type × 3 个点 ----
                % 每个 scene_type 有3个维度，依次绘制 L*, a*, b*
                dim_names = {'L*', 'a*', 'b*'};
                dim_colors = {[0.5, 0.5, 0.5], [0.8, 0.2, 0.2], [0.2, 0.2, 0.8]};  % 灰色、红、绿

                % 绘制 cen_i（3个维度）
                for i_dim = 1:3
                    cen_i_val = cen_i(i_dim);
                    % 用短横线连接3个维度作为 cen_i 的表示
                    if i_dim == 1
                        plot([0.5, 0.5], [0, cen_i_val], 'k-', 'LineWidth', 2);
                    elseif i_dim == 2
                        plot([1.5, 1.5], [0, cen_i_val], 'k-', 'LineWidth', 2);
                    else
                        plot([2.5, 2.5], [0, cen_i_val], 'k-', 'LineWidth', 2);
                    end
                end

                % 绘制 cen_r_scaled（每个 scene_type × 3个维度）
                x_offset = 0;
                for i_scene_type = 1:n_scene_type
                    scene_color = scene_colors(i_scene_type, :);
                    for i_dim = 1:3
                        x_pos = x_offset + i_dim;
                        y_val = cen_r_scaled(i_scene_type, i_dim);
                        plot(x_pos, y_val, 'o', 'MarkerSize', 10, ...
                            'MarkerFaceColor', scene_color, 'MarkerEdgeColor', 'k');

                        % 在点旁边标注 rela_incre（小字）
                        rela_val = rela_incre(i_scene_type, i_dim);
                        text_x = x_pos + 0.15;
                        text_y = y_val;
                        text_str = sprintf('%.1f%%', rela_val);
                        text(text_x, text_y, text_str, ...
                            'FontSize', 8, 'Color', scene_color, ...
                            'VerticalAlignment', 'middle');
                    end
                    x_offset = x_offset + 3.5;  % 每个 scene_type 之间留空
                end

                % 设置坐标轴
                xlim([0, x_offset + 1]);
                ylim([0, max([cen_i(:); cen_r_scaled(:)]) * 1.2]);

                % 添加维度标签
                for i_dim = 1:3
                    text(i_dim - 0.3, -2, dim_names{i_dim}, ...
                        'FontSize', 12, 'FontWeight', 'bold');
                end

                % 添加 scene_type 图例标签
                scene_type_names = {'Indoor', 'Outdoor', 'Night', 'Other'};
                legend_handles = [];
                legend_labels = {};
                for i_scene_type = 1:n_scene_type
                    h = plot(NaN, NaN, 'o', 'MarkerSize', 10, ...
                        'MarkerFaceColor', scene_colors(i_scene_type,:), ...
                        'MarkerEdgeColor', 'k');
                    legend_handles = [legend_handles, h];
                    if i_scene_type <= length(scene_type_names)
                        legend_labels{end+1} = scene_type_names{i_scene_type};
                    end
                end
                legend(legend_handles, legend_labels, 'Location', 'bestoutside');

                title_str = sprintf('%s - %s: cen_i vs cen_r_scaled (scene_types)', ...
                    nation, attributes(i_attr));
                title(title_str, 'FontSize', 14);

            elseif strcmp(draw_pic_type, "scenes")
                % ---- scenes 模式：绘制 n_scenes × 3 个点 ----
                dim_names = {'L*', 'a*', 'b*'};

                % 绘制 cen_i（3个维度）
                for i_dim = 1:3
                    cen_i_val = cen_i(i_dim);
                    if i_dim == 1
                        plot([0.5, 0.5], [0, cen_i_val], 'k-', 'LineWidth', 2);
                    elseif i_dim == 2
                        plot([1.5, 1.5], [0, cen_i_val], 'k-', 'LineWidth', 2);
                    else
                        plot([2.5, 2.5], [0, cen_i_val], 'k-', 'LineWidth', 2);
                    end
                end

                % 绘制 mean_cen_all_scaled（每个 scene × 3个维度）
                x_offset = 0;
                for i_scene = 1:size(mean_cen_all_scaled, 1)
                    scene_color = scene_colors_scenes(mod(i_scene-1, n_scene_r)+1, :);
                    for i_dim = 1:3
                        x_pos = x_offset + i_dim;
                        y_val = mean_cen_all_scaled(i_scene, i_dim);
                        plot(x_pos, y_val, 'o', 'MarkerSize', 8, ...
                            'MarkerFaceColor', scene_color, 'MarkerEdgeColor', 'k');

                        % 在点旁边标注 rela_incre（小字）
                        rela_val = rela_incre_scenes(i_scene, i_dim);
                        text_x = x_pos + 0.15;
                        text_y = y_val;
                        text_str = sprintf('%.1f%%', rela_val);
                        text(text_x, text_y, text_str, ...
                            'FontSize', 7, 'Color', scene_color, ...
                            'VerticalAlignment', 'middle');
                    end
                    x_offset = x_offset + 3.5;  % 每个 scene 之间留空
                end

                % 设置坐标轴
                xlim([0, x_offset + 1]);
                ylim([0, max([cen_i(:); mean_cen_all_scaled(:)]) * 1.2]);

                % 添加维度标签
                for i_dim = 1:3
                    text(i_dim - 0.3, -2, dim_names{i_dim}, ...
                        'FontSize', 12, 'FontWeight', 'bold');
                end

                title_str = sprintf('%s - %s: cen_i vs cen_r_scaled (scenes)', ...
                    nation, attributes(i_attr));
                title(title_str, 'FontSize', 14);
            end

            % 添加 cen_i 的标签
            text(0.3, cen_i(1), 'cen_i', 'FontSize', 10, 'Color', 'k');

            xlabel('Dimension', 'FontSize', 12);
            ylabel('Value', 'FontSize', 12);
            grid on;

            % 保存图片
            pic_save_folder = fullfile(save_folder, 'pics');
            if ~exist(pic_save_folder, 'dir')
                mkdir(pic_save_folder);
            end
            pic_name = fullfile(pic_save_folder, ...
                sprintf('%s_%s_%s.jpg', nation_serial, attributes(i_attr), draw_pic_type));
            exportgraphics(fig_h, pic_name, 'Resolution', 300);
            fprintf('  [%s] Picture saved → %s\n', nation, pic_name);
            close(fig_h);
        end % end i_attr
    end % end draw_pic_type check

end % end i_nation

fprintf('\nDone. Results in: %s\n', fullfile(pwd, save_folder));
