clc;clear;close all;
addpath("utils\")
%%

table_folder = fullfile("AnalyseResults_p","efit_p","resTable");
table_file = fullfile(table_folder, "Peggy_VIVO_table.mat");
if ~exist(table_file, "file")
    table_folder = fullfile("AnalyseResults_p","efit_p","scaled","resTable");
    table_file = fullfile(table_folder, "Peggy_VIVO_table.mat");
end
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
dim_names = ["L","a","b","C","h"];

kw_fields = ["CCT","illuminance","scene","model_ethnicity","model_id"];
mwu_fields = ["gender","observer_type"];

output_folder = fullfile("AnalyseResults_p","efit_p","t_test");
if ~exist(output_folder, "dir")
    mkdir(output_folder);
end
output_file = fullfile(output_folder, "nonparametric_tests.xlsx");

results = cell(0, 10);
row = 0;

for i_field = 1:numel(kw_fields)
    field_name = kw_fields(i_field);
    group_var = fit_table.(field_name);
    [group_var, lab_ch_filtered] = filter_groups(group_var, lab_ch);

    for dim = 1:5
        y = lab_ch_filtered(:, dim);
        [y, group_dim] = filter_by_dim(y, group_var);
        [p, stat, stat_name, note, n_groups] = run_kruskalwallis(y, group_dim);
        row = row + 1;
        results(row, :) = {char(field_name), "Kruskal-Wallis", char(dim_names(dim)), ...
            n_groups, numel(y), strjoin(string(unique(group_dim)), ";"), ...
            stat_name, stat, p, note};
    end
end

for i_field = 1:numel(mwu_fields)
    field_name = mwu_fields(i_field);
    group_var = fit_table.(field_name);
    [group_var, lab_ch_filtered] = filter_groups(group_var, lab_ch);

    for dim = 1:5
        y = lab_ch_filtered(:, dim);
        [y, group_dim] = filter_by_dim(y, group_var);
        [p, stat, stat_name, note, n_groups] = run_mannwhitney(y, group_dim);
        row = row + 1;
        results(row, :) = {char(field_name), "Mann-Whitney U", char(dim_names(dim)), ...
            n_groups, numel(y), strjoin(string(unique(group_dim)), ";"), ...
            stat_name, stat, p, note};
    end
end

results_table = cell2table(results, 'VariableNames', { ...
    'field','test','dimension','n_groups','n_total','group_names', ...
    'statistic_name','statistic','p_value','note' ...
});
writetable(results_table, output_file, "FileType", "spreadsheet");

disp(output_file);

function [group_var, lab_ch_filtered] = filter_groups(group_var, lab_ch)
if iscell(group_var)
    group_var = string(group_var);
end
if ischar(group_var)
    group_var = string(group_var);
end

valid = ~ismissing(group_var);
if isnumeric(group_var)
    valid = valid & ~isnan(group_var);
end
valid = valid & ~any(isnan(lab_ch), 2);

group_var = group_var(valid);
lab_ch_filtered = lab_ch(valid, :);

if isstring(group_var) || iscellstr(group_var)
    group_var = categorical(group_var);
end
end

function [y, group_var] = filter_by_dim(y, group_var)
valid = ~isnan(y);
y = y(valid);
group_var = group_var(valid);
end

function [p, stat, stat_name, note, n_groups] = run_kruskalwallis(y, group_var)
note = "";
stat_name = "chi2";
groups = unique(group_var);
n_groups = numel(groups);

if n_groups < 2 || numel(y) < 2
    p = NaN;
    stat = NaN;
    note = "insufficient_groups";
    return;
end

try
    [p, tbl] = kruskalwallis(y, group_var, 'off');
    stat = extract_kw_stat(tbl);
    if isnan(stat)
        stat_name = "unknown";
    end
catch
    p = NaN;
    stat = NaN;
    note = "kw_failed";
end
end

function stat = extract_kw_stat(tbl)
stat = NaN;
if isempty(tbl)
    return;
end
try
    header = string(tbl(1, :));
    col_idx = find(strcmpi(header, "Chi-sq"), 1);
    if ~isempty(col_idx)
        stat = tbl{2, col_idx};
    elseif size(tbl, 2) >= 5
        stat = tbl{2, 5};
    end
catch
    stat = NaN;
end
end

function [p, stat, stat_name, note, n_groups] = run_mannwhitney(y, group_var)
note = "";
stat_name = "zval";
groups = unique(group_var);
n_groups = numel(groups);

if n_groups ~= 2 || numel(y) < 2
    p = NaN;
    stat = NaN;
    note = "need_two_groups";
    return;
end

y1 = y(group_var == groups(1));
y2 = y(group_var == groups(2));
if isempty(y1) || isempty(y2)
    p = NaN;
    stat = NaN;
    note = "empty_group";
    return;
end

try
    [p, ~, stats] = ranksum(y1, y2);
    if isstruct(stats) && isfield(stats, "zval")
        stat = stats.zval;
    else
        stat = NaN;
        stat_name = "unknown";
    end
catch
    p = NaN;
    stat = NaN;
    note = "mwu_failed";
end
end
