close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量
%%
% clear; clc;
% % 读取图片
% dir_img=dir('Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\*.jpg');
% dir_bull=dir('Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\CardMask\*.jpg');
% save_folder='Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\cardProcessed';
% 
% for i_img=1:length(dir_img)
%     img = imread(fullfile(dir_img(i_img).folder,dir_img(i_img).name));
%     i_bull=1;
%     while ~contains(dir_img(i_img).name,dir_bull(i_bull).name)
%         i_bull=i_bull+1;
%     end
%     bull = imread(fullfile(dir_bull(i_bull).folder,dir_bull(i_bull).name));
% 
%     % 将bull转换为灰度图
%     bull = rgb2gray(bull);
% 
%     % 创建 bull1，大小与 bull 相同
%     bull1 = zeros(size(bull), 'like', bull);
% 
%     % 查找 bull 中白色区域的边界
%     [ys, xs] = find(bull == 255);
%     if isempty(xs) || isempty(ys)
%         error('Bull image does not contain any region with value 255.');
%     end
% 
%     min_x = min(xs);
%     max_x = max(xs);
%     min_y = min(ys);
%     max_y = max(ys);
% 
%     % 确定白色区域的宽度和高度
%     width = max_x - min_x + 1;
%     height = max_y - min_y + 1;
% 
%     % 将 bull 的白色区域移动到 bull1 的左上角
%     bull1(1:height, 1:width) = bull(min_y:min_y+height-1, min_x:min_x+width-1);
% 
%     % 将 img 中 bull = 255 区域的像素替换为 bull1 中对应位置的像素
%     mask = bull1 > 0;
%     img_replacement = img;
%     img_replacement(repmat(mask, [1, 1, size(img, 3)])) = img(repmat(mask, [1, 1, size(img, 3)]));
% 
%     % 显示结果
%     imshow(img_replacement);
% 
%     % 保存结果
%     imwrite(img_replacement, fullfile(save_folder,dir_img(i_img).name));
% end
% 
% %%
% % 清除工作区所有变量和命令窗口
% clear; clc;
% dir_orimask=dir('Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\CardMask\*.jpg');
% save_folder='Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\CardMask';
% for i_orimask=1:length(dir_orimask)
%     % 读取图像
%     image_path = fullfile(dir_orimask(i_orimask).folder,dir_orimask(i_orimask).name); % 请替换为实际图像路径
%     original_image = imread(image_path);
% 
%     % 查找白色区域的位置
%     [row, col, ~] = find(original_image == 1);
% 
%     % 计算白色区域的边界框
%     min_row = min(row);
%     max_row = max(row);
%     min_col = min(col);
%     max_col = max(col);
% 
%     % 提取白色区域
%     white_region = original_image(min_row:max_row, min_col:max_col, :);
% 
%     % 创建新图像，初始值为全黑
%     [new_height, new_width, ~] = size(original_image);
%     new_image = zeros(new_height, new_width, 3, 'uint8');
% 
%     % 平移白色区域到上边缘或左边缘
%     % 计算平移参数
%     translation_row = min_row - 1; % 上边缘平移
%     translation_col = min_col - 1; % 左边缘平移
% 
%     % 如果行平移更小，优先平移到上边缘
%     if translation_row <= translation_col
%         new_image(1:(max_row-min_row+1), min_col:max_col, :) = white_region;
%         translation_row_final = translation_row;
%         translation_col_final = 0;
%     else
%         new_image(min_row:max_row, 1:(max_col-min_col+1), :) = white_region;
%         translation_row_final = 0;
%         translation_col_final = translation_col;
%     end
% 
%     % 保存新图像
%     saveFolder=fullfile(save_folder,'fillSourceMask');
%     if ~exist(saveFolder,'dir')
%         mkdir(saveFolder);
%     end
%     imwrite(new_image, fullfile(saveFolder,dir_orimask(i_orimask).name));
% 
%     % 保存平移参数
%     saveFolder=fullfile(save_folder,'translation_params');
%     if ~exist(saveFolder,'dir')
%         mkdir(saveFolder);
%     end
%     params = struct('translation_row', translation_row_final, 'translation_col', translation_col_final);
%     save(fullfile(saveFolder,strcat(dir_orimask(i_orimask).name(end-4),'.mat')), '-struct', 'params');
% 
% end
% disp('done');
%%
% Read the image
folder='Z:\homes\Peggy\oppoSkinExperi\picked40\Hassel\downSampled1\cropped\mask';
imgname='female1nomakeup.jpg';
imgin=fullfile(folder,imgname);
imgout=fullfile(folder,imgname);

img = imread(imgin);

% Resize the image to the desired dimensions
resizedImg = imresize(img, [958 973]);

% Save the resized image
imwrite(resizedImg, imgout);
disp("done");



%%
%**********************小图变大图***********************8
% 文件夹路径
% largeImageFolderPath = 'Z:\homes\Peggy\oppoSkinExperi\picked40\iphone';
% smallImageFolderPath = ['Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\cropped\' ...
%     'renderedLUTchoose\renderedAdd07\indoor\drawable'];
% cropRectFolderPath = 'Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\cropped\crop_para';
% outputFolderPath = ['Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\cropped\' ...
%     'renderedLUTchoose\renderedAdd07\indoor\drawable'];
largeImageFolderPath = 'Z:\homes\Peggy\oppoSkinExperi\picked40\iphone';
% smallImageFolderPath = ['Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\cropped\' ...
%     'renderedLUTchoose\renderedAdd07\sunset'];
smallImageFolderPath = ['Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\cropped\' ...
    'renderedLUTchoose\renderedReCen07\'];
cropRectFolderPath = 'Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\cropped\crop_para';
outputFolderPath = ['Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\cropped\' ...
    'renderedLUTchoose\renderedReCen07\rendered_big'];

% 获取文件信息
largeImageFiles = dir(fullfile(largeImageFolderPath, '*.jpg'));
smallImageFiles = dir(fullfile(smallImageFolderPath, '*.jpg'));
cropRectFiles = dir(fullfile(cropRectFolderPath, '*.mat'));

% 批量处理
for i = 1:length(smallImageFiles)
    % 读取小图文件名（去掉后缀）
    [~, smallImageName, ~] = fileparts(smallImageFiles(i).name);
    
    % 查找对应的大图文件
    largeImageFile = '';
    for j = 1:length(largeImageFiles)
        [~, largeImageName, ~] = fileparts(largeImageFiles(j).name);
        if contains(smallImageName, largeImageName)
            largeImageFile = largeImageFiles(j).name;
            break;
        end
    end
    
    % 查找对应的cropRect文件
    cropRectFile = '';
    for k = 1:length(cropRectFiles)
        [~, cropRectName, ~] = fileparts(cropRectFiles(k).name);
        cropRectName = strrep(cropRectName, 'crop_para', '');
        if contains(smallImageName, cropRectName)
            cropRectFile = cropRectFiles(k).name;
            break;
        end
    end
    
    % 确保找到了对应的文件
    if isempty(largeImageFile) || isempty(cropRectFile)
        error('未找到与小图 %s 对应的大图或cropRect文件', smallImageFiles(i).name);
    end
    
    % 读取大图
    largeImage = imread(fullfile(largeImageFolderPath, largeImageFile));
    
    % 读取小图
    smallImage = imread(fullfile(smallImageFolderPath, smallImageFiles(i).name));
    
    % 读取cropRect
    cropRectPath = fullfile(cropRectFolderPath, cropRectFile);
    cropData = load(cropRectPath);
    cropRect = cropData.cropRect;  % 假设.mat文件中变量名为cropRect
    if contains(smallImageFiles(i).name,'sunset03')
        cropRect=[100,100,2100,2924];
    end
    
    % 将小图恢复到大图中
    restoredImage = largeImage;
    restoredImage(cropRect(2):(cropRect(2)+cropRect(4)), cropRect(1):(cropRect(1)+cropRect(3)), :) = smallImage;
    

    
    % 保存恢复后的图像
    [~, name, ext] = fileparts(smallImageFiles(i).name);
    outputFileName = fullfile(outputFolderPath, [name  ext]);
    imwrite(restoredImage, outputFileName);
end


%%
% 获取文件夹路径
folderPath = 'Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\cropped\mask';

% 获取所有JPG文件的信息
jpgFiles = dir(fullfile(folderPath, '*.jpg'));

% 初始化存储1的像素数的数组
pixelCountArray = zeros(length(jpgFiles), 1);

% 遍历每个JPG文件
for i = 1:length(jpgFiles)
    % 获取文件的完整路径
    filePath = fullfile(folderPath, jpgFiles(i).name);
    
    % 读取图像
    img = imread(filePath);
    
    % 确保图像是二值化的（如果不是则进行二值化处理）
    if size(img, 3) == 3
        img = rgb2gray(img);
    end
    img = imbinarize(img);
    
    % 统计像素值为1的数量
    pixelCount = sum(img(:));
    
    % 存储到数组中
    pixelCountArray(i) = pixelCount;
end

% 输出结果
disp(pixelCountArray);

%%
% 指定文件夹路径
folderPath = ['Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\cropped\' ...
    'setPointsUseMask\setPointsUseMask07'];

% 获取文件夹下所有.mat文件的信息
matFiles = dir(fullfile(folderPath, '*.mat'));

% 预先分配一个cell数组来存储所有的结构体
dataCells = cell(1, length(matFiles));

% 遍历每一个.mat文件
for k = 1:length(matFiles)
    % 获取当前文件的完整路径
    filePath = fullfile(folderPath, matFiles(k).name);
    
    % 读取.mat文件内容到一个结构体
    dataStruct = load(filePath);
    
    % 将结构体存储到cell数组中
    dataCells{k} = dataStruct;
end

% 显示读取的结果（可选）
disp(dataCells);

%%
% 指定要处理的文件夹路径
folderPath = ['Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\cropped\' ...
    'renderedLUTchoose\renderedReCen07']; % 替换为实际路径
savePath = ['Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\' ...
    'cropped\renderedLUTchoose\renderedReCen07\drawable'];

% 检查输出文件夹是否存在，如果不存在则创建
if ~exist(savePath, 'dir')
    mkdir(savePath);
end

files = dir(fullfile(folderPath, '*.jpg'));

num_points = readmatrix('Z:\homes\Peggy\oppoSkinExperi\points48.xlsx'); 
num_center = num_points(53,:); 
num_points(50:53,:) = [];
average_file = ['Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\cropped\' ...
    'aveSkinByHand\autoNhand.mat'];
average = load(average_file);
average = average.average_lab_all(:, 5:7);

% 遍历文件夹中的所有 JPG 文件
for k = 1:length(files)
    % 获取当前文件名
    oldName = files(k).name;
    
    % 使用正则表达式匹配文件名格式，忽略括号内的内容
    expression = 'cropped_indoor(\d{2})_(\d{2})\[\d+\.?\d*,\d+\.?\d*,\d+\.?\d*\]';
    tokens = regexp(oldName, expression, 'tokens');
    
    if ~isempty(tokens)
        % 提取数字部分
        i_points = str2double(tokens{1}{2});
        i = str2double(tokens{1}{1});
        
        % 计算 delta_Lab 和 dlab
        delta_Lab = num_points(i_points, :) - num_center;
        dlab = average(i, :) + delta_Lab;
        
        % 构造新的文件名
        newName = sprintf('cropped_indoor%02d_%02d[%0.4f,%0.4f,%0.4f].jpg', ...
            i, i_points, dlab(1), dlab(2), dlab(3));
        
        % 获取完整的文件路径
        oldFilePath = fullfile(folderPath, oldName);
        newFilePath = fullfile(savePath, newName);
        
        % 重命名文件
        movefile(oldFilePath, newFilePath);
        disp(['重命名: ', oldName, ' -> ', newName]);
    else
        disp(['文件名格式不匹配: ', oldName]);
    end
end

disp("done");


%%
% 定义源目录和目标目录
sourceDir = 'Z:\homes\Peggy\OPPO-Skin-Images-2024\哈苏-X2D100C-JPEG'; % 替换为源目录的路径
targetDir = 'Z:\homes\Peggy\oppoSkinExperi\picked40\Hassel'; % 替换为目标目录的路径

% 获取源目录下所有子文件夹
subfolders = dir(sourceDir);
subfolders = subfolders([subfolders.isdir]); % 仅保留文件夹
subfolders = subfolders(~ismember({subfolders.name}, {'.', '..'})); % 去除 '.' 和 '..' 文件夹

% 遍历所有子文件夹
for i = 1:length(subfolders)
    subfolderName = subfolders(i).name;
    subfolderPath = fullfile(sourceDir, subfolderName);
    
    % 定义原文件和目标文件的路径
    sourceFile = fullfile(subfolderPath, '6000km.jpg');
    if exist(sourceFile, 'file') == 2 % 检查文件是否存在
        targetFile = fullfile(targetDir, [subfolderName, '.jpg']);
        
        % 复制文件并重命名
        copyfile(sourceFile, targetFile);
        disp(['已复制并重命名文件: ', sourceFile, ' 到 ', targetFile]);
    else
        disp(['文件未找到: ', sourceFile]);
    end
end

%%
% 打开需要处理的MATLAB脚本文件
scriptFile = 'main_renderMY.m';
fid = fopen(scriptFile, 'r');
if fid == -1
    error(['无法打开文件: ', scriptFile]);
end

% 读取文件内容
content = fread(fid, '*char')';  % 以字符形式读取整个文件内容
fclose(fid);

% 正则表达式匹配和替换注释
processed_content = regexprep(content, '%.*?\n', ''); % 匹配以 '%' 开头的任何内容直到行末

% 输出文件名
outputFile = 'new_rendered_script.m';

% 将处理后的内容写入新文件
fid = fopen(outputFile, 'w');
fwrite(fid, processed_content, 'char');
fclose(fid);

disp(['处理后的内容已写入文件: ', outputFile]);

%%
disp("begin");
% 加载MAT文件（假设MAT文件中包含文本）
load('main_renderMY.m');  % 加载MAT文件，假设其中包含文本内容，如MATLAB代码

% 假设MAT文件中有一个名为 content 的变量，包含文本内容
% 正则表达式匹配和替换注释
processed_content = regexprep(content, '%.*?\n', ''); % 匹配以 '%' 开头的任何内容直到行末

% 输出文件名
outputFile = 'Z:\homes\Peggy\oppoSkinExperi\memoryAWB-simplify\main_renderMY.m';

% 将处理后的内容写入新文件
fid = fopen(outputFile, 'w');
fwrite(fid, processed_content, 'char');
fclose(fid);

disp(['处理后的内容已写入文件: ', outputFile]);





%%
A=load("Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\cropped\setPoints07\" + ...
    "setPoints0.7cropped_outdoor02.mat");
A1=load("Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\cropped\setPoints07\" + ...
    "setPoints0.7cropped_outdoor01.mat");

%%
% folderPath = 'Z:\homes\Peggy\oppoSkinExperi\picked40\iphone';
% load(fullfile(folderPath,'averageLabMatrix.mat'));
% 
% LUTback_file="Z:\homes\Peggy\oppoSkinExperi\LUT3d\results\data_sorted40_3.mat";
% meanRGB= lut3d_xyz2rgb1(meanXYZ38,LUTback_file,1,1);
%lut3d_xyz2rgbIpv_bfCashe1(meanXYZ38,XYZw,LUTback_file);
%%
% % % 指定文件夹路径
% folderPath = 'Z:\homes\Peggy\oppoSkinExperi\picked40\iphone';
% 
% % 获取文件夹中所有 JPG 文件的列表
% fileList = dir(fullfile(folderPath, '*.jpg'));
% 
% % 初始化用于保存平均 Lab 值的矩阵
% averageLabMatrix = [];
% averageXYZMatrix = [];
% for i = 1:length(fileList)
%     % 获取文件名
%     fileName = fileList(i).name;
% 
%     % 构造完整的文件路径
%     filePath = fullfile(folderPath, fileName);
% 
%     % 读取图像
%     img = imread(filePath);
% 
%     % 获取图像尺寸
%     [m, n, ~] = size(img);
% 
%     % 展平图像为 (m*n, 3)
%     imgFlattened = double(reshape(img, [], 3));
% 
%     % 从 RGB 转换到 XYZ
%     datai_file=("Z:\homes\Peggy\oppoSkinExperi\LUT3d\results\datai_sorted40_3.mat");
%     load(datai_file);
%     imgXYZ = lut3d_rgb2xyz1(imgFlattened,datai_file);
% 
%     % 从 XYZ 转换到 Lab
%     [imgLab] = xyz2lab(imgXYZ,'user',XYZw);
% 
%     % 计算整张图片的平均 Lab 值
%     meanLab = mean(imgLab, 1);
%     meanXYZ = mean(imgXYZ, 1);
%     % 将平均 Lab 值添加到矩阵中
%     averageLabMatrix = [averageLabMatrix; meanLab];
%     averageXYZMatrix = [averageXYZMatrix; meanXYZ];
% end
% 
% meanLab38=mean(averageLabMatrix);
% meanXYZ38=mean(averageXYZMatrix);
% LUTback_file="Z:\homes\Peggy\oppoSkinExperi\LUT3d\results\data_sorted40_3.mat";
% 
% 
% % 保存平均 Lab 值矩阵
% save(fullfile(folderPath,'averageLabMatrix.mat'), ...
%     'averageLabMatrix',"averageXYZMatrix","meanXYZ38","meanLab38");
% meanRGB= lut3d_xyz2rgb1(meanXYZ38,LUTback_file,1,1);
% % mean(averageLabMatrix)=   50.6101    1.1818    7.9529
%%
% % 指定文件夹路径
% folderPath = '此电脑\OPPO Find X6 Pro\内部共享存储空间\Download\android\indoor2';
% 
% % 获取文件夹中所有文件的列表
% fileList = dir(folderPath);
% 
% % 循环遍历每个文件
% for i = 1:length(fileList)
%     % 获取文件名
%     fileName = fileList(i).name;
% 
%     % 检查文件名是否包含“复制”
%     if contains(fileName, '复制')
%         % 构造完整的文件路径
%         filePath = fullfile(folderPath, fileName);
% 
%         % 删除文件
%         delete(filePath);
%     end
% end

%%
% **********去[]************
% % 定义源目录和目标目录
sourceDir = ['Z:\homes\Peggy\oppoSkinExperi\picked40\Hassel\downSampled1\' ...
    'cropped\renderedAdd\renderedReCen07']; 
targetDir = ['Z:\homes\Peggy\oppoSkinExperi\picked40\Hassel\downSampled1\' ...
    'cropped\renderedAdd\renderedReCen07\drawable']; 

% sourceDir = ['Z:\homes\Peggy\oppoSkinExperi\picked40\Hassel\downSampled1\' ...
%     'cropped\renderedAdd\renderedAdd07']; 
% targetDir = ['Z:\homes\Peggy\oppoSkinExperi\picked40\Hassel\downSampled1\' ...
%     'cropped\renderedAdd\renderedAdd07\drawable']; 
 

% 检查目标目录是否存在，如果不存在则创建
if ~exist(targetDir, 'dir')
    mkdir(targetDir);
end

% 获取源目录下所有jpg文件的信息
jpgFiles = dir(fullfile(sourceDir, '*.jpg'));

% 遍历每个jpg文件
for k = 1:length(jpgFiles)
    % % pattern = 'female5';
    % pattern = 'indoor05';
    % if ~contains(jpgFiles(k).name, pattern)
    %     continue
    % end
    % 获取当前文件的完整路径
    currentFile = fullfile(sourceDir, jpgFiles(k).name);

    % 获取当前文件名
    [~, fileName, fileExt] = fileparts(jpgFiles(k).name);

    % 删除文件名打头的cropped_
    if startsWith(fileName, 'cropped_')
        fileName = erase(fileName, 'cropped_');
    end

    % 删除文件名中从[开始到后缀名之前的内容（包括[）
    idx = strfind(fileName, '[');
    if ~isempty(idx)
        fileName = fileName(1:idx-1);
    end

    % 生成新的文件名
    newFileName = [fileName, fileExt];

    % 生成目标文件的完整路径
    targetFile = fullfile(targetDir, newFileName);

    % 复制文件到目标目录
    copyfile(currentFile, targetFile);

    % 打印处理信息
    fprintf('File %s renamed and copied to %s\n', jpgFiles(k).name, newFileName);
end

fprintf('All files have been processed.\n');

%%
% %重命名
% % 指定文件夹路径
% folder_path = 'Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\cropped\renderedLUTchoose\renderedLUT07';
% dest_path='Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\cropped\renderedLUTchoose\renderedLUT07\inner07';
% % 获取文件夹中所有文件
% file_list = dir(folder_path);
% 
% % 遍历文件列表
% for i = 1:length(file_list)
%     % 获取文件名
%     [~, name, ext] = fileparts(file_list(i).name);
%     
%     % 检查文件是否不是目录，并且文件名是否以 'inner07' 开头
%     if ~file_list(i).isdir && startsWith(name, 'inner07')
%         % 去掉 'inner07' 前缀的新文件名
%         new_name = [name(8:end) ext];
%         
%         % 构建完整的旧文件路径和新文件路径
%         old_file = fullfile(folder_path, file_list(i).name);
%         new_file = fullfile(dest_path, new_name);
%         
%         % 重命名文件
%         movefile(old_file, new_file);
%     end
% end
% 
% disp('文件重命名完成');

%%
% 选择性复制粘贴文件

% source_folder = 'Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\cropped\renderedLUT\inner';
% destination_folder = 'Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\cropped\renderedLUTchoose\inner1';
% % 检查源文件夹和目标文件夹是否存在
% if ~isfolder(source_folder)
%     error('源文件夹不存在: %s', source_folder);
% end
% if ~isfolder(destination_folder)
%     mkdir(destination_folder); % 如果目标文件夹不存在，创建它
% end
% 
% % 获取源文件夹下所有jpg文件
% jpg_files = dir(fullfile(source_folder, '*.jpg'));
% 
% % 定义符合条件的数字范围
% % valid_ranges = [1:8, 17:24, 33:40];
% valid_ranges = [21, 33];
% % 遍历所有jpg文件
% for i = 1:length(jpg_files)
%     filename = jpg_files(i).name;
% 
%     % 查找文件名中'_'后面的数字
%     tokens = regexp(filename, '^[^_]*_[^_]*_([0-9]{2})\[.*\.jpg$', 'tokens');
%     if ~isempty(tokens)
%         file_number = str2double(tokens{1}{1});
% 
%         % 检查数字是否在有效范围内
%         if ismember(file_number, valid_ranges)
%             % 移动文件到目标文件夹
%             source_path = fullfile(source_folder, filename);
%             destination_path = fullfile(destination_folder, filename);
%             movefile(source_path, destination_path);
%             fprintf('移动文件: %s 到 %s\n', source_path, destination_path);
%         end
%     end
% end



%%

% dir_drawable=dir("Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\cropped\renderedLUT\" + ...
%     "indoorLUTdrawable\indoor10_*.jpg");
% disp("1");
%%
% %生成groupName
% % % 指定要搜索的目录
% directory = 'Z:\homes\Peggy\oppoSkinExperi\analyzeResult\drawable\night';
% 
% % 获取目录中的所有jpg文件
% jpgFiles = dir(fullfile(directory, '*.jpg'));
% 
% % 创建一个空的cell数组来存储文件名中_前的部分
% uniqueNames = {};
% 
% for k = 1:length(jpgFiles)
%     % 获取文件名
%     [~, fileName, ~] = fileparts(jpgFiles(k).name);
% 
%     % 找到文件名中第一个_的位置
%     underscoreIndex = strfind(fileName, '_');
% 
%     % 如果找到了_，提取_前的部分
%     if ~isempty(underscoreIndex)
%         namePart = fileName(1:underscoreIndex(1)-1);
%     else
%         namePart = fileName; % 如果没有_，则使用整个文件名
%     end
% 
%     % 如果uniqueNames中还没有这个namePart，添加进去
%     if ~any(strcmp(uniqueNames, namePart))
%         uniqueNames{end+1} = namePart;
%     end
% end
% 
% % 输出所有独特的部分
% for k = 1:length(uniqueNames)
%     disp(uniqueNames{k})
% end

%%

% 指定源目录和目标目录
sourceDir = 'Z:\homes\Peggy\oppoSkinExperi\picked40\Hassel';
targetDir = 'Z:\homes\Peggy\oppoSkinExperi\picked40\Hassel';

% 如果目标目录不存在，则创建它
if ~exist(targetDir, 'dir')
    mkdir(targetDir);
end

% 获取源目录下所有 JPG 文件
jpgFiles = dir(fullfile(sourceDir, '*.jpg'));

% 遍历所有文件并重命名、复制
for k = 1:length(jpgFiles)
    % 获取文件名和完整路径
    oldName = jpgFiles(k).name;
    oldPath = fullfile(sourceDir, oldName);

    % 进行重命名
    newName = oldName;
    newName = strrep(newName, 'cropped_', '');
    newName = strrep(newName, '7000km', '');
    newName = strrep(newName, '被试男', 'male');
    newName = strrep(newName, '被试女', 'female');
    newName = strrep(newName, '未带妆', 'nomakeup');
    newName = strrep(newName, '已带妆', 'makeup');

    % 目标路径
    newPath = fullfile(targetDir, newName);

    % 复制文件到目标目录
    copyfile(oldPath, newPath);

    % 输出重命名信息
    fprintf('Renamed and copied: %s -> %s\n', oldName, newName);
end



%%
% % %重命名文件
% % % 指定图片文件夹路径
% % 定义源文件夹和目标文件夹
% source_folder = 'Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\cropped\renderedLUTchoose\renderedLUT07\night\rendered_big_night\';
% target_folder = 'Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\cropped\renderedLUTchoose\renderedLUT07\night\drawable_night\';
% 
% % 确保目标文件夹存在，如果不存在则创建
% if ~exist(target_folder, 'dir')
%     mkdir(target_folder);
% end
% 
% % 获取源文件夹中的所有 .jpg 文件
% all_files = dir(fullfile(source_folder, 'cropped_*.jpg'));
% 
% % % 定义需要删除的部分的正则表达式
% pattern_to_delete = '\[.*?\]';
% prefix_to_delete = 'cropped_';
% 
% % 遍历所有文件并复制到目标文件夹，同时修改文件名
% for i = 1:numel(all_files)
%     % 获取原始文件名和路径
%     original_file_name = all_files(i).name;
%     original_file_path = fullfile(all_files(i).folder, original_file_name);
% 
%     % 删除文件名中的指定部分
%     new_file_name = regexprep(original_file_name, pattern_to_delete, '');
%     new_file_name = strrep(new_file_name, prefix_to_delete, '');
% %     new_file_name=sprintf("train%02d.jpg",i);
%     % 生成新的文件路径
%     new_file_path = fullfile(target_folder, new_file_name);
% 
%     % 复制文件到目标文件夹
%     copyfile(original_file_path, new_file_path);
% end
% 
% disp('所有文件已成功复制并重命名。');



%%
% bull1=imread("D:\oppoSkinExperi\picked40\iphone\cropped\correct1\mask\" + ...
%     "mask3_cropped_sunset07.jpg");
% bull2=imread("D:\oppoSkinExperi\picked40\iphone\cropped\correct1\mask\" + ...
%     "mask3_cropped_sunset08.jpg");
% setPoints1=load("D:\oppoSkinExperi\picked40\iphone\cropped\correct1\SetPoints\" + ...
%     "setPointscropped_sunset07.mat");
% setPoints2=load("D:\oppoSkinExperi\picked40\iphone\cropped\correct1\SetPoints\" + ...
%     "setPointscropped_sunset08.mat"); 

