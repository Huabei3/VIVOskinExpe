% make_Peggy_OPPO_table
% - 读取 OPPO 段落所用数据源，生成与 Peggy_VIVO_table 相同字段结构的表
% - 输出到: AnalyseResults_p\display\rela\efit_p\resTable\Peggy_OPPO_table.mat/.xlsx

clc; clear; close all;

% 常量与固定字符串
fit_equation_str = "y = (1./(1 + a(6) * exp(sqrt(a(1) * (data2 - a(4)).^2 + a(2) * (data3 - a(5)).^2 + a(3) * (data2 - a(4)) .* (data3 - a(5)))))) .* ((a(1) * (data2 - a(4)).^2 + a(2) * (data3 - a(5)).^2 + a(3) * (data2 - a(4)) .* (data3 - a(5))) >= 0);";
D_equation_str   = "D=0.9193.*(1-500.1675./CCT);";
db_source        = "Peggy_OPPO";

wd65=[94.811 100.00 107.304];
lightness_type="abs";
rgb2xyz_type="display";
Dtype = "efit_p";

% 目录
sourceFolder = fullfile('AnalyseResults_p',char(rgb2xyz_type),char(lightness_type));
output_folder= fullfile(sourceFolder, char(Dtype));
if ~exist(output_folder, 'dir'); mkdir(output_folder); end

load(fullfile("documents","CATedPre.mat"),"picname");
load(fullfile("neutral24","white.mat"),"CCT","XYZ_gray");
load(fullfile("documents","group_Lab.mat"),"cellMatrix");
load("OPPOskin\matchTable.mat","match_table");
CCT_scenes{1,1}=CCT(1:14,:);
CCT_scenes{2,1}=CCT(15:24,:);
CCT_scenes{3,1}=CCT(25:34,:);
CCT_scenes{4,1}=CCT(35:44,:);
CCT_scenes{5,1}=CCT(45:52,:);
avedata=load("documents\aveSkin\Hassel\autoNhand.mat");
ave_scenes{1,1}=avedata.average_lab_all;
avedata=load("documents\aveSkin\iphone\autoNhand.mat");
ave_scenes{2,1}=avedata.average_lab_all(1:10,:);
ave_scenes{3,1}=avedata.average_lab_all(11:20,:);
ave_scenes{4,1}=avedata.average_lab_all(21:30,:);
ave_scenes{5,1}=avedata.average_lab_all(31:38,:);

% lastParts
lastParts = ["inLab","indoorAdd","nightAdd","outdoorAdd","sunsetAdd","recen"];

% 列初始化（与 Peggy_VIVO_table 一致）
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
col_lighting             = {};
col_D_equation_str       = {};
col_model_ethnicity      = {};
col_model_gender         = {};
col_model_id             = {};
col_observer_type        = {};
col_opinion_score_range  = {};
col_other_info           = {};


% 生成逐 picname 的行
curr_row = 0;
for i_lastPart = 1:5  % 与给出代码一致，仅前 5 个
    lastPart = lastParts(i_lastPart);

    fitRes_folder = fullfile(output_folder, char(lastPart), 'ellipPara_scaled');
    fitRes_level_file = fullfile(fitRes_folder, "fitRes_level.mat");
    clear('par_ind','picname_check');
    load(fitRes_level_file,'par_ind','picname_check');

    labNscore_folder=fullfile(output_folder, char(lastPart), 'labNscore');


    n_par = size(par_ind,1);
    for i_par = 1:n_par
        curr_row = curr_row + 1;
        pn = string(picname_check{i_par});
        par_vec = par_ind(i_par,:);
        lab_center = par_vec(1,5:7);  % [L*, a0, b0] 约定

        labNscore_file = fullfile(labNscore_folder, ...
            strcat("labNscore_groupAdd",pn,".mat"));
        load(labNscore_file,"lab_group","p_group");

        % CCT / illuminance（保守处理：CCT按 picname 索引；illuminance 暂缺）
        cct_val = CCT_scenes{i_lastPart,1}(i_par,:);

        E_val = NaN;

        % 其他元信息

        for i_match=1:size(match_table,1)
            if strcmp(pn,match_table{i_match,3})
                model_id=match_table{i_match,1};
                break
            end
        end
        if i_match==size(match_table,1)+1
            model_id="nan";
        end
        if contains(model_id,"fe")
            model_gender="female";
        else
            model_gender="male";
        end

        % 聚合行
        col_source{curr_row,1}               = strcat(db_source,"_",pn);
        col_lab_values{curr_row,1}           = lab_group;
        col_opinion_scores{curr_row,1}       = p_group;              % OPPO 段无主观分数
        col_par{curr_row,1}                  = par_vec;
        col_fit_equation{curr_row,1}         = fit_equation_str;
        col_lab_center{curr_row,1}           = lab_center;
        col_average_lab{curr_row,1}          = ave_scenes{i_lastPart,1}(i_par,9:11);
        col_cct{curr_row,1}                  = cct_val;
        col_illuminance{curr_row,1}          = E_val;
        col_scene{curr_row,1}                = lastPart + " " + pn;
        col_lighting{curr_row,1}             = "D65";
        col_D_equation_str{curr_row,1}       = D_equation_str;
        col_model_ethnicity{curr_row,1}      = "Asian";
        col_model_gender{curr_row,1}         = model_gender;
        col_model_id{curr_row,1}             = model_id;
        col_observer_type{curr_row,1}        = "Asian";
        col_opinion_score_range{curr_row,1}  = "-3~3";
        info = struct();
        info.lastPart = char(lastPart);
        info.picname  = char(pn);
        col_other_info{curr_row,1}           = info;
    end


