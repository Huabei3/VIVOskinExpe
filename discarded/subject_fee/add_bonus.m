% 清理工作区和命令行
clear;
clc;

% 设置输入文件路径
input_file = 'D:\work\VIVOskinExpe\analyze\subject_fee\绩效报销.xlsx'; % <-- 在这里修改为你的XLSX文件名

% --- 定义数据映射 ---
mp_sec_fee = containers.Map();
mp_sec_fee('f01') = 38; mp_sec_fee('f02') = 38; mp_sec_fee('f03') = 38; mp_sec_fee('f04') = 0;
mp_sec_fee('f05') = 0;  mp_sec_fee('f06') = 0;  mp_sec_fee('f07') = 27; mp_sec_fee('f08') = 27;
mp_sec_fee('f09') = 27; mp_sec_fee('f10') = 27; mp_sec_fee('m01') = 33; mp_sec_fee('m02') = 33;
mp_sec_fee('m03') = 33; mp_sec_fee('m04') = 0;  mp_sec_fee('m05') = 0;  mp_sec_fee('m06') = 0;
mp_sec_fee('m07') = 22; mp_sec_fee('m08') = 22; mp_sec_fee('m09') = 22; mp_sec_fee('m10') = 22;

% --- 读入数据 ---
fprintf('正在读取文件 %s...\n', input_file);
try
    data_table = readtable(input_file, 'VariableNamingRule', 'preserve');
catch
    error('读取文件时出错。请检查文件路径是否正确，且文件为XLSX格式。');
end

% --- 按第二列进行分组 ---
unique_keys = unique(data_table{:, 2});
fprintf('找到 %d 个唯一的分组键。\n', length(unique_keys));

% --- 初始化结果存储 ---
merged_rows = {};
merged_row_index = 1;

% --- 循环处理每个分组 ---
fprintf('开始处理数据...\n');
for i = 1:length(unique_keys)
    current_key = unique_keys{i};
    
    % 找出属于当前分组的所有行
    is_current_key = strcmp(data_table{:, 2}, current_key);
    current_group_data = data_table(is_current_key, :);
    sum(is_current_key)
    
    % --- 应用合并规则 ---
    
    % 第一列合并: 非NaN、长度>6、全数字字符串，且只保留唯一值
    merged_col1 = {};
    for j = 1:size(current_group_data, 1)
        val = current_group_data{j, 1}{1,1};
        % 检查条件：非空、长度大于6、除首字母外全是数字
        if ischar(val) && length(val) > 6 && all(isstrprop(val(2:end), 'digit'))
            % 检查是否已存在于合并列表中
            if ~ismember(val, merged_col1)
                merged_col1{end+1} = val;
            end
        end
    end
    merged_col1_str = strjoin(merged_col1, ',');
    
    % 第二列保持不变
    merged_col2 = current_key;
    
    % 第三列: 所有sec_bonus之和
    total_sec_bonus = 0;
    
    % 第四列: 所有sec_str的拼接
    merged_col4 = {};
    
    % 第五列: 第五列为True的sec_str的拼接
    true_sec_strs_map = {};
    
    % 第六列: 第五列为False的sec_str的拼接
    false_sec_strs_map = {};
    
    % 遍历分组内的每一行，进行计算和拼接
    sec_strs_map = containers.Map;
    for j = 1:size(current_group_data, 1)
        % 从第四列路径中提取sec_str
        path_str = current_group_data{j, 4}{1,1};
        parts = strsplit(path_str, '\');
        if length(parts) >= 3
            sec_str = parts{end-1};
            
            % 添加到第四列的拼接中
            if isKey(sec_strs_map, sec_str)                
                sec_strs_map(sec_str)=sec_strs_map(sec_str)+1;
                sec_str=strcat(sec_str,"repeat");
                sec_str=char(sec_str);
            else
                sec_strs_map(sec_str)=1;
            end
            merged_col4{end+1} = sec_str;
            

            % 计算sec_bonus
            if isKey(mp_sec_fee, sec_str(1:end-1))
                is_true = current_group_data{j, 5};
                if is_true
                    sec_bonus = mp_sec_fee(sec_str(1:end-1));
                    true_sec_strs_map{end+1} = sec_str;
                else
                    sec_bonus = 0;
                    false_sec_strs_map{end+1} = sec_str;
                end
                total_sec_bonus = total_sec_bonus + sec_bonus;
            end
        end
    end
    
    % 最终拼接字符串
    merged_col4_str = strjoin(merged_col4, ',');
    merged_col5_str = strjoin(true_sec_strs_map, ',');
    merged_col6_str = strjoin(false_sec_strs_map, ',');

    % 将新行添加到结果中
    merged_rows{merged_row_index, 1} = merged_col1_str;
    merged_rows{merged_row_index, 2} = merged_col2;
    merged_rows{merged_row_index, 3} = total_sec_bonus;
    merged_rows{merged_row_index, 4} = merged_col4_str;
    merged_rows{merged_row_index, 5} = merged_col5_str;
    merged_rows{merged_row_index, 6} = merged_col6_str;
    merged_row_index = merged_row_index + 1;
end

% 将结果转换为表格
headers = {'Merged_Col1', 'Merged_Col2', 'Merged_Col3', 'Merged_Col4', 'Merged_Col5', 'Merged_Col6'};
merged_data = cell2table(merged_rows, 'VariableNames', headers);

% --- 新增的逻辑：删除第三列为0的行 ---
fprintf('开始过滤数据，删除第三列为0的行...\n');
is_zero_bonus = (merged_data.Merged_Col3 == 0);
merged_data(is_zero_bonus, :) = [];
fprintf('过滤完成，共删除 %d 行。\n', sum(is_zero_bonus));

% 将最终结果写入新的XLSX文件
output_file = 'merged_output_1.xlsx';
fprintf('数据处理完成。正在写入文件 %s...\n', output_file);
writetable(merged_data, output_file);
fprintf('脚本运行完毕！结果已保存在 %s 中。\n', output_file);


