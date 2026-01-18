close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量
%%
folder = 'E:\Hasselblad-lab-23model-22light\dsp\femaleVIVO\i\CardMasked';  % 文件夹路径
files = dir(fullfile(folder, '*.jpg'));  % 读取文件夹中的所有.jpg文件

save_folder=fullfile(folder,'mask_findCen');
if exist(save_folder,'dir')==0
    mkdir(save_folder);
end

dlab=[30,0,0];
% dir_pointsfiles=dir("F:\研一\L_N_Preference\oppo_skin_images\OPPO-Skin-Images-2024\" + ...
%     "哈苏-X2D100C-JPEG\已压缩\result\*.mat");
% for i = 6:6
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
   

    [predict_white,rgbnew,ccT,duv,bull,bullx,ratio,lab,xyz,center0,center1]=AWBrendering1(img,i,spq,w,dlab,'srgb');%渲染函数
    imshow(bull);
    imwrite(bull,fullfile(save_folder,strcat( 'mask_',files(i).name)) );

    
end
output_folder=fullfile(save_folder,'autoAve');
if exist(output_folder,'dir')==0
    mkdir(output_folder);
end
save(fullfile(output_folder,strcat("aveSkinColor",files(i).name(1:end-4),".mat")),'center0');