end

% 追加 self 数据（observer_type = "model"）
self_folder = fullfile(output_folder, "self");
self_file = fullfile(self_folder, "fitRes_self.mat");
if exist(self_file, 'file')
    self_data = load(self_file, "lab_group_all", "SV_group_all", "mean_center_all");
    mean_center_all = self_data.mean_center_all;
    lab_group_all = self_data.lab_group_all;
    SV_group_all = self_data.SV_group_all;

    n_self = size(mean_center_all, 1);
    if n_self > 0
        n_render = floor(size(lab_group_all, 1) / n_self);
    else
        n_render = 0;
    end

    for i_self = 1:n_self
        curr_row = curr_row + 1;
        name_str = string(mean_center_all{i_self, 1});
        lab_center = mean_center_all{i_self, 2};
        if size(lab_center, 1) > 1
            lab_center = mean(lab_center, 1, 'omitnan');
        end

        if n_render > 0
            idx_start = (i_self - 1) * n_render + 1;
            idx_end = min(i_self * n_render, size(lab_group_all, 1));
            lab_group = lab_group_all(idx_start:idx_end, :);
            p_group = SV_group_all(idx_start:idx_end, :);
        else
            lab_group = [];
            p_group = [];
        end

        if isempty(lab_group)
            ave_lab = NaN(1,3);
        else
            ave_lab = mean(lab_group, 1, 'omitnan');
        end

        model_id = resolve_model_id(name_str, match_table);
        if contains(lower(name_str), "female")
            model_gender = "female";
        elseif contains(lower(name_str), "male")
            model_gender = "male";
        elseif contains(model_id, "fe")
            model_gender = "female";
        else
            model_gender = "male";
        end

        info = struct();
        info.self_name = char(name_str);

        col_source{curr_row,1}               = db_source;
        col_lab_values{curr_row,1}           = lab_group;
        col_opinion_scores{curr_row,1}       = p_group;
        col_par{curr_row,1}                  = [];
        col_fit_equation{curr_row,1}         = fit_equation_str;
        col_lab_center{curr_row,1}           = lab_center;
        col_average_lab{curr_row,1}          = ave_lab;
        col_cct{curr_row,1}                  = NaN;
        col_illuminance{curr_row,1}          = NaN;
        col_scene{curr_row,1}                = "self " + name_str;
        col_lighting{curr_row,1}             = "D65";
        col_D_equation_str{curr_row,1}       = D_equation_str;
        col_model_ethnicity{curr_row,1}      = "Asian";
        col_model_gender{curr_row,1}         = model_gender;
        col_model_id{curr_row,1}             = model_id;
        col_observer_type{curr_row,1}        = "model";
        col_opinion_score_range{curr_row,1}  = "-3~3";
        col_other_info{curr_row,1}           = info;
    end
end

% 生成表（字段名与 Peggy_VIVO_table 一致）
fit_table = table( ...
    col_source, col_lab_values, col_opinion_scores, col_par, col_fit_equation, ...
    col_lab_center, col_average_lab, col_cct, col_illuminance, col_scene, col_lighting, ...
    col_D_equation_str, col_model_ethnicity, col_model_gender, col_model_id, col_observer_type, ...
    col_opinion_score_range, col_other_info, ...
    'VariableNames', { ...
        'source', 'lab_values', 'opinion_scores', 'par', 'fit_equation', ...
        'lab_center', 'average_lab', 'CCT', 'illuminance', 'scene', 'lighting', ...
        'D_equation_str', 'model_ethnicity', 'gender', 'model_id', 'observer_type', ...
        'opinion_score_range', 'other_info' ...
    } ...
);

% 导出
res_dir = fullfile(output_folder, 'resTable');
if ~exist(res_dir,'dir'); mkdir(res_dir); end
out_mat  = fullfile(res_dir, 'Peggy_OPPO_table.mat');
out_xlsx = fullfile(res_dir, 'Peggy_OPPO_table.xlsx');

save(out_mat, 'fit_table');
excel_table = summarize_for_excel_final(fit_table);
writetable(excel_table, out_xlsx, 'FileType', 'spreadsheet');

fprintf('Saved: %s\n', out_mat);
fprintf('Saved: %s\n', out_xlsx);


% -------- helper for Excel summary --------
function model_id = resolve_model_id(name_str, match_table)
model_id = "nan";
if isempty(match_table)
    return;
end
for i_match = 1:size(match_table, 1)
    col1 = string(match_table{i_match, 1});
    col3 = string(match_table{i_match, 3});
    if strcmp(name_str, col3) || strcmp(name_str, col1)
        model_id = col1;
        return;
    end
end
end

function T = summarize_for_excel_final(fit_table)
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
