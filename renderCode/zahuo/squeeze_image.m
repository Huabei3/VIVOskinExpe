% 指定原始图片所在的文件夹路径
srcFolderPath = 'F:\研一\L_N_Preference\oppo_skin_images\OPPO-Skin-Images-2024\哈苏-X2D100C-JPEG\用于压缩\';

% 指定压缩后的图片保存的文件夹路径
destFolderPath = 'F:\研一\L_N_Preference\oppo_skin_images\OPPO-Skin-Images-2024\哈苏-X2D100C-JPEG\已压缩\';

% 如果目标文件夹不存在，则创建它
if ~exist(destFolderPath, 'dir')
    mkdir(destFolderPath);
end

% 获取原始图片文件夹内所有JPEG文件的列表
imageFiles = dir(fullfile(srcFolderPath, '*.jpg'));
nFiles = length(imageFiles);

% 遍历所有图片文件
for k = 1:nFiles
    % 读取每一张图片
    fileName = imageFiles(k).name;
    fullPath = fullfile(srcFolderPath, fileName);
    img = imread(fullPath);
    
    % 指定压缩选项，这里以降低JPEG质量为例
    options = {'jpg', 'Quality', 10};
    
    % 保存压缩后的图片到目标文件夹
    compressedPath = fullfile(destFolderPath, fileName);
    imwrite(img, compressedPath, options{:});
    
    % 打印进度
    fprintf('Processed %d of %d: %s', k, nFiles, fileName);
end

fprintf('All images have been compressed and saved to %s', destFolderPath);