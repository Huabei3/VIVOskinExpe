function concatenate_images_f(save_folder,n_col,i_nation)

    all_sub_folders = dir(save_folder);
    
    % 3. 过滤掉 '.' 和 '..'
    % 遍历所有子文件夹
    image_files = []; % 创建一个空 cell 数组来存储找到的图片路径
    for k = 1:length(all_sub_folders)
        
        current_folder = all_sub_folders(k);
        
        % 检查是否是文件夹，并且不是 '.' 或 '..'
        if current_folder.isdir && ~strcmp(current_folder.name, '.') && ~strcmp(current_folder.name, '..')
            
            % 4. 构造二级子文件夹 'i' 的路径
            nested_i_folder_path = fullfile(save_folder, current_folder.name, 'i');
            
            % 5. 检查 'i' 文件夹是否存在
            if exist(nested_i_folder_path, 'dir')
                
                % 6. 在 'i' 文件夹中查找所有 JPG 图片
                image_files_in_i = dir(fullfile(nested_i_folder_path, '*.jpg'));
                
                % 7. 如果找到图片，将第一张图片的完整路径添加到列表中
                if ~isempty(image_files_in_i)
                    first_image_path = dir(fullfile(nested_i_folder_path, image_files_in_i(i_nation).name));
                    image_files = [image_files;first_image_path];
                end
                
            end
            
        end
    end

    % 读取第一张图片并获取其大小
    first_image = imread(fullfile(image_files(1).folder, image_files(1).name));
    [first_rows, first_cols, channels] = size(first_image);
    
    % 将所有图片的高度调整为与第一张图片相同，保持宽高比
    num_images = length(image_files);
    resized_images = cell(1, num_images);
    for i = 1:num_images
        img = imread(fullfile(image_files(i).folder, image_files(i).name));
        [rows, cols, ~] = size(img);
        scale_factor = first_rows / rows; % 计算高度缩放比例
        new_cols = round(cols * scale_factor); % 等比例缩放宽度
        resized_images{i} = imresize(img, [first_rows, new_cols]);
    end
    
    % 设置文本的颜色和位置
    text_color_number = [255, 255, 255]; % 红色 (R, G, B) - 用于图像编号
    
    % 在每张图片上添加文本并保存带文本的图片
    for i = 1:num_images
        img = resized_images{i};
        [rows, cols, ~] = size(img);
        
        % 动态计算字体大小，大约为图片宽度的1/20
        font_size_number = round(cols / 10);
        
        % 确保字体大小不超过图片尺寸
        font_size_number = min(font_size_number, round(rows / 5));
        
        % 动态计算文本位置，确保文本在图片内部且居于右下角
        text_position_number = [cols - font_size_number*2, rows - font_size_number*1.5];
        
        % 在图片上插入编号
        font_size_number=min(font_size_number,200);
        img_with_text = insertText(img, text_position_number, num2str(i), ...
            'FontSize', font_size_number, 'TextColor', text_color_number, 'BoxOpacity', 0);
        
        resized_images{i} = img_with_text;
    end
    
    % 计算拼接图像的总高度和宽度
    n = n_col; % 每行放置的图片数量
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
    
    % 创建一个空白的拼接图像（白色背景）
    concatenated_image = 255 * ones(total_height, max_row_width, channels, 'uint8'); % 白色背景    
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
    output_folder = fullfile(save_folder, 'concatenated');
    if ~exist(output_folder, 'dir')
        mkdir(output_folder);
    end
    output_file = fullfile(output_folder, strcat('bigImg',num2str(i_nation),'.jpg'));
    imwrite(concatenated_image, output_file);
    
    fprintf('Concatenated image saved to %s\n', output_file);
end
save_folder="D:\work\VIVOskinExpe\analyze\ellip_pic\efit2\fullpara";
for i_nation=1:4
    concatenate_images_f(save_folder,3,i_nation);
end