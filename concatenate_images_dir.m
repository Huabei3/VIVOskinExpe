function concatenate_images_dir(dir_res, save_filename, n_col)
    % Read all JPG files from the input directory.
    dir_res = dir_res;
    if isempty(dir_res)
        error('No JPG images found in the specified directory: %s', dir_res);
    end
    
    % Read the first image to get its dimensions.
    first_image = imread(fullfile(dir_res(1).folder, dir_res(1).name));
    [first_rows, first_cols, channels] = size(first_image);
    
    % Adjust all images to the same height as the first one, maintaining aspect ratio.
    num_images = length(dir_res);
    resized_images = cell(1, num_images);
    for i = 1:num_images
        img = imread(fullfile(dir_res(i).folder, dir_res(i).name));
        [rows, cols, ~] = size(img);
        scale_factor = first_rows / rows;
        new_cols = round(cols * scale_factor);
        resized_images{i} = imresize(img, [first_rows, new_cols]);
    end
    
    % Set text color for the image numbers.
    text_color_number = [0, 0, 0]; % White
    
    % Add a number to each image.
    for i = 1:num_images
        img = resized_images{i};
        [rows, cols, ~] = size(img);
        
        % Dynamically calculate font size and position.
        font_size_number = round(cols / 20);
        font_size_number = min(font_size_number, round(rows / 5));
        
        % Ensure font size is not excessively large.
        font_size_number = min(font_size_number, 200);
        
        % Position text in the bottom-right corner.
        text_position_number = [cols - font_size_number * 2, rows - font_size_number * 1.5];
        
        % Insert the number text.
        img_with_text = insertText(img, text_position_number, strcat("(",char('a'+i-1),")"), ...
            'FontSize', font_size_number, 'TextColor', text_color_number, 'BoxOpacity', 0);
        
        resized_images{i} = img_with_text;
    end
    
    % Calculate the total dimensions for the final concatenated image.
    num_rows = ceil(num_images / n_col);
    total_height = num_rows * first_rows;
    
    % Find the maximum width of any row.
    max_row_width = 0;
    for i = 1:num_rows
        start_idx = (i - 1) * n_col + 1;
        end_idx = min(i * n_col, num_images);
        
        current_row_width = 0;
        for j = start_idx:end_idx
            [~, cols, ~] = size(resized_images{j});
            current_row_width = current_row_width + cols;
        end
        
        if current_row_width > max_row_width
            max_row_width = current_row_width;
        end
    end
    
    % Create a blank white image to hold the concatenated result.
    concatenated_image = 255 * ones(total_height, max_row_width, channels, 'uint8');
    
    % Place each image into the grid.
    start_row = 1;
    start_col = 1;
    for i = 1:num_images
        [rows, cols, ~] = size(resized_images{i});
        
        concatenated_image(start_row:start_row + rows - 1, start_col:start_col + cols - 1, :) = resized_images{i};
        
        start_col = start_col + cols;
        
        % Check if a new row is needed.
        if mod(i, n_col) == 0
            start_row = start_row + first_rows;
            start_col = 1;
        end
    end
    
    % Save the concatenated image.

    output_file = fullfile( strcat(save_filename, '.jpg'));
    imwrite(concatenated_image, output_file);
    
    fprintf('Concatenated image saved to %s\n', output_file);
end