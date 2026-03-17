clear; close all;


% 设置输入目录和输出目录
source_folder = "D:\work\VIVOskinExpe\renderCode\rendered\33_i_wei\PNp\f05i"; % 替换为实际的输入目录路径
dest_folder = fullfile(source_folder, 'big1'); % 替换为实际的输出目录路径

% 确保输出目录存在
if ~exist(dest_folder, 'dir')
    mkdir(dest_folder);
end

% 获取所有子文件夹
all_subfolders = dir(source_folder);
all_subfolders = all_subfolders([all_subfolders.isdir]); % 仅保留文件夹

% 筛选以 "H"、"L" 或 "M" 开头的子文件夹
subfolders = [];
for i = 1:length(all_subfolders)
    folder_name = all_subfolders(i).name;
    if startsWith(folder_name, 'H') || startsWith(folder_name, 'L') || startsWith(folder_name, 'M')
        subfolders = [subfolders; all_subfolders(i)];
    end
end

% 每行放置的图片数量
n = 11;

% 遍历每个子文件夹
for k = 1:length(subfolders)
    current_subfolder = fullfile(source_folder, subfolders(k).name);
    
    % 读取当前子文件夹中的所有 JPG 图片文件
    image_files = dir(fullfile(current_subfolder, '*.jpg'));
    
    if isempty(image_files)
        warning('No JPG images found in folder: %s', current_subfolder);
        continue;
    end
    
    % 读取第一张图片并获取其大小
    first_image = imread(fullfile(current_subfolder, image_files(1).name));
    [first_rows, first_cols, channels] = size(first_image);
    
    % 若图片过大，进行压缩
    first_rows = first_rows / 10;
    
    % 调整所有图片的高度为与第一张图片相同，保持宽高比
    num_images = length(image_files);
    resized_images = cell(1, num_images);
    for i = 1:num_images
        img = imread(fullfile(current_subfolder, image_files(i).name));
        slashes1=find(image_files(i).name=='_');
        slashes2=find(image_files(i).name=='[');
        labels{i}=image_files(i).name(slashes1+1:slashes2-1);
        [rows, cols, ~] = size(img);
        scale_factor = first_rows / rows; % 计算高度缩放比例
        new_cols = round(cols * scale_factor); % 等比例缩放宽度
        resized_images{i} = imresize(img, [first_rows, new_cols]);
    end
    
    % 设置文本的颜色和位置
    text_color_number = [255, 0, 0]; % 红色 (R, G, B) - 用于图像编号
    
    % 在每张图片上添加文本并保存带文本的图片
    for i = 1:num_images
        img = resized_images{i};
        [rows, cols, ~] = size(img);
        
        % 动态计算字体大小，大约为图片宽度的1/20
        font_size_number = round(cols / 5);
        font_size_labels = round(cols / 8);
        
        % 确保字体大小不超过图片尺寸
        font_size_number = min(font_size_number, round(rows / 3));
        font_size_labels = min(font_size_labels, round(rows / 3));
        
        % 动态计算文本位置，确保文本在图片内部且居于右下角
        text_position_number = [cols - font_size_number * 2, rows - font_size_number * 1.5];
        text_position_labels = [cols - font_size_labels*8, rows - font_size_labels*2];

        % 在图片上插入编号
        img_with_text = insertText(img, text_position_number, num2str(i), ...
            'FontSize', font_size_number, 'TextColor', text_color_number, 'BoxOpacity', 0);
            img_with_text = insertText(img, text_position_labels, ...
        labels{i}, ...
        'FontSize', font_size_labels, 'TextColor', text_color_number, 'BoxOpacity', 0);
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
    current_col = 1;
    for i = 1:num_images
        [rows, cols, ~] = size(resized_images{i});
        
        if current_col + cols - 1 > max_row_width
            start_row = start_row + first_rows; % 新行开始
            current_col = 1; % 重置列位置
        end
        
        start_col = current_col;
        concatenated_image(start_row:start_row + rows - 1, start_col:start_col + cols - 1, :) = resized_images{i};
        current_col = current_col + cols; % 更新列位置
        
        % 检查是否需要换行
        if mod(i, n) == 0
            start_row = start_row + rows; % 下一行
            current_col = 1; % 从新行开始
        end
    end
    
    % 保存拼接后的图像
    output_file = fullfile(dest_folder, strcat(subfolders(k).name, '.jpg'));
    imwrite(concatenated_image, output_file);
    
    fprintf('Concatenated image saved to %s\n', output_file);
end

disp('All images processed and saved.');
%%
% % 设置输入目录
% input_folder = "D:\work\VIVOskinExpe\analyze\ellip_pic\ellipse\combined\single\summer"; % 替换为实际的输入目录路径
% 
% % 定义每行放置的图片数量
% n = 7;
% 
% % 定义 picnames_groups 并转换为大写
% picnames_groups = ["h3k","h4k","h5k","h6k","hd65", "h7k","h8k", ...
%                    "m3k","m4k","m5k","m6k","md65","m7k","m8k", ...
%                    "l3k","l4k","l5k","l6k","ld65","l7k","l8k"];
% picnames_groups = upper(picnames_groups); % 转换为大写
% 
% % 获取输入目录下所有以 0 开头的子文件夹
% subfolders = dir(input_folder);
% subfolders = subfolders([subfolders.isdir]); % 仅保留文件夹
% % subfolders = subfolders(startsWith({subfolders.name}, '0')); % 仅保留以 0 开头的文件夹
% 
% % 遍历每个以 0 开头的子文件夹
% for folder_idx = 1:length(subfolders)
%     % 当前子文件夹路径
%     current_folder = fullfile(input_folder, subfolders(folder_idx).name);
% 
%     % 设置输出目录
%     output_folder = fullfile(current_folder, 'big1');
% 
%     % 创建输出文件夹
%     if ~exist(output_folder, 'dir')
%         mkdir(output_folder);
%     end
% 
%     % 读取当前子文件夹中的所有 JPG 图片文件
%     image_files = dir(fullfile(current_folder, '*.jpg'));
% 
%     if isempty(image_files)
%         warning('No JPG images found in folder: %s', current_folder);
%         continue; % 跳过没有图片的文件夹
%     end
% 
%     % 提取文件名中 _ 前面的部分，并与 picnames_groups 匹配
%     file_names = {image_files.name};
%     file_prefixes = cell(size(file_names));
%     for i = 1:length(file_names)
%         % 提取 _ 前面的部分
%         underscore_idx = strfind(file_names{i}, '_');
% 
%         if isempty(underscore_idx)
%             file_prefixes{i} = ''; % 如果没有 _，则前缀为空
%         else
%             file_prefixes{i} = upper(file_names{i}(1:underscore_idx(1)-1)); % 转换为大写
%         end
%     end
% 
%     % 根据 picnames_groups 的顺序对文件进行排序
%     [~, sort_idx] = ismember(file_prefixes, picnames_groups); % 获取匹配的索引
%     [~, sorted_order] = sort(sort_idx); % 按照索引排序
%     image_files = image_files(sorted_order); % 排序后的文件列表
% 
%     % 读取第一张图片并获取其大小
%     first_image = imread(fullfile(current_folder, image_files(1).name));
%     [first_rows, first_cols, channels] = size(first_image);
% 
%     % 若图片过大，进行压缩
%     % first_rows = first_rows / 10;
% 
%     % 将所有图片的高度调整为与第一张图片相同，保持宽高比
%     num_images = length(image_files);
%     resized_images = cell(1, num_images);
%     for i = 1:num_images
%         img = imread(fullfile(current_folder, image_files(i).name));
%         [rows, cols, ~] = size(img);
%         scale_factor = first_rows / rows; % 计算高度缩放比例
%         new_cols = round(cols * scale_factor); % 等比例缩放宽度
%         resized_images{i} = imresize(img, [first_rows, new_cols]);
%     end
% 
%     % 设置文本的颜色和位置
%     text_color_number = [255, 0, 0]; % 橙色 (R, G, B) - 用于图像编号
% 
%     % 在每张图片上添加文本并保存带文本的图片
%     for i = 1:num_images
%         img = resized_images{i};
%         [rows, cols, ~] = size(img);
% 
%         % 动态计算字体大小，大约为图片宽度的1/20
%         font_size_number = round(cols / 20);
%         font_size_labels = round(cols / 20);
% 
%         % 确保字体大小不超过图片尺寸
%         font_size_number = min(font_size_number, round(rows / 3));
%         font_size_labels = min(font_size_labels, round(rows / 3));
% 
%         % 动态计算文本位置，确保文本在图片内部且居于右下角
%         text_position_number = [cols - font_size_number * 2, rows - font_size_number * 1.5];
%         text_position_labels = [cols - font_size_labels * 18, rows - font_size_labels * 2];
% 
%         % 在图片上插入编号
%         img_with_text = insertText(img, text_position_number, num2str(i), ...
%             'FontSize', font_size_number, 'TextColor', text_color_number, 'BoxOpacity', 0);
%                 % 在图片上插入编号
%         img_with_text = insertText(img, text_position_labels, num2str(i), ...
%             'FontSize', labels{i}, 'TextColor', text_color_number, 'BoxOpacity', 0);
%         resized_images{i} = img_with_text;
%     end
% 
%     % 计算拼接图像的总高度和宽度
%     total_height = 0;
%     row_widths = zeros(1, num_images);
%     max_row_width = 0;
%     current_row = 1;
%     for i = 1:num_images
%         [rows, cols, ~] = size(resized_images{i});
%         row_widths(current_row) = row_widths(current_row) + cols;
%         if row_widths(current_row) > max_row_width
%             max_row_width = row_widths(current_row);
%         end
%         if mod(i, n) == 0 || i == num_images
%             total_height = total_height + rows;
%             current_row = current_row + 1;
%         end
%     end
% 
%     % 创建一个空白的拼接图像
%     concatenated_image = zeros(total_height, max_row_width, channels, 'uint8');
% 
%     % 将图片放入拼接图像中
%     start_row = 1;
%     current_row = 1;
%     current_col = 1;
%     for i = 1:num_images
%         [rows, cols, ~] = size(resized_images{i});
% 
%         if current_col + cols - 1 > max_row_width
%             start_row = start_row + first_rows; % 新行开始
%             current_col = 1; % 重置列位置
%         end
% 
%         start_col = current_col;
%         concatenated_image(start_row:start_row + rows - 1, start_col:start_col + cols - 1, :) = resized_images{i};
%         current_col = current_col + cols; % 更新列位置
% 
%         % 检查是否需要换行
%         if mod(i, n) == 0
%             start_row = start_row + rows; % 下一行
%             current_col = 1; % 从新行开始
%         end
%     end
% 
%     % 保存拼接后的图像
%     imshow(concatenated_image);
%     output_file = fullfile(output_folder, strcat(image_files(1).name, '.jpg'));
%     imwrite(concatenated_image, output_file);
% 
%     fprintf('Concatenated image saved to %s\n', output_file);
% end