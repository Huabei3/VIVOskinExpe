
% make_Peggy_VIVO_table
% - 直接按 scatter_attr1 的三层循环结构逐个 lastPart/attribute 加载 AnalyseResults_p 内的
%   ellipPara/fitRes.mat（par_all），配合 aveSkin 的平均肤色，生成行式 fit_table
% - 不依赖 data_reshaped_*.mat
% - 列包含：source(Peggy_VIVO)、lab_values(Nx3)、opinion_scores(Nx1，用模型在 lab_bf 处预测的 y_pred)，
%   par(6x1，par_all 的均值)、fit_equation(给定字符串)、lab_center([mean(L*), a0, b0]，使用 par 均值的 a0/b0)、
%   average_lab(1x3)、CCT、illuminance、scene、lighting(i/r)、D_equation_str(给定字符串)、
%   model_ethnicity、model_id、observer_type、opinion_score_range
%
% 输出：
%   resTable/Peggy_VIVO_table.mat (变量 fit_table)
%   resTable/Peggy_VIVO_table.xlsx (excel 摘要表)

clc;clear;close all;
%%


% 基础路径（VIVO 分析目录）
base_analyze = fullfile('D:\','work','VIVOskinExpe','analyze');
addpath(fullfile(base_analyze,'utils')); % 以便使用 lab2xyz2 / xyz2lab 等

% 关键开关（可按需改）
scale_type         = "scaled";    % "unscaled" 或 "scaled"（影响 lab_scaled 计算）
scale_type_origin  = "unscaled";    % fitRes 路径中的原始尺度层级
scale_time         = "late";        % "early" 时 fitRes 在 scaled/ 子目录下
Dtype              = 'efit_p';      % 与 scatter_attr1 一致
obs_types          = ["non_model","model_group"];
attributes         = 1:10;
attribute_names_new = ["Preference","Attractiveness","Feminine","Cooperative", ...
                       "Youth","Healthy","Fidelity","Harmony","Fair","Ruddy"];
nations   = ["AS","CA","SA","AF"];
nation_names=["Asian","Caucasian","South Asian","African"];
nation_indices = {1:6, 7:12, 13:16, 17:20};

% lastParts（i/r 两套）
lastParts_i = {'f04i','f05i','f06i','m04i','m05i','m06i', ...
               'f01i','f02i','f03i','m01i','m02i','m03i', ...
               'f07i','f08i','m07i','m08i', ...
               'f09i','f10i','m09i','m10i'};
lastParts_r = {'f04r','f05r','f06r','m04r','m05r','m06r', ...
               'f01r','f02r','f03r','m01r','m02r','m03r', ...
               'f07r','f08r','m07r','m08r', ...
               'f09r','f10r','m09r','m10r'};

% 常量与 LUT
wd65 = [94.811, 100.00, 107.304];
datai_file = fullfile('D:\','work','VIVOskinExpe','renderCode','calibResults','datai_ipv18_3.mat');
LUT=load(datai_file); XYZw_LUT=LUT.XYZw;

% 列初始化
col_source               = {};
col_lab_values           = {};
col_opinion_scores       = {};
col_par                  = {};
col_fit_equation         = {};
col_lab_center           = {};
col_average_lab          = {};
col_cct                  = {};
col_illuminance          = {};
col_scene                = {};
col_nodel_lighting             = {};
col_D_equation_str       = {};
col_model_ethnicity      = {};
col_model_gender               = {};   % NEW
col_model_id             = {};
col_observer_type        = {};
col_opinion_score_range  = {};
col_other_info           = {}; 
col_attr           = {}; % NEW

% 固定字符串（按你的要求）
fit_equation_str = "y = (1./(1 + a(6) * exp(sqrt(a(1) * (data2 - a(4)).^2 + a(2) * (data3 - a(5)).^2 + a(3) * (data2 - a(4)) .* (data3 - a(5)))))) .* ((a(1) * (data2 - a(4)).^2 + a(2) * (data3 - a(5)).^2 + a(3) * (data2 - a(4)) .* (data3 - a(5))) >= 0);";
D_equation_str  = "D=0.9193.*(1-500.1675./CCT);";

% 数据库来源常量
db_source = "Peggy_VIVO";
iOrs=["i","r"];
% 两套 lastParts 轮流跑一遍：i 再 r
for i_iOr = 1:2
    
    iOr=iOrs(i_iOr);
    load(fullfile("documents",iOr,"render_data2.mat"),"render_map");
    if iOr=='i'
    picnames_groups = ["h3k","h4k","h5k","h6k","hd65","h7k","h8k",...
            "m3k","m4k","m5k","m6k","md65","m7k","m8k",...
             "l3k","l4k","l5k","l6k","ld65","l7k","l8k"];
    elseif iOr=='r'
        picnames_groups = ["rs01","rs02","rs03","rs04","rs05","rs06","rs07", ...
                 "rs08","rs09","rs10","rs11","rs12","rs13","rs14"];
    end
    if iOr=='i'
        target_indices{1}=1:7;
        target_indices{2}=8:14;
        target_indices{3}=15:21;
    else
        target_indices{1}=[1,2,4,5,6];
        target_indices{2}=[7,8,9,10];
        target_indices{3}=[11,12];
        target_indices{4}=[13,14];
    end
    if strcmp(iOr,"i")
        scene_type=["high","mediocre","low"];
    elseif strcmp(iOr,"r")
        scene_types=["indoor","outdoor","sunset","night"];
    end
    if i_iOr==1, lastParts = lastParts_i; else, lastParts = lastParts_r; end

    for i_obs = 1:length(obs_types)
        obs_type = obs_types(i_obs);

        for i_nation = 1:length(nations)
            nation = nations(i_nation);
            curr_nation_indices = nation_indices{i_nation};
            n_subjects = numel(curr_nation_indices);

            for i_subject = 1:n_subjects
                subject_idx = curr_nation_indices(i_subject);
                lastPart = lastParts{subject_idx};
                iOr = lastPart(end); % 'i' or 'r'

                % 加载平均肤色（用于 L* 与 lab_bf）
                average_file = fullfile(base_analyze,"aveSkin", lastPart, "autoNhand_scaleoverLUT.mat");
                if exist(average_file, 'file')
                    average_data = load(average_file);
                    ave_curr = average_data.average_lab_all(:, 1:3); % (n_para x 3)
                else
                    ave_curr = nan(1,3); % 占位
                end

                % 加载白点（用于 scaled late）
                XYZw_white = [];
                white_file = fullfile(base_analyze,"optimizedD","whiteSquare","XYZw_white", strcat(lastPart, ".mat"));
                if exist(white_file,'file')
                    sW = load(white_file);
                    if isfield(sW,'XYZw_white'), XYZw_white = sW.XYZw_white; end
                end

                % 逐 attribute 处理
                for i_attr = 1:numel(attributes)
                    attribute = attributes(i_attr);
                    attribute_serial = strcat(sprintf("%02d", attribute), attribute_names_new(attribute));



                    % 构造 fitRes 路径（不读 data_reshaped）
                    if strcmp(scale_time,"early")
                        source_file = fullfile(base_analyze,'AnalyseResults_p', Dtype, scale_type_origin, "scaled", ...
                            lastPart, obs_type, attribute_serial, 'ellipPara', 'fitRes.mat');
                    else
                        source_file = fullfile(base_analyze,'AnalyseResults_p', Dtype, scale_type_origin, ...
                            lastPart, obs_type, attribute_serial, 'ellipPara', 'fitRes.mat');
                    end

                    if ~exist(source_file,'file')
                        % 缺文件：跳过该行
                        continue;
                    end

                    S = load(source_file);
                    if isfield(S,'par_all')
                        par_all = S.par_all;  % (n_para x 6)
                    elseif isfield(S,'par')
                        par_all = S.par;
                    else
                        % 未找到 par，跳过
                        continue;
                    end
                    if isempty(par_all), continue; end

                    % 与平均肤色对齐
                    n_row = size(par_all,1);
                    if size(ave_curr,1) >= n_row
                        ave_use = ave_curr(1:n_row, :);
                    else
                        % ave 比 par_all 短：按 par_all 行数截断/填充
                        ave_use = nan(n_row,3);
                        ave_use(1:size(ave_curr,1),:) = ave_curr;
                    end

                    % lab_bf = [Lmean, a0, b0]（unscaled 或进一步按 late-scaled 转换）
                    lab_bf = [ave_use(:,1), par_all(:,4:5)];
                    lab_fit = lab_bf;
                    if strcmp(scale_type,"scaled") && strcmp(scale_time,"late") && ~isempty(XYZw_white)
                        lab_fit = nan(size(lab_bf));
                        for ip = 1:size(lab_bf,1)
                            try
                                xyz_fit = lab2xyz2(lab_bf(ip,:), "user", wd65./wd65(2).*XYZw_LUT(2));
                                lab_fit(ip,:) = xyz2lab(xyz_fit, "user", wd65./wd65(2).*XYZw_white(ip,2));
                            catch
                                lab_fit(ip,:) = lab_bf(ip,:);
                            end
                        end
                    end
                    for i_par=1:size(par_all,1)
                        curr_cell=render_map(strcat(lastPart,picnames_groups(i_par)));
                        curr_CCT=curr_cell.CCT_val;
                        curr_E=curr_cell.E_val;

                        labNscore_file = fullfile(base_analyze,'AnalyseResults_p', ...
                            Dtype, scale_type_origin, ...
                                lastPart, obs_type, attribute_serial, ...
                                'labNscore', ...
                                strcat('labNscore_group',lastPart, ...
                                picnames_groups(i_par),'.mat'));
                        labNscore_data=load(labNscore_file);
                        % 计算该 subject-attr 的 par 向量（按 n_para 求均值 -> 6x1）
                        par_vec = par_all(i_par,:);
                        if strcmp(iOr,"r")
                            for i_scene_type=1:length(target_indices)
                                if ismember(i_par,target_indices{i_scene_type})
                                    break
                                end
                            end
                        end
                        if strcmp(iOr,"i")
                            scene_type="inLab";
                        elseif strcmp(iOr,"r")
                            scene_type=scene_types(i_scene_type);
                            scene_type
                        end
   
    
                        % 行聚合
                        if startsWith(lastPart,'f')
                            gender = "female";
                        elseif startsWith(lastPart,'m')
                            gender = "male";
                        else
                            gender = "unknown";
                        end
                        row = size(col_source,1) + 1;
                        col_source{row,1}               = db_source;
             
                        col_lab_values{row,1}           =  labNscore_data.lab_group;               
                        col_opinion_scores{row,1}       =  labNscore_data.p_group;
                        col_par{row,1}                  = par_vec;                 % 6×1
                        col_fit_equation{row,1}         = fit_equation_str;
                        col_lab_center{row,1}           = lab_fit(i_par,:);
                        col_average_lab{row,1}          = labNscore_data.average_curr;
                        col_cct{row,1}                  = curr_CCT;       % 可后续回填
                        col_illuminance{row,1}          = curr_E;       % 可后续回填
                        col_scene{row,1}                = strcat(scene_type," ",picnames_groups(i_par));    % 场景标识
                        col_nodel_lighting{row,1}       = "D65";
                        col_D_equation_str{row,1}       = D_equation_str;
                        col_model_ethnicity{row,1}      = string(nation_names(i_nation));
                        col_model_gender{row,1}               = gender;
                        col_model_id{row,1}             = string(lastPart(1:end-1));
                        col_observer_type{row,1}        = string(obs_type);
                        col_opinion_score_range{row,1}  = "-3~3";
                        col_other_info{row,1}           = curr_cell;
                        col_attr{row,1}           = attribute_names_new(attribute);

                    end
                end
            end
        end
    end
end

% 生成表
fit_table = table( ...
    col_source, col_lab_values, col_opinion_scores, col_par, col_fit_equation, ...
    col_lab_center, col_average_lab, col_cct, col_illuminance, col_scene, col_nodel_lighting, ...
    col_D_equation_str, col_model_ethnicity, col_model_gender, col_model_id, col_observer_type, ...
    col_opinion_score_range, col_other_info,col_attr, ...
    'VariableNames', { ...
        'source', 'lab_values', 'opinion_scores', 'par', 'fit_equation', ...
        'lab_center', 'average_lab', 'CCT', 'illuminance', 'scene', 'lighting', ...
        'D_equation_str', 'model_ethnicity', 'gender', 'model_id', 'observer_type', ...
        'opinion_score_range', 'other_info','attribute' ...
    } ...
);


% 导出

output_folder = fullfile("AnalyseResults_p\efit_p",scale_type,"resTable");

if ~exist(output_folder,'dir'), mkdir(output_folder); end
out_mat  = fullfile(output_folder, 'Peggy_VIVO_table.mat');
out_xlsx = fullfile(output_folder, 'Peggy_VIVO_table.xlsx');

save(out_mat, 'fit_table');

% Excel 摘要（与 make_cherry_table 风格一致）
excel_table = summarize_for_excel_final(fit_table);
writetable(excel_table, out_xlsx, 'FileType', 'spreadsheet');

fprintf('Saved: %s\n', out_mat);
fprintf('Saved: %s\n', out_xlsx);

% main

function T = summarize_for_excel_final(fit_table)
% 将数组列展平为 Excel 友好的统计摘要
n = height(fit_table);
lab_n   = zeros(n,1);
lab_L   = zeros(n,1);
lab_a   = zeros(n,1);
lab_b   = zeros(n,1);
score_n = zeros(n,1);
score_min = zeros(n,1);
score_max = zeros(n,1);
par_len = zeros(n,1);
for i=1:n
    Lv = fit_table.lab_values{i};
    if ~isempty(Lv)
        lab_n(i) = size(Lv,1);
        lab_L(i) = mean(Lv(:,1),'omitnan');
        lab_a(i) = mean(Lv(:,2),'omitnan');
        lab_b(i) = mean(Lv(:,3),'omitnan');
    else
        lab_n(i)=0; lab_L(i)=NaN; lab_a(i)=NaN; lab_b(i)=NaN;
    end
    sc = fit_table.opinion_scores{i};
    if ~isempty(sc)
        score_n(i)   = numel(sc);
        score_min(i) = min(sc);
        score_max(i) = max(sc);
    else
        score_n(i)=0; score_min(i)=NaN; score_max(i)=NaN;
    end
    pv = fit_table.par{i};
    if ~isempty(pv), par_len(i) = numel(pv); else, par_len(i) = 0; end
end
T = table( ...
    string(fit_table.source), ...
    lab_n, lab_L, lab_a, lab_b, ...
    score_n, score_min, score_max, ...
    par_len, ...
    string(fit_table.fit_equation), ...
    fit_table.lab_center, ...
    fit_table.average_lab, ...
    fit_table.CCT, ...
    fit_table.illuminance, ...
    string(fit_table.scene), ...
    string(fit_table.lighting), ...
    string(fit_table.D_equation_str), ...
    string(fit_table.model_ethnicity), ...
    string(fit_table.model_id), ...
    string(fit_table.observer_type), ...
    string(fit_table.opinion_score_range), ...
    'VariableNames', { ...
        'source', ...
        'lab_count','lab_mean_L','lab_mean_a','lab_mean_b', ...
        'score_count','score_min','score_max', ...
        'par_length', ...
        'fit_equation', ...
        'lab_center', ...
        'average_lab', ...
        'CCT', ...
        'illuminance', ...
        'scene', ...
        'lighting', ...
        'D_equation_str', ...
        'model_ethnicity', ...
        'model_id', ...
        'observer_type', ...
        'opinion_score_range' ...
    } ...
);
end
