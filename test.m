clear;clc;close all;addpath("utils\")
%% 查看
% savefile='gog\GOGpara.mat';
% wd65_64=[94.811 100.00 107.304];
% XYZw_pre=[33.521517698541395,34.853121228819360,29.380539268455140];
% % XYZw_pre=[82.899171244283790,86.782992208213000,75.037090964697270];
% XYZw_pre=XYZw_pre./XYZw_pre(2).*wd65_64(2);
% XYZ_96white=[124.035328150026	128.030968697676	143.941971778570];
% 
% img_folder="new_exp";
% 
% mask_file="ori\mask\ori1_1.jpg";
% mask=imread(mask_file);
% mask=mask./255;
% mask=mean(mask,3);
% mask_indices = mask == 1;
% for i_level=1:8
%     dir_img=dir(fullfile(img_folder,strcat(sprintf("rendering_Lab=[%02d",10*i_level),"*.jpg")));
%     filename=fullfile(dir_img(1).folder,dir_img(1).name);
%     img=imread(filename);
%     [~, name_only, ~] = fileparts(filename);
%     lab_str = extractBetween(name_only, '[', ']');
%     lab_cell = strsplit(lab_str{1}, ',');
%     lab_name = [str2double(lab_cell{1}), str2double(lab_cell{2}), str2double(lab_cell{3})];
% 
%     img=double(img)./255;
%     sz=size(img);
%     rgb_i=reshape(img,[sz(1)*sz(2),sz(3)]);
%     xyz_i=display_f(rgb_i,savefile);
%     xyz_mean(i_level,:)=mean(xyz_i,1);
%     % lab_i=xyz2lab(xyz_i,"d65_31");
% 
% 
% 
% end
% save("documents\Y_mean.mat","xyz_mean");
%% 查看Ricky转的时候用的什么白点
% savefile='gog\GOGpara.mat';
% wd65_64=[94.811 100.00 107.304];
% XYZw_pre=[33.521517698541395,34.853121228819360,29.380539268455140];
% % XYZw_pre=[82.899171244283790,86.782992208213000,75.037090964697270];
% XYZw_pre=XYZw_pre./XYZw_pre(2).*wd65_64(2);
% 
% 
% img_folder="new_exp";
% dir_img=dir(fullfile(img_folder,"*.jpg"));
% mask_file="ori\mask\ori1_1.jpg";
% mask=imread(mask_file);
% mask=mask./255;
% mask=mean(mask,3);
% mask_indices = mask == 1;
% for i_img=1:size(dir_img,1)
%     filename=fullfile(dir_img(i_img).folder,dir_img(i_img).name);
%     img=imread(filename);
%     [~, name_only, ~] = fileparts(filename);
%     lab_str = extractBetween(name_only, '[', ']');
%     lab_cell = strsplit(lab_str{1}, ',');
%     lab_name = [str2double(lab_cell{1}), str2double(lab_cell{2}), str2double(lab_cell{3})];
% 
%     img=double(img)./255;
%     sz=size(img);
%     rgb_i=reshape(img,[sz(1)*sz(2),sz(3)]);
%     xyz_i=display_f(rgb_i,savefile);
%     lab_i=xyz2lab(xyz_i,"d65_64");
%     lab_i2=xyz2lab(xyz_i,"d65_31");
%     lab_i1=xyz2lab(xyz_i,"user",XYZw_pre);
% 
%     lab_extract=mean(lab_i(mask_indices,:));
%     lab_extract1=mean(lab_i1(mask_indices,:));
%     lab_extract2=mean(lab_i2(mask_indices,:));
%     dE(i_img,1)=deltaE2000(lab_name,lab_extract);
%     dE(i_img,2)=deltaE2000(lab_name,lab_extract1);
%     dE(i_img,3)=deltaE2000(lab_name,lab_extract2);
% 
% 
% end
%% find PMCC white against display white
% load("SkinColorPreferenceScale\whiteSquare\crop_rect_info_white.mat")
% % 假设原始图像和裁剪区域信息已定义
% img = imread('ori\bigOri.jpg'); % 读取RGB图像
% img=double(img);
% % crop_rect_info = [x, y, width, height]; % 裁剪区域坐标向量
% savefile='gog\GOGpara.mat';
% % 提取裁剪区域的RGB数据
% RGB_white = mean(mean(img(crop_rect_info(2):crop_rect_info(2)+crop_rect_info(4)-1, ...
%                   crop_rect_info(1):crop_rect_info(1)+crop_rect_info(3)-1, :)));
% RGB_white=reshape(RGB_white,[1,3]);
% RGB_white=RGB_white./255;
% XYZ_white=display_f(RGB_white,savefile);
% imshow(img./255)
% rectangle('Position', [crop_rect_info(1), crop_rect_info(2), 30, 30], ...
%       'EdgeColor', 'r', ...        % 矩形框的边缘颜色为红色
%       'LineWidth', 2);      
% XYZ_gogwhite=[116.13,116.14,134.37];
%% 提取原图平均肤色
% img=imread("D:\work\FirstYearMaster\SkinColorPreferenceScale\ori\ori1.jpg");
% 
% 
% bull=imread("D:\work\FirstYearMaster\SkinColorPreferenceScale\ori\mask\ori1_1.jpg");
% [logicalIndex,bull_weight]=read_bull(bull,0);
% 
% [m, n, p] = size(img);
% out=reshape(img, [m * n, p]);
% out=double(out);
% xyz=srgb2xyz(out);
% 
% [lab] = xyz2lab(xyz,'d65_64');
% 
% average_lab=get_average(lab,bull,0);
% 
% 
% %-----画mask区域肤色预览图-----------
% out=uint8(double(out).*bull_weight);
% 
% imshow(reshape(out,[m,n,p]));
%% 找Dt
% img_ori=imread("ori\ori1.jpg");
% img_aft=imread("new_exp\rendering_Lab=[60,16,20].jpg");
% bull=imread("ori\mask\ori1_1.jpg");
% 
% [logicalIndex,bull_weight]=read_bull(bull,0);
% sz = size(img_ori);
% rgb_ori=reshape(img_ori, [sz(1) * sz(2), sz(3)]);
% rgb_ori=double(rgb_ori);
% rgb_ori_non_face=rgb_ori(logicalIndex,:);
% xyz_ori_non_face=srgb2xyz(rgb_ori_non_face);
% xyz_ori=srgb2xyz(rgb_ori);
% 
% rgb_aft=reshape(img_aft, [sz(1) * sz(2), sz(3)]);
% rgb_aft=double(rgb_aft);
% rgb_aft_non_face=rgb_aft(logicalIndex,:);
% savefile='gog\GOGpara.mat';
% xyz_aft_non_face=display_f(rgb_aft_non_face./255,savefile).*100;
% % xyz_aft_non_face=srgb2xyz(rgb_aft_non_face);
% 
% M=[0.401288   0.650173  -0.051461
%      -0.250268   1.204414   0.045854
%      -0.002079   0.048952   0.953127];%CAT16
% 
% lms_ori=M*xyz_ori';
% % lms_ori=lms_ori';
% lms_ori_non_face=M*xyz_ori_non_face';lms_ori_non_face=lms_ori_non_face';
% lms_aft_non_face=M*xyz_aft_non_face';lms_aft_non_face=lms_aft_non_face';
% 
% 
% gain_all=lms_aft_non_face./lms_ori_non_face;
% 
% gain_all(isinf(gain_all)) = nan;
% lms_gain=mean(gain_all);
% % lms_gain=mean(gain_all,1,"omitnan");
% 
% % step 3 ------RGB1 to RGB2-----------
% lms_CATed=lms_ori'.*lms_gain;
% 
% % step 4 ------RGB2 to XYZ2-----------
% XYZ_CATed=(M\lms_CATed')';
% XYZ_CATed(XYZ_CATed<0)=0;
% % rgb_CATed=xyz2srgb(XYZ_CATed);
% % rgb_CATed1=reshape(rgb_CATed./255, [sz(1) , sz(2), sz(3)]);
% rgb_CATed=display_r(XYZ_CATed./100,savefile);
% rgb_CATed1=reshape(rgb_CATed, [sz(1) , sz(2), sz(3)]);
% 
% imshow(rgb_CATed1);
% imwrite(rgb_CATed1,"..\memoryAWB-simplify\pictures\result\esti_CATed.jpg");

%% find PMCC white against display white with Dt
% Dt=[0.8477    0.8955    1.5772]';
% 
% load("SkinColorPreferenceScale\whiteSquare\crop_rect_info_white.mat")
% savefile='gog\GOGpara.mat';
% % 假设原始图像和裁剪区域信息已定义
% img = imread('ori\bigOri.jpg'); % 读取RGB图像
% img=double(img);
% sz=size(img);
% rgb_ori=reshape(img, [sz(1) * sz(2), sz(3)]);
% rgb_ori=double(rgb_ori);
% 
% xyz_ori=srgb2xyz(rgb_ori);
% XYZ_CATed = SimpleTwostepCAT_Dt (xyz_ori,Dt);
% rgb_CATed=display_r(XYZ_CATed./100,savefile);
% rgb_CATed1=reshape(rgb_CATed, [sz(1) , sz(2), sz(3)]);
% XYZ_CATed1=reshape(XYZ_CATed, [sz(1) , sz(2), sz(3)]);
% 
% imshow(rgb_CATed1);
% imwrite(rgb_CATed1,"..\memoryAWB-simplify\pictures\result\big_ori_esti_CATed.jpg");
% XYZw_PMCC_CATed = mean(mean(XYZ_CATed1(crop_rect_info(2):crop_rect_info(2)+crop_rect_info(4)-1, ...
%                   crop_rect_info(1):crop_rect_info(1)+crop_rect_info(3)-1, :)));
% XYZw_PMCC_CATed=squeeze(XYZw_PMCC_CATed);
% XYZw_PMCC_CATed=XYZw_PMCC_CATed';
% % 提取裁剪区域的RGB数据
% % RGB_white = mean(mean(img(crop_rect_info(2):crop_rect_info(2)+crop_rect_info(4)-1, ...
% %                   crop_rect_info(1):crop_rect_info(1)+crop_rect_info(3)-1, :)));
% % RGB_white=reshape(RGB_white,[1,3]);
% % RGB_white=RGB_white./255;
% savefile='gog\GOGpara.mat';
% % XYZ_white=display_f(RGB_white,savefile);
% imshow(img./255)
% rectangle('Position', [crop_rect_info(1), crop_rect_info(2), 30, 30], ...
%       'EdgeColor', 'r', ...        % 矩形框的边缘颜色为红色
%       'LineWidth', 2);      
% XYZ_gogwhite=[116.13,116.14,134.37];
%% 计算所有图片背景和"中性图片"的平均色差


% clear; clc; close all;
% 
% % 1. 配置参数（根据你的实际路径修改）
% img_folder = '..\memoryAWB-simplify\pictures\result\find_bg';          % img文件夹路径
% new_exp_folder = 'new_exp';  % new_exp文件夹路径
% % crop_rect_info = [1146,178,30,30]; % [x, y, width, height] 裁剪区域信息
% crop_rect_info =[18	628	30	30];
% % 注意：crop_rect_info(1)=x(列起始), crop_rect_info(2)=y(行起始)
% %       crop_rect_info(3)=宽度(列数), crop_rect_info(4)=高度(行数)
% dE = []; % 存储平均色差结果
% 
% % 2. 获取img文件夹中所有目标图片
% img_files = dir(fullfile(img_folder, 'img*.jpg'));
% 
% 
% n_imgs = length(img_files); 
% 
% % 3. 遍历每张img图片，执行匹配+裁剪+色差计算
% for i_img = n_imgs:-1:1
%     % ---------------------- Step 3.1: 提取当前img图片的第一个数字 ----------------------
%     img_filename = img_files(i_img).name;
%     img_filename=char(img_filename);
%     slash1=find(img_filename=='[');
%     slash2=find(img_filename==',');
%     slash3=find(img_filename==']');
%     l_str=img_filename(slash1+1:slash2(1)-1);
%     a_str=img_filename(slash2(1)+1:slash2(2)-1);
%     b_str=img_filename(slash2(2)+1:slash3-1);
%     lab_target=[str2double(l_str),str2double(a_str),str2double(b_str)];
% 
% 
%     new_exp_files = dir(fullfile(new_exp_folder, strcat('rendering_Lab=[',l_str,'*.jpg')));
%     % ---------------------- Step 3.2: 在new_exp文件夹中匹配第一个数字相同的图片 ----------------------
%     img1 = imread(fullfile(img_files(i_img).folder, img_files(i_img).name));
%     img2=imread(fullfile(new_exp_files(1).folder,new_exp_files(1).name));
% 
%     % ---------------------- Step 3.3: 读取图片并裁剪指定区域 ----------------------
%     % if i_img==1
%         % figure(1); hold on;
%         % imshow(img1);
%         % rectangle('Position', [crop_rect_info(1), crop_rect_info(2), 30, 30], ...
%         %   'EdgeColor', 'r', ...        % 矩形框的边缘颜色为红色
%         %   'LineWidth', 2);   
%     % end
%     % 验证裁剪区域是否合法
%     crop_x1 = crop_rect_info(1);
%     crop_y1 = crop_rect_info(2);
%     crop_w = crop_rect_info(3);
%     crop_h = crop_rect_info(4);
% 
%     sub_img1 = img1(crop_rect_info(2):crop_rect_info(2)+30, ...
%         crop_rect_info(1):crop_rect_info(1)+30, :);
%     sub_img2 = img2(crop_rect_info(2):crop_rect_info(2)+30, ...
%         crop_rect_info(1):crop_rect_info(1)+30, :);
% 
%     % ---------------------- Step 3.4: 颜色空间转换（RGB→XYZ→Lab） ----------------------
%     % 转换为双精度浮点数（0-1范围）
%     sz = size(sub_img1);
%     sub_img1_rspd = reshape(double(sub_img1)./255,[sz(1)*sz(2),sz(3)]);
%     sub_img2_rspd = reshape(double(sub_img2)./255, [sz(1)*sz(2),sz(3)]);
%     % RGB转XYZ（使用sRGB标准转换，MATLAB内置函数）
%     % 若需自定义转换矩阵，可替换此处
%     XYZ1_1=srgb2xyz(sub_img2_rspd.*255).*100;
%     % figure(2);
%     % imshow(reshape(XYZ1_1,[sz(1),sz(2),sz(3)]))
%     % Lab1_1 = xyz2lab(XYZ1_1,"d65_64");
%     savefile='gog\GOGpara.mat';
%     XYZ1=display_f(sub_img1_rspd,savefile);
%     XYZ2=display_f(sub_img2_rspd,savefile);
% 
%     % XYZ1_full=display_f(reshape(img1,[sz(1)*sz(2),sz(3)]),savefile);
% 
% 
%     % XYZ转Lab（参考白场为D65，默认设置）
%     Lab1 = xyz2lab(XYZ1.*100,"d65_64");
%     Lab2 = xyz2lab(XYZ2.*100,"d65_64");
% 
%     % ---------------------- Step 3.5: Reshape+计算平均色差 ----------------------
% 
%     dE_pixel = deltaE2000(Lab1, Lab2)';
% 
%     % 计算平均色差
%     mean_dE = mean(dE_pixel,1,"omitnan");
%     dE(i_img, 1) = mean_dE;
%     dE(i_img, 2:4) = lab_target;
%     % disp(i_img)
% 
% end
% 
% % 4. 结果输出
% fprintf('\n所有图片处理完成！\n');
% fprintf('平均色差结果存储在dE矩阵中，维度：%d×1\n', size(dE,1));
% % 可选：保存dE结果到mat文件
% save(fullfile(img_folder,'mean_dE_results.mat'), 'dE');
% fprintf('色差结果已保存至mean_dE_results.mat\n');

%% 找出平均色差最小的"中性图片"
% 
% for i_level=10:10:80
%     dE_level=dE(dE(:,2)==i_level,:);
%     [Min,Ind]=min(dE_level(:,1));
%     lab_min(i_level/10,:)=dE_level(Ind,:);
% 
% 
% end
% save(fullfile(img_folder,'mean_dE_results.mat'), 'dE',"lab_min");
%% 求背景平均亮度
% 极简版：JPG图片RGB转XYZ并计算全局平均
load("SkinColorPreferenceScale\whiteSquare\crop_rect_info_white.mat")
XYZ_gogwhite=[116.13,116.14,134.37];
p='D:\work\FirstYearMaster\memoryAWB-simplify\pictures\result\find_bg\big_ori';
d=dir(fullfile(p,'*.jpg'));
for i_level=1:length(d)
    img=imread(fullfile(p,d(i_level).name));
    sz = size(img);
    img_rspd = reshape(double(img)./255,[sz(1)*sz(2),sz(3)]);
    savefile='gog\GOGpara.mat';
    XYZ=display_f(img_rspd,savefile);
    XYZ_bg_gray(i_level,:)=mean(XYZ);
    mean(XYZ)
    XYZ_2d=reshape(XYZ,[sz(1),sz(2),sz(3)]);
    XYZ_bg_peak(i_level,:) = mean(mean(XYZ_2d(crop_rect_info(2):crop_rect_info(2)+crop_rect_info(4)-1, ...
                  crop_rect_info(1):crop_rect_info(1)+crop_rect_info(3)-1, :)));


    imshow(img);hold on;
    rectangle('Position', [crop_rect_info(1), crop_rect_info(2), 30, 30], ...
          'EdgeColor', 'r', ...        % 矩形框的边缘颜色为红色
          'LineWidth', 2);  

end
XYZ_bg_gray_scaled=XYZ_bg_gray.*XYZ_gogwhite(2);
XYZ_bg_peak_scaled=XYZ_bg_peak.*XYZ_gogwhite(2);
save(fullfile("whiteSquare\bg_gray.mat"), ...
    "XYZ_bg_gray","XYZ_bg_gray_scaled","XYZ_gogwhite", ...
    "XYZ_bg_peak","XYZ_bg_peak_scaled");
