dir_joint=dir("D:\oppoSkinExperi\哈苏jpg\已裁剪\result\results\joint\Rendered_*bigImg.png");
for i_joint=1:length(dir_joint)
% 读取图片
    originalImg = imread([dir_joint(i_joint).folder,'\',dir_joint(i_joint).name]); % 请替换为你的图片文件路径
    
    % 调整图片尺寸为原来的一半
    resizedImg = imresize(originalImg, 0.25);
    
    % 保存调整尺寸后的图片
    imwrite(resizedImg, [dir_joint(i_joint).folder,'\',dir_joint(i_joint).name(10:end)]); % 保存为新文件以保留原图
end