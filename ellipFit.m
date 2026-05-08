close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量
dir_res=dir("Z:\homes\Peggy\FirstYearMaster\MATLAB\SkinColorPreferenceScale\L_result_before\*.mat");
n_file=length(dir_res);

load("Z:\homes\Peggy\FirstYearMaster\MATLAB\SkinColorPreferenceScale\newfile.mat");
n_lab=length(filename);
%%
%读取分数
score_all=zeros(n_lab,n_file);
num_lab_all=zeros(n_lab,n_file);
for i_file=1:n_file
    resfile=strcat(dir_res(i_file).folder,'\',dir_res(i_file).name);
    load(resfile);

    temp=zeros(3);
    n_pic=length(result);
    for i_pic=n_pic-1:-1:1
        for j_pic=1:i_pic
            if result(j_pic,1)>result(j_pic+1,1)
                temp=result(j_pic,:);
                result(j_pic,:)=result(j_pic+1,:);
                result(j_pic+1,:)=temp;
            end
        end
    end
    
    for i_lab=1:max(result(:,1))
        num_scores=find(result(:,1)==i_lab);
        score_lab(i_lab)=mean(result(num_scores,2));
        num_lab(i_lab)=length(num_scores);
    end
%     save(strcat("E:\documents\MATLAB\SkinColorPreferenceScale\level_data" + ...
%     "\lab_level",num2str(i_lab),".mat"),lab_level);
    score_all(:,i_file)=score_lab;
    num_lab_all(:,i_file)=num_lab;
end


%%

%读取lab
lab=zeros(n_lab,3);
for i_lab=1:n_lab
    lab_str=filename{i_lab}(16:end-5);
    parts = strsplit(lab_str, ','); % 使用逗号作为分隔符进行分割
    lab(i_lab,1) = str2double(parts{1});
    lab(i_lab,2) = str2double(parts{2});
    lab(i_lab,3) = str2double(parts{3});
end
%分亮度保存
for i_level=10:10:80
    lab_level=lab(lab(:,1)==i_level,:);
    score_level=score_all(lab(:,1)==i_level,:);

%     n_lablevel=length(lab_level);
%     Ch_level=zeros(n_lablevel,2);
%     labCh_level=zeros(n_lablevel,5);
%     Ch_level(:,1)=sqrt(lab_level(:,2).^2+lab_level(:,3).^2);
%     Ch_level(:,2)=atan2d_360(lab_level(:,3),lab_level(:,2));
%     labCh_level(:,1:3)=lab_level;
%     labCh_level(:,4:5)=Ch_level;
    save(strcat("Z:\homes\Peggy\FirstYearMaster\MATLAB\SkinColorPreferenceScale\level_data" + ...
        "\labNscore_level",num2str(i_level),".mat"),'lab_level','score_level');
end
%%
%拟合每个被试的椭圆
%拟合椭圆

% for i_obs=1:length(dir_res)
%     par_ind=[];r_ind=[];
%     for i_level=10:10:80
%     load(strcat("Z:\homes\Peggy\FirstYearMaster\MATLAB\SkinColorPreferenceScale\level_data" + ...
%         "\labNscore_level",num2str(i_level),".mat"));
% 
%     score_level_ind=score_level(:,i_obs);
%     score_level_ind=(score_level_ind-(-3))./6;
% 
%     [par,r,y] = my_ellipsoidfit3(lab_level,score_level_ind);
% 
%     par_ind=[par_ind;par];
%     r_ind=[r_ind;r];
% 
%     end
%     par_ind_all{i_level}=[par_ind;par];
%     r_ind_all{i_level}=[r_ind;r];
% 
%     save(strcat("ind_ellip\ind_ellip_para_",num2str(i_obs),".mat"), ...
%         'par_ind_all','r_ind_all','score_level_ind');
% 
% end
% 
% save(strcat("ind_ellip\ind_ellip_all\ind_ellip_para.mat"),'par_ind_all','r_ind_all');
%%
%拟合椭圆
par_all=[];r_all=[];y_all=zeros(49,8);exam_all=zeros(49,8);
for i_level=10:10:80
    load(strcat("Z:\homes\Peggy\FirstYearMaster\MATLAB\SkinColorPreferenceScale\level_data" + ...
        "\labNscore_level",num2str(i_level),".mat"));
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
save("level_data\fitRes_level.mat",'par_all','r_all','exam_all',"y_all");
%%
%atan2d_360
function degree = atan2d_360(y, x)
    degree = atan2d(y, x);
    if degree < 0
        degree = degree + 360;
    end
end

