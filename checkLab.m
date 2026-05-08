clear;clc;close all;
%%
dir_expPic=dir("new_exp\rendering_Lab*.jpg");
dir_mask=dir('ori\mask\ori1.jpg');
% dir_mask=dir('ori\mask\ori1_1.jpg');
average_xyz_all=[];average_lab_all=[];picname=[];
for i_expPic=1:length(dir_expPic)
    img=imread(fullfile(dir_expPic(i_expPic).folder,dir_expPic(i_expPic).name));
    [m, n, p] = size(img);
    bull=imread(strcat(dir_mask(1).folder,'\',dir_mask(1).name));
    bull_reshaped=reshape(bull, [m * n, p])./255;
    bull_reshaped = double(bull_reshaped);
    logicalIndex = all(bull_reshaped == 0, 2);


    %%
    
    img=im2double(img);
    out = reshape(img, [m * n, p]);     

    gog_file=['gog\GOGpara.mat'];
    xyz=display_f(out,gog_file);
    
    [lab] = xyz2lab(xyz,'d65_31');
    if any(~logicalIndex)
        average_lab=mean(lab(~logicalIndex, :));
    else
        average_lab = [];
    end
    [average_xyz] = lab2xyz2(average_lab,'d65_31');
  
    average_xyz_all=[average_xyz_all;average_xyz];
    average_lab_all=[average_lab_all;average_lab];
    picname=[picname;{dir_expPic(i_expPic).name}];

end


save("expLab\expLab.mat","picname","average_xyz_all","average_lab_all");