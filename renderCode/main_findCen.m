close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量
%%
files = dir('D:\oppoSkinExperi\picked40\iphone\cropped\correct1\cropped\cropped_sunset07*.jpg'); 
% files = dir('D:\oppoSkinExperi\picked40\iphone\cropped\correct1\cropped\cropped_sunset07*.jpg');  % 读取文件夹中的所有.jpg文件



dlab=[30,10,10];
% dir_pointsfiles=dir("D:\oppoSkinExperi\哈苏jpg\已裁剪\result\setPoints*.mat");
% dir_mask=dir("D:\oppoSkinExperi\哈苏jpg\已裁剪\mask_*.jpg");
% for i = 1:1
for i = 1:numel(files)  %改为1：numel(files),可以实现对文件夹中图片进行批量操作
    close all
    white65=[95.04,100,108.89];
%     load(strcat(dir_pointsfiles(i).folder,'\',dir_pointsfiles(i).name));%加载setPoints
    spq=1;
    mode=3;         %1 caucasian,2 brown,3 chinese,4 sky ,5 grass，6 black
    load zip/w.mat   %相机修正参数
    
    filename = fullfile(files(i).folder, files(i).name);  % 获取文件名,包含路径
    img0=imread(filename);
    img=im2double(img0);
   
%     [face,rect1]=imcrop(img);
%     [m,n,~]=size(face);
%     imshow(face)
%     for i_points=1:length(centers)
%         dlab=centers(i_points,:);
        [predict_white,rgbnew,ccT,duv,bull,bullx,ratio,lab,xyz,center0,center1]=AWBrendering(img,mode,spq,w,dlab,'srgb');%渲染函数
%         bull=imread(strcat(dir_mask(i).folder,'\',dir_mask(i).name));
%         [out_rendering,outxyz,k,out_awb]=imgcat2(img,bull,predict_white,white65,white65,w,'srgb');%根据计算得到的白点，进行cat变化，得到渲染后的图像
%         imshow(out_rendering)
    
        disp([num2str(i),'/',num2str(numel(files)),' ',files(i).name,' was done']);

%         imwrite(out_rendering,['D:\oppoSkinExperi\哈苏jpg\已裁剪\result\results\' ...
%             'Rendered_',files(i).name(12:end-4),num2str(i_points),'[',num2str(dlab(1,1)),',' ,...
%             num2str(dlab(1,2)),',',num2str(dlab(1,3)),'].jpg'] );
        
        save(strcat("D:\oppoSkinExperi\picked40\iphone\cropped\correct1\aveSkinColor" + ...
            "\aveSkinColor",files(i).name(1:end-4),".mat"),'center0');

%     end
end



