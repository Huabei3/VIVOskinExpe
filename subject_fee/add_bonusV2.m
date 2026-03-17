% 脚本名称: merge_data.m
% 描述: 该脚本读取一个XLSX文件，根据第二列相同的值合并行，并根据特定规则计算新列的值。
clear; clc;
% --- 用户设置 ---
input_filename = '绩效报销.xlsx'; % <-- 请将此处替换为你的输入文件名
output_filename = 'merged_outputV2.xlsx'; % <-- 设置你的输出文件名
% ------------------
% 创建一个 Map 来存储 sec_str 到 bonus 的映射
mp_sec_fee = containers.Map();
mp_sec_fee('f01') = 38; mp_sec_fee('f02') = 38; mp_sec_fee('f03') = 38; mp_sec_fee('f04') = 0;
mp_sec_fee('f05') = 0;  mp_sec_fee('f06') = 0;  mp_sec_fee('f07') = 27; mp_sec_fee('f08') = 27;
mp_sec_fee('f09') = 27; mp_sec_fee('f10') = 27; mp_sec_fee('m01') = 33; mp_sec_fee('m02') = 33;
mp_sec_fee('m03') = 33; mp_sec_fee('m04') = 0;  mp_sec_fee('m05') = 0;  mp_sec_fee('m06') = 0;
mp_sec_fee('m07') = 22; mp_sec_fee('m08') = 22; mp_sec_fee('m09') = 22; mp_sec_fee('m10') = 22;
% 读取XLSX文件
try
    opts = detectImportOptions(input_filename, 'VariableNamingRule', 'preserve');
    data = readtable(input_filename, opts);
catch
    error('无法读取文件。请确保文件存在且文件名正确。');
end
% 检查列数是否足够
if size(data, 2) < 5
    error('输入文件列数不足，至少需要5列。');
end
% 获取第二列（用于分组）
group_col = data{:, 2};
[unique_groups, ~, group_idx] = unique(group_col);

% --- 移除空字符串分组的修改部分 ---
valid_groups_idx = ~cellfun(@isempty, unique_groups);
unique_groups = unique_groups(valid_groups_idx);
group_col(~ismember(group_col, unique_groups)) = {''};
[~, ~, group_idx] = unique(group_col);
group_idx(group_idx == 1) = []; % 假设空字符串在第一个，根据实际情况可能需要调整
% ---------------------------------

% 创建用于存储合并结果的表格
num_unique_groups = length(unique_groups);
merged_data = table('Size', [num_unique_groups, 6], ...
                    'VariableTypes', {'cell', 'cell', 'double', 'cell', 'cell', 'cell'}, ...
                    'VariableNames', {'ID', 'name', 'bonus', 'sec_str', 'passed_sec', 'unpassed_sec'});
disp(['找到 ', num2str(num_unique_groups), ' 个唯一分组，开始处理...']);
for i = 1:num_unique_groups
    % 找到当前组的所有行
    current_group_indices = find(group_idx == i);
    if isempty(current_group_indices)
        continue
    end
    current_group_rows = data(current_group_indices, :);
    
    % --- 合并规则实现 ---
    % 1. 新行的第一列：取待合并行中第一行第一列的值
    new_col1 = current_group_rows{1, 1};
    
    % 2. 新行的第二列：不变，取分组值
    new_col2 = unique_groups{i};
    
    % 初始化用于计算和拼接的变量
    total_bonus = 0;
    sec_str_col4_parts = {};
    sec_str_true_parts = {};
    sec_str_false_parts = {};
    
    % 用于检查sec_str是否在当前组中重复
    sec_str_seen = containers.Map('KeyType', 'char', 'ValueType', 'logical');
    
    % 遍历当前组的所有行
    for j = 1:size(current_group_rows, 1)
        row = current_group_rows(j, :);
        
        % 提取第四列的sec_str
        col4_str = row{1, 4};
        parts = strsplit(col4_str{1,1}, '\');
        if length(parts) >= 3
            sec_str = parts{end-1};
        else
            sec_str = '';
        end
        
        % 检查sec_str是否已在当前组中出现过
        if isKey(sec_str_seen, sec_str)
            sec_str_display = [sec_str, '重复'];
        else
            sec_str_seen(sec_str) = true;
            sec_str_display = sec_str;
        end
        
        % 拼接sec_str到第四列
        sec_str_col4_parts{end+1} = sec_str_display;
        
        % 计算bonus并拼接第五/六列
        is_true = row{1, 5};
        if is_true
            bonus = 0;
            keys = mp_sec_fee.keys;
            for k = 1:length(keys)
                if contains(sec_str, keys{k})
                    bonus = mp_sec_fee(keys{k});
                    break;
                end
            end
            total_bonus = total_bonus + bonus;
            
            % 拼接第五列内容
            sec_str_true_parts{end+1} = sec_str_display;
        else
            % 拼接第六列内容
            sec_str_false_parts{end+1} = sec_str_display;
        end
    end
    
    % 3. 新行的第三列：所有待合并行bonus相加
    new_col3 = total_bonus;
    
    % 4. 新行的第四列：所有sec_str的拼接
    new_col4 = strjoin(sec_str_col4_parts, ', ');
    
    % 5. 新行的第五列：第五列为"TRUE"的sec_str拼接
    new_col5 = strjoin(sec_str_true_parts, ', ');
    
    % 6. 新行的第六列：第五列为"FALSE"的sec_str拼接
    new_col6 = strjoin(sec_str_false_parts, ', ');
    
    % 将结果赋值给新的行
    merged_data{i, 'ID'} = new_col1;
    merged_data{i, 'name'} = {new_col2};
    merged_data{i, 'bonus'} = new_col3;
    merged_data{i, 'sec_str'} = {new_col4};
    merged_data{i, 'passed_sec'} = {new_col5};
    merged_data{i, 'unpassed_sec'} = {new_col6};
end
% 将合并后的数据写入新的XLSX文件
writetable(merged_data, output_filename);
disp('-------------------------------------');
disp(['处理完成，结果已保存到 ', output_filename]);