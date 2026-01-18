clear;
%%
% dir_image=dir("F:\研一\L_N_Preference\oppo_skin_images\OPPO-Skin-Images-2024\" + ...
%     "哈苏-X2D100C-JPEG\用于压缩\*.jpg");
% dir_compressed=['F:\研一\L_N_Preference\oppo_skin_images\OPPO-Skin-Images-2024' ...
%     '\哈苏-X2D100C-JPEG\已压缩'];
dir_image=dir("Z:\homes\Peggy\oppoSkinExperi\picked40\Hassel\*.jpg");
dir_compressed='Z:\homes\Peggy\oppoSkinExperi\picked40\Hassel\downSampled1';
n_image=length(dir_image);
for i_image=1:n_image
    image=imread(strcat(dir_image(i_image).folder,'\',dir_image(i_image).name));
    downsampledImage = downsampleImage(image, 4);
    compressedPath=fullfile(dir_compressed,dir_image(i_image).name);
    imwrite(downsampledImage, compressedPath);
end


function downsampledImage = downsampleImage(image, factor)
    % 输入参数：
    % image - 原始图片
    % factor - 下采样因子，指定每隔多少行和列取一个像素
    
    % 检查输入图像是灰度图还是彩色图
    [rows, cols, channels] = size(image);
    
    % 计算下采样后的图像尺寸
    newRows = ceil(rows / factor);
    newCols = ceil(cols / factor);
    
    % 初始化下采样后的图像
    downsampledImage = zeros(newRows, newCols, channels, class(image));
    
    % 对每个通道进行下采样
    for c = 1:channels
        for i = 1:newRows
            for j = 1:newCols
                % 计算在原图中对应的行列位置
                rowIdx = min((i-1)*factor + 1, rows);
                colIdx = min((j-1)*factor + 1, cols);
                
                % 从原图中取出对应的像素值
                downsampledImage(i, j, c) = image(rowIdx, colIdx, c);
            end
        end
    end
end


