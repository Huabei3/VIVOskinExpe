clear; close all;
%%
save_folder = fullfile("ellip_pic_p\ellipse", "VIVOskin\com_ori_with_OPPO");
if ~exist(save_folder, "dir")
    mkdir(save_folder);
end

lastParts = {'f04i', 'f05i', 'f06i', 'm04i', 'm05i', 'm06i',...
'f01i', 'f02i', 'f03i', 'm01i', 'm02i', 'm03i',...
'f07i', 'f08i','m07i', 'm08i',...
'f09i', 'f10i','m09i', 'm10i'};n_para = 21;iOr='i';indices_target = [5,12,19];

    % lastParts = {'f04r', 'f05r', 'f06r', 'm04r', 'm05r', 'm06r',...
    % 'f01r', 'f02r', 'f03r', 'm01r', 'm02r', 'm03r',...
    % 'f07r', 'f08r','m07r', 'm08r',...
    % 'f09r', 'f10r','m09r', 'm10r'};n_para = 14;iOr='r';indices_target = 1:14;

if iOr =='i'
    picnames_groups = ["h3k","h4k","h5k","h6k","hd65","h7k","h8k",...
                    "m3k","m4k","m5k","m6k","md65","m7k","m8k",...
                     "l3k","l4k","l5k","l6k","ld65","l7k","l8k"];
elseif iOr=='r'
    picnames_groups = ["rs01","rs02","rs03","rs04","rs05","rs06","rs07", ...
             "rs08","rs09","rs10","rs11","rs12","rs13","rs14"];
end
load(fullfile("documents",iOr,"render_data2.mat"),"render_map");
Keys = keys(render_map);
lab_ori=[];
for i_lastPart=1:6
% for i_lastPart=1:length(lastParts)
    lastPart=lastParts{i_lastPart};
    for i_par=indices_target
        picname_curr=strcat(lastParts,iOr,picnames_groups(i_par));
        curr_cell=render_map(strcat(lastPart,picnames_groups(i_par)));
        ave(i_lastPart,i_par,:)=curr_cell.average;
        ave_scaled(i_lastPart,i_par,:)=curr_cell.ave_scaled_val;
        ave_aft(i_lastPart,i_par,:)=curr_cell.average_aft_val;
        lab_ori=[lab_ori;curr_cell.average_aft_val];
    end

end




% 提取 L, a, b, C 数据
all_L = lab_ori(:, 1);
all_a = lab_ori(:, 2);
all_b = lab_ori(:, 3);
lab_ori(:, 4) = sqrt(lab_ori(:, 2).^2+lab_ori(:, 3).^2);
C = lab_ori(:, 4);
h = atan2d(all_b, all_a);
h_table=[mean(h),max(h),min(h)];
all_LabCh = [all_L, all_a, all_b, C, h];
% 保存数据
% 设置坐标轴范围
L_limits = [25,90];
a_limits = [0,40];
b_limits = [0,40];
C_limits = [0,50];
h_limits = [45,65];
ab_limits = [min(min(all_a), min(all_b)) - 5, 45];
%% load OPPO


load("D:\work\project_code_backup\OPPOskinExpe\analyzeResult_scaled\documents\CATedPre.mat","picname");
load("D:\work\project_code_backup\OPPOskinExpe\analyzeResult_scaled\neutral24\white.mat","CCT","XYZ_gray");
load("D:\work\project_code_backup\OPPOskinExpe\analyzeResult_scaled\OPPOskin\matchTable.mat");
% lastParts=["inLab","indoorAdd","nightAdd","outdoorAdd","sunsetAdd","recen"];
load('D:\work\project_code_backup\OPPOskinExpe\analyzeResult_scaled\documents\group_Lab.mat','cellMatrix');


render_type="display";
if strcmp(iOr,"r")
    XYZ_gray_used=XYZ_gray(15:end,:);
    folder=fullfile("D:\work\project_code_backup\OPPOskinExpe\dataset_image\iphone\cropped");
