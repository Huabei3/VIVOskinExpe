clear; clc; close all;
%% 从XYZ提取
models = ["f01","f02","f03","f04","f05","f06","f07","f08","f09","f10",...
          "m01","m02","m03","m04","m05","m06","m07","m08","m09","m10"];
% iOrs = ["i"];
iOrs = ["r"];
save_folder = fullfile("optimizedD\neutral_gray",iOrs);

if ~exist(save_folder,"dir")
    mkdir(save_folder);
end
output_folder = fullfile(save_folder,"gray_patch4");
if ~exist(output_folder, "dir")
    mkdir(output_folder);
end
if ~exist(fullfile(output_folder,"check_pic"),"dir")
    mkdir(fullfile(output_folder,"check_pic"));
end

for iOr = iOrs
    if strcmp(iOr,"i")
        picnames_groups = ["H3K","H4K","H5K","H6K","HD65","H7K","H8K",...
                           "M3K","M4K","M5K","M6K","MD65","M7K","M8K",...
                           "L3K","L4K","L5K","L6K","LD65","L7K","L8K"];
    elseif strcmp(iOr,"r")
        picnames_groups = ["rs01","rs02","rs03","rs04","rs05","rs06","rs07",...
                           "rs08","rs09","rs10","rs11","rs12","rs13","rs14"];
    end
    
    for i_model = 1:length(models)
        model = models(i_model);
        lastPart = strcat(model,iOr);
        
        % 初始化裁剪信息存储
        num_pics = length(picnames_groups);
        crop_rect_info = zeros(num_pics, 4); % [xMin, yMin, width, height]
        picname = cell(num_pics, 1);
        
        % 对每个图片组
        for i_pic = 1:length(picnames_groups)
            if strcmp(iOr,"i")
                XYZ_file = fullfile("..\renderCode\XYZ",iOr,lastPart, ...
                                  strcat(picnames_groups(i_pic),".mat"));
                load(XYZ_file,"XYZ_cropped");
            elseif strcmp(iOr,"r")
                XYZ_file = fullfile("..\analyze\optimizedD\card",lastPart, ...
                              strcat(picnames_groups(i_pic),".mat"));
                load(XYZ_file,"XYZ1_cropped");
                XYZ_cropped=XYZ1_cropped;
            end
            
            
            % 显示图像并等待用户点击
            fig = figure(1);
            clf;
            if strcmp(iOr,"i")
                if i_pic<=14
                    imshow(XYZ_cropped./20);
                else
                    imshow(XYZ_cropped./5);
                end
            elseif strcmp(iOr,"r")
                if i_pic<=13&&i_pic~=6
                    imshow(XYZ_cropped./60);
                else
                    imshow(XYZ_cropped./20);
                end
            end
            title(['图片: ', picnames_groups(i_pic), ' - 点击选择白色正方形中心']);
            axis on;
            hold on;
            
            % 等待用户点击选择中心点
            [x, y] = ginput(1);
            
            % 处理用户取消选择
            if isempty(x)
                disp('用户取消选择，跳过此图片');
                continue;
            end
            
            x = round(x(1));
            y = round(y(1));
            
            % 验证点是否在图片范围内
            [height, width, ~] = size(XYZ_cropped);
            if x < 1 || x > width || y < 1 || y > height
                disp('选择的点超出图片范围，请重新选择');
                i_pic = i_pic - 1;
                continue;
            end
            
            % 计算30x30正方形的边界（中心点偏移）
            sideLength = 30;
            xMin = max(1, x - sideLength/2);
            xMax = min(width, x + sideLength/2);
            yMin = max(1, y - sideLength/2);
            yMax = max(height, y + sideLength/2);
            
            % 保存裁剪信息和图片名称
            picname{i_pic, 1} = picnames_groups(i_pic);
            crop_rect_info(i_pic, :) = [xMin, yMin, sideLength, sideLength];
            
            % 显示选择的区域
            rectangle('Position', [xMin, yMin, sideLength, sideLength], ...
                     'EdgeColor', 'r', 'LineWidth', 2);
            drawnow;
            
            % 计算区域均值
            gray_pos = crop_rect_info(i_pic,:);
            XYZw(i_pic,:) = mean(mean(XYZ_cropped(gray_pos(2):gray_pos(2)+30, ...
                                                  gray_pos(1):gray_pos(1)+30,:)));
            picname_check{i_pic,1} = picnames_groups(i_pic);
            
            % 保存检查图片
            saveas(fig, fullfile(output_folder, "check_pic", ...
                              strcat(lastPart, picnames_groups(i_pic), ".jpg")));
            close(fig);
        end
        
        % 保存裁剪信息和处理结果
        disp(["已保存裁剪信息到: ", fullfile(output_folder,strcat(lastPart,".mat"))]);
        
        % 保存结果数据
        save(fullfile(output_folder,strcat(lastPart,".mat")),"XYZw","picname_check","crop_rect_info");
    end
