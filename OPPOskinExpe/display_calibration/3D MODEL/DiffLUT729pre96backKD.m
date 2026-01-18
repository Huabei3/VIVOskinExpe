clear;
%XYZ->RGB
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

LUTback_file="results\data_sorted40_3.mat";
LUTfore_file="results\datai_sorted40_3.mat";
% GOGModel=['Z:\homes\Peggy\oppoSkinExperi\LUT3d\results\' ...
%     'GOGpara-3-96.mat'];

RGB_r1= lut3d_xyz2rgbNoParitp(XYZ_mea1,LUTback_file);
XYZ_r1=lut3d_rgb2xyz1(RGB_r1,LUTfore_file);

RGB_r2= lut3d_xyz2rgbNoParitp(XYZ_mea2,LUTback_file);
XYZ_r2=lut3d_rgb2xyz1(RGB_r2,LUTfore_file);

RGB_r3= lut3d_xyz2rgbNoParitp(XYZ_mea3,LUTback_file);
XYZ_r3=lut3d_rgb2xyz1(RGB_r3,LUTfore_file);

RGB_r4= lut3d_xyz2rgbNoParitp(XYZ_mea4,LUTback_file);
XYZ_r4=lut3d_rgb2xyz1(RGB_r4,LUTfore_file);
disp("KD");

[lab_r1] = xyz2lab(XYZ_r1,'user',XYZw);
[lab_r2] = xyz2lab(XYZ_r2,'user',XYZw);
[lab_r3] = xyz2lab(XYZ_r3,'user',XYZw);
[lab_r4] = xyz2lab(XYZ_r4,'user',XYZw);
[lab_mea1] = xyz2lab(XYZ_mea1,'user',XYZw);
[lab_mea2] = xyz2lab(XYZ_mea2,'user',XYZw);
[lab_mea3] = xyz2lab(XYZ_mea3,'user',XYZw);
[lab_mea4] = xyz2lab(XYZ_mea4,'user',XYZw);



% 初始化结果矩阵
result_matrix = zeros(1,4);
cell_matrix = cell(1,4);
result_matrix24 = zeros(1,4);
cell_matrix24 = cell(1,4);

% 定义所有的 Lab 组
lab_mea_groups = {lab_mea1, lab_mea2, lab_mea3, lab_mea4};
lab_r_groups = {lab_r1, lab_r2, lab_r3, lab_r4};
% 计算两两之间的平均色差值
for i = 1:4
        % 计算 i 组和 j 组之间的色差
        [de,~,~,~] = cielabde(lab_mea_groups{i},lab_r_groups{i});
        [de00,de00c] = deltaE2000(lab_mea_groups{i},lab_r_groups{i});
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

