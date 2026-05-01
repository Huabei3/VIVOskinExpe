%% fix_headers.m
% 修复 scatter_L_depend_new.m 中 full_header 和 full_header1 的类型错误
% 用法：在 MATLAB 中 cd 到 analyze 目录，运行 fix_headers

fname = 'scatter_L_depend_new.m';
fid = fopen(fname, 'r', 'n', 'UTF-8');
lines = textscan(fid, '%s', 'Delimiter', '\n', 'Whitespace', '');
fclose(fid);
lines = lines{1};

for i = 1:length(lines)
    % 修复 full_header（字符串数组 -> cell数组）
    if contains(lines{i}, 'full_header = ["Attribute", excel_col_names]')
        lines{i} = strrep(lines{i}, ...
            'full_header = ["Attribute", excel_col_names];', ...
            'full_header = [{"Attribute"}, cellstr(excel_col_names)];');
        fprintf('Fixed line %d: full_header\n', i);
    end
    % 修复 full_header1（字符串数组 -> cell数组）
    if contains(lines{i}, 'full_header1 = ["Attribute"')
        % 整行替换为正确形式
        lines{i} = '    full_header1 = [{"Attribute"}, repmat({""},1,size(a_for_excel_C_L,2))];';
        fprintf('Fixed line %d: full_header1\n', i);
    end
end

fid = fopen(fname, 'w', 'n', 'UTF-8');
for i = 1:length(lines)
    fprintf(fid, '%s\n', lines{i});
end
fclose(fid);
fprintf('Done! %s has been updated.\n', fname);
