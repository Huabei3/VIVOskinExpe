close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量
%%
folder = 'F:\研一\L_N_Preference\oppo_skin_images\OPPO-Skin-Images-2024\哈苏-X2D100C-JPEG\已裁剪\';  % 文件夹路径
files = dir(fullfile(folder, '*.jpg'));  % 读取文件夹中的所有.jpg文件

outfolder='F:\研一\L_N_Preference\oppo_skin_images\OPPO-Skin-Images-2024\哈苏-X2D100C-JPEG\已裁剪\result';
if exist(outfolder,'dir')==0
    mkdir(outfolder);
end

dlab=[30,0,0];
% dir_pointsfiles=dir("F:\研一\L_N_Preference\oppo_skin_images\OPPO-Skin-Images-2024\" + ...
%     "哈苏-X2D100C-JPEG\已压缩\result\*.mat");

for i = 1:numel(files)  %改为1：numel(files),可以实现对文件夹中图片进行批量操作
    close all
    white65=[95.04,100,108.89];
%     load(strcat(dir_pointsfiles(i).folder,'\',dir_pointsfiles(i).name));%加载setPoints
    spq=1;
    mode=3;         %1 caucasian,2 brown,3 chinese,4 sky ,5 grass，6 black
    load zip/w.mat   %相机修正参数
    
    filename = fullfile(folder, files(i).name);  % 获取文件名,包含路径
    img0=imread(filename);
    img=im2double(img0);
   
%     [face,rect1]=imcrop(img);
%     [m,n,~]=size(face);
%     imshow(face)
    
    
    [predict_white,rgbnew,ccT,duv,bull,bullx,ratio,lab,xyz,center0,center1]=AWBrendering1(img,i,spq,w,dlab,'srgb');%渲染函数
    imshow(bull);
    imwrite(bull,['F:\研一\L_N_Preference\oppo_skin_images\' ...
        'OPPO-Skin-Images-2024\哈苏-X2D100C-JPEG\已裁剪\' ...
        'mask_',files(i).name(9:end)] );

%     save(strcat("F:\研一\L_N_Preference\oppo_skin_images\OPPO-Skin-Images-2024\哈苏-X2D100C-JPEG\用于压缩" + ...
%         "\bull",files(i).name(1:end-4),".mat"),'bull');

%     [out_rendering]=imgcat_testcrop(img,bull,predict_white,white65,white65,w,'srgb');%根据计算得到的白点，进行cat变化，得到渲染后的图像
%     imshow(out_rendering);
% 
%     disp([num2str(i),'/',num2str(numel(files)),' ',files(i).name,' was done']);
% %     save(strcat(outfolder,'\rendered_',num2str(i),'.png'));
%     imwrite(out_rendering,['F:\研一\L_N_Preference\oppo_skin_images\' ...
%         'OPPO-Skin-Images-2024\哈苏-X2D100C-JPEG\已裁剪\result\test_crop\' ...
%         'flexiblyRendered_',files(i).name(9:end-4),'[',num2str(dlab(1,1)),',' ,...
%         num2str(dlab(1,2)),',',num2str(dlab(1,3)),'].jpg'] );
    
    save(strcat("F:\研一\L_N_Preference\oppo_skin_images\OPPO-Skin-Images-2024\哈苏-X2D100C-JPEG\已裁剪\" + ...
            "\bull",files(i).name(1:end-4),".mat"),'bull');
   
end



