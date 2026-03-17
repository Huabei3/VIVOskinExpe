%%
load("maleVIVOi_max.mat", "max_ind", "max_MSV");
%%
% 
% specifiedVector = [22,13,22,14,22,21,21,33,30]; % 替换为你的指定 vector
% 源文件夹路径
% 源文件夹路径
sourceFolder = 'D:\work\VIVOskinExpe\renderCode\rendered\33_i_lL_C\maleVIVOi'; % 替换为你的源文件夹路径

% 目标文件夹路径
targetFolder = fullfile(sourceFolder, "H3K_01Preference"); % 替换为你的目标文件夹路径

% 创建目标文件夹
if ~exist(targetFolder, 'dir')
    mkdir(targetFolder);
end

% 获取所有符合 H3K*.jpg 的文件
dir_1light = dir(fullfile(sourceFolder, 'H3K*.jpg'));

% 指定的 vector
specifiedVector = [22, 13, 22, 14, 22, 21, 21, 33, 30]; % 替换为你的指定 vector

% 遍历每个文件
for i_pic = 1:length(dir_1light)
    % 获取文件名
    fileName = dir_1light(i_pic).name;
    
    % 按 _ 分割文件名
    parts = split(fileName, '_');
    if length(parts) < 2
        continue; % 如果文件名中没有 _，跳过
    end
    
    % 提取 _ 后的两个字符
    serialStr = parts{2}(1:2); % 取前两个字符
    serial = str2double(serialStr); % 转换为数字
    
    % 检查 serial 是否在指定的 vector 中
    indices = find(specifiedVector == serial); % 找到所有匹配的索引
    if ~isempty(indices)
        % 对每个匹配的索引，重命名并复制文件
        for idx = indices
            % 重命名文件：在文件名前面加上 index
            newFileName = sprintf('%02d_%s', idx, fileName); % 例如：01_H3K_01.jpg
            % 复制文件到目标文件夹
            sourceFile = fullfile(sourceFolder, fileName);
            targetFile = fullfile(targetFolder, newFileName);
            copyfile(sourceFile, targetFile);
        end
    end
end

disp('文件复制完成。');
%% 复制指定 serial 的图片到目标文件夹
% % 源文件夹路径
% sourceFolder = 'D:\work\VIVOskinExpe\renderCode\rendered\33_i_lL_C\maleVIVOi'; % 替换为你的源文件夹路径
% 
% % 目标文件夹路径
% targetFolder = fullfile(sourceFolder, "max_01"); % 替换为你的目标文件夹路径
% 
% % 创建目标文件夹
% if ~exist(targetFolder, 'dir')
%     mkdir(targetFolder);
% end
% 
% % 获取所有 .jpg 文件
% files = dir(fullfile(sourceFolder, '*.jpg'));
% load("maleVIVOi_max.mat", "max_ind", "max_MSV");
% 
% % 定义每组的 serial（共 21 组，每组一个 serial）
% % groupSerials = max_ind(1, :);
% groupSerials=[22	14	6	6	33	8	7	14	14	33	7	1	1	7	22	6	6	33	33	8	8];
% 
% % 定义 21 个组名（转换为大写）
% picname_group = ["h3k", "h4k", "h5k", "h6k", "h7k", "h8k", "hd65", ...
%                  "l3k", "l4k", "l5k", "l6k", "l7k", "l8k", "ld65", ...
%                  "m3k", "m4k", "m5k", "m6k", "m7k", "m8k", "md65"];
% picname_group = upper(picname_group); % 转换为大写
% 
% % 遍历所有文件
% for i = 1:length(files)
%     % 获取文件名
%     fileName = files(i).name;
% 
%     % 按 _ 分割文件名
%     parts = split(fileName, '_');
%     if length(parts) < 2
%         continue; % 如果文件名中没有 _，跳过
%     end
% 
%     % 获取组名和 serial
%     groupName = upper(parts{1}); % _ 前的部分，转换为大写
%     serialStr = regexp(parts{2}, '\d+', 'match'); % 提取 _ 后的数字
%     if isempty(serialStr)
%         continue; % 如果 _ 后没有数字，跳过
%     end
%     serial = str2double(serialStr{1}); % 转换为数字
% 
%     % 检查组名是否在 picname_group 中
%     groupIndex = find(strcmp(picname_group, groupName));
%     if isempty(groupIndex)
%         continue; % 如果组名不在 picname_group 中，跳过
%     end
% 
%     % 检查 serial 是否匹配
%     if serial == groupSerials(groupIndex)
%         % 复制文件到目标文件夹
%         sourceFile = fullfile(sourceFolder, fileName);
%         targetFile = fullfile(targetFolder, fileName);
%         copyfile(sourceFile, targetFile);
%     end
% end
% 
% disp('文件复制完成。');