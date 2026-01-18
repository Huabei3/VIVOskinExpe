close all; 
clc;       
clear;  
%%
% 获取当前文件夹下的所有JPG文件
source_folder = 'Z:\homes\Peggy\oppoSkinExperi\picked40\iphone';
imageFiles = dir(fullfile(source_folder, '*.jpg'));
save_folder = fullfile(source_folder, 'autoCardMask');
if ~exist(save_folder, 'dir')
    mkdir(save_folder);
end

% 设置颜色相似性的阈值
threshold = 200; % 可以根据需要调整

% 定义四连通邻域（上、下、左、右）
neighbors = [0, 1; 1, 0; 0, -1; -1, 0];

% 循环处理每个图片文件
for i = 1:length(imageFiles)
    % 读取图像
    img = imread(fullfile(imageFiles(i).folder, imageFiles(i).name));
    [rows, cols, ~] = size(img);
    
    % 创建一个交互窗口显示图像
    figure, imshow(img);
    title('点击图片中的一点选择区域');
    
    % 获取用户点击的点
    [x, y] = ginput(1);
    x = round(x);
    y = round(y);
    
    % 获取点击点的RGB值并转换为double类型
    clickedColor = double(squeeze(img(y, x, :)));
    
    % 初始化掩码
    mask = false(rows, cols);
    
    % 使用栈进行DFS
    stack = [x, y];
    
    while ~isempty(stack)
        % 弹出栈顶元素
        point = stack(end, :);
        stack(end, :) = [];
        
        px = point(1);
        py = point(2);
        
        % 跳过已访问的点
        if mask(py, px)
            continue;
        end
        
        % 获取当前点的颜色
        currentColor = double(squeeze(img(py, px, :)));
        
        % 计算颜色差异
        colorDiff = sum((currentColor - clickedColor).^2);
        
        % 如果颜色差异在阈值范围内，标记为属于相似区域
        if colorDiff < threshold
            mask(py, px) = true;
            
            % 将邻近像素点加入栈
            for j = 1:size(neighbors, 1)
                nx = px + neighbors(j, 1);
                ny = py + neighbors(j, 2);
                
                % 检查邻近点是否在图像范围内
                if nx > 0 && nx <= cols && ny > 0 && ny <= rows
                    stack = [stack; nx, ny]; %#ok<AGROW>
                end
            end
        end
    end
    
    % 在交互式窗口中用颜色标识选中的区域
    hold on;
    [B, ~] = bwboundaries(mask, 'noholes');
    for k = 1:length(B)
        boundary = B{k};
        plot(boundary(:,2), boundary(:,1), 'g', 'LineWidth', 2);
    end
    
    % 保存二值掩码图像
    maskImage = uint8(mask) * 255;
    maskFileName = fullfile(save_folder, imageFiles(i).name);
    imwrite(maskImage, maskFileName);
    
    % 关闭当前图像窗口
    close;
end

disp('处理完毕！');
