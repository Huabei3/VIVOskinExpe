% 运行 scatter_L_depend_n_drop1.m 并检查输出
close all; clc; clear;

% 备份原始文件
copyfile('scatter_L_depend_n_drop1.m', 'scatter_L_depend_n_drop1_backup.m');

% 修改脚本以只运行部分测试
fid = fopen('scatter_L_depend_n_drop1.m', 'r');
content = fread(fid, '*char')';
fclose(fid);

% 找到 if_draw = "false"; 这行
pattern = 'if_draw = "false";';
new_line = 'if_draw = "false";\n\n%% ===== 调试模式：只运行第一个 nation 和 attribute =====\ndebug_mode = true;\nnations = ["AS"];  % 只测试第一个 nation\nattributes = [1];  % 只测试第一个 attribute\n';
idx = strfind(content, pattern);
if ~isempty(idx)
    content = [content(1:idx+length(pattern)-1) new_line content(idx+length(pattern):end)];
end

% 找到主循环开始的地方，添加调试输出
pattern = '%% ===== 主循环：nation → val_combo_idx → attribute → i_par =====';
new_section = '\n%% ===== 主循环：nation → val_combo_idx → attribute → i_par =====\nif debug_mode\n    fprintf("调试模式：只运行第一个 nation (AS) 和第一个 attribute (Preference)\\n");\nend\n';
idx = strfind(content, pattern);
if ~isempty(idx)
    content = [content(1:idx-1) new_section content(idx:end)];
end

% 找到写 xlsx 的部分，添加更多调试信息
pattern = 'row_data = {attr_name, dropped_lastPart, sprintf(''%d'', dropped_subject_idx), ...';
new_line = '            %% ===== 追加写 xlsx =====\n            fprintf("    [写xlsx] a_C_L = [%.4f, %.4f]\\n", a_C_L(1), a_C_L(2));\n            fprintf("    [写xlsx] a_alpha = %.4f\\n", a_alpha);\n            row_data = {attr_name, dropped_lastPart, sprintf(''%d'', dropped_subject_idx), ...';
idx = strfind(content, pattern);
if ~isempty(idx)
    content = [content(1:idx-1) new_line content(idx:end)];
end

% 写回文件
fid = fopen('scatter_L_depend_n_drop1_debug.m', 'w');
fprintf(fid, '%s', content);
fclose(fid);

fprintf('已创建调试版本: scatter_L_depend_n_drop1_debug.m\n');
fprintf('运行调试脚本...\n');

% 运行调试脚本
try
    run('scatter_L_depend_n_drop1_debug.m');
catch ME
    fprintf('运行出错: %s\n', ME.message);
end

% 恢复原始文件
copyfile('scatter_L_depend_n_drop1_backup.m', 'scatter_L_depend_n_drop1.m');
delete('scatter_L_depend_n_drop1_backup.m');
delete('scatter_L_depend_n_drop1_debug.m');

fprintf('调试完成。\n');