elseif strcmp(iOr,"i")
    XYZ_gray_used=XYZ_gray(1:14,:);
    folder=fullfile("D:\work\project_code_backup\OPPOskinExpe\dataset_image\Hassel\cropped");
end
files = dir(fullfile(folder,'*.jpg'));  
dir_mask=dir(fullfile(folder,"mask\*.jpg"));
ave_folder=fullfile('documents',"srgb\d65",iOr,'aveSkinByHand');




wd65=[94.811 100.00 107.304];   
XYZw_pre_all=XYZ_gray./XYZ_gray(:,2).*100;

datai_file = 'D:\work\project_code_backup\OPPOskinExpe\camera_calibration\datai_sorted40_3.mat';
XYZw=load(datai_file);
XYZw=XYZw.XYZw;

if strcmp(render_type,"d65")
    average_file=fullfile(ave_folder,'autoNhand.mat');
else
    average_file=fullfile(folder,'autoNhand.mat');
end
if_render=0;

average=load(average_file);
average=average.average_lab_all(:,5:7);
average(:, 4) = sqrt(average(:, 2).^2+average(:, 3).^2);
XYZ_ave=lab2xyz2(average(:,1:3),"d65_64");
for i_par=1:size(average,1)

    % XYZw_pre(i_nog,:)=XYZw_pre_all(i_par,:);
    wd65_scaled(i_par,:)=wd65.*XYZ_gray_used(i_par,2)./XYZw(2);
    ave_scaled_OPPO(i_par,:)=xyz2lab(XYZ_ave(i_par,:),"user",wd65_scaled(i_par,:));
end

ave_scaled_OPPO(:, 4) = sqrt(ave_scaled_OPPO(:, 2).^2+ave_scaled_OPPO(:, 3).^2);
%%
output_folder=fullfile(save_folder,iOr);
if ~exist(output_folder,"dir")
    mkdir(output_folder);
end

% a-b 图 (h0)
h0=figure(5);
hold on;

% 为每个模型绘制点，使用预先生成的颜色
plot(lab_ori(:, 2), lab_ori(:, 3), ...
    'o', ...
    'Color', 'r', ...
    'MarkerFaceColor', 'r', ...
    'MarkerSize', 5);
plot(ave_scaled_OPPO(:, 2), ave_scaled_OPPO(:, 3), ...
    'o', ...
    'Color', 'b', ...
    'MarkerFaceColor', 'b', ...
    'MarkerSize', 5);
% 添加45°线
x = linspace(ab_limits(1), ab_limits(2), 1000);
y = x; 
plot(x, y, 'k--', 'LineWidth', 1);

xlabel('$a^*$', 'Interpreter', 'latex', 'FontSize', 12*2);
ylabel('$b^*$', 'Interpreter', 'latex', 'FontSize', 12*2);
axis equal;
xlim(ab_limits);
ylim(ab_limits);
exportgraphics(h0, fullfile(output_folder, strcat('all_a_b.jpg')), 'Resolution', 300);

% L-C 图 (h3)
h3=figure(3);
hold on;

plot(lab_ori(:, 4), lab_ori(:, 1), ...
    'o', ...
    'Color', 'r', ...
    'MarkerFaceColor', 'r', ...
    'MarkerSize', 5);
plot(ave_scaled_OPPO(:, 4), ave_scaled_OPPO(:, 1), ...
    'o', ...
    'Color', 'b', ...
    'MarkerFaceColor', 'b', ...
    'MarkerSize', 5);

xlabel('$C_{ab}^*$', 'Interpreter', 'latex', 'FontSize', 12*2);
ylabel('$L^*$', 'Interpreter', 'latex', 'FontSize', 12*2);
axis equal;
xlim(C_limits);
ylim(L_limits);
exportgraphics(h3, fullfile(output_folder, strcat('all_L_C.jpg')), 'Resolution', 300);
concatenate_images1(output_folder, 5);