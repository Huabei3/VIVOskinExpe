clc; clear; close all;

% 设置输入和输出文件夹
folderPath = 'Z:\homes\Peggy\oppoSkinExperi\picked40\iphone';
output_folder = fullfile(folderPath, 'chosenRect');
if ~exist(output_folder, "dir")
    mkdir(output_folder);
end
grayscaleMask_folder = fullfile(folderPath, 'grayscaleMask');
if ~exist(grayscaleMask_folder, "dir")
    mkdir(grayscaleMask_folder);
end

% 获取当前文件夹下的所有jpg文件
files = dir(fullfile(folderPath, '*.jpg'));
if isempty(files)
    disp('文件夹中没有找到JPG文件');
    return;
end

% 遍历所有JPG文件
for i = 1:length(files)
    fileName = files(i).name;
    filePath = fullfile(folderPath, fileName);
    img = imread(filePath);

    % 显示图片
    hFig = figure('Name', fileName, 'NumberTitle', 'off');
    imshow(img);
    hold on;

    point_info = []; % 存储每个选取点的信息
    count = 0; % 用户的选取次数
    maskImages = {}; % 存储所有的掩码图像

    % 用户交互选取点（6次）
    while count < 6
        % 用户点击图像来选择一个点
        [x, y] = ginput(1); % 获取单个点的坐标
        if isempty(x) || isempty(y)
            break; % 用户按下回车键，退出循环
        end

        count = count + 1;
        point_x = round(x);
        point_y = round(y);
        plot(point_x, point_y, 'r+', 'MarkerSize', 10, 'LineWidth', 1); % 在图上显示用户选择的点

        % 获取选取点的RGB值
        point_rgb = squeeze(img(point_y, point_x, :))';

        % 使用颜料桶算法获取连通区域
        regionMask = regionGrowing(img, point_x, point_y, point_rgb, 30); % 30为色差阈值，可以根据需要调整

        % 创建标记图像，标出连通区域
        maskImage = uint8(regionMask) * 255;
        outputImage = zeros(size(img), 'uint8');
        outputImage(:,:,1) = img(:,:,1) .* uint8(~regionMask) + uint8(regionMask) * 255;
        outputImage(:,:,2) = img(:,:,2) .* uint8(~regionMask) + uint8(regionMask) * 0;
        outputImage(:,:,3) = img(:,:,3) .* uint8(~regionMask) + uint8(regionMask) * 0;

        % 存储掩码图像
        maskImages{count} = maskImage;

        % 保存点的信息（包括RGB值和点坐标）
        point_info(end+1, :) = [point_rgb, point_x, point_y]; %#ok<AGROW>
    end

    % 统一保存处理后的图片
    for j = 1:length(maskImages)
        saveName = sprintf('%s_%d.jpg', fileName(1:end-4), j);
        imwrite(maskImages{j}, fullfile(grayscaleMask_folder, saveName));
    end

    % 保存选取的点数据到MAT文件
    if ~isempty(point_info)
        save(fullfile(output_folder, sprintf('%s_data.mat', fileName(1:end-4))), 'point_info');
    end

    close(hFig); % 关闭当前图片窗口
end

disp('所有图片处理完毕');

function regionMask = regionGrowing(img, seedX, seedY, targetRGB, tolerance)
    % 颜料桶算法，通过色差找到连通区域
    [rows, cols, ~] = size(img);
    regionMask = false(rows, cols);
    toProcess = false(rows, cols);
    toProcess(seedY, seedX) = true;

    while any(toProcess(:))
        [currentY, currentX] = find(toProcess, 1);
        toProcess(currentY, currentX) = false;
        currentRGB = squeeze(double(img(currentY, currentX, :)));
        targetRGB = double(targetRGB);
        currentRGB=double(currentRGB);
        if norm(currentRGB - targetRGB) <= tolerance
            regionMask(currentY, currentX) = true;
            for dx = -1:1
                for dy = -1:1
                    newX = currentX + dx;
                    newY = currentY + dy;
                    if newX > 0 && newX <= cols && newY > 0 && newY <= rows && ~regionMask(newY, newX)
                        toProcess(newY, newX) = true;
                    end
                end
            end
        end
    end
end
