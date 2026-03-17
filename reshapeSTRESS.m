clc; clear; close all;

% 定义Excel文件路径和工作表名称
excelFileName = 'AlalyseResults\femalevivoi\femalevivoi_STRESS_汇总表3.xlsx'; % 替换为您的Excel文件名
sheetName = 'STRESS_intra_汇总'; % 替换为您的工作表名称

% 从Excel文件中读取数据
dataTable = readtable(excelFileName, 'Sheet', sheetName, 'VariableNamingRule', 'preserve');

% 确保数据表有两列：FileName 和 Value
if ~all(ismember({'FileName', 'STRESS_intra'}, dataTable.Properties.VariableNames))
    error('数据表必须包含两列：FileName 和 STRESS_intra');
end

% 提取obs序号和attribute序号
obsList = cellfun(@(x) str2double(x(4:5)), dataTable.FileName); % 提取obs序号
attrList = cellfun(@(x) str2double(x(7:8)), dataTable.FileName); % 提取attribute序号

% 获取唯一的obs序号和attribute序号
uniqueObs = unique(obsList);
uniqueAttr = unique(attrList);

% 初始化结果表格
resultTable = table();
resultTable.obs = arrayfun(@(x) sprintf('obs%02d', x), uniqueObs, 'UniformOutput', false); % 第一列存储obs序号

% 遍历每个attribute，将数据填充到对应的列
for i = 1:length(uniqueAttr)
    attr = uniqueAttr(i);
    attrData = NaN(size(uniqueObs)); % 初始化当前attribute的数据列
    
    % 找到当前attribute对应的数据
    for j = 1:length(uniqueObs)
        obs = uniqueObs(j);
        idx = (obsList == obs) & (attrList == attr); % 找到对应的行索引
        if any(idx)
            attrData(j) = dataTable.STRESS_intra(idx); % 填充数据
        end
    end
    
    % 将当前attribute的数据列添加到结果表格
    resultTable.(sprintf('attr%02d', attr)) = attrData;
end

% 显示结果表格
disp(resultTable);

% 将结果表格写入Excel文件
outputFileName = 'rearranged_table.xlsx';
writetable(resultTable, outputFileName);

disp('表格重新排列完成，结果已保存到 rearranged_table.xlsx');