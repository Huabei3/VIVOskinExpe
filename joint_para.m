clc; clear; close all;

%% 定义source文件夹路径
sourceFolder = 'D:\work\VIVOskinExpe\analyze\AlalyseResults\femalevivoi'; % 请将此处替换为你的source文件夹路径

% 获取source文件夹的名字
[~, sourceFolderName, ~] = fileparts(sourceFolder);

% 创建一个新的Excel文件用于存储总表，文件名为source文件夹的名字
outputFileName = fullfile(sourceFolder, [sourceFolderName, '_para.xlsx']);
if exist(outputFileName, 'file')
    delete(outputFileName); % 如果文件已存在，则删除
end

% 获取source文件夹下的所有一级子文件夹
subFolders = dir(sourceFolder);
subFolders = subFolders([subFolders.isdir]); % 只保留文件夹
subFolders = subFolders(~ismember({subFolders.name}, {'.', '..'})); % 去除'.'和'..'

% 遍历每个一级子文件夹
for i = 1:length(subFolders)
    % 获取当前一级子文件夹路径
    currentSubFolder = fullfile(sourceFolder, subFolders(i).name);
    
    % 查找二级子文件夹ellipPara
    ellipParaFolder = fullfile(currentSubFolder, 'ellipPara');
    if exist(ellipParaFolder, 'dir')
        % 查找fitRes_level.mat文件
        fitResFile = fullfile(ellipParaFolder, 'fitRes_level.mat');
        if exist(fitResFile, 'file')
            % 加载fitRes_level.mat文件
            load(fitResFile, 'parNr_all');
            
            % 将parNr_all转换为表格
            dataTable = array2table(parNr_all, 'VariableNames', {'parNr_1', 'parNr_2', 'parNr_3', 'parNr_4', 'parNr_5', 'parNr_6', 'parNr_7'});
            
            % 计算每一列的平均值
            meanRow = array2table(mean(dataTable{:,:}, 1, 'omitnan'), 'VariableNames', dataTable.Properties.VariableNames);
            % meanRow = [{'mean'}, meanRow]; % 添加行头
            
            % 将平均值行添加到表格末尾
            dataTable = [dataTable; meanRow];
            
            % 将数据写入总表，工作表名称为一级子文件夹的名字
            sheetName = subFolders(i).name;
            writetable(dataTable, outputFileName, 'Sheet', sheetName);
        else
            warning('文件 %s 不存在', fitResFile);
        end
    else
        warning('文件夹 %s 不存在', ellipParaFolder);
    end
end

disp('汇总表生成完成！');