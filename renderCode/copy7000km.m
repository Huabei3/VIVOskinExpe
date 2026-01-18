% 定义源根目录和目标目录
srcRootDir = ['F:\研一\L_N_Preference\oppo_skin_images\OPPO-Skin-Images-2024\' ...
    '哈苏-X2D100C-JPEG']; % 替换为你的源根目录路径
destDir = ['F:\研一\L_N_Preference\oppo_skin_images\OPPO-Skin-Images-2024\' ...
    '哈苏-X2D100C-JPEG\已压缩']; % 替换为你的目标目录路径

% 确保目标目录存在，如果不存在则创建
if ~exist(destDir, 'dir')
    mkdir(destDir);
end

% 获取根目录下所有子文件夹
subFolders = dir(srcRootDir);
% 保留那些实际上是文件夹的条目
isSub = [subFolders(:).isdir]; %#ok<*NBRAK>
subFolders = {subFolders(isSub).name}';
% 移除'.'和'..'
subFolders(ismember(subFolders, {'.', '..'})) = [];

% 遍历所有子文件夹
for i = 1:length(subFolders)
    subFolderName = subFolders{i};
    fullSubFolderPath = fullfile(srcRootDir, subFolderName);
    
    % 构建待复制文件的完整路径
    srcFilePath = fullfile(fullSubFolderPath, '7000km.jpg');
    
    % 检查文件是否存在
    if exist(srcFilePath, 'file')
        % 定义目标文件路径，使用文件夹名称重命名
        destFilePath = fullfile(destDir, [subFolderName, '7000km.jpg']);
        % 复制文件
        copyfile(srcFilePath, destFilePath);
        fprintf('File copied: %s\n', destFilePath);
    else
        fprintf('File not found in: %s\n', fullSubFolderPath);
    end
end

fprintf('Finished copying files.\n');