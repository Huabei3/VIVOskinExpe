clc;clear;close all;
%%
% 新的makemask
dir_croppedPic=dir("D:\oppoSkinExperi\picked40\iphone\cropped\*.jpg");
dir_setPoints=dir("D:\oppoSkinExperi\picked40\iphone\cropped\setPoints\*.mat");

% for i_croppedPic=1:length(dir_croppedPic)
for i_croppedPic=37:37

    img = imread(strcat(dir_croppedPic(i_croppedPic).folder,'\',dir_croppedPic(i_croppedPic).name));
    img=im2double(img);
    % make mask0
    white65=[95.04,100,108.89];
    spq=1;
    mode=3;         %1 caucasian,2 brown,3 chinese,4 sky ,5 grass，6 black
    load zip/w.mat   %相机修正参数
    load(strcat(dir_setPoints(i_croppedPic).folder,'\',dir_setPoints(i_croppedPic).name));
    dlab=center0;
    [predict_white,rgbnew,ccT,duv,mask0,bullx,ratio,lab,xyz,center0,center1]=AWBrendering1(img,i_croppedPic,spq,w,dlab,'srgb');%渲染函数

    
    % 步骤 4: 人脸检测
    faceDetector = vision.CascadeObjectDetector();
    bbox = step(faceDetector, img);
    
    % 步骤 5: 结合人脸检测和肤色模型，获得mask1
    mask1 = false(size(img, 1), size(img, 2)); % 初始化mask1
    for i = 1:size(bbox, 1)
        faceMask = false(size(img, 1), size(img, 2));
        faceMask(bbox(i,2):bbox(i,2)+bbox(i,4), bbox(i,1):bbox(i,1)+bbox(i,3)) = 1;
        mask1 = mask1 | (mask0 & faceMask);
    end
    
    % 求mask1覆盖的肤色中心
    [maskY, maskX] = find(mask1);

    
    % 使用肤色中心进行第二次肤色检测，获取mask2
    % 这里假设使用相同的肤色检测方法，实际应用中可以根据需要调整

    % 计算mask1的下巴处作为分界线
    chinY = max(maskY); % 脸的最低点
    faceHeight = chinY - min(maskY); % 脸的高度
    dividerY = chinY - round(faceHeight * 0.1); % 以脸的最低点上移脸高度的10%作为分界
    
    % 生成最终的mask3
    mask3 = mask1; % 初始化mask3
    mask3(dividerY:end, :) = mask0(dividerY:end, :) | mask3(dividerY:end, :); % 下方使用mask2
    
    % 可视化结果
%     figure; imshow(mask3); title('Final Mask Covering Face and Neck');
    imwrite(mask3,strcat("D:\oppoSkinExperi\picked40\iphone\cropped\correct1\mask\new\mask3_",dir_croppedPic(i_croppedPic).name));
end


% A=load("D:\oppoSkinExperi\picked40\iphone\cropped\correct1\crop_para\crop_paraoutdoor05.mat");
% B=load("D:\oppoSkinExperi\picked40\iphone\cropped\correct\crop_para\crop_paraoutdoor05.mat");


