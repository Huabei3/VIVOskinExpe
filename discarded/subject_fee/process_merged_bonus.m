% 清理工作区和命令窗口
clear;
clc;

% 定义要读取的XLSX文件名
filename = 'merged_output.xlsx'; % 替换为您的实际文件名
% 定义合并后的数据要写入的新工作表名称
output_sheet = 'Merged_and_Filtered_Data';

% 检查文件是否存在
if ~isfile(filename)
    error('文件不存在，请检查文件名和路径。');
end

% 读取XLSX文件数据，以单元格数组形式读取，处理混合数据类型
try
    data = readcell(filename, 'Sheet', 1);
    if size(data, 2) < 6
        error('文件列数不足6列，请检查数据。');
    end
catch ME
    error('读取文件时出错：\n%s', ME.message);
end

% 提取表头和数据部分
headers = data(1, :);
data = data(2:end, :);

% 将第二列数据转换为字符串，以便进行唯一值分组
col2 = string(data(:, 2));
[unique_col2, ~, ic] = unique(col2);

% 初始化一个新的单元格数组来存储合并后的数据
merged_data = cell(length(unique_col2), size(data, 2));

% 循环处理每个唯一的第二列值
for i = 1:length(unique_col2)
    % 找到所有第二列相同的行
    rows_to_merge = data(ic == i, :);
    
    % --- 应用合并规则 ---
    
    % 第一列：直接取第一个待合并行的第一列值
    first_col_val = rows_to_merge{1, 1};
    % 检查并处理 'missing' 类型，将其转换为 NaN 或空字符串
    if ismissing(first_col_val)
        % 如果是数字类型数据，转换为 NaN；否则，转换为''
        if isnumeric(first_col_val)
            first_col_val = NaN;
        else
            first_col_val = '';
        end
    end
    merged_data{i, 1} = first_col_val;
    
    % 第二列：保持不变
    merged_data{i, 2} = unique_col2(i);
    
    % 第三列：求和
    total_sum = 0;
    col3_values = rows_to_merge(:, 3);
    for k = 1:length(col3_values)
        current_val = col3_values{k};
        % 检查并处理 NaN/missing 值
        if isnumeric(current_val) && ~isnan(current_val) && ~ismissing(current_val)
            total_sum = total_sum + current_val;
        end
    end
    merged_data{i, 3} = total_sum;
    
    % 第4/5/6列：拼接
    for j = 4:6
        col_values_str = rows_to_merge(:, j);
        valid_values = {}; % 初始化空单元格数组
        for k = 1:length(col_values_str)
            current_value = col_values_str{k};
            % 判断当前值是否为非NaN或缺失值
            if any(~ismissing(current_value)) && (~isnumeric(current_value) || ~any(isnan(current_value)))
                % 将非NaN值添加到 valid_values
                valid_values{end + 1} = num2str(current_value);
            end
        end
        merged_data{i, j} = strjoin(valid_values, ',');
    end
end

% 筛选：删除第三列值为0的行
% 使用循环和 if 语句来安全地处理
rows_to_keep_logic = false(size(merged_data, 1), 1);
for i = 1:size(merged_data, 1)
    if isnumeric(merged_data{i, 3}) && merged_data{i, 3} ~= 0
        rows_to_keep_logic(i) = true;
    end
end
final_data = merged_data(rows_to_keep_logic, :);

% 将表头和最终数据拼接起来
final_data_with_headers = [headers; final_data];

% 将结果写入新的工作表
fprintf('数据处理完成。正在写入文件 %s 的 "%s" 工作表中...\n', filename, output_sheet);
try
    writecell(final_data_with_headers, filename, 'Sheet', output_sheet);
    fprintf('脚本运行完毕！结果已保存在 %s 中。\n', filename);
catch ME
    error('写入文件时出错：\n%s', ME.message);
end