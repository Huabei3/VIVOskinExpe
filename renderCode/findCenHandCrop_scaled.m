close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量
%%
% files = dir('Z:\homes\Peggy\oppoSkinExperi\picked40\Hassel\downSampled1\cropped\*.jpg');  % 读取文件夹中的所有.jpg文件
% dir_mask=dir("Z:\homes\Peggy\oppoSkinExperi\picked40\Hassel\downSampled1\cropped\mask\*.jpg");
% dir_setPoints=dir(['Z:\homes\Peggy\oppoSkinExperi\HasselCropped\' ...
%     'setPoints07\setPoints*.mat']);
% save_folder='Z:\homes\Peggy\oppoSkinExperi\picked40\Hassel\downSampled1\cropped\aveSkinByHand';

files = dir('Z:\homes\Peggy\work\oppoSkinExperi\picked40\iphone\cropped\*.jpg');  % 读取文件夹中的所有.jpg文件
dir_mask=dir("Z:\homes\Peggy\work\oppoSkinExperi\picked40\iphone\cropped\mask\*.jpg");
dir_setPoints=dir(['Z:\homes\Peggy\work\oppoSkinExperi\picked40\iphone\cropped\' ...
    'discarded\setPoints07\setPoints*.mat']);
save_folder='Z:\homes\Peggy\work\oppoSkinExperi\picked40\iphone\cropped\aveSkinByHand';
check_folder=fullfile(save_folder,"check_pic");
if ~exist(check_folder,"dir")
    mkdir(check_folder);
end
load("..\analyzeResult\documents\CATedPre.mat");
average_rgb_all=[];average_xyz_all=[];average_lab_all=[];
de_all=[];de00_all=[];de00c_all=[];

for i = 1:numel(files) 
    
    img=imread(fullfile(files(i).folder, files(i).name));
    [m, n, p] = size(img);
    bull=imread(strcat(dir_mask(i).folder,'\',dir_mask(i).name));
    bull_reshaped=reshape(bull, [m * n, p])./255;
    bull_reshaped = double(bull_reshaped);
    logicalIndex = all(bull_reshaped == 0, 2);
    
    % 提取与bull==1对应的图像区域
    mask = bull == 1;  % 生成逻辑掩码，bull中值为1的位置为true，其余为false
    masked_image=im2double(img);
    masked_image(bull == 0)=0;
    % 计算每个通道的平均值
    if sum(mask(:)) > 0
        % 分别计算每个通道的平均值
        avg_r = sum(sum(masked_image(:,:,1)))./sum(~logicalIndex);
        avg_g = sum(sum(masked_image(:,:,2)))./sum(~logicalIndex);
        avg_b = sum(sum(masked_image(:,:,3)))./sum(~logicalIndex);
        % 合并成一个RGB向量
        average_rgb1 = [avg_r, avg_g, avg_b];
    else
        average_rgb1 = [0 0 0];  % 如果bull==1的区域不存在，返回全零RGB值
    end
    datai_file = 'D:\work\project_code_backup\OPPOskinExpe\display_calibration\datai_sorted40_3.mat';
    XYZw=load(datai_file,'XYZw');
    XYZw=XYZw.XYZw;
    average_rgb1=average_rgb1.*255;
    average_xyz1 = lut3d_rgb2xyz1(average_rgb1, datai_file);    
    
    [average_lab1] = xyz2lab(average_xyz1,'user',XYZw);

    %%
    
    img=im2double(img);
    out = reshape(img, [m * n, p]);     
    out=out*255;
    datai_file = 'D:\work\project_code_backup\OPPOskinExpe\display_calibration\datai_sorted40_3.mat';
    XYZw=load(datai_file,'XYZw');
    XYZw=XYZw.XYZw;
    xyz = lut3d_rgb2xyz1(out, datai_file);      
    [lab] = xyz2lab(xyz,'user',XYZw);%用LUT白提取
    % [lab] = xyz2lab(xyz./XYZw(2).*100,'d65_64');%用D65提取
    if any(~logicalIndex)
        average_lab2=mean(lab(~logicalIndex, :));
    else
        average_lab2 = [];
    end
    [average_xyz2] = lab2xyz2(average_lab2,'user',XYZw);
    check_pic=img.*(double(bull)./255);
    figure();
    imshow(check_pic);
    exportgraphics(gcf,fullfile(check_folder,files(i).name),"Resolution",150);
    close(gcf)

%%
    load(fullfile(dir_setPoints(i).folder,dir_setPoints(i).name));
    [de1,~,~,~] = cielabde(average_lab1,center0);
    [de2,~,~,~] = cielabde(average_lab2,center0);
    [de001,de00c1] = deltaE2000(average_lab1,center0);
    [de002,de00c2] = deltaE2000(average_lab2,center0);
    
    average_rgb_all=[average_rgb_all;average_rgb1];
    average_xyz_all=[average_xyz_all;[average_xyz1,0,average_xyz2]];
    average_lab_all=[average_lab_all;[average_lab1,0,average_lab2,0,center0]];
    de_all=[de_all;[de1,de2]];
    de00_all=[de00_all;[de001,de002]];
    de00c_all=[de00c_all;[de00c1,de00c2]];
end
% save(fullfile(save_folder,strcat('autoNhand1.mat')), ...
%         'average_rgb_all','average_xyz_all','average_lab_all', ...
%         'de_all',"de00_all","de00c_all");