end
%% 从dsp提取

% new_names = [ "f04", "f05","f06", "m04", "m05","m06"];
% ct=["H3K","H4K","H5K","H6K","HD65","H7K","H8K",...
%    "M3K","M4K","M5K","M6K","MD65","M7K","M8K", ...
% "L3K","L4K","L5K","L6K","LD65","L7K","L8K"];
% 
% folderPath = 'D:\work\VIVOskinExpe\renderCode\dsp\i';
% slashes = strfind(folderPath, '\');
% if ~isempty(slashes)
%     % 提取最后一个斜杠后的内容
%     lastPart = folderPath((slashes(1,end-1)+1:slashes(1,end)-1));
% end
% lastPart=[lastPart,'i'];
% 
% imageFiles = dir(fullfile(folderPath, '*.jpg'));
% numImages = length(imageFiles);
% 
% % 初始化矩阵来存储每张图片中正方形区域的裁剪信息
% crop_rect_info = zeros(numImages, 4); % [x, y, width, height]
% 
% fig = figure('Name', 'RGB Selection', 'NumberTitle', 'off');
% 
% for i_pic = 1:numImages
%     imageFile = fullfile(folderPath, imageFiles(i_pic).name);
%     img = imread(imageFile);
% 
%     imshow(img);
%     title(['Image: ', imageFiles(i_pic).name, ' - Select 1 point']);
% 
%     [height, width, ~] = size(img);
% 
%     h = impoint;
%     position = wait(h);
% 
%     if isempty(position)
%         continue;
%     end
% 
%     x = round(position(1));
%     y = round(position(2));
% 
%     if x < 1 || x > width || y < 1 || y > height
%         disp('Selected point is out of bounds, please select a point within the image.');
%         continue;
%     end
% 
%     % 计算正方形的边界
%     sideLength = 30; % 正方形边长
%     halfSideLength = sideLength / 2;
%     xMin = max(1, x - halfSideLength);
%     xMax = min(width, x + halfSideLength);
%     yMin = max(1, y - halfSideLength);
%     yMax = min(height, y + halfSideLength);
% 
%     % 保存正方形区域的裁剪信息
%     picname(i_pic,1)={imageFiles(i_pic).name};
%     crop_rect_info(i_pic, :) = [xMin, yMin, sideLength, sideLength];
% end
% 
% close(fig);
% 
% % 保存crop_rect_info到MATLAB文件
% % outputFolder = fullfile(output_folder, "crop_rect_info");
% % if ~exist(outputFolder, "dir")
% %     mkdir(outputFolder);
% % end
% 
% outputFolder="whiteSquare";
% % outputFolder="skinSquare";
% if ~exist(outputFolder, "dir")
%     mkdir(outputFolder);
% end
% filename = fullfile(outputFolder, strcat('crop_rect_info_white_',lastPart,'.mat'));
% save(filename, 'crop_rect_info','picname');