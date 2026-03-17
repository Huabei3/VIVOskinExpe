clc;clear;close all;
%%
% MATLAB 脚本：处理文件夹并生成 CSV 文件计数日志

% --- 配置部分 ---
source_folder = 'D:\work\VIVOskinExpe\analyze\expRes\f06i\model_group'; % 源文件夹路径

% --- 主执行流程 ---

% 调用 attr2num 函数 (这是一个占位函数，需要根据您的实际Python代码进行完善)
% 如果 attr2num 在 Python 中会修改文件或文件夹，您需要在这里实现相应的MATLAB逻辑。
attr2num(source_folder); 

% 插入 'renamed' 到路径中
slashes=find(source_folder=='\');

renamed_folder = fullfile(source_folder(1:slashes(end-1)-1),"renamed", ...
    source_folder(slashes(end-1)+1:end));
disp(['Renamed folder path: ', renamed_folder]); % 显示新路径，方便调试

% 为 CSV 文件计数生成日志
generate_log_for_csv_counts(renamed_folder, 'log');


% --- 函数定义部分 ---

function attr2num(source_folder)

    % 构造新的renamed_folder路径
    renamed_folder = insert_renamed_in_path(source_folder);
    
    % 创建目标文件夹
    if ~exist(renamed_folder, 'dir')
        mkdir(renamed_folder);
    end
    
    % 定义属性名称映射
    attribute_names = [
        "Preference", "Attractiveness", "Feminine", "Cooperative",...
        "Youth", "Healthy", "Fidelity", "Harmony", "Fair", "Ruddy"];
    
    attribute_names_old = [
        "Preference", "Attractiveness", "Feminine", "Cooperative",...
        "Youth", "Healthy", "Precise reproduction",...
        "suit the environment or not", "white-skinned", "ruddy"];
    
    % 创建日志文件
    timestamp = datestr(now, 'yyyymmdd_HHMMSS');
    folders_log_file_name = sprintf('folders_log_%s.txt', timestamp);
    files_log_file_name = sprintf('files_log_%s.txt', timestamp);
    folders_log_file_path = fullfile(renamed_folder, folders_log_file_name);
    files_log_file_path = fullfile(renamed_folder, files_log_file_name);
    
    % 获取source文件夹下的所有子文件夹
    subfolders = dir(source_folder);
    subfolders = subfolders([subfolders.isdir]);  % 只保留文件夹
    % 过滤掉.和..
    subfolders = subfolders(~ismember({subfolders.name}, {'.', '..'}));
    
    % 打开日志文件
    folders_log = fopen(folders_log_file_path, 'w');
    files_log = fopen(files_log_file_path, 'w');
    
    % 遍历每个子文件夹
    for i = 1:length(subfolders)
        subfolder = subfolders(i).name;
        % 构造新的子文件夹名称
        new_subfolder_name = sprintf('obs%02d', i);
        new_subfolder_path = fullfile(renamed_folder, new_subfolder_name);
        
        % 创建新的子文件夹
        if ~exist(new_subfolder_path, 'dir')
            mkdir(new_subfolder_path);
        end
        
        % 记录文件夹的重命名操作
        fprintf(folders_log, '%s -> %s\n', subfolder, new_subfolder_name);
        
        % 获取当前子文件夹下的所有CSV文件
        subfolder_path = fullfile(source_folder, subfolder);
        csv_files = dir(fullfile(subfolder_path, '*.csv'));
        csv_files = {csv_files.name};
        
        % 遍历每个CSV文件
        for j = 1:length(csv_files)
            csv_file = csv_files{j};
            new_csv_name = csv_file;  % 默认使用原文件名
            
            % 检查文件名是否包含特定属性名称
            for k = 1:length(attribute_names)
                attr_name = attribute_names{k};
                attr_name_old = attribute_names_old{k};
                
                if contains(csv_file, attr_name) || contains(csv_file, attr_name_old)
                    % 构造新的文件名
                    new_csv_name = sprintf('%s_%02d.csv', new_subfolder_name, k);
                    break;
                end
            end
            
            % 源文件路径和目标文件路径
            source_csv_path = fullfile(subfolder_path, csv_file);
            target_csv_path = fullfile(new_subfolder_path, new_csv_name);
            
            % 复制并重命名文件
            copyfile(source_csv_path, target_csv_path);
            
            % 记录文件的重命名操作
            fprintf(files_log, '%s -> %s\n', csv_file, new_csv_name);
        end
    end
    
    % 关闭日志文件
    fclose(folders_log);
    fclose(files_log);
    
    disp('文件重命名完成。');
    disp(['文件夹日志文件已生成：', folders_log_file_path]);
    disp(['文件日志文件已生成：', files_log_file_path]);
end



function generate_log_for_csv_counts(source_folder, log_file_prefix)
% generate_log_for_csv_counts - 生成日志文件，记录每个子文件夹中的 .csv 文件数量。
% 新增：自动创建目标文件夹（如果不存在）

    % 第一步：检查并创建目标文件夹（关键修复）
    if ~exist(source_folder, 'dir')
        mkdir(source_folder);  % 递归创建不存在的文件夹（包括中间层级）
        fprintf('已创建文件夹: %s\n', source_folder);
    end

    % 第二步：生成日志文件（原有逻辑）
    timestamp = datestr(now, 'yyyymmdd_HHMMSS');
    log_file_name = [log_file_prefix, '_', timestamp, '.txt'];
    log_file_path = fullfile(source_folder, log_file_name);

    log_file_id = fopen(log_file_path, 'w');
    if log_file_id == -1
        error('无法创建日志文件: %s', log_file_path);
    end

    % 遍历子文件夹并统计CSV文件（原有逻辑）
    contents = dir(source_folder);
    for i = 1:length(contents)
        item = contents(i);
        if item.isdir && ~strcmp(item.name, '.') && ~strcmp(item.name, '..')
            folder_name = item.name;
            folder_path = fullfile(source_folder, folder_name);
            sub_contents = dir(folder_path);
            
            csv_files_count = 0;
            for j = 1:length(sub_contents)
                sub_item = sub_contents(j);
                if ~sub_item.isdir && endsWith(sub_item.name, '.csv', 'IgnoreCase', true)
                    csv_files_count = csv_files_count + 1;
                end
            end
            
            fprintf(log_file_id, 'Folder ''%s'' contains %d .csv files.\n', folder_name, csv_files_count);
        end
    end

    fclose(log_file_id);
    fprintf('日志文件 ''%s'' 已生成在 ''%s''.\n', log_file_name, source_folder);
end

%% expRes 2 renamed
% 定义文件夹路径
% sourceFolder = 'D:\work\VIVOskinExpe\analyze\expRes'; % 源文件夹路径
% destFolder = 'D:\work\VIVOskinExpe\analyze\expRes\renamed'; % 目标文件夹路径
% 
% % 定义文件夹名称列表和属性名称
% lastParts = ["f04iadd", "f05iadd", "f06iadd", "m04iadd", "m05iadd", "m06iadd"];
% attribute_names = ["Preference", "Attractiveness", "Feminine", "Cooperative", ...
%     "Youth", "Healthy", "Fidelity", "Harmony", "Fair", "Ruddy"];
% 
% % 创建日志文件路径
% logFilePath = fullfile(destFolder, 'log.txt');
% 
% % 打开日志文件
% fid = fopen(logFilePath, 'w');
% if fid == -1
%     error('Failed to open log file: %s', logFilePath);
% end
% 
% % 写入日志文件头部信息
% fprintf(fid, 'Log of file operations\n');
% fprintf(fid, '----------------------\n');
% fprintf(fid, 'Timestamp: %s\n', datestr(now));
% fprintf(fid, '----------------------\n');
% 
% % 遍历每个 model 文件夹
% for i = 1:length(lastParts)
%     modelFolder = fullfile(sourceFolder, lastParts(i), 'non_model');
% 
%     % 检查 model 文件夹是否存在
%     if ~isfolder(modelFolder)
%         warning('Model folder %s does not exist.', modelFolder);
%         continue;
%     end
% 
%     % 获取所有 obs 文件夹
%     obsFolders = dir(fullfile(modelFolder));
%     obsFolders = obsFolders([obsFolders.isdir] & ~ismember({obsFolders.name}, {'.', '..'}));
% 
%     % 初始化用于存储结果的 cell 数组
%     stressObsCell = {}; % 每行存储 [STRESS_intra_mean, obsFolder]
% 
%     % 遍历每个 obs 文件夹
%     for j = 1:length(obsFolders)
%         obsFolder = fullfile(obsFolders(j).folder, obsFolders(j).name);
%         csvFiles = dir(fullfile(obsFolder, '*.csv'));
% 
%         % 删除小于 8KB 的文件
%         for k = 1:length(csvFiles)
%             if csvFiles(k).bytes < 5 * 1024
%                 delete(fullfile(obsFolder, csvFiles(k).name));
%             end
%         end
% 
%         % 获取剩余的 CSV 文件
%         csvFiles = dir(fullfile(obsFolder, '*.csv'));
% 
%         % 如果剩余文件数量大于 2，则处理
%         if length(csvFiles) > 2
%             dir_res = dir(fullfile(obsFolder, '*.csv'));
%             [STRESS_inter, STRESS_intra] = process_data_calSTRESS(dir_res);
%             STRESS_intra_mean = mean(cell2mat(STRESS_intra(:, 2)));
% 
%             % 将结果存储到 cell 数组中
%             stressObsCell{end + 1, 1} = STRESS_intra_mean;
%             stressObsCell{end, 2} = obsFolder;
%         end
%     end
% 
%     % 按照 STRESS_intra_mean 对 cell 数组排序
%     [~, sortedIdx] = sort(cell2mat(stressObsCell(:, 1)));
%     stressObsCell_sorted = stressObsCell(sortedIdx, :);
% 
%     % 提取排序后的前 10 个 obs 文件夹
%     top10ObsFolders = stressObsCell_sorted(1:10, 2);
% 
%     % 创建目标文件夹
%     for j = 1:length(top10ObsFolders)
%         obsFolder = top10ObsFolders{j};
%         obsNumber = j;
%         relaObsFolder = fullfile(destFolder, lastParts(i), 'non_model', sprintf('obs_%02d', obsNumber));
% 
%         % 如果目标文件夹不存在，则创建
%         if ~isfolder(relaObsFolder)
%             mkdir(relaObsFolder);
%         end
% 
%         % 获取 obs 文件夹中的 CSV 文件
%         csvFiles = dir(fullfile(obsFolder, '*.csv'));
% 
%         % 遍历每个 CSV 文件并重命名后复制到目标文件夹
%         for k = 1:length(csvFiles)
%             csvFile = csvFiles(k).name;
%             [~, csvName] = fileparts(csvFile);
% 
%             % 找到文件名中包含的属性名称索引
%             for idx = 1:length(attribute_names)
%                 if contains(csvName, attribute_names(idx))
%                     newFileName = sprintf('obs%02d_%02d.csv', obsNumber, idx);
%                     break;
%                 end
%             end
% 
%             % 复制文件到目标文件夹
%             sourceFilePath = fullfile(obsFolder, csvFile);
%             destFilePath = fullfile(relaObsFolder, newFileName);
%             copyfile(sourceFilePath, destFilePath, 'f');
% 
%             % 记录操作到日志文件
%             fprintf(fid, 'Copied: %s -> %s\n', sourceFilePath, destFilePath);
%         end
%     end
% end
% 
% % 关闭日志文件
% fclose(fid);
% 
% % 提示完成
% disp('Processing complete. Log file saved to:');
% disp(logFilePath);
%% 把ruddy复制到non_model1
% lastParts=["f04iadd","f05iadd","f06iadd","m04iadd","m05iadd","m06iadd"];
% for i = 1:length(lastParts)
%     source_folder = fullfile('D:\work\VIVOskinExpe\analyze\expRes\', ...
%         lastParts(i),'\non_model1');
%     dest_folder = fullfile('D:\work\VIVOskinExpe\analyze\expRes\renamed', ...
%         lastParts(i));
% 
% 
%     % 确保目标文件夹存在，如果已存在则删除并重新创建
%     non_model1_folder = fullfile(dest_folder, 'non_model1');
%     if exist(non_model1_folder, 'dir')
%         rmdir(non_model1_folder, 's');
%         % delete(fullfile(non_model1_folder, '*.*')); % 删除文件夹中的所有文件
%     end
%     mkdir(non_model1_folder); % 创建新的文件夹
% 
%     % 遍历 source 文件夹下的所有子文件夹
%     subfolders = dir(fullfile(source_folder, '*'));
%     subfolders = subfolders([subfolders.isdir]); % 仅保留文件夹
%     subfolders = subfolders(~ismember({subfolders.name}, {'.', '..'})); 
% 
%     % 初始化 dir_res
%     dir_res = [];
% 
%     % 遍历每个子文件夹
%     for i = 1:length(subfolders)
%         folder_path = fullfile(source_folder, subfolders(i).name);
%         files = dir(fullfile(folder_path, '*Ruddy*.csv')); % 筛选包含 "Ruddy" 的文件
%         for j = 1:length(files)
%             if files(j).bytes > 8 * 1024 % 筛选文件大小大于 8KB
%                 dir_res = [dir_res; files(j)]; % 添加到 dir_res
%                 break; % 只取第一个符合条件的文件
%             end
%         end
%     end
% 
%     % 如果 dir_res 为空，提示并退出
%     if isempty(dir_res)
%         disp('没有找到符合条件的文件');
%         return;
%     end
% 
%     % 调用 process_data_calSTRESS 函数
%     [STRESS_inter, STRESS_intra] = process_data_calSTRESS(dir_res);
% 
%     % 按 STRESS_inter 升序排序
%     [~, sorted_idx] = sort(cell2mat(STRESS_intra(:, 2)));
%     STRESS_intra_sorted = STRESS_intra(sorted_idx, :);
% 
%     % 获取排名前 10 的子文件夹
%     top_folders = STRESS_intra_sorted(1:10, 1);
% 
%     % 复制排名前 10 的子文件夹到 non_model1 文件夹
%     log_file = fullfile(non_model1_folder, 'copy_log.txt');
%     fid = fopen(log_file, 'w'); % 打开日志文件
%     for i = 1:min(10, length(top_folders))
%         [folder_dir, ~, ~] = fileparts(top_folders{i});
%         [~, folder_name, ~] = fileparts(folder_dir);
%         source_file = fullfile(source_folder, folder_name);
%         dest_folder_path = fullfile(non_model1_folder, folder_name);
%         if exist(dest_folder_path, 'dir')
%             rmdir(dest_folder_path, 's'); % 如果目标文件夹已存在，删除
%         end
%         copyfile(source_file, dest_folder_path); % 复制文件夹
%         fprintf(fid, '复制文件夹: %s 到 %s\n', source_folder, dest_folder_path);
%     end
%     fclose(fid); % 关闭日志文件
% end
% disp('操作完成，排名前 10 的子文件夹已复制到 non_model1 文件夹');
%% 酬金申报加被试费
% 指定文件名和工作表名称
% filename = 'D:\work\VIVOskinExpe\汇报PPT\肤色感知实验第3批酬金申报.xlsx'; % Excel 文件名
% sheetname = '草稿'; % 工作表名称
% 
% % 读取指定工作表的数据为 cell 数组
% data = readcell(filename, 'Sheet', sheetname);
% 
% % 在所有处理之前，将所有 missing 转换为 NaN
% for i = 1:size(data, 1)
%     for j = 1:size(data, 2)
%         if ismissing(data{i, j})
%             data{i, j} = NaN;
%         end
%     end
% end
% 
% % 处理逻辑
% for i_data = 1:size(data, 1)
%     if ~isnan(data{i_data, 2}) % 检查第二列是否不是 NaN
%         for j_data = 1:i_data-1
%             if strcmp(data{i_data, 2}, data{j_data, 2}) % 如果第二列的值相同
%                 data{j_data, 3} = data{j_data, 3} + data{i_data, 3}; % 累加第三列的值
%                 data{i_data, 2} = []; % 清空第二列
%                 data{i_data, 3} = []; % 清空第三列
%             end
%         end
%     end
% end
% 
% % 标记需要删除的行
% rowsToDelete = [];
% for i_data = 1:size(data, 1)
%     if any(isempty(data{i_data, 2})) || any(isnan(data{i_data, 2})) % 检查第二列是否为空或 NaN
%         rowsToDelete = [rowsToDelete; i_data];
%     end
% end
% 
% % 删除标记的行
% data(rowsToDelete, :) = [];
% 
% % 将处理后的数据写入新的工作表
% newSheetName = 'ProcessedData'; % 新工作表名称
% writecell(data, filename, 'Sheet', newSheetName);
% 
% disp('数据处理完成并已写入 Excel！');

%%
% % 指定文件名和工作表名称
% filename = 'D:\work\VIVOskinExpe\汇报PPT\肤色感知实验第3批酬金申报.xlsx'; % Excel 文件名
% sheetname = '草稿'; % 工作表名称
% 
% % 读取指定工作表的数据为 cell 数组
% data = readcell(filename, 'Sheet', sheetname);
% 
% % 检查数据是否至少有三列
% if size(data, 2) < 3
%     error('数据中缺少必要的列。');
% end
% 
% % 初始化一个结构用于存储累加结果
% groupedData = containers.Map('KeyType', 'char', 'ValueType', 'double');
% 
% % 遍历数据，按第二列分组并累加第三列的值
% for i = 2:size(data, 1) % 假设第一行是标题行，从第二行开始处理
%     key = data{i, 2}; % 第二列的字符串作为键
%     value = str2double(data{i, 3}); % 第三列的数值（转换为数字）
% 
%     if ~isnan(value) % 确保第三列是有效的数字
%         if isKey(groupedData, key)
%             groupedData(key) = groupedData(key) + value; % 累加
%         else
%             groupedData(key) = value; % 初始化
%         end
%     end
% end
% 
% % 创建一个新的 cell 数组用于存储结果
% resultData = cell(size(data));
% resultData(1, :) = data(1, :); % 复制标题行
% 
% % 遍历数据，填充结果
% isFirstOccurrence = containers.Map('KeyType', 'char', 'ValueType', 'logical');
% for i = 2:size(data, 1)
%     key = data{i, 2};
%     if isKey(groupedData, key)
%         if ~isKey(isFirstOccurrence, key)
%             resultData{i, 3} = groupedData(key); % 赋值
%             isFirstOccurrence(key) = true; % 标记为首次出现
%         else
%             resultData{i, 3} = ''; % 清空其他重复行的第三列
%         end
%     end
% end
% 
% % 写入新的工作表
% newSheetName = 'ProcessedData'; % 新工作表名称
% writecell(resultData, filename, 'Sheet', newSheetName);
% 
% disp(['处理完成，结果已写入工作表 ', newSheetName]);
%% 合并model 和 non_model

% %   sourceFolder - 包含 model_group 和 non_model 文件夹的根目录路径
% sourceFolder="D:\work\VIVOskinExpe\analyze\expRes\m06iadd";
% % 初始化日志内容
% logContent = sprintf('操作日志 - %s\n', datestr(datetime('now'), 'yyyy-mm-dd HH:MM:SS'));
% logContent = [logContent, '-----------------------------------------------\n'];
% 
% % 定义一级子文件夹名称
% nonModelFolder = 'non_model';
% modelGroupFolder = 'model_group';
% allFolder = 'all';
% 
% % 构造文件夹路径
% nonModelPath = fullfile(sourceFolder, nonModelFolder);
% modelGroupPath = fullfile(sourceFolder, modelGroupFolder);
% allFolderPath = fullfile(sourceFolder, allFolder);
% 
% % 确保 all 文件夹存在
% if ~exist(allFolderPath, 'dir')
%     mkdir(allFolderPath);
%     logContent = [logContent, sprintf('创建文件夹: %s\n', allFolder)];
% end
% 
% % 获取 non_model 文件夹中的二级子文件夹
% nonModelSubfolders = dir(fullfile(nonModelPath, 'obs*'));
% nonModelSubfolders = nonModelSubfolders([nonModelSubfolders.isdir]);
% nonModelSubfolders = {nonModelSubfolders.name}';
% 
% % 找到 non_model 中的最大编号
% maxObsNumber = 0;
% for i = 1:length(nonModelSubfolders)
%     folderName = nonModelSubfolders{i};
%     obsNumber = str2double(folderName(4:end)); % 提取 obs 后的数字
%     if obsNumber > maxObsNumber
%         maxObsNumber = obsNumber;
%     end
% end
% 
% % 复制 non_model 中的二级子文件夹到 all 文件夹
% for i = 1:length(nonModelSubfolders)
%     folderName = nonModelSubfolders{i};
%     sourcePath = fullfile(nonModelPath, folderName);
%     targetPath = fullfile(allFolderPath, folderName);
% 
%     % 复制文件夹
%     copyfile(sourcePath, targetPath, 'f'); % 递归复制
%     logContent = [logContent, sprintf('复制文件夹: %s -> %s\n', sourcePath, targetPath)];
% end
% 
% % 获取 model_group 文件夹中的二级子文件夹
% modelGroupSubfolders = dir(fullfile(modelGroupPath, 'obs*'));
% modelGroupSubfolders = modelGroupSubfolders([modelGroupSubfolders.isdir]);
% modelGroupSubfolders = {modelGroupSubfolders.name}';
% 
% % 重命名 model_group 中的二级子文件夹
% for i = 1:length(modelGroupSubfolders)
%     folderName = modelGroupSubfolders{i};
%     newObsNumber = maxObsNumber + i; % 新编号
%     newFolderName = sprintf('obs%02d', newObsNumber);
%     sourcePath = fullfile(modelGroupPath, folderName);
%     targetPath = fullfile(allFolderPath, newFolderName);
% 
%     % 重命名文件夹
%     copyfile(sourcePath, targetPath);
%     logContent = [logContent, sprintf('重命名文件夹: %s -> %s\n', sourcePath, targetPath)];
% end
% 
% % 对 all 文件夹中的文件进行批量重命名
% logContent = [logContent, '\n处理 all 文件夹中的文件...\n'];
% logContent = [logContent, batchRenameFiles(allFolderPath)];
% 
% % 生成带有时间戳的日志文件
% logFileName = fullfile(sourceFolder, sprintf('operation_log_%s.txt', datestr(datetime('now'), 'yyyy-mm-dd_HH-MM-SS')));
% fid = fopen(logFileName, 'w');
% if fid == -1
%     error('无法创建日志文件：%s', logFileName);
% else
%     fprintf(fid, '%s', logContent);
%     fclose(fid);
% end
% 
% disp(['日志文件已生成：', logFileName]);
% 
% 
% function logContent = batchRenameFiles(targetFolder)
%     % 批量重命名 all 文件夹中的文件
%     logContent = sprintf('批量重命名日志 - %s\n', datestr(datetime('now'), 'yyyy-mm-dd HH:MM:SS'));
% 
%     % 获取目标文件夹下所有符合格式 obs%02d 的子文件夹
%     subfolders = dir(fullfile(targetFolder, 'obs*'));
%     subfolders = subfolders([subfolders.isdir]);
%     subfolders = {subfolders.name}';
%     subfolders = subfolders(~ismember(subfolders, {'.', '..'}));
% 
%     % 遍历每个子文件夹
%     for i = 1:length(subfolders)
%         folderName = subfolders{i};
%         folderPath = fullfile(targetFolder, folderName);
% 
%         % 获取当前子文件夹下所有符合格式 obs%02d_%02d.csv 的文件
%         files = dir(fullfile(folderPath, 'obs*.csv'));
%         files = {files.name}';
% 
%         % 遍历每个文件
%         for j = 1:length(files)
%             fileName = files{j};
%             slashes = find(fileName == '_');
%             prefix = fileName(1:slashes(1) - 1);
%             suffix = fileName(slashes(1) + 1:end);
% 
%             % 检查文件名前缀是否与文件夹名称一致
%             if ~strcmp(prefix, folderName)
%                 newFileName = [folderName, '_', suffix];
%                 oldFilePath = fullfile(folderPath, fileName);
%                 newFilePath = fullfile(folderPath, newFileName);
% 
%                 % 重命名文件
%                 movefile(oldFilePath, newFilePath);
%                 logContent = [logContent, sprintf('文件重命名：%s -> %s\n', fileName, newFileName)];
%             end
%         end
%     end
% end
%% 数文件
% % 目标文件夹路径
% targetFolder = 'D:\work\VIVOskinExpe\analyze\expRes'; % 替换为你的目标文件夹路径
% 
% % 初始化日志内容
% logContent = sprintf('文件夹结构检查日志 - %s\n', datestr(datetime('now'), 'yyyy-mm-dd HH:MM:SS'));
% logContent = [logContent, '--------------------------------------------------\n'];
% 
% % 获取目标文件夹下所有以 "female" 或 "male" 开头的文件夹
% subfolders = dir(fullfile(targetFolder, 'female*i'));
% subfolders = [subfolders; dir(fullfile(targetFolder, 'male*i'))];
% subfolders = subfolders([subfolders.isdir]);
% subfolders = {subfolders.name}';
% subfolders = subfolders(~ismember(subfolders, {'.', '..'}));
% 
% % 遍历每个符合条件的文件夹
% for i = 1:length(subfolders)
%     folderName = subfolders{i}; % 当前文件夹名称
%     folderPath = fullfile(targetFolder, folderName); % 当前文件夹路径
%     logContent = [logContent, sprintf('\n检查文件夹: %s\n', folderPath)];
% 
%     % 检查一级子文件夹
%     requiredSubfolders = {'model', 'all', 'non_model', 'model_group'};
%     existingSubfolders = {dir(fullfile(folderPath, '*')).name}';
%     existingSubfolders = existingSubfolders(~ismember(existingSubfolders, {'.', '..'}));
% 
%     % 检查是否存在所有一级子文件夹
%     for j = 1:length(requiredSubfolders)
%         subfolderName = requiredSubfolders{j};
%         if ~ismember(subfolderName, existingSubfolders)
%             logContent = [logContent, sprintf('  缺少一级子文件夹: %s\n', subfolderName)];
%         else
%             % 检查二级子文件夹数量
%             subfolderPath = fullfile(folderPath, subfolderName);
%             obsFolders = dir(fullfile(subfolderPath, 'obs*'));
%             obsFolders = obsFolders([obsFolders.isdir]);
%             obsFolders = {obsFolders.name}';
%             obsFolders = obsFolders(~ismember(obsFolders, {'.', '..'}));
% 
%             % 检查二级子文件夹数量是否符合要求
%             requiredCount = [1, 20, 15, 5]; % 对应 model, all, non_model, model_group 的子文件夹数量
%             if length(obsFolders) ~= requiredCount(j)
%                 logContent = [logContent, sprintf('  文件夹 %s 下的二级子文件夹数量不符合要求，应为 %d 个，实际为 %d 个\n', ...
%                     subfolderName, requiredCount(j), length(obsFolders))];
%             else
%                 % 检查每个二级子文件夹下的文件
%                 for k = 1:length(obsFolders)
%                     obsFolderName = obsFolders{k};
%                     obsFolderPath = fullfile(subfolderPath, obsFolderName);
%                     requiredFiles = cell(1, 9);
%                     for m = 1:9
%                         requiredFiles{m} = sprintf('%s_%02d.csv', obsFolderName, m);
%                     end
%                     existingFiles = {dir(fullfile(obsFolderPath, '*.csv')).name}';
% 
%                     % 检查文件是否齐全
%                     missingFiles = setdiff(requiredFiles, existingFiles);
%                     if ~isempty(missingFiles)
%                         logContent = [logContent, sprintf('  文件夹 %s 下缺少文件: %s\n', obsFolderPath, strjoin(missingFiles, ', '))];
%                     end
%                 end
%             end
%         end
%     end
% end
% 
% % 生成带有时间戳的汇报文件
% logFileName = fullfile(targetFolder, sprintf('folder_structure_report_%s.txt', datestr(datetime('now'), 'yyyy-mm-dd_HH-MM-SS')));
% fid = fopen(logFileName, 'w');
% if fid == -1
%     error('无法创建汇报文件：%s', logFileName);
% else
%     fprintf(fid, '%s', logContent);
%     fclose(fid);
% end
% 
% disp(['汇报文件已生成：', logFileName]);
%% 把格式已经是obs%02d_%02d，但是obs%02d与文件夹名称不相符合的文件批量重命名
% % % 目标文件夹路径
% targetFolder = 'D:\work\VIVOskinExpe\analyze\expRes\f06iadd\all'; % 替换为你的目标文件夹路径
% 
% % 获取目标文件夹下所有符合格式 obs%02d 的子文件夹
% subfolders = dir(fullfile(targetFolder, 'obs*')); % 获取所有符合条件的子文件夹
% subfolders = subfolders([subfolders.isdir]); % 筛选出文件夹
% subfolders = {subfolders.name}'; % 获取文件夹名称
% subfolders = subfolders(~ismember(subfolders, {'.', '..'})); % 去掉'.'和'..'目录
% 
% % 初始化日志内容
% logContent = sprintf('重命名日志 - %s\n', datestr(datetime('now'), 'yyyy-mm-dd HH:MM:SS'));
% 
% % 遍历每个子文件夹
% for i = 1:length(subfolders)
%     folderName = subfolders{i}; % 当前子文件夹名称
%     folderPath = fullfile(targetFolder, folderName); % 当前子文件夹路径
% 
%     % 获取当前子文件夹下所有符合格式 obs%02d_%02d.csv 的文件
%     files = dir(fullfile(folderPath, 'obs*.csv')); % 获取所有符合条件的文件
%     files = {files.name}'; % 获取文件名称
% 
%     % 遍历每个文件
%     for j = 1:length(files)
%         fileName = files{j}; % 当前文件名
%         % [~, prefix, suffix] = fileparts(fileName); % 分离文件名和扩展名
%         % prefix = strrep(prefix, '_', ''); % 去掉文件名中的下划线
%         slashes=find(fileName=='_');
%         prefix=fileName(1:slashes-1);
%         suffix=fileName(slashes+1:end);
% 
%         % 检查文件名前缀是否与文件夹名称一致
%         if ~strcmp(prefix, folderName)
%             % 如果不一致，修改文件名前缀
%             newFileName = [folderName, '_', suffix]; % 构造新文件名
%             oldFilePath = fullfile(folderPath, fileName); % 原文件路径
%             newFilePath = fullfile(folderPath, newFileName); % 新文件路径
% 
%             % 重命名文件
%             movefile(oldFilePath, newFilePath);
%             logContent = [logContent, sprintf('文件重命名：%s -> %s\n', fileName, newFileName)];
%         end
%     end
% end
% 
% % 生成带有时间戳的日志文件
% logFileName = fullfile(targetFolder, sprintf('rename_log_%s.txt', datestr(datetime('now'), 'yyyy-mm-dd_HH-MM-SS')));
% fid = fopen(logFileName, 'w');
% if fid == -1
%     error('无法创建日志文件：%s', logFileName);
% else
%     fprintf(fid, '%s', logContent);
%     fclose(fid);
% end
% 
% disp(['日志文件已生成：', logFileName]);

%% 把一个文件夹下面所有xls或者xlsx文件另存为csv文件
% 目标文件夹路径
% targetFolder = 'D:\work\VIVOskinExpe\analyze\expRes\femalevivoi\model_group\obs01'; % 替换为你的目标文件夹路径
% 
% % 获取目标文件夹下所有 .xls 或 .xlsx 文件
% files = dir(fullfile(targetFolder, '*.xls'));
% files = [files; dir(fullfile(targetFolder, '*.xlsx'))];
% fileNames = {files.name}'; % 获取文件名
% 
% % 初始化日志内容
% logContent = sprintf('文件复制日志 - %s\n', datestr(datetime('now'), 'yyyy-mm-dd HH:MM:SS'));
% 
% % 遍历每个文件并复制为 CSV 格式
% for i = 1:length(fileNames)
%     fileName = fileNames{i}; % 当前文件名
%     [~, name, ~] = fileparts(fileName); % 获取文件名（不含扩展名）
%     csvFileName = [name, '.csv']; % 构造 CSV 文件名
%     sourceFilePath = fullfile(targetFolder, fileName); % 源文件路径
%     destFilePath = fullfile(targetFolder, csvFileName); % 目标文件路径
% 
%     try
%         % 复制文件并更改扩展名
%         copyfile(sourceFilePath, destFilePath);
% 
%         % 记录到日志
%         logContent = [logContent, sprintf('复制文件: %s -> %s\n', fileName, csvFileName)];
%     catch ME
%         % 如果复制失败，记录错误信息
%         logContent = [logContent, sprintf('复制失败: %s，错误信息: %s\n', fileName, ME.message)];
%     end
% end
% 
% % 生成带有时间戳的日志文件
% logFileName = fullfile(targetFolder, sprintf('copy_log_%s.txt', datestr(datetime('now'), 'yyyy-mm-dd_HH-MM-SS')));
% fid = fopen(logFileName, 'w');
% if fid == -1
%     error('无法创建日志文件：%s', logFileName);
% else
%     fprintf(fid, '%s', logContent);
%     fclose(fid);
% end
% 
% disp(['日志文件已生成：', logFileName]);
%% 生成dlabNpicname
% lastPart="f06i";
% source_folder="D:\work\VIVOskinExpe\renderCode\rendered\33_i_lL_C_CATed\drawable";
% files=dir(fullfile(source_folder,strcat(lastPart,"*.jpg")));
% 
% for i = 1:numel(files) 
%     slashes0 = find(files(i).name == '_');
%     slashes1 = find(files(i).name == '[');
%     slashes2 = find(files(i).name == ',');
%     slashes3 = find(files(i).name == ']');
%     % lastPart=files(i).name(1:4);
%     % light_name=files(i).name(5:slashes0-1);
%     picname=files(i).name(1:slashes1-1);
%     dlab(i,1) = str2double(files(i).name(slashes1+1:slashes2(1)-1));
%     dlab(i,2) = str2double(files(i).name(slashes2(1)+1:slashes2(2)-1));
%     dlab(i,3) = str2double(files(i).name(slashes2(2)+1:slashes3-1));
%     dlabsNpicname{i,1}=[dlab(i,1),dlab(i,2),dlab(i,3)];
%     dlabsNpicname{i,2}=picname;
% end
% save_folder=fullfile("dlabsNpicname","ruddy");
% if ~exist(save_folder,"dir")
%     mkdir(save_folder);
% end
% save(fullfile(save_folder,lastPart),"dlabsNpicname");
% disp("d")
%%  重命名文件夹为obs%02d
% 
% % % 获取目标文件夹路径
% targetFolder = 'D:\work\VIVOskinExpe\analyze\expRes\pre\non_model'; % 替换为你的目标文件夹路径
% 
% % 获取目标文件夹下所有的子文件夹
% subfolders = dir(fullfile(targetFolder, '*')); % 获取目标文件夹下的所有条目
% subfolders = subfolders([subfolders.isdir]); % 筛选出文件夹
% subfolders = {subfolders.name}'; % 获取文件夹名称
% subfolders = subfolders(~ismember(subfolders, {'.', '..'})); % 去掉'.'和'..'目录
% 
% % 初始化日志内容
% logContent = sprintf('重命名日志 - %s\n', datestr(datetime('now'), 'yyyy-mm-dd HH:MM:SS'));
% 
% % 遍历子文件夹并重命名
% for i = 1:length(subfolders)
%     oldName = fullfile(targetFolder, subfolders{i}); % 原文件夹完整路径
%     newName = fullfile(targetFolder, sprintf('obs%02d', i)); % 新文件夹名称
% 
%     % 检查新文件夹是否已存在
%     if exist(newName, 'dir')
%         warning('新文件夹 %s 已存在，跳过重命名。\n', newName);
%         logContent = [logContent, sprintf('跳过重命名：%s -> %s（目标文件夹已存在）\n', subfolders{i}, newName)];
%     else
%         % 重命名文件夹
%         movefile(oldName, newName);
%         logContent = [logContent, sprintf('重命名：%s -> %s\n', subfolders{i}, newName)];
%     end
% end
% 
% % 生成带有时间戳的日志文件
% logFileName = fullfile(targetFolder, sprintf('rename_folder_log_%s.txt', datestr(datetime('now'), 'yyyy-mm-dd_HH-MM-SS')));
% fid = fopen(logFileName, 'w');
% if fid == -1
%     error('无法创建日志文件：%s', logFileName);
% else
%     fprintf(fid, '%s', logContent);
%     fclose(fid);
% end
% 
% disp(['日志文件已生成：', logFileName]);


%% attribute 2 number

% % 
% % % % 定义文件夹路径
% source_folder = 'D:\work\VIVOskinExpe\analyze\expRes\pre\non_model'; % 替换为你的文件夹路径
% 
% % 定义属性名称和对应的替换字符串
% attribute_names = ["Preference", "Attractiveness", "Feminine", "Cooperative", ...
%         "Youth", "Healthy", "Fidelity","Harmony", "Fair", "Ruddy"];
% attribute_names_old = ["Preference", "Attractiveness", "Feminine", "Cooperative", ...
%     "Youth", "Healthy", "Precise reproduction", ...
%     "suit the environment or not", "white-skinned", "ruddy"];
% replace_strings = ["01", "02", "03", "04", "05", "06", "07", "08", "09", "10"];
% 
% % 获取所有格式为 obs%02d 的子文件夹
% subFolders = dir(fullfile(source_folder, 'obs*'));
% subFolders = subFolders([subFolders.isdir]); % 只保留文件夹
% 
% % 创建重命名日志文件
% timestamp = datestr(now, 'yyyy-mm-dd_HH-MM-SS');
% rename_log_file = fullfile(source_folder, strcat('rename_log_', timestamp, '.txt'));
% fid = fopen(rename_log_file, 'w'); % 打开日志文件
% if fid == -1
%     error('无法创建重命名日志文件');
% end
% 
% % 遍历每个子文件夹
% % for i_obs = 16:16
% for i_obs = 1:length(subFolders)
%     % 获取当前子文件夹路径
%     folderPath = fullfile(source_folder, subFolders(i_obs).name);
% 
%     % 获取子文件夹中的所有文件
%     files = dir(fullfile(folderPath, '*.*'));
%     files = files(~[files.isdir]); % 只保留文件，排除文件夹
% 
%     % 遍历每个文件
%     for i_file = 1:length(files)
%         % 获取当前文件的名称和路径
%         oldName = files(i_file).name;
%         oldPath = fullfile(folderPath, oldName);
% 
%         % 检查文件名是否包含属性名称
%         for i_attr = 1:length(attribute_names)
%             if contains(oldName, attribute_names(i_attr))||contains(oldName, attribute_names_old(i_attr))
%                 % 提取文件后缀
%                 [~, ~, ext] = fileparts(oldName);
% 
%                 % 生成新文件名
%                 newName = strcat(subFolders(i_obs).name, '_', replace_strings(i_attr), ext);
%                 newPath = fullfile(folderPath, newName);
% 
%                 % 重命名文件
%                 movefile(oldPath, newPath);
% 
%                 % 记录重命名操作到日志文件
%                 fprintf(fid, '重命名: %s -> %s\n', oldPath, newPath);
%                 break; % 找到匹配的属性名称后跳出循环
%             end
%         end
%     end
% end
% 
% % 关闭日志文件
% fclose(fid);
% disp('重命名完成，日志文件已生成。');
%% 移除重复
% % 定义源文件夹和目标文件夹
% sourceDir = 'D:\work\VIVOskinExpe\renderCode\rendered\33_i_wei\PNp\90\summer\m05i\H3K';
% destDir = fullfile(sourceDir,"bf_0202");
% if ~exist(destDir,"dir")
%     mkdir(destDir);
% end
% % 获取源文件夹中所有的jpg文件
% jpgFiles = dir(fullfile(sourceDir, '*.jpg'));
% 
% % 提取文件名和日期信息
% fileNames = {jpgFiles.name};
% fileDates = [jpgFiles.datenum];
% 
% % 创建一个结构体来存储分组信息
% fileGroups = struct();
% 
% % 遍历所有文件，按文件名前缀分组
% for i = 1:length(fileNames)
%     % 提取文件名前缀
%     fileName = fileNames{i};
%     prefix = extractBefore(fileName, '_'); % 假设文件名前缀是以'_'分隔的
% 
%     % 如果前缀不存在于结构体中，则创建一个新的组
%     if ~isfield(fileGroups, prefix)
%         fileGroups.(prefix) = [];
%     end
% 
%     % 将当前文件的信息添加到对应的组中
%     fileGroups.(prefix) = [fileGroups.(prefix); struct('name', fileName, 'date', fileDates(i))];
% end
% 
% % 遍历每个组，处理文件
% groupNames = fieldnames(fileGroups);
% for i = 1:length(groupNames)
%     groupName = groupNames{i};
%     groupFiles = fileGroups.(groupName);
% 
%     % 如果组中有2张及以上图片
%     if length(groupFiles) >= 2
%         % 按日期排序
%         [~, sortedIdx] = sort([groupFiles.date]);
%         sortedFiles = groupFiles(sortedIdx);
% 
%         % 移动除最后一张外的其他图片
%         for j = 1:length(sortedFiles)-1
%             sourceFile = fullfile(sourceDir, sortedFiles(j).name);
%             destFile = fullfile(destDir, sortedFiles(j).name);
%             movefile(sourceFile, destFile);
%         end
%     end
% end
% 
% disp('文件移动完成。');
%% 合成预览大图
% source_folder="D:\work\VIVOskinExpe\renderCode\rendered\33_i_wei\PNp\90\summer\f06i";
% dest_folder=fullfile(source_folder,"bigImg");
% % 检查目标文件夹是否存在，如果不存在则创建
% if ~exist(dest_folder, 'dir')
%     mkdir(dest_folder);
% end
% 
% % 获取所有以 H、M 或 L 开头的子文件夹
% sub_folders = dir(fullfile(source_folder));
% sub_folders = sub_folders([sub_folders.isdir]); % 只保留文件夹
% delete_idx=[];
% for i_sub=1:size(sub_folders,1)
%     if ~ismember(sub_folders(i_sub).name(1),["H","M","L"])
%         delete_idx=[delete_idx,i_sub];        
%     end
% end
% sub_folders(delete_idx)=[];
% % 遍历每个子文件夹
% for i_sub = 1:length(sub_folders)
%     output_file=fullfile(dest_folder,strcat(sub_folders(i_sub).name,".jpg"));
%     con_folder=fullfile(sub_folders(i_sub).folder,sub_folders(i_sub).name);
%     concatenate_images2(con_folder, 8,output_file);
% end



%%
% % 定义文件夹路径
% parent_folder = 'D:\work\VIVOskinExpe\analyze\expRes\female78i\all_ruddy_normal'; % 替换为实际的父文件夹路径
% 
% 
% % 获取所有格式为 obs%02d 的子文件夹
% sub_folders = dir(fullfile(parent_folder, 'obs*'));
% sub_folders = sub_folders([sub_folders.isdir]); % 只保留文件夹
% 
% % 遍历每个子文件夹
% for i = 1:length(sub_folders)
%     sub_folder_path = fullfile(parent_folder, sub_folders(i).name);
% 
%     % 查找所有格式为 obs%02d_%02d.csv 的文件
%     csv_files = dir(fullfile(sub_folder_path, 'obs*_*.csv'));
% 
%     % 遍历每个 CSV 文件
%     for j = 1:length(csv_files)
%         file_name = csv_files(j).name;
% 
%         % 提取文件名中的第二个 %02d
%         underscore_indices = strfind(file_name, '_'); % 找到所有下划线的位置
%         if length(underscore_indices) >= 1
%             % 获取第二个数字的起始位置
%             second_number_start = underscore_indices(end) + 1;
%             second_number_end = strfind(file_name, '.csv') - 1;
% 
%             % 提取第二个数字
%             second_number_str = file_name(second_number_start:second_number_end);
%             second_number = str2double(second_number_str);
% 
%             % 如果第二个数字不为 10，则删除文件
%             if second_number ~= 10
%                 file_path = fullfile(sub_folder_path, file_name);
%                 delete(file_path);
%                 fprintf('Deleted file: %s\n', file_path);
%             end
%         end
%     end
% end
% 
% disp('Deletion complete.');
%% 移除ruddy_abnormal
% % 定义源文件夹和目标文件夹
% source_folder = 'D:\work\VIVOskinExpe\analyze\expRes\female78i\all_ruddy_normal'; % 替换为实际的源文件夹路径
% dest_folder = fullfile(source_folder,'discarded'); % 替换为实际的目标文件夹路径
% if ~exist(dest_folder,"dir")
%     mkdir(dest_folder);
% end
% % 获取所有以 'obs' 开头的子文件夹
% sub_folders = dir(fullfile(source_folder, 'obs*'));
% sub_folders = sub_folders([sub_folders.isdir]); % 只保留文件夹
% 
% % 遍历每个子文件夹
% for i = 1:length(sub_folders)
%     sub_folder_path = fullfile(source_folder, sub_folders(i).name);
% 
%     % 查找以 'obs' 开头且以 '_10.csv' 结尾的文件
%     csv_files = dir(fullfile(sub_folder_path, 'obs*_10.csv'));
% 
%     % 遍历每个 CSV 文件
%     for j = 1:length(csv_files)
%         file_path = fullfile(sub_folder_path, csv_files(j).name);
% 
%         % 读取 CSV 文件
%         data = readtable(file_path, 'ReadVariableNames', false);
% 
%         % 检查第二列以 '8k_30' 结尾的行
%         is_8k_30 = endsWith(string(data.Var2), '8k_30'); % 第二列是字符串
%         third_column_values = data.Var3(is_8k_30); % 第三列是数字
% 
%         % 如果所有符合条件的行的第三列都是 3
%         if all(third_column_values == 3)
%             % 生成带时间戳的新文件名
%             new_file_name = sprintf('%s.csv', csv_files(j).name(1:end-4));
%             new_file_path = fullfile(dest_folder, new_file_name);
% 
%             % 移动文件
%             movefile(file_path, new_file_path);
%             fprintf('Moved file: %s to %s\n', file_path, new_file_path);
%         end
%     end
% end
% 
% disp('Processing complete.');
%% 生成STRESS summary文件
% % % 定义主文件夹路径
% main_folder = 'D:\work\VIVOskinExpe\analyze\AnalyseResults\summer\female41i\all'; % 替换为你的主文件夹路径
% 
% % 获取所有以 %02d 打头的子文件夹
% subfolders = dir(fullfile(main_folder)); % 匹配以两位数字开头的文件夹
% subfolders = subfolders([subfolders.isdir]); % 只保留文件夹
% subfolders = subfolders(~ismember({subfolders.name}, {'.', '..'})); 
% % 初始化结果存储
% results = cell(length(subfolders) + 1, 3); % 用于存储结果
% results{1, 1} = 'Folder';
% results{1, 2} = 'Mean_STRESS_inter';
% results{1, 3} = 'Mean_STRESS_intra';
% 
% % 遍历每个子文件夹
% folder_name_inds=[];
% for attribute = 1:length(subfolders)
%     folder_name = subfolders(attribute).name;
% 
%     folder_path = fullfile(main_folder, folder_name);
% 
%     % 检查是否存在 STRESS.mat 文件
%     stress_file = fullfile(folder_path, 'STRESS.mat');
%     mean_inter=[];mean_intra=[];
%     if exist(stress_file, 'file')
%         % 加载 STRESS.mat 文件
%         load(stress_file, 'STRESS_inter', 'STRESS_intra');
% 
%         % 计算 STRESS_inter 和 STRESS_intra 的第二列均值
%         mean_inter(:,attribute) = cell2mat(STRESS_inter(:, 2));
%         mean_intra(:,attribute) = cell2mat(STRESS_intra(:, 2));
% 
%     else
%         mean_inter(:,attribute)=NaN;
%         mean_intra(:,attribute)=NaN;
%     end
% end
% mean_inter_mean=nanmean(mean_inter,2);
% mean_intra_mean=nanmean(mean_intra,2);
% 
% 
% % 创建结果 cell 数组
% results = cell(length(subfolders) + 1, 3); % 加1是为了添加表头
% results{1, 1} = 'obs'; % 表头
% results{1, 2} = 'mean_intra_mean'; % 表头
% results{1, 3} = 'mean_inter_mean'; % 表头
% 
% % 填充文件夹名称和均值
% for i_obs = 1:size(mean_inter_mean,1)
%     results{i_obs + 1, 1} = sprintf("obs%02d",i_obs); % 文件夹名称
%     results{i_obs + 1, 2} = mean_intra_mean(i_obs); % mean_intra_mean
%     results{i_obs + 1, 3} = mean_inter_mean(i_obs); % mean_inter_mean
% end
% 
% % 将结果写入 Excel 文件
% output_file = fullfile(main_folder, 'STRESS_inds.xlsx');
% writecell(results, output_file);
% 
% disp(['结果已保存到: ', output_file]);
%% 生成STRESS summary文件
% % % 定义主文件夹路径
% main_folder = 'D:\work\VIVOskinExpe\analyze\AlalyseResults\summer\male59i\all'; % 替换为你的主文件夹路径
% 
% % 获取所有以 %02d 打头的子文件夹
% subfolders = dir(fullfile(main_folder)); % 匹配以两位数字开头的文件夹
% subfolders = subfolders([subfolders.isdir]); % 只保留文件夹
% 
% % 初始化结果存储
% results = cell(length(subfolders) + 1, 3); % 用于存储结果
% results{1, 1} = 'Folder';
% results{1, 2} = 'Mean_STRESS_inter';
% results{1, 3} = 'Mean_STRESS_intra';
% 
% % 遍历每个子文件夹
% for i = 1:length(subfolders)
%     folder_name = subfolders(i).name;
%     folder_path = fullfile(main_folder, folder_name);
% 
%     % 检查是否存在 STRESS.mat 文件
%     stress_file = fullfile(folder_path, 'STRESS.mat');
%     if exist(stress_file, 'file')
%         % 加载 STRESS.mat 文件
%         load(stress_file, 'STRESS_inter', 'STRESS_intra');
% 
%         % 计算 STRESS_inter 和 STRESS_intra 的第二列均值
%         mean_inter = mean(cell2mat(STRESS_inter(:, 2)));
%         mean_intra = mean(cell2mat(STRESS_intra(:, 2)));
% 
%         % 存储结果
%         results{i + 1, 1} = folder_name;
%         results{i + 1, 2} = mean_inter;
%         results{i + 1, 3} = mean_intra;
%     else
%         % 如果文件不存在，标记为 NaN
%         results{i + 1, 1} = folder_name;
%         results{i + 1, 2} = NaN;
%         results{i + 1, 3} = NaN;
%     end
% end
% 
% % 将结果写入 Excel 文件
% output_file = fullfile(main_folder, 'STRESS_summary.xlsx');
% writecell(results, output_file);
% 
% disp(['结果已保存到: ', output_file]);
%% 批量数文件
% % 源文件夹路径
% source_folder = 'D:\work\VIVOskinExpe\analyze\expRes\male39i\all';
% 
% % 获取所有子文件夹
% sub_folders = dir(source_folder);
% sub_folders = sub_folders([sub_folders.isdir]); % 只保留文件夹
% sub_folders = sub_folders(~ismember({sub_folders.name}, {'.', '..'})); % 去掉 . 和 ..
% 
% % 创建重命名日志文件
% timestamp = datestr(now, 'yyyymmdd_HHMMSS');
% log_file = fullfile(source_folder, ['rename_log_', timestamp, '.txt']);
% fid = fopen(log_file, 'w'); % 打开日志文件
% if fid == -1
%     error('无法创建日志文件。');
% end
% 
% % 遍历每个子文件夹
% for i = 1:length(sub_folders)
%     % 获取当前子文件夹名称
%     folder_name = sub_folders(i).name;
% 
%     % 检查文件夹名称是否符合 obs%02d 格式
%     if startsWith(folder_name, 'obs') && length(folder_name) == 5 && all(isstrprop(folder_name(4:5), 'digit'))
%         % 提取文件夹名称中的 %02d
%         folder_num = str2double(folder_name(4:5));
% 
%         % 获取当前子文件夹下所有文件
%         csv_files = dir(fullfile(source_folder, folder_name, '*.csv'));
% 
%         % 初始化计数器
%         valid_csv_count = 0; % 符合格式的 CSV 文件数量
%         invalid_files = {};  % 不符合格式的文件列表
% 
%         % 遍历每个 CSV 文件
%         for j = 1:length(csv_files)
%             % 获取当前 CSV 文件名称
%             csv_name = csv_files(j).name;
% 
%             % 检查文件名称是否符合 obs%02d_%02d.csv 格式
%             if startsWith(csv_name, 'obs') && length(csv_name) == 12 && ...
%                     all(isstrprop(csv_name(4:5), 'digit')) && ...
%                     csv_name(6) == '_' && ...
%                     all(isstrprop(csv_name(7:8), 'digit')) && ...
%                     strcmp(csv_name(end-3:end), '.csv')
%                 % 提取文件名中的两个 %02d
%                 file_num1 = str2double(csv_name(4:5)); % 提取 obs 后的第一个数字
%                 file_num2 = str2double(csv_name(7:8)); % 提取 obs 后的第二个数字
% 
%                 % 检查第一个 %02d 是否与文件夹名称中的 %02d 一致
%                 if file_num1 ~= folder_num
%                     % 构建新文件名
%                     new_csv_name = sprintf('obs%02d_%02d.csv', folder_num, file_num2);
% 
%                     % 构建旧文件和新文件的完整路径
%                     old_file = fullfile(source_folder, folder_name, csv_name);
%                     new_file = fullfile(source_folder, folder_name, new_csv_name);
% 
%                     % 重命名文件
%                     movefile(old_file, new_file);
% 
%                     % 记录重命名操作到日志文件
%                     fprintf(fid, 'Renamed: %s -> %s\n', old_file, new_file);
%                     fprintf('Renamed: %s -> %s\n', old_file, new_file);
%                 end
% 
%                 % 增加符合格式的 CSV 文件计数
%                 valid_csv_count = valid_csv_count + 1;
%             else
%                 % 记录不符合格式的文件
%                 invalid_files{end+1} = csv_name;
%             end
%         end
% 
%         % 检查 CSV 文件数量是否为 20
%         if (i<=15&&valid_csv_count == 9)||(i>15&&valid_csv_count == 10)
%             fprintf(fid, 'Folder %s: 有且仅有 20 个 CSV 文件，符合要求。\n', folder_name);
%         else
%             fprintf(fid, 'Folder %s: CSV 文件数量不符合要求（实际数量：%d）。\n', folder_name, valid_csv_count);
%         end
% 
%         % 报告不符合格式的文件
%         if ~isempty(invalid_files)
%             fprintf(fid, 'Folder %s: 发现以下不符合格式的文件：\n', folder_name);
%             for k = 1:length(invalid_files)
%                 fprintf(fid, '  - %s\n', invalid_files{k});
%             end
%         end
%     end
% end
% 
% % 关闭日志文件
% fclose(fid);
% disp(['重命名日志已保存到: ', log_file]);
%% 复制HD65到一个文件夹
% % 源文件夹路径
% source_folder = 'D:\work\VIVOskinExpe\renderCode\dsp';
% 
% % 目标文件夹路径
% dest_folder = 'dsp\HD65';
% if ~exist(dest_folder, 'dir')
%     mkdir(dest_folder); % 如果目标文件夹不存在，则创建
% end
% 
% 
% 
% % 获取所有子文件夹
% sub_folders = dir(source_folder);
% sub_folders = sub_folders([sub_folders.isdir]); % 只保留文件夹
% sub_folders = sub_folders(~ismember({sub_folders.name}, {'.', '..'})); % 去掉 . 和 ..
% 
% % 遍历每个子文件夹
% for i = 1:length(sub_folders)
%     % 获取当前子文件夹名称
%     folder_name = sub_folders(i).name;
% 
%     % 检查文件夹名称是否符合 f%02d 或 m%02d 格式
%     if (startsWith(folder_name, 'f') || startsWith(folder_name, 'm')) ...
%             && length(folder_name) == 3 ...
%             && all(isstrprop(folder_name(2:3), 'digit'))
%         % 构建 HD65.jpg 文件的完整路径
%         hd65_file = fullfile(source_folder, folder_name, 'i', 'HD65.jpg');
% 
%         % 检查文件是否存在
%         if exist(hd65_file, 'file')
%             % 构建新文件名（在 HD65.jpg 前加上文件夹名称）
%             new_filename = [folder_name, '_HD65.jpg'];
% 
%             % 构建目标文件的完整路径
%             dest_file = fullfile(dest_folder, new_filename);
% 
%             % 复制文件到目标文件夹
%             copyfile(hd65_file, dest_file);
%             fprintf('Copied: %s -> %s\n', hd65_file, dest_file);
%         else
%             fprintf('File not found: %s\n', hd65_file);
%         end
%     end
% end
% 
% disp('All files processed.');
% concatenate_images1(dest_folder,10);
%% 复制33到一个文件夹
% % 定义源文件夹和目标文件夹
% source_folder = 'D:\work\VIVOskinExpe\renderCode\rendered\33_i_lL_C\femalevivoi'; % 替换为源文件夹路径
% target_folder = fullfile(source_folder, '33'); % 目标文件夹路径
% 
% % 创建目标文件夹（如果不存在）
% if ~exist(target_folder, 'dir')
%     mkdir(target_folder);
% end
% 
% % 获取源文件夹中所有 jpg 文件
% jpg_files = dir(fullfile(source_folder, '*.jpg'));
% 
% % 遍历所有 jpg 文件
% for i = 1:length(jpg_files)
%     file_name = jpg_files(i).name; % 获取文件名
% 
%     % 查找文件名中 '_' 和 '[' 之间的字符串
%     underscore_idx = strfind(file_name, '_'); % 找到所有 '_' 的位置
%     bracket_idx = strfind(file_name, '[');    % 找到所有 '[' 的位置
% 
%     % 检查是否同时存在 '_' 和 '['
%     if ~isempty(underscore_idx) && ~isempty(bracket_idx)
%         % 提取 '_' 和 '[' 之间的字符串
%         target_str = file_name(underscore_idx(end)+1 : bracket_idx(1)-1);
% 
%         % 如果字符串为 '33'，则复制文件
%         if strcmp(target_str, '33')
%             source_file = fullfile(source_folder, file_name); % 源文件路径
%             target_file = fullfile(target_folder, file_name); % 目标文件路径
%             copyfile(source_file, target_file); % 复制文件
%             fprintf('Copied: %s\n', file_name); % 打印复制信息
%         end
%     end
% end
% 
% disp('File copying completed.');
%% 数文件是否齐全
% % 
% % % 指定目录
% directory = 'D:\work\VIVOskinExpe\analyze\expRes\male39i';
% 
% % 获取所有以 'obs' 开头的文件夹
% obsFolders = dir(fullfile(directory, 'obs*'));
% obsFolders = obsFolders([obsFolders.isdir]);  % 只保留文件夹
% 
% % 遍历每个文件夹
% for i = 1:length(obsFolders)
%     folderPath = fullfile(directory, obsFolders(i).name);
% 
%     % 获取文件夹中的所有 CSV 文件
%     csvFiles = dir(fullfile(folderPath, '*.csv'));
% 
%     % 检查是否有 9 个 CSV 文件
%     if length(csvFiles) ~= 9
%         fprintf('文件夹 %s 中的 CSV 文件数量不是 9 个。\n', obsFolders(i).name);
%         continue;
%     end
% 
%     % 获取所有 CSV 文件的大小
%     fileSizes = [csvFiles.bytes];
% 
%     % 检查文件大小是否相仿（例如，大小差异不超过 10%）
%     maxSize = max(fileSizes);
%     minSize = min(fileSizes);
%     if (maxSize - minSize) / maxSize > 0.1
%         fprintf('文件夹 %s 中的 CSV 文件大小差异较大。\n', obsFolders(i).name);
%     else
%         fprintf('文件夹 %s 中的 CSV 文件大小相仿。\n', obsFolders(i).name);
%     end
% end
%%  MATLAB 脚本：删除指定文件夹下所有大小为 0 KB 的文件


% % 设置文件夹路径（请修改为你的目标文件夹路径）
% folderPath = 'D:\work\VIVOskinExpe\analyze\expRes\male59i'; % 替换为你的文件夹路径
% 
% 检查文件夹是否存在
% if ~isfolder(folderPath)
%     error('指定的文件夹路径不存在: %s', folderPath);
% end
% 
% 获取文件夹下所有文件的信息
% fileList = dir(fullfile(folderPath, '*')); % 获取所有文件和文件夹
% fileList = fileList(~[fileList.isdir]);    % 过滤掉文件夹，只保留文件
% 
% 初始化计数器
% deletedFileCount = 0;
% 
% 遍历文件列表
% for i = 1:length(fileList)
%     filePath = fullfile(folderPath, fileList(i).name); % 文件的完整路径
%     fileInfo = dir(filePath); % 获取文件信息
% 
%     如果文件大小为 0 KB，则删除
%     if fileInfo.bytes == 0
%         fprintf('正在删除 0 KB 文件: %s\n', filePath);
%         delete(filePath); % 删除文件
%         deletedFileCount = deletedFileCount + 1; % 更新计数器
%     end
% end
% 
% 输出结果
% if deletedFileCount > 0
%     fprintf('删除完成！共删除了 %d 个 0 KB 文件。\n', deletedFileCount);
% else
%     fprintf('未找到 0 KB 文件。\n');
% end

%% xls 2 csv
% % 指定文件夹路径
% folderPath = 'D:\work\VIVOskinExpe\analyze\expRes\femalevivoi\obs08'; % 替换为你的文件夹路径
% 
% 
% % 获取文件夹中的所有 .xls 文件
% files = dir(fullfile(folderPath, '*.xls'));
% 
% % 遍历每个文件
% for i = 1:length(files)
%     % 获取当前文件的完整路径
%     oldFilePath = fullfile(folderPath, files(i).name);
% 
%     % 构建新的 .csv 文件名
%     [~, fileName, ~] = fileparts(files(i).name);
%     newFilePath = fullfile(folderPath, [fileName, '.csv']);
% 
%     % 重命名文件
%     movefile(oldFilePath, newFilePath);
% 
%     % 打印日志
%     disp(['已重命名文件: ', files(i).name, ' -> ', [fileName, '.csv']]);
% end
% 
% disp('所有文件重命名完成。');

%% 重命名


%% 单个文件夹重命名
% % 文件夹路径
% folderPath = 'D:\work\VIVOskinExpe\analyze\expRes\femalevivoi\all\obs16'; % 替换为你的文件夹路径
% 
% % 获取文件夹中的所有 .csv 文件
% files = dir(fullfile(folderPath, '*.csv'));
% 
% timestamp = datestr(now, 'yyyy-mm-dd_HH-MM-SS'); % 格式为：年-月-日_时-分-秒
% 
% % 打开日志文件用于写入，文件名包含时间戳
% logFile = fopen(fullfile(folderPath, ['rename_log_', timestamp, '.txt']), 'w');
% 
% % 遍历每个文件
% for i = 1:length(files)
%     % 获取旧文件名
%     oldName = files(i).name;
% 
%     % 检查文件名长度是否大于 10 个字符
%     if length(oldName) <= 10
%         continue; % 如果文件名长度不大于 10，跳过
%     end
% 
%     % 提取前两个数字
%     digits = regexp(oldName, '\d{2}', 'match');
%     if isempty(digits)
%         continue; % 如果文件名中没有数字，跳过
%     end
%     firstTwoDigits = digits{1}; % 取前两个数字
% 
%     % 构建新文件名
%     [~, folderName, ~] = fileparts(folderPath); % 获取文件夹名字
%     newName = sprintf('%s_%s.csv', folderName, firstTwoDigits);
% 
%     % 重命名文件
%     movefile(fullfile(folderPath, oldName), fullfile(folderPath, newName));
% 
%     % 写入日志文件
%     fprintf(logFile, '%s %s\n', oldName, newName);
% end
% 
% % 关闭日志文件
% fclose(logFile);
% 
% % 打印完成信息
% disp(['文件夹 ', folderPath, ' 处理完成，日志已生成。']);

%% 批量重命名
% 主文件夹路径
% mainFolderPath = 'D:\work\VIVOskinExpe\analyze\expRes\femalevivoi\model\obs01'; % 替换为你的主文件夹路径
% 
% % 获取所有格式为 obs%02d 的子文件夹
% subFolders = dir(fullfile(mainFolderPath, 'obs*'));
% subFolders = subFolders([subFolders.isdir]); % 只保留文件夹
% 
% % 遍历每个子文件夹
% for k = 1:length(subFolders)
%     % 获取当前子文件夹路径
%     folderPath = fullfile(mainFolderPath, subFolders(k).name);
% 
%     % 获取文件夹中的所有 .csv 文件
%     files = dir(fullfile(folderPath, '*.csv'));
% 
%     % 打开日志文件用于写入
%     logFile = fopen(fullfile(folderPath, 'rename_log.txt'), 'w');
% 
%     % 遍历每个文件
%     for i = 1:length(files)
%         % 获取旧文件名
%         oldName = files(i).name;
% 
%         % 检查文件名长度是否大于 10 个字符
%         if length(oldName) <= 10
%             continue; % 如果文件名长度不大于 10，跳过
%         end
% 
%         % 提取前两个数字
%         digits = regexp(oldName, '\d{2}', 'match');
%         if isempty(digits)
%             continue; % 如果文件名中没有数字，跳过
%         end
%         firstTwoDigits = digits{1}; % 取前两个数字
% 
%         % 构建新文件名
%         [~, folderName, ~] = fileparts(folderPath); % 获取文件夹名字
%         newName = sprintf('%s_%s.csv', folderName, firstTwoDigits);
% 
%         % 重命名文件
%         movefile(fullfile(folderPath, oldName), fullfile(folderPath, newName));
% 
%         % 写入日志文件
%         fprintf(logFile, '%s %s\n', oldName, newName);
%     end
% 
%     % 关闭日志文件
%     fclose(logFile);
% 
%     % 打印完成信息
%     disp(['子文件夹 ', subFolders(k).name, ' 处理完成，日志已生成。']);
% end
% 
% disp('所有子文件夹处理完成。');
%% 对于一些没有%02d格式的被试
% % % 指定文件夹路径
% folderPath = 'D:\work\VIVOskinExpe\analyze\expRes\femalevivoi\obs07'; % 替换为你的文件夹路径
% 
% 
% % 获取文件夹中的所有 .csv 文件
% files = dir(fullfile(folderPath, '*.csv'));
% 
% % 获取文件夹名字
% [~, folderName, ~] = fileparts(folderPath);
% 
% % 遍历每个文件
% for i = 1:length(files)
%     % 获取旧文件名
%     oldName = files(i).name;
% 
%     % 找到所有下划线的位置
%     underscorePositions = find(oldName == '_');
% 
%     % 确保至少有两个下划线
%     if length(underscorePositions) < 2
%         continue; % 如果不足两个下划线，跳过
%     end
% 
%     % 提取前两个下划线之间的内容
%     startIdx = underscorePositions(1) + 1; % 第一个下划线后的位置
%     endIdx = underscorePositions(2) - 1;   % 第二个下划线前的位置
%     numberStr = oldName(startIdx:endIdx);  % 提取数字部分
% 
%     % 将数字转换为数值并格式化为 %02d
%     number = str2double(numberStr);
%     if isnan(number)
%         continue; % 如果提取的内容不是数字，跳过
%     end
%     formattedNumber = sprintf('%02d', number);
% 
%     % 构建新文件名：文件夹名字_格式化数字.csv
%     newName = [folderName, '_', formattedNumber, '.csv'];
% 
%     % 重命名文件
%     movefile(fullfile(folderPath, oldName), fullfile(folderPath, newName));
% 
%     % 打印日志
%     fprintf('重命名: %s -> %s\n', oldName, newName);
% end
% 
% disp('重命名完成。');
%%  重命名单个文件夹下的文件
% folderPath = 'D:\work\VIVOskinExpe\analyze\expRes\femalevivoi\model_group\obs01'; % 替换为你的文件夹路径
% 
% % 获取文件夹中的所有 .xls 文件
% files = dir(fullfile(folderPath, '*.csv'));
% 
% % 打开日志文件用于写入
% logFile = fopen(fullfile(folderPath, 'rename_log.txt'), 'w');
% 
% % 遍历每个文件
% for i = 1:length(files)
%     % 获取旧文件名
%     oldName = files(i).name;
% 
%     % 提取前两个数字
%     digits = regexp(oldName, '\d{2}', 'match');
%     if isempty(digits)
%         continue; % 如果文件名中没有数字，跳过
%     end
%     firstTwoDigits = digits{1}; % 取前两个数字
% 
%     % 构建新文件名
%     [~, folderName, ~] = fileparts(folderPath); % 获取文件夹名字
%     newName = sprintf('%s_%s.xls', folderName, firstTwoDigits);
% 
%     % 重命名文件
%     movefile(fullfile(folderPath, oldName), fullfile(folderPath, newName));
% 
%     % 写入日志文件
%     fprintf(logFile, '%s %s\n', oldName, newName);
% end
% 
% % 关闭日志文件
% fclose(logFile);
% 
% disp('重命名完成，日志已生成。');