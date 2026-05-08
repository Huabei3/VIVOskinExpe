close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量
addpath("utils\")
%%
dir_res=dir("L_result_before\*.mat");
n_file=length(dir_res);

filename=load("newfile.mat");
filename=filename.filename;
n_lab=length(filename);
wd65_64 = [94.811, 100.00, 107.304];
XYZw_pre=[92.6458313910619,	100,	140.355436958488];%w_bg
% XYZw_pre=[74.2393729978199	75.6079281496091	121.296172643142];
%XYZw_PMCC_CATed,extracted by 12.26.2026

% XYZw_pre=[33.521517698541395,34.853121228819360,29.380539268455140];
% XYZw_pre1=[82.899171244283790,86.782992208213000,75.037090964697270];
XYZw_pre=XYZw_pre./XYZw_pre(2).*wd65_64(2);
CCT=xyz2CCT(XYZw_pre,10);

XYZw_PMCC=[0.824896999038825	0.845965324097912	0.747165892096635]*100;
xyz2CCT(XYZw_PMCC);
%见test里面find PMCC white against display white 
%%
%读取分数
score_all=zeros(n_lab,n_file);
num_lab_all=zeros(n_lab,n_file);

subject_all=[];
% Dtype="noCAT";
scale_type="scaled";
% scale_type="unscaled";
Dtype="efit_p";
save_folder=fullfile('AnalyseResults_p',Dtype,scale_type);
if ~exist(save_folder,"dir")
    mkdir(save_folder);
end



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
    % repeat_score_scaled=repeat_score;
    % repeat_score_scaled(:,2:3)=(repeat_score(:,2:3)-(-3))/6;
    STRESS_intra(i_file,1)=STRESS(repeat_score(:,2),repeat_score(:,3));
    % STRESS_intra1(i_file,1)=STRESS1(repeat_score_scaled(:,2),repeat_score_scaled(:,3));
    % STRESS_intra2(i_file,1)=STRESS2(repeat_score_scaled(:,2),repeat_score_scaled(:,3));

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
output_folder=fullfile(save_folder,"labNscore");
if ~exist(output_folder,"dir")
    mkdir(output_folder);
end
for i_level=10:10:80
    lab_level=lab(lab(:,1)==i_level,:);
    score_level=score_all(lab(:,1)==i_level,:);

    save(fullfile(output_folder,strcat("labNscore_level_p",num2str(i_level),".mat")), ...
        'lab_level','score_level');
end
%%
%计算STRESS_inter
score_all_scaled=(score_all-(-3))/6;
score_all_mean=mean(score_all,2);
score_all_scaled_mean=mean(score_all_scaled,2);
for i_file=1:n_file
    STRESS_inter(i_file,1)=STRESS(score_all_scaled(:,i_file),score_all_scaled_mean);
    STRESS_inter1(i_file,1)=STRESS(score_all(:,i_file),score_all_mean);
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
output_folder=fullfile(save_folder,"STRESS");
if ~exist(output_folder,"dir")
    mkdir(output_folder);
end
save(fullfile(output_folder,"STRESS_p.mat"), ...
    'STRESS_inter1','STRESS_inter','STRESS_intra');
%%
output_folder=fullfile(save_folder,"fitRes");
if ~exist(output_folder,"dir")
    mkdir(output_folder);
end
pre_draw_folder = fullfile(output_folder, 'pre_draw');
if ~exist(pre_draw_folder, 'dir')
    mkdir(pre_draw_folder);
end
goodness_draw_folder = fullfile(output_folder, 'goodness_draw');
if ~exist(goodness_draw_folder, 'dir')
    mkdir(goodness_draw_folder);
end
% %拟合椭圆
par_all=[];r_all=[];parNr_all=[];
load("whiteSquare\bg_gray.mat");
% CCT1=xyz2CCT(XYZw_pre1,10);
% CCT2=xyz2CCT(XYZw_PMCC,10);
D = calculateD(CCT, 0, Dtype);
for i_level=10:10:80
    clear("p","lab_level");
    load(fullfile(save_folder,"labNscore",strcat("labNscore_level_p",num2str(i_level),".mat")));
    %计算p
    score_level_mapped = mapMatrixValues(score_level);
    score_level_norm=(score_level_mapped-1)./5;
    for i_row=1:size(score_level_norm,1)
        p(i_row,1) = sum(score_level_norm(i_row,:)>0.5)./size(score_level_norm,2);
    end

    %% CAT
    
 
    % average_bf=average(i_level,:);
    % XYZ_ave_bf = lab2xyz2(average_bf, 'd65_64');
    % XYZ_ave_aft = CAT16_D(XYZ_ave_bf,  XYZw_pre,wd65_64, D(i_level,1));
    % average_curr = xyz2lab(XYZ_ave_aft, 'd65_64');
    % average_CATed(i_level,:)=average_curr;

    for i_points=1:size(lab_level,1)
        XYZ_bf(i_points, :) = lab2xyz2(lab_level(i_points, :), 'd65_64');  
        %对的就该D65白进行XYZ转Lab，因为我去看了Ricky的rendering code，就是用的D65         
        %CAT
        if ~strcmp(Dtype,'noCAT')
            XYZ_aft(i_points, :) = CAT16_D(XYZ_bf(i_points, :), XYZw_pre,wd65_64, D);
            lab_level(i_points, :) = xyz2lab(XYZ_aft(i_points, :), 'd65_64');
        end
        %亮度转换
        if strcmp(scale_type,"scaled")
            xyz_fit(i_points,:)=lab2xyz2(lab_level(i_points,:),"user", ...
                wd65_64);
            lab_level(i_points,:)=xyz2lab(xyz_fit(i_points,:),"user", ...
                wd65_64.*XYZ_bg_peak(i_level./10,2));    
        end
    end


    %%
    [par_mean, r_mean] = calculate_weighted_or_simple_mean(p, lab_level);
    mean_cen(1)=mean(lab_level(:,1));
    mean_cen(2:3)=par_mean(1,4:5);
    mean(lab_level),mean(p)
    [par, r, y] = my_ellipsoidfit3_dy(lab_level,p,mean_cen);
    % [par,r,y] = my_ellipsoidfit3(lab_level,p);
    % [par,r,y] = ellipsoidfit_glm(lab_level,p);
    p_all{i_level/10,1}=p;
    y_all{i_level/10,1}=y;
    par_all=[par_all;par];
    r_all=[r_all;r];
    parNr_all=[parNr_all;[par,r]];

    figure('Visible','off');
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
    exportgraphics(gcf,fullfile(goodness_draw_folder,strcat("L=",num2str(i_level),".jpg")),"Resolution",150);
    close(gcf)


    figure(1);
    plot_contour_with_scatter(par, lab_level, p);
    title(strcat("L=",num2str(i_level/10)));

    exportgraphics(gcf, fullfile(pre_draw_folder, strcat("L=",num2str(i_level),".jpg")));
    close(gcf);

end
concatenate_images1(pre_draw_folder,4);
save(fullfile(output_folder,"fitRes_level_p.mat"),'par_all','r_all', ...
    'parNr_all',"y_all","p_all");





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
