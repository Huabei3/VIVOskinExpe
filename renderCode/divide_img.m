function grid_img=divide_img(img,downsize)
    %% 按照每个像素块占原图的比重分，如10*10表示将图像分为100块
    [height, width, ~] = size(img);
    % 计算每个小格的尺寸
    grid_height = floor(height / downsize);
    grid_width = floor(width / downsize);
    
    % 初始化一个新的图像，用于存储分割后的小格
    grid_img = cell(downsize+1);
    
    % 分割图像
    k = 1;
    for i = 1:downsize+1
        for j = 1:downsize+1
            % 计算当前小格的位置
            start_row = (i-1) * grid_height + 1;
            end_row = i * grid_height;
            if end_row>height
                end_row=height;
            end 
            start_col = (j-1) * grid_width + 1;
            end_col = j * grid_width;
            if end_col > width
                end_col = width;
            end 
            
            % 提取当前小格的像素
            block = img(start_row:end_row, start_col:end_col, :);
            grid_img{i,j}=block;
            
            k = k + 1;
        end
    end
    
%     figure;montage(blocks)
%     figure;montage(grid_img,'size',[downsize downsize])
end