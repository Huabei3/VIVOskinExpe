close all; 
clc;       
clear;  
%%
% 获取当前文件夹下的所有JPG文件
source_folder = 'Z:\homes\Peggy\oppoSkinExperi\picked40\iphone';
imageFiles = dir(fullfile(source_folder, '*.jpg'));
save_folder = fullfile(source_folder, 'RectMask');
if ~exist(save_folder, 'dir')
    mkdir(save_folder);
end

% 循环处理每个图片文件
for i = 1:length(imageFiles)
    % 读取图像
    img = imread(fullfile(imageFiles(i).folder, imageFiles(i).name));
    [rows, cols, ~] = size(img);
    
    % 计算目标宽度和高度
    targetWidth = cols / 3;
    targetHeight = rows / 6;
    
    % 将图像转换为灰度图
    grayImg = rgb2gray(img);
    
    % 边缘检测
    edges = edge(grayImg, 'Canny');
    
    % 形态学操作以填充小的空洞并连接边缘
    se = strel('rectangle', [10, 10]);
    closedEdges = imclose(edges, se);
    
    % 查找所有轮廓
    [B, L] = bwboundaries(closedEdges, 'noholes');
    
    % 初始化变量存储最接近目标宽高的矩形
    bestBoundary = [];
    minWidthDiff = Inf;
    minHeightDiff = Inf;
    
    % 遍历所有轮廓，寻找最接近目标宽高的矩形
    for k = 1:length(B)
        boundary = B{k};
        
        % 获取轮廓的最小外接矩形
        rect = regionprops(poly2mask(boundary(:,2), boundary(:,1), rows, cols), 'BoundingBox');
        if isempty(rect)
            disp("emptyRect");
        end
        boundingBox = rect.BoundingBox;
        
        % 计算宽度和高度
        width = boundingBox(3);
        height = boundingBox(4);
        
        % 计算宽度和高度与目标值的差异
        widthDiff = abs(width - targetWidth);
        heightDiff = abs(height - targetHeight);
        
        % 更新最佳轮廓，如果该轮廓更接近目标宽高
        if widthDiff < minWidthDiff && heightDiff < minHeightDiff
            minWidthDiff = widthDiff;
            minHeightDiff = heightDiff;
            bestBoundary = boundary;
        end
    end
    
    % 如果找到了最佳轮廓
    if ~isempty(bestBoundary)
        % 创建掩码图像
        mask = poly2mask(bestBoundary(:,2), bestBoundary(:,1), rows, cols);
        
        % 创建填充灰色的图像
        grayFill = img;
        grayFill(repmat(mask, [1 1 3])) = 128; % 将灰色填充到检测区域内 (0.5 * 255 = 128)
        
        % 保存结果图像
        saveFileName = fullfile(save_folder, imageFiles(i).name);
        imwrite(grayFill, saveFileName);
    end
end

disp('处理完毕！');

%%

