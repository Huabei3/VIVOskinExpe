clc;clear;close all;
addpath("utils\")
%%


table_folder = fullfile("AnalyseResults_p","efit_p","scaled","resTable");
table_file = fullfile(table_folder, "Peggy_VIVO_table.mat");

table_data = load(table_file);

table_fields = fieldnames(table_data);
fit_table = [];
for i_field = 1:numel(table_fields)
    candidate = table_data.(table_fields{i_field});
    if istable(candidate)
        fit_table = candidate;
        break;
    end
end
if isempty(fit_table)
    error("No table found in %s", table_file);
end

required_fields = ["lab_center","CCT","illuminance","scene","model_ethnicity", ...
    "gender","model_id","observer_type"];
missing_fields = required_fields(~ismember(required_fields, fit_table.Properties.VariableNames));
if ~isempty(missing_fields)
    error("Missing required fields: %s", strjoin(missing_fields, ", "));
end

lab_center = fit_table.lab_center;
if iscell(lab_center)
    lab_center = cell2mat(lab_center);
end
if size(lab_center, 2) ~= 3
    error("lab_center must be Nx3, got %dx%d", size(lab_center, 1), size(lab_center, 2));
end

L = lab_center(:, 1);
a = lab_center(:, 2);
b = lab_center(:, 3);
C = sqrt(a.^2 + b.^2);
h = mod(atan2d(b, a) + 360, 360);
lab_ch = [L, a, b, C, h];

group_fields = ["CCT","illuminance","scene","model_ethnicity","gender","model_id","observer_type"];
min_samples = 5;
sourceFolder = fullfile("AnalyseResults_p","efit_p");
output_folder = fullfile(sourceFolder, "scaled","Lilliefors");
if ~exist(output_folder, "dir")
    mkdir(output_folder);
end

summary_rows = cell(numel(group_fields), 8);
dim45_stats_rows = cell(numel(group_fields), 15);
dim45_pct_rows = cell(numel(group_fields), 6);
for i_field = 1:numel(group_fields)
    field_name = group_fields(i_field);
    group_var = fit_table.(field_name);

    [data_cell, n_groups_used] = build_group_data(group_var, lab_ch, min_samples);
    if n_groups_used == 0
        warning("No valid groups for %s (min_samples=%d).", field_name, min_samples);
        summary_rows{i_field, 1} = char(field_name);
        summary_rows{i_field, 2} = n_groups_used;
        summary_rows{i_field, 3} = min_samples;
        summary_rows{i_field, 8} = "insufficient_data";
        dim45_stats_rows{i_field, 1} = char(field_name);
        dim45_stats_rows{i_field, 8} = "insufficient_data";
        dim45_stats_rows{i_field, 15} = "insufficient_data";
        dim45_pct_rows{i_field, 1} = char(field_name);
        dim45_pct_rows{i_field, 2} = NaN;
        dim45_pct_rows{i_field, 3} = "insufficient_data";
        dim45_pct_rows{i_field, 4} = NaN;
        dim45_pct_rows{i_field, 5} = "insufficient_data";
        dim45_pct_rows{i_field, 6} = "insufficient_data";
        continue;
    end

    [normality_results, homogeneity_results, summary_stats] = perform_lilliefors_and_homogeneity( ...
        data_cell, field_name, sourceFolder);
    method = choose_correlation_method(summary_stats);

    summary_rows{i_field, 1} = char(field_name);
    summary_rows{i_field, 2} = n_groups_used;
    summary_rows{i_field, 3} = min_samples;
    summary_rows{i_field, 4} = summary_stats.normality_p_min;
    summary_rows{i_field, 5} = summary_stats.homogeneity_p_mean;
    summary_rows{i_field, 6} = summary_stats.normality_conclusion;
    summary_rows{i_field, 7} = summary_stats.homogeneity_conclusion;
    summary_rows{i_field, 8} = method;

    dims_used = [4, 5];
    [norm_p, norm_stat] = collect_lillie_dim_values(normality_results, dims_used);
    [lev_p, lev_stat] = collect_levene_dim_values(homogeneity_results, dims_used);

    norm_p_pct = pct_lt(norm_p, 0.05);
    lev_p_pct = pct_lt(lev_p, 0.05);
    norm_conclusion = conclusion_from_pct(norm_p_pct, "normality");
    lev_conclusion = conclusion_from_pct(lev_p_pct, "homogeneity");

    dim45_stats_rows{i_field, 1} = char(field_name);
    dim45_stats_rows{i_field, 2} = safe_max(norm_p);
    dim45_stats_rows{i_field, 3} = safe_min(norm_p);
    dim45_stats_rows{i_field, 4} = safe_mean(norm_p);
    dim45_stats_rows{i_field, 5} = safe_max(norm_stat);
    dim45_stats_rows{i_field, 6} = safe_min(norm_stat);
    dim45_stats_rows{i_field, 7} = safe_mean(norm_stat);
    dim45_stats_rows{i_field, 8} = norm_conclusion;
    dim45_stats_rows{i_field, 9} = safe_max(lev_p);
    dim45_stats_rows{i_field, 10} = safe_min(lev_p);
    dim45_stats_rows{i_field, 11} = safe_mean(lev_p);
    dim45_stats_rows{i_field, 12} = safe_max(lev_stat);
    dim45_stats_rows{i_field, 13} = safe_min(lev_stat);
    dim45_stats_rows{i_field, 14} = safe_mean(lev_stat);
    dim45_stats_rows{i_field, 15} = lev_conclusion;

    dim45_pct_rows{i_field, 1} = char(field_name);
    dim45_pct_rows{i_field, 2} = norm_p_pct;
    dim45_pct_rows{i_field, 3} = norm_conclusion;
    dim45_pct_rows{i_field, 4} = lev_p_pct;
    dim45_pct_rows{i_field, 5} = lev_conclusion;
    dim45_pct_rows{i_field, 6} = recommend_test_method(n_groups_used, norm_conclusion, lev_conclusion);
end

summary_table = cell2table(summary_rows, 'VariableNames', { ...
    'field', 'n_groups_used', 'min_samples', ...
    'normality_p_min', 'homogeneity_p_mean', ...
    'normality_conclusion', 'homogeneity_conclusion', ...
    'recommended_method' ...
});
summary_file = fullfile(output_folder, "statistical_method_summary.xlsx");
writetable(summary_table, summary_file, "FileType", "spreadsheet");

dim45_stats_table = cell2table(dim45_stats_rows, 'VariableNames', { ...
    'field', ...
    'normality_p_max', 'normality_p_min', 'normality_p_mean', ...
    'normality_stat_max', 'normality_stat_min', 'normality_stat_mean', ...
    'normality_conclusion', ...
    'levene_p_max', 'levene_p_min', 'levene_p_mean', ...
    'levene_stat_max', 'levene_stat_min', 'levene_stat_mean', ...
    'levene_conclusion' ...
});
dim45_stats_file = fullfile(output_folder, "dim45_stats_summary.xlsx");
writetable(dim45_stats_table, dim45_stats_file, "FileType", "spreadsheet");

dim45_pct_table = cell2table(dim45_pct_rows, 'VariableNames', { ...
    'field', ...
    'normality_p_lt_0_05_pct', 'normality_conclusion', ...
    'levene_p_lt_0_05_pct', 'levene_conclusion', ...
    'recommended_test_method' ...
});
dim45_pct_file = fullfile(output_folder, "dim45_pct_summary.xlsx");
writetable(dim45_pct_table, dim45_pct_file, "FileType", "spreadsheet");
%%
% attributes = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
% attribute_names_new = ["Preference", "Attractiveness", "Feminine", "Cooperative", ...
%     "Youth", "Healthy", "Fidelity", "Harmony", "Fair", "Ruddy"];
% nations = ["AS", "CA", "SA", "AF", "all"];
% nation_names=["Asian","Caucasian","South Asian","African","all"];
% genders = ["female", "male"];  % 添加gender名称
% Dtype="efit_p";
% sourceFolder=fullfile('AnalyseResults_p',Dtype);
% output_folder = fullfile(sourceFolder, "Lilliefors");
% if ~exist(output_folder, "dir")
%     mkdir(output_folder);
% end
% % 定义人种对应的lastParts索引
% nation_indices = cell(5, 1);
% nation_indices{1} = 1:6;  % AS
% nation_indices{2} = 7:12; % CA  
% nation_indices{3} = 13:16; % SA
% nation_indices{4} = 17:20; % AF
% nation_indices{5} = 1:20; % all
% 
% iOrs=["i","r"];
% 
% % 初始化cens变量 - 全部改为元胞数组
% cens_ethnic = cell(4, 2); % i_nation固定时的样本点，第2列为数据
% cens_scene = cell(14, 4, 2); % i_row固定时的样本点，第3列为数据
% cens_attr = cell(10, 4, 35, 2); % i_attr,i_nation,i_row固定时的样本点，第4列为数据
% cens_obs = cell(200, 4, 35, 2); % i_obs,i_nation,i_row固定时的样本点，第4列为数据
% cens_gender1 = cell(2, 4, 35, 2); % i_gender,i_nation,i_row固定时的样本点，第4列为数据
% cens_gender2 = cell(2, 2); % i_gender固定时的样本点，第2列为数据
% 
% for i_iOr=1:2
%     iOr=iOrs(i_iOr);
%     if iOr =='i'
%         picnames_groups = ["h3k","h4k","h5k","h6k","hd65","h7k","h8k",...
%                     "m3k","m4k","m5k","m6k","md65","m7k","m8k",...
%                      "l3k","l4k","l5k","l6k","ld65","l7k","l8k"];
%     elseif iOr=='r'
%         picnames_groups = ["rs01","rs02","rs03","rs04","rs05","rs06","rs07", ...
%                  "rs08","rs09","rs10","rs11","rs12","rs13","rs14"];
%     end
% 
%     % 加载数据
%     if i_iOr == 1
%         % i数据
%         lastParts = {'f04i', 'f05i', 'f06i', 'm04i', 'm05i', 'm06i',...
%                      'f01i', 'f02i', 'f03i', 'm01i', 'm02i', 'm03i',...
%                      'f07i', 'f08i','m07i', 'm08i',...
%                      'f09i', 'f10i','m09i', 'm10i'};
%         n_para = 21;
%     else
%         % r数据
%         lastParts = {'f04r', 'f05r', 'f06r', 'm04r', 'm05r', 'm06r',...
%                      'f01r', 'f02r', 'f03r', 'm01r', 'm02r', 'm03r',...
%                      'f07r', 'f08r','m07r', 'm08r',...
%                      'f09r', 'f10r','m09r', 'm10r'};
%         n_para = 14;
%     end
% 
%     load(fullfile("ellip_pic_p\efit_p\scaled\attr", ...
%         strcat("data_reshaped_",iOr,".mat")));
% 
%     % 获取数据的维度信息
%     [n_obs, n_nation] = size(lab_fit_reshaped);
%     n_row = size(lab_fit_reshaped{1,1}, 1); % 行数
% 
%     % 遍历所有可能的组合来收集样本点
%     for i_nation = 1:4
%         for i_row = 1:n_row
%             if strcmp(iOr,"r")
%                 i_row_used = i_row + 21; % 调整索引
%             else
%                 i_row_used = i_row;
%             end
% 
%             % 获取当前人种的subject数量
%             if i_nation == 1 || i_nation == 2
%                 n_subject_nation = 6; % AS和CA有6个subject
%             else
%                 n_subject_nation = 4; % SA和AF有4个subject
%             end
% 
%             % 获取当前nation的数据维度信息
%             [temp_n_subject, temp_n_attr] = size(lab_fit_reshaped{1, i_nation});
% 
%             % 确保我们不会超出数据范围
%             actual_n_subject = min(n_subject_nation, temp_n_subject);
%             actual_n_attr = min(10, temp_n_attr); % 最多10个属性
% 
%             % 收集cens_ethnic样本点（i_nation固定）
%             ethnic_samples = [];
% 
%             for i_subject = 1:actual_n_subject
%                 lastPart=lastParts{nation_indices{i_nation}(i_subject)};
%                 for i_attr = 1:actual_n_attr
%                     for i_obs = 1:min(200, n_obs) % 限制obs数量
%                         % 检查数据是否存在
%                         if ~isempty(lab_fit_reshaped{i_obs, i_nation}) && ...
%                            size(lab_fit_reshaped{i_obs, i_nation}, 1) >= i_row && ...
%                            size(lab_fit_reshaped{i_obs, i_nation}, 3) >= i_subject && ...
%                            size(lab_fit_reshaped{i_obs, i_nation}, 4) >= i_attr
% 
%                             sample = lab_fit_reshaped{i_obs, i_nation}(i_row, :, i_subject, i_attr);
%                             if ~isempty(sample) && all(~isnan(sample))
%                                 % 生成标签
%                                 picname = picnames_groups(i_row);
%                                 nation_label = nations(i_nation);
% 
%                                 % 确定gender（根据subject编号）
%                                 if i_subject <= n_subject_nation/2
%                                     i_gender = 1; % 前一半为female
%                                     gender_label = genders(1);
%                                 else
%                                     i_gender = 2; % 后一半为male
%                                     gender_label = genders(2);
%                                 end
% 
%                                 % 添加到cens_ethnic
%                                 ethnic_samples = [ethnic_samples; sample];
% 
%                                 % ========== cens_scene ==========
%                                 if strcmp(iOr,"r")
%                                     label_scene = strcat("obs", num2str(i_obs),attr_name,  nation_label, lastPart, picname);
%                                     if isempty(cens_scene{i_row, i_nation, 2})
%                                         cens_scene{i_row, i_nation, 1} = {label_scene};
%                                         cens_scene{i_row, i_nation, 2} = sample;
%                                     else
%                                         % 检查标签是否已存在
%                                         existing_labels = cens_scene{i_row, i_nation, 1};
%                                         if ~any(strcmp(existing_labels, label_scene))
%                                             cens_scene{i_row, i_nation, 1} = [cens_scene{i_row, i_nation, 1}; {label_scene}];
%                                             cens_scene{i_row, i_nation, 2} = [cens_scene{i_row, i_nation, 2}; sample];
%                                         end
%                                     end
%                                 end
% 
%                                 % ========== cens_attr ==========
%                                 attr_name = attribute_names_new(i_attr);
% 
%                                 label_attr = strcat("obs", num2str(i_obs),attr_name,  nation_label, lastPart, picname);
%                                 if isempty(cens_attr{i_attr, i_nation, i_row_used, 2})
%                                     cens_attr{i_attr, i_nation, i_row_used, 1} = {label_attr};
%                                     cens_attr{i_attr, i_nation, i_row_used, 2} = sample;
%                                 else
%                                     existing_labels = cens_attr{i_attr, i_nation, i_row_used, 1};
%                                     if ~any(strcmp(existing_labels, label_attr))
%                                         cens_attr{i_attr, i_nation, i_row_used, 1} = [cens_attr{i_attr, i_nation, i_row_used, 1}; {label_attr}];
%                                         cens_attr{i_attr, i_nation, i_row_used, 2} = [cens_attr{i_attr, i_nation, i_row_used, 2}; sample];
%                                     end
%                                 end
% 
%                                 % ========== cens_obs ==========
%                                 label_obs = strcat("obs", num2str(i_obs), attr_name, nation_label, lastPart,picname);
%                                 if isempty(cens_obs{i_obs, i_nation, i_row_used, 2})
%                                     cens_obs{i_obs, i_nation, i_row_used, 1} = {label_obs};
%                                     cens_obs{i_obs, i_nation, i_row_used, 2} = sample;
%                                 else
%                                     existing_labels = cens_obs{i_obs, i_nation, i_row_used, 1};
%                                     if ~any(strcmp(existing_labels, label_obs))
%                                         cens_obs{i_obs, i_nation, i_row_used, 1} = [cens_obs{i_obs, i_nation, i_row_used, 1}; {label_obs}];
%                                         cens_obs{i_obs, i_nation, i_row_used, 2} = [cens_obs{i_obs, i_nation, i_row_used, 2}; sample];
%                                     end
%                                 end
% 
%                                 % ========== cens_gender1 ==========
%                                 label_gender1 = strcat(gender_label, "obs", num2str(i_obs), attr_name, nation_label, lastPart, picname);
%                                 if isempty(cens_gender1{i_gender, i_nation, i_row_used, 2})
%                                     cens_gender1{i_gender, i_nation, i_row_used, 1} = {label_gender1};
%                                     cens_gender1{i_gender, i_nation, i_row_used, 2} = sample;
%                                 else
%                                     existing_labels = cens_gender1{i_gender, i_nation, i_row_used, 1};
%                                     if ~any(strcmp(existing_labels, label_gender1))
%                                         cens_gender1{i_gender, i_nation, i_row_used, 1} = [cens_gender1{i_gender, i_nation, i_row_used, 1}; {label_gender1}];
%                                         cens_gender1{i_gender, i_nation, i_row_used, 2} = [cens_gender1{i_gender, i_nation, i_row_used, 2}; sample];
%                                     end
%                                 end
% 
%                                 % ========== cens_gender2 ==========
%                                 label_gender2 = gender_label;
%                                 if isempty(cens_gender2{i_gender, 2})
%                                     cens_gender2{i_gender, 1} = {label_gender2};
%                                     cens_gender2{i_gender, 2} = sample;
%                                 else
%                                     existing_labels = cens_gender2{i_gender, 1};
%                                     if ~any(strcmp(existing_labels, label_gender2))
%                                         cens_gender2{i_gender, 1} = [cens_gender2{i_gender, 1}; {label_gender2}];
%                                         cens_gender2{i_gender, 2} = [cens_gender2{i_gender, 2}; sample];
%                                     end
%                                 end
%                             end
%                         end
%                     end
%                 end
%             end
% 
%             % 将收集的样本点添加到cens_ethnic
%             label_ethnic = nations(i_nation);
%             if isempty(cens_ethnic{i_nation, 2})
%                 cens_ethnic{i_nation, 1} = {label_ethnic};
%                 cens_ethnic{i_nation, 2} = ethnic_samples;
%             else
%                 % 检查标签是否已存在
%                 existing_labels = cens_ethnic{i_nation, 1};
%                 if ~any(strcmp(existing_labels, label_ethnic))
%                     cens_ethnic{i_nation, 1} = [cens_ethnic{i_nation, 1}; {label_ethnic}];
%                     cens_ethnic{i_nation, 2} = [cens_ethnic{i_nation, 2}; ethnic_samples];
%                 end
%             end
%         end
%     end
% end
% 
% %% 验证数据结构
% fprintf('数据结构验证:\n');
% fprintf('cens_ethnic: %d×%d元胞数组\n', size(cens_ethnic, 1), size(cens_ethnic, 2));
% fprintf('cens_scene: %d×%d×%d元胞数组\n', size(cens_scene, 1), size(cens_scene, 2), size(cens_scene, 3));
% fprintf('cens_attr: %d×%d×%d×%d元胞数组\n', size(cens_attr, 1), size(cens_attr, 2), size(cens_attr, 3), size(cens_attr, 4));
% fprintf('cens_obs: %d×%d×%d×%d元胞数组\n', size(cens_obs, 1), size(cens_obs, 2), size(cens_obs, 3), size(cens_obs, 4));
% fprintf('cens_gender1: %d×%d×%d×%d元胞数组\n', size(cens_gender1, 1), size(cens_gender1, 2), size(cens_gender1, 3), size(cens_gender1, 4));
% fprintf('cens_gender2: %d×%d元胞数组\n', size(cens_gender2, 1), size(cens_gender2, 2));
% 
% %% 显示示例
% fprintf('\n示例 - cens_gender1(1,1,1):\n');
% if ~isempty(cens_gender1{1,1,1,1})
%     fprintf('标签: %s\n', cens_gender1{1,1,1,1}{1});
%     fprintf('数据大小: %d×%d\n', size(cens_gender1{1,1,1,2}, 1), size(cens_gender1{1,1,1,2}, 2));
% end
% 
% fprintf('\n示例 - cens_ethnic(1):\n');
% if ~isempty(cens_ethnic{1,1})
%     fprintf('标签: %s\n', cens_ethnic{1,1}{1});
%     fprintf('数据大小: %d×%d\n', size(cens_ethnic{1,2}, 1), size(cens_ethnic{1,2}, 2));
% end
% 
% %% 保存数据
% save(fullfile(output_folder,'cens_data_with_labels.mat'), ...
%     'cens_ethnic', 'cens_scene', 'cens_attr', 'cens_obs', 'cens_gender1', 'cens_gender2', ...
%     'genders', 'nations', 'picnames_groups', 'attribute_names_new');
% 
% fprintf('\n数据已保存到 cens_data_with_labels.mat\n');
% %%
% % clc;clear;close all;
% % addpath("utils\")
% % 
% % %%
% % attributes = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
% % attribute_names_new = ["Preference", "Attractiveness", "Feminine", "Cooperative", ...
% %     "Youth", "Healthy", "Fidelity", "Harmony", "Fair", "Ruddy"];
% % nations = ["AS", "CA", "SA", "AF", "all"];
% % nation_names=["Asian","Caucasian","South Asian","African","all"];
% % % 定义人种对应的lastParts索引
% % nation_indices = cell(5, 1); % 5个人种（包括"all"）
% % % AS (Asian): f04i, f05i, f06i, m04i, m05i, m06i (索引1-6)
% % nation_indices{1} = 1:6;
% % % CA (Caucasian): f01i, f02i, f03i, m01i, m02i, m03i (索引7-12)  
% % nation_indices{2} = 7:12;
% % % SA (South Asian): f07i, f08i, m07i, m08i (索引13-16)
% % nation_indices{3} = 13:16;
% % % AF (African): f09i, f10i, m09i, m10i (索引17-20)
% % nation_indices{4} = 17:20;
% % % all: 所有索引 (索引1-20)
% % nation_indices{5} = 1:20;
% % 
% % iOrs=["i","r"];
% % 
% % % 初始化cens变量
% % cens_ethnic = cell(4, 1); % i_nation固定时的样本点
% % cens_scene = cell(14, 4); % i_row固定时的样本点 (行: i_row, 列: i_nation)
% % cens_attr = cell(10, 4, 35); % i_attr,i_nation,i_row固定时的样本点
% % cens_obs = cell(200, 4, 35); % i_obs,i_nation,i_row固定时的样本点
% % cens_gender1 = cell(2, 4, 35); % i_gender,i_nation,i_row固定时的样本点
% % cens_gender2 = cell(2, 1); % i_gender固定时的样本点
% % 
% % for i_iOr=1:2
% %     iOr=iOrs(i_iOr);
% %     if iOr =='i'
% %     picnames_groups = ["h3k","h4k","h5k","h6k","hd65","h7k","h8k",...
% %                     "m3k","m4k","m5k","m6k","md65","m7k","m8k",...
% %                      "l3k","l4k","l5k","l6k","ld65","l7k","l8k"];
% %     elseif iOr=='r'
% %         picnames_groups = ["rs01","rs02","rs03","rs04","rs05","rs06","rs07", ...
% %                  "rs08","rs09","rs10","rs11","rs12","rs13","rs14"];
% %     end
% %     % 加载数据
% %     if i_iOr == 1
% %         % i数据
% %         lastParts = {'f04i', 'f05i', 'f06i', 'm04i', 'm05i', 'm06i',...
% %                      'f01i', 'f02i', 'f03i', 'm01i', 'm02i', 'm03i',...
% %                      'f07i', 'f08i','m07i', 'm08i',...
% %                      'f09i', 'f10i','m09i', 'm10i'};
% %         n_para = 21;
% %     else
% %         % r数据
% %         lastParts = {'f04r', 'f05r', 'f06r', 'm04r', 'm05r', 'm06r',...
% %                      'f01r', 'f02r', 'f03r', 'm01r', 'm02r', 'm03r',...
% %                      'f07r', 'f08r','m07r', 'm08r',...
% %                      'f09r', 'f10r','m09r', 'm10r'};
% %         n_para = 14;
% %     end
% % 
% %     load(fullfile("ellip_pic_p\efit_p\scaled\attr", ...
% %         strcat("data_reshaped_",iOr,".mat")));
% % 
% %     % 获取数据的维度信息
% %     [n_obs, n_nation] = size(lab_fit_reshaped);
% %     n_row = size(lab_fit_reshaped{1,1}, 1); % 行数
% %     n_col = size(lab_fit_reshaped{1,1}, 2); % 列数（应该是n_para）
% % 
% %     % 遍历所有可能的组合来收集样本点
% %     for i_nation = 1:4
% %         for i_row = 1:n_row
% %             if strcmp(iOr,"r")
% %                 i_row_used=i_row+21;
% %             else
% %                 i_row_used=i_row;
% %             end
% %             % 获取当前人种的subject数量
% %             if i_nation == 1 || i_nation == 2
% %                 n_subject_nation = 6; % AS和CA有6个subject
% %             else
% %                 n_subject_nation = 4; % SA和AF有4个subject
% %             end
% % 
% %             % 获取当前nation的数据维度信息
% %             [temp_n_subject, temp_n_attr] = size(lab_fit_reshaped{1, i_nation});
% % 
% %             % 确保我们不会超出数据范围
% %             actual_n_subject = min(n_subject_nation, temp_n_subject);
% %             actual_n_attr = min(10, temp_n_attr); % 最多10个属性
% % 
% %             % 收集cens_ethnic样本点（i_nation固定）
% %             ethnic_samples = [];
% % 
% %             for i_subject = 1:actual_n_subject
% %                 for i_attr = 1:actual_n_attr
% %                     for i_obs = 1:min(200, n_obs) % 限制obs数量
% %                         % 检查数据是否存在
% %                         if ~isempty(lab_fit_reshaped{i_obs, i_nation}) && ...
% %                            size(lab_fit_reshaped{i_obs, i_nation}, 1) >= i_row && ...
% %                            size(lab_fit_reshaped{i_obs, i_nation}, 3) >= i_subject && ...
% %                            size(lab_fit_reshaped{i_obs, i_nation}, 4) >= i_attr
% % 
% %                             sample = lab_fit_reshaped{i_obs, i_nation}(i_row, :, i_subject, i_attr);
% %                             if ~isempty(sample) && all(~isnan(sample))
% %                                 % 添加到cens_ethnic
% %                                 ethnic_samples = [ethnic_samples; sample];
% % 
% %                                 % 添加到cens_scene（i_row,i_nation固定）
% %                                 if strcmp(iOr,"r")
% %                                     if isempty(cens_scene{i_row, i_nation})
% %                                         cens_scene{i_row, i_nation} = sample;
% %                                     else
% %                                         cens_scene{i_row, i_nation} = [cens_scene{i_row, i_nation}; sample];
% %                                     end
% %                                 end
% % 
% %                                 % 添加到cens_attr（i_attr,i_nation,i_row固定）
% %                                 if isempty(cens_attr{i_attr, i_nation, i_row_used})
% %                                     cens_attr{i_attr, i_nation, i_row_used} = sample;
% %                                 else
% %                                     cens_attr{i_attr, i_nation, i_row_used} = [cens_attr{i_attr, i_nation, i_row}; sample];
% %                                 end
% % 
% %                                 % 添加到cens_obs（i_obs,i_nation,i_row固定）
% %                                 if isempty(cens_obs{i_obs, i_nation, i_row})
% %                                     cens_obs{i_obs, i_nation, i_row_used} = sample;
% %                                 else
% %                                     cens_obs{i_obs, i_nation, i_row_used} = [cens_obs{i_obs, i_nation, i_row}; sample];
% %                                 end
% % 
% %                                 % 确定gender（根据subject编号）
% %                                 if i_subject <= n_subject_nation/2
% %                                     i_gender = 1; % 前一半为gender 1
% %                                 else
% %                                     i_gender = 2; % 后一半为gender 2
% %                                 end
% % 
% %                                 % 添加到cens_gender1（i_gender,i_nation,i_row固定）
% %                                 if isempty(cens_gender1{i_gender, i_nation, i_row_used})
% %                                     cens_gender1{i_gender, i_nation, i_row_used} = sample;
% %                                 else
% %                                     cens_gender1{i_gender, i_nation, i_row_used} = [cens_gender1{i_gender, i_nation, i_row}; sample];
% %                                 end
% % 
% %                                 % 添加到cens_gender2（i_gender固定）
% %                                 if isempty(cens_gender2{i_gender})
% %                                     cens_gender2{i_gender} = sample;
% %                                 else
% %                                     cens_gender2{i_gender} = [cens_gender2{i_gender}; sample];
% %                                 end
% %                             end
% %                         end
% %                     end
% %                 end
% %             end
% % 
% %             % 将收集的样本点添加到cens_ethnic
% %             cens_ethnic{i_nation} = ethnic_samples;
% %         end
% %     end
% % end
% % 
% % % 所有要分析的变量
% % all_cens = {cens_ethnic, cens_scene, cens_attr, cens_obs, cens_gender1, cens_gender2};
% % all_labels = {"cens_ethnic", "cens_scene", "cens_attr", "cens_obs", "cens_gender1", "cens_gender2"};
% % num_vars = length(all_labels);
% % 
% % % 显示各个cens变量的大小信息
% % fprintf('各个cens变量的信息:\n');
% % for i = 1:num_vars
% %     fprintf('%s: ', all_labels{i});
% %     if i == 1 % cens_ethnic
% %         for j = 1:4
% %             if ~isempty(all_cens{i}{j})
% %                 fprintf('nation%d有%d个样本点; ', j, size(all_cens{i}{j}, 1));
% %             end
% %         end
% %     elseif i == 2 % cens_scene
% %         total_samples = 0;
% %         for row = 1:8
% %             for col = 1:4
% %                 if ~isempty(all_cens{i}{row, col})
% %                     total_samples = total_samples + size(all_cens{i}{row, col}, 1);
% %                 end
% %             end
% %         end
% %         fprintf('总样本数: %d\n', total_samples);
% %     else
% %         fprintf('已填充\n');
% %     end
% %     fprintf('\n');
% % end
% %%
% 
% 
% %% 所有要分析的变量
% all_cens = {cens_ethnic, cens_scene, cens_attr,  cens_obs,cens_gender1,cens_gender2};
% all_labels = {"ethnic", "scene", "attr",  "obs","gender1","gender2"};
% num_vars = length(all_labels);
% 
% % 存储所有检验结果的汇总
% summary_table = cell(6, num_vars + 1);  % 6行：维度数 + 5个统计量，列：标签+值
% 
% %% 对每个变量进行正态性和方差齐性检验
% for var_idx = 1:num_vars
%     cens_used = all_cens{var_idx};
%     label = all_labels{var_idx};
% 
%     fprintf('\n=== 分析变量: %s ===\n', label);
% 
%     % 调用正态性和方差齐性检验函数
%     [normality_results, homogeneity_results, summary_stats] = ...
%         perform_lilliefors_and_homogeneity(cens_used, label, sourceFolder);
% 
%     % 构建汇总表
%     if var_idx == 1
%         % 第一列：统计指标
%         summary_table{1, 1} = '统计指标';
%         summary_table{2, 1} = '正态性检验P最小值';
%         summary_table{3, 1} = '正态性检验P最大值';
%         summary_table{4, 1} = '正态性检验P平均值';
%         summary_table{5, 1} = '正态性检验结论';
%         summary_table{6, 1} = '方差齐性检验P最小值';
%         summary_table{7, 1} = '方差齐性检验P最大值';
%         summary_table{8, 1} = '方差齐性检验P平均值';
%         summary_table{9, 1} = '方差齐性检验结论';
%     end
% 
%     % 填充数据
%     summary_table{1, var_idx+1} = label;  % 列标题
% 
%     % 正态性检验结果
%     summary_table{2, var_idx+1} = summary_stats.normality_p_min;
%     summary_table{3, var_idx+1} = summary_stats.normality_p_max;
%     summary_table{4, var_idx+1} = summary_stats.normality_p_mean;
%     summary_table{5, var_idx+1} = summary_stats.normality_conclusion;
% 
%     % 方差齐性检验结果
%     summary_table{6, var_idx+1} = summary_stats.homogeneity_p_min;
%     summary_table{7, var_idx+1} = summary_stats.homogeneity_p_max;
%     summary_table{8, var_idx+1} = summary_stats.homogeneity_p_mean;
%     summary_table{9, var_idx+1} = summary_stats.homogeneity_conclusion;
% 
%     fprintf('  正态性: %s (P范围: %.4f-%.4f, 平均: %.4f)\n', ...
%         summary_stats.normality_conclusion, ...
%         summary_stats.normality_p_min, ...
%         summary_stats.normality_p_max, ...
%         summary_stats.normality_p_mean);
% 
%     fprintf('  方差齐性: %s (P范围: %.4f-%.4f, 平均: %.4f)\n', ...
%         summary_stats.homogeneity_conclusion, ...
%         summary_stats.homogeneity_p_min, ...
%         summary_stats.homogeneity_p_max, ...
%         summary_stats.homogeneity_p_mean);
% end
% 
% %% 保存汇总表到Excel
% 
% 
% summary_filename = fullfile(output_folder, 'all_variables_summary.xlsx');
% 
% % 创建工作簿
% writecell(summary_table, summary_filename, 'Sheet', '汇总统计');
% 
% % 添加格式说明
% format_table = {
%     '统计指标说明:', '', '';
%     '正态性检验P最小值', '所有组和维度中正态性检验的最小P值', 'P<0.05表示不满足正态性';
%     '正态性检验P最大值', '所有组和维度中正态性检验的最大P值', 'P越大越可能满足正态性';
%     '正态性检验P平均值', '所有组和维度中正态性检验的平均P值', '平均值>0.05通常认为基本满足正态性';
%     '正态性检验结论', '基于平均P值的判断', '满足/不满足/部分满足';
%     '方差齐性检验P最小值', '所有维度方差齐性检验的最小P值', 'P<0.05表示方差不齐';
%     '方差齐性检验P最大值', '所有维度方差齐性检验的最大P值', 'P越大越可能满足方差齐性';
%     '方差齐性检验P平均值', '所有维度方差齐性检验的平均P值', '平均值>0.05通常认为满足方差齐性';
%     '方差齐性检验结论', '基于平均P值的判断', '满足/不满足/部分满足';
%     '', '', '';
%     '判断标准:', '', '';
%     'P值>0.05', '接受原假设', '';
%     'P值≤0.05', '拒绝原假设', '';
% };
% 
% writecell(format_table, summary_filename, 'Sheet', '说明');
% 
% fprintf('\n=== 所有变量分析完成 ===\n');
% fprintf('汇总表已保存到: %s\n', summary_filename);
% 
% %% 显示汇总表
% fprintf('\n=== 所有变量检验结果汇总 ===\n');
% disp("d");
%%
% 
% Dtype = "efit_p";
% lightness_type="rela";
% rgb2xyz_type="display";
% if strcmp(Dtype,"efit_p")
%     sourceFolder=fullfile('AnalyseResults_p',rgb2xyz_type,lightness_type);
% else
%     sourceFolder='AnalyseResults';
% end
% load(fullfile(sourceFolder,"data_for_Lilliefors.mat"), ...
%     "cens_model","cens_makeup","cens_scene","cens_gender","cens_self");
% % cens_used=cens_gender;label="gender";
% % cens_used=cens_scene;label="scene";
% % cens_used=cens_makeup;label="makeup";
% % cens_used=cens_model;label="model";
% cens_used=cens_self;label="self";
% n=size(cens_used,1);
% for i_type=1:n
%     data{i_type}=cens_used{i_type,1};
% end
% 
% 
% % n=size(cens_used,1);
% % for i_type=3:n
% %     data{i_type-2}=cens_used{i_type,1};
% % end
% %% Lilliefors正态性检验
% disp('=== Lilliefors正态性检验 ===');
% lillie_results = cell(n, 6);  % 存储结果：组号、维度、H值、P值、统计量、结论
% 
% for group = 1:n
%     current_data = data{group};
%     [num_samples, num_dimensions] = size(current_data);
% 
%     fprintf('\n第%d组数据（%d个样本）：\n', group, num_samples);
% 
%     for dim = 1:num_dimensions
%         % 提取当前维度的数据
%         dim_data = current_data(:, dim);
% 
%         % Lilliefors检验（改进的Kolmogorov-Smirnov检验）
%         [h, p, kstat] = lillietest(dim_data, 'Alpha', 0.05);
% 
%         % 判断结论
%         if h == 0
%             conclusion = '服从正态分布';
%         else
%             conclusion = '不服从正态分布';
%         end
% 
%         % 存储结果
%         lillie_results{(group-1)*num_dimensions + dim, 1} = ['Group ', num2str(group)];
%         lillie_results{(group-1)*num_dimensions + dim, 2} = ['Dim ', num2str(dim)];
%         lillie_results{(group-1)*num_dimensions + dim, 3} = h;
%         lillie_results{(group-1)*num_dimensions + dim, 4} = p;
%         lillie_results{(group-1)*num_dimensions + dim, 5} = kstat;
%         lillie_results{(group-1)*num_dimensions + dim, 6} = conclusion;
% 
%         % 显示结果
%         fprintf('  维度%d: H=%d, p=%.4f, 统计量=%.4f - %s\n', ...
%                 dim, h, p, kstat, conclusion);
%     end
% end
% 
% %% 方差齐性检验
% disp('=== 方差齐性检验 ===');
% % 准备数据用于方差齐性检验
% variance_data = cell(1, num_dimensions);
% group_labels = cell(1, num_dimensions);
% 
% for dim = 1:num_dimensions
%     dim_all_data = [];
%     dim_labels = [];
% 
%     for group = 1:n
%         current_data = data{group};
%         dim_data = current_data(:, dim);
%         dim_all_data = [dim_all_data; dim_data];
%         dim_labels = [dim_labels; group * ones(size(dim_data))];
%     end
% 
%     variance_data{dim} = dim_all_data;
%     group_labels{dim} = dim_labels;
% end
% 
% % 执行方差齐性检验
% vartest_results = cell(num_dimensions, 5);  % 存储结果：维度、检验方法、P值、统计量、结论
% 
% for dim = 1:num_dimensions
%     fprintf('\n维度%d的方差齐性检验：\n', dim);
% 
%     % Bartlett检验（要求数据服从正态分布）
%     try
%         [p_bartlett, tbl_bartlett, stats_bartlett] = vartestn(variance_data{dim}, group_labels{dim}, ...
%                                                             'Display', 'off', 'TestType', 'Bartlett');
%         bartlett_stat = tbl_bartlett{2, 5};  % 卡方统计量
%     catch
%         p_bartlett = NaN;
%         bartlett_stat = NaN;
%     end
% 
%     % Levene检验（对非正态数据更稳健）
%     [p_levene, tbl_levene] = vartestn(variance_data{dim}, group_labels{dim}, ...
%                                                    'Display', 'off', 'TestType', 'LeveneAbsolute');
%     levene_stat = tbl_levene.fstat;  % F统计量
% 
%     % 判断结论（使用Levene检验的结果）
%     if p_levene > 0.05
%         conclusion = '方差齐性';
%     else
%         conclusion = '方差不齐';
%     end
% 
%     % 存储结果
%     vartest_results{dim, 1} = ['Dim ', num2str(dim)];
%     vartest_results{dim, 2} = 'Bartlett检验';
%     vartest_results{dim, 3} = p_bartlett;
%     vartest_results{dim, 4} = bartlett_stat;
%     vartest_results{dim, 5} = conclusion;
% 
%     vartest_results{dim+num_dimensions, 1} = ['Dim ', num2str(dim)];
%     vartest_results{dim+num_dimensions, 2} = 'Levene检验';
%     vartest_results{dim+num_dimensions, 3} = p_levene;
%     vartest_results{dim+num_dimensions, 4} = levene_stat;
%     vartest_results{dim+num_dimensions, 5} = conclusion;
% 
%     % 显示结果
%     fprintf('  Bartlett检验: p=%.4f, 统计量=%.4f\n', p_bartlett, bartlett_stat);
%     fprintf('  Levene检验: p=%.4f, 统计量=%.4f\n', p_levene, levene_stat);
%     fprintf('  结论: %s\n', conclusion);
% end
% 
% %% 创建汇总统计表
% disp('=== 创建汇总统计表 ===');
% summary_results = cell(n*num_dimensions + 1, 7);
% summary_results{1, 1} = '组别';
% summary_results{1, 2} = '维度';
% summary_results{1, 3} = '样本数';
% summary_results{1, 4} = '均值';
% summary_results{1, 5} = '标准差';
% summary_results{1, 6} = '正态性(P值)';
% summary_results{1, 7} = '方差齐性(Levene P值)';
% 
% row_idx = 2;
% for group = 1:n
%     current_data = data{group};
%     [num_samples, ~] = size(current_data);
% 
%     for dim = 1:num_dimensions
%         dim_data = current_data(:, dim);
% 
%         % 获取对应的检验结果
%         lillie_idx = (group-1)*num_dimensions + dim;
%         levene_p = vartest_results{dim+num_dimensions, 3};
% 
%         summary_results{row_idx, 1} = ['Group ', num2str(group)];
%         summary_results{row_idx, 2} = ['Dim ', num2str(dim)];
%         summary_results{row_idx, 3} = num_samples;
%         summary_results{row_idx, 4} = mean(dim_data);
%         summary_results{row_idx, 5} = std(dim_data);
%         summary_results{row_idx, 6} = lillie_results{lillie_idx, 4};  % Lilliefors P值
%         summary_results{row_idx, 7} = levene_p;
% 
%         row_idx = row_idx + 1;
%     end
% end
% 
% %% 输出结果到Excel
% disp('=== 输出结果到Excel文件 ===');
% 
% % 创建输出文件名（带时间戳避免覆盖）
% output_folder=fullfile(sourceFolder,"Lilliefors");
% if ~exist(output_folder,"dir")
%     mkdir(output_folder);
% end
% output_filename = fullfile(output_folder, ...
%     strcat('statistical_analysis_',label,'.xlsx'));
% 
% % 写入Lilliefors检验结果
% lillie_header = {'组别', '维度', 'H值', 'P值', '统计量', '结论'};
% xlswrite(output_filename, lillie_header, '正态性检验', 'A1');
% xlswrite(output_filename, lillie_results, '正态性检验', 'A2');
% 
% % 写入方差齐性检验结果
% vartest_header = {'维度', '检验方法', 'P值', '统计量', '结论'};
% xlswrite(output_filename, vartest_header, '方差齐性检验', 'A1');
% xlswrite(output_filename, vartest_results, '方差齐性检验', 'A2');
% 
% % 写入汇总统计表
% xlswrite(output_filename, summary_results, '汇总统计', 'A1');
% 
% 
% fprintf('\n=== 分析完成 ===\n');
% fprintf('结果已保存到文件: %s\n', output_filename);
% fprintf('包含以下工作表：\n');
% fprintf('  1. 正态性检验 - Lilliefors检验结果\n');
% fprintf('  2. 方差齐性检验 - Bartlett和Levene检验结果\n');
% fprintf('  3. 汇总统计 - 描述性统计和检验P值汇总\n');
% 
% %% 可选：显示数据预览
% disp(' ');
% disp('数据预览（前3行）：');
% for group = 1:min(n, 3)
%     fprintf('第%d组数据（前3行）:\n', group);
%     disp(data{group}(1:min(3, size(data{group}, 1)), :));
% end

function [data_cell, n_groups_used] = build_group_data(group_var, lab_ch, min_samples)
valid = ~any(isnan(lab_ch), 2) & ~ismissing(group_var);
group_var = group_var(valid);
lab_ch = lab_ch(valid, :);

if iscell(group_var)
    group_var = string(group_var);
end

[G, ~] = findgroups(group_var);
n_groups = max(G);
data_cell = cell(0, 1);
if n_groups == 0
    n_groups_used = 0;
    return;
end

keep = 0;
for g = 1:n_groups
    idx = (G == g);
    if sum(idx) < min_samples
        continue;
    end
    keep = keep + 1;
    data_cell{keep, 1} = lab_ch(idx, :);
end
n_groups_used = keep;
end

function method = choose_correlation_method(summary_stats)
if summary_stats.normality_p_min > 0.05 && summary_stats.homogeneity_p_mean > 0.05
    method = "pearson_or_parametric";
else
    method = "spearman_or_nonparametric";
end
end

function [p_vals, stat_vals] = collect_lillie_dim_values(normality_results, dims)
p_vals = [];
stat_vals = [];
for i = 1:size(normality_results, 1)
    dim_num = parse_dim_label(normality_results{i, 2});
    if ismember(dim_num, dims)
        p = normality_results{i, 4};
        stat = normality_results{i, 5};
        p_vals = [p_vals; p];
        stat_vals = [stat_vals; stat];
    end
end
end

function [p_vals, stat_vals] = collect_levene_dim_values(homogeneity_results, dims)
p_vals = [];
stat_vals = [];
n_rows = size(homogeneity_results, 1);
if n_rows == 0
    return;
end
num_dimensions = floor(n_rows / 2);
for d = dims
    if d <= num_dimensions
        row = num_dimensions + d;
        p_vals = [p_vals; homogeneity_results{row, 3}];
        stat_vals = [stat_vals; homogeneity_results{row, 4}];
    end
end
end

function dim_num = parse_dim_label(dim_label)
dim_num = NaN;
try
    token = regexp(string(dim_label), '\d+', 'match', 'once');
    if ~isempty(token)
        dim_num = str2double(token);
    end
catch
    dim_num = NaN;
end
end

function pct = pct_lt(values, threshold)
values = values(~isnan(values));
if isempty(values)
    pct = NaN;
else
    pct = sum(values < threshold) / numel(values) * 100;
end
end

function conclusion = conclusion_from_pct(pct, kind)
if isnan(pct)
    conclusion = "insufficient_data";
    return;
end
if pct > 5
    if strcmp(kind, "normality")
        conclusion = "not_normal";
    else
        conclusion = "not_homogeneous";
    end
else
    if strcmp(kind, "normality")
        conclusion = "normal";
    else
        conclusion = "homogeneous";
    end
end
end

function method = recommend_test_method(n_groups_used, normality_conclusion, homogeneity_conclusion)
if n_groups_used < 2
    method = "insufficient_groups";
    return;
end
if normality_conclusion == "insufficient_data" || homogeneity_conclusion == "insufficient_data"
    method = "insufficient_data";
    return;
end

is_normal = (normality_conclusion == "normal");
is_homo = (homogeneity_conclusion == "homogeneous");

if n_groups_used == 2
    if ~is_normal
        method = "Mann-Whitney U";
    elseif is_homo
        method = "t-test";
    else
        method = "improved t-test";
    end
else
    if ~is_normal
        method = "Kruskal-Wallis";
    elseif is_homo
        method = "ANOVA";
    else
        method = "improved ANOVA";
    end
end
end

function v = safe_max(values)
values = values(~isnan(values));
if isempty(values)
    v = NaN;
else
    v = max(values);
end
end

function v = safe_min(values)
values = values(~isnan(values));
if isempty(values)
    v = NaN;
else
    v = min(values);
end
end

function v = safe_mean(values)
values = values(~isnan(values));
if isempty(values)
    v = NaN;
else
    v = mean(values);
end
end
