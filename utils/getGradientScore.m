function [gradientScore, faceCenter, faceRadius, detectionBox] = getGradientScore(img, faceMask, numRings)
%GETGRADIENTSCORE 计算亮度梯度并在当前图窗标注范围
%
% 输入:
%   img         - 图像矩阵
%   faceMask    - 面部掩码
%   numRings    - 环数 (默认 5)

    if nargin < 3, numRings = 5; end
    
    % 1. 基础预处理
    img_double = double(img);
    [H, W, C] = size(img_double);
    
    % 计算亮度通道 (用于计算梯度)
    if C == 3
        img_Y = 0.2126 * img_double(:,:,1) + 0.7152 * img_double(:,:,2) + 0.0722 * img_double(:,:,3);
    else
        img_Y = img_double;
    end
    
    % 2. 自动人脸检测 (修正 Mask)
    detectionBox = [];
    try
        faceDetector = vision.CascadeObjectDetector();
        bbox = step(faceDetector, img);
        if ~isempty(bbox)
            detectionBox = bbox(1, :);
            % 缩小 mask 范围到检测框内
            [X_g, Y_g] = meshgrid(1:W, 1:H);
            detMask = (X_g >= bbox(1)) & (X_g <= bbox(1)+bbox(3)) & (Y_g >= bbox(2)) & (Y_g <= bbox(2)+bbox(4));
            if any(faceMask(:) & detMask), faceMask = faceMask & detMask; end
        end
    catch
    end

    % 3. 计算几何特征
    [rows, cols] = find(faceMask);
    if isempty(rows), gradientScore = NaN; faceCenter = [NaN,NaN]; faceRadius = NaN; return; end
    
    centerY = mean(rows);
    centerX = mean(cols);
    faceCenter = [centerY, centerX];
    faceRadius = max(sqrt((rows - centerY).^2 + (cols - centerX).^2));
    
    % 4. 可视化部分 (简单直接)
    figure; 
    imshow(img); hold on;
    
    % 画检测框 (蓝色虚线)
    if ~isempty(detectionBox)
        rectangle('Position', detectionBox, 'EdgeColor', 'c', 'LineStyle', '--', 'LineWidth', 1);
    end
    
    % 画中心点 (红叉)
    plot(centerX, centerY, 'rx', 'MarkerSize', 12, 'LineWidth', 2);
    
    % 画圆环 (黄色)
    ringRadii = linspace(0, faceRadius * 1.5, numRings + 1);
    theta = linspace(0, 2*pi, 100);
    for r = ringRadii
        plot(centerX + r*cos(theta), centerY + r*sin(theta), 'y-', 'LineWidth', 1);
    end
    
    % 5. 计算梯度得分
    ringMeans = zeros(numRings, 1);
    [Y_all, X_all] = ndgrid(1:H, 1:W);
    distMap = sqrt((Y_all - centerY).^2 + (X_all - centerX).^2);
    
    for i = 1:numRings
        ringMask = (distMap >= ringRadii(i)) & (distMap < ringRadii(i+1)) & faceMask;
        pixels = img_Y(ringMask);
        if ~isempty(pixels), ringMeans(i) = mean(pixels(pixels > 0)); else ringMeans(i) = NaN; end
    end
    
    validIdx = ~isnan(ringMeans);
    if sum(validIdx) >= 2
        p = polyfit(find(validIdx), ringMeans(validIdx), 1);
        gradientScore = p(1);
    else
        gradientScore = NaN;
    end
    
    title(sprintf('Gradient Score: %.2f', gradientScore));
    hold off;
end

% function [gradientScore, faceCenter, faceRadius, detectionBox] = getGradientScore(img, faceMask, numRings)
% %GETGRADIENTSCORE 计算从人脸中心向边缘的亮度梯度 (精简版)
% %
% % 输入:
% %   img         - 三通道图像 (RGB 或 XYZ) [H x W x 3]
% %   faceMask    - 面部 mask (逻辑矩阵或 0/1 矩阵) [H x W]
% %   numRings    - 可选，采样环数 (默认 5)
% %
% % 输出:
% %   gradientScore  - 亮度梯度得分 (正值：中心亮；负值：中心暗/逆光)
% %   faceCenter     - 人脸中心 [y, x]
% %   faceRadius     - 人脸区域最大半径
% %   detectionBox   - MATLAB 人脸检测的框 [x, y, width, height]
% 
%     if nargin < 3
%         numRings = 5;
%     end
% 
%     % 基础预处理
%     originalFaceMask = faceMask;
%     img = double(img);
%     [H, W, C] = size(img);
% 
%     % 计算 Y 通道 (亮度)
%     if C == 3
%         img_Y = 0.2126 * img(:, :, 1) + 0.7152 * img(:, :, 2) + 0.0722 * img(:, :, 3);
%     else
%         img_Y = img;
%     end
% 
%     % 初始化输出
%     faceCenter = [NaN, NaN];
%     faceRadius = NaN;
%     detectionBox = [];
% 
%     if isempty(faceMask) || ~any(faceMask(:))
%         gradientScore = NaN;
%         return;
%     end
% 
%     % ========== 1. 人脸检测与 Mask 修正 ==========
%     try
%         % 准备检测用图
%         imgForDet = img;
%         if max(imgForDet(:)) > 1, imgForDet = imgForDet / 255; end
%         if C ~= 3, imgForDet = repmat(img_Y/max(img_Y(:)), [1,1,3]); end
% 
%         faceDetector = vision.CascadeObjectDetector();
%         bbox = step(faceDetector, imgForDet);
% 
%         if ~isempty(bbox)
%             detectionBox = bbox(1, :);
%             % 创建检测框 Mask
%             [X_grid, Y_grid] = meshgrid(1:W, 1:H);
%             detMask = (X_grid >= detectionBox(1)) & (X_grid <= detectionBox(1) + detectionBox(3)) & ...
%                       (Y_grid >= detectionBox(2)) & (Y_grid <= detectionBox(2) + detectionBox(4));
% 
%             % 取交集
%             tempMask = faceMask & detMask;
%             if any(tempMask(:))
%                 faceMask = tempMask;
%             else
%                 detectionBox = []; % 交集为空则重置
%             end
%         end
%     catch
%         detectionBox = [];
%     end
% 
%     % ========== 2. 几何特征计算 ==========
%     [rows, cols] = find(faceMask);
%     if isempty(rows)
%         gradientScore = NaN;
%         return;
%     end
% 
%     centerY = mean(rows);
%     centerX = mean(cols);
%     faceCenter = [centerY, centerX];
% 
%     distances = sqrt((rows - centerY).^2 + (cols - centerX).^2);
%     faceRadius = max(distances);
% 
%     % ========== 3. 环形梯度采样 ==========
%     ringRadii = linspace(0, faceRadius * 1.5, numRings + 1);
%     ringMeans = zeros(numRings, 1);
% 
%     [Y_all, X_all] = ndgrid(1:H, 1:W);
%     distMap = sqrt((Y_all - centerY).^2 + (X_all - centerX).^2);
% 
%     for i = 1:numRings
%         % 当前圆环且在 faceMask 内
%         ringMask = (distMap >= ringRadii(i)) & (distMap < ringRadii(i+1)) & faceMask;
% 
%         pixels = img_Y(ringMask);
%         pixels = pixels(pixels > 0); % 排除无效零值
% 
%         if ~isempty(pixels)
%             ringMeans(i) = mean(pixels);
%         else
%             ringMeans(i) = NaN;
%         end
%     end
% 
%     % ========== 4. 梯度拟合 ==========
%     validIdx = ~isnan(ringMeans);
%     if sum(validIdx) >= 2
%         x = find(validIdx);
%         y = ringMeans(validIdx);
%         p = polyfit(x, y, 1);
%         gradientScore = p(1); 
%     else
%         gradientScore = NaN;
%     end
% end