clear;clc;close all;
addpath("utils\")
%% cens self区分场景
load("AnalyseResults_p\display\rela\efit_p\self\fitRes_self.mat","mean_center_all");
Dtype = "efit_p";
lightness_type="rela";
rgb2xyz_type="display";
if strcmp(Dtype,"efit_p")
    sourceFolder=fullfile('AnalyseResults_p',rgb2xyz_type,lightness_type);
else
    sourceFolder='AnalyseResults';
end
load("OPPOskin\matchTable_map.mat");
load("documents\par52.mat");
load("OPPOskin\matchTable.mat");
for i_row=1:5
    for i_col=1:2
        cens_self_scene{i_row,i_col}=[];
        cens_self_scene{i_row,i_col}=[];
    end
end
for i_sing=1:size(result_sing)
    for i_self=1:size(mean_center_all,1)
        if strcmp(result_sing{i_sing,1},mean_center_all{i_self,1})

            LabCh=mean_center_all{i_self,2};
            LabCh(:,4)=sqrt(LabCh(:,2).^2+LabCh(:,3).^2);
            LabCh(:,5)=atan2d(LabCh(:,3).^2,LabCh(:,2).^2);


            if contains(result_sing{i_sing,1},"male")
                cens_self_scene{1,1}=[cens_self_scene{1,1};result_sing{i_sing,2}];
                cens_self_scene{1,2}=[cens_self_scene{1,2};LabCh];
            elseif contains(result_sing{i_sing,1},"indoor")
                cens_self_scene{2,1}=[cens_self_scene{2,1};result_sing{i_sing,2}];
                cens_self_scene{2,2}=[cens_self_scene{2,2};LabCh];
            elseif contains(result_sing{i_sing,1},"night")
                cens_self_scene{3,1}=[cens_self_scene{3,1};result_sing{i_sing,2}];
                cens_self_scene{3,2}=[cens_self_scene{3,2};LabCh];
            elseif contains(result_sing{i_sing,1},"outdoor")
                cens_self_scene{4,1}=[cens_self_scene{4,1};result_sing{i_sing,2}];
                cens_self_scene{4,2}=[cens_self_scene{4,2};LabCh];
            elseif contains(result_sing{i_sing,1},"sunset")
                cens_self_scene{5,1}=[cens_self_scene{5,1};result_sing{i_sing,2}];
                cens_self_scene{5,2}=[cens_self_scene{5,2};LabCh];
            end
        end
    end

end

% load(fullfile(sourceFolder,"data_for_Lilliefors.mat"), ...
%     "cens_model","cens_makeup","cens_scene","cens_gender","cens_self");
% % 
% % 
% save(fullfile(sourceFolder,"data_for_Lilliefors.mat"), ...
%     "cens_model","cens_makeup","cens_scene","cens_gender", ...
%     "cens_self","cens_self_scene");
%% 相关性分析所用数据
% load("AnalyseResults_p\display\rela\efit_p\self\fitRes_self.mat","mean_center_all");
% Dtype = "efit_p";
% lightness_type="rela";
% rgb2xyz_type="display";
% if strcmp(Dtype,"efit_p")
%     sourceFolder=fullfile('AnalyseResults_p',rgb2xyz_type,lightness_type);
% else
%     sourceFolder='AnalyseResults';
% end
% load("OPPOskin\matchTable_map.mat");
% load("documents\par52.mat");
% load("OPPOskin\matchTable.mat");
% 
% cens_self{1,1}=[];cens_self{2,1}=[];
% for i_sing=1:size(result_sing)
%     for i_self=1:size(mean_center_all,1)
%         if strcmp(result_sing{i_sing,1},mean_center_all{i_self,1})
%             cens_self{1,1}=[cens_self{1,1};result_sing{i_sing,2}];
%             LabCh=mean_center_all{i_self,2};
%             LabCh(:,4)=sqrt(LabCh(:,2).^2+LabCh(:,3).^2);
%             LabCh(:,5)=atan2d(LabCh(:,3).^2,LabCh(:,2).^2);
%             cens_self{2,1}=[cens_self{2,1};LabCh];
%         end
%     end
% 
% end
% 
% load(fullfile(sourceFolder,"data_for_Lilliefors.mat"), ...
%     "cens_model","cens_makeup","cens_scene","cens_gender","cens_self");
% % 
% % 
% save(fullfile(sourceFolder,"data_for_Lilliefors1.mat"), ...
%     "cens_model","cens_makeup","cens_scene","cens_gender","cens_self");
% for i_row=1:2
%     cens_gender{i_row,1}=[];
% end
% for i_row=1:5
%     cens_scene{i_row,1}=[];
% end
% for i_row=1:2
%     cens_makeup{i_row,1}=[];
% end
% for i_row=1:9
%     cens_model{i_row,1}=[];
% end
% for i_sing=1:size(result_sing,1)
%     corr_name=match_table_map(result_sing{i_sing,1});
% 
%     if contains(corr_name,"female")
%         cens_gender{1,1}=[cens_gender{1,1};result_sing{i_sing,2}];
%     else
%         cens_gender{2,1}=[cens_gender{2,1};result_sing{i_sing,2}];
%     end
% 
%     if contains(result_sing{i_sing,1},"male")
%         cens_scene{1,1}=[cens_scene{1,1};result_sing{i_sing,2}];
%     elseif contains(result_sing{i_sing,1},"indoor")
%         cens_scene{2,1}=[cens_scene{2,1};result_sing{i_sing,2}];
%     elseif contains(result_sing{i_sing,1},"night")
%         cens_scene{3,1}=[cens_scene{3,1};result_sing{i_sing,2}];
%     elseif contains(result_sing{i_sing,1},"outdoor")
%         cens_scene{4,1}=[cens_scene{4,1};result_sing{i_sing,2}];
%     elseif contains(result_sing{i_sing,1},"sunset")
%         cens_scene{5,1}=[cens_scene{5,1};result_sing{i_sing,2}];
%     end
%     if contains(result_sing{i_sing,1},"female")&&~contains(result_sing{i_sing,1},"no")
%         cens_makeup{1,1}=[cens_makeup{1,1};result_sing{i_sing,2}];
%     elseif contains(result_sing{i_sing,1},"female")&&contains(result_sing{i_sing,1},"no")
%         cens_makeup{2,1}=[cens_makeup{2,1};result_sing{i_sing,2}];
%     end
% 
%     if contains(corr_name,"female1")
%         cens_model{1,1}=[cens_model{1,1};result_sing{i_sing,2}];
%         cens_model{1,2}(end+1,1)=result_sing{i_sing,1};
%     elseif contains(corr_name,"female2")        
%         cens_model{2,1}=[cens_model{2,1};result_sing{i_sing,2}];
%         cens_model{1,2}=result_sing{i_sing,1};
%     elseif contains(corr_name,"female3")
%         cens_model{1,2}=result_sing{i_sing,1};
%         cens_model{3,1}=[cens_model{2,1};result_sing{i_sing,2}];
%     elseif contains(corr_name,"female4")
%         cens_model{4,1}=[cens_model{2,1};result_sing{i_sing,2}];
%     elseif contains(corr_name,"female5")
%         cens_model{5,1}=[cens_model{2,1};result_sing{i_sing,2}];
%     elseif contains(corr_name,"male1")
%         cens_model{6,1}=[cens_model{2,1};result_sing{i_sing,2}];
%     elseif contains(corr_name,"male2")
%         cens_model{7,1}=[cens_model{2,1};result_sing{i_sing,2}];
%     elseif contains(corr_name,"male3")
%         cens_model{8,1}=[cens_model{2,1};result_sing{i_sing,2}];
%     elseif contains(corr_name,"male4")
%         cens_model{9,1}=[cens_model{2,1};result_sing{i_sing,2}];
%     end
% 
% end
% Dtype = "efit_p";
% lightness_type="rela";
% rgb2xyz_type="display";
% if strcmp(Dtype,"efit_p")
%     sourceFolder=fullfile('AnalyseResults_p',rgb2xyz_type,lightness_type);
% else
%     sourceFolder='AnalyseResults';
% end
% 
% disp("d")
% save(fullfile(sourceFolder,"data_for_Lilliefors.mat"), ...
%     "cens_model","cens_makeup","cens_scene","cens_gender");
%% 不同场景LCh增量和CCT的表
% load("neutral24\white.mat","CCT","XYZ_gray","result_cell");
% % load("OPPOskin\matchTable_map.mat");
% % load("neutral24\global_ratio.mat");
% 
% CCT_scenes{1,1}=CCT(1:14,:);
% CCT_scenes{2,1}=CCT(15:24,:);
% CCT_scenes{3,1}=CCT(25:34,:);
% CCT_scenes{4,1}=CCT(35:44,:);
% CCT_scenes{5,1}=CCT(45:52,:);
% CCT_scenes{2,1}(5,:)=[];
% CCT_scenes{5,1}([1,2,3,8],:)=[];
% 
% lastParts=["inLab","indoorAdd","nightAdd","outdoorAdd","sunsetAdd"];
% % load("Optimize_D\picnameNCCT.mat");
% % Dtype="OPPO_CAT16";
% Dtype = "efit_p";
% lightness_type="rela";
% rgb2xyz_type="display";
% if strcmp(Dtype,"efit_p")
%     sourceFolder=fullfile('AnalyseResults_p',rgb2xyz_type,lightness_type);
% else
%     sourceFolder='AnalyseResults';
% end
% output_folder=fullfile(sourceFolder,Dtype);
% if ~exist(output_folder, 'dir')
%     mkdir(output_folder);
% end
% for i_lastPart=1:length(lastParts)
%     lastPart=lastParts(i_lastPart);
%     outputFolder=fullfile(output_folder, "scene",lastPart,'ellipPara_scaled');
%     fit_data=load(fullfile(outputFolder, "fitRes_level.mat"),...
%         "par","r",'picname_check',"ori_labs","labCh_ori");
%     res_matrix(i_lastPart,1:3)=fit_data.par(1,5:7);
%     res_matrix(i_lastPart,4:6)=fit_data.par(1,5:7)-fit_data.labCh_ori;
%     res_matrix(i_lastPart,7)=mean(CCT_scenes{i_lastPart,1},1);
% end
% disp("d")
%%
% data1=load("AnalyseResults_p\abs\efit_p\indoorAdd\ellipPara_scaled\fitRes_level.mat");
% data2=load("AnalyseResults_p\display\rela\efit_p\indoorAdd\ellipPara_scaled\fitRes_level.mat");
%% 制作表 不同场景、模特、性别、妆容状态的表

load("documents\CATedPre.mat","picname");
load("neutral24\white.mat","CCT","XYZ_gray");
load("OPPOskin\matchTable.mat");
lastParts=["inLab","indoorAdd","nightAdd","outdoorAdd","sunsetAdd","recen"];
load('documents\group_Lab.mat','cellMatrix');

load("AnalyseResults_p\display\rela\efit_p\self\fitRes_self.mat","mean_center_all");

wd65=[94.811 100.00 107.304];   
XYZw_pre_all=XYZ_gray./XYZ_gray(:,2).*100;

lightness_type="rela";
rgb2xyz_type="display";
Dtype = "efit_p";
if strcmp(Dtype,"efit_p")
    sourceFolder=fullfile('AnalyseResults_p',rgb2xyz_type,lightness_type);
else
    sourceFolder='AnalyseResults';
end
output_folder=fullfile(sourceFolder,Dtype);
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end
curr=1;curr1=1;
res_sing_matrix=[];res_group_matrix=[];res_sing_matrix_fit=[];


fitRes_older=fullfile(output_folder, "scene",'ellipPara_scaled');
data1=load(fullfile(fitRes_older,"fitRes_level.mat"));

for i_lastPart=1:5
    lastPart=lastParts(i_lastPart);
    fitRes_older=fullfile(output_folder, lastPart,'ellipPara_scaled');
    data=load(fullfile(fitRes_older,"fitRes_level.mat"));
    for i_par=1:size(data.par_ind,1)
        clear("LabCh")
        LabCh=data.par_ind(i_par,5:7);
        LabCh(:,4)=sqrt(LabCh(:,2).^2+LabCh(:,3).^2);
        LabCh(:,5)=atan2d(LabCh(:,3).^2,LabCh(:,2).^2);
        result_sing{curr,1}=data.picname_check{i_par,1};
        result_sing{curr,2}=LabCh;
        curr=curr+1;
        res_sing_matrix=[res_sing_matrix;LabCh(:,[1:5])];
        res_sing_matrix_fit=[res_sing_matrix_fit;data.par_ind(i_par,:)];
    end
    clear("LabCh")
    LabCh=data1.par_all(i_lastPart,5:7);
    LabCh(:,4)=sqrt(LabCh(:,2).^2+LabCh(:,3).^2);
    LabCh(:,5)=atan2d(LabCh(:,3).^2,LabCh(:,2).^2);

    result_group{curr1,1}=lastPart;

    result_group{curr1,2}=LabCh;

    curr1=curr1+1;
    res_group_matrix=[res_group_matrix;LabCh(:,[1:5])];
    fitRes95_file=fullfile(output_folder, ...
        "scene\95\ellipPara",strcat(lastPart,"fitRes_level.mat"));
    fitRes95_data=load(fitRes95_file);

end


types = ["female1", "female2", "female3", "female4", "female5", ...
    "male1", "male2", "male3", "male4"];
fitRes_older=fullfile(output_folder, "models",'ellipPara_scaled');
data=load(fullfile(fitRes_older,"fitRes_level.mat"));
for i_par=1:size(data.par_all,1)
    clear("LabCh")
    LabCh=data.par_all{i_par,1}(1,5:7);
    LabCh(:,4)=sqrt(LabCh(:,2).^2+LabCh(:,3).^2);
    LabCh(:,5)=atan2d(LabCh(:,3).^2,LabCh(:,2).^2);
    result_group{curr1,1}=types(i_par);
    result_group{curr1,2}=LabCh;
    curr1=curr1+1;
    res_group_matrix=[res_group_matrix;LabCh(:,[1:5])];
end
types=["f","m"];
fitRes_older=fullfile(output_folder, "gender",'ellipPara_scaled');
data=load(fullfile(fitRes_older,"fitRes_level.mat"));
for i_par=1:size(data.par_all,1)
    clear("LabCh")
    LabCh=data.par_all(i_par,5:7);
    LabCh(:,4)=sqrt(LabCh(:,2).^2+LabCh(:,3).^2);
    LabCh(:,5)=atan2d(LabCh(:,3).^2,LabCh(:,2).^2);

    result_group{curr1,1}=types(i_par);
    result_group{curr1,2}=LabCh;
    curr1=curr1+1;    
    res_group_matrix=[res_group_matrix;LabCh(:,[1:5])];
end
types=["fm","fn","m"];
fitRes_older=fullfile(output_folder, "makeup",'ellipPara_scaled');
data=load(fullfile(fitRes_older,"fitRes_level.mat"));
for i_par=1:2
    clear("LabCh")
    LabCh=data.par_all(i_par,5:7);
    LabCh(:,4)=sqrt(LabCh(:,2).^2+LabCh(:,3).^2);
    LabCh(:,5)=atan2d(LabCh(:,3).^2,LabCh(:,2).^2);

    result_group{curr1,1}=types(i_par);
    result_group{curr1,2}=data.par_all(i_par,5:7);
    curr1=curr1+1;
    res_group_matrix=[res_group_matrix;LabCh(:,[1:5])];
end
% res_group_matrix(:,4)=sqrt(res_group_matrix(:,2).^2+res_group_matrix(:,3).^2);
% res_group_matrix(:,5)=atan2d(res_group_matrix(:,3),res_group_matrix(:,2));
disp("d")
save("documents\par52.mat", ...
    "res_group_matrix","result_group","result_sing","res_sing_matrix");
%%
% load("neutral24\white.mat","CCT","XYZ_gray","result_cell");
% load("OPPOskin\matchTable_map.mat");
% load("neutral24\global_ratio.mat");
% 
% % 初始化 result_cell1，用于存储结果
% % result_cell1 的大小应该根据 match_table_map 的键的数量来确定
% keys_map = match_table_map.keys;
% result_cell1 = cell(1, length(keys_map));
% 
% % 遍历 match_table_map 中的每一个键
% for k_idx = 1:length(keys_map)
%     current_key = keys_map{k_idx};
%     matching_rows_indices=[];
%     % 查找 result_cell 中第一列与 current_key 匹配的所有行
%     for i_row =1:length(result_cell)
%         if strcmp(match_table_map(result_cell{i_row,1}),current_key)
%             matching_rows_indices=[matching_rows_indices,i_row];
%         end
%     end
% 
%     % 提取这些匹配的行
%     matching_rows_data = result_cell(matching_rows_indices, :);
% 
%     % 将匹配的行存储到 result_cell1 对应的单元格中
%     result_cell1{k_idx} = matching_rows_data;
% end
% 
% % 现在 result_cell1 包含了您想要的结果
% % 例如，您可以查看 result_cell1{1} 来查看与第一个键相关的所有行
% %%
% num_rows = size(result_cell, 1);
% new_column = cell(num_rows, 1);
% 
% % Iterate through each row and populate the new column
% for idx = 1:num_rows
%     key = result_cell{idx, 1}; % Get the key from the first column of result_cell
%     if isKey(match_table_map, key)
%         new_column{idx, 1} = match_table_map(key); % Get the value from the hash table
%     else
%         % Handle cases where the key might not be in the hash table
%         % You can assign a default value, an empty array, or NaN/empty string
%         new_column{idx, 1} = []; % Example: assign empty if key not found
%     end
% end
% % Concatenate the new column to result_cell
% result_cell = [result_cell, new_column];
% save("Optimize_D\picnameNCCT.mat","result_cell");
%%
% source_folder="D:\work\project_code_backup\OPPOskinExpe\analyzeResult_scaled\images\sample\r";
% concatenate_images2(source_folder,4);
%% 计算欧莱雅的SKin Color Chart标准

% % 读取Excel文件
% model_table = readtable('OPPOskin\OPPOskin.xlsx', 'ReadVariableNames', false);
% 
% % 定义labCh_D矩阵
% labCh_D = [
%     35.34    8.62    14.7     17.04   59.61;  % D12
%     38.41    9.84    16.06    18.83   58.5;   % D11
%     41.45   10.83    17.32    20.43   57.98;  % D10
%     44.53   11.52    18.46    21.76   58.03;  % D9
%     47.51   12.12    19.36    22.84   57.95;  % D8
%     50.53   12.47    19.99    23.56   58.04;  % D7
%     53.51   12.73    20.41    24.05   58.05;  % D6
%     56.49   12.85    20.54    24.23   57.97;  % D5
%     59.50   12.80    20.43    24.11   57.93;  % D4
%     62.51   12.59    20.12    23.73   57.96;  % D3
%     65.50   12.19    19.55    23.04   58.06;  % D2
%     68.51   11.68    18.76    22.10   58.09;  % D1
% ];
% 
% % 创建h_SCC表格 (n*2的cell数组)
% h_SCC = cell(6, 2);
% h_SCC(:, 1) =  {'A'; 'B'; 'C'; 'D'; 'E'; 'H'};  % 第一列：1到11的索引
% h_SCC(:, 2) = num2cell((46:4:66)');  % 第二列：46, 50, ..., 66
% 
% % 创建L_SCC表格 (n*2的cell数组)
% L_SCC = cell(12, 2);
% L_SCC(:, 1) = num2cell((1:12)');  % 第一列：标签
% L_SCC(:, 2) = num2cell((68.5:-3:35.5)');  % 第二列：35.5, 38.5, ..., 68.5
% 
% % 提取model_table的五列labCh数据（从第二列到第六列）
% labCh_data = table2cell(model_table(:, 2:6));
% labCh_model=cell2mat(labCh_data);
% % 为每列labCh数据找到最近的L_SCC和h_SCC值，并生成序列号
% serial_cell = cell(size(labCh_data, 1), 1);
% load("OPPOskin\OPPOskin.mat","all_LabCh","lab_OPPO","picname");
% for i_model = 1:size(labCh_data, 1)
%     serial_str = '';
%     [~, i_L] = min(abs([L_SCC{:, 2}] - labCh_data{i_model, 1}));
%     [~, i_h] = min(abs([h_SCC{:, 2}] - labCh_data{i_model, 5}));
%     serial_str = [serial_str, h_SCC{i_h, 1}];
%     serial_str = [serial_str, num2str(L_SCC{i_L, 1})];
%     labCh_data{i_model,6}=serial_str;
%     ITA = atan2d((labCh_model(i_model,1) - 50),labCh_model(i_model,3));
%     labCh_data{i_model,7}=ITA;
% 
%     % 根据ITA值判断皮肤类型
%     if ITA > 55
%         skin_type = 'Very light';
%     elseif ITA > 41
%         skin_type = 'Light';
%     elseif ITA > 28
%         skin_type = 'Intermediate';
%     elseif ITA > 10
%         skin_type = 'Tan';
%     elseif ITA > -30  % 修正原分类中的错误（原分类30 < ITA°<10不可能成立）
%         skin_type = 'Brown';
%     else
%         skin_type = 'Dark';
%     end
% 
%     labCh_data{i_model,8} = skin_type;
%     labCh_data{i_model,9} = picname{i_model,1};
% end
% 
% save("OPPOskin\OPPOskin.mat","all_LabCh","lab_OPPO","picname","labCh_data");
% 
% 
% disp("d")
%% 计算每张图平均亮度和白色块亮度之比
% load("OPPOskin\matchTable_map.mat");
% load("neutral24\white.mat");
% source_folder="images\i";
% images=dir(fullfile(source_folder,"*.jpg"));
% source_folder="images\r";
% images=[images;dir(fullfile(source_folder,"*.JPG"));];
% datai_file = 'LUT3d_results\datai_sorted40_3.mat';
% xyz_global_map = containers.Map('KeyType', 'char', 'ValueType', 'any');
% xyz_ratio_map = containers.Map('KeyType', 'char', 'ValueType', 'any');
% for i_img=1:length(images)
%     img=imread(fullfile(images(i_img).folder,images(i_img).name));
%     sz=size(img);
%     img=double(img);
%     out = reshape(img, [sz(1) * sz(2), sz(3)]);  
%     xyz_img=lut3d_rgb2xyz1(out,datai_file);
%     xyz_global{i_img,1}=mean(xyz_img,1);
%     xyz_global{i_img,2}=images(i_img).name(1:end-4);
%     XYZw_pre(i_img,:)=XYZ_gray_map(images(i_img).name(1:end-4));
%     xyz_ratio(i_img,:)=XYZw_pre(i_img,:)./xyz_global{i_img,1};
%     xyz_ratio_map(images(i_img).name(1:end-4)) = xyz_ratio(i_img,:);
%     disp(images(i_img).name)
%     XYZw_pre(i_img,:),max(xyz_img)
% end
% save("neutral24\global_ratio.mat", ...
%     'xyz_ratio_map',"xyz_global_map","xyz_global","xyz_ratio");
%%  制作matchTable_map
% load("neutral24\white.mat","CCT","XYZ_gray");
% load("OPPOskin\matchTable_map.mat");
% load("OPPOskin\matchTable.mat");
% match_serial=match_table(:,2);
% pic_names=match_table(:,1);
% pic_names = cellstr(pic_names);
% % pic_names=keys();pic_names=pic_names';
% pic_cors=match_table(:,3);
% XYZ_gray_map = containers.Map('KeyType', 'char', 'ValueType', 'any');
% 
% 
% for i = 1:length(pic_names)
%     XYZ_gray_map(pic_names{i}) = XYZ_gray(i, :); % 将第 i 行的值作为映射的值
%     % XYZ_gray_map(pic_names{i}),XYZ_gray(i, :)
% end
% 
% CCT_map=containers.Map(pic_names,CCT);
% match_serial_map=containers.Map(pic_names,match_serial);
% match_table_map=containers.Map(pic_names,pic_cors);
% save("OPPOskin\matchTable_map.mat", ...
%     "match_serial_map","CCT_map","XYZ_gray_map","match_table_map");