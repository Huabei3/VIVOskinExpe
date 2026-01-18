clc; clear; close all;

%% 设置输入和输出文件夹
folderPath = 'Z:\homes\Peggy\oppoSkinExperi\picked40\iphone';
output_folder = fullfile(folderPath,'simpleChoseRect', 'chosenRect');
if ~exist(output_folder, "dir")
    mkdir(output_folder);
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

    rect_info = []; % 存储每个矩形区域的信息
    count = 0; % 用户的选取次数
    
    %% 用户交互选取矩形区域
    while true
        % 等待用户操作（按键或点击）
        k = waitforbuttonpress;
        if k == 1  % 用户按下键盘
            key = get(gcf, 'CurrentCharacter');
            if key == 13 % 检查是否是回车键
                break; % 用户按下回车键，退出循环
            end
        else  % 用户单击鼠标
            rect = getrect; % 用户绘制一个矩形
            count = count + 1;
            rect_x = round(rect(1));
            rect_y = round(rect(2));
            rect_width = round(rect(3));
            rect_height = round(rect(4));
            rectangle('Position', [rect_x, rect_y, rect_width, rect_height], 'EdgeColor', 'r', 'LineWidth', 1);
            
            % 保存矩形区域的信息
            rect_info(end+1, :) = [rect_x, rect_y, rect_width, rect_height]; %#ok<AGROW>
        end
    end

    %% 计算每个矩形块的平均RGB
    rect_ave_rgb = zeros(size(rect_info, 1), 3); % 平均RGB存储
    for j = 1:size(rect_info, 1)
        rect_x = rect_info(j, 1);
        rect_y = rect_info(j, 2);
        rect_width = rect_info(j, 3);
        rect_height = rect_info(j, 4);

        % 提取矩形区域的RGB值
        rect_rgb = img(rect_y:(rect_y + rect_height - 1), rect_x:(rect_x + rect_width - 1), :);
        rect_ave_rgb(j, :) = mean(reshape(rect_rgb, [], 3), 1);
    end

    % 保存矩形区域的平均RGB和坐标数据到MAT文件
    if ~isempty(rect_info)
        rect_size = rect_info; % 矩形的坐标和大小
        save(fullfile(output_folder, sprintf('%s_data.mat', fileName(1:end-4))), 'rect_ave_rgb', 'rect_size');
    end

    close(hFig); % 关闭当前图片窗口
end

disp('所有图片处理完毕');
