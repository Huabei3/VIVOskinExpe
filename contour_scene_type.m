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
% draw_pic_type = "scene_types";
% draw_pic_type = "scenes";
draw_pic_type = "none";
save_folder = fullfile('D:\work\VIVOskinExpe\analyze\AnalyseResults_p', Dtype, scale_type, ...
    "contour_scene_type", obs_type_used);

%% =========================================================
%  主循环：逐 nation 和 attribute 计算，合并所有结果到一个 .mat
%% =========================================================
fprintf('\n========== Computing & Saving All Results ==========\n');

for i_nation = 1:length(nations)

    nation = nations(i_nation);
    nation_serial = sprintf("%02d%s", i_nation, nation);

    all_scenes          = string(VIVO_table.scene);
    all_ethnicities     = string(VIVO_table.model_ethnicity);
    all_attributes      = string(VIVO_table.attribute);
    all_observer_types  = string(VIVO_table.observer_type);

    for i_attr = 1:length(attributes)

        attribute = attributes(i_attr);
        attribute_serial = sprintf("%02d%s", i_attr,attribute);

        % ========== 第一步：iOr='r' 逐 scene 计算 mean_cen ==========
        picnames_groups_r = ["rs01","rs02","rs03","rs04","rs05","rs06","rs07", ...
                     "rs08","rs09","rs10","rs11","rs12","rs13","rs14"];

        mean_cen_all_r = nan(length(picnames_groups_r), 3);

        for i_scene = 1:length(picnames_groups_r)
            [lab_g, p_g] = get_scene_data(picnames_groups_r(i_scene), ...
                all_scenes, all_ethnicities, nation, ...
                all_attributes, attribute, ...
                all_observer_types, VIVO_table, scale_type, wd65, XYZw_LUT);
            if ~isempty(lab_g)
                mean_cen_all_r(i_scene, :) = calc_mean_cen(lab_g, p_g);
            end
        end

        % ========== 第二步：计算 scene_type 中心 (r) ==========
        mean_cen_scene_type_r = nan(n_scene_type, 3);

        for i_scene_type = 1:n_scene_type
            lab_group_type = [];
            p_group_type   = [];

            for i_scene = scene_type_indices{i_scene_type}
                if i_scene > length(picnames_groups_r)
                    continue;
                end
                [lab_this, p_this] = get_scene_data(picnames_groups_r(i_scene), ...
                    all_scenes, all_ethnicities, nation, ...
                    all_attributes, attribute, ...
                    all_observer_types, VIVO_table, scale_type, wd65, XYZw_LUT);
                lab_group_type = [lab_group_type; lab_this]; %#ok<AGROW>
                p_group_type   = [p_group_type;   p_this];   %#ok<AGROW>
            end
            mean_cen_scene_type_r(i_scene_type, :) = calc_mean_cen(lab_group_type, p_group_type);
        end

        % ========== 第三步：iOr='i' 计算 D65 scene 中心 ==========
        picnames_groups_i = ["h3k","h4k","h5k","h6k","hd65","h7k","h8k",...
                            "m3k","m4k","m5k","m6k","md65","m7k","m8k",...
                             "l3k","l4k","l5k","l6k","ld65","l7k","l8k"];

        lab_group_d65 = [];
        p_group_d65   = [];

        for i_scene = scene_indices_d65_i
            if i_scene > length(picnames_groups_i)
                continue;
            end
            [lab_this, p_this] = get_scene_data(picnames_groups_i(i_scene), ...
                all_scenes, all_ethnicities, nation, ...
                all_attributes, attribute, ...
                all_observer_types, VIVO_table, scale_type, wd65, XYZw_LUT);
            lab_group_d65 = [lab_group_d65; lab_this]; %#ok<AGROW>
            p_group_d65   = [p_group_d65;   p_this];   %#ok<AGROW>
        end
        mean_cen_scene_type_i = calc_mean_cen(lab_group_d65, p_group_d65);

        % ========== 第四步：计算 rela_incre ==========
        % cen_r 和 mean_cen_all_r 先转 XYZ，拉伸 Y 到与 cen_i 转成的 XYZ 一样，再转回 Lab
        cen_i = mean_cen_scene_type_i;  % 1 × 3
        cen_r = mean_cen_scene_type_r;  % n_scene_type × 3

        % 1) cen_i 转 XYZ
        XYZ_i = lab2xyz(cen_i, 'user', wd65./wd65(2).*XYZw_LUT(2));  % 1 × 3

        % 2) cen_r 转 XYZ，逐行处理
        XYZ_r = zeros(size(cen_r));
        for i_row = 1:size(cen_r, 1)
            XYZ_r(i_row, :) = lab2xyz(cen_r(i_row, :), 'user', wd65./wd65(2).*XYZw_LUT(2));
        end

        % 3) 拉伸 Y 到与 cen_i 的 Y 相等
        Y_target = XYZ_i(2);
        XYZ_r_scaled = XYZ_r;
        for i_row = 1:size(XYZ_r, 1)
            scale_factor_y = Y_target / XYZ_r(i_row, 2);
            XYZ_r_scaled(i_row, :) = XYZ_r(i_row, :) * scale_factor_y;
        end

        % 4) XYZ_r_scaled 转回 Lab
        cen_r_scaled = zeros(size(cen_r));
        for i_row = 1:size(XYZ_r_scaled, 1)
            cen_r_scaled(i_row, :) = xyz2lab(XYZ_r_scaled(i_row, :), 'user', wd65./wd65(2).*XYZw_LUT(2));
        end

        % 5) 同样处理 mean_cen_all_r (每个 scene)
        XYZ_scenes = zeros(size(mean_cen_all_r));
        for i_row = 1:size(mean_cen_all_r, 1)
            XYZ_scenes(i_row, :) = lab2xyz(mean_cen_all_r(i_row, :), 'user', wd65./wd65(2).*XYZw_LUT(2));
        end

        XYZ_scenes_scaled = XYZ_scenes;
        for i_row = 1:size(XYZ_scenes, 1)
            scale_factor_y = Y_target / XYZ_scenes(i_row, 2);
            XYZ_scenes_scaled(i_row, :) = XYZ_scenes(i_row, :) * scale_factor_y;
        end

        mean_cen_all_r_scaled = zeros(size(mean_cen_all_r));
        for i_row = 1:size(XYZ_scenes_scaled, 1)
            mean_cen_all_r_scaled(i_row, :) = xyz2lab(XYZ_scenes_scaled(i_row, :), 'user', wd65./wd65(2).*XYZw_LUT(2));
        end

        % 6) 计算 rela_incre
        rela_incre = (cen_r_scaled - cen_i) ./ abs(cen_i) * 100;  % n_scene_type × 3 (%)
        rela_incre_scenes = (mean_cen_all_r_scaled - cen_i) ./ abs(cen_i) * 100;  % n_scenes × 3 (%)
        if i_attr==7
            disp("d")
        end
        % ========== 保存到统一 .mat ==========
        save_folder_attr = fullfile(save_folder, attribute_serial);
        if ~exist(save_folder_attr, 'dir')
            mkdir(save_folder_attr);
        end

        save_file = fullfile(save_folder_attr, strcat(nation_serial, ".mat"));
        save(save_file, ...
            'mean_cen_all_r', 'mean_cen_scene_type_r', 'mean_cen_scene_type_i', ...
            'rela_incre', 'rela_incre_scenes', ...
            'cen_r', 'cen_r_scaled', 'cen_i', ...
            'mean_cen_all_r_scaled', ...
            'XYZ_r', 'XYZ_r_scaled', 'XYZ_i', ...
            'XYZ_scenes', 'XYZ_scenes_scaled', ...
            'scene_type_indices', 'scene_indices_d65_i', ...
            'picnames_groups_r', 'picnames_groups_i');
        fprintf('  [%s, %s] Saved → %s\n', nation, attribute, save_file);

    end % end i_attr
end % end i_nation

fprintf('\nDone. Results in: %s\n', save_folder);
