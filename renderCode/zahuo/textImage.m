
folderPath = 'D:\oppoSkinExperi\哈苏jpg\已裁剪\result'; % 替换为你的图片文件夹路径
files = dir(fullfile(folderPath, 'Rendered_1未带妆7000km*.jpg')); % 假设图片是PNG格式，根据需要调整

% 假设所有图片的尺寸相同，获取第一张图片的尺寸作为参考
imgExample = imread(fullfile(folderPath, files(1).name));
[imgHeight, imgWidth, ~] = size(imgExample);

% 计算大图的尺寸
bigImgWidth = imgWidth * 8;
bigImgHeight = imgHeight * 6;
bigImg=imread(['D:\oppoSkinExperi\哈苏jpg\已裁剪\result\joint\',files(i).name(1:19),'bigImg.jpg']);
imshow(bigImg);
for i = 1:length(files)
    row = floor((i-1) / 8) + 1;
    col = mod(i-1, 8) + 1;
    startX = (col-1) * imgWidth + 1;
    startY = (row-1) * imgHeight + 30;
    text(startX, startY, files(i).name(20:end-4), 'Color', 'white', 'FontSize', 12); % 添加文字
end
% 可选: 保存大图
imwrite(bigImg, ['D:\oppoSkinExperi\哈苏jpg\已裁剪\result\joint\',files(i).name(1:19),'jointImg.jpg']);