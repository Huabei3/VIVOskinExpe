clc; clear; close all;
%% 生成汇总表
% 定义source文件夹路径
sourceFolder = 'D:\work\VIVOskinExpe\analyze\AlalyseResults\femalevivoi'; % 请将此处替换为你的source文件夹路径

% 获取source文件夹的名字
[~, sourceFolderName, ~] = fileparts(sourceFolder);

% 创建一个新的Excel文件用于存储总表，文件名为source文件夹的名字
outputFileName = fullfile(sourceFolder, [sourceFolderName, '_STRESS_汇总表1.xlsx']);
if exist(outputFileName, 'file')
    delete(outputFileName); % 如果文件已存在，则删除
end

% 获取source文件夹下的所有子文件夹
subFolders = dir(sourceFolder);
subFolders = subFolders([subFolders.isdir]); % 只保留文件夹
subFolders = subFolders(~ismember({subFolders.name}, {'.', '..'})); % 去除'.'和'..'

% 遍历每个子文件夹
for i = 1:length(subFolders)
    % 获取当前子文件夹路径
    currentSubFolder = fullfile(sourceFolder, subFolders(i).name);
    
    % 查找STRESS.mat文件
    stressFile = fullfile(currentSubFolder, 'STRESS.mat');
    if exist(stressFile, 'file')
        % 加载STRESS.mat文件
        load(stressFile, 'STRESS_intra', 'STRESS_inter');
        
        % 将STRESS_intra和STRESS_inter转换为表格
        stressIntraTable = cell2table(STRESS_intra, 'VariableNames', {'FileName', 'STRESS_intra'});
        stressInterTable = cell2table(STRESS_inter, 'VariableNames', {'FileName', 'STRESS_inter'});
        
        % 合并两个表格
        stressTable = join(stressIntraTable, stressInterTable, 'Keys', 'FileName');
        
        % 在每一列下面增加一行，存储该列所有数据的平均值
        avgRow = cell(1, width(stressTable)); % 创建一个单元格数组用于存储平均值
        for k = 1:width(stressTable)
            if isnumeric(stressTable{:, k}) % 只对数值型列计算平均值
                avgRow{k} = mean(stressTable{:, k}, 'omitnan'); % 计算平均值，忽略NaN
            else
                avgRow{k} = 'mean'; % N/A非数值型列标记为'N/A'
            end
        end
        
        % 将平均值行添加到表格末尾
        avgTable = cell2table(avgRow, 'VariableNames', stressTable.Properties.VariableNames);
        stressTable = [stressTable; avgTable];
        
        % 将数据写入总表，工作表名称为子文件夹的名字
        sheetName = subFolders(i).name;
        writetable(stressTable, outputFileName, 'Sheet', sheetName);
    else
        warning('文件 %s 不存在', stressFile);
    end
end

disp('汇总表生成完成！');