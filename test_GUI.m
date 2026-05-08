clear; clc; close all;
%%

folderPath = 'ori';

imageFiles = dir(fullfile(folderPath, 'ori1.jpg'));
% imageFiles = dir(fullfile(folderPath, 'bigOri.jpg'));
numImages = length(imageFiles);

% 初始化矩阵来存储每张图片中正方形区域的裁剪信息
crop_rect_info = zeros(numImages, 4); % [x, y, width, height]

fig = figure('Name', 'RGB Selection', 'NumberTitle', 'off');

for i_pic = 1:numImages
    imageFile = fullfile(folderPath, imageFiles(i_pic).name);
    img = imread(imageFile);

    imshow(img);
    title(['Image: ', imageFiles(i_pic).name, ' - Select 1 point']);
    
    [height, width, ~] = size(img);
    
    h = impoint;
    position = wait(h);
    
    if isempty(position)
        continue;
    end
    
    x = round(position(1));
    y = round(position(2));
    
    if x < 1 || x > width || y < 1 || y > height
        disp('Selected point is out of bounds, please select a point within the image.');
        continue;
    end
    
    % 计算正方形的边界
    sideLength = 30; % 正方形边长
    halfSideLength = sideLength / 2;
    xMin = max(1, x - halfSideLength);
    xMax = min(width, x + halfSideLength);
    yMin = max(1, y - halfSideLength);
    yMax = min(height, y + halfSideLength);
    
    % 保存正方形区域的裁剪信息
    picname(i_pic,1)={imageFiles(i_pic).name};
    crop_rect_info(i_pic, :) = [xMin, yMin, sideLength, sideLength];
end

close(fig);



outputFolder="whiteSquare\find_bg";
% outputFolder="D:\work\VIVOskinExpe\renderCode\skinSquare";
if ~exist(outputFolder, "dir")
    mkdir(outputFolder);
end
filename = fullfile(outputFolder, strcat('crop_rect_info_white.mat'));
save(filename, 'crop_rect_info','picname');



%%
% load(filename, 'crop_rect_info','picname');
% img=imread("ori\bigOri.jpg");
% figure();
% imshow(img);
% img=double(img);
% sq=img(crop_rect_info(2):crop_rect_info(2)+30, ...
%     crop_rect_info(1):crop_rect_info(1)+30,:);
% sz=size(sq);
% sq_rspd=reshape(sq,[sz(1)*sz(2),sz(3)]);
% xyz_sq=srgb2xyz(sq_rspd./255);
% xyz_sq_mean=mean(xyz_sq);
% rectangle('Position', [crop_rect_info(1), crop_rect_info(2), 30, 30], ...
%       'EdgeColor', 'r', ...        % 矩形框的边缘颜色为红色
%       'LineWidth', 2);   

% save(filename, 'crop_rect_info','picname','xyz_sq_mean');