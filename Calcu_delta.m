close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量
delta_deleted_all=[];
delta_ori_all=[];

for i_level=10:10:80
    deleted=load(strcat("E:\documents\MATLAB\SkinColorPreferenceScale\level_data" + ...
    "\labNscore_level_deleted",num2str(i_level),".mat"));
    ori=load(strcat("E:\documents\MATLAB\SkinColorPreferenceScale\level_data" + ...
    "\labNscore_level",num2str(i_level),".mat"));
    uniqueValues = unique(deleted.lab_level(:,2));
    numUniqueValues = length(uniqueValues);
    delta_a=(max(deleted.lab_level(:,2))-min(deleted.lab_level(:,2)))./(numUniqueValues-1);
    delta_deleted=sqrt(2)*delta_a;

    uniqueValues = unique(ori.lab_level(:,2));
    numUniqueValues = length(uniqueValues);
    delta_a=(max(ori.lab_level(:,2))-min(ori.lab_level(:,2)))./(numUniqueValues-1);
    delta_ori=sqrt(2)*delta_a;

    delta_deleted_all=[delta_deleted_all;delta_deleted];
    delta_ori_all=[delta_ori_all;delta_ori];
end

save("E:\documents\MATLAB\SkinColorPreferenceScale\level_data" + ...
"\compare_delta.mat",'delta_deleted_all','delta_ori_all');

