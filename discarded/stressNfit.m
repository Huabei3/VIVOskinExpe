% rehash toolboxcache %解决无法访问以前可以访问的文件，重新处理工具箱缓存
close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量
%% 生成目录


source_folder = 'D:\work\VIVOskinExpe\analyze\expRes\femalevivoi'; 
slashes = strfind(source_folder, '\');
lastPart=source_folder(slashes(1,end)+1:end);
model = lastPart(1:end-1);

% 输入要提取的文件编号
attribute = 4;
attribute_names=["Preference","Attractiveness","Feminine","Cooperative",...
    "Youth","Healthy","suit the environment or not","white-skinned","ruddy"];
% 获取所有格式为 obs%02d 的子文件夹
subFolders = dir(fullfile(source_folder, 'obs*'));
subFolders = subFolders([subFolders.isdir]); % 只保留文件夹
% 初始化一个空的 dir 结构体数组
dir_res = [];
% 支持的文件格式
supportedFormats = {'.csv', '.xls', '.xlsx'};

% 遍历每个子文件夹
for i_obs = 1:length(subFolders)
    % 获取当前子文件夹路径
    folderPath = fullfile(source_folder, subFolders(i_obs).name);
    
    % 遍历支持的文件格式
    for fmt = supportedFormats
        % 构建目标文件名
        targetFileName = sprintf('%s_%02d%s', subFolders(i_obs).name, attribute, fmt{1});
        targetFilePath = fullfile(folderPath, targetFileName);
        
        % 检查文件是否存在
        if exist(targetFilePath, 'file')
            % 获取文件的 dir 信息
            fileInfo = dir(targetFilePath);
            
            % 将 dir 信息添加到结构体数组中
            dir_res = [dir_res; fileInfo];
            break; % 如果找到文件，跳出格式循环
        end
    end
end

%%
% 定义目录路径
attribute_serial=strcat(sprintf("%02d",attribute),attribute_names(attribute));
output_folder=fullfile('AlalyseResults',lastPart,attribute_serial);
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end


resfile = fullfile(dir_res(1).folder, dir_res(1).name);
result = readtable(resfile);
result_cell = table2cell(result);
indices = result_cell(:, 1);
indices = cell2mat(indices);
n_lab = max(indices) + 1;
n_file=length(dir_res);

score_all = zeros(n_lab, n_file);
num_lab_all = zeros(n_lab, n_file);
STRESS_intra = [];
repeat_score_all = [];

for i_file = 1:length(dir_res)
    resfile = fullfile(dir_res(i_file).folder, dir_res(i_file).name);
    result = readtable(resfile);
    
    % 将 table 转换为元胞数组
    result_cell = table2cell(result);
    
    % 归一化
    scores = cell2mat(result_cell(:, 3));
    scores = mapMatrixValues(scores);
    for k = 1:length(scores)
        result_cell{k, 3} = scores(k);
    end
    
    % 排序
    result_cell = sortrows(result_cell, 1);
    
    % 处理结果
    repeat_score = [];
    picname_lab = [];
    
    score_lab = zeros(max(cell2mat(result_cell(:, 1))) + 1, 1);
    num_lab = zeros(max(cell2mat(result_cell(:, 1))) + 1, 1);
    
    for i_lab = 0:max(cell2mat(result_cell(:, 1)))
        num_scores = find(cell2mat(result_cell(:, 1)) == i_lab);        
        score_lab(i_lab + 1) = mean(cell2mat(result_cell(num_scores, 3)));
        picname_lab = [picname_lab; result_cell(num_scores(1), 2)];
        num_lab(i_lab + 1) = length(num_scores);
        if num_lab(i_lab + 1) > 1
            repeat_score_temp = [i_lab, cell2mat(result_cell(num_scores(1), 3)), cell2mat(result_cell(num_scores(2), 3))];
            repeat_score = [repeat_score; repeat_score_temp];
        end
    end
    repeat_score(:,2:3)=(repeat_score(:,2:3)-1)/5;
    repeat_score_mean = (repeat_score(:, 2) + repeat_score(:, 3)) ./ 2;
    repeat_score_all = [repeat_score_all; {repeat_score}];
    STRESS_intra = [STRESS_intra; {dir_res(i_file).name, STRESS(repeat_score(:, 2), repeat_score_mean)}];
    
    score_all(:, i_file) = score_lab;
    num_lab_all(:, i_file) = num_lab;
end

STRESS_intra_mean = mean(cell2mat(STRESS_intra(:, 2)));
% save(fullfile(output_folder, 'AllScore.mat'), 'score_all');

% 计算STRESS_inter
STRESS_inter = [];
score_all_scaled=(score_all-1)/5;
score_all_mean = mean(score_all_scaled, 2);
for i_file = 1:n_file
    STRESS_inter = [STRESS_inter; {dir_res(i_file).name, STRESS(score_all_scaled(:, i_file), score_all_mean)}];
end

save(fullfile(output_folder, 'STRESS.mat'), 'STRESS_inter', 'STRESS_intra');

n_group = floor(length(result_cell) / 37);


%% 计算z_score
score_all=round(score_all);
for i_pic=1:size(score_all,1)
    for i_grade=1:6
        count(i_pic,i_grade)=sum(score_all(i_pic,:)==i_grade);        
    end
end    
for i_grade=1:6
cumu(:,i_grade)=sum(count(:,1:i_grade),2);
end
LG=log((cumu+0.5)./(size(score_all,2)-cumu+0.5));
z_score=LG*0.6422+0.0003;
for i_grade=1:5
    diff(:,i_grade)=z_score(:,i_grade+1)-z_score(:,i_grade);
end
mean_diff=mean(diff,1);
boundary(1,1)=0;
for i_grade=2:6
    boundary(1,i_grade)=boundary(1,i_grade-1)+mean_diff(1,i_grade-1);
end
scaledValue=repmat(boundary,size(z_score,1),1)-z_score;
meanScaledValue=mean(scaledValue(:,1:5),2);
MSV_scaled=(meanScaledValue-min(meanScaledValue))./(max(meanScaledValue)-min(meanScaledValue));

% z_score1=zscore(score_all,1);
% z_score1_mean=mean(z_score1,2);

%% 处理并保存每个group的z-score和lab

load(fullfile('dlabsNpicname',strcat(lastPart,".mat")));

picname_check = [];

for i_group = 1:33:length(score_all)
    picname_group = picname_lab{i_group}(1:end-3);
    picname_check{floor((i_group-1)/33)+1,1}=picname_lab{i_group}(1:end-3);
    lab_group=[];
    for i_pic=1:length(dlabsNpicname)
        if strcmp(dlabsNpicname{i_pic,2}(1:end-3),picname_group)
            lab_group = [lab_group; dlabsNpicname{i_pic, 1}];
        end

    end
    MSV_group = MSV_scaled(i_group:i_group + 32, :);
    %计算lab_group

    outputFolder=fullfile(output_folder, 'labNscore');
    if ~exist(outputFolder, 'dir')
        mkdir(outputFolder);
    end
    save(fullfile(outputFolder, strcat("labNscore_group", picname_group, ".mat")), ...
        'lab_group', 'MSV_group');
end
disp("finish STRESS calculating");

%% 拟合椭圆

dir_labNgroup=dir(fullfile(outputFolder,"*.mat"));


outputFolder=fullfile(output_folder, 'ellipPara');
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end
redo=[1,15];
if isempty(redo)
    redo=1:21;
end
fitRes_file=fullfile(outputFolder, "fitRes_level.mat");
if exist(fitRes_file,"file")
    par_data=load(fitRes_file);

end
par_all=[];r_all=[];parNr_all=[];
for i_group=1:length(dir_labNgroup)
    picname_check{i_group,2}=dir_labNgroup(i_group).name(1:end-4);
    if ismember(i_group,redo)
        MSVNlab=load(fullfile(dir_labNgroup(i_group).folder,dir_labNgroup(i_group).name));
        lab_group=MSVNlab.lab_group;
        MSV_group=MSVNlab.MSV_group;
        [lab_group,MSV_group] = delete_bad(lab_group,MSV_group,lastPart, ...
            i_group,attribute);
        plot_scatter(lab_group, MSV_group);
        [par,r,y] = my_ellipsoidfit3(lab_group,MSV_group);
        [max_val{i_group,1},max_ind{i_group,1}] = sortrows(abs(y-MSV_group),'descend');
        plot_contour_with_scatter(par, lab_group, MSV_group);
    else
        par=par_data.par_all(i_group,:);
        r=par_data.parNr_all(i_group,end);
    end
    % y_all{i_group,1}=y;
    par_all=[par_all;par];
    parNr_all=[parNr_all;[par,r]];

    % figure(i_group);
    % scatter(p, y);
    % hold on;
    %     %45°
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
    % title(strcat('L=',num2str(i_group/10),' Fitting Result'));
    % saveas(i_group,strcat("fitRes\ydataNy\L=",num2str(i_group/10),".jpg"));


end


save(fullfile(outputFolder, "fitRes_level.mat"), ...
    'par_all', 'r_all', 'parNr_all',"picname_check");



%%
%atan2d_360
function degree = atan2d_360(y, x)
    degree = atan2d(y, x);
    if degree < 0
        degree = degree + 360;
    end
end

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



function [lab_group,MSV_group] = delete_bad(lab_group,MSV_group,lastPart,i_group,attribute)
    delete_ind=[];
    if strcmp(lastPart, "femalevivoi")
        if attribute == 1
            if i_group == 1
                delete_ind=24;
            elseif i_group == 15
                delete_ind=22;
            end
        elseif attribute == 2
            if i_group == 1
                delete_ind=29;
            elseif i_group == 15
                delete_ind=[17,9];
            end
        elseif attribute == 3
            if i_group == 15
                delete_ind=24;
            end
        elseif attribute == 4
            if i_group == 1
                delete_ind=16;
            elseif i_group == 15
                delete_ind=29;
            end
        end
    end
    lab_group(delete_ind, :) = [];
    MSV_group(delete_ind, :) = [];
end




function plot_scatter(lab_group, MSV_group)
    % 创建一个新的图形窗口
    figure();
    
    % 绘制散点图
    scatter(lab_group(:, 2), lab_group(:, 3), 40, MSV_group, 'filled');
    
    % 计算坐标轴范围
    lim_max = max(max(lab_group(:, 2)), max(lab_group(:, 3))) + 10;
    lim_min = min(min(lab_group(:, 2)), min(lab_group(:, 3))) - 10;
    
    % 添加 x=0 和 y=0 的轴
    line([0, 0], [lim_min, lim_max], 'Color', 'k', 'LineStyle', '--'); % x=0
    line([lim_min, lim_max], [0, 0], 'Color', 'k', 'LineStyle', '--'); % y=0
    
    % 添加 45 度线
    refline(1, 0); % 斜率为 1，截距为 0 的直线
    
    % 保持图形窗口
    hold on;
    
    % 设置坐标轴比例相等
    axis equal;
    
    % 设置坐标轴范围
    xlim([lim_min, lim_max]);
    ylim([lim_min, lim_max]);
    

end




function plot_contour_with_scatter(par, lab_group, MSV_group)
    % 绘制等高线
    check_data2 = par(4) + (-30:0.2:30);
    check_data3 = par(5) + (-30:0.2:30);
    [data2, data3] = meshgrid(check_data2, check_data3);

    a = par;
    y = (1./(1 + a(6) * exp(sqrt(a(1) * (data2 - a(4)).^2 + a(2) * (data3 - a(5)).^2 + ...
        a(3) * (data2 - a(4)) .* (data3 - a(5)))))) .* ((a(1) * (data2 - a(4)).^2 + ...
        a(2) * (data3 - a(5)).^2 + a(3) * (data2 - a(4)) .* (data3 - a(5))) >= 0);

    % 绘制等高线
    contour(data2, data3, y, [0.5, 1], 'Linewidth', 2);
    hold on;

    % 绘制散点图
    scatter(lab_group(:, 2), lab_group(:, 3), 40, MSV_group, 'filled');
    hold on;

    % 绘制拟合中心点
    scatter(par(4), par(5), 30, 'filled');
    hold on;

    % 添加坐标轴和参考线
    lim_max = max(max(lab_group(:, 2)), max(lab_group(:, 3))) + 10;
    lim_min = min(min(lab_group(:, 2)), min(lab_group(:, 3))) - 10;
    line([0, 0], [lim_min, lim_max], 'Color', 'k', 'LineStyle', '--'); % x=0
    line([lim_min, lim_max], [0, 0], 'Color', 'k', 'LineStyle', '--'); % y=0
    refline(1, 0); % 45 度线

    % 设置图形属性
    axis equal;
    xlim([lim_min, lim_max]);
    ylim([lim_min, lim_max]);
    xlabel('{\ita*}');
    ylabel('{\itb*}');
    title('Contour Plot with Scatter');
    hold off;
end