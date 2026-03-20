clc; clear; close all;
addpath("utils\");

%% 配置与初始化
lastParts = {'f04r', 'f05r', 'f06r', 'm04r', 'm05r', 'm06r',... % AS
             'f01r', 'f02r', 'f03r', 'm01r', 'm02r', 'm03r',... % CA
             'f07r', 'f08r', 'm07r', 'm08r',...                 % SA
             'f09r', 'f10r', 'm09r', 'm10r'};                   % AF

% 人种映射配置
nations = ["AS", "CA", "SA", "AF"];
nation_map = containers.Map();
nation_map("AS") = {'f04', 'f05', 'f06', 'm04', 'm05', 'm06'};
nation_map("CA") = {'f01', 'f02', 'f03', 'm01', 'm02', 'm03'};
nation_map("SA") = {'f07', 'f08', 'm07', 'm08'};
nation_map("AF") = {'f09', 'f10', 'm09', 'm10'};
save_folder='documents\backlitAnalysis';
output_file = fullfile(save_folder, 'Backlit_Metrics_Results.xlsx');
if ~exist(save_folder, 'dir'), mkdir(save_folder); end
if exist(output_file, 'file'), delete(output_file); end % 运行前删除旧文件

all_data_cell = {}; % 用于最后总平均

%% 1. 遍历每个 lastPart 计算数据
for i_lastPart = 1:length(lastParts)
    lastPart = lastParts{i_lastPart};
    fprintf('\nProcessing %s...\n', lastPart);
    
    % --- 路径准备 ---
    model = lastPart(1:end-1);
    iOr = lastPart(end);
    file_whiteSquare = fullfile('D:\work\VIVOskinExpe\skin_projectV7\A_characterization\whiteSquare', ['crop_rect_info_white_', lastPart, '.mat']);
    source_folder = fullfile('D:\work\VIVOskinExpe\renderCode\dsp', model, iOr, 'jpg', 'noCard');
    source_folder1 = fullfile('D:\work\VIVOskinExpe\renderCode\dsp', model, iOr, 'jpg', 'card');
    dir_mask = dir(fullfile('D:\work\VIVOskinExpe\renderCode\mask', lastPart, '*.jpg'));
    
    if exist(file_whiteSquare, 'file')
        load(file_whiteSquare); hasWhiteCardInfo = true;
    else
        hasWhiteCardInfo = false; crop_rect_info = [];
    end
    
    files = dir(fullfile(source_folder, '*.jpg'));
    numFiles = numel(files);
    
    % 初始化当前 Sheet 的数据
    sheetImgNames = cell(numFiles, 1);
    sheetSkinRatio = zeros(numFiles, 1);
    sheetWCPercentile = zeros(numFiles, 1);
    sheetWCRatio = zeros(numFiles, 1);
    
    for i = 1:numFiles
        imgName = files(i).name(1:end-4);
        img = imread(fullfile(files(i).folder, files(i).name));
        img1 = imread(fullfile(source_folder1, files(i).name));
        
        % 获取 Mask
        bull = []; flag = 0;
        for i_mask = 1:length(dir_mask)
            if contains(imgName, dir_mask(i_mask).name(1:end-4))
                bull = imread(fullfile(dir_mask(i_mask).folder, dir_mask(i_mask).name));
                flag = 1; break;
            end
        end
        
        if flag == 1
            % 调用计算函数
            sRatio = getSkinRatio(img, bull);
            wCPerc = getWhiteCardPercentile(img1, crop_rect_info, i);
            if hasWhiteCardInfo && i <= size(crop_rect_info, 1)
                wCRatio = getWhiteCardRatio(img1, crop_rect_info, i, false); % 关闭可视化
            else
                wCRatio = NaN;
            end
        else
            sRatio = NaN; wCPerc = NaN; wCRatio = NaN;
        end
        
        sheetImgNames{i} = imgName;
        sheetSkinRatio(i) = sRatio;
        sheetWCPercentile(i) = wCPerc;
        sheetWCRatio(i) = wCRatio;
        % 使用 %.3f 确保输出为普通小数，不使用科学计数法
        fprintf('%s  %.3f  %.3f  %.3f\n', imgName, sRatio, wCPerc, wCRatio);
    end
    
    % 创建 Table 并写入 Excel
    T = table(sheetImgNames, sheetSkinRatio, sheetWCPercentile, sheetWCRatio, ...
        'VariableNames', {'ImgName', 'SkinRatio', 'WhiteCardPercentile', 'WhiteCardRatio'});
    writetable(T, output_file, 'Sheet', lastPart);
    
    % 存入内存用于后续平均值计算
    all_data_cell.(lastPart) = T;
end

%% 2. 计算人种平均与总平均
fprintf('\nCalculating averages...\n');

% 获取图片行名（假设所有模特图片顺序一致）
sampleT = all_data_cell.(lastParts{1});
picNames = sampleT.ImgName;
numPics = height(sampleT);

% --- A. 计算每个人种的平均 ---
for i_n = 1:length(nations)
    curr_nation = nations(i_n);
    models_in_nation = nation_map(curr_nation);
    
    % 初始化累加器
    sumSkin = zeros(numPics, 1); sumWCP = zeros(numPics, 1); sumWCR = zeros(numPics, 1);
    count = 0;
    
    for i_m = 1:length(models_in_nation)
        sheet_key = [models_in_nation{i_m}, 'r']; % 加上 'r' 后缀匹配
        if isfield(all_data_cell, sheet_key)
            t = all_data_cell.(sheet_key);
            sumSkin = sumSkin + fillmissing(t.SkinRatio, 'constant', 0);
            sumWCP  = sumWCP  + fillmissing(t.WhiteCardPercentile, 'constant', 0);
            sumWCR  = sumWCR  + fillmissing(t.WhiteCardRatio, 'constant', 0);
            count = count + 1;
        end
    end
    
    if count > 0
        meanT = table(picNames, sumSkin/count, sumWCP/count, sumWCR/count, ...
            'VariableNames', {'ImgName', 'SkinRatio', 'WhiteCardPercentile', 'WhiteCardRatio'});
        writetable(meanT, output_file, 'Sheet', char(curr_nation));
    end
end

% --- B. 计算总平均 (Mean) ---
sumSkinAll = zeros(numPics, 1); sumWCPAll = zeros(numPics, 1); sumWCRAll = zeros(numPics, 1);
totalCount = length(lastParts);

for i_lp = 1:totalCount
    t = all_data_cell.(lastParts{i_lp});
    sumSkinAll = sumSkinAll + fillmissing(t.SkinRatio, 'constant', 0);
    sumWCPAll  = sumWCPAll  + fillmissing(t.WhiteCardPercentile, 'constant', 0);
    sumWCRAll  = sumWCRAll  + fillmissing(t.WhiteCardRatio, 'constant', 0);
end

grandMeanT = table(picNames, sumSkinAll/totalCount, sumWCPAll/totalCount, sumWCRAll/totalCount, ...
    'VariableNames', {'ImgName', 'SkinRatio', 'WhiteCardPercentile', 'WhiteCardRatio'});
writetable(grandMeanT, output_file, 'Sheet', 'Mean');

fprintf('\nAll analysis completed! Results saved to: %s\n', output_file);







% clc;clear;close all;
% addpath("utils\");
% 
% %% 计算面部相对亮度、白卡百分位、亮度梯度 (逆光检测)
% % 适配根目录：D:\work\VIVOskinExpe\analyze
% % 调用：getSkinRatio, getWhiteCardPercentile, getGradientScore
% % 参考：main_rs.m 中 file_whiteSquare 的调用方式
% 
% %-----------rs----------
% lastParts = {'f04r', 'f05r', 'f06r', 'm04r', 'm05r', 'm06r',...
%     'f01r', 'f02r', 'f03r', 'm01r', 'm02r', 'm03r',...
%     'f07r', 'f08r','m07r', 'm08r',...
%     'f09r', 'f10r','m09r', 'm10r'};
% 
% % 存储所有结果的数组
% allResults = [];
% 
% for i_lastPart = 1:length(lastParts)
%     lastPart = lastParts{i_lastPart};
%     fprintf('\n========== Processing %s ==========\n', lastPart);
% 
%     % 加载白卡裁剪信息 (参考 main_rs.m 的方式)
%     file_whiteSquare = fullfile('D:\work\VIVOskinExpe\skin_projectV7\A_characterization\whiteSquare', ['crop_rect_info_white_', lastPart, '.mat']);
%     if exist(file_whiteSquare, 'file')
%         load(file_whiteSquare);  % 加载 crop_rect_info
%         hasWhiteCardInfo = true;
%     else
%         warning('未找到白卡信息文件：%s', file_whiteSquare);
%         hasWhiteCardInfo = false;
%         crop_rect_info = [];
%     end
% 
%     model = lastPart(1:end-1);
%     iOr = lastPart(end);
% 
%     % 路径配置 (相对于 analyze 目录)
%     source_folder = fullfile('D:\work\VIVOskinExpe\renderCode\dsp', model, iOr, 'jpg', 'noCard');
%     source_folder1 = fullfile('D:\work\VIVOskinExpe\renderCode\dsp', model, iOr, 'jpg', 'card');
%     dir_mask = dir(fullfile('D:\work\VIVOskinExpe\renderCode\mask', lastPart, '*.jpg'));
%     dir_XYZ = dir(fullfile('D:\work\VIVOskinExpe\renderCode\XYZ', 'r', lastPart, '*.mat'));
% 
%     % 权重设置
%     if ismember(lastPart, {'f04i','f05i','f06i','m04i','m06i'})
%         if_wei = 0;
%     else
%         if_wei = 1;
%     end
% 
%     % 读取图片列表
%     files = dir(fullfile(source_folder, '*.jpg'));
% 
%     % 初始化结果数组
%     results = struct();
%     results.lastPart = lastPart;
%     results.imgNames = {};
%     results.skinRatio = [];
%     results.whiteCardPercentile = [];
%     results.whiteCardRatio = [];
%     results.gradientScore = [];
% 
%     for i = 1:numel(files)
%         imgName = files(i).name(1:end-4);
%         fprintf('  Processing %s... ', imgName);
% 
%         % 读取图像
%         img = imread(fullfile(files(i).folder, files(i).name));
%         img1 = imread(fullfile(source_folder1, files(i).name));
%         [m, n, p] = size(img);
% 
%         % 读取面部 mask
%         flag = 0;
%         bull = [];
%         for i_mask = 1:length(dir_mask)
%             if contains(imgName, dir_mask(i_mask).name(1:end-4))
%                 bull = imread(fullfile(dir_mask(i_mask).folder, dir_mask(i_mask).name));
%                 flag = 1;
%                 break;
%             end
%         end
% 
%         if flag == 1
%             % ========== 可视化：显示图片 ==========
%             figureHandle = figure('Name', sprintf('%s - %s', lastPart, imgName), 'Visible', 'on');
%             figure(1);hold on;
%             imshow(img);
% 
%             title(sprintf('%s - %s | skin=%.3f | WC%%=%.3f | WCR=%.3f | grad=%.4f', ...
%                 lastPart, imgName, NaN, NaN, NaN, NaN));
% 
%             % 计算 SkinRatio
%             skinRatio = getSkinRatio(img, bull);
% 
%             % 计算 WhiteCardPercentile
%             whiteCardPercentile = getWhiteCardPercentile(img1, crop_rect_info, i);
% 
%             % 计算 WhiteCardRatio (带可视化：框出白卡区域)
%             if hasWhiteCardInfo && ~isempty(crop_rect_info) && i <= size(crop_rect_info, 1)
%                 whiteCardRatio = getWhiteCardRatio(img1, crop_rect_info, i, true);
%             else
%                 whiteCardRatio = NaN;
%             end
% 
% 
%             % 计算 GradientScore (带可视化)
%             % 将 mask 转换为逻辑矩阵
%             if size(bull, 3) == 3
%                 bull_gray = bull(:,:,2);
%             else
%                 bull_gray = bull;
%             end
%             faceMask = bull_gray > 128;
%             [gradientScore, faceCenter, faceRadius, detectionBox] = getGradientScore(img, faceMask, 10);
% 
%             % 更新标题显示所有指标
%             title(sprintf('%s - %s | skin=%.3f | WC%%=%.3f | WCR=%.3f | grad=%.4f', ...
%                 lastPart, imgName, skinRatio, whiteCardPercentile, whiteCardRatio, gradientScore));
% 
%             % 存储结果
%             results.imgNames{i} = imgName;
%             results.skinRatio(i) = skinRatio;
%             results.whiteCardPercentile(i) = whiteCardPercentile;
%             results.whiteCardRatio(i) = whiteCardRatio;
%             results.gradientScore(i) = gradientScore;
% 
%             fprintf('skinRatio=%.3f, whiteCard%%=%.3f, whiteCardRatio=%.3f, gradient=%.4f\n', ...
%                 skinRatio, whiteCardPercentile, whiteCardRatio, gradientScore);
%         else
%             fprintf('No mask found\n');
%             results.imgNames{i} = imgName;
%             results.skinRatio(i) = NaN;
%             results.whiteCardPercentile(i) = NaN;
%             results.gradientScore(i) = NaN;
%         end
%     end
% 
%     % 添加到总结果
%     allResults = [allResults; results];
% 
%     % 保存当前 lastPart 的结果
%     save_folder = fullfile('backlitAnalysis', lastPart);
%     if ~exist(save_folder, 'dir')
%         mkdir(save_folder);
%     end
%     save(fullfile(save_folder, 'backlit_metrics.mat'), 'results');
% 
%     % 统计摘要
%     validSkinRatio = results.skinRatio(~isnan(results.skinRatio));
%     validWhiteCard = results.whiteCardPercentile(~isnan(results.whiteCardPercentile));
%     validWhiteCardRatio = results.whiteCardRatio(~isnan(results.whiteCardRatio));
%     validGradient = results.gradientScore(~isnan(results.gradientScore));
% 
%     fprintf('  Summary for %s:\n', lastPart);
%     fprintf('    SkinRatio: mean=%.3f, std=%.3f (n=%d)\n', ...
%         mean(validSkinRatio), std(validSkinRatio), length(validSkinRatio));
%     fprintf('    WhiteCardPercentile: mean=%.3f, std=%.3f (n=%d)\n', ...
%         mean(validWhiteCard), std(validWhiteCard), length(validWhiteCard));
%     fprintf('    WhiteCardRatio: mean=%.3f, std=%.3f (n=%d)\n', ...
%         mean(validWhiteCardRatio), std(validWhiteCardRatio), length(validWhiteCardRatio));
%     fprintf('    GradientScore: mean=%.4f, std=%.4f (n=%d)\n', ...
%         mean(validGradient), std(validGradient), length(validGradient));
% 
%     % 逆光判断 (参考阈值)
%     backlitBySkin = sum(validSkinRatio < 0.65);
%     backlitByWhiteCard = sum(validWhiteCard < 0.35);
%     backlitByWhiteCardRatio = sum(validWhiteCardRatio < 0.65);
%     backlitByGradient = sum(validGradient < 0);
%     fprintf('    Backlit detection: skin=%d/%d, whiteCard%%=%d/%d, whiteCardRatio=%d/%d, gradient=%d/%d\n', ...
%         backlitBySkin, length(validSkinRatio), ...
%         backlitByWhiteCard, length(validWhiteCard), ...
%         backlitByWhiteCardRatio, length(validWhiteCardRatio), ...
%         backlitByGradient, length(validGradient));
% 
%     disp('done');
% end
% 
% % 保存所有结果
% save('backlitAnalysis\all_backlit_metrics.mat', 'allResults');
% fprintf('\n========== All analysis completed ==========\n');
% fprintf('Results saved to backlitAnalysis\all_backlit_metrics.mat\n');
