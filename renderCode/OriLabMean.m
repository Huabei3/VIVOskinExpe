close all; % 茅鈥斅?
clc;       % 氓漏碌莽鈥毬疵ε?
clear;     % 氓漏碌莽鈥毬疵ε捖该┡铰?
%%
% files = dir('Z:\homes\Peggy\oppoSkinExperi\HasselCropped\downSampled1\*.jpg');  
% dir_pointsfiles=dir("Z:\homes\Peggy\oppoSkinExperi\HasselCropped\setPoints\setPoints*.mat");
% dir_mask=dir("Z:\homes\Peggy\oppoSkinExperi\HasselCropped\downSampled1\mask\*.jpg");

files = dir('Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\cropped\*.jpg');  
dir_mask=dir("Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\cropped\mask\*.jpg");
lab_ori_mean_all=[];
lab_whole_mean_all=[];
lab_noFace_mean_all=[];
for i = 1:numel(files)
    filename = fullfile(files(i).folder, files(i).name);  % 茅鈥斅伱モ?β济?
    img0=imread(filename);
    img=im2double(img0);
    bull=imread(strcat(dir_mask(i).folder,'\',dir_mask(i).name));
    [m, n, p] = size(img);
    bull_reshaped=reshape(bull, [m * n, p])./255;
    bull_reshaped = double(bull_reshaped);
    logicalIndex = all(bull_reshaped == 0, 2);
    out = reshape(img, [m * n, p]);
    datai_file = 'Z:\homes\Peggy\oppoSkinExperi\LUT3d\results\datai_sorted40_3.mat';
    load(datai_file,'XYZw');
    out = out * 255;
    xyz = lut3d_rgb2xyz1(out, datai_file);
    [lab_ori] = xyz2lab(xyz(~logicalIndex, :),'user',XYZw);
    lab_ori_mean=mean(lab_ori,1);
    lab_ori_mean_all=[lab_ori_mean_all;lab_ori_mean];
    [lab_noFace] = xyz2lab(xyz,'user',XYZw);
    lab_noFace_mean=mean(lab_noFace,1);
    lab_noFace_mean_all=[lab_noFace_mean_all;lab_noFace_mean];
    [lab_whole] = xyz2lab(xyz,'user',XYZw);
    lab_whole_mean=mean(lab_whole,1);
    lab_whole_mean_all=[lab_whole_mean_all;lab_whole_mean];

end
save("Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\cropped\LabMeanStatistics.mat", ...
    "lab_ori_mean_all","lab_whole_mean_all","lab_noFace_mean_all");



