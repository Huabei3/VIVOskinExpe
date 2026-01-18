close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量
%%
%test
largeImageFolderPath = 'Z:\homes\Peggy\work\oppoSkinExperi\picked40\iphone';
smallImageFolderPath = ['Z:\homes\Peggy\work\oppoSkinExperi\picked40\iphone\cropped\test'];
cropRectFolderPath = 'Z:\homes\Peggy\work\oppoSkinExperi\picked40\iphone\cropped\test';
outputFolderPath = ['Z:\homes\Peggy\work\oppoSkinExperi\picked40\iphone\cropped\test'];

% 获取文件信息
largeImageFiles = dir(fullfile(largeImageFolderPath, 'sunset03.jpg'));
smallImageFiles = dir(fullfile(smallImageFolderPath, '*.jpg'));
cropRectFiles = dir(fullfile(cropRectFolderPath, '*.mat'));

% 批量处理
for i = 1:length(smallImageFiles)
    % 读取小图文件名（去掉后缀）
    [~, smallImageName, ~] = fileparts(smallImageFiles(i).name);
    
    % 查找对应的大图文件
    largeImageFile = '';
    for j = 1:length(largeImageFiles)
        [~, largeImageName, ~] = fileparts(largeImageFiles(j).name);
        if contains(smallImageName, largeImageName)
            largeImageFile = largeImageFiles(j).name;
            break;
        end
    end
    
    % 查找对应的cropRect文件
    cropRectFile = '';
    for k = 1:length(cropRectFiles)
        [~, cropRectName, ~] = fileparts(cropRectFiles(k).name);
        cropRectName = strrep(cropRectName, 'crop_para', '');
        if contains(smallImageName, cropRectName)
            cropRectFile = cropRectFiles(k).name;
            break;
        end
    end
    
    % 确保找到了对应的文件
    if isempty(largeImageFile) || isempty(cropRectFile)
        error('未找到与小图 %s 对应的大图或cropRect文件', smallImageFiles(i).name);
    end
    
    % 读取大图
    largeImage = imread(fullfile(largeImageFolderPath, largeImageFile));
    
    % 读取小图
    smallImage = imread(fullfile(smallImageFolderPath, smallImageFiles(i).name));
    
    % 读取cropRect
    cropRectPath = fullfile(cropRectFolderPath, cropRectFile);
    cropData = load(cropRectPath);
    cropRect = cropData.cropRect;  % 假设.mat文件中变量名为cropRect
    cropRect=[100,100,2100,2924];
    disp("cropRect");
    % 将小图恢复到大图中
    restoredImage = largeImage;
    restoredImage(cropRect(2):(cropRect(2)+cropRect(4)), cropRect(1):(cropRect(1)+cropRect(3)), :) = smallImage;
    

    
    % 保存恢复后的图像
    [~, name, ext] = fileparts(smallImageFiles(i).name);
    outputFileName = fullfile(outputFolderPath, [name,'_big',  ext]);
    imwrite(restoredImage, outputFileName);
end
%%
%test
img=imread("Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\sunset03.jpg");

cropRect =[500,600,25,25];

croppedImg = imcrop(img, cropRect);

imwrite(croppedImg,['Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\cropped\test\' ...
    ,'sunset03.jpg'] );
save(strcat("Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\cropped\test\", ...
   'sunset03.mat'),'cropRect');
%%
% dir_uncropped=dir("Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\sunset05.JPG");
dir_uncropped=dir("Z:\homes\Peggy\oppoSkinExperi\picked40\Hassel\downSampled1\*.JPG");
% fileNames = {dir_uncropped.name};
% [sortedNames, sortOrder] = sort(fileNames);
% dir_uncropped = dir_uncropped(sortOrder);

for i_crop=14:14
% for i_crop=1:length(dir_uncropped)
    img=imread(strcat(dir_uncropped(i_crop).folder,"\",dir_uncropped(i_crop).name));
    % cropRect =[971,614.5,972,957];
    cropRect =[971,214.5,972,957];

    % cropRect =[1408.95,429,1068.1,1056];
    % cropRect =[1408.95,729,1068.1,1056];%初始Hassel
    % cropRect =[400,500,1100,1400];
    croppedImg = imcrop(img, cropRect);

    imwrite(croppedImg,['Z:\homes\Peggy\oppoSkinExperi\picked40\Hassel\downSampled1\cropped\' ...
        ,dir_uncropped(i_crop).name] );
    save(strcat("Z:\homes\Peggy\oppoSkinExperi\picked40\Hassel\downSampled1\crop_para\", ...
        dir_uncropped(i_crop).name(1:end-4),'.mat'),'cropRect');
end




%%
%
% % 指定图片所在的目录
% inputFolder = 'Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\discarded';
% outputFolder = 'Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\discarded\vertical';
% 
% % 检查输出文件夹是否存在，如果不存在则创建
% if ~exist(outputFolder, 'dir')
%     mkdir(outputFolder);
% end
% 
% % 获取目录下所有的图片文件
% imageFiles = dir(fullfile(inputFolder, '*.jpg')); % 假设图片格式为jpg，可根据实际情况修改
% 
% % 循环处理每一张图片
% for k = 1:length(imageFiles)
%     % 读取图片
%     imgName = imageFiles(k).name;
%     imgPath = fullfile(inputFolder, imgName);
%     img = imread(imgPath);
% 
%     % 获取图片尺寸
%     [height, width, ~] = size(img);
% 
%     % 计算需要裁剪的宽度和高度
%     targetWidth = 3024/4032*3024;
%     targetHeight = 3024;
% 
%     % 计算宽度需要裁剪多少像素
%     if width > targetWidth
%         cropWidth = width - targetWidth;
%         cropWidthLeft = floor(cropWidth / 2);
%         cropWidthRight = cropWidth - cropWidthLeft;
%     else
%         cropWidthLeft = 0;
%         cropWidthRight = 0;
%     end
% 
%     % 计算高度需要裁剪多少像素
%     if height > targetHeight
%         cropHeight = height - targetHeight;
%         cropHeightTop = floor(cropHeight / 2);
%         cropHeightBottom = cropHeight - cropHeightTop;
%     else
%         cropHeightTop = 0;
%         cropHeightBottom = 0;
%     end
% 
%     % 裁剪图片
%     croppedImg = img(1 + cropHeightTop:end - cropHeightBottom, 1 + cropWidthLeft:end - cropWidthRight, :);
% 
%     % 保存裁剪后的图片
%     outputFilePath = fullfile(outputFolder, imgName);
%     imwrite(croppedImg, outputFilePath);
% end
% 
% disp('所有图片已处理完毕');
