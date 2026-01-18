close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量

%% 初始化
models = ["female1", "female2", "female3", "female4", "female5", ...
    "male1", "male2", "male3", "male4"];
lastParts = ["inLab", "indoorAdd", "nightAdd", "outdoorAdd", "sunsetAdd"];
wd65 = [94.811 100.00 107.304];

Dtype = "OPPO_CAT16";
output_folder = fullfile('AnalyseResults', Dtype);
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end

%% 加载数据并分类，然后对每个 model + lastPart 组合进行拟合
load("OPPOskin\matchTable.mat", "match_table");

% Initialize storage for fitting results per model and lastPart
par_all_per_scene = cell(length(models), length(lastParts)); % Ellipse parameters
r_all_per_scene = cell(length(models), length(lastParts));   % Residuals
picname_cor_model_per_scene = cell(length(models), length(lastParts)); % Corresponding picture names
% --- 对每个 model + current lastPart 组合进行椭圆拟合 ---
outputFolder_ellipPara = fullfile(output_folder, 'ellipPara_scaled',"scene_ind");
if ~exist(outputFolder_ellipPara, 'dir')
    mkdir(outputFolder_ellipPara);
end
for i_lastPart = 1:length(lastParts)
    lastPart = lastParts(i_lastPart);
    directory = fullfile('ExperimentResult', lastPart);
    dir_res = dir(fullfile(directory, '*.csv'));
    n_file = length(dir_res);

    % Initialize storage for current lastPart
    lab_current_lastPart = cell(length(models), 1);
    MSV_current_lastPart = cell(length(models), 1);
    picname_cor_current_lastPart = cell(length(models), 1);

    for i_model = 1:length(models)
        lab_current_lastPart{i_model} = [];
        MSV_current_lastPart{i_model} = [];
        picname_cor_current_lastPart{i_model} = [];
    end

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

    % 遍历每个分组，加载数据并分类到当前 lastPart 的模特组
    for i_group = 1:length(picname_groups)
        group_name = picname_groups(i_group);
        outputFolder_labNscore = fullfile(output_folder, lastPart, 'labNscore');
        if ~exist(outputFolder_labNscore, 'dir')
            mkdir(outputFolder_labNscore);
        end

        % 加载分组数据
        dir_groupfile = dir(fullfile(outputFolder_labNscore, ...
            strcat("labNscore_groupAdd", group_name, ".mat")));

        if ~isempty(dir_groupfile)
            load(fullfile(dir_groupfile(1).folder, dir_groupfile(1).name));
            picname_check = strrep(dir_groupfile(1).name(1:end-4), "labNscore_groupAdd", "");

            % 找到对应的模特
            model_name = '';
            for i_match = 1:size(match_table, 1) % Use size(match_table, 1) for rows
                if strcmp(picname_check, match_table{i_match, 1})
                    model_name = match_table{i_match,3};
                    break;
                end
            end

            % 分类保存到当前 lastPart 对应的模特组
            if ~isempty(model_name)
                for i_model = 1:length(models)
                    if contains(model_name, models(i_model))
                        lab_current_lastPart{i_model} = [lab_current_lastPart{i_model}; lab_group];
                        MSV_current_lastPart{i_model} = [MSV_current_lastPart{i_model}; MSV_scaled_group];
                        picname_cor_current_lastPart{i_model} = [picname_cor_current_lastPart{i_model}; picname_check];
                        break;
                    end
                end
            end
        end
    end



    for i_model = 1:length(models)
        lab_type = lab_current_lastPart{i_model};
        MSV_type = MSV_current_lastPart{i_model};

        if ~isempty(lab_type) && ~isempty(MSV_type)
            cen = calculate_weighted_or_simple_mean(MSV_type,lab_type);
            [par, r, y] = my_ellipsoidfit_withL(lab_type, MSV_type,cen); % 拟合椭圆
            figure; % Create a new figure for each plot
            plot_contour_with_scatter(par, lab_type, MSV_type); % 绘制拟合结果
            title(sprintf('%s - %s', models(i_model), lastPart)); % Add title
            exportgraphics(gcf, fullfile(outputFolder_ellipPara, strcat(models(i_model), '_', lastPart, '.jpg')), 'Resolution', 150); % 保存图像
            close(gcf); % Close the figure after saving
            MSV_type_per_scene{i_model, i_lastPart} = MSV_type;
            lab_type_per_scene{i_model, i_lastPart} = lab_type;
            par_all_per_scene{i_model, i_lastPart} = par; % 保存拟合参数
            r_all_per_scene{i_model, i_lastPart} = r;     % 保存残差
            picname_cor_model_per_scene{i_model, i_lastPart} = picname_cor_current_lastPart{i_model}; % 保存图片名称
        else
            MSV_type_per_scene{i_model, i_lastPart} = MSV_type;
            lab_type_per_scene{i_model, i_lastPart} = lab_type;
            par_all_per_scene{i_model, i_lastPart} = [];
            r_all_per_scene{i_model, i_lastPart} = [];
            picname_cor_model_per_scene{i_model, i_lastPart} = [];
        end
    end


end
% Save results for the current lastPart
save(fullfile(outputFolder_ellipPara, strcat("fitRes_level_.mat")), ...
    "par_all_per_scene", "r_all_per_scene", "picname_cor_model_per_scene", ...
    "MSV_type_per_scene","lab_type_per_scene"); % Save combined for all models for current lastPart
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