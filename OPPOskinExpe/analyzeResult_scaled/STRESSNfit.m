close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量
%%

%%
load("documents\CATedPre.mat","picname");
load("neutral24\white.mat","CCT","XYZ_gray");
load("OPPOskin\matchTable.mat");
lastParts=["inLab","indoorAdd","nightAdd","outdoorAdd","sunsetAdd","recen"];
load('documents\group_Lab.mat','cellMatrix');
wd65=[94.811 100.00 107.304];   
XYZw_pre_all=XYZ_gray./XYZ_gray(:,2).*100;
Dtype="OPPO_CAT16";
lightness_type="abs";

for i_lastPart=1:length(lastParts)
    clear("picname_check")
    lastPart=lastParts(i_lastPart);
    directory = fullfile('ExperimentResult1',lastPart);
    dir_res = dir(fullfile(directory, '*.xlsx'));
    
    slashes = strfind(directory, '\');   
    
    n_file = length(dir_res);    

    output_folder=fullfile('AnalyseResults',lightness_type,Dtype);
    if ~exist(output_folder, 'dir')
        mkdir(output_folder);
    end
    
    
    resfile = string(fullfile(dir_res(1).folder, dir_res(1).name));
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
    % 计算 z_score
    cumu=[];count=[];diff=[];
    score_all = round(score_all);
    for i_pic = 1:size(score_all, 1)
        for i_grade = 1:6
            count(i_pic, i_grade) = sum(score_all(i_pic, :) == i_grade);
        end
    end
    for i_grade = 1:6
        cumu(:, i_grade) = sum(count(:, 1:i_grade), 2);
    end
    LG = log((cumu + 0.5) ./ (size(score_all, 2) - cumu + 0.5));
    z_score = LG * 0.6422 + 0.0003;
    for i_grade = 1:5
        diff(:, i_grade) = z_score(:, i_grade + 1) - z_score(:, i_grade);
    end
    mean_diff = mean(diff, 1);
    boundary(1, 1) = 0;
    for i_grade = 2:6
        boundary(1, i_grade) = boundary(1, i_grade - 1) + mean_diff(1, i_grade - 1);
    end
    scaledValue = repmat(boundary, size(z_score, 1), 1) - z_score;
    meanScaledValue = mean(scaledValue(:, 1:5), 2);
    MSV_scaled = (meanScaledValue - min(meanScaledValue)) ./ (max(meanScaledValue) - min(meanScaledValue));
    
    %%
    %删去
    for i_row =1:size(result_cell,1)
        picname_row=result_cell{i_row,2};
        slash = find(picname_row=='_');
        serial = str2num(picname_row(slash+1:end));

    end


    %%
    n_render=49;
    for i_group = 1:n_render:length(MSV_scaled)
        i_nog=floor((i_group-1)/n_render)+1;%number of group
        for i_match=1:length(match_table)
            if strcmp(strrep(picname_lab{i_group}(1:end-3),"zrecen",""), ...
                    match_table{i_match,1})
                break
            end
        end
        XYZw_pre(i_nog,:)=XYZw_pre_all(i_match,:);
        
        
        picname_group = strcat(picname_lab{i_group}(1:end-3));
        picname_check{i_nog,1}=picname_lab{i_group}(1:end-3);
        picname_check{i_nog,2}=match_table{i_match,1};
        picname_check{i_nog,4}=XYZw_pre(i_nog,:);
        for i_cellMatrix = 1:length(cellMatrix)
            if isequal(cellMatrix{i_cellMatrix, 2}, picname_group)
                lab_group = cellMatrix{i_cellMatrix, 1};
                break
            end
        end
        
        MSV_scaled_group = MSV_scaled(i_group:i_group + n_render-1, :);
    
    
        %计算lab_group
        datai_file = '..\display_calibration\datai_sorted40_3.mat';
        XYZw=load(datai_file);
        XYZw=XYZw.XYZw;
        XYZw_scaled=XYZw./XYZw(2).*wd65(2);
        [xyz_group] = lab2xyz2(lab_group,'user',XYZw_scaled);
        wd65=[94.811 100.00 107.304];
        %-----------ecat------------
        if lightness_type=="rela"
            wd65_scaled=wd65.*XYZ_gray(i_match,2)./XYZw(2);
        elseif lightness_type=="abs"
            wd65_scaled=wd65;
        end
        if strcmp(Dtype,"noCAT")
            [lab_group] = xyz2lab(xyz_group,'user',wd65_scaled);
        else        
            [CCT(i_nog,1),duv(i_nog,1),S_out{i_nog,1}] = xyz2CCT(XYZw_pre(i_nog,:),10);
            D3(i_nog,1) = calculateD(CCT(i_nog,1),duv(i_nog,1), Dtype);
            for i_ecat=1:size(xyz_group,1)
                XYZ_aft(i_ecat,:) = CAT16_D(xyz_group(i_ecat,:), ...
                    XYZw_pre(i_nog,:), ...
                    wd65, D3(i_nog,1));
            end 
            
            [lab_group] = xyz2lab(XYZ_aft,'user',wd65_scaled);
        end
        
    
        %-------------------------------
    
        outputFolder=fullfile(output_folder, lastPart,'labNscore');
        if ~exist(outputFolder, 'dir')
            mkdir(outputFolder);
        end
        save(fullfile(outputFolder, strcat("labNscore_groupAdd", picname_group, ".mat")), ...
            'lab_group', 'MSV_scaled_group');
    end
    disp("finish STRESS calculating");
    %%
    % 拟合椭球并保存结果
    
    pre_draw_folder = fullfile(output_folder, lastPart,'pre_draw');
    if ~exist(pre_draw_folder, 'dir')
        mkdir(pre_draw_folder);
    end
    
    lab_group_all=[];MSV_group_all=[];ave_all=[];par_ind=[];r_ind=[]; 


    for i_nog = 1:length(picname_check)

        dir_groupfile = dir(fullfile(outputFolder,  ...
            strcat("labNscore_groupAdd",picname_check{i_nog,1},".mat")));
        load(fullfile(dir_groupfile(1).folder, dir_groupfile(1).name));
        picname_check{i_nog,3}=strrep(dir_groupfile(1).name,"labNscore_groupAdd","");
        if ~ismember(picname_check{i_nog,3},["sunset01","sunset02","sunset03","sunset08"])
            lab_group_all=[lab_group_all;lab_group];
            MSV_group_all=[MSV_group_all;MSV_scaled_group];
        end
        [par_ind(i_nog,:), r_ind(i_nog,:), y_ind(i_nog,:)] = ...
            my_ellipsoidfit_withL(lab_group, MSV_scaled_group);
        ave_all(i_nog,:)=lab_group(end,:);
    
        if i_nog==5
            disp("d")
        end
        [A, B, ~] = calculate_ellipse_axes_from_par(par_ind(i_nog,:));
        plot_contour_with_scatter(par_ind(i_nog,:), lab_group, MSV_scaled_group);
        exportgraphics(gcf, fullfile(pre_draw_folder, ...
            strcat(strrep(dir_groupfile(1).name, ...
            'labNscore_group',''), '.jpg')),'Resolution',150);
    end
        
    [par, r, y] = my_ellipsoidfit_withL(lab_group_all, MSV_group_all);
    plot_contour_with_scatter(par, lab_group_all, MSV_group_all);
    exportgraphics(gcf, fullfile(pre_draw_folder, 'all.jpg'),'Resolution',150);
    parNr=[par, r];
    
    list_table = create_list_table(ave_all(:,1), par_ind,r_ind);
    
    %%
    XYZ_bf=lab2xyz2([mean(lab_group_all(:,1)),par(:,4:5)],'d65_64');
    
    outputFolder=fullfile(output_folder, lastPart,'ellipPara_scaled');
    if ~exist(outputFolder, 'dir')
        mkdir(outputFolder);
    end
    save(fullfile(outputFolder, "fitRes_level.mat"), ...
        'par', 'r', 'y','parNr',"picname_check","XYZ_bf", ...
        "lab_group_all","MSV_group_all", ...
        "par_ind","y_ind","r_ind","list_table");


end

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
