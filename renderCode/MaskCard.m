close all; 
clc;       
clear;     
%%
%cardMask
source_folder='D:\work\FirstYearMaster\oppoSkinExperi\picked40\drawable';
input_folder=source_folder;
% source_folder='Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\cropped\renderedLUTchoose\renderedAdd07\sunset';
% input_folder=fullfile(source_folder,'drawable');
dir_picname=dir('D:\work\FirstYearMaster\oppoSkinExperi\picked40\iphone\*.jpg');

files = dir(fullfile(input_folder,'*.jpg'));  
dir_mask=dir("D:\work\FirstYearMaster\oppoSkinExperi\picked40\iphone\CardMask\*.jpg");
% save_folder=fullfile(source_folder,'CardProcessed');
save_folder=fullfile(source_folder,'CardMasked_smalldE');
if ~exist(save_folder, 'dir')
    mkdir(save_folder);
end
smalldERenNfit=[4,7,19,13,23,22,37,36];
% bigdERenNfit=[6,8,9,16,11,15,27,24,21,31,33,34];
for i = 1:numel(files)
    is_small=0;
    for i_small=1:length(smalldERenNfit)
        disp(strcat(files(i).name," ",dir_picname(smalldERenNfit(i_small)).name(1:end-4)));
        disp(contains(files(i).name, dir_picname(smalldERenNfit(i_small)).name(1:end-4)));
        if contains(files(i).name, dir_picname(smalldERenNfit(i_small)).name(1:end-4))
            is_small=1;
            break
        end
    end
    if is_small==0
        continue
    end
    % is_big=0;
    % for i_big=1:length(bigdERenNfit)
    %     disp(strcat(files(i).name," ",dir_picname(bigdERenNfit(i_big)).name(1:end-4)));
    %     disp(contains(files(i).name, dir_picname(bigdERenNfit(i_big)).name(1:end-4)));
    %     if contains(files(i).name, dir_picname(bigdERenNfit(i_big)).name(1:end-4))
    %         is_big=1;
    %         break
    %     end
    % end
    % if is_big==0
    %     continue
    % end
    img_file=strcat(save_folder,'\',files(i).name(1:end-4),'.jpg');
    if exist(img_file, 'file') == 2
        continue
    end
    filename = fullfile(files(i).folder, files(i).name);      
    img0=imread(filename);
    img=im2double(img0);
    [m, n, p] = size(img);
    out = reshape(img, [m * n, p]);   
    i_mask=1;
    while (~contains(files(i).name,dir_mask(i_mask).name(1:end-4)))
        i_mask=i_mask+1;
    end

    bull=imread(strcat(dir_mask(i_mask).folder,'\',dir_mask(i_mask).name));
    if ~isequal(size(bull), size(img))
        if size(bull,1)/size(bull,2)==size(img,1)/size(img,2)
            bull=imresize(bull,[size(img, 1), size(img, 2)]);
        end
    end
    bull_reshaped=reshape(bull, [m * n, p])./255;
    bull_reshaped = double(bull_reshaped);
    logicalIndex = all(bull_reshaped == 0, 2);


    
    if any(~logicalIndex)            
        out(~logicalIndex, :)=repmat([0.5,0.5,0.5], sum(~logicalIndex), 1);
    end
    outnew = reshape(out, [m, n, p]);
    imshow(outnew);
    imwrite(outnew,strcat(save_folder,'\',files(i).name(1:end-4),'.jpg') );
    currentTime = datetime('now');  
    formattedTime = datestr(currentTime, 'yyyy-mm-dd HH:MM:SS');
    disp([files(i).name(1:end-4),'finished: ',formattedTime]);
end
disp("done");
%%
%cardMask部分0.5 0.5 0.5
% files = dir(['Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\cropped\renderedLUTchoose\' ...
%     'renderedAdd07\indoor\drawble_uncardmasked\*.jpg']);  
% dir_mask=dir("Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\CardMask\*.jpg");
% 
% for i = 1:numel(files)
% 
%     filename = fullfile(files(i).folder, files(i).name);      
%     img0=imread(filename);
%     img=im2double(img0);
%     [m, n, p] = size(img);
%     out = reshape(img, [m * n, p]);   
%     i_mask=1;
%     while (~contains(files(i).name,dir_mask(i_mask).name(1:end-4)))
%         i_mask=i_mask+1;
%     end
% 
%     bull=imread(strcat(dir_mask(i_mask).folder,'\',dir_mask(i_mask).name));
%     bull_reshaped=reshape(bull, [m * n, p])./255;
%     bull_reshaped = double(bull_reshaped);
%     logicalIndex = all(bull_reshaped == 0, 2);
% 
%     img_file=['Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\cropped\renderedLUTchoose\renderedAdd07\indoor\CardMasked\' ...
%         ,files(i).name(1:end-4),'.jpg'];
%     if exist(img_file, 'file') == 2
%         continue
%     end
% 
%     if any(~logicalIndex)            
%         out(~logicalIndex, :)=repmat([0.5,0.5,0.5], sum(~logicalIndex), 1);
%     end
%     outnew = reshape(out, [m, n, p]);
%     imshow(outnew);
% 
%     imwrite(outnew,['Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\cropped\renderedLUTchoose\renderedAdd07\indoor\CardMasked\' ...
%         ,files(i).name(1:end-4),'.jpg'] );
% 
% end







%%
% clear;
%%
% 文件夹路径设置
% sourceFolder = 'Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\CardMask'; % 包含二值化图片的文件夹
% targetFolder = ['Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\cropped\' ...
%     'renderedLUTchoose\renderedAdd07\indoor\drawable']; % 包含待查找图片的文件夹
% outputFolder = ['Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\cropped\' ...
%     'renderedLUTchoose\renderedAdd07\indoor\CardMasked']; % 存放生成图像的文件夹
% 
% % 获取 sourceFolder 中的所有 .jpg 文件的文件名（不包括后缀）
% sourceFiles = dir(fullfile(sourceFolder, '*.JPG'));
% sourceNames = {sourceFiles.name};
% sourceNames = cellfun(@(x) erase(x, '.JPG'), sourceNames, 'UniformOutput', false);
% 
% % 获取 targetFolder 中的所有 .jpg 文件的文件名
% targetFiles = dir(fullfile(targetFolder, '*.JPG'));
% 
% % 遍历每个 sourceName
% for i = 1:length(sourceNames)
%     picname = sourceNames{i};
% 
%     % 在 targetFolder 中查找包含 picname 的文件
%     for j = 1:length(targetFiles)
%         targetFile = targetFiles(j).name;
%         if contains(targetFile, picname) 
%             % 读取 source 文件夹中的二值化图片
%             sourceImagePath = fullfile(sourceFolder, strcat(picname, '.JPG'));
%             sourceImage = imread(sourceImagePath);
% 
%             % 读取 target 文件夹中的待处理图片
%             targetImagePath = fullfile(targetFolder, targetFile);
%             targetImage = imread(targetImagePath);
% 
%             % 初始化 RGB 图像
%             [rows, cols] = size(sourceImage);
%             outputImage = uint8(zeros(rows, cols, 3));
% 
%             % 设置为 RGB (123, 123, 123) 的灰色
%             grayColor = [123, 123, 123];
% 
%             % 更新 outputImage 根据 sourceImage 的二值化结果
%             outputImage(:, :, 1) = uint8(sourceImage(:, :, 1)) * grayColor(1);
%             outputImage(:, :, 2) = uint8(sourceImage(:, :, 2)) * grayColor(2);
%             outputImage(:, :, 3) = uint8(sourceImage(:, :, 3)) * grayColor(3);
% 
%             % 其他部分保持不变
%             % 将二值化区域合并到原始图像中
%             targetImage(:,:,1) = uint8(~sourceImage(:,:,1)) .* targetImage(:,:,1) + outputImage(:,:,1);
%             targetImage(:,:,2) = uint8(~sourceImage(:,:,2)) .* targetImage(:,:,2) + outputImage(:,:,2);
%             targetImage(:,:,3) = uint8(~sourceImage(:,:,3)) .* targetImage(:,:,3) + outputImage(:,:,3);
% 
%             % 保存结果图像到 outputFolder
%             outputImagePath = fullfile(outputFolder, targetFile);
%             imwrite(targetImage, outputImagePath);
%         end
%     end
% end
