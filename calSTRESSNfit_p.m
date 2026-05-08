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
    %归一化
    % result_score=result(:,2);
    % result_score=(result_score-mean(result_score,2))/std(result_score,0,2);%z-score标准化
    % 
    % result(:,2)=result_score;

    n_pic=length(result);
    result=sortrows(result,1,'ascend');

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
    repeat_score_scaled(:,2:3)=(repeat_score(:,2:3)-(-3))/6;
    STRESS_intra(i_file,1)=STRESS(repeat_score_scaled(:,2),repeat_score_scaled(:,3));
    STRESS_intra1(i_file,1)=STRESS1(repeat_score_scaled(:,2),repeat_score_scaled(:,3));
    STRESS_intra2(i_file,1)=STRESS2(repeat_score_scaled(:,2),repeat_score_scaled(:,3));

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

    save(strcat("level_data\labNscore_level_p",num2str(i_level),".mat"),'lab_level','score_level');
end
%%
%计算STRESS_inter
score_all_scaled=(score_all-(-3))/6;
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

save("STRESS\STRESS_p.mat",'STRESS_inter1','STRESS_inter','STRESS_intra1','STRESS_intra');
%%

% %拟合椭圆
par_all=[];r_all=[];parNr_all=[];
for i_level=10:10:80

    load(strcat("level_data\labNscore_level_p",num2str(i_level),".mat"));
    %计算p
    score_level1=round(score_level);
    cata=[-3,-2,-1,1,2,3];
    sum_matrix=[];cumu_matrix=[];
    for i_renPic=1:size(score_level1,1)
        for i_cata=1:length(cata)
            sum_matrix(i_renPic,i_cata)=sum(score_level1(i_renPic,:)==cata(i_cata));
            cumu_matrix(i_renPic,i_cata)=sum(sum_matrix(i_renPic,1:i_cata));
        end
    end
    p_matrix=cumu_matrix./n_file;
    p=ones(size(p_matrix,1),1)-p_matrix(:,3);
    % p=sum(score_level>0,2)./size(score_level,2);
    % p1=sum(sum_matrix(:,4:6),2)./n_file;
    [par,r,y] = my_ellipsoidfit3(lab_level,p);
    % [par,r,y] = ellipsoidfit_glm(lab_level,p);
    p_all{i_level/10,1}=p;
    y_all{i_level/10,1}=y;
    par_all=[par_all;par];
    r_all=[r_all;r];
    parNr_all=[parNr_all;[par,r]];

    figure(i_level/10);
    scatter(p, y);
    hold on;
        %45°
    axis equal;
    lim_max=max(max(p),max(y))+0.2;
    lim_min=min(min(p),min(y))-0.2;
    xlim([lim_min,lim_max]);
    ylim([lim_min,lim_max]);

    x = linspace(lim_min, lim_max, 1000);
    y= x;
    text( lim_max-0.3,lim_max-0.3,'45°', ...
                'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'FontSize', 10);
    plot(x,y);


    xlabel('True Probability');
    ylabel('Predicted Probability');
    title(strcat('L=',num2str(i_level/10),' Fitting Result'));
    saveas(i_level/10,strcat("fitRes\ydataNy\L=",num2str(i_level/10),".jpg"));


end

save("fitRes\fitRes_level_p.mat",'par_all','r_all', ...
    'parNr_all',"y_all","p_all");

%%
%拟合每个被试的椭圆
%拟合椭圆
% 
% for i_obs=1:length(dir_res)
%     par_ind=[];r_ind=[];
%     for i_level=10:10:80
%         load(strcat("level_data\labNscore_level_p",num2str(i_level),".mat"));
% 
%         score_level_ind=score_level(:,i_obs);
%         score_level_ind=(score_level_ind-(-3))./6;
%         [lab_level,score_level_ind] = delete_abnormal(lab_level,score_level_ind);
%         %看看删除干净不
%         figure(i_obs*8+i_level/10);
%         colormap("parula"); % 显示颜色条
%         scatter(lab_level(:,2),lab_level(:,3), 40, score_level_ind, 'filled'); 
% 
%         colorbar;
% 
%         [par,r,y] = my_ellipsoidfit3(lab_level,score_level_ind);
% 
%         par_ind=[par_ind;par];
%         r_ind=[r_ind;r];
%         lab_level_ind{i_obs,i_level/10}=lab_level;
%         score_level_ind_all{i_obs,i_level/10}=score_level_ind;
% 
%     end
%     par_ind_all{i_obs,1}=[par_ind;par];
%     r_ind_all{i_obs,1}=[r_ind;r];
% 
%     save(fullfile("ind_ellip",sprintf("ind_ellip_para_%02d.mat",i_obs)), ...
%         'par_ind','r_ind','score_level_ind_all','lab_level_ind');
% 
% end
% save_folder="ind_ellip\ind_ellip_all";
% if ~exist(save_folder,"dir")
%     mkdir(save_folder);
% end
% save(strcat("ind_ellip\ind_ellip_all\ind_ellip_para.mat"),'par_ind_all','r_ind_all');
% 

%%
% %单独保存lab_level_ind和score_level_ind_all
% for i_obs=1:length(dir_res)
%     par_ind=[];r_ind=[];
%     for i_level=10:10:80
%         load(strcat("level_data\labNscore_level_p",num2str(i_level),".mat"));
% 
%         score_level_ind=score_level(:,i_obs);
%         score_level_ind=(score_level_ind-(-3))./6;
%         [lab_level,score_level_ind] = delete_abnormal(lab_level,score_level_ind);
%         %看看删除干净不
%         % figure(i_obs*8+i_level/10);
%         % colormap("parula"); % 显示颜色条
%         % scatter(lab_level(:,2),lab_level(:,3), 40, score_level_ind, 'filled'); 
% 
%         colorbar;
% 
%         lab_level_ind{i_obs,i_level/10}=lab_level;
%         score_level_ind_all{i_obs,i_level/10}=score_level_ind;
% 
%     end
%     par_ind_all{i_obs,1}=[par_ind;par];
%     r_ind_all{i_obs,1}=[r_ind;r];
%     load(fullfile("ind_ellip",sprintf("ind_ellip_para_%02d.mat",i_obs)),'par_ind','r_ind');
% 
%     save(fullfile("ind_ellip",sprintf("ind_ellip_para_%02d.mat",i_obs)), ...
%         'par_ind','r_ind','score_level_ind_all','lab_level_ind');
% 
% end




%%
function [lab_level,score_level_ind] = delete_abnormal(lab_level,score_level_ind)
    % 初始化一个逻辑索引数组，用于标记需要删除的点
    % figure();
    % colormap("parula"); % 显示颜色条
    % scatter(lab_level(:,2),lab_level(:,3), 40, score_level_ind, 'filled'); 
    % 
    % colorbar;
    indices_to_delete = false(size(lab_level, 1), 1);
    col_values=unique(lab_level(:,2));
    col_values=sortrows(col_values);
    step=col_values(2)-col_values(1);
    % 遍历每个点
    for i = 2:(size(lab_level, 1) - 1)  % 跳过第一行和最后一行，因为它们没有上下或左右邻居
        a_i=lab_level(i,2);
        b_i=lab_level(i,3);
        % 找到左右上下的索引
        left_idx = find(lab_level(:, 2) == a_i - step & lab_level(:, 3) == b_i);
        right_idx = find(lab_level(:, 2) == a_i + step & lab_level(:, 3) == b_i);
        up_idx = find(lab_level(:, 2) == a_i & lab_level(:, 3) == b_i - step);
        down_idx = find(lab_level(:, 2) == a_i & lab_level(:, 3) == b_i + step);
        
        % 检查是否存在左右或上下邻居，并且当前点的得分是否小于邻居的得分
        smaller_than_neighbors = (~isempty(left_idx) && ~isempty(right_idx) && ...
            score_level_ind(i) < min(score_level_ind(left_idx), score_level_ind(right_idx))) || ...
           (~isempty(up_idx) && ~isempty(down_idx) && ...
            score_level_ind(i) < min(score_level_ind(up_idx), score_level_ind(down_idx)));
        
        % 检查是否存在左右或上下邻居，并且当前点的得分是否大于邻居的得分
        larger_than_neighbors = (~isempty(left_idx) && ~isempty(right_idx) && ...
            score_level_ind(i) > max(score_level_ind(left_idx), score_level_ind(right_idx))) && ...
           (~isempty(up_idx) && ~isempty(down_idx) && ...
            score_level_ind(i) > max(score_level_ind(up_idx), score_level_ind(down_idx)));
        
        % 标记需要删除的点
        if smaller_than_neighbors || larger_than_neighbors
            indices_to_delete(i) = true;
        end

    end
                % 删除标记为true的点
    lab_level(indices_to_delete, :) = [];
    score_level_ind(indices_to_delete) = [];

    % figure();
    % colormap("parula"); % 显示颜色条
    % scatter(lab_level(:,2),lab_level(:,3), 40, score_level_ind, 'filled'); 

end
%%
%atan2d_360
function degree = atan2d_360(y, x)
    degree = atan2d(y, x);
    if degree < 0
        degree = degree + 360;
    end
end
