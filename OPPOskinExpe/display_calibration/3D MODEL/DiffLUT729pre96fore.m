clear;

%729pre96
%RGB->XYZ
load("RGB.mat");
datai_file=("results\datai_sorted40_3.mat");
RGB=RGB*255;
XYZ_pre = lut3d_rgb2xyz1(RGB,datai_file);
XYZ_table=readtable("results\" + ...
    "test-color-patch-1-96.csv");
XYZ_spd=table2array(XYZ_table(:,1:end));
SPDname = 380:1:780;
SPDname = SPDname';
XYZ_mea1 = spd2xyz([SPDname XYZ_spd'],10);
XYZ_table=readtable("results\" + ...
    "test-color-patch-2-96.csv");
XYZ_spd=table2array(XYZ_table(:,1:end));
SPDname = 380:1:780;
SPDname = SPDname';
XYZ_mea2 = spd2xyz([SPDname XYZ_spd'],10);
XYZ_table=readtable("results\" + ...
    "test-color-patch-3-96.csv");
XYZ_spd=table2array(XYZ_table(:,1:end));
SPDname = 380:1:780;
SPDname = SPDname';
XYZ_mea3 = spd2xyz([SPDname XYZ_spd'],10);
XYZ_table=readtable("results\" + ...
    "test-color-patch-5-96.csv");
XYZ_spd=table2array(XYZ_table(:,1:end));
SPDname = 380:1:780;
SPDname = SPDname';
XYZ_mea4 = spd2xyz([SPDname XYZ_spd'],10);
[val, ind]=max(XYZ_mea1);
XYZw=XYZ_mea1(ind(2),:);


[lab_pre] = xyz2lab(XYZ_pre,'user',XYZw);
[lab_mea1] = xyz2lab(XYZ_mea1,'user',XYZw);
[lab_mea2] = xyz2lab(XYZ_mea2,'user',XYZw);
[lab_mea3] = xyz2lab(XYZ_mea3,'user',XYZw);
[lab_mea4] = xyz2lab(XYZ_mea4,'user',XYZw);

% [de,~,~,~] = cielabde(lab_pre,lab_mea);
% [de00,de00c] = deltaE2000(lab_pre,lab_mea);
% de00=de00';de00c=de00c';
% de00grey=de00(55:72,:);
% de0024=de00(73:96,:);
% 
% mean_de=mean(de);
% mean_de00=mean(de00);
% mean_de00c=mean(de00c);
% mean_de00grey=mean(de00grey);
% mean_de0024=mean(de0024);
% save("Z:\homes\Peggy\oppoSkinExperi\LUT3d\results\LUTNGOG_sorted50_2",'de',"de00c","de00", ...
%     'mean_de','mean_de00','mean_de00c');

% 初始化结果矩阵
result_matrix = zeros(1,4);
cell_matrix = cell(1,4);
result_matrix24 = zeros(1,4);
cell_matrix24 = cell(1,4);

% 定义所有的 Lab 组
lab_groups = {lab_mea1, lab_mea2, lab_mea3, lab_mea4};

% 计算两两之间的平均色差值
for i = 1:4

    % 计算 i 组和 j 组之间的色差
    [de,~,~,~] = cielabde(lab_groups{i},lab_pre);
    [de00,de00c] = deltaE2000(lab_groups{i},lab_pre);
    % 计算平均色差
    de0024=de00(73:end);
    average_deltaE = mean(de00);
    average_deltaE24 = mean(de0024);
    % 存储在结果矩阵中
    result_matrix(1,i) = average_deltaE;
    result_matrix24(1,i) = average_deltaE24;

    result_matrix(2,i) = max(de00);
    result_matrix24(2,i) = max(de0024);

    result_matrix(3,i) = min(de00);
    result_matrix24(3,i) = min(de0024);

    result_matrix(4,i) = std(de00);
    result_matrix24(4,i) = std(de00);

    % 存储在元胞矩阵中
    cell_matrix{i, 1} = de00;
    cell_matrix24{i, 1} = de0024;
        

end


result_matrix24=result_matrix24';
