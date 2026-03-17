clc; clear; close all;
%% 生成汇总表
% 定义source文件夹路径
sourceFolder = 'D:\work\VIVOskinExpe\analyze\AlalyseResults\malevivoi'; % 请将此处替换为你的source文件夹路径

% 获取source文件夹的名字
[~, sourceFolderName, ~] = fileparts(sourceFolder);

% 创建一个新的Excel文件用于存储总表，文件名为source文件夹的名字
outputFileName = fullfile(sourceFolder, [sourceFolderName, '_汇总表.xlsx']);
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
    
    % 查找list子文件夹
    listFolderPath = fullfile(currentSubFolder, 'list');
    if exist(listFolderPath, 'dir')
        % 查找ellip_list.xlsx文件
        ellipListFile = fullfile(listFolderPath, 'ellip_list.xlsx');
        if exist(ellipListFile, 'file')
            % 读取Excel文件内容
            [~, sheets] = xlsfinfo(ellipListFile);
            for j = 1:length(sheets)
                data = readtable(ellipListFile, 'Sheet', sheets{j});
                
                % 检查是否存在picname_group列
                if ismember('picname_group', data.Properties.VariableNames)
                    % 获取picname_group列的数据
                    picnameGroupCol = data.picname_group;
                    
                    % 删除原表中的picname_group列
                    data.picname_group = [];
                    
                    % 将picname_group列插入到第一列
                    data = [table(picnameGroupCol, 'VariableNames', {'picname_group'}), data];
                else
                    warning('文件 %s 的工作表 %s 中不存在 picname_group 列', ellipListFile, sheets{j});
                end
                
                % 在每一列下面增加一行，记录该列的平均值
                avgRow = cell(1, width(data)); % 创建一个单元格数组用于存储平均值
                for k = 1:width(data)
                    if isnumeric(data{:, k}) % 只对数值型列计算平均值
                        avgRow{k} = mean(data{:, k}, 'omitnan'); % 计算平均值，忽略NaN
                    else
                        avgRow{k} = 'mean'; % 非数值型列标记为'N/A'
                    end
                end
                
                % 将平均值行添加到表格末尾
                avgTable = cell2table(avgRow, 'VariableNames', data.Properties.VariableNames);
                data = [data; avgTable];
                
                % 将数据写入总表，工作表名称为二级子文件夹的名字
                sheetName = subFolders(i).name;
                writetable(data, outputFileName, 'Sheet', sheetName);
            end
        else
            warning('文件 %s 不存在', ellipListFile);
        end
    else
        warning('文件夹 %s 不存在', listFolderPath);
    end
end

disp('汇总表生成完成！');