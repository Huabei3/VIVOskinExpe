% scatter_scene2_CT.m
% 将iOr='i'和iOr='r'的内容画到一张图上，point_color依据CT(i_point)而定

close all;
clc;
clear;
addpath("utils\")
%% 定义所有需要处理的 attribute
attributes = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

nations = ["AS", "CA", "SA", "AF"];
text_type="ch";
if strcmp(text_type,"eng")
    nation_names = ["Asian", "Caucasian", "South Asian", "African"];
    attribute_names = ["Preference", "Attractiveness", "Feminine", "Cooperative", ...
    "Youth", "Healthy", "Fidelity", "Harmony", "Fair", "Ruddy"];
elseif strcmp(text_type,"ch")
    nation_names = ["亚洲人", "高加索人", "南亚人", "非洲人"];
    attribute_names = ["喜好的", "有吸引力的", "女性化的", "友善的", ...
    "年轻的", "健康的", "真实还原的", "与环境适配的", "白皙的", "红润的"];
end
targetFontSize=12;
interpreter_type = "tex"; % "tex" 或 "latex"

%% 定义i和r两组lastParts
lastParts_i = {'f04i', 'f05i', 'f06i', 'm04i', 'm05i', 'm06i',...
'f01i', 'f02i', 'f03i', 'm01i', 'm02i', 'm03i',...
'f07i', 'f08i','m07i', 'm08i',...
'f09i', 'f10i','m09i', 'm10i'};
lastParts_r = {'f04r', 'f05r', 'f06r', 'm04r', 'm05r', 'm06r',...
'f01r', 'f02r', 'f03r', 'm01r', 'm02r', 'm03r',...
'f07r', 'f08r','m07r', 'm08r',...
'f09r', 'f10r','m09r', 'm10r'};

n_para_i = 21;
n_para_r = 14;

picnames_groups_i = ["h3k","h4k","h5k","h6k","hd65","h7k","h8k",...
                    "m3k","m4k","m5k","m6k","md65","m7k","m8k",...
                     "l3k","l4k","l5k","l6k","ld65","l7k","l8k"];
picnames_groups_r = ["rs01","rs02","rs03","rs04","rs05","rs06","rs07", ...
             "rs08","rs09","rs10","rs11","rs12","rs13","rs14"];

lightness_type="rela";
scale_type_origin="unscaled";
load("documents\valid_attr.mat","map");

wd65 = [94.811, 100.00, 107.304];
datafile = 'D:\work\VIVOskinExpe\renderCode\calibResults\datai_ipv18_3.mat';
LUT=load(datafile);
XYZw_LUT=LUT.XYZw;
line_style = {'-',':','-.'};
plot_style = {'v','^'};

genders = ["f", "m"];

obs_types = ["non_model", "model_group"];

% 人种对应的lastParts索引
nation_indices = cell(5, 1);
% AS (Asian): f04i/f04r, f05i/f05r, f06i/f06r, m04i/m04r, m05i/m05r, m06i/m06r (索引1-6)
nation_indices{1} = 1:6;
% CA (Caucasian): f01i/f01r, f02i/f02r, f03i/f03r, m01i/m01r, m02i/m02r, m03i/m03r (索引7-12)
nation_indices{2} = 7:12;
% SA (South Asian): f07i/f07r, f08i/f08r, m07i/m07r, m08i/m08r (索引13-16)
nation_indices{3} = 13:16;
% AF (African): f09i/f09r, f10i/f10r, m09i/m09r, m10i/m10r (索引17-20)
nation_indices{4} = 17:20;
% all: 所有索引 (索引1-20)
nation_indices{5} = 1:20;

%% 加载CT数据 - i和r两组
indices_target_i = 1:21;
load('optimizedD\neutral_gray\combi_XYZw_i.mat', 'XYZ_combi', 'CCT_combi');
CT_i = CCT_combi;  % CT for i condition

indices_target_r = 1:14;
for i_nation=1:length(nations)
    model_tcp_mean_inds=[];
    for i_lastPart=nation_indices{i_nation}
        load(fullfile("..\renderCode\light_r\model_tcp", ...
            strcat(lastParts_r{i_lastPart}(1:end-1),".mat")), ...
        "model_tcp_mean");
        model_tcp_mean_inds=[model_tcp_mean_inds,model_tcp_mean];
    end
    CT_nations{i_nation}=mean(model_tcp_mean_inds,2);
end
CT_r = CT_nations;  % CT for r condition

%% CT颜色映射设置
cmap_resolution = 256;
current_cmap = flipud(turbo(cmap_resolution));
lim_CCT = [2500, 8500];

% 将CT值映射到颜色索引的函数
function color_idx = CCT_to_coloridx(ct, lim_CCT, cmap_resolution)
    ct_clamped = max(lim_CCT(1), min(lim_CCT(2), ct));
    normalized = (ct_clamped - lim_CCT(1)) / (lim_CCT(2) - lim_CCT(1));
    color_idx = floor(normalized * (cmap_resolution - 1)) + 1;
    color_idx = max(1, min(cmap_resolution, color_idx));
end

%% 初始化数据结构
average_reshaped = cell(5, 1);
par_reshaped = cell(3, 5, 2);  % 3种观察者类型 × 5个人种 × 2种iOr(i=1, r=2)
lab_fit_reshaped = cell(3, 5, 2);
labCh_PMCC=[[62.11	18.96	19.76	27.39	46.18];...
            [64.15	19.56	19.63	27.71	45.10];...
            [56.01	18.25	18.72	26.14	45.72];...
            [41.06	17.37	17.94	24.97	45.93]];
labCh_PMCC(end+1,:)=mean(labCh_PMCC,1);
file_missing={};
Dtype = 'efit_p';

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

%% 加载i和r两组数据
% iOr = 1 (i condition)
lastParts = lastParts_i;
n_para = n_para_i;
iOr_flag = 1;
picnames_groups = picnames_groups_i;
indices_target = indices_target_i;

for i_obs = 1:length(obs_types)
    obs_type = obs_types(i_obs);
    
    for i_nation = 1:length(nations)
        nation=nations(i_nation);
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
            white_file = fullfile("optimizedD\whiteSquare\XYZw_white", ...
                strcat(lastPart, ".mat"));
            load(white_file,"XYZw_white");
            
            for i_attr = 1:length(attributes)
                attribute = attributes(i_attr);
                attribute_serial = strcat(sprintf("%02d", attribute), attribute_names(attribute));
                attribute_serial=ch2eng(attribute_serial);
                source_file = fullfile('AnalyseResults_p', Dtype,scale_type_origin, lastPart, obs_type, attribute_serial, 'ellipPara', 'fitRes.mat');
                
                if exist(source_file, 'file')
                    par_all_data = load(source_file);
                    par_all = par_all_data.par_all;
                    [target_rows, target_cols] = size(par_current, 1, 2);
                    par_padded = nan(target_rows, target_cols);
                    par_padded(1:size(par_all, 1), 1:size(par_all, 2)) = par_all;
                    par_current(:, :, i_subject, i_attr) = par_padded;

                    lab_bf=[average_current(:, 1, i_subject), par_padded(:,4:5)];
                    if strcmp(lightness_type,"rela")
                        xyz_fit=[];lab_scaled=[];
                        for i_para=1:size(par_all,1)
                            xyz_fit(i_para,:)=lab2xyz2(lab_bf(i_para,:),"user",wd65./wd65(2).*XYZw_LUT(2));
                            lab_scaled(i_para,:)=xyz2lab(xyz_fit(i_para,:),"user",wd65./wd65(2).*XYZw_white(i_para,2));
                        end

                        [max_rows, max_cols] = size(lab_fit_current, 1, 2);
                        lab_padded = nan(max_rows, max_cols);
                        rows_to_fill = min(size(lab_scaled, 1), max_rows);
                        cols_to_fill = min(size(lab_scaled, 2), max_cols);
                        lab_padded(1:rows_to_fill, 1:cols_to_fill) = lab_scaled(1:rows_to_fill, 1:cols_to_fill);
                        lab_fit_current(:, :, i_subject, i_attr) = lab_padded;
                    else
                        lab_fit_current(:, :, i_subject, i_attr) = lab_bf;
                    end
                else
                    par_current(:, :, i_subject, i_attr) = NaN(n_para, 6);
                    lab_fit_current(:, :, i_subject, i_attr) = NaN(n_para, 3);
                    file_missing{end+1,1}=lastPart;
                    file_missing{end,2}=obs_type;
                    file_missing{end,3}=attribute_serial;
                end
            end
        end
        
        par_reshaped{i_obs, i_nation, iOr_flag} = par_current;
        lab_fit_reshaped{i_obs, i_nation, iOr_flag} = lab_fit_current;
        
        if i_obs == 1
            average_reshaped{i_nation} = average_current;
        end
        
        average_mean{i_obs, i_nation}=nanmean(average_reshaped{i_nation} ,3);
        par_mean{i_obs,i_nation}=nanmean(par_reshaped{i_obs,i_nation,iOr_flag},3);
        average_nation_temp(i_nation,:)=mean(average_mean{i_obs, i_nation}(indices_target,:));
    end
    average_nations{i_obs}=average_nation_temp;
end

% iOr = 2 (r condition)
lastParts = lastParts_r;
n_para = n_para_r;
iOr_flag = 2;
picnames_groups = picnames_groups_r;
indices_target = indices_target_r;

for i_obs = 1:length(obs_types)
    obs_type = obs_types(i_obs);
    
    for i_nation = 1:length(nations)
        nation=nations(i_nation);
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
            white_file = fullfile("optimizedD\whiteSquare\XYZw_white", ...
                strcat(lastPart, ".mat"));
            load(white_file,"XYZw_white");
            
            for i_attr = 1:length(attributes)
                attribute = attributes(i_attr);
                attribute_serial = strcat(sprintf("%02d", attribute), attribute_names(attribute));
                attribute_serial=ch2eng(attribute_serial);
                source_file = fullfile('AnalyseResults_p', Dtype,scale_type_origin, lastPart, obs_type, attribute_serial, 'ellipPara', 'fitRes.mat');
                
                if exist(source_file, 'file')
                    par_all_data = load(source_file);
                    par_all = par_all_data.par_all;
                    [target_rows, target_cols] = size(par_current, 1, 2);
                    par_padded = nan(target_rows, target_cols);
                    par_padded(1:size(par_all, 1), 1:size(par_all, 2)) = par_all;
                    par_current(:, :, i_subject, i_attr) = par_padded;

                    lab_bf=[average_current(:, 1, i_subject), par_padded(:,4:5)];
                    if strcmp(lightness_type,"rela")
                        xyz_fit=[];lab_scaled=[];
                        for i_para=1:size(par_all,1)
                            xyz_fit(i_para,:)=lab2xyz2(lab_bf(i_para,:),"user",wd65./wd65(2).*XYZw_LUT(2));
                            lab_scaled(i_para,:)=xyz2lab(xyz_fit(i_para,:),"user",wd65./wd65(2).*XYZw_white(i_para,2));
                        end

                        [max_rows, max_cols] = size(lab_fit_current, 1, 2);
                        lab_padded = nan(max_rows, max_cols);
                        rows_to_fill = min(size(lab_scaled, 1), max_rows);
                        cols_to_fill = min(size(lab_scaled, 2), max_cols);
                        lab_padded(1:rows_to_fill, 1:cols_to_fill) = lab_scaled(1:rows_to_fill, 1:cols_to_fill);
                        lab_fit_current(:, :, i_subject, i_attr) = lab_padded;
                    else
                        lab_fit_current(:, :, i_subject, i_attr) = lab_bf;
                    end
                else
                    par_current(:, :, i_subject, i_attr) = NaN(n_para, 6);
                    lab_fit_current(:, :, i_subject, i_attr) = NaN(n_para, 3);
                    file_missing{end+1,1}=lastPart;
                    file_missing{end,2}=obs_type;
                    file_missing{end,3}=attribute_serial;
                end
            end
        end
        
        par_reshaped{i_obs, i_nation, iOr_flag} = par_current;
        lab_fit_reshaped{i_obs, i_nation, iOr_flag} = lab_fit_current;
        
        if i_obs == 1
            average_reshaped_r{i_nation} = average_current;
        end
        
        average_mean_r{i_obs, i_nation}=nanmean(average_reshaped_r{i_nation} ,3);
        par_mean_r{i_obs,i_nation}=nanmean(par_reshaped{i_obs,i_nation,iOr_flag},3);
        average_nation_temp_r(i_nation,:)=mean(average_mean_r{i_obs, i_nation}(indices_target,:));
    end
    average_nations_r{i_obs}=average_nation_temp_r;
end

%% 计算全局坐标轴范围
lim_min_x = inf;
lim_min_y = inf;
lim_max_x = -inf;
lim_max_y = -inf;

% i condition
for i_nation = 1:length(nations)
    for i_obs = 1:length(obs_types)
        obs_type=obs_types(i_obs);
        n_subjects = size(lab_fit_reshaped{i_obs, i_nation, 1}, 3);
        if n_subjects == 0
            continue;
        end
        curr_nation_indices = nation_indices{i_nation};

        for attribute = attributes
            lab = lab_fit_reshaped{i_obs,i_nation, 1}(indices_target_i, :, :, attribute);
            lab_mean = nanmean(lab, 3);
            if ~all(isnan(lab_mean(:)))
                lim_min_x = min(lim_min_x, min(lab_mean(:,2)));
                lim_max_x = max(lim_max_x, max(lab_mean(:,2)));
                lim_min_y = min(lim_min_y, min(lab_mean(:,3)));
                lim_max_y = max(lim_max_y, max(lab_mean(:,3)));
            end
        end

        lim_min_x = min(lim_min_x, labCh_PMCC(i_nation, 2));
        lim_max_x = max(lim_max_x, labCh_PMCC(i_nation, 2));
        lim_min_y = min(lim_min_y, labCh_PMCC(i_nation, 3));
        lim_max_y = max(lim_max_y, labCh_PMCC(i_nation, 3));
    end
end

% r condition
for i_nation = 1:length(nations)
    for i_obs = 1:length(obs_types)
        obs_type=obs_types(i_obs);
        n_subjects = size(lab_fit_reshaped{i_obs, i_nation, 2}, 3);
        if n_subjects == 0
            continue;
        end
        curr_nation_indices = nation_indices{i_nation};

        for attribute = attributes
            lab = lab_fit_reshaped{i_obs,i_nation, 2}(indices_target_r, :, :, attribute);
            lab_mean = nanmean(lab, 3);
            if ~all(isnan(lab_mean(:)))
                lim_min_x = min(lim_min_x, min(lab_mean(:,2)));
                lim_max_x = max(lim_max_x, max(lab_mean(:,2)));
                lim_min_y = min(lim_min_y, min(lab_mean(:,3)));
                lim_max_y = max(lim_max_y, max(lab_mean(:,3)));
            end
        end

        lim_min_x = min(lim_min_x, labCh_PMCC(i_nation, 2));
        lim_max_x = max(lim_max_x, labCh_PMCC(i_nation, 2));
        lim_min_y = min(lim_min_y, labCh_PMCC(i_nation, 3));
        lim_max_y = max(lim_max_y, labCh_PMCC(i_nation, 3));
    end
end

lim_min_x = lim_min_x - 1;
lim_max_x = lim_max_x + 1;
lim_min_y = lim_min_y - 1;
lim_max_y = lim_max_y + 1;

range_x = lim_max_x - lim_min_x;
range_y = lim_max_y - lim_min_y;
max_range = max(range_x, range_y);

lim_min_x = (lim_min_x + lim_max_x - max_range) / 2;
lim_max_x = (lim_min_x + lim_max_x + max_range) / 2;
lim_min_y = (lim_min_y + lim_max_y - max_range) / 2;
lim_max_y = (lim_min_y + lim_max_y + max_range) / 2;

%% 颜色模式开关: "scene", "CT" 或 "CT_scene"
color_mode = "CT_scene";  % 可选: "scene" (按场景着色), "CT" (按CT值着色), "CT_scene" (i按CT, r按scene)

%% 画线开关: "none" 或 "line"
draw_line = "none";  % "line" 时画连接线

%% 绘图部分
nan_record={};
res_matrix=[];curr=1;

% 创建scene模式的颜色映射 (与scatter_scene2一致)
n_scenetype = 3;
hue_values = linspace(0, 1, n_scenetype + 1);
hue_values = hue_values(1:end-1);
hsv_matrix = [hue_values', 0.8*ones(n_scenetype, 1), 0.8*ones(n_scenetype, 1)];
scene_colors = hsv2rgb(hsv_matrix);
scene_colors([2,3],:)=scene_colors([3,2],:);
plot_45_only = true;
obs_types_plot=["non_model"];

for i_obs=1:length(obs_types_plot)
    obs_type=obs_types_plot(i_obs);
    for i_nation = 1:length(nations)
        nation=nations(i_nation);
        nation_serial=strcat(sprintf("%02d",i_nation),nation);
        
        figure(i_nation);
        hold on;
        set(gcf, 'Color', 'white');
        
        % ========== 绘制 i condition ==========
        CT_current = CT_i;  % 使用i的CT
        
        % 预先计算所有i数据的颜色
        lab_data_i = lab_fit_reshaped{i_obs,i_nation, 1}(indices_target_i, :, :, 1);
        lab_i = nanmean(lab_data_i, 3);
        valid_idx_i = ~all(isnan(lab_i), 2);
        lab_valid_i = lab_i(valid_idx_i, :);
        
        % 根据color_mode计算每个点的颜色
        point_color_all_i = zeros(size(lab_valid_i, 1), 3);
        for i_point = 1:size(lab_valid_i, 1)
            if strcmp(color_mode, "CT") || strcmp(color_mode, "CT_scene")
                % CT模式或CT_scene模式：按CT值着色
                if i_point <= length(CT_current)
                    ct_val = CT_current(i_point);
                    color_idx = CCT_to_coloridx(ct_val, lim_CCT, cmap_resolution);
                    point_color_all_i(i_point, :) = current_cmap(color_idx, :);
                else
                    point_color_all_i(i_point, :) = [0.5, 0.5, 0.5];
                end
            else
                % scene模式：按场景类型着色，i condition全为黑色
                point_color_all_i(i_point, :) = [0, 0, 0];  % 黑色
            end
        end
        
        for attribute = [1]
            attribute_serial = strcat(sprintf("%02d", attribute), attribute_names(attribute));
            attribute_serial=ch2eng(attribute_serial);
            
            lab_data = lab_fit_reshaped{i_obs,i_nation, 1}(indices_target_i, :, :, attribute);
            lab = nanmean(lab_data, 3);
            
            for i_row=indices_target_i
            res_matrix=[res_matrix;lab(i_row,:)];
            res_cell{curr,1}=lab(i_row,:);
            res_cell{curr,2}=strcat('i',nation_serial, picnames_groups_i(i_row));
            curr=curr+1;
            end
            
            data_for_color = lab(:, 1);
            valid_idx = ~all(isnan(lab), 2);
            lab_valid = lab(valid_idx, :);
            data_valid = data_for_color(valid_idx);
            
            if ~isempty(lab_valid)
                % 获取对应的颜色
                if length(point_color_all_i) >= size(lab_valid, 1)
                    point_colors = point_color_all_i(1:size(lab_valid, 1), :);
                else
                    point_colors = repmat([0.5, 0.5, 0.5], size(lab_valid, 1), 1);
                end
                
                if strcmp(color_mode, "CT") || strcmp(color_mode, "CT_scene")
                    % CT模式或CT_scene模式：用scatter画圆点
                    scatter(lab_valid(:, 2), lab_valid(:, 3), 27, point_colors, 'o', 'filled', ...
                        'MarkerFaceAlpha', 0.8, 'MarkerEdgeColor', 'k', 'LineWidth', 0.5);
                else
                    % scene模式：用text表示（黑色）
                    for i_point = 1:size(lab_valid, 1)
                        text(lab_valid(i_point, 2), lab_valid(i_point, 3), ...
                        num2str(i_point), 'FontSize', 5, ...
                        'VerticalAlignment', 'middle','Color',[0, 0, 0], ...
                        'FontWeight', 'bold');
                    end
                end
            end
        end
        
        % ========== 绘制 r condition ==========
        CT_current_r = CT_r{i_nation};  % 使用r的CT (按人种)
        
        % 预先计算所有r数据的颜色
        lab_data_r = lab_fit_reshaped{i_obs,i_nation, 2}(indices_target_r, :, :, 1);
        lab_r = nanmean(lab_data_r, 3);
        valid_idx_r = ~all(isnan(lab_r), 2);
        lab_valid_r = lab_r(valid_idx_r, :);
        
        point_color_all_r = zeros(size(lab_valid_r, 1), 3);
        for i_point = 1:size(lab_valid_r, 1)
            if strcmp(color_mode, "CT")
                % CT模式：按CT值着色
                if i_point <= length(CT_current_r)
                    ct_val = CT_current_r(i_point);
                    color_idx = CCT_to_coloridx(ct_val, lim_CCT, cmap_resolution);
                    point_color_all_r(i_point, :) = current_cmap(color_idx, :);
                else
                    point_color_all_r(i_point, :) = [0.5, 0.5, 0.5];
                end
            elseif strcmp(color_mode, "CT_scene")
                % CT_scene模式：r按scene模式着色
                if ismember(i_point, [1, 2, 4, 5, 6])
                    point_color_all_r(i_point, :) = scene_colors(1, :);
                elseif ismember(i_point, [3, 7, 8, 9, 10, 11, 12])
                    point_color_all_r(i_point, :) = scene_colors(2, :);
                elseif ismember(i_point, [13, 14])
                    point_color_all_r(i_point, :) = scene_colors(3, :);
                else
                    point_color_all_r(i_point, :) = [0, 0, 0];
                end
            else
                % scene模式：按场景类型着色
                if ismember(i_point, [1, 2, 4, 5, 6])
                    point_color_all_r(i_point, :) = scene_colors(1, :);
                elseif ismember(i_point, [3, 7, 8, 9, 10, 11, 12])
                    point_color_all_r(i_point, :) = scene_colors(2, :);
                elseif ismember(i_point, [13, 14])
                    point_color_all_r(i_point, :) = scene_colors(3, :);
                else
                    point_color_all_r(i_point, :) = [0, 0, 0];
                end
            end
        end
        
        for attribute = [1]
            attribute_serial = strcat(sprintf("%02d", attribute), attribute_names(attribute));
            attribute_serial=ch2eng(attribute_serial);
            
            lab_data = lab_fit_reshaped{i_obs,i_nation, 2}(indices_target_r, :, :, attribute);
            lab = nanmean(lab_data, 3);
            
            for i_row=indices_target_r
            res_matrix=[res_matrix;lab(i_row,:)];
            res_cell{curr,1}=lab(i_row,:);
            res_cell{curr,2}=strcat('r',nation_serial, picnames_groups_r(i_row));
            curr=curr+1;
            end
            
            data_for_color = lab(:, 1);
            valid_idx = ~all(isnan(lab), 2);
            lab_valid = lab(valid_idx, :);
            data_valid = data_for_color(valid_idx);
            
            if ~isempty(lab_valid)
                % 获取对应的颜色
                if length(point_color_all_r) >= size(lab_valid, 1)
                    point_colors_r = point_color_all_r(1:size(lab_valid, 1), :);
                else
                    point_colors_r = repmat([0.5, 0.5, 0.5], size(lab_valid, 1), 1);
                end
                
                % r condition统一用text表示
                for i_point = 1:size(lab_valid, 1)
                    text(lab_valid(i_point, 2), lab_valid(i_point, 3), ...
                    num2str(i_point), 'FontSize', 8, ...
                    'VerticalAlignment', 'middle','Color',point_colors_r(i_point, :), ...
                    'FontWeight', 'bold');
                end
                disp("d")
            end
        end
        
        if strcmp(interpreter_type, "tex")
            xlabel('a^{*}','Interpreter','tex','FontName','Arial','FontAngle','italic','FontSize',targetFontSize);
            ylabel('b^{*}','Interpreter','tex','FontName','Arial','FontAngle','italic','FontSize',targetFontSize);
        elseif strcmp(interpreter_type, "latex")
            xlabel('a^{*}','Interpreter','latex','FontSize',targetFontSize);
            ylabel('b^{*}','Interpreter','latex','FontSize',targetFontSize);
        end
        title([nation_names(i_nation)],'FontSize', targetFontSize);
        axis equal;
        
        % 根据人种设置不同的坐标轴范围
        if i_nation == 4  % AF (非洲人)
            xlim([0, 20]);
            ylim([0, 20]);
        else
            xlim([0, 35]);
            ylim([0, 35]);
        end
        
        if plot_45_only
            thetas_to_plot = 45;
        else
            thetas_to_plot = 20:5:70;
        end
        
        for theta = thetas_to_plot
            m = tand(theta);
            x_line = linspace(0, lim_max_x, 100);
            y_line = m * x_line;
            valid_line_idx = (y_line >= 0) & (y_line <= lim_max_y);
            plot(x_line(valid_line_idx), y_line(valid_line_idx), 'Color', 'k', 'LineStyle', '--');
        end
        
        % 画连接线
        if strcmp(draw_line, "line")
            % 线1: (2,2) -> (2,3) -> (6,2) -> (6,3)
            plot([lab_valid(2, 2), lab_valid(6, 2)], [lab_valid(2, 3), lab_valid(6, 3)], ...
                'k-', 'LineWidth', 1);
            % 线2: (9,2) -> (9,3) -> (10,2) -> (10,3)
            plot([lab_valid(9, 2), lab_valid(10, 2)], [lab_valid(9, 3), lab_valid(10, 3)], ...
                'k-', 'LineWidth', 1);
        end
        
        ax = gca;
        set(ax, 'FontSize', targetFontSize);
        xlabel('a^*', 'Interpreter', 'tex', 'FontSize', targetFontSize, ...
            'FontName','Arial','FontAngle','italic');
        ylabel('b^*', 'Interpreter', 'tex', 'FontSize', targetFontSize, ...
            'FontName','Arial','FontAngle','italic');
        yPos = ax.YLabel.Position;
        yPos(1) = yPos(1) - 5;
        ax.YLabel.Position = yPos;
        xPos = ax.XLabel.Position;
        xPos(2) = xPos(2) - 5;
        ax.XLabel.Position = xPos;
        % set(findobj(gcf, 'Type', 'Text'), 'FontSize', targetFontSize);
        
        % 保存图片
        save_folder = fullfile("ellip_pic_p", Dtype, "scene2_CT", lightness_type, obs_type, text_type);
        if ~exist(save_folder, "dir")
            mkdir(save_folder, 'recursive');
        end
        
        img_name=fullfile(save_folder, strcat(nation_serial, '_L.jpg'));
        savefig(gcf, strrep(img_name,'jpg','fig'));
        exportgraphics(gcf, img_name, 'Resolution', 300);
    end
    
    % 合并所有图片
    %% adjust_fig
    opts.lim_min=0; 
    opts.lim_max=40;  
    opts.targetFontSize=12;
    opts.margin=0.1;    
    opts.label_type="scene";
    opts.if_rotate=false;
    opts.axis_limits=[[0,28,0,28];[0,28,0,28];[0,28,0,28];[0,18,0,18]];
    opts.axis_ticks=[5,5,5,5];
    adjust_fig(save_folder, opts);
    
    %% concatenate_figs_legend1
    if strcmp(color_mode, "scene")
        % scene模式：与scatter_scene2一致，绘制row2，不绘制colorbar
        if strcmp(text_type,"eng")
            s.labels_row1 = {"in-lab","indoor","outdoor","night"};
        elseif strcmp(text_type,"ch")
            s.labels_row1 = {"实验室","室内","室外","夜景"};
        end
        s.labels_row2 = {};
        s.markers_row2 = {};
        s.markers_colors = [];
        s.markers_face_colors = [];
        s.n_col1 = 5; 
        s.n_col2 = 5;
        s.if_label = true;
        s.leg_x_shift=-0.03;
        
        num_attributes = 3;
        hue_values = linspace(0, 1, num_attributes + 1);
        hue_values = hue_values(1:end-1);
        hsv_matrix = [hue_values', 0.8 * ones(num_attributes, 1), 0.8 * ones(num_attributes, 1)];
        s.colors_row1(2:4,:) = hsv2rgb(hsv_matrix);
        s.colors_row1(1,:)=[0 0 0];
        s.label_type = "scene";
        
    else
        % CT模式或CT_scene模式：绘制colorbar，控制位置使其横跨两行
        if strcmp(text_type,"eng")
            s.labels_row1 = {"indoor","outdoor","night"};
        elseif strcmp(text_type,"ch")
            s.labels_row1 = {"室内","室外","夜景"};
        end
        s.labels_row2 = {};
        s.markers_row2 = {};
        s.markers_colors = [];
        s.markers_face_colors = [];
        s.n_col1 = 5; 
        s.n_col2 = 5;
        s.if_label = true;  % CT/CT_scene模式不显示row1标签
        
        
        % CT模式或CT_scene模式：定义legend的位置参数，使colorbar横跨两行
        % legend_labels包含: {colorbar位置, colorbar高度比例, colorbar距右边距离}
        % 位置: 0-1之间，表示在所有subfig之后的相对位置
        s.legend_labels = {0.95, 0.9, 0.02};  % [相对位置, 高度比例, 右边距]
        s.colorbar_height_ratio = 0.9;  % colorbar高度占两行的比例
        s.colorbar_right_margin = 0.02;  % 距离最右边subfig的距离
        s.colorbar_position = 'right';  % colorbar在右侧
        s.colorbar_mode = 'cover_rows';  % colorbar覆盖所有行
        
        num_attributes = 3;
        hue_values = linspace(0, 1, num_attributes + 1);
        hue_values = hue_values(1:end-1);
        hsv_matrix = [hue_values', 0.8 * ones(num_attributes, 1), 0.8 * ones(num_attributes, 1)];
        s.colors_row1 = hsv2rgb(hsv_matrix);
        s.colors_row1([2,3],:)=s.colors_row1([3,2],:);
        s.color_limits = [2500, 8500];
        s.cmap = current_cmap;
        s.label_type = "scene";
        
        num_attributes = 0;
    end
    
    dir_figs = dir(fullfile(save_folder, "*adjusted.fig"));
    clear("figFiles")
    for i_fig = 1:length(dir_figs)
        figFiles{i_fig} = dir_figs(i_fig).name;
    end
    s.fontSizeScale=1.2;
    concatenate_figs_legend1(save_folder, figFiles, 2, "none", "draw", s, 0.09, 0.35);
    
    %% 合并图片
    concatenate_images1(save_folder, 4);
end

fullfile(pwd, save_folder)