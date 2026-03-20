function skinRatio = getSkinRatio(img, bull)
%GETSKINRATIO 计算肤色区域与全局明度比值
%
% 输入:
%   img       - 三通道图像 (RGB 或 XYZ) [H x W x 3]
%   bull      - 面部 mask 图像 (与 img 同尺寸) [H x W] 或 [H x W x 3]
%
% 输出:
%   skinRatio - 肤色区域平均明度 / 全局平均明度
%               比值<0.65 提示逆光，>0.8 提示顺光

    % 确保 img 是 double 类型
    img = double(img);
    
    % 计算 Y 通道 (亮度)
    if size(img, 3) == 3
        % 使用标准亮度公式：Y = 0.2126*R + 0.7152*G + 0.0722*B
        img_Y = 0.2126 * img(:, :, 1) + 0.7152 * img(:, :, 2) + 0.0722 * img(:, :, 3);
    else
        img_Y = img;
    end
    
    % 处理 bull (mask)
    if size(bull, 3) == 3
        bull_gray = bull(:,:,2);  % 参考 test_backlit.m 中使用绿色通道
    else
        bull_gray = bull;
    end
    mask = bull_gray > 128;  % 二值化
    
    if isempty(mask) || all(mask(:) == 0)
        warning('未找到有效面部 mask');
        skinRatio = NaN;
        return;
    end
    
    % 计算肤色区域平均明度
    skinMeanY = mean(img_Y(mask));
    
    % 计算全局平均明度 (排除纯黑背景)
    validPixels = img_Y(img_Y > 0);
    if isempty(validPixels)
        globalMeanY = mean(img_Y(:));
    else
        globalMeanY = mean(validPixels);
    end
    
    % 计算比值
    skinRatio = skinMeanY / globalMeanY;
end
