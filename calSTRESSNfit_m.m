close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量
dir_res=dir("L_result_before\*.mat");
n_file=length(dir_res);

filename=load("newfile.mat");
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

    n_pic=length(result);
    result=sortrows(result,1,'ascend');

    result(:,2)=mapMatrixValues(result(:,2));

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
    
    repeat_score_scaled=repeat_score;
    repeat_score_scaled(:,2:3)=(repeat_score(:,2:3)-1)/5;
    repeat_score_mean=(repeat_score_scaled(:,2)+repeat_score_scaled(:,3)./2);
    STRESS_intra(i_file,1)=STRESS(repeat_score_scaled(:,2),repeat_score_mean);
    STRESS_intra1(i_file,1)=STRESS1(repeat_score_scaled(:,2),repeat_score_mean);
    STRESS_intra2(i_file,1)=STRESS2(repeat_score_scaled(:,2),repeat_score_mean);

    score_all(:,i_file)=score_lab;
    num_lab_all(:,i_file)=num_lab;
    subject_all=[subject_all;{dir_res(i_file).name}];
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

    save(strcat("level_data_m\labNscore_level",num2str(i_level),".mat"),'lab_level','score_level');
end
%%
%计算STRESS_inter
score_all_scaled=(score_all-1)/5;
score_all_scaled_mean=mean(score_all_scaled,2);
for i_file=1:n_file
    STRESS_inter(i_file,1)=STRESS(score_all_scaled(:,i_file),score_all_scaled_mean);
    STRESS_inter1(i_file,1)=STRESS1(score_all_scaled(:,i_file),score_all_scaled_mean);
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

save("STRESS\STRESS_m.mat",'STRESS_inter1','STRESS_inter','STRESS_intra1','STRESS_intra');

%%
%MCDM
for i_level=10:10:80
    load(strcat("level_data_m\labNscore_level",num2str(i_level),".mat"));
    score_mean=mean(score_level,2);
    indices_glo=score_mean>=4;
    preCen=mean(lab_level(indices_glo,:));

    for i_obs=1:size(score_level,2)
        indices=score_level(:,i_obs)>=4;
        preCen_ind(i_obs,:)=mean(lab_level(indices,:));
        MCDM_inter(i_obs,:)=cielabde(preCen_ind(i_obs,:),preCen);

        MCDM_inter_all(i_obs,i_level/10)=MCDM_inter(i_obs,:);
        MCDM_inter_all_00(i_obs,i_level/10)=deltaE2000(preCen_ind(i_obs,:),preCen);

    end
    load(strcat("level_data_m\labNscore_level",num2str(i_level),".mat"));
    save(strcat("level_data_m\labNscore_level_MCDM",num2str(i_level),".mat"), ...
        "preCen_ind","lab_level","score_level","MCDM_inter","preCen");
end

save(strcat("level_data_m\MCDM_all\labNscore_level_MCDM_all.mat"), ...
        "MCDM_inter_all","MCDM_inter_all_00");


%%
% %拟合椭圆
%直接平均

par_all=[];r_all=[];parNr_all=[];
for i_level=10:10:80

    load(strcat("level_data_m\labNscore_level",num2str(i_level),".mat"));
    %计算zscore
    score=(score_level-1)./5;
    score_m=mean(score,2);
    
    [par,r,y] = my_ellipsoidfit3(lab_level,score_m);
    m_all{i_level/10,1}=score_m;
    y_all{i_level/10,1}=y;
    par_all=[par_all;par];
    r_all=[r_all;r];
    parNr_all=[parNr_all;[par,r]];

    % figure(i_level/10);
    % scatter(score_m, y);
    % hold on;
        %45°
    % axis equal;
    % lim_max=max(max(p),max(y))+0.2;
    % lim_min=min(min(p),min(y))-0.2;
    % xlim([lim_min,lim_max]);
    % ylim([lim_min,lim_max]);
    % 
    % x = linspace(lim_min, lim_max, 1000);
    % y= x;
    % text( lim_max-0.3,lim_max-0.3,'45°', ...
    %             'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'FontSize', 10);
    % plot(x,y);
    % 
    % 
    % xlabel('True Probability');
    % ylabel('Predicted Probability');
    % title(strcat('L=',num2str(i_level/10),' Fitting Result'));
    % saveas(i_level/10,strcat("fitRes\ydataNy\L=",num2str(i_level/10),".jpg"));


end

save("fitRes\fitRes_level_m.mat",'par_all','r_all', ...
    'parNr_all',"y_all","m_all");

%%
%atan2d_360
function degree = atan2d_360(y, x)
    degree = atan2d(y, x);
    if degree < 0
        degree = degree + 360;
    end
end


%%
% function mappedMatrix = mapMatrixValues(matrix)
%     % 创建映射关系
%     originalValues = [-3, -2, -1, 1, 2, 3];
%     mappedValues = [1, 2, 3, 4, 5, 6];
% 
%     % 创建查找表
%     lookupTable = containers.Map(originalValues, mappedValues);
% 
%     % 初始化输出矩阵
%     mappedMatrix = matrix;
% 
%     % 遍历矩阵并替换值
%     [rows, cols] = size(matrix);
%     for i = 1:rows
%         for j = 1:cols
%             value = matrix(i, j);
%             if lookupTable.isKey(value)
%                 mappedMatrix(i, j) = lookupTable(value);
%             end
%         end
%     end
% end


%%

function mappedMatrix = mapMatrixValues(matrix)
 

    mappedMatrix = matrix;
    
    % 遍历矩阵并替换值
    [rows, cols] = size(matrix);
    for i = 1:rows
        for j = 1:cols
            
            if matrix(i,j)==-3
                mappedMatrix(i, j) = 1;
            elseif matrix(i,j)==-2
                mappedMatrix(i, j) = 2;
            elseif matrix(i,j)==-1
                mappedMatrix(i, j) = 3;
            elseif matrix(i,j)==1
                mappedMatrix(i, j) = 4;
            elseif matrix(i,j)==2
                mappedMatrix(i, j) = 5;
            elseif matrix(i,j)==3
                mappedMatrix(i, j) = 6;
            else

            end
        end
    end
end