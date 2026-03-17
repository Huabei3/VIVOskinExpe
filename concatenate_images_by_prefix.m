function concatenate_images_by_prefix(source_folder, prefixes_map)
    % 定制的图片拼接函数，按前缀分行
    % source_folder: 主源目录
    % prefixes_map: 包含前缀和对应文件路径的 Map

    output_folder = fullfile(source_folder, 'concatenated_by_prefix');
    if ~exist(output_folder, 'dir')
        mkdir(output_folder);
    end
    output_file = fullfile(output_folder, 'bigImg_by_prefix.jpg');

    all_image_files_in_source = dir(fullfile(source_folder, "*.jpg"));
    if isempty(all_image_files_in_source)
        error('No JPG images found in the specified source directory for main concatenation.');
    end

    % 读取第一张图片并获取其大小，作为参考高度
    first_image_overall = imread(fullfile(source_folder, all_image_files_in_source(1).name));
    [first_rows_overall, ~, channels] = size(first_image_overall);

    concatenated_rows = {}; % 存储每行的拼接图像
    
    prefix_keys_sorted = sort(keys(prefixes_map)); % 按字母顺序处理前缀，保持一致性

    for k_prefix = 1:length(prefix_keys_sorted)
        current_prefix = prefix_keys_sorted{k_prefix};
        files_for_current_prefix = prefixes_map(current_prefix);
        
        current_row_images = cell(1, length(files_for_current_prefix));
        current_row_total_width = 0;

        % 调整当前前缀所有图片的高度
        for i = 1:length(files_for_current_prefix)
            img = imread(files_for_current_prefix{i});
            [rows, cols, ~] = size(img);
            scale_factor = first_rows_overall / rows;
            new_cols = round(cols * scale_factor);
            
            resized_img = imresize(img, [first_rows_overall, new_cols]);

            % 在图片上添加文本
            font_size_number = round(new_cols / 10);
            font_size_number = min(font_size_number, round(first_rows_overall / 5));
            text_position_number = [new_cols - font_size_number*2, first_rows_overall - font_size_number*1.5];
            font_size_number = min(font_size_number,200);
            
            % 使用前缀和图片编号作为文本
            text_to_add = sprintf('%s-%d', current_prefix, i);
            img_with_text = insertText(resized_img, text_position_number, text_to_add, ...
                'FontSize', font_size_number, 'TextColor', [255, 255, 255], 'BoxOpacity', 0);
            
            current_row_images{i} = img_with_text;
            current_row_total_width = current_row_total_width + size(img_with_text, 2);
        end
        
        % 拼接当前前缀的图片成一行
        if ~isempty(current_row_images)
            % 创建一个空白行图像
            max_width_for_row = current_row_total_width; % 确保这一行能容纳所有图
            
            % 对于单行拼接，使用 cat(2, ...) 即可
            concatenated_row_img = cat(2, current_row_images{:});
            concatenated_rows{end+1} = concatenated_row_img;
        end
    end

    if isempty(concatenated_rows)
        fprintf('No images to concatenate in main source folder.\n');
        return;
    end

    % 计算最终拼接图像的总高度和最大宽度
    total_final_height = 0;
    max_final_width = 0;
    for i = 1:length(concatenated_rows)
        total_final_height = total_final_height + size(concatenated_rows{i}, 1);
        max_final_width = max(max_final_width, size(concatenated_rows{i}, 2));
    end
    
    % 创建最终的空白拼接图像（白色背景）
    final_concatenated_image = 255 * ones(total_final_height, max_final_width, channels, 'uint8');

    % 将每一行放入最终图像
    current_y_offset = 1;
    for i = 1:length(concatenated_rows)
        row_img = concatenated_rows{i};
        [r, c, ~] = size(row_img);
        final_concatenated_image(current_y_offset : current_y_offset + r - 1, 1 : c, :) = row_img;
        current_y_offset = current_y_offset + r;
    end

    imwrite(final_concatenated_image, output_file);
    fprintf('Main concatenated image by prefix saved to %s\n', output_file);
end