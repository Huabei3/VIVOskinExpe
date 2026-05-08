function concatenate_images1noSerial(save_folder, n_col)
    % 间隙大小（像素）
    gap = 30; 

    % 读取输入目录中的所有JPG和PNG图片文件
    image_files = dir(fullfile(save_folder, "*.jpg"));
    image_files = [image_files; dir(fullfile(save_folder, "*.png"))];
    if isempty(image_files)
        error('No images found in the specified directory.');
    end
    
    % 读取第一张图片并获取其大小作为基准高度
    first_image = imread(fullfile(save_folder, image_files(1).name));
    [first_rows, ~, channels] = size(first_image);
    
    num_images = length(image_files);
    resized_images = cell(1, num_images);
    for i = 1:num_images
        img = imread(fullfile(save_folder, image_files(i).name));
        [rows, cols, ~] = size(img);
        scale_factor = first_rows / rows; 
        new_cols = round(cols * scale_factor); 
        resized_images{i} = imresize(img, [first_rows, new_cols]);
    end
    
    % 计算总行数
    num_rows = ceil(num_images / n_col);
    
    % 计算每一行的宽度，并找出最大宽度
    row_widths = zeros(1, num_rows);
    for i = 1:num_images
        r = ceil(i / n_col);
        [~, cols, ~] = size(resized_images{i});
        % 宽度累加：图片宽 + 间隙（如果是该行最后一张则不加间隙）
        row_widths(r) = row_widths(r) + cols;
        if mod(i, n_col) ~= 0 && i ~= num_images
            row_widths(r) = row_widths(r) + gap;
        end
    end
    max_row_width = max(row_widths);
    
    % 计算总高度：(图片高度 * 行数) + (间隙 * (行数-1))
    total_height = (first_rows * num_rows) + (gap * (num_rows - 1));
    
    % 创建白色背景的画布
    concatenated_image = 255 * ones(total_height, max_row_width, channels, 'uint8');
    
    % 放置图片
    for i = 1:num_images
        % 计算当前图片所在的行和列索引
        row_idx = ceil(i / n_col);
        col_idx_in_row = mod(i-1, n_col) + 1;
        
        % 计算起始行坐标
        start_row = (row_idx - 1) * (first_rows + gap) + 1;
        
        % 计算起始列坐标（需要累加当前行之前图片的宽度和间隙）
        start_col = 1;
        for j = (row_idx-1)*n_col + 1 : i-1
            [~, prev_cols, ~] = size(resized_images{j});
            start_col = start_col + prev_cols + gap;
        end
        
        [h, w, ~] = size(resized_images{i});
        concatenated_image(start_row:start_row+h-1, start_col:start_col+w-1, :) = resized_images{i};
    end
    
    % 保存结果
    output_folder = fullfile(save_folder, 'concatenated');
    if ~exist(output_folder, 'dir')
        mkdir(output_folder);
    end
    output_file = fullfile(output_folder, 'bigImg_with_gap.png');
    imwrite(concatenated_image, output_file);
    fullfile(pwd,output_folder)
    
    fprintf('Concatenated image with gaps saved to %s\n', output_file);
end

%%
% concatenate_images1noSerial("D:\work\VIVOskinExpe\analyze\ellip_pic_p\efit_p\compare_thesis_pre\exclude_this",4)



