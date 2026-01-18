clear all;
% load('SONY-XYZ729-0511.mat') %load XYZ cube
% load('XYZ-samsung-tabs-slides.mat');
% load('XYZ-Apple-XDR-HDR.mat');

% XYZ_table1=readtable("E:\documents\pycharm\jeti\test-color-patch_1-2024-05-27-13.csv");
% XYZ_table2=readtable("E:\documents\pycharm\jeti\test_color_patch_2.csv");
% XYZ_table5=readtable("E:\documents\pycharm\jeti\test_color_patch_5.csv");

XYZ_table=readtable("results\" + ...
    "test-color-patch-3-729.csv");
XYZ_spd=table2array(XYZ_table(:,1:end));
SPDname = 380:1:780;
SPDname = SPDname';
XYZ10 = spd2xyz([SPDname XYZ_spd'],10);

%XYZ9=XYZ10;
%调整顺序XYZ
load("Rgb729.mat");
RGB_729=readtable("rgb_values1.csv");
RGB_729=table2array(RGB_729(:,2:4));
% 检查矩阵的尺寸是否正确
if size(RGB729, 1) ~= 729 || size(RGB729, 2) ~= 3 || size(RGB_729, 1) ~= 729 || size(RGB_729, 2) ~= 3
    error('矩阵必须是 729x3 大小');
end
% Step 2: 找到 RGB729 中每行在 matrix2 中对应的行号
[~, indices] = ismember(RGB729, RGB_729, 'rows');
% 检查是否找到所有对应关系
if any(indices == 0)
    error('有些 RGB 值在 RGB_729 中没有找到对应的行');
end
for i=1:length(RGB_729)
    RGB_729_1(i,:)=RGB_729(indices(i),:);
    XYZ9(i,:)=XYZ10(indices(i),:);
end





cubeLoriginal=9;
% cubeL=9;
cubeL=40; 
disp(strcat("cubeL=",num2str(cubeL)));
[r,g,b]=meshgrid(linspace(0,255,cubeL));
rgb=[r(:),g(:),b(:)];

[val ind]=max(XYZ9);
XYZw=XYZ9(ind(2),:);
method='cubic';
lablut=xyz2lab(XYZ9,'user',XYZw);

cubeL=cubeLoriginal;
[P_labs] = lut3d( r(:),g(:),b(:),lablut,method,cubeLoriginal);

save('F:\FirstYearMaster\oppoSkinExperi\LUT3d\results\datai_sorted40_3.mat', ...
    'lablut','cubeL','XYZw','method','indices','XYZ9') %save invserse data file
save ('F:\FirstYearMaster\oppoSkinExperi\LUT3d\results\data_sorted40_3.mat', ...
    'P_labs','rgb','cubeL','XYZw','method','indices','XYZ9')%save forward data file
