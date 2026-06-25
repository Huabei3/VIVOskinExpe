% 运行最小化测试
close all; clc; clear;

% 只运行第一个 nation 的第一个 attribute 的第一个 dropped subject
fprintf('=== 最小化测试 scatter_L_depend_n_drop1.m ===\n');

% 修改脚本以只运行一个测试用例
fid = fopen('scatter_L_depend_n_drop1.m', 'r');
content = fread(fid, '*char')';
fclose(fid);

% 在脚本开头添加限制
add_text = '\n%% === 调试限制 ===\n';
add_text = [add_text 'debug_limited = true;\n'];
add_text = [add_text 'if debug_limited\n'];
add_text = [add_text '    nations = ["AS"];\n'];
add_text = [add_text '    attributes = [1];  % Preference\n'];
add_text = [add_text '    % 只运行第一个 dropped subject\n'];
add_text = [add_text '    val_combo_idx_to_run = 1;\n'];
add_text = [add_text '    fprintf("调试模式：只运行 AS nation, Preference attribute, 第一个 dropped subject\\n");\n'];
add_text = [add_text 'end\n\n'];

% 找到 close all; clc; clear; 这行之后插入
pattern = 'close all; clc; clear;';
idx = strfind(content, pattern);
if ~isempty(idx)
    insert_pos = idx + length(pattern);
    content = [content(1:insert_pos) add_text content(insert_pos+1:end)];
end

% 在主循环中添加条件限制
pattern = 'for i_nation = 1:length(nations)';
new_line = 'for i_nation = 1:length(nations)\n    if debug_limited && i_nation > 1, break; end';
idx = strfind(content, pattern);
if ~isempty(idx)
    content = [content(1:idx-1) new_line content(idx+length(pattern):end)];
end

pattern = 'for val_combo_idx = 1:n_subjects_nation';
new_line = 'for val_combo_idx = 1:n_subjects_nation\n        if debug_limited && val_combo_idx > val_combo_idx_to_run, break; end';
idx = strfind(content, pattern);
if ~isempty(idx)
    content = [content(1:idx-1) new_line content(idx+length(pattern):end)];
end

pattern = 'for idx_attribute = 1:length(attributes)';
new_line = 'for idx_attribute = 1:length(attributes)\n            if debug_limited && idx_attribute > 1, break; end';
idx = strfind(content, pattern);
if ~isempty(idx)
    content = [content(1:idx-1) new_line content(idx+length(pattern):end)];
end

% 写临时文件
temp_file = 'scatter_L_depend_n_drop1_temp.m';
fid = fopen(temp_file, 'w');
fprintf(fid, '%s', content);
fclose(fid);

fprintf('已创建临时测试文件: %s\n', temp_file);
fprintf('运行测试...\n');

% 运行测试
try
    run(temp_file);
catch ME
    fprintf('运行出错: %s\n', ME.message);
    fprintf('错误堆栈:\n');
    for i = 1:length(ME.stack)
        fprintf('  %s (%d)\n', ME.stack(i).name, ME.stack(i).line);
    end
end

% 清理
delete(temp_file);
fprintf('测试完成。\n');