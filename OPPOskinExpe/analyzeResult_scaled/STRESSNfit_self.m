close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量

interpreter_type="tex";  % 可选 "tex" 或 "latex"

%%

directory = 'ExperimentResult1\selfAssRes';
dir_res = dir(fullfile(directory, '*.xlsx'));

n_file = length(dir_res);
load("OPPOskin\matchTable.mat","match_table");
load("documents\CATedPre.mat","picname");
load("documents\group_Lab_withrecenNgray.mat");
load("neutral24\white.mat","CCT","XYZ_gray");
wd65=[94.811 100.00 107.304];
XYZw_pre_all=XYZ_gray./XYZ_gray(:,2).*100;
% Dtype="OPPO_CAT16";

Dtype = "efit_p";
lightness_type="rela";
rgb2xyz_type="display";
if strcmp(Dtype,"efit_p")
    sourceFolder=fullfile('AnalyseResults_p',rgb2xyz_type,lightness_type);
else
    sourceFolder='AnalyseResults';
end

output_folder=fullfile(sourceFolder,Dtype,"self");
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end

STRESS_intra=[];mean_center_all={};
SV_group_all=[];picname_check=[];lab_group_all=[];
for i_file = 1:n_file

    resfile = fullfile(dir_res(i_file).folder, dir_res(i_file).name);
    model=dir_res(i_file).name(1:end-4);
    result = readtable(resfile);
    result_cell = table2cell(result);
    indices = result_cell(:, 1);
    indices = cell2mat(indices);
    
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
    STRESS_intra = [STRESS_intra; {dir_res(i_file).name, STRESS(repeat_score(:, 2), repeat_score_mean)}];


%%
    SV=(score_lab-1)/5;
    
%%
    %删去
    delete_rows=[];
    for i_row =1:size(result_cell,1)
        picname_row=result_cell{i_row,2};
        slash = find(picname_row=='_');
        serial = str2num(picname_row(slash+1:end));

    end
    result_cell_check = result_cell;

    SV_ori=SV;
    %%
    n_render=49;
    for i_group = 1:n_render:length(SV)

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
        
        
        SV_group = SV(i_group:i_group + n_render-1, :);

        %-----------ecat------------
        %计算预测光源的中性白
        %计算lab_group
        datai_file = '..\display_calibration\datai_sorted40_3.mat';
        XYZw=load(datai_file);
        XYZw=XYZw.XYZw;
        XYZw_scaled=XYZw./XYZw(2).*wd65(2);
        [xyz_group] = lab2xyz2(lab_group,'user',XYZw_scaled);
        wd65=[94.811 100.00 107.304];
        %-----------ecat------------
        wd65_scaled=wd65.*XYZ_gray(i_match,2)./XYZw(2);
        %根据Dtype进行色适应变换
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
    
        mean_center = calculate_weighted_or_simple_mean(SV_group, lab_group);

        mean_center_all{end+1,1}=string(picname_lab{i_group,1}(1:end-3));
        mean_center_all{end,2}=mean_center;

        outputFolder=fullfile(output_folder, 'labNscore');
        if ~exist(outputFolder, 'dir')
            mkdir(outputFolder);
        end
        pre_draw_folder = fullfile(output_folder,'pre_draw');
        if ~exist(pre_draw_folder, 'dir')
            mkdir(pre_draw_folder);
        end
        figure();
        mean_cen_with_scatter(lab_group, SV_group)
        hold on;
        scatter(mean_center(2),mean_center(3),80,'p','filled', ...
            'MarkerEdgeColor','r','MarkerFaceColor','r');
        exportgraphics(gcf, fullfile(pre_draw_folder, ...
            strcat(model,string(picname_lab(i_nog)), '.jpg')),'Resolution',150);
        close(gcf)
        save(fullfile(outputFolder, strcat("labNscore_groupAdd", picname_group, ".mat")), ...
        'lab_group', 'SV_group','mean_center');
        SV_group_all=[SV_group_all;SV_group];
        lab_group_all=[lab_group_all;lab_group];
    end
   
end
fullfile(pwd,outputFolder)
save(fullfile(output_folder, "fitRes_self.mat"), ...
    "SV_group_all","lab_group_all","mean_center_all");


disp("d");
%%
% pic_folder=pre_draw_folder;
% opts.targetFontSize=12;
% opts.margin=0.12;    
% opts.label_type="gender50";
% opts.if_rotate=false;
% 
% opts.dir_figs=dir(fullfile(pic_folder,"a_b_50.fig"));
% opts.dir_figs=[opts.dir_figs;dir(fullfile(pic_folder,"L_C_50.fig"))];
% opts.dir_figs=[opts.dir_figs;dir(fullfile(pic_folder,"L_a_50.fig"))];
% opts.dir_figs=[opts.dir_figs;dir(fullfile(pic_folder,"L_b_50.fig"))];
% 
% opts.axis_limits=[[5,40,5,40];[5,40,45,75];[10,30,45,75];[5,40,45,75]];
% opts.axis_ticks=[10,10,10,10];
% 
% adjust_fig(pic_folder, opts);
% %%
% text_type="ch";
% if strcmp(text_type,"eng")
%     s.labels_row1 = {'female','male'};
%     s.labels_row2 = {'preference center','original','PMCC'};
% elseif strcmp(text_type,"ch")
%     s.labels_row1 = {"女性","男性"};
%     s.labels_row2 = {'喜好中心', '原图肤色','PMCC'};
% end
% 
% s.markers_row2 = {'o', '+','s'};
% s.markers_colors = [0 0 0; 0 0 0; 1 0 1];
% s.markers_face_colors=[0 0 0; 0 0 0; 1 0 1];
% 
% s.sidePad=0.2;
% s.if_label=1;
% s.colors_row1 = colors;
% s.marginL=0.25;
% s.leg_x_shift=-0.1;
% s.h_space_scale=0.7;
% s.posY_shift=0.2;
% s.rowStep=0.2;
% %----------------------
% dir_figs=dir(fullfile(pic_folder,"*adjusted.fig"));   
% clear("figFiles");i_fig1=1;
% for i_fig=1:length(dir_figs)
%     figFiles{i_fig1}=dir_figs(i_fig).name;
%     i_fig1=i_fig1+1;
% end
% s.dir_figs=dir(fullfile(pic_folder,"a_b_50adjusted.fig"));
% s.dir_figs=[s.dir_figs;dir(fullfile(pic_folder,"L_C_50adjusted.fig"))];
% s.dir_figs=[s.dir_figs;dir(fullfile(pic_folder,"L_a_50adjusted.fig"))];
% s.dir_figs=[s.dir_figs;dir(fullfile(pic_folder,"L_b_50adjusted.fig"))];
% 
% s.interpreter_type=interpreter_type;  % 传递给concatenate_figs_legend1
% legend_file="";
% s.tickFontScale = 1;
% s.fontSizeScale=1.2;
% s.row_gap = 0.05;
% s.col_gap = 0.03;
% s.posY_bottom = 0.15;
% concatenate_figs_legend1(pic_folder, figFiles, 2,legend_file,"draw",s,0,0.4);
% 
% 
% fullfile(pwd,pic_folder)
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
