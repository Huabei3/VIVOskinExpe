close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量
addpath("utils\")

interpreter_type="tex";  % 可选 "tex" 或 "latex"

%%
lastParts=["inLab","indoorAdd","nightAdd","outdoorAdd","sunsetAdd"];
load('documents\group_Lab.mat','cellMatrix');
load("OPPOskin\matchTable.mat","match_table");
wd65=[94.811 100.00 107.304];

load("documents\CATedPre.mat","picname");
load("neutral24\white.mat","CCT","XYZ_gray");
XYZw_pre_all=XYZ_gray./XYZ_gray(:,2).*100;
lab_fm=[];p_fm=[];picname_fm={};picname_cor_fm=[];ori_labs_fm=[];
lab_fn=[];p_fn=[];picname_fn={};picname_cor_fn=[];ori_labs_fn=[];
lab_m=[];p_m=[];picname_m={};picname_cor_m=[];ori_labs_m=[];
% Dtype="OPPO_CAT16";
Dtype = "efit_p";
lightness_type="rela";
rgb2xyz_type="display";
if strcmp(Dtype,"efit_p")
    sourceFolder=fullfile('AnalyseResults_p',rgb2xyz_type,lightness_type);
else
    sourceFolder='AnalyseResults';
end
output_folder=fullfile(sourceFolder,Dtype);
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end
colors=hsv(2);

for i_lastPart=1:1
    lastPart=lastParts(i_lastPart);
    directory = fullfile('ExperimentResult',lastPart,'changedResultsFile\all_delete');
    dir_res = dir(fullfile(directory, '*.csv'));
    
    slashes = strfind(directory, '\');   
    
    n_file = length(dir_res);

    %%
    % 拟合椭球并保存结果
    if lastPart == "inLab"
        picname_groups=["female1makeup","female1nomakeup",...
        "female2makeup","female2nomakeup",...
        "female3makeup","female3nomakeup",...
        "female4makeup","female4nomakeup",...
        "female5makeup","female5nomakeup",...
        "male1","male2","male3","male4"];
    elseif lastPart == "indoorAdd"
        picname_groups=["indoor01","indoor02","indoor03","indoor04","indoor05",...
            "indoor06","indoor07","indoor08","indoor09","indoor10"];
    elseif lastPart == "nightAdd"
        picname_groups=["night01","night02","night03","night04","night05",...
            "night06","night07","night08","night09","night10"];
    elseif lastPart == "outdoorAdd"
        picname_groups=["outdoor01","outdoor02","outdoor03","outdoor04","outdoor05",...
            "outdoor06","outdoor07","outdoor08","outdoor09","outdoor10"];
    elseif lastPart == "sunsetAdd"
        picname_groups=["sunset01","sunset02","sunset03","sunset04","sunset05",...
            "sunset06","sunset07","sunset08"];
    end
    clear("picname_check")

    picname_fm=["female1makeup","female2makeup","female3makeup",...
        "female4makeup","female5makeup"];
    picname_fn=["female1nomakeup","female2nomakeup","female3nomakeup",...
        "female4nomakeup","female5nomakeup"];
    picname_m=["male1","male2","male3","male4"];
    sunset_escape=["sunset01","sunset02","sunset03","sunset08"];
    escape=["indoor05","sunset01","sunset02","sunset03","sunset08"];

    outputFolder=fullfile(output_folder, lastPart,'labNscore');
    if ~exist(outputFolder, 'dir')
        mkdir(outputFolder);
    end
    for i_group = 1:length(picname_groups)
        dir_groupfile = dir(fullfile(outputFolder,  ...
            strcat("labNscore_groupAdd",picname_groups(i_group),".mat")));
        load(fullfile(dir_groupfile(1).folder, dir_groupfile(1).name));
        picname_check{i_group,1}=strrep(dir_groupfile(1).name,"labNscore_groupAdd","");
        %找到picnam判断男女e_rela
        for i_match=1:size(match_table)
            picname_cor=picname_groups(i_group);
            if strcmp(picname_cor,match_table{i_match,3})
                picname_rela=match_table{i_match,1};
                break
            end
        end
            %分类保存
        if ismember(picname_rela,picname_fm)
             if ~ismember(picname_cor,escape)
                lab_fm=[lab_fm;lab_group];
                p_fm=[p_fm;p_group];
                picname_cor_fm=[picname_cor_fm;picname_cor];
                ori_labs_fm=[ori_labs_fm;lab_group(end,:)];
             end
        elseif ismember(picname_rela,picname_fn)
             if ~ismember(picname_cor,escape)
                lab_fn=[lab_fn;lab_group];
                p_fn=[p_fn;p_group];
                picname_cor_fn=[picname_cor_fn;picname_cor];
                ori_labs_fn=[ori_labs_fn;lab_group(end,:)];
             end
        elseif ismember(picname_rela,picname_m)
            if ~ismember(picname_cor,escape)
                lab_m=[lab_m;lab_group];
                p_m=[p_m;p_group];  
                picname_cor_m=[picname_cor_m;picname_cor];
                ori_labs_m=[ori_labs_m;lab_group(end,:)];
            end
        end
    end     

end
outputFolder=fullfile(output_folder, "makeup",'labNscore');
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end
save(fullfile(outputFolder, strcat("labNscore_groupAdd_makeup.mat")), ...
    'lab_fm', 'p_fm','lab_fn', 'p_fn', ...
    'lab_m', 'p_m','picname_cor_fm','picname_cor_fn','picname_cor_m');
pre_draw_folder = fullfile(output_folder, "makeup",'pre_draw');
if ~exist(pre_draw_folder, 'dir')
    mkdir(pre_draw_folder);
end
types=["fm","fn","m"];
par_all=[];r_all=[];parNr_all=[];
for i_types = 1:2
    if i_types==1
        lab_type=lab_fm;
        p_type=p_fm;
        labCh_ori=mean(ori_labs_fm,1);
    elseif i_types==2
        lab_type=lab_fn;
        p_type=p_fn;
        labCh_ori=mean(ori_labs_fn,1);
    elseif i_types==3
        lab_type=lab_m;
        p_type=p_m;
        labCh_ori=mean(ori_labs_m,1);
    end
    [cen,~] = calculate_weighted_or_simple_mean(p_type, lab_type);
    [par, r, y]=my_ellipsoidfit_fixed(lab_type, p_type,cen);

    % [par, r, y] = my_ellipsoidfit_withL(lab_type, p_type);
    figure(5)
    plot_contour_with_scatter(par, lab_type, p_type);

    img_name=fullfile(pre_draw_folder,strcat(types(i_types), '.jpg'));    
    savefig(gcf, strrep(img_name,'jpg','fig'));
    exportgraphics(gcf,img_name,'Resolution',150);
    
    pic_folder = fullfile(output_folder, "makeup",'ellipsoid_sections');
    if ~exist(pic_folder, 'dir')
        mkdir(pic_folder);
    end
    contour50ellip(par, colors(i_types,:), ...
    pic_folder,"makeup", labCh_ori, interpreter_type);
    par_all = [par_all; par];
    r_all = [r_all; r];
    parNr_all = [parNr_all; [par, r]];        

end

%%
% concatenate_images1(pic_folder,2);
outputFolder=fullfile(output_folder, "makeup",'ellipPara_scaled');
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end
save(fullfile(outputFolder, "fitRes_level.mat"),...
    "lab_fm","p_fm","lab_fn","p_fn","lab_m","p_m", ...
    "par_all","r_all",'picname_cor_fm','picname_cor_fn','picname_cor_m');



%%

opts.targetFontSize=12;
opts.margin=0.12;    
opts.label_type="makeup50";
opts.if_rotate=false;

opts.dir_figs=dir(fullfile(pic_folder,"a_b_50.fig"));
opts.dir_figs=[opts.dir_figs;dir(fullfile(pic_folder,"L_C_50.fig"))];
opts.dir_figs=[opts.dir_figs;dir(fullfile(pic_folder,"L_a_50.fig"))];
opts.dir_figs=[opts.dir_figs;dir(fullfile(pic_folder,"L_b_50.fig"))];

opts.axis_limits=[[5,40,5,40];[5,40,45,75];[10,30,45,75];[5,40,45,75]];
opts.axis_ticks=[10,10,10,10];

adjust_fig(pic_folder, opts);
%%
text_type="ch";
if strcmp(text_type,"eng")
    s.labels_row1 = {'with makeup','without makeup'};
    s.labels_row2 = {'preference center','original','PMCC'};
elseif strcmp(text_type,"ch")
    s.labels_row1 = {"带妆","素颜"};
    s.labels_row2 = {'喜好中心', '原图肤色','PMCC'};
end

s.markers_row2 = {'o', '+','s'};
s.markers_colors = [0 0 0; 0 0 0; 1 0 1];
s.markers_face_colors=[0 0 0; 0 0 0; 1 0 1];

s.sidePad=0.2;
s.if_label=1;
s.colors_row1 = colors;
s.marginL=0.25;
s.leg_x_shift=-0.1;
s.h_space_scale=0.7;
s.posY_shift=0.2;
s.rowStep=0.2;
%----------------------
dir_figs=dir(fullfile(pic_folder,"*adjusted.fig"));   
clear("figFiles");i_fig1=1;
for i_fig=1:length(dir_figs)
    figFiles{i_fig1}=dir_figs(i_fig).name;
    i_fig1=i_fig1+1;
end
s.dir_figs=dir(fullfile(pic_folder,"a_b_50adjusted.fig"));
s.dir_figs=[s.dir_figs;dir(fullfile(pic_folder,"L_C_50adjusted.fig"))];
s.dir_figs=[s.dir_figs;dir(fullfile(pic_folder,"L_a_50adjusted.fig"))];
s.dir_figs=[s.dir_figs;dir(fullfile(pic_folder,"L_b_50adjusted.fig"))];

s.interpreter_type=interpreter_type;  % 传递给concatenate_figs_legend1
legend_file="";
s.tickFontScale = 1;
s.fontSizeScale=1.2;
s.row_gap = 0.05;
s.col_gap = 0.03;
s.posY_bottom = 0.15;
concatenate_figs_legend1(pic_folder, figFiles, 2,legend_file,"draw",s,0,0.4);


fullfile(pwd,pic_folder)
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
