function concatenate_images1_23(save_folder)
    % 读取输入目录中的所有JPG图片文件
    % image_files = dir(fullfile(save_folder, "*.jpg"));
    image_files = dir(fullfile(save_folder, "a*.jpg"));
    image_files = [image_files; dir(fullfile(save_folder, "L*.jpg"))];
    if isempty(image_files)
        error('No JPG images found in the specified directory.');
    end
    
    % 读取第一张图片并获取其大小
    first_image = imread(fullfile(save_folder, image_files(1).name));
    [first_rows, first_cols, channels] = size(first_image);
    
    % 将所有图片的高度调整为与第一张图片相同，保持宽高比
    num_images = length(image_files);
    resized_images = cell(1, num_images);
    for i = 1:num_images
        img = imread(fullfile(save_folder, image_files(i).name));
        [rows, cols, ~] = size(img);
        scale_factor = first_rows / rows; % 计算高度缩放比例
        new_cols = round(cols * scale_factor); % 等比例缩放宽度
        resized_images{i} = imresize(img, [first_rows, new_cols]);
    end
    
    labels = ["a", "b", "c", "d", "e"];
    % 设置文本的颜色和位置
    text_color_number = [0, 0, 0]; % 黑色 (R, G, B) - 用于图像编号
    
    % 在每张图片上添加文本并保存带文本的图片
    for i = 1:num_images
        img = resized_images{i};
        [rows, cols, ~] = size(img);
        
        % 动态计算字体大小，大约为图片宽度的1/20
        font_size_number = round(rows / 20);
        
        % 确保字体大小不超过图片尺寸
        font_size_number = min(font_size_number, round(rows / 5));
        
        % 动态计算文本位置，确保文本在图片内部且居于右下角
        text_position_number = [cols - font_size_number*2, rows - font_size_number*1.5];
        
        % 在图片上插入编号
        font_size_number = min(font_size_number, 200);
        img_with_text = insertText(img, text_position_number, strcat("(", labels(i), ")"), ...
            'FontSize', font_size_number, 'TextColor', text_color_number, 'BoxOpacity', 0);
        
        resized_images{i} = img_with_text;
    end
    
    % 计算每行的宽度并找出最大宽度
    max_row_width = 0;
    row_widths = zeros(1, ceil((num_images-1)/2) + 1); % 总行数
    
    % 第一张图片单独一行
    [~, cols, ~] = size(resized_images{1});
    row_widths(1) = cols;
    max_row_width = max(max_row_width, cols);
    
    % 计算剩余行的宽度（每行两张图片）
    for row = 2:length(row_widths)
        first_img_idx = 2 + (row-2)*2;
        second_img_idx = first_img_idx + 1;
        
        row_width = 0;
        if first_img_idx <= num_images
            [~, cols, ~] = size(resized_images{first_img_idx});
            row_width = row_width + cols;
        end
        
        if second_img_idx <= num_images
            [~, cols, ~] = size(resized_images{second_img_idx});
            row_width = row_width + cols;
        end
        
        row_widths(row) = row_width;
        max_row_width = max(max_row_width, row_width);
    end
    
    % 计算总高度
    total_height = first_rows * ceil((num_images+1)/2);
    
    % 创建一个空白的拼接图像（白色背景）
    concatenated_image = 255 * ones(total_height, max_row_width, channels, 'uint8'); % 白色背景
    
    % 将图片放入拼接图像中
    start_row = 1;
    for row = 1:length(row_widths)
        current_col = 1;
        
        if row == 1
            % 第一行只有一张图片
            img_idx = 1;
            img = resized_images{img_idx};
            [rows, cols, ~] = size(img);
            
            % 计算左右边距
            margin = (max_row_width - cols) / 2;
            current_col = round(margin) + 1;
            
            concatenated_image(start_row:start_row+rows-1, current_col:current_col+cols-1, :) = img;
        else
            % 后续行有两张图片
            first_img_idx = 2 + (row-2)*2;
            second_img_idx = first_img_idx + 1;
            
            if first_img_idx <= num_images
                img1 = resized_images{first_img_idx};
                [rows1, cols1, ~] = size(img1);
                
                % 计算左右边距
                if second_img_idx <= num_images
                    img2 = resized_images{second_img_idx};
                    [~, cols2, ~] = size(img2);
                    
                    total_cols = cols1 + cols2;
                    margin = (max_row_width - total_cols) / 2;
                    current_col = round(margin) + 1;
                    
                    concatenated_image(start_row:start_row+rows1-1, current_col:current_col+cols1-1, :) = img1;
                    current_col = current_col + cols1;
                    
                    concatenated_image(start_row:start_row+rows1-1, current_col:current_col+cols2-1, :) = img2;
                else
                    % 只有一张图片的情况
                    margin = (max_row_width - cols1) / 2;
                    current_col = round(margin) + 1;
                    
                    concatenated_image(start_row:start_row+rows1-1, current_col:current_col+cols1-1, :) = img1;
                end
            end
        end
        
        % 移动到下一行
        start_row = start_row + first_rows;
    end
    
    % 保存拼接后的图像
    output_folder = fullfile(save_folder, 'concatenated');
    if ~exist(output_folder, 'dir')
        mkdir(output_folder);
    end
    output_file = fullfile(output_folder, strcat('bigImg.jpg'));
    imwrite(concatenated_image, output_file);
    
    fprintf('Concatenated image saved to %s\n', output_file);
end