function [whiteCardRatio, whiteCardRegion] = getWhiteCardRatio(img, crop_rect_info, picIndex, visualize)
%GETWHITECARDRATIO 计算白卡区域平均亮度（第二通道）与全局平均亮度的比值
%
% 输入:
%   img             - 三通道图像 (RGB 或 XYZ) [H x W x 3]
%   crop_rect_info  - 白卡裁剪矩形信息 [N x 4]，每行 [x, y, width, height]
%                     参考 main_rs.m 中的使用方式
%   picIndex        - 当前图片的索引 (用于从 crop_rect_info 中取对应行)
%   visualize       - 可选，是否可视化白卡区域 (默认 false)
%
% 输出:
%   whiteCardRatio  - 白卡区域平均亮度（第二通道）/ 全局平均亮度（第二通道）
%                     比值<0.65 提示逆光，>0.8 提示顺光
%   whiteCardRegion - 白卡区域的图像块 (用于调试)

    % 验证 crop_rect_info
    if nargin < 3 || isempty(crop_rect_info) || picIndex > size(crop_rect_info, 1)
        warning('无效的 crop_rect_info 或 picIndex');
        whiteCardRatio = NaN;
        whiteCardRegion = [];
        return;
    end
    
    if nargin < 4
        visualize = false;
    end
    
    % 确保 img 是 double 类型
    img = double(img);
    
    % 获取第二通道（绿色通道或 Y 通道）
    img_Ch2 = img(:, :, 2);
    
    % 获取当前图片的白卡矩形信息
    % 格式：[x, y, width, height] 对应 [col, row, width, height]
    gray_pos = crop_rect_info(picIndex, :);
    x = gray_pos(1);
    y = gray_pos(2);
    w = gray_pos(3);
    h = gray_pos(4);
    
    % 提取白卡区域 (参考 main_rs.m 中的提取方式)
    % 注意：MATLAB 索引是 (row, col) = (y, x)
    if w <= 0 || h <= 0
        % 如果没有指定宽高，默认 30x30 (参考 main_rs.m)
        w = 30;
        h = 30;
    end
    
    whiteCardRegion = img_Ch2(y:y+h-1, x:x+w-1);
    
    if isempty(whiteCardRegion) || all(whiteCardRegion(:) == 0)
        warning('白卡区域提取失败');
        whiteCardRatio = NaN;
        return;
    end
    
    % 计算白卡区域平均亮度（第二通道）
    whiteCardMeanCh2 = mean(whiteCardRegion(:));
    
    % 计算全局平均亮度（第二通道，排除纯黑背景）
    validPixels = img_Ch2(img_Ch2 > 0);
    if isempty(validPixels)
        globalMeanCh2 = mean(img_Ch2(:));
    else
        globalMeanCh2 = mean(validPixels);
    end
    
    % 计算比值
    whiteCardRatio = whiteCardMeanCh2 / globalMeanCh2;
    
    % ========== 可视化：框出白卡区域 ==========
    if visualize
        figure(2);hold on;
        imshow(img./255);hold on;
        % 在当前 figure 上绘制矩形框
        rectangle('Position', [x, y, w, h], ...
            'EdgeColor', 'c', 'LineWidth', 2, 'LineStyle', '-');hold on;
        
        % 在四个角标记
        plot([x, x+w], [y, y], 'c.', 'MarkerSize', 10);
        plot([x, x], [y, y+h], 'c.', 'MarkerSize', 10);
        plot([x+w, x+w], [y, y+h], 'c.', 'MarkerSize', 10);
        plot([x, x+w], [y+h, y+h], 'c.', 'MarkerSize', 10);
    end
end
