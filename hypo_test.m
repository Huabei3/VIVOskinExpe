clc;clear;close all;
addpath("utils\")
%%


table_folder = fullfile("AnalyseResults_p","efit_p","scaled","resTable");
table_file = fullfile(table_folder, "Peggy_VIVO_table.mat");

table_data = load(table_file);
T = resolve_table(table_data);

save_folder = fullfile("AnalyseResults_p","efit_p","scaled","cens_fields");
if ~exist(save_folder, "dir")
    mkdir(save_folder);
end

required_fields = ["CCT","illuminance","scene","model_ethnicity", ...
    "gender","model_id","observer_type"];
dim_names = ["L","a","b","C","h"];
results = cell(0, 9);
row = 0;
cens_fields_map = cell(numel(required_fields), 1);

for i_field = 1:numel(required_fields)
    field_name = required_fields(i_field);
    if field_name == "CCT"
        T_inlab = filter_inlab_scene(T);
        cct_tokens = ["3k","4k","5k","6k","d65","7k","8k"];
        cens_field = build_cens_field_scene_token(T_inlab, cct_tokens);
    elseif field_name == "illuminance"
        cens_field = build_cens_field_illuminance(T);
    else
        cens_field = build_cens_field(T, field_name);
    end
    cens_fields_map{i_field} = cens_field;
    out_file = fullfile(save_folder, strcat("cens_", field_name, ".mat"));
    save(out_file, "cens_field", "field_name");

    for i_row = 1:size(cens_field, 1)
        group_label = cens_field{i_row, 2};
        if iscell(group_label)
            if isempty(group_label)
                group_label = "";
            else
                group_label = string(group_label{1});
            end
        else
            group_label = string(group_label);
        end

        group_data = cens_field{i_row, 1};
        for i_col = 1:numel(dim_names)
            note = "";
            if isempty(group_data) || size(group_data, 2) < i_col
                dim_data = [];
            else
                dim_data = group_data(:, i_col);
            end
            dim_data = dim_data(~isnan(dim_data));
            n_samples = numel(dim_data);
            if n_samples < 4
                h = NaN;
                p = NaN;
                kstat = NaN;
                note = "insufficient_samples";
            else
                try
                    [h, p, kstat] = lillietest(dim_data, 'Alpha', 0.05);
                catch
                    h = NaN;
                    p = NaN;
                    kstat = NaN;
                    note = "lillietest_failed";
                end
            end

            row = row + 1;
            results{row, 1} = char(field_name);
            results{row, 2} = i_row;
            results{row, 3} = char(group_label);
            results{row, 4} = char(dim_names(i_col));
            results{row, 5} = n_samples;
            results{row, 6} = h;
            results{row, 7} = p;
            results{row, 8} = kstat;
            results{row, 9} = char(note);
        end
    end
end

summary_file = fullfile(save_folder, "lillietest_summary.xlsx");
results_table = cell2table(results, 'VariableNames', { ...
    'field','group_index','group_label','dimension','n_samples', ...
    'h','p','kstat','note' ...
});
writetable(results_table, summary_file, "FileType", "spreadsheet");

summary_rows = cell(numel(required_fields), 6);
for i_field = 1:numel(required_fields)
    field_name = required_fields(i_field);
    mask = results_table.field == field_name;
    p_vals = results_table.p(mask);
    p_vals = p_vals(~isnan(p_vals));
    if isempty(p_vals)
        p_max = NaN;
        p_min = NaN;
        p_mean = NaN;
        p_lt_pct = NaN;
        is_normal = "no";
    else
        p_max = max(p_vals);
        p_min = min(p_vals);
        p_mean = mean(p_vals);
        p_lt_pct = sum(p_vals < 0.05) / numel(p_vals) * 100;
        if all(p_vals >= 0.05)
            is_normal = "yes";
        else
            is_normal = "no";
        end
    end

    summary_rows{i_field, 1} = char(field_name);
    summary_rows{i_field, 2} = p_max;
    summary_rows{i_field, 3} = p_min;
    summary_rows{i_field, 4} = p_mean;
    summary_rows{i_field, 5} = p_lt_pct;
    summary_rows{i_field, 6} = char(is_normal);
end

summary_table = cell2table(summary_rows, 'VariableNames', { ...
    'field','p_max','p_min','p_mean','p_lt_0_05_pct','is_normal' ...
});
writetable(summary_table, summary_file, "FileType", "spreadsheet", "Sheet", "summary");
%%
test_results = cell(0, 10);
row = 0;
mw_fields = ["gender","observer_type"];

for i_field = 1:numel(required_fields)
    field_name = required_fields(i_field);
    cens_field = cens_fields_map{i_field};
    if isempty(cens_field)
        continue;
    end

    for i_col = 1:numel(dim_names)
        y = [];
        group = [];
        group_names = strings(0, 1);

        for g = 1:size(cens_field, 1)
            group_data = cens_field{g, 1};
            if isempty(group_data) || size(group_data, 2) < i_col
                continue;
            end
            dim_data = group_data(:, i_col);
            dim_data = dim_data(~isnan(dim_data));
            if isempty(dim_data)
                continue;
            end

            y = [y; dim_data];
            group = [group; repmat(g, numel(dim_data), 1)];
            group_names = [group_names; string(cens_field{g, 2})];
        end

        n_groups = numel(unique(group));
        n_total = numel(y);
        group_label = strjoin(group_names, ";");
        stat_name = "";
        stat = NaN;
        p_value = NaN;
        note = "";

        if any(field_name == mw_fields)
            test_name = "Mann-Whitney U";
            if n_groups ~= 2
                note = "need_two_groups";
            else
                g_vals = unique(group);
                y1 = y(group == g_vals(1));
                y2 = y(group == g_vals(2));
                try
                    [p_value, ~, stats] = ranksum(y1, y2);
                    stat_name = "zval";
                    if isstruct(stats) && isfield(stats, "zval")
                        stat = stats.zval;
                    end
                catch
                    note = "mwu_failed";
                end
            end
        else
            test_name = "Kruskal-Wallis";
            if n_groups < 2
                note = "insufficient_groups";
            else
                try
                    [p_value, tbl] = kruskalwallis(y, group, 'off');
                    stat_name = "chi2";
                    if size(tbl, 2) >= 5
                        stat = tbl{2, 5};
                    end
                catch
                    note = "kw_failed";
                end
            end
        end

        row = row + 1;
        test_results{row, 1} = char(field_name);
        test_results{row, 2} = char(test_name);
        test_results{row, 3} = char(dim_names(i_col));
        test_results{row, 4} = n_groups;
        test_results{row, 5} = n_total;
        test_results{row, 6} = char(group_label);
        test_results{row, 7} = char(stat_name);
        test_results{row, 8} = stat;
        test_results{row, 9} = p_value;
        test_results{row, 10} = char(note);
    end
end

test_table = cell2table(test_results, 'VariableNames', { ...
    'field','test','dimension','n_groups','n_total','group_labels', ...
    'statistic_name','statistic','p_value','note' ...
});
summary_file = fullfile(save_folder, "hypo_test_summary.xlsx");
writetable(test_table, summary_file, "FileType", "spreadsheet", "Sheet", "nonparametric_tests");
