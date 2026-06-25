% 检查 xlsx 文件中的参数
close all; clc; clear;

xlsx_file = fullfile("AnalyseResults_p\efit_p\unscaled\model_fullpara_n_drop", ...
    "d65\new\i\non_model\drop_1", "n_drop_cv_results_n1.xlsx");

nations_sheets = {"AS", "CA", "SA", "AF", "all"};

% 列索引（1-based）
COL = struct();
COL.Attr       = 1;
COL.Drop_subj  = 2;
COL.a_C1       = 8;
COL.a_C2       = 9;
COL.a_la1      = 10;
COL.a_la2      = 11;
COL.a_la3      = 12;
COL.a_la4      = 13;
COL.a_sa1      = 14;
COL.a_sa2      = 15;
COL.a_sa3      = 16;
COL.a_sa4      = 17;
COL.hue_angle  = 18;
COL.theta      = 19;
COL.alpha      = 20;

for i_n = 1:length(nations_sheets)
    nation = nations_sheets{i_n};
    fprintf('\n===== 检查 sheet: %s =====\n', nation);
    
    try
        [num, txt, raw] = xlsread(xlsx_file, nation);
    catch ME
        fprintf('  读取失败: %s\n', ME.message);
        continue;
    end
    
    n_rows = size(raw, 1);
    if n_rows < 2
        fprintf('  没有数据行\n');
        continue;
    end
    
    fprintf('  总行数: %d\n', n_rows);
    
    % 检查前几行的 a_C1 和 a_C2 值
    for r = 2:min(6, n_rows)
        drop_subj = raw{r, COL.Drop_subj};
        attr = raw{r, COL.Attr};
        a_C1 = raw{r, COL.a_C1};
        a_C2 = raw{r, COL.a_C2};
        
        fprintf('  行 %d: Drop_subj=%s, Attr=%s, a_C1=%s, a_C2=%s', ...
            r, string(drop_subj), string(attr), ...
            string(a_C1), string(a_C2));
        
        if isnan(a_C1) || isnan(a_C2)
            fprintf('  ← 包含 NaN!\n');
        else
            fprintf('\n');
        end
    end
    
    % 统计 NaN 数量
    nan_count_C1 = 0;
    nan_count_C2 = 0;
    total_rows = n_rows - 1; % 减去标题行
    
    for r = 2:n_rows
        a_C1 = raw{r, COL.a_C1};
        a_C2 = raw{r, COL.a_C2};
        
        if isnan(a_C1)
            nan_count_C1 = nan_count_C1 + 1;
        end
        if isnan(a_C2)
            nan_count_C2 = nan_count_C2 + 1;
        end
    end
    
    fprintf('  a_C1 NaN: %d/%d (%.1f%%)\n', nan_count_C1, total_rows, nan_count_C1/total_rows*100);
    fprintf('  a_C2 NaN: %d/%d (%.1f%%)\n', nan_count_C2, total_rows, nan_count_C2/total_rows*100);
    
    % 检查其他参数
    nan_count_alpha = 0;
    for r = 2:n_rows
        alpha_val = raw{r, COL.alpha};
        if isnan(alpha_val)
            nan_count_alpha = nan_count_alpha + 1;
        end
    end
    fprintf('  alpha NaN: %d/%d (%.1f%%)\n', nan_count_alpha, total_rows, nan_count_alpha/total_rows*100);
end

fprintf('\n===== 检查 predict_fullpara_n_drop.m 使用的输出目录 =====\n');
output_mat_folder = fullfile("AnalyseResults_p\efit_p\unscaled\model_fullpara", ...
    "d65\new\i\non_model\1_drop");

if exist(output_mat_folder, 'dir')
    fprintf('  目录存在: %s\n', output_mat_folder);
    mat_files = dir(fullfile(output_mat_folder, '*.mat'));
    fprintf('  找到 %d 个 .mat 文件:\n', length(mat_files));
    for i = 1:length(mat_files)
        fprintf('    %s\n', mat_files(i).name);
    end
else
    fprintf('  目录不存在: %s\n', output_mat_folder);
end