% Set the source and destination folders
source_folder = 'D:\work\VIVOskinExpe\analyze\AnalyseResults1\efit2\scaled';
dest_folder = 'D:\work\VIVOskinExpe\analyze\AnalyseResults1\efit2\scaled\big_pic';
n_col = 5; % Number of columns for the concatenated image

% Check if the source folder exists
if ~isfolder(source_folder)
    fprintf('Source folder "%s" not found.\n', source_folder);
    return;
end

% Create the destination folder if it doesn't exist
if ~isfolder(dest_folder)
    mkdir(dest_folder);
end

% Find all subdirectories
sub_folders = dir(fullfile(source_folder, '*'));
sub_folders = sub_folders([sub_folders.isdir]); % Keep only directories

% Iterate through each first-level subdirectory (f01r, m02r, etc.)
for i = 1:length(sub_folders)
    folder_name = sub_folders(i).name;
    
    % Skip '.' and '..'
    if strcmp(folder_name, '.') || strcmp(folder_name, '..')
        continue;
    end
    
    % Construct the path to the 'non_model' folder
    non_model_path = fullfile(source_folder, folder_name, 'non_model');
    
    if isfolder(non_model_path)
        % Find all subdirectories within 'non_model'
        second_level_folders = dir(fullfile(non_model_path, '*'));
        second_level_folders = second_level_folders([second_level_folders.isdir]);
        
        % Iterate through each second-level subdirectory
        for j = 1:length(second_level_folders)
            second_folder_name = second_level_folders(j).name;
            
            % Skip '.' and '..'
            if strcmp(second_folder_name, '.') || strcmp(second_folder_name, '..')
                continue;
            end
            
            % Construct the path to the 'pre_draw' folder
            pre_draw_path = fullfile(non_model_path, second_folder_name, 'pre_draw');
            
            if isfolder(pre_draw_path)
                % Define the output file name
                output_file_name = sprintf('%s_%s.jpg', folder_name, second_folder_name);
                output_file = fullfile(dest_folder, output_file_name);
                
                fprintf('Processing folder: %s\n', pre_draw_path);
                
                % Call the image concatenation function
                concatenate_images2(pre_draw_path, n_col, output_file);
            end
        end
    end
end
function concatenate_images2(save_folder, n_col, output_file)
    % Read all JPG image files from the input directory
    image_files = dir(fullfile(save_folder, '*.jpg'));

    if isempty(image_files)
        fprintf('No JPG images found in %s\n', save_folder);
        return
    end
    
    % Read the first image and get its size
    first_image = imread(fullfile(save_folder, image_files(1).name));
    [first_rows, first_cols, channels] = size(first_image);
    
    % Resize all images to have the same height as the first image
    num_images = length(image_files);
    resized_images = cell(1, num_images);
    labels = cell(1, num_images);
    
    for i = 1:num_images
        img = imread(fullfile(save_folder, image_files(i).name));
        
        % Extract label from file name
        label = '';
        slashes1 = find(image_files(i).name == '_');
        slashes2 = find(image_files(i).name == '[');
        if ~isempty(slashes1) && ~isempty(slashes2) && slashes1(end) < slashes2(1)
            text_str = image_files(i).name(slashes1(end)+1:slashes2(1)-1);
            if length(text_str) > 10
                if isstrprop(text_str(end-1:end), 'digit')
                    text_str = text_str([1:8, end-1:end]);
                else
                    text_str = text_str(1:10);
                end
            end
            labels{i} = text_str;
        end
        
        [rows, cols, ~] = size(img);
        scale_factor = first_rows / rows;
        new_cols = round(cols * scale_factor);
        resized_images{i} = imresize(img, [first_rows, new_cols]);
    end
    
    % Set text color and add text to each image
    text_color = [255, 0, 0];
    
    for i = 1:num_images
        img = resized_images{i};
        [rows, cols, ~] = size(img);
        
        font_size = round(cols / 10);
        font_size = min(font_size, 200);
        
        % Position for image number
        text_position_number = [cols - 10, rows - 10]; 
        
        img_with_text = insertText(img, text_position_number, num2str(i), ...
            'FontSize', font_size, 'TextColor', text_color, 'BoxOpacity', 0, 'AnchorPoint', 'RightBottom');
        
        % Position for label
        if ~isempty(labels{i})
            label_text = labels{i};
            text_position_labels = [cols - 10, rows - font_size - 20];
            img_with_text = insertText(img_with_text, text_position_labels, label_text, ...
                'FontSize', round(font_size * 0.7), 'TextColor', text_color, 'BoxOpacity', 0, 'AnchorPoint', 'RightBottom');
        end
        
        resized_images{i} = img_with_text;
    end
    
    % Calculate the total width of the concatenated image
    total_width = 0;
    current_row_width = 0;
    
    for i = 1:num_images
        [~, cols, ~] = size(resized_images{i});
        if mod(i - 1, n_col) == 0
            current_row_width = 0;
        end
        current_row_width = current_row_width + cols;
        total_width = max(total_width, current_row_width);
    end
    
    % Calculate the total height of the concatenated image
    num_rows = ceil(num_images / n_col);
    total_height = num_rows * first_rows;
    
    % Create a blank concatenated image with a white background
    concatenated_image = 255 * ones(total_height, total_width, channels, 'uint8');
    
    % Place the images into the concatenated image
    current_row = 0;
    current_col = 0;
    
    for i = 1:num_images
        img = resized_images{i};
        [rows, cols, ~] = size(img);
        
        if mod(i - 1, n_col) == 0 && i > 1
            current_row = current_row + rows;
            current_col = 0;
        end
        
        concatenated_image(current_row + 1 : current_row + rows, current_col + 1 : current_col + cols, :) = img;
        current_col = current_col + cols;
    end
    
    imwrite(concatenated_image, output_file);
    fprintf('Concatenated image saved to %s\n', output_file);
end
fprintf('All image combinations are complete.\n');