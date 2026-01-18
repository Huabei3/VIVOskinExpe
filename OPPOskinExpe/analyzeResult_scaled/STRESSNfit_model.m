close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量

%% 初始化
models = ["female1", "female2", "female3", "female4", "female5", ...
    "male1", "male2", "male3", "male4"];
lastParts = ["inLab", "indoorAdd", "nightAdd", "outdoorAdd", "sunsetAdd"];
wd65 = [94.811 100.00 107.304];
num_models=length(models);
H = linspace(0, 1, num_models + 1); % 加1是为了避免最后一个值为1（和0重复）
H = H(1:end-1); % 去掉最后一个值
S = 0.8 * ones(1, num_models);
V = 0.8 * ones(1, num_models);
colors = hsv2rgb([H; S; V]');
% 初始化存储变量
lab_model = cell(length(models), 1); % 每个模特一个存储单元
p_model = cell(length(models), 1); % 每个模特一个存储单元
picname_cor_model = cell(length(models), 1); % 对应的图片名称
for i_model = 1:length(models)
    lab_model{i_model} = [];
    p_model{i_model} = [];
    picname_cor_model{i_model} = [];
    ori_labs{i_model} = [];
end
Dtype = "efit_p";
lightness_type="rela";
rgb2xyz_type="display";
if strcmp(Dtype,"efit_p")
    sourceFolder=fullfile('AnalyseResults_p',rgb2xyz_type,lightness_type);
else
    sourceFolder='AnalyseResults';
end
output_folder = fullfile(sourceFolder, Dtype);
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end

%% 加载数据并分类
load("OPPOskin\matchTable.mat", "match_table");
escape=["indoor05","sunset01","sunset02","sunset03","sunset08"];
for i_lastPart = 1:length(lastParts)
    lastPart = lastParts(i_lastPart);
    directory = fullfile('ExperimentResult', lastPart);
    dir_res = dir(fullfile(directory, '*.csv'));
    n_file = length(dir_res);

    % 根据 lastPart 获取对应的分组信息
    if lastPart == "inLab"
        picname_groups = ["female1makeup", "female1nomakeup", ...
            "female2makeup", "female2nomakeup", ...
            "female3makeup", "female3nomakeup", ...
            "female4makeup", "female4nomakeup", ...
            "female5makeup", "female5nomakeup", ...
            "male1", "male2", "male3", "male4"];
    elseif lastPart == "indoorAdd"
        picname_groups = ["indoor01", "indoor02", "indoor03", "indoor04", "indoor05", ...
            "indoor06", "indoor07", "indoor08", "indoor09", "indoor10"];
    elseif lastPart == "nightAdd"
        picname_groups = ["night01", "night02", "night03", "night04", "night05", ...
            "night06", "night07", "night08", "night09", "night10"];
    elseif lastPart == "outdoorAdd"
        picname_groups = ["outdoor01", "outdoor02", "outdoor03", "outdoor04", "outdoor05", ...
            "outdoor06", "outdoor07", "outdoor08", "outdoor09", "outdoor10"];
    elseif lastPart == "sunsetAdd"
        picname_groups = ["sunset01", "sunset02", "sunset03", "sunset04", "sunset05", ...
            "sunset06", "sunset07", "sunset08"];
    end

    % 遍历每个分组
    for i_group = 1:length(picname_groups)
        group_name = picname_groups(i_group);
        outputFolder = fullfile(output_folder, lastPart, 'labNscore');
        if ~exist(outputFolder, 'dir')
            mkdir(outputFolder);
        end

        % 加载分组数据
        dir_groupfile = dir(fullfile(outputFolder, ...
            strcat("labNscore_groupAdd", group_name, ".mat")));
        if ~isempty(dir_groupfile)
            load(fullfile(dir_groupfile(1).folder, dir_groupfile(1).name));
            picname_check = strrep(dir_groupfile(1).name(1:end-4), "labNscore_groupAdd", "");
            if ismember(picname_check,escape)
                continue
            end
            % 找到对应的模特
            for i_match = 1:size(match_table)
                if strcmp(picname_check, match_table{i_match, 1})
                    model_name = match_table{i_match,3};
                    break;
                end
            end

            % 分类保存到对应的模特组
            for i_model = 1:length(models)
                if contains(model_name, models(i_model))
                    ori_labs{i_model}=[ori_labs{i_model}; lab_group(end,:)];
                    lab_model{i_model} = [lab_model{i_model}; lab_group];
                    if strcmp(Dtype,"efit_p")
                        p_model{i_model} = [p_model{i_model}; p_group];
                    else
                        p_model{i_model} = [p_model{i_model}; MSV_scaled_group];
                    end
                    picname_cor_model{i_model} = [picname_cor_model{i_model}; picname_check];
                    break;
                end
            end
        end
    end
end

%% 保存按模特分组的结果
outputFolder = fullfile(output_folder, "models", 'labNscore');
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end

for i_model = 1:length(models)
    save(fullfile(outputFolder, strcat("labNscore_model_", models(i_model), ".mat")), ...
        'lab_model', 'p_model', 'picname_cor_model');
end

%% 拟合椭圆并保存结果
outputFolder = fullfile(output_folder, "models", 'ellipPara_scaled');
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end

par_all = cell(length(models), 1); % 每个模特的椭圆参数
r_all = cell(length(models), 1); % 每个模特的拟合残差
parNr_all = cell(length(models), 1); % 每个模特的拟合参数和残差

for i_model = 1:length(models)
    lab_type = lab_model{i_model};
    p_type = p_model{i_model};
    
    if ~isempty(lab_type) && ~isempty(p_type)
        [cen,~] = calculate_weighted_or_simple_mean(p_type, lab_type);
        % [par, r, y] = my_ellipsoidfit_withL(lab_type, p_type,cen); % 拟合椭圆
        [par, r, y]=my_ellipsoidfit_fixed(lab_type, p_type,cen);

        labCh_ori=mean(ori_labs{i_model},1);
        pic_folder = fullfile(output_folder, "model",'ellipsoid_sections');
        if ~exist(pic_folder, 'dir')
            mkdir(pic_folder);
        end
        contour50ellip(par, colors(i_model,:), ...
        pic_folder,"model", labCh_ori);
        % plot_contour_with_scatter3D(par, lab_type, p_type, ...
        %     outputFolder,models(i_model));
        % plot_contour_with_scatter(par, lab_type, p_type); % 绘制拟合结果
        % exportgraphics(gcf, fullfile(outputFolder, strcat(models(i_model), '.jpg')), 'Resolution', 150); % 保存图像
        
        par_all{i_model} = par; % 保存拟合参数
        r_all{i_model} = r; % 保存残差
        parNr_all{i_model} = [par, r]; % 保存拟合参数和残差
    else
        par_all{i_model} = [];
        r_all{i_model} = [];
        parNr_all{i_model} = [];
    end
end

%% 保存拟合结果
save(fullfile(outputFolder, "fitRes_level.mat"), ...
    "models", "par_all", "r_all", "picname_cor_model");

%% 辅助函数：atan2d_360
function degree = atan2d_360(y, x)
    degree = atan2d(y, x);
    if degree < 0
        degree = degree + 360;
    end
end

%% 辅助函数：mapMatrixValues
function mappedMatrix = mapMatrixValues(matrix)
    mappedMatrix = matrix;
    [rows, cols] = size(matrix);
    for i = 1:rows
        for j = 1:cols
            if matrix(i,j) == -3
                mappedMatrix(i, j) = 1;
            elseif matrix(i,j) == -2
                mappedMatrix(i, j) = 2;
            elseif matrix(i,j) == -1
                mappedMatrix(i, j) = 3;
            elseif matrix(i,j) == 1
                mappedMatrix(i, j) = 4;
            elseif matrix(i,j) == 2
                mappedMatrix(i, j) = 5;
            elseif matrix(i,j) == 3
                mappedMatrix(i, j) = 6;
            end
        end
    end
end