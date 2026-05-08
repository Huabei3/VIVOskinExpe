clear; close all;

% 设置输入目录和输出目录
% save_folder="ellip_pic\ellipse_m";
save_folder="ellip_pic\linear\m\CATed\D3";
% save_folder="ellip_pic\ellipse_m_cat\D3";

input_folder = fullfile(save_folder); % 替换为实际的输入目录路径

output_folder = fullfile(save_folder,'big');
disp("begin")


if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end

n = 4; % 每行放置的图片数量

% 读取输入目录中的所有JPG图片文件
image_files = dir(fullfile(input_folder, '*.jpg'));
% image_files = dir(fullfile(input_folder, 'sunset03*.jpg'));

if isempty(image_files)
    error('No JPG images found in the specified directory.');
end

% 读取第一张图片并获取其大小
first_image = imread(fullfile(input_folder, image_files(1).name));
[first_rows, first_cols, channels] = size(first_image);
%若图片过大，进行压缩
% first_rows=first_rows./10;
% 将所有图片的高度调整为与第一张图片相同，保持宽高比
num_images = length(image_files);
resized_images = cell(1, num_images);
for i = 1:num_images
    img = imread(fullfile(input_folder, image_files(i).name));
    [rows, cols, ~] = size(img);
    scale_factor = first_rows / rows; % 计算高度缩放比例
    new_cols = round(cols * scale_factor); % 等比例缩放宽度
    resized_images{i} = imresize(img, [first_rows, new_cols]);
end

% 设置文本的颜色和位置
text_color_number = [255, 255, 255]; % 橙色 (R, G, B) - 用于图像编号


% 在每张图片上添加文本并保存带文本的图片
for i = 1:num_images
    filename=image_files(i).name;
    % dlab_L = regexp(filename, '\[(\d+),', 'tokens');
    % dlab_L=dlab_L{1,1}{1,1};
    % dlab_a = regexp(filename, '\,(\d+),', 'tokens');
    % dlab_a=dlab_a{1,1}{1,1};
    % dlab_b = regexp(filename, '\,(\d+)]', 'tokens');
    % dlab_b=dlab_b{1,1}{1,1};
    % 
    % 
    % dlab_L=str2double(dlab_L);
    % dlab_L=num2str(dlab_L);
    % dlab_a=str2double(dlab_a);
    % dlab_a=num2str(dlab_a);
    % dlab_b=str2double(dlab_b);
    % dlab_b=num2str(dlab_b);

    img = resized_images{i};
    [rows, cols, ~] = size(img);
% %-----------------遮眼睛--------------
%         % 计算黑色矩形块的尺寸
%     rect_height = round(rows / 6);
%     rect_width = round(cols / 3);
%     % 计算黑色矩形块的位置
%     rect_y = round((rows - rect_height) / 2);
%     rect_x = round((cols - rect_width) / 2);
% 
%     % 创建黑色矩形块
%     rect_mask = zeros(rows, cols, 3);
%     rect_mask(rect_y:rect_y+rect_height-1, rect_x:rect_x+rect_width-1, :) = 0; % 填充黑色
% 
%     % 将黑色矩形块添加到图片上
%     img_with_rect = img;
%     img_with_rect(rect_y:rect_y+rect_height-1, rect_x:rect_x+rect_width-1, :) = rect_mask(rect_y:rect_y+rect_height-1, rect_x:rect_x+rect_width-1, :);
% %-------------遮盖眼睛--------------------

    % 动态计算字体大小，大约为图片宽度的1/20
    font_size_number = round(cols / 20);
    font_size_labels = round(cols / 20);

    % 确保字体大小不超过图片尺寸
    font_size_number = min(font_size_number, round(rows / 5));
    font_size_labels = min(font_size_labels, round(rows / 5));

    % 动态计算文本位置，确保文本在图片内部且居于右下角
    text_position_number = [cols - font_size_number*2, rows - font_size_number*1.5];
    text_position_labels = [cols - font_size_labels*9, rows - font_size_labels*1.5];

    % 在图片上插入编号
    img_with_text = insertText(img, text_position_number, sprintf("(%d)",i), ...
        'FontSize', font_size_number, 'TextColor', text_color_number, 'BoxOpacity', 0);

    % % % 在图片上插入其他文本
    % img_with_text = insertText(img_with_text, text_position_labels, ...
    %     strcat(dlab_L,',',dlab_a,',',dlab_b), ...
    %     'FontSize', font_size_labels, 'TextColor', text_color_number, 'BoxOpacity', 0);

    resized_images{i} = img_with_text;
end

% 计算拼接图像的总高度和宽度
total_height = 0;
row_widths = zeros(1, num_images);
max_row_width = 0;
current_row = 1;
for i = 1:num_images
    [rows, cols, ~] = size(resized_images{i});
    row_widths(current_row) = row_widths(current_row) + cols;
    if row_widths(current_row) > max_row_width
        max_row_width = row_widths(current_row);
    end
    if mod(i, n) == 0 || i == num_images
        total_height = total_height + rows;
        current_row = current_row + 1;
    end
end

% 创建一个空白的拼接图像
concatenated_image = zeros(total_height, max_row_width, channels, 'uint8');

% 将图片放入拼接图像中
start_row = 1;
current_row = 1;
current_col = 1;
for i = 1:num_images
    [rows, cols, ~] = size(resized_images{i});
    
    if current_col + cols - 1 > max_row_width
        start_row = start_row + first_rows; % 新行开始
        current_col = 1; % 重置列位置
    end
    
    start_col = current_col;
    concatenated_image(start_row:start_row+rows-1, start_col:start_col+cols-1, :) = resized_images{i};
    current_col = current_col + cols; % 更新列位置

    % 检查是否需要换行
    if mod(i, n) == 0
        start_row = start_row + rows; % 下一行
        current_col = 1; % 从新行开始
    end
end

% 保存拼接后的图像
imshow(concatenated_image);
output_file = fullfile(output_folder, strcat(image_files(1).name,'_bigImg.jpg'));
imwrite(concatenated_image, output_file);

fprintf('Concatenated image saved to %s\n', output_file);
