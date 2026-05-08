clear; clc; close all;

%%

folderPath = 'ori';

imageFiles = dir(fullfile(folderPath, 'bigOri.jpg')); % 修改为匹配所有jpg文件
numImages = length(imageFiles);

% 初始化矩阵来存储每张图片中正方形区域的裁剪信息
crop_rect_info_all = []; % [x, y, width, height] for 6 selections

fig = figure('Name', 'RGB Selection', 'NumberTitle', 'off');

for i_pic = 1:numImages
    crop_rect_info=zeros(6,4);
    imageFile = fullfile(folderPath, imageFiles(i_pic).name);
    img = imread(imageFile);

    imshow(img);
    title(['Image: ', imageFiles(i_pic).name, ' - Select 6 points']);
    
    [height, width, ~] = size(img);
    
    for i_select = 1:6
        
        h = impoint;
        position = wait(h);
        
        if isempty(position)
            disp('No point selected, skipping to next image.');
            break; % 如果没有选取点，则跳到下一张图片
        end
        
        x = round(position(1));
        y = round(position(2));
        
        if x < 1 || x > width || y < 1 || y > height
            disp('Selected point is out of bounds, please select a point within the image.');
            continue; % 如果选取点超出边界，则重新选取
        end
        
        % 计算正方形的边界
        sideLength = 30; % 正方形边长
        halfSideLength = sideLength / 2;
        xMin = max(1, x - halfSideLength);
        xMax = min(width, x + halfSideLength);
        yMin = max(1, y - halfSideLength);
        yMax = min(height, y + halfSideLength);
        
        % 保存正方形区域的裁剪信息
        crop_rect_info( i_select, :) = [xMin, yMin, xMax - xMin, yMax - yMin];
        
    end
    crop_rect_info_all{i_pic,1}=crop_rect_info;
end

close(fig);

outputFolder = "graySquares";
if ~exist(outputFolder, "dir")
    mkdir(outputFolder);
end
filename = fullfile(outputFolder, strcat('crop_rect_info_gray.mat'));
save(filename, 'crop_rect_info'); % 保存裁剪信息

%%
outputFolder = "graySquares";
if ~exist(outputFolder, "dir")
    mkdir(outputFolder);
end
filename = fullfile(outputFolder, strcat('crop_rect_info_gray.mat'));
load(filename, 'crop_rect_info'); % 保存裁剪信息

%
neutral_Y=[90.01,59.10,36.20,19.77,9.00,3.13];
neutral_Y=neutral_Y';
ratio=neutral_Y./neutral_Y(1);
ratio_pmcc=[1,0.664048387704395,0.411795232309412,0.218320481610776,...
0.107489189773339,0.0492843040088944];
ratio_pmcc=ratio_pmcc';

img=imread("ori\bigOri.jpg");
figure();
imshow(img);
img=double(img);

xyz_sq_mean=zeros(6,3);
for i_neutral=1:size(crop_rect_info,1)
    gray_pos=crop_rect_info(i_neutral,:);
    sq=img(gray_pos(2):gray_pos(2)+30, ...
        gray_pos(1):gray_pos(1)+30,:);
    sz=size(sq);
    sq_rspd=reshape(sq,[sz(1)*sz(2),sz(3)]);
    xyz_sq=srgb2xyz(sq_rspd./255);
    xyz_sq_mean(i_neutral,:)=mean(xyz_sq);
    rectangle('Position', [gray_pos(1), gray_pos(2), 30, 30], ...
          'EdgeColor', 'r', ...        % 矩形框的边缘颜色为红色
          'LineWidth', 2);   
end
xyz_sq_scaled=xyz_sq_mean./repmat(ratio,1,size(xyz_sq_mean,2));
xyz_sq_scaled_pmcc=xyz_sq_mean./repmat(ratio_pmcc,1,size(xyz_sq_mean,2));
XYZw_pre=mean(xyz_sq_mean,1);

save(filename, 'crop_rect_info','xyz_sq_mean','xyz_sq_scaled',"XYZw_pre");