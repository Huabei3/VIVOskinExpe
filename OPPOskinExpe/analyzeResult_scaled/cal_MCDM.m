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
Dtype="OPPO_CAT16";
cell_CATed={};
summary_filename=fullfile("AnalyseResults",Dtype,"sum_list/MCDM.XLSX");
concatenated_table={};
for i_lastPart=1:length(lastParts)
    clear("picname_check","score_all","score_all_mean", ...
        "score_all_scaled","score_lab","scores");
    lastPart=lastParts(i_lastPart);
    directory = fullfile('ExperimentResult',lastPart);
    dir_res = dir(fullfile(directory, '*.csv'));
    
    slashes = strfind(directory, '\');   
    
    n_file = length(dir_res);    

    output_folder=fullfile('AnalyseResults',Dtype);
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
    load(fullfile("AnalyseResults",Dtype,lastPart, ...
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
            cen_ind(i_obs,:) = calculate_weighted_or_simple_mean( ...
                score_ind_temp, lab_group);
            dE_FM(i_nog,i_obs)=deltaE2000(mean_cen(i_nog,:),cen_ind(i_obs,:));
        end

            
    end
    picname_check=picname_check(:,1);
    picname_check{end+1,1}="mean";
    picname_check=cell2table(picname_check(:,1));
    dE_FM(end+1,:)=mean(dE_FM,1);
    dE_FM(:,end+1)=mean(dE_FM,2);
    list_table = array2table(dE_FM);
    % list_table=[picname_check,list_table];
    writetable(list_table, summary_filename, 'Sheet', lastPart);  

    % concatenated_table = [concatenated_table; list_table];

end
% writetable(concatenated_table, summary_filename, 'Sheet', lastPart );  
disp("finish MCDM calculating");
save("documents\lab_group_CATed.mat","cell_CATed");
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
