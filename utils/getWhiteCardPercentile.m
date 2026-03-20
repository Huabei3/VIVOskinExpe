function whiteCardPercentile = getWhiteCardPercentile(img, crop_rect_info, picIndex)
%GETWHITECARDPERCENTILE 计算白卡亮度在全图亮度排序中的百分位
%
% 输入:
%   img             - 三通道图像 (RGB 或 XYZ) [H x W x 3]
%   crop_rect_info  - 白卡裁剪矩形信息 [N x 4]，每行 [x, y, width, height]
%                     参考 main_rs.m 中的使用方式
%   picIndex        - 当前图片的索引 (用于从 crop_rect_info 中取对应行)
%
% 输出:
%   whiteCardPercentile - 白卡平均亮度在全图亮度排序中的百分位
%                         百分位<35% 提示逆光，>70% 提示顺光

    % 确保 img 是 double 类型
    img = double(img);
    
    % 计算 Y 通道 (亮度)
    if size(img, 3) == 3
        % 使用标准亮度公式：Y = 0.2126*R + 0.7152*G + 0.0722*B
        img_Y = 0.2126 * img(:, :, 1) + 0.7152 * img(:, :, 2) + 0.0722 * img(:, :, 3);
    else
        img_Y = img;
    end
    
    % 验证 crop_rect_info
    if nargin < 3 || isempty(crop_rect_info) || picIndex > size(crop_rect_info, 1)
        warning('无效的 crop_rect_info 或 picIndex');
        whiteCardPercentile = NaN;
        return;
    end
    
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
    
    whiteCardRegion = img_Y(y:y+h-1, x:x+w-1);
    
    if isempty(whiteCardRegion) || all(whiteCardRegion(:) == 0)
        warning('白卡区域提取失败');
        whiteCardPercentile = NaN;
        return;
    end
    
    % 计算白卡区域平均亮度
    whiteCardMeanY = mean(whiteCardRegion(:));
    
    % 计算白卡亮度在全图的百分位
    % 即：有多少比例的像素亮度低于白卡平均亮度
    totalPixels = numel(img_Y);
    pixelsBelowWhiteCard = sum(img_Y(:) < whiteCardMeanY);
    whiteCardPercentile = pixelsBelowWhiteCard / totalPixels;
end
