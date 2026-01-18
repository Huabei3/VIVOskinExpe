clc;clear;close all;

% 目标最终图像尺寸
targetWidth = 350;
targetHeight = 206;

% 网格布局 (2行3列)
gridRows = 2;
gridCols = 3;

% 图像文件夹路径
folderPath = "D:\work\secondYearMaster\CIC\documents\CIC33-Skin color preference under multi-scene demand_9.15";

% 检查文件夹是否存在
if ~isfolder(folderPath)
    error('指定的文件夹路径不存在。');
end

% 创建临时JPG文件夹
jpgFolder = fullfile(folderPath, 'temp_jpg');
if ~exist(jpgFolder, 'dir')
    mkdir(jpgFolder);
end

% 获取文件夹中所有的PNG文件
filePattern = fullfile(folderPath, '*.png');
theFiles = dir(filePattern);

% 如果没有找到PNG文件，则显示警告并返回
if isempty(theFiles)
    warning('在指定的文件夹中没有找到任何PNG文件。');
    return;
end

% 按文件名排序，确保处理顺序一致
[~, order] = sortrows({theFiles.name}');
theFiles = theFiles(order);

% 读取PNG并转换为JPG保存
jpgFiles = {};
for i = 1:length(theFiles)
    baseFileName = theFiles(i).name;
    fullFileName = fullfile(theFiles(i).folder, baseFileName);
    
    % 读取索引图像及其颜色映射
    [imgData, colorMap] = imread(fullFileName);
    
    % 将索引图像转换为RGB格式
    if ~isempty(colorMap)
        rgbImage = ind2rgb(imgData, colorMap);
    else
        % 如果没有颜色映射，直接转换为RGB
        rgbImage = im2rgb(imgData);
    end
    
    % 保存为JPG
    [~, name, ~] = fileparts(baseFileName);
    jpgFileName = fullfile(jpgFolder, [name '.jpg']);
    imwrite(im2uint8(rgbImage), jpgFileName);
    jpgFiles{i} = jpgFileName;
end

% 读取所有JPG图像
allImages = {};
for i = 1:length(jpgFiles)
    allImages{i} = imread(jpgFiles{i});
end

% 计算网格布局所需的图像数量
maxImages = gridRows * gridCols;
% 如果图像数量超过网格容量，只使用前maxImages个
if length(allImages) > maxImages
    allImages = allImages(1:maxImages);
    warning('图像数量超过%d个(2x3网格)，只使用前%d个图像', maxImages, maxImages);
end

% 计算每张图像的最大可能尺寸（保持比例）
% 先找出所有图像的宽高比
aspectRatios = cellfun(@(img) size(img,2)/size(img,1), allImages);

% 计算网格中每个单元格的最大可能尺寸
% 假设所有图像按比例缩放后宽度相同
% 找出最小的宽高比，它将决定最大可能的单元格宽度
minAspectRatio = min(aspectRatios);

% 计算每个单元格的尺寸
cellWidth = floor(targetWidth / gridCols);
cellHeight = floor(cellWidth / minAspectRatio);

% 确保单元格高度适合网格行数
if cellHeight * gridRows > targetHeight
    cellHeight = floor(targetHeight / gridRows);
    cellWidth = floor(cellHeight * minAspectRatio);
end

% 缩放所有图像以适应单元格（保持原始比例）
scaledImages = cell(size(allImages));
for i = 1:length(allImages)
    origHeight = size(allImages{i}, 1);
    origWidth = size(allImages{i}, 2);
    
    % 计算缩放比例
    scaleW = cellWidth / origWidth;
    scaleH = cellHeight / origHeight;
    scaleFactor = min(scaleW, scaleH);  % 使用较小的缩放比例以确保图像完全在单元格内
    
    % 计算缩放后的尺寸
    newWidth = round(origWidth * scaleFactor);
    newHeight = round(origHeight * scaleFactor);
    
    % 缩放图像
    scaledImages{i} = imresize(allImages{i}, [newHeight, newWidth]);
end

% 创建空白画布用于拼接
stitchedImage = ones(targetHeight, targetWidth, 3, 'uint8') * 255;  % 白色背景

% 计算单元格位置
cellPosWidth = targetWidth / gridCols;
cellPosHeight = targetHeight / gridRows;

% 放置图像到网格中（居中放置）
for i = 1:length(scaledImages)
    % 计算图像在网格中的位置
    row = ceil(i / gridCols);
    col = mod(i - 1, gridCols) + 1;
    
    % 计算放置位置（居中）
    imgHeight = size(scaledImages{i}, 1);
    imgWidth = size(scaledImages{i}, 2);
    
    startRow = round((row - 1) * cellPosHeight + (cellPosHeight - imgHeight) / 2);
    startCol = round((col - 1) * cellPosWidth + (cellPosWidth - imgWidth) / 2);
    
    % 确保不超出边界
    startRow = max(1, startRow);
    startCol = max(1, startCol);
    endRow = min(targetHeight, startRow + imgHeight - 1);
    endCol = min(targetWidth, startCol + imgWidth - 1);
    
    % 调整图像尺寸以适应可用空间
    imgToPlace = scaledImages{i}(1:(endRow - startRow + 1), 1:(endCol - startCol + 1), :);
    
    % 放置图像
    stitchedImage(startRow:endRow, startCol:endCol, :) = imgToPlace;
end

% 显示拼接后的图像
figure;
imshow(stitchedImage);
title('2x3网格拼接后的图像');

% 保存拼接后的图像
output_folder = fullfile(folderPath, 'concatenated');
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end
output_file = fullfile(output_folder, 'grid_bigImg.jpg');
imwrite(stitchedImage, output_file);

fprintf('图像已成功拼接并保存至: %s\n', output_file);
fprintf('拼接后图像尺寸: %d x %d\n', size(stitchedImage, 2), size(stitchedImage, 1));

% 提示临时JPG文件夹的位置
fprintf('转换后的JPG图像保存在: %s\n', jpgFolder);
    