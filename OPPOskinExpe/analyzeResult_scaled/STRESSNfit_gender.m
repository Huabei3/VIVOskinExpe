close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量

%%
lastParts=["inLab","indoorAdd","nightAdd","outdoorAdd","sunsetAdd"];
load('documents\group_Lab.mat','cellMatrix');
load("OPPOskin\matchTable.mat","match_table");
wd65=[94.811 100.00 107.304];

load("documents\CATedPre.mat","picname");
load("neutral24\white.mat","CCT","XYZ_gray");
XYZw_pre_all=XYZ_gray./XYZ_gray(:,2).*100;
lab_f=[];lab_m=[];picname_cor_f=[];ori_labs_f=[];
p_f=[];p_m=[];picname_cor_m=[];ori_labs_m=[];
genders=["f","m"];
% Dtype="OPPO_CAT16";
lightness_type="rela";
Dtype = "efit_p";
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
colors=hsv(length(genders));
% ori_labs_gender= cell(length(genders), 1);
for i_lastPart=1:length(lastParts)
    lastPart=lastParts(i_lastPart);
    directory = fullfile('ExperimentResult',lastPart);
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

    picname_f=["female1makeup","female2makeup","female3makeup",...
        "female4makeup","female5makeup",...
        "female1nomakeup","female2nomakeup","female3nomakeup",...
        "female4nomakeup","female5nomakeup"];
    picname_m=["male1","male2","male3","male4"];
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
        if ismember(picname_rela,picname_f)
             if ~ismember(picname_cor,escape)
                ori_labs_f=[ori_labs_f;lab_group(end,:)];
                lab_f=[lab_f;lab_group];
                p_f=[p_f;p_group];
                % ori_labs_gender{1} = [ori_labs_gender{1}; ori_labs(i_para, :)];
                picname_cor_f=[picname_cor_f;picname_cor];
             end
        elseif ismember(picname_rela,picname_m)
            if ~ismember(picname_cor,escape)
                ori_labs_m=[ori_labs_m;lab_group(end,:)];
                lab_m=[lab_m;lab_group];
                p_m=[p_m;p_group];  
                % ori_labs_gender{2} = [ori_labs_gender{2}; ori_labs(i_para, :)];
                picname_cor_m=[picname_cor_m;picname_cor];
            end
        end
    end     

end
outputFolder=fullfile(output_folder, "gender",'labNscore');
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end
save(fullfile(outputFolder, strcat("labNscore_groupAdd_gender.mat")), ...
    'lab_f', 'p_f','lab_m', 'p_m','picname_cor_f','picname_cor_m');
pre_draw_folder = fullfile(output_folder, "gender",'pre_draw');
if ~exist(pre_draw_folder, 'dir')
    mkdir(pre_draw_folder);
end
types=["f","m"];
par_all=[];r_all=[];parNr_all=[];
for i_types = 1:2
    if i_types==1
        lab_type=lab_f;
        p_type=p_f;
        labCh_ori=mean(ori_labs_f,1);
    elseif i_types==2
        lab_type=lab_m;
        p_type=p_m;
        labCh_ori=mean(ori_labs_m,1);
    end

    [cen,~] = calculate_weighted_or_simple_mean(p_type, lab_type);
    [par, r, y]=my_ellipsoidfit_fixed(lab_type, p_type,cen);

    % [par, r, y] = my_ellipsoidfit_withL(lab_type, p_type);
    figure(5)
    plot_contour_with_scatter(par, lab_type, p_type);
    exportgraphics(gcf, fullfile(pre_draw_folder,strcat(types(i_types), '.jpg')),'Resolution',150);
    
    pic_folder = fullfile(output_folder, "gender",'ellipsoid_sections');
    if ~exist(pic_folder, 'dir')
        mkdir(pic_folder);
    end
    contour50ellip(par, colors(i_types,:), ...
    pic_folder,"gender", labCh_ori);

    par_all = [par_all; par];
    r_all = [r_all; r];
    parNr_all = [parNr_all; [par, r]];        

end

%%
concatenate_images1(pic_folder,2);
outputFolder=fullfile(output_folder, "gender",'ellipPara_scaled');
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end
save(fullfile(outputFolder, "fitRes_level.mat"),...
    "lab_f","p_f","lab_m","p_m", ...
    "par_all","r_all",'picname_cor_f','picname_cor_m');
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
