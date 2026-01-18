close all; 
clc;       
clear;  
%%
% 获取当前文件夹下的所有JPG文件
source_folder = 'D:\work\FirstYearMaster\oppoSkinExperi\picked40\iphone';
imageFiles = dir(fullfile(source_folder, '*.jpg'));
save_folder = fullfile(source_folder, 'RectMask');
if ~exist(save_folder, 'dir')
    mkdir(save_folder);
end

% 循环处理每个图片文件
for i = 1:length(imageFiles)
    % 读取图像
    img = imread(fullfile(imageFiles(i).folder, imageFiles(i).name));
    grayImg = rgb2gray(img);

    % 边缘检测
    edges = edge(grayImg, 'Canny');

    % 形态学操作以填充小的空洞并连接边缘
    se = strel('rectangle', [10, 10]);
    closedEdges = imclose(edges, se);

    % 查找所有轮廓
    [B, L] = bwboundaries(closedEdges, 'noholes');

    % 初始化变量存储最大的近似矩形轮廓
    maxArea = 0;
    bestBoundary = [];

    % 遍历所有轮廓，寻找类似矩形的区域
    for k = 1:length(B)
        boundary = B{k};

        % 使用多边形逼近来简化轮廓
        approxPoly = bwtraceboundary(L, boundary(1,:), 'N', 8, Inf, 'clockwise');

        % 计算逼近多边形的面积和周长
        area = polyarea(approxPoly(:,2), approxPoly(:,1));

        % 找到最大面积的区域
        if area > maxArea
            maxArea = area;
            bestBoundary = approxPoly;
        end
    end

    % 创建掩码图像
    mask = poly2mask(bestBoundary(:,2), bestBoundary(:,1), size(img, 1), size(img, 2));

    % 创建填充灰色的图像
    grayFill = img;
    grayFill(repmat(mask, [1 1 3])) = 128; % 将灰色填充到检测区域内 (0.5 * 255 = 128)

    % 保存结果图像
    saveFileName = fullfile(save_folder, imageFiles(i).name);
    imwrite(grayFill, saveFileName);
end

disp('处理完毕！');
