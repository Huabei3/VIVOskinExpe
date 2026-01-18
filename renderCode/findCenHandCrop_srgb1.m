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
load("GrayScaleMeanRGB\GrayScaleMeanRGB.mat","RGB_gray_all","ratio");
save_folder='findCen_srgb_scaled';
wd65=[94.813  100.000  107.262];
lab_PMCC=[62.11,18.96,19.76];

for i_pic52 = 1:size(RGB_gray_all,1)
    for i_grayScale=1:(size(RGB_gray_all,2)-1)
        RGB_gray=RGB_gray_all{i_pic52,i_grayScale}./255;
        XYZ_gray(i_grayScale,:)=srgb2xyz(RGB_gray);
        XYZw_pre(i_grayScale,:)=XYZ_gray(i_grayScale,:)./ratio(i_grayScale,:);
    end
    XYZw_pre_mean=mean(XYZw_pre,1);
    XYZw_pre_all(i_pic52,:)=XYZw_pre_mean;
    labw_pre_all(i_pic52,:)=xyz2lab(XYZw_pre_mean,'d65_64');
    % wpre_picname(i_pic52,:)=RGB_gray_all{i_pic52,7};
end



if ~exist(save_folder,"dir")
    mkdir(save_folder);
end
average_lab_all=[];average_lab_all1=[];
de_all=[];de00_all=[];de00c_all=[];

for i_pic38 = 1:numel(files) 
    
    img=imread(fullfile(files(i_pic38).folder, files(i_pic38).name));
    [m, n, p] = size(img);
    bull=imread(strcat(dir_mask(i_pic38).folder,'\',dir_mask(i_pic38).name));
    bull_reshaped=reshape(bull, [m * n, p])./255;
    bull_reshaped = double(bull_reshaped);
    logicalIndex = all(bull_reshaped == 0, 2);
    
    %%
    
    img=im2double(img);
    out = reshape(img, [m * n, p]);     
    % out=out*255;
    datai_file = 'Z:\homes\Peggy\work\oppoSkinExperi\LUT3d\results\datai_sorted40_3.mat';
    XYZw=load(datai_file,'XYZw');
    XYZw=XYZw.XYZw;

    xyz = srgb2xyz(out);  

    average_xyz(i_pic38,:)=mean(xyz(~logicalIndex, :));

    xyz_unscaled=xyz;
    for i_pic52=1:size(RGB_gray_all,1)
        if contains(files(i_pic38).name,RGB_gray_all{i_pic52,7})
            disp([files(i_pic38).name,RGB_gray_all{i_pic52,7}]);
            XYZw_pre_pic(i_pic38,:)=XYZw_pre_all(i_pic52,:);
            break
        end
    end
    xyz=xyz./XYZw_pre_pic(i_pic38,2).*wd65(2);
    [lab] = xyz2lab(xyz,'d65_64');
    [lab1] = xyz2lab(xyz,'user',XYZw_pre_pic(i_pic38,:));
    average_lab2(i_pic38,:) = xyz2lab(average_xyz(i_pic38,:),'user', ...
        XYZw_pre_pic(i_pic38,:));
    average_xyz_CATed(i_pic38,:)=CAT16_D(average_xyz(i_pic38,:), ...
        XYZw_pre_pic(i_pic38,:), wd65,  1);
    average_lab_CATed(i_pic38,:)=xyz2lab(average_xyz_CATed(i_pic38,:),'user', ...
        XYZw_pre_pic(i_pic38,:));
    if any(~logicalIndex)
        average_lab=mean(lab(~logicalIndex, :));
        average_lab1=mean(lab1(~logicalIndex, :));
    else
        average_lab = [];
    end



%%
    load(fullfile(dir_setPoints(i_pic38).folder,dir_setPoints(i_pic38).name));
    [de,~,~,~] = cielabde(average_lab,lab_PMCC);
    [de00,de00c] = deltaE2000(average_lab,lab_PMCC);    
    [de00_CATed(i_pic38,:),de00c_CATed(i_pic38,:)] = deltaE2000(average_lab_CATed(i_pic38,:),lab_PMCC);
    [de002(i_pic38,:),de00c2(i_pic38,:)] = deltaE2000(average_lab2(i_pic38,:),lab_PMCC);

    average_lab_all=[average_lab_all;average_lab];
    average_lab_all1=[average_lab_all1;average_lab1];
    de_all=[de_all;de];
    de00_all=[de00_all;de00];
    de00c_all=[de00c_all;de00c];
end
%%
average_file='Z:\homes\Peggy\work\oppoSkinExperi\picked40\iphone\cropped\aveSkinByHand\autoNhand.mat';
average=load(average_file);
average=average.average_lab_all(:,5:7);
[de00_oriAve,~]=deltaE2000(average,repmat(lab_PMCC,length(average),1));


save(fullfile(save_folder,strcat('autoNhand_srgb_scaled.mat')), ...
        'average_lab_all','average_lab_CATed','average_lab2', ...
        "XYZw_pre_all","XYZw_pre_pic","de002");

A=average_xyz./XYZw_pre_pic(:,2);



%%
par_All52=[];
fitRes=load("Z:\homes\Peggy\oppoSkinExperi\analyzeResult\AlalyseResults\" + ...
    "CAT_MSV\inLab\ellipPara\fitRes_level.mat");
par_All52=[par_All52;fitRes.par_all(:,5:7)];
fitRes=load("Z:\homes\Peggy\oppoSkinExperi\analyzeResult\AlalyseResults\" + ...
    "CAT_MSV\indoorAdd\ellipPara\fitRes_level.mat");
par_All52=[par_All52;fitRes.par_all(:,5:7)];
fitRes=load("Z:\homes\Peggy\oppoSkinExperi\analyzeResult\AlalyseResults\" + ...
    "CAT_MSV\nightAdd\ellipPara\fitRes_level.mat");
par_All52=[par_All52;fitRes.par_all(:,5:7)];
fitRes=load("Z:\homes\Peggy\oppoSkinExperi\analyzeResult\AlalyseResults\" + ...
    "CAT_MSV\outdoorAdd\ellipPara\fitRes_level.mat");
par_All52=[par_All52;fitRes.par_all(:,5:7)];
fitRes=load("Z:\homes\Peggy\oppoSkinExperi\analyzeResult\AlalyseResults\" + ...
    "CAT_MSV\sunsetAdd\ellipPara\fitRes_level.mat");
par_All52=[par_All52;fitRes.par_all(:,5:7)];
par_All38=par_All52(15:52,:);
[de00_fitRes,~]=deltaE2000(par_All38,repmat(lab_PMCC,length(par_All38),1));

mean(de00_all),mean(de00_CATed),mean(de002),mean(de00_oriAve),mean(de00_fitRes)
