close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量

%%
load("documents\CATedPre.mat","picname");
load("neutral24\white.mat","CCT","XYZ_gray");
load("OPPOskin\matchTable.mat");
lastParts=["inLab","indoorAdd","nightAdd","outdoorAdd","sunsetAdd","recen"];
load('documents\group_Lab.mat','cellMatrix');
wd65=[94.811 100.00 107.304];   
XYZw_pre_all=XYZ_gray./XYZ_gray(:,2).*100;
% Dtype="OPPO_CAT16";
Dtype="efit_p";
lightness_type="rela";
rgb2xyz_type="display";
cell_CATed={};
save_folder=fullfile("AnalyseResults_p",rgb2xyz_type,lightness_type,Dtype,"sum_list");
if ~exist(save_folder,"dir")
    mkdir(save_folder);
end
summary_filename=fullfile(save_folder,"MCDM.XLSX");
concatenated_table={};
MCDM_mean_scenes=[];
for i_lastPart=1:5
% for i_lastPart=1:length(lastParts)
    clear("picname_check","score_all","score_all_mean", ...
        "score_all_scaled","score_lab","scores","MCDM");
    lastPart=lastParts(i_lastPart);
    directory = fullfile('ExperimentResult1',lastPart);
    dir_res = dir(fullfile(directory, '*.xlsx'));
    
    slashes = strfind(directory, '\');   
    
    n_file = length(dir_res);    

    output_folder=fullfile('AnalyseResults_p',rgb2xyz_type,lightness_type,Dtype);
    if ~exist(output_folder, 'dir')
        mkdir(output_folder);
    end
    
    
    resfile = fullfile(dir_res(1).folder, dir_res(1).name);
    result = readtable(resfile);
    result_cell = table2cell(result);
    indices = result_cell(:, 1);
    indices = cell2mat(indices);
    n_lab = max(indices) + 1;
    
    score_all = zeros(n_lab, n_file);
    num_lab_all = zeros(n_lab, n_file);
    STRESS_intra = [];
    repeat_score_all = [];
    
    for i_file = 1:n_file
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
    n_group=size(score_all,1)./49;
    for i_obs = 1:size(score_all,2)
        for i_nog = 1:n_group        
            score_all_temp=score_all((i_nog-1)*49+1:i_nog*49,i_obs);
            % picname_lab_temp=picname_lab((i_nog-1)*49+1:i_nog*49,1);
            score_all_temp = (score_all_temp - min(score_all_temp)) /(max(score_all_temp)-min(score_all_temp));
            score_all_scaled((i_nog-1)*49+1:i_nog*49,i_obs)=score_all_temp;
        end
    end
    score_all_mean = mean(score_all_scaled, 2);
    for i_file = 1:n_file
        STRESS_inter = [STRESS_inter; {dir_res(i_file).name, STRESS(score_all_scaled(:, i_file), score_all_mean)}];
    end
    outputFolder=fullfile(output_folder, lastPart,'STRESS');
    if ~exist(outputFolder, 'dir')
        mkdir(outputFolder);
    end
    save(fullfile(outputFolder, 'STRESS.mat'), 'STRESS_inter', 'STRESS_intra');
    
    n_group = floor(length(result_cell) / 64);


    %%
    n_render=49;
    load(fullfile("AnalyseResults_p",rgb2xyz_type,lightness_type,Dtype,lastPart, ...
    "ellipPara_scaled\fitRes_level.mat"), ...
    "lab_group_all","picname_check","par_ind");
    for i_group = 1:n_render:length(score_all_scaled)
        i_nog=floor((i_group-1)/n_render)+1;%number of group
        lab_group=lab_group_all(i_group:i_group+n_render-1,:);
        cell_CATed{end+1,1}=lab_group;
        cell_CATed{end,2}=picname_lab{i_group}(1:end-3);
            %-------------------------------\
        mean_cen(i_nog,:)=par_ind(i_nog,5:7);
        for i_obs=1:size(score_all_scaled,2)
            score_ind_temp=score_all_scaled(i_group:i_group+n_render-1,i_obs);
            cen_ind(i_obs,:) = calculate_weighted_or_simple_mean3D( ...
                score_ind_temp, lab_group);
            MCDM(i_nog,i_obs)=deltaE2000(mean_cen(i_nog,:),cen_ind(i_obs,:));
        end

            
    end
    picname_check=picname_check(:,1);
    picname_check{end+1,1}="mean";
    picname_check=cell2table(picname_check(:,1));
    MCDM_ori=MCDM;
    MCDM_mean_scenes=[MCDM_mean_scenes;mean(MCDM_ori,2)];
    
    MCDM(end+1,:)=mean(MCDM,1);
    MCDM(:,end+1)=mean(MCDM,2);
    
    MCDM_scene(i_lastPart,1)=MCDM(end,end);
    list_table = array2table(MCDM);
    list_table=[picname_check,list_table];
    writetable(list_table, summary_filename, 'Sheet', lastPart);  

    % concatenated_table = [concatenated_table; list_table];

end

res=[mean(mean(MCDM_mean_scenes)),max(max(MCDM_mean_scenes)),min(min(MCDM_mean_scenes))];

% writetable(concatenated_table, summary_filename, 'Sheet', lastPart );  
disp("finish MCDM calculating");
save("documents\lab_group_CATed.mat","cell_CATed");


%% 画图

figure(1);
hold on;

n_lastParts = 5;
hue_MCDM_scene = linspace(0, 1, n_lastParts + 1);
hue_MCDM_scene = hue_MCDM_scene(1:end-1); 
hsv_matrix = [hue_MCDM_scene', 0.8 * ones(n_lastParts, 1), 0.8 * ones(n_lastParts, 1)];
colors = hsv2rgb(hsv_matrix);

bar_width = 0.8 /n_lastParts; % 计算每个 bar 的宽度
figure(1)
b = bar(MCDM_scene(1:5,1));
% for i_lastPart = 1:5
%     b.FaceColor = 'flat';        % 允许为每个 bar 单独设置颜色
%     b.CData(i_lastPart,:) = colors(i_lastPart,:);  % 为每个 bar 指定颜色
% end

% for attribute = 1:n_lastParts
%     x = (1:size(nation_indices, 1)) + (attribute - 1) * bar_width - bar_width * (size(MCDM_global_1, 2) - 1) / 2;
%     bar(x, MCDM_nation(:, attribute), bar_width, 'FaceColor', colors(attribute, :));
% end
% ylim([1,3]);
% xticklabels({"实验室","室内","夜景","室外","黄昏"});
% xlabel('场景');
% ylabel('MCDM');


% 数据
labels = {"实验室","室内","夜景","室外","黄昏"};

% 绘制柱状图
b = bar(MCDM_scene, 'FaceColor', 'flat');

% 应用每个柱子的颜色
b.CData = colors;

% 添加数值标签
for i = 1:length(MCDM_scene)
    text(i, MCDM_scene(i) + 1, num2str(MCDM_scene(i)), ...
        'HorizontalAlignment','center', ...
        'VerticalAlignment','bottom');
end

set(gca, 'XTick', 1:length(labels), 'XTickLabel', labels);
xlabel('场景');
ylabel('MCDM');

ylim([1,1.8]);

MCDM_folder=fullfile(save_folder,"MCDM");
if ~exist(MCDM_folder,"dir")
    mkdir(MCDM_folder)
end
saveas(gcf,fullfile(MCDM_folder,"MCDM.jpg"));

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
