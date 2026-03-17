% 1. 定义文件路径和文件名
filename_in = 'batch6apply_delivered1.xlsx'; % 替换为你的输入文件名
filename_out = 'model_name_subject_fee.xlsx'; % 定义输出文件名

% 2. 从Excel文件中读取数据
% 使用 readtable，并指定要读取的范围 'A2:E'

T_in = readtable(filename_in, 'VariableNamingRule', 'preserve');


% 3. 初始化变量以存储结果
model_name = '';
fee = 0;
found_match = false; % 用一个标志来判断是否找到匹配项

% 4. 遍历每一行数据
% 使用 table 的行数
for i = 1:height(T_in)
    % 检查第三列和第五列是否有值
    % 由于是 table，直接通过列索引访问数据
    text_col = T_in{i, 5};
    fee_col = T_in{i, 3};

    % 检查第五列是否非空且是字符串
    if ~isempty(text_col) && ischar(text_col{1})
        text = text_col{1};

        % 查找第一个 "(" 和 ")" 的位置
        start_bracket = strfind(text, '(');
        end_bracket = strfind(text, ')');
        
        % 确保找到了括号且它们的顺序正确
        if ~isempty(start_bracket) && ~isempty(end_bracket) && start_bracket(1) < end_bracket(1)
            
            % 提取括号之间的内容作为 model_name
            model_name = text(start_bracket(1)+1 : end_bracket(1)-1);
            
            % 获取第三列的值作为被试费
            fee = fee_col;
            
            % 设置标志为 true 并跳出循环，因为你只需要第一个符合条件的行
            found_match = true;
            break;
        end
    end
end

% 5. 将结果写入新的Excel文件
if found_match
    % 创建一个新的 table 来存储结果
    T_out = table({model_name}, fee, 'VariableNames', {'model_name', '被试费'});
    
    % 使用 writetable 将数据写入新的Excel文件
    writetable(T_out, filename_out);
    
    fprintf('成功找到匹配项，并创建了文件：%s\n', filename_out);
else
    fprintf('未找到符合条件的行。\n');
end