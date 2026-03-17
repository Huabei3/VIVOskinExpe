close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量
addpath("utils\");
%%

%-----------i--------------
source_folder='D:\work\VIVOskinExpe\AndroidStudio1\maleVIVOr65\app\src\main\res\drawable';
slashe = find(source_folder=='\');
lastPart = source_folder(slashe(end-5)+1:slashe(end-4)-1);
lastPart=strrep(lastPart,'65','');
lastPart=gen_lastPart_new(lastPart);
%--------------

files = dir(fullfile(source_folder,'*.jpg'));  % 读取文件夹中的所有.jpg文件
dir_mask=dir(fullfile("..\renderCode\mask",lastPart,"*.jpg"));
dir_mask_sd=dir(fullfile("..\renderCode\Shadow\mask",lastPart,"nosd\*.jpg"));
dir_XYZ=dir(strcat("..\renderCode\XYZ\rs\",lastPart,"\*.mat"));

if ismember(lastPart,["f04i","f05i","f06i","m04i","m06i"]) 
    if_wei=0;
else
    if_wei=1;
end

% if ismember(lastPart,["m02i","m03i"]) 
%     dir_mask_used=dir_mask_sd;
% else
dir_mask_used=dir_mask;
% end

wd65=[94.813  100.000  107.262];
save_folder=fullfile('aveSkinByHand2',lastPart);

if ~exist(save_folder,"dir")
    mkdir(save_folder);
end

average_rgb_all=[]; average_xyz_all=[]; average_lab_all=[]; average_lab1_all=[];
de_all=[]; de00_all=[]; de00c_all=[];
XYZ_all=[]; XYZw_all=[];

datai_file = '..\renderCode\calibResults\datai_ipv18_3.mat';
LUT=load(datai_file);
XYZw_LUT=LUT.XYZw;
wd65_scaled=wd65./100.*XYZw_LUT(2);  

% 初始化上一个前缀
prev_prefix = '';
bull = [];

for i = 1:numel(files) 
    img=imread(fullfile(files(i).folder, files(i).name));
    [m, n, p] = size(img); 
    
    % 提取当前文件名_之前的部分
    underscore_pos = strfind(files(i).name, '_');
    if ~isempty(underscore_pos)
        current_prefix = files(i).name(1:underscore_pos(1)-1);
    else
        current_prefix = files(i).name(1:end-4); % 如果没有下划线，使用整个文件名(不含扩展名)
    end
    
    % 只有当前缀变化时才重新寻找并加载掩码
    if ~strcmp(current_prefix, prev_prefix)
        % 重置标志
        mask_found = false;
        
        % 寻找匹配的掩码
        for i_mask = 1:length(dir_mask_used)
            picname_cur = strrep(gen_lastPart_new(files(i).name(1:end-4)), lastPart, "");
            if contains(picname_cur, dir_mask_used(i_mask).name(1:end-4))
                picname_check{i,1} = files(i).name(1:end-4);
                picname_check{i,2} = dir_mask_used(i_mask).name(1:end-4);
                bull = imread(fullfile(dir_mask_used(i_mask).folder, dir_mask_used(i_mask).name));
                mask_found = true;
                break;
            end
        end
        
        % 如果没有找到匹配的掩码，使用上一个掩码或设置默认值
        if ~mask_found
            if ~isempty(bull)
                warning('未找到匹配的掩码，使用上一个掩码');
            else
                warning('未找到匹配的掩码，使用全白掩码');
                bull = ones(m, n, 'uint8') * 255;
            end
        end
        
        % 更新上一个前缀
        prev_prefix = current_prefix;
    end
    
    bull = double(bull);
    bull_reshaped = reshape(bull, [m * n, size(bull,3)]) ./ 255;
    bull_weight = mean(bull_reshaped, 2);
    disp(min(bull_weight));
    
    logicalIndex = all(bull_reshaped == 0, 2);
    out = reshape(img, [m * n, p]);
    out = double(out);
    
    % 颜色空间转换
    xyz = lut3d_rgb2xyz1(out, datai_file);
    [lab] = xyz2lab(xyz, 'user', wd65_scaled);
    average_lab = get_average(lab, bull, if_wei);
    
    dlabsNpicname{i,1} = average_lab;
    dlabsNpicname{i,2} = files(i).name(1:end-4);

    %-----画mask区域肤色预览图-----------
    out = uint8(double(out) .* bull_weight);
    figure(1);
    imshow(reshape(out, [m, n, p]));
    
    output_folder = fullfile(save_folder, "cropped_area_skin");
    if ~exist(output_folder, "dir")
        mkdir(output_folder);
    end
    
    imwrite(reshape(out, [m, n, p]), fullfile(output_folder, strcat(files(i).name(1:end-4), ".jpg")));
end

save(fullfile("dlabsNpicname", strcat(lastPart, ".mat")), "dlabsNpicname");
disp("done");