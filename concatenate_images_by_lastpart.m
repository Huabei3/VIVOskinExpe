clc;       % 清空命令窗口
clear;     % 清除工作区所有变量
addpath '..'
%% 设置参数
lastParts = {'f04i', 'f05i', 'f06i', 'm04i', 'm05i', 'm06i',...
'f01i', 'f02i', 'f03i', 'm01i', 'm02i', 'm03i',...
'f07i', 'f08i','m07i', 'm08i',...
'f09i', 'f10i','m09i', 'm10i'};
% 定义 lastParts
% lastParts = {'f04r', 'f05r', 'f06r', 'm04r', 'm05r', 'm06r',...
%     'f01r', 'f02r', 'f03r', 'm01r', 'm02r', 'm03r',...
%     'f07r', 'f08r','m07r', 'm08r',...
%     'f09r', 'f10r','m09r', 'm10r'};

% 定义 attribute_names_new 和 attribute 范围
attribute_names_new = ["Preference", "Attractiveness", "Feminine", "Cooperative", ...
    "Youth", "Healthy", "Fidelity","Harmony", "Fair", "Ruddy"];
attribute_range = [1, 2, 3, 4, 5, 6,7, 8, 9, 10];

% 定义基础路径和目标文件夹
base_path = 'D:\\work\\VIVOskinExpe\\analyze\\AnalyseResults_p_free\\efit_p_free\\unscaled';
dest_folder =fullfile(base_path,'Concatenated_Images') ;

% 创建目标文件夹（如果不存在）
if ~exist(dest_folder, 'dir')
    mkdir(dest_folder);
end

%% 遍历每个 lastPart 和 attribute

for lastPartIdx = 1:length(lastParts)
    lastPart = lastParts{lastPartIdx};
    
    for attribute = attribute_range
        attribute_serial = strcat(sprintf("%02d", attribute), attribute_names_new(attribute));
        
        % 构建源文件夹路径
        source_folder = fullfile(base_path, lastPart, 'non_model', attribute_serial, 'pre_draw');
        
        % 检查源文件夹是否存在
        if ~exist(source_folder, 'dir')
            fprintf('源文件夹不存在: %s\n', source_folder);
            continue;
        end
        
        % 获取源文件夹中的所有 jpg 文件
        jpg_files = dir(fullfile(source_folder, '*.jpg'));
        
        if isempty(jpg_files)
            fprintf('源文件夹中没有找到 jpg 文件: %s\n', source_folder);
            continue;
        end
        
        % 对文件名进行排序（可选，根据需要调整排序规则）
        [~, idx] = sort({jpg_files.name});
        jpg_files = jpg_files(idx);
        
        % 读取所有图片
        images = cell(length(jpg_files), 1);
        for i = 1:length(jpg_files)
            img_path = fullfile(source_folder, jpg_files(i).name);
            images{i} = imread(img_path);
        end
        
        % 调用拼接函数
        concatenated_img = concatenate_images1(images);
        
        % 构建保存路径和文件名
        output_filename = strcat('concatenated_', lastPart, '_', attribute_serial, '.jpg');
        output_path = fullfile(dest_folder, output_filename);
        
        % 保存拼接后的图片
        imwrite(concatenated_img, output_path);
        fprintf('已保存拼接图片: %s\n', output_path);
    end
end

%% 图片拼接函数（参考 concatenate_images1 实现）
%% 图片拼接函数（修改为7张图一行）
function concatenated_img = concatenate_images1(images)
    % 确保输入是 cell 数组
    if ~iscell(images)
        error('输入必须是包含图像的 cell 数组');
    end
    
    % 获取所有图像的尺寸
    num_images = length(images);
    heights = zeros(num_images, 1);
    widths = zeros(num_images, 1);
    
    for i = 1:num_images
        if ~isempty(images{i})
            [heights(i), widths(i), ~] = size(images{i});
        else
            heights(i) = 0;
            widths(i) = 0;
        end
    end
    
    % 过滤掉空图像
    valid_indices = heights > 0 & widths > 0;
    images = images(valid_indices);
    heights = heights(valid_indices);
    widths = widths(valid_indices);
    
    if isempty(images)
        error('没有有效的图像进行拼接');
    end
    
    % 设置每行的图片数量
    images_per_row = 7;
    
    % 计算行数
    num_valid_images = length(images);
    num_rows = ceil(num_valid_images / images_per_row);
    
    % 计算每行的最大高度和每列的最大宽度
    max_widths_per_row = zeros(num_rows, 1);
    
    for r = 1:num_rows
        start_idx = (r-1)*images_per_row + 1;
        end_idx = min(r*images_per_row, num_valid_images);
        max_widths_per_row(r) = sum(widths(start_idx:end_idx));
    end
    
    % 计算拼接后图像的总宽度和总高度
    total_width = max(max_widths_per_row);
    total_height = sum(max(heights));  % 假设每行使用该行的最大高度
    
    % 创建拼接后的图像（假设是 RGB 图像）
    concatenated_img = zeros(total_height, total_width, 3, 'uint8');
    
    % 按行列方式拼接图像
    current_height = 1;
    
    for r = 1:num_rows
        start_idx = (r-1)*images_per_row + 1;
        end_idx = min(r*images_per_row, num_valid_images);
        
        % 计算当前行的最大高度
        row_images = images(start_idx:end_idx);
        row_heights = heights(start_idx:end_idx);
        row_widths = widths(start_idx:end_idx);
        row_max_height = max(row_heights);
        
        % 拼接当前行的图像
        current_width = 1;
        for i = 1:length(row_images)
            img = row_images{i};
            img_height = size(img, 1);
            img_width = size(img, 2);
            
            % 确保图像是 RGB 格式
            if size(img, 3) == 1
                img = repmat(img, [1, 1, 3]);
            end
            
            % 计算垂直居中位置
            vertical_offset = floor((row_max_height - img_height) / 2) + current_height;
            
            % 将图像复制到拼接结果中
            concatenated_img(vertical_offset:vertical_offset+img_height-1, current_width:current_width+img_width-1, :) = img;
            
            % 更新当前宽度位置
            current_width = current_width + img_width;
        end
        
        % 更新当前高度位置
        current_height = current_height + row_max_height;
    end
end