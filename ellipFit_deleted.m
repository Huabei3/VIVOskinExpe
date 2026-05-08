close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量
for i_level=10:10:80
    load(strcat("Z:\homes\Peggy\FirstYearMaster\MATLAB\SkinColorPreferenceScale\level_data" + ...
    "\labNscore_level",num2str(i_level),".mat"));
    if max(lab_level(:,2))==12
        n_check=4;
    else 
        n_check=8;
    end
    rowsToKeep = mod(lab_level(:, 2), n_check) == 0;
    lab_level = lab_level(rowsToKeep, :);
    score_level = score_level(rowsToKeep, :);
    if max(lab_level(:,3))==12
        n_check=4;
    else 
        n_check=8;
    end
    rowsToKeep = mod(lab_level(:, 3), n_check) == 0;
    lab_level = lab_level(rowsToKeep, :);
    score_level = score_level(rowsToKeep, :);

    save(strcat("Z:\homes\Peggy\FirstYearMaster\MATLAB\SkinColorPreferenceScale\level_data" + ...
    "\labNscore_level_deleted",num2str(i_level),".mat"),"lab_level",'score_level');
end

% for i_level=1:1:8
%     A{i_level}=load(strcat("E:\documents\MATLAB\SkinColorPreferenceScale\level_data" + ...
%     "\labNscore_level_deleted",num2str(i_level),"0.mat"));
% end
%%
%拟合椭圆
par_all=[];r_all=[];y_all=zeros(49,8);exam_all=zeros(49,8);
for i_level=10:10:80
    load(strcat("Z:\homes\Peggy\FirstYearMaster\MATLAB\SkinColorPreferenceScale\level_data" + ...
        "\labNscore_level_deleted",num2str(i_level),".mat"));
    score_level=(score_level-(-3))./6;
    score_level=mean(score_level,2);
    [par,r,y] = my_ellipsoidfit3(lab_level,score_level);
    n_scorelevel=length(score_level);
    y_all(1:n_scorelevel,i_level./10)=y;
    exam_all(1:n_scorelevel,i_level./10)=score_level./y;
%     [par_Alan,r_Alan]=ellipfitAlan(lab_level,score_level);
    par_all=[par_all;par];
    r_all=[r_all;r];
%     save(strcat("E:\documents\MATLAB\SkinColorPreferenceScale\level_data" + ...
%     "\preNori",num2str(i_level),".mat"),'lab_level','score_level','y','exam');
%     par_Alan_all=[par_Alan_all;par_Alan];
%     r_Alan_all=[r_Alan_all;r_Alan];

end
% save("E:\documents\MATLAB\SkinColorPreferenceScale\level_data" + ...
% "\fitRes_level.mat",'par_all','r_all','y_all','par_Alan_all','r_Alan_all');
save("Z:\homes\Peggy\FirstYearMaster\MATLAB\SkinColorPreferenceScale\level_data" + ...
"\fitRes_level_deleted_2024_09_11_Test.mat",'par_all','r_all','exam_all',"y_all");
%%
%atan2d_360
function degree = atan2d_360(y, x)
    degree = atan2d(y, x);
    if degree < 0
        degree = degree + 360;
    end
end

