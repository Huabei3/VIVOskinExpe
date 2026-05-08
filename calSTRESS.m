close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量
dir_res=dir("Z:\homes\Peggy\FirstYearMaster\MATLAB\SkinColorPreferenceScale\L_result_before\*.mat");
n_file=length(dir_res);

filename=load("Z:\homes\Peggy\FirstYearMaster\MATLAB\SkinColorPreferenceScale\newfile.mat");
filename=filename.filename;
n_lab=length(filename);
%%
%读取分数
score_all=zeros(n_lab,n_file);
num_lab_all=zeros(n_lab,n_file);

subject_all=[];

for i_file=1:n_file
    resfile=strcat(dir_res(i_file).folder,'\',dir_res(i_file).name);
    load(resfile);
    %归一化
    result_score=result(:,2);
    result_score=(result_score-min(result_score))/(max(result_score)-min(result_score));
    result(:,2)=result_score;

    temp=zeros(3);
    n_pic=length(result);
    for i_pic=n_pic-1:-1:1
        for j_pic=1:i_pic     %排序
            if result(j_pic,1)>result(j_pic+1,1)
                temp=result(j_pic,:);
                result(j_pic,:)=result(j_pic+1,:);
                result(j_pic+1,:)=temp;
            end
        end
    end
    repeat_score=[];
    for i_lab=1:max(result(:,1))  %max(result(:,1))=图片数量
        num_scores=find(result(:,1)==i_lab);
        score_lab(i_lab)=mean(result(num_scores,2));
        num_lab(i_lab)=length(num_scores);
        if num_lab(i_lab)>1
            repeat_score_temp=[i_lab,result(num_scores(1),2),result(num_scores(2),2)];
            repeat_score=[repeat_score;repeat_score_temp];
        end
    end
    
    STRESS_intra(i_file,1)=STRESS(repeat_score(:,2),repeat_score(:,3));
    STRESS_intra1(i_file,1)=STRESS1(repeat_score(:,2),repeat_score(:,3));
    STRESS_intra2(i_file,1)=STRESS2(repeat_score(:,2),repeat_score(:,3));

    score_all(:,i_file)=score_lab;
    num_lab_all(:,i_file)=num_lab;
    subject_all=[subject_all;{dir_res(i_file).name}];
end

%%
%计算STRESS_inter
score_all_mean=mean(score_all,2);
for i_file=1:n_file
    STRESS_inter(i_file,1)=STRESS(score_all(:,i_file),score_all_mean);
    STRESS_inter1(i_file,1)=STRESS1(score_all(:,i_file),score_all_mean);
end
STRESS_mean=[mean(STRESS_intra),mean(STRESS_inter)];

for i_file=1:n_file
STRESS_cell{i_file,1}=dir_res(i_file).name;
STRESS_cell{i_file,2}=STRESS_intra(i_file);
STRESS_cell{i_file,3}=STRESS_inter(i_file);
% STRESS_mean_all=mean(STRESS_deleted(:,2:3),1);
end
% STRESS_sorted=sortrows(STRESS_cell,2,'ascend');
% STRESS_deleted=STRESS_sorted{1:10,:};

save("STRESS\STRESS.mat",'STRESS_inter1','STRESS_inter','STRESS_intra1','STRESS_intra');
%%
% %读取lab
% lab=zeros(n_lab,3);
% for i_lab=1:n_lab
%     lab_str=filename{i_lab}(16:end-5);
%     parts = strsplit(lab_str, ','); % 使用逗号作为分隔符进行分割
%     lab(i_lab,1) = str2double(parts{1});
%     lab(i_lab,2) = str2double(parts{2});
%     lab(i_lab,3) = str2double(parts{3});
% end
% %分亮度保存
% for i_level=10:10:80
%     lab_level=lab(lab(:,1)==i_level,:);
%     score_level=score_all(lab(:,1)==i_level,:);
% 
% %     n_lablevel=length(lab_level);
% %     Ch_level=zeros(n_lablevel,2);
% %     labCh_level=zeros(n_lablevel,5);
% %     Ch_level(:,1)=sqrt(lab_level(:,2).^2+lab_level(:,3).^2);
% %     Ch_level(:,2)=atan2d_360(lab_level(:,3),lab_level(:,2));
% %     labCh_level(:,1:3)=lab_level;
% %     labCh_level(:,4:5)=Ch_level;
%     save(strcat("E:\documents\MATLAB\SkinColorPreferenceScale\level_data" + ...
%         "\labNscore_level",num2str(i_level),".mat"),'lab_level','score_level');
% end