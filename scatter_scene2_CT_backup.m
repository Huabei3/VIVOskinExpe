% scatter_scene2_CT.m
% 灏唅Or='i'鍜宨Or='r'鐨勫唴瀹圭敾鍒颁竴寮犲浘涓婏紝point_color渚濇嵁CT(i_point)鑰屽畾

close all;
clc;
clear;
addpath("utils\")
%% 瀹氫箟鎵€鏈夐渶瑕佸鐞嗙殑 attribute
attributes = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

nations = ["AS", "CA", "SA", "AF"];
text_type="ch";
if strcmp(text_type,"eng")
    nation_names = ["Asian", "Caucasian", "South Asian", "African"];
    attribute_names = ["Preference", "Attractiveness", "Feminine", "Cooperative", ...
    "Youth", "Healthy", "Fidelity", "Harmony", "Fair", "Ruddy"];
elseif strcmp(text_type,"ch")
    nation_names = ["浜氭床浜?, "楂樺姞绱汉", "鍗椾簹浜?, "闈炴床浜?];
    attribute_names = ["鍠滃ソ鐨?, "鏈夊惛寮曞姏鐨?, "濂虫€у寲鐨?, "鍙嬪杽鐨?, ...
    "骞磋交鐨?, "鍋ュ悍鐨?, "鐪熷疄杩樺師鐨?, "涓庣幆澧冮€傞厤鐨?, "鐧界殭鐨?, "绾㈡鼎鐨?];
end % 
targetFontSize=12;
interpreter_type = "tex"; % "tex" 鎴?"latex"

%% 瀹氫箟i鍜宺涓ょ粍lastParts
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

% 浜虹瀵瑰簲鐨刲astParts绱㈠紩
nation_indices = cell(5, 1);
% AS (Asian): f04i/f04r, f05i/f05r, f06i/f06r, m04i/m04r, m05i/m05r, m06i/m06r (绱㈠紩1-6)
nation_indices{1} = 1:6;
% CA (Caucasian): f01i/f01r, f02i/f02r, f03i/f03r, m01i/m01r, m02i/m02r, m03i/m03r (绱㈠紩7-12)
nation_indices{2} = 7:12;
% SA (South Asian): f07i/f07r, f08i/f08r, m07i/m07r, m08i/m08r (绱㈠紩13-16)
nation_indices{3} = 13:16;
% AF (African): f09i/f09r, f10i/f10r, m09i/m09r, m10i/m10r (绱㈠紩17-20)
nation_indices{4} = 17:20;
% all: 鎵€鏈夌储寮?(绱㈠紩1-20)
nation_indices{5} = 1:20;

%% 鍔犺浇CT鏁版嵁 - i鍜宺涓ょ粍
indices_target_i = 1:21;
load('optimizedD\neutral_gray\combi_XYZw_i.mat', 'XYZ_combi', 'CCT_combi');
CT_i = CCT_combi;  % CT for i condition

indices_target_r = 1:14;
for i_nation=1:length(nations)
    model_tcp_mean_inds=[];
    for i_lastPart=nation_indices{i_nation}
        load(fullfile("..\renderCode\light_r\model_tcp", ...
            strcat(lastParts_r{i_lastPart}(1:end % -1),".mat")), ...
        "model_tcp_mean");
        model_tcp_mean_inds=[model_tcp_mean_inds,model_tcp_mean];
    end % 
    CT_nations{i_nation}=mean(model_tcp_mean_inds,2);
end % 
CT_r = CT_nations;  % CT for r condition

%% CT棰滆壊鏄犲皠璁剧疆
cmap_resolution = 256;
current_cmap = flipud(turbo(cmap_resolution));
lim_CCT = [2500, 8500];

% 灏咰T鍊兼槧灏勫埌棰滆壊绱㈠紩鐨勫嚱鏁?function color_idx = CCT_to_coloridx(ct, lim_CCT, cmap_resolution)
    ct_clamped = max(lim_CCT(1), min(lim_CCT(2), ct));
    normalized = (ct_clamped - lim_CCT(1)) / (lim_CCT(2) - lim_CCT(1));
    color_idx = floor(normalized * (cmap_resolution - 1)) + 1;
    color_idx = max(1, min(cmap_resolution, color_idx));
end

%% 鍒濆鍖栨暟鎹粨鏋?average_reshaped = cell(5, 1);
par_reshaped = cell(3, 5, 2);  % 3绉嶈瀵熻€呯被鍨?脳 5涓汉绉?脳 2绉峣Or(i=1, r=2)
lab_fit_reshaped = cell(3, 5, 2);
labCh_PMCC=[[62.11	18.96	19.76	27.39	46.18];...
            [64.15	19.56	19.63	27.71	45.10];...
            [56.01	18.25	18.72	26.14	45.72];...
            [41.06	17.37	17.94	24.97	45.93]];
labCh_PMCC(end % +1,:)=mean(labCh_PMCC,1);
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
        end % 
    end % 
end

%% 鍔犺浇i鍜宺涓ょ粍鏁版嵁
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
            end % 
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
                        end % 

                        [max_rows, max_cols] = size(lab_fit_current, 1, 2);
                        lab_padded = nan(max_rows, max_cols);
                        rows_to_fill = min(size(lab_scaled, 1), max_rows);
                        cols_to_fill = min(size(lab_scaled, 2), max_cols);
                        lab_padded(1:rows_to_fill, 1:cols_to_fill) = lab_scaled(1:rows_to_fill, 1:cols_to_fill);
                        lab_fit_current(:, :, i_subject, i_attr) = lab_padded;
                    else
                        lab_fit_current(:, :, i_subject, i_attr) = lab_bf;
                    end % 
                else
                    par_current(:, :, i_subject, i_attr) = NaN(n_para, 6);
                    lab_fit_current(:, :, i_subject, i_attr) = NaN(n_para, 3);
                    file_missing{end % +1,1}=lastPart;
                    file_missing{end % ,2}=obs_type;
                    file_missing{end % ,3}=attribute_serial;
                end % 
            end % 
        end % 
        
        par_reshaped{i_obs, i_nation, iOr_flag} = par_current;
        lab_fit_reshaped{i_obs, i_nation, iOr_flag} = lab_fit_current;
        
        if i_obs == 1
            average_reshaped{i_nation} = average_current;
        end % 
        
        average_mean{i_obs, i_nation}=nanmean(average_reshaped{i_nation} ,3);
        par_mean{i_obs,i_nation}=nanmean(par_reshaped{i_obs,i_nation,iOr_flag},3);
        average_nation_temp(i_nation,:)=mean(average_mean{i_obs, i_nation}(indices_target,:));
    end % 
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
            end % 
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
                        end % 

                        [max_rows, max_cols] = size(lab_fit_current, 1, 2);
                        lab_padded = nan(max_rows, max_cols);
                        rows_to_fill = min(size(lab_scaled, 1), max_rows);
                        cols_to_fill = min(size(lab_scaled, 2), max_cols);
                        lab_padded(1:rows_to_fill, 1:cols_to_fill) = lab_scaled(1:rows_to_fill, 1:cols_to_fill);
                        lab_fit_current(:, :, i_subject, i_attr) = lab_padded;
                    else
                        lab_fit_current(:, :, i_subject, i_attr) = lab_bf;
                    end % 
                else
                    par_current(:, :, i_subject, i_attr) = NaN(n_para, 6);
                    lab_fit_current(:, :, i_subject, i_attr) = NaN(n_para, 3);
                    file_missing{end % +1,1}=lastPart;
                    file_missing{end % ,2}=obs_type;
                    file_missing{end % ,3}=attribute_serial;
                end % 
            end % 
        end % 
        
        par_reshaped{i_obs, i_nation, iOr_flag} = par_current;
        lab_fit_reshaped{i_obs, i_nation, iOr_flag} = lab_fit_current;
        
        if i_obs == 1
            average_reshaped_r{i_nation} = average_current;
        end % 
        
        average_mean_r{i_obs, i_nation}=nanmean(average_reshaped_r{i_nation} ,3);
        par_mean_r{i_obs,i_nation}=nanmean(par_reshaped{i_obs,i_nation,iOr_flag},3);
        average_nation_temp_r(i_nation,:)=mean(average_mean_r{i_obs, i_nation}(indices_target,:));
    end % 
    average_nations_r{i_obs}=average_nation_temp_r;
end

%% 璁＄畻鍏ㄥ眬鍧愭爣杞磋寖鍥?lim_min_x = inf;
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
        end % 
        curr_nation_indices = nation_indices{i_nation};

        for attribute = attributes
            lab = lab_fit_reshaped{i_obs,i_nation, 1}(indices_target_i, :, :, attribute);
            lab_mean = nanmean(lab, 3);
            if ~all(isnan(lab_mean(:)))
                lim_min_x = min(lim_min_x, min(lab_mean(:,2)));
                lim_max_x = max(lim_max_x, max(lab_mean(:,2)));
                lim_min_y = min(lim_min_y, min(lab_mean(:,3)));
                lim_max_y = max(lim_max_y, max(lab_mean(:,3)));
            end % 
        end % 

        lim_min_x = min(lim_min_x, labCh_PMCC(i_nation, 2));
        lim_max_x = max(lim_max_x, labCh_PMCC(i_nation, 2));
        lim_min_y = min(lim_min_y, labCh_PMCC(i_nation, 3));
        lim_max_y = max(lim_max_y, labCh_PMCC(i_nation, 3));
    end % 
end

% r condition
for i_nation = 1:length(nations)
    for i_obs = 1:length(obs_types)
        obs_type=obs_types(i_obs);
        n_subjects = size(lab_fit_reshaped{i_obs, i_nation, 2}, 3);
        if n_subjects == 0
            continue;
        end % 
        curr_nation_indices = nation_indices{i_nation};

        for attribute = attributes
            lab = lab_fit_reshaped{i_obs,i_nation, 2}(indices_target_r, :, :, attribute);
            lab_mean = nanmean(lab, 3);
            if ~all(isnan(lab_mean(:)))
                lim_min_x = min(lim_min_x, min(lab_mean(:,2)));
                lim_max_x = max(lim_max_x, max(lab_mean(:,2)));
                lim_min_y = min(lim_min_y, min(lab_mean(:,3)));
                lim_max_y = max(lim_max_y, max(lab_mean(:,3)));
            end % 
        end % 

        lim_min_x = min(lim_min_x, labCh_PMCC(i_nation, 2));
        lim_max_x = max(lim_max_x, labCh_PMCC(i_nation, 2));
        lim_min_y = min(lim_min_y, labCh_PMCC(i_nation, 3));
        lim_max_y = max(lim_max_y, labCh_PMCC(i_nation, 3));
    end % 
end % 

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

%% 棰滆壊妯″紡寮€鍏? "scene", "CT" 鎴?"CT_scene"
color_mode = "CT_scene";  % 鍙€? "scene" (鎸夊満鏅潃鑹?, "CT" (鎸塁T鍊肩潃鑹?, "CT_scene" (i鎸塁T, r鎸塻cene)

%% 鐢荤嚎寮€鍏? "none" 鎴?"line"
draw_line = "none";  % "line" 鏃剁敾杩炴帴绾?
%% variable_type寮€鍏? "nation" 鎴?"attr"
% "nation": for i_nation=[1:length(nations)], for i_attr=[1] (鍘熸湁閫昏緫)
% "attr": for i_nation=[1], for i_attr=[1:length(attributes)]
variable_type = "attr";

%% if_draw_in_lab寮€鍏? 0 鎴?1
% 褰搃f_draw_in_lab==0鏃讹紝涓嶇粯鍒秈Or=='i'鎯呭喌涓嬬殑鐐?if_draw_in_lab = 0;

%% 缁樺浘閮ㄥ垎
nan_record={};
res_matrix=[];curr=1;

% 鍒涘缓scene妯″紡鐨勯鑹叉槧灏?(涓巗catter_scene2涓€鑷?
n_scenetype = 3;
hue_values = linspace(0, 1, n_scenetype + 1);
hue_values = hue_values(1:end % -1);
hsv_matrix = [hue_values', 0.8*ones(n_scenetype, 1), 0.8*ones(n_scenetype, 1)];
scene_colors = hsv2rgb(hsv_matrix);
scene_colors([2,3],:)=scene_colors([3,2],:);
plot_45_only = true;
obs_types_plot=["non_model"];

for i_obs=1:length(obs_types_plot)
    obs_type=obs_types_plot(i_obs);
    
    % 鏍规嵁variable_type鍐冲畾寰幆鏂瑰紡
    if strcmp(variable_type, "nation")
        nation_loop = 1:length(nations);
        attr_loop = 1;
    elseif strcmp(variable_type, "attr")
        nation_loop = 1;
        attr_loop = 1:length(attributes);
    end
    
    % variable_type="attr"鏃讹紝姣忎釜attribute鍗曠嫭澶勭悊
    if strcmp(variable_type, "attr")
        for i_attr_idx = attr_loop
            attribute = attributes(i_attr_idx);
            attribute_serial = strcat(sprintf("%02d", attribute), attribute_names(attribute));
            attribute_serial = ch2eng(attribute_serial);
            
            % 姣忎釜attribute鍒涘缓涓€寮犲浘
            figure(attribute);
            hold on;
            set(gcf, 'Color', 'white');
            
            % 鍙娇鐢?i_nation = 1 鐨勬暟鎹?            i_nation = 1;
            nation = nations(i_nation);
            nation_serial = strcat(sprintf("%02d", i_nation), nation);
            
            % ========== 缁樺埗 i condition ==========
            CT_current = CT_i;
            
            % 棰勫厛璁＄畻鎵€鏈塱鏁版嵁鐨勯鑹?(浣跨敤褰撳墠attribute)
            lab_data_i = lab_fit_reshaped{i_obs, i_nation, 1}(indices_target_i, :, :, attribute);
            lab_i = nanmean(lab_data_i, 3);
            valid_idx_i = ~all(isnan(lab_i), 2);
            lab_valid_i = lab_i(valid_idx_i, :);
            
            point_color_all_i = zeros(size(lab_valid_i, 1), 3);
            for i_point = 1:size(lab_valid_i, 1)
                if strcmp(color_mode, "CT") || strcmp(color_mode, "CT_scene")
                    if i_point <= length(CT_current)
                        ct_val = CT_current(i_point);
                        color_idx = CCT_to_coloridx(ct_val, lim_CCT, cmap_resolution);
                        point_color_all_i(i_point, :) = current_cmap(color_idx, :);
                    else
                        point_color_all_i(i_point, :) = [0.5, 0.5, 0.5];
                    end % 
                else
                    point_color_all_i(i_point, :) = [0, 0, 0];
                end % 
            end % 
            
            lab_data = lab_fit_reshaped{i_obs, i_nation, 1}(indices_target_i, :, :, attribute);
            lab = nanmean(lab_data, 3);
            
            for i_row = indices_target_i
                res_matrix = [res_matrix; lab(i_row, :)];
                res_cell{curr, 1} = lab(i_row, :);
                res_cell{curr, 2} = strcat('i', nation_serial, picnames_groups_i(i_row));
                curr = curr + 1;
            end % 
            
            valid_idx = ~all(isnan(lab), 2);
            lab_valid = lab(valid_idx, :);
            
            if if_draw_in_lab == 1
                if ~isempty(lab_valid)
                    if length(point_color_all_i) >= size(lab_valid, 1)
                        point_colors = point_color_all_i(1:size(lab_valid, 1), :);
                    else
                        point_colors = repmat([0.5, 0.5, 0.5], size(lab_valid, 1), 1);
                    end % 
                    
                    if strcmp(color_mode, "CT") || strcmp(color_mode, "CT_scene")
                        scatter(lab_valid(:, 2), lab_valid(:, 3), 27, point_colors, 'o', 'filled', ...
                            'MarkerFaceAlpha', 0.8, 'MarkerEdgeColor', 'k', 'LineWidth', 0.5);
                    else
                        for i_point = 1:size(lab_valid, 1)
                            text(lab_valid(i_point, 2), lab_valid(i_point, 3), ...
                                num2str(i_point), 'FontSize', 5, ...
                                'VerticalAlignment', 'middle', 'Color', [0, 0, 0], ...
                                'FontWeight', 'bold');
                        end % 
                    end % 
                end % 
            end
            
            % ========== 缁樺埗 r condition ==========
            CT_current_r = CT_r{i_nation};
            
            lab_data_r = lab_fit_reshaped{i_obs, i_nation, 2}(indices_target_r, :, :, attribute);
            lab_r = nanmean(lab_data_r, 3);
            valid_idx_r = ~all(isnan(lab_r), 2);
            lab_valid_r = lab_r(valid_idx_r, :);
            
            point_color_all_r = zeros(size(lab_valid_r, 1), 3);
            for i_point = 1:size(lab_valid_r, 1)
                if strcmp(color_mode, "CT")
                    if i_point <= length(CT_current_r)
                        ct_val = CT_current_r(i_point);
                        color_idx = CCT_to_coloridx(ct_val, lim_CCT, cmap_resolution);
                        point_color_all_r(i_point, :) = current_cmap(color_idx, :);
                    else
                        point_color_all_r(i_point, :) = [0.5, 0.5, 0.5];
                    end % 
                elseif strcmp(color_mode, "CT_scene")
                    if ismember(i_point, [1, 2, 4, 5, 6])
                        point_color_all_r(i_point, :) = scene_colors(1, :);
                    elseif ismember(i_point, [3, 7, 8, 9, 10, 11, 12])
                        point_color_all_r(i_point, :) = scene_colors(2, :);
                    elseif ismember(i_point, [13, 14])
                        point_color_all_r(i_point, :) = scene_colors(3, :);
                    else
                        point_color_all_r(i_point, :) = [0, 0, 0];
                    end % 
                else
                    if ismember(i_point, [1, 2, 4, 5, 6])
                        point_color_all_r(i_point, :) = scene_colors(1, :);
                    elseif ismember(i_point, [3, 7, 8, 9, 10, 11, 12])
                        point_color_all_r(i_point, :) = scene_colors(2, :);
                    elseif ismember(i_point, [13, 14])
                        point_color_all_r(i_point, :) = scene_colors(3, :);
                    else
                        point_color_all_r(i_point, :) = [0, 0, 0];
                    end % 
                end % 
            end % 
            
            lab_data_r_attr = lab_fit_reshaped{i_obs, i_nation, 2}(indices_target_r, :, :, attribute);
            lab_r_attr = nanmean(lab_data_r_attr, 3);
            
            for i_row = indices_target_r
                res_matrix = [res_matrix; lab_r_attr(i_row, :)];
                res_cell{curr, 1} = lab_r_attr(i_row, :);
                res_cell{curr, 2} = strcat('r', nation_serial, picnames_groups_r(i_row));
                curr = curr + 1;
            end % 
            
            valid_idx_r_attr = ~all(isnan(lab_r_attr), 2);
            lab_valid_r_attr = lab_r_attr(valid_idx_r_attr, :);
            
            if ~isempty(lab_valid_r_attr)
                if length(point_color_all_r) >= size(lab_valid_r_attr, 1)
                    point_colors_r = point_color_all_r(1:size(lab_valid_r_attr, 1), :);
                else
                    point_colors_r = repmat([0.5, 0.5, 0.5], size(lab_valid_r_attr, 1), 1);
                end % 
                
                for i_point = 1:size(lab_valid_r_attr, 1)
                    text(lab_valid_r_attr(i_point, 2), lab_valid_r_attr(i_point, 3), ...
                        num2str(i_point), 'FontSize', 8, ...
                        'VerticalAlignment', 'middle', 'Color', point_colors_r(i_point, :), ...
                        'FontWeight', 'bold');
                end % 
            end
            
            % 璁剧疆鍧愭爣杞村拰鏍囬
            if strcmp(interpreter_type, "tex")
                xlabel('a^{*}', 'Interpreter', 'tex', 'FontName', 'Arial', 'FontAngle', 'italic', 'FontSize', targetFontSize);
                ylabel('b^{*}', 'Interpreter', 'tex', 'FontName', 'Arial', 'FontAngle', 'italic', 'FontSize', targetFontSize);
            elseif strcmp(interpreter_type, "latex")
                xlabel('a^{*}', 'Interpreter', 'latex', 'FontSize', targetFontSize);
                ylabel('b^{*}', 'Interpreter', 'latex', 'FontSize', targetFontSize);
            end
            % title璁句负attribute_names
            title(attribute_names(attribute), 'FontSize', targetFontSize);
            axis equal;
            xlim([0, 35]);
            ylim([0, 35]);
            
            for theta = 45
                m = tand(theta);
                x_line = linspace(0, lim_max_x, 100);
                y_line = m * x_line;
                valid_line_idx = (y_line >= 0) & (y_line <= lim_max_y);
                plot(x_line(valid_line_idx), y_line(valid_line_idx), 'Color', 'k', 'LineStyle', '--');
            end % 
            
            ax = gca;
            set(ax, 'FontSize', targetFontSize);
            yPos = ax.YLabel.Position;
            yPos(1) = yPos(1) - 5;
            ax.YLabel.Position = yPos;
            xPos = ax.XLabel.Position;
            xPos(2) = xPos(2) - 5;
            ax.XLabel.Position = xPos;
            
            % 淇濆瓨鍥剧墖
            save_folder = fullfile("ellip_pic_p", Dtype, "scene2_CT", ...
                lightness_type, obs_type, text_type, variable_type);
            if ~exist(save_folder, "dir")
                mkdir(save_folder, 'recursive');
            end % 
            
            img_name = fullfile(save_folder, strcat(attribute_serial, '_L.jpg'));
            savefig(gcf, strrep(img_name, 'jpg', 'fig'));
            exportgraphics(gcf, img_name, 'Resolution', 300);
        end
        
        % attr妯″紡涓嬬殑鍥剧墖鍚堝苟澶勭悊
        save_folder = fullfile("ellip_pic_p", Dtype, "scene2_CT", ...
            lightness_type, obs_type, text_type, variable_type);
        
        %% adjust_fig
        opts.lim_min = 0;
        opts.lim_max = 40;
        opts.targetFontSize = 12;
        opts.margin = 0.1;
        opts.label_type = "scene";
        opts.if_rotate = false;
        opts.axis_limits = repmat([0, 28, 0, 28], length(attributes), 1);
        opts.axis_ticks = repmat(5, 1, length(attributes));
        adjust_fig(save_folder, opts);
        
        %% concatenate_figs_legend1
        if strcmp(color_mode, "scene")
            if strcmp(text_type, "eng")
                s.labels_row1 = {"in-lab", "indoor", "outdoor", "night"};
            elseif strcmp(text_type, "ch")
                s.labels_row1 = {"瀹為獙瀹?, "瀹ゅ唴", "瀹ゅ", "澶滄櫙"};
            end % 
            s.labels_row2 = {};
            s.markers_row2 = {};
            s.markers_colors = [];
            s.markers_face_colors = [];
            s.n_col1 = 5;
            s.n_col2 = 5;
            s.if_label = true;
            s.leg_x_shift = -0.03;
            
            num_attributes = 3;
            hue_values = linspace(0, 1, num_attributes + 1);
            hue_values = hue_values(1:end % -1);
            hsv_matrix = [hue_values', 0.8 * ones(num_attributes, 1), 0.8 * ones(num_attributes, 1)];
            s.colors_row1(2:4, :) = hsv2rgb(hsv_matrix);
            s.colors_row1(1, :) = [0 0 0];
            s.label_type = "scene";
        else
            if strcmp(text_type, "eng")
                s.labels_row1 = {"indoor", "outdoor", "night"};
            elseif strcmp(text_type, "ch")
                s.labels_row1 = {"瀹ゅ唴", "瀹ゅ", "澶滄櫙"};
            end % 
            s.labels_row2 = {};
            s.markers_row2 = {};
            s.markers_colors = [];
            s.markers_face_colors = [];
            s.n_col1 = 5;
            s.n_col2 = 5;
            s.if_label = true;
            
            if if_draw_in_lab == 1
                s.legend_labels = {0.95, 0.9, 0.02};
                s.colorbar_height_ratio = 0.9;
                s.colorbar_right_margin = 0.02;
                s.colorbar_position = 'right';
                s.colorbar_mode = 'cover_rows';
            else
                s.colorbar_mode = 'none';
            end % 
            
            num_attributes = 3;
            hue_values = linspace(0, 1, num_attributes + 1);
            hue_values = hue_values(1:end % -1);
            hsv_matrix = [hue_values', 0.8 * ones(num_attributes, 1), 0.8 * ones(num_attributes, 1)];
            s.colors_row1 = hsv2rgb(hsv_matrix);
            s.colors_row1([2, 3], :) = s.colors_row1([3, 2], :);
            s.color_limits = [2500, 8500];
            s.cmap = current_cmap;
            s.label_type = "scene";
            
            num_attributes = 0;
        end % 
        
        dir_figs = dir(fullfile(save_folder, "*adjusted.fig"));
        clear("figFiles")
        for i_fig = 1:length(dir_figs)
            figFiles{i_fig} = dir_figs(i_fig).name;
        end % 
        s.fontSizeScale = 1.2;
        
        % 鏍规嵁attribute鏁伴噺鍐冲畾鍚堝苟鍒楁暟
        n_cols = ceil(length(attributes) / 2);
        concatenate_figs_legend1(save_folder, figFiles, n_cols, "none", "draw", s, 0.09, 0.35);
        
        concatenate_images1(save_folder, 4);
        
    else
        % variable_type = "nation" 妯″紡锛屼繚鎸佸師鏈夐€昏緫
        for i_nation_idx = nation_loop
            i_nation = i_nation_idx;
            nation=nations(i_nation);
            nation_serial=strcat(sprintf("%02d",i_nation),nation);
            figure(i_nation);
            hold on;
            set(gcf, 'Color', 'white');
        
        % ========== 缁樺埗 i condition ==========
        CT_current = CT_i;  % 浣跨敤i鐨凜T
        
        % 棰勫厛璁＄畻鎵€鏈塱鏁版嵁鐨勯鑹?        lab_data_i = lab_fit_reshaped{i_obs,i_nation, 1}(indices_target_i, :, :, 1);
        lab_i = nanmean(lab_data_i, 3);
        valid_idx_i = ~all(isnan(lab_i), 2);
        lab_valid_i = lab_i(valid_idx_i, :);
        
        % 鏍规嵁color_mode璁＄畻姣忎釜鐐圭殑棰滆壊
        point_color_all_i = zeros(size(lab_valid_i, 1), 3);
        for i_point = 1:size(lab_valid_i, 1)
            if strcmp(color_mode, "CT") || strcmp(color_mode, "CT_scene")
                % CT妯″紡鎴朇T_scene妯″紡锛氭寜CT鍊肩潃鑹?                if i_point <= length(CT_current)
                    ct_val = CT_current(i_point);
                    color_idx = CCT_to_coloridx(ct_val, lim_CCT, cmap_resolution);
                    point_color_all_i(i_point, :) = current_cmap(color_idx, :);
                else
                    point_color_all_i(i_point, :) = [0.5, 0.5, 0.5];
                end % 
            else
                % scene妯″紡锛氭寜鍦烘櫙绫诲瀷鐫€鑹诧紝i condition鍏ㄤ负榛戣壊
                point_color_all_i(i_point, :) = [0, 0, 0];  % 榛戣壊
            end % 
        end % 
        
        for i_attr_idx = attr_loop
            if strcmp(variable_type,"attr")
                figure(i_attr_idx);hold on;
            end % 
            attribute = attributes(i_attr_idx);
            attribute_serial = strcat(sprintf("%02d", attribute), attribute_names(attribute));
            attribute_serial=ch2eng(attribute_serial);
            
            lab_data = lab_fit_reshaped{i_obs,i_nation, 1}(indices_target_i, :, :, attribute);
            lab = nanmean(lab_data, 3);
            
            for i_row=indices_target_i
            res_matrix=[res_matrix;lab(i_row,:)];
            res_cell{curr,1}=lab(i_row,:);
            res_cell{curr,2}=strcat('i',nation_serial, picnames_groups_i(i_row));
            curr=curr+1;
            end % 
            
            data_for_color = lab(:, 1);
            valid_idx = ~all(isnan(lab), 2);
            lab_valid = lab(valid_idx, :);
            data_valid = data_for_color(valid_idx);
            
            % 鍙湁鍦╥f_draw_in_lab==1鏃舵墠缁樺埗i condition鐨勭偣
            if if_draw_in_lab == 1
                if ~isempty(lab_valid)
                    % 鑾峰彇瀵瑰簲鐨勯鑹?                    if length(point_color_all_i) >= size(lab_valid, 1)
                        point_colors = point_color_all_i(1:size(lab_valid, 1), :);
                    else
                        point_colors = repmat([0.5, 0.5, 0.5], size(lab_valid, 1), 1);
                    end % 
                    
                    if strcmp(color_mode, "CT") || strcmp(color_mode, "CT_scene")
                        % CT妯″紡鎴朇T_scene妯″紡锛氱敤scatter鐢诲渾鐐?                        scatter(lab_valid(:, 2), lab_valid(:, 3), 27, point_colors, 'o', 'filled', ...
                            'MarkerFaceAlpha', 0.8, 'MarkerEdgeColor', 'k', 'LineWidth', 0.5);
                    else
                        % scene妯″紡锛氱敤text琛ㄧず锛堥粦鑹诧級
                        for i_point = 1:size(lab_valid, 1)
                            text(lab_valid(i_point, 2), lab_valid(i_point, 3), ...
                            num2str(i_point), 'FontSize', 5, ...
                            'VerticalAlignment', 'middle','Color',[0, 0, 0], ...
                            'FontWeight', 'bold');
                        end % 
                    end % 
                end % 
            end % 
        end
        
        % ========== 缁樺埗 r condition ==========
        CT_current_r = CT_r{i_nation};  % 浣跨敤r鐨凜T (鎸変汉绉?
        
        % 棰勫厛璁＄畻鎵€鏈塺鏁版嵁鐨勯鑹?        lab_data_r = lab_fit_reshaped{i_obs,i_nation, 2}(indices_target_r, :, :, 1);
        lab_r = nanmean(lab_data_r, 3);
        valid_idx_r = ~all(isnan(lab_r), 2);
        lab_valid_r = lab_r(valid_idx_r, :);
        
        point_color_all_r = zeros(size(lab_valid_r, 1), 3);
        for i_point = 1:size(lab_valid_r, 1)
            if strcmp(color_mode, "CT")
                % CT妯″紡锛氭寜CT鍊肩潃鑹?                if i_point <= length(CT_current_r)
                    ct_val = CT_current_r(i_point);
                    color_idx = CCT_to_coloridx(ct_val, lim_CCT, cmap_resolution);
                    point_color_all_r(i_point, :) = current_cmap(color_idx, :);
                else
                    point_color_all_r(i_point, :) = [0.5, 0.5, 0.5];
                end % 
            elseif strcmp(color_mode, "CT_scene")
                % CT_scene妯″紡锛歳鎸塻cene妯″紡鐫€鑹?                if ismember(i_point, [1, 2, 4, 5, 6])
                    point_color_all_r(i_point, :) = scene_colors(1, :);
                elseif ismember(i_point, [3, 7, 8, 9, 10, 11, 12])
                    point_color_all_r(i_point, :) = scene_colors(2, :);
                elseif ismember(i_point, [13, 14])
                    point_color_all_r(i_point, :) = scene_colors(3, :);
                else
                    point_color_all_r(i_point, :) = [0, 0, 0];
                end % 
            else
                % scene妯″紡锛氭寜鍦烘櫙绫诲瀷鐫€鑹?                if ismember(i_point, [1, 2, 4, 5, 6])
                    point_color_all_r(i_point, :) = scene_colors(1, :);
                elseif ismember(i_point, [3, 7, 8, 9, 10, 11, 12])
                    point_color_all_r(i_point, :) = scene_colors(2, :);
                elseif ismember(i_point, [13, 14])
                    point_color_all_r(i_point, :) = scene_colors(3, :);
                else
                    point_color_all_r(i_point, :) = [0, 0, 0];
                end % 
            end % 
        end % 
        
        for i_attr_idx = attr_loop
            attribute = attributes(i_attr_idx);
            attribute_serial = strcat(sprintf("%02d", attribute), attribute_names(attribute));
            attribute_serial=ch2eng(attribute_serial);
            
            lab_data = lab_fit_reshaped{i_obs,i_nation, 2}(indices_target_r, :, :, attribute);
            lab = nanmean(lab_data, 3);
            
            for i_row=indices_target_r
            res_matrix=[res_matrix;lab(i_row,:)];
            res_cell{curr,1}=lab(i_row,:);
            res_cell{curr,2}=strcat('r',nation_serial, picnames_groups_r(i_row));
            curr=curr+1;
            end % 
            
            data_for_color = lab(:, 1);
            valid_idx = ~all(isnan(lab), 2);
            lab_valid = lab(valid_idx, :);
            data_valid = data_for_color(valid_idx);
            
            if ~isempty(lab_valid)
                % 鑾峰彇瀵瑰簲鐨勯鑹?                if length(point_color_all_r) >= size(lab_valid, 1)
                    point_colors_r = point_color_all_r(1:size(lab_valid, 1), :);
                else
                    point_colors_r = repmat([0.5, 0.5, 0.5], size(lab_valid, 1), 1);
                end
                
                % r condition缁熶竴鐢╰ext琛ㄧず
                for i_point = 1:size(lab_valid, 1)
                    text(lab_valid(i_point, 2), lab_valid(i_point, 3), ...
                    num2str(i_point), 'FontSize', 8, ...
                    'VerticalAlignment', 'middle','Color',point_colors_r(i_point, :), ...
                    'FontWeight', 'bold');
                end % 
                disp("d")
            end % 
        end % 
        
        if strcmp(interpreter_type, "tex")
            xlabel('a^{*}','Interpreter','tex','FontName','Arial','FontAngle','italic','FontSize',targetFontSize);
            ylabel('b^{*}','Interpreter','tex','FontName','Arial','FontAngle','italic','FontSize',targetFontSize);
        elseif strcmp(interpreter_type, "latex")
            xlabel('a^{*}','Interpreter','latex','FontSize',targetFontSize);
            ylabel('b^{*}','Interpreter','latex','FontSize',targetFontSize);
        end % 
        if strcmp(variable_type,"attr")
            title(attribute_names(attribute),'FontSize', targetFontSize);
        else
            title([nation_names(i_nation)],'FontSize', targetFontSize);
        end % 
        axis equal;
        
        % 鏍规嵁浜虹璁剧疆涓嶅悓鐨勫潗鏍囪酱鑼冨洿
        if i_nation == 4  % AF (闈炴床浜?
            xlim([0, 20]);
            ylim([0, 20]);
        else
            xlim([0, 35]);
            ylim([0, 35]);
        end % 
        
        if plot_45_only
            thetas_to_plot = 45;
        else
            thetas_to_plot = 20:5:70;
        end % 
        
        for theta = thetas_to_plot
            m = tand(theta);
            x_line = linspace(0, lim_max_x, 100);
            y_line = m * x_line;
            valid_line_idx = (y_line >= 0) & (y_line <= lim_max_y);
            plot(x_line(valid_line_idx), y_line(valid_line_idx), 'Color', 'k', 'LineStyle', '--');
        end
        
        % 鐢昏繛鎺ョ嚎
        if strcmp(draw_line, "line")
            % 绾?: (2,2) -> (2,3) -> (6,2) -> (6,3)
            plot([lab_valid(2, 2), lab_valid(6, 2)], [lab_valid(2, 3), lab_valid(6, 3)], ...
                'k-', 'LineWidth', 1);
            % 绾?: (9,2) -> (9,3) -> (10,2) -> (10,3)
            plot([lab_valid(9, 2), lab_valid(10, 2)], [lab_valid(9, 3), lab_valid(10, 3)], ...
                'k-', 'LineWidth', 1);
        end % 
        
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
        
        % 淇濆瓨鍥剧墖
        save_folder = fullfile("ellip_pic_p", Dtype, "scene2_CT", ...
            lightness_type, obs_type, text_type,variable_type);
        if ~exist(save_folder, "dir")
            mkdir(save_folder, 'recursive');
        end % 
        
        img_name=fullfile(save_folder, strcat(nation_serial, '_L.jpg'));
        savefig(gcf, strrep(img_name,'jpg','fig'));
        exportgraphics(gcf, img_name, 'Resolution', 300);
    end  % end %  for i_nation_idx (nation妯″紡)
    
    % nation妯″紡鐨勫浘鐗囧悎骞?    %% adjust_fig
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
        % scene妯″紡锛氫笌scatter_scene2涓€鑷达紝缁樺埗row2锛屼笉缁樺埗colorbar
        if strcmp(text_type,"eng")
            s.labels_row1 = {"in-lab","indoor","outdoor","night"};
        elseif strcmp(text_type,"ch")
            s.labels_row1 = {"瀹為獙瀹?,"瀹ゅ唴","瀹ゅ","澶滄櫙"};
        end % 
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
        hue_values = hue_values(1:end % -1);
        hsv_matrix = [hue_values', 0.8 * ones(num_attributes, 1), 0.8 * ones(num_attributes, 1)];
        s.colors_row1(2:4,:) = hsv2rgb(hsv_matrix);
        s.colors_row1(1,:)=[0 0 0];
        s.label_type = "scene";
        
    else
        % CT妯″紡鎴朇T_scene妯″紡锛氱粯鍒禼olorbar锛屾帶鍒朵綅缃娇鍏舵í璺ㄤ袱琛?        if strcmp(text_type,"eng")
            s.labels_row1 = {"indoor","outdoor","night"};
        elseif strcmp(text_type,"ch")
            s.labels_row1 = {"瀹ゅ唴","瀹ゅ","澶滄櫙"};
        end % 
        s.labels_row2 = {};
        s.markers_row2 = {};
        s.markers_colors = [];
        s.markers_face_colors = [];
        s.n_col1 = 5; 
        s.n_col2 = 5;
        s.if_label = true;  % CT/CT_scene妯″紡涓嶆樉绀簉ow1鏍囩
        
        % 鍙湁鍦╥f_draw_in_lab==1鏃舵墠缁樺埗colorbar
        if if_draw_in_lab == 1
            % CT妯″紡鎴朇T_scene妯″紡锛氬畾涔塴egend鐨勪綅缃弬鏁帮紝浣縞olorbar妯法涓よ
            % legend_labels鍖呭惈: {colorbar浣嶇疆, colorbar楂樺害姣斾緥, colorbar璺濆彸杈硅窛绂粆
            % 浣嶇疆: 0-1涔嬮棿锛岃〃绀哄湪鎵€鏈塻ubfig涔嬪悗鐨勭浉瀵逛綅缃?            s.legend_labels = {0.95, 0.9, 0.02};  % [鐩稿浣嶇疆, 楂樺害姣斾緥, 鍙宠竟璺漖
            s.colorbar_height_ratio = 0.9;  % colorbar楂樺害鍗犱袱琛岀殑姣斾緥
            s.colorbar_right_margin = 0.02;  % 璺濈鏈€鍙宠竟subfig鐨勮窛绂?            s.colorbar_position = 'right';  % colorbar鍦ㄥ彸渚?            s.colorbar_mode = 'cover_rows';  % colorbar瑕嗙洊鎵€鏈夎
        else
            % if_draw_in_lab==0鏃朵笉缁樺埗colorbar
            s.colorbar_mode = 'none';
        end % 
        
        num_attributes = 3;
        hue_values = linspace(0, 1, num_attributes + 1);
        hue_values = hue_values(1:end % -1);
        hsv_matrix = [hue_values', 0.8 * ones(num_attributes, 1), 0.8 * ones(num_attributes, 1)];
        s.colors_row1 = hsv2rgb(hsv_matrix);
        s.colors_row1([2,3],:)=s.colors_row1([3,2],:);
        s.color_limits = [2500, 8500];
        s.cmap = current_cmap;
        s.label_type = "scene";
        
        num_attributes = 0;
    end % 
    
    dir_figs = dir(fullfile(save_folder, "*adjusted.fig"));
    clear("figFiles")
    for i_fig = 1:length(dir_figs)
        figFiles{i_fig} = dir_figs(i_fig).name;
    end % 
    s.fontSizeScale=1.2;
    concatenate_figs_legend1(save_folder, figFiles, 2, "none", "draw", s, 0.09, 0.35);
    
    %% 鍚堝苟鍥剧墖
    concatenate_images1(save_folder, 4);
end % 

fullfile(pwd, save_folder)

