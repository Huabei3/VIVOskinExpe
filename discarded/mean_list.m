% 定义文件路径
function mean_list(filename)
    outputFilename = filename; % 输出文件名
    
    % 获取所有工作表的名称
    sheetNames = sheetnames(filename);
    
    % 定义 picname_group 的值
    ct = ["H3K", "H4K", "H5K", "H6K", "H7K", "H8K", "HD65", ...
          "L3K", "L4K", "L5K", "L6K", "L7K", "L8K", "LD65", ...
          "M3K", "M4K", "M5K", "M6K", "M7K", "M8K", "MD65"];
    
    % 初始化一个表格来存储平均值
    meanTable = [];
    
    % 遍历每个工作表
    for i = 1:length(sheetNames)
        % 读取当前工作表
        currentSheet = sheetNames{i};
        dataTable = readtable(filename, 'Sheet', currentSheet);
    
        % 如果是第一个工作表，初始化 meanTable 并保存非数字列
        if isempty(meanTable)
            % 保存非数字列（假设第一列是数字，其他列可能是文字）
            textColumns = dataTable(:, 2:end);
            meanTable = dataTable(:, 1); % 初始化为第一个工作表的数字列
        else
            % 累加数字列
            meanTable{:, 1} = meanTable{:, 1} + dataTable{:, 1};
        end
    end
    
    % 计算平均值
    meanTable{:, 1} = meanTable{:, 1} / length(sheetNames);
    
    % 将非数字列合并回表格
    meanTable = [meanTable, textColumns];
    
    % 修改 picname_group 列为指定的值
    meanTable.picname_group = repmat(ct', height(meanTable) / length(ct), 1);
    
    % 写入新的工作表
    writetable(meanTable, outputFilename, 'Sheet', 'Mean');
    
    disp('处理完成，平均值已保存到新的工作表中。');
end