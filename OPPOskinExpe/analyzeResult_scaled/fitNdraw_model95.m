close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量

%%

models = ["female1", "female2", "female3", "female4", "female5", ...
    "male1", "male2", "male3", "male4"];
num_models=length(models);
H = linspace(0, 1, num_models + 1); % 加1是为了避免最后一个值为1（和0重复）
H = H(1:end-1); % 去掉最后一个值
S = 0.8 * ones(1, num_models);
V = 0.8 * ones(1, num_models);
colors = hsv2rgb([H; S; V]');
lastParts = ["inLab", "indoorAdd", "nightAdd", "outdoorAdd", "sunsetAdd"];
escape = ["indoor05", "sunset01", "sunset02", "sunset03", "sunset08"];
% Dtype = "OPPO_CAT16";
Dtype = "efit_p";
scale_type="scaled";
if strcmp(Dtype,"efit_p")
    sourceFolder='AnalyseResults_p\abs';
else
    sourceFolder='AnalyseResults';
end
load("OPPOskin\matchTable_map.mat", "match_table_map");
% load("OPPOskin\matchTable.mat", "match_table");
lab_model = cell(length(models), 1); 
picname_cor_model = cell(length(models), 1);
ori_labs_model= cell(length(models), 1);
for i_model = 1:length(models)
    lab_model{i_model} = [];
    picname_cor_model{i_model} = [];
end

% 分类保存数据
for i_lastPart = 1:length(lastParts)
    lastPart = lastParts(i_lastPart);
    source_folder = fullfile(sourceFolder, Dtype, lastPart, 'ellipPara_scaled');
    source_file = fullfile(source_folder, "fitRes_level.mat");
    fit_data = load(source_file);
    % 提取数据
    n_render = 49;
    rows_used = 49:n_render:size(fit_data.lab_group_all, 1);
    ori_labs = fit_data.lab_group_all(rows_used, :);
    picname_check = fit_data.picname_check(:, 1);
    par_ind = fit_data.par_ind;

    lab_group = fit_data.par_ind(:, 5:7);
    %-------------convert to PMCC white---------------
    datai_file = '..\display_calibration\datai_sorted40_3.mat';
    XYZw=load(datai_file);
    XYZw=XYZw.XYZw;
    XYZw_scaled=XYZw./XYZw(2).*wd65(2);
    [xyz_group] = lab2xyz2(lab_group,'user',XYZw_scaled);
    wd65=[94.811 100.00 107.304];

    if strcmp(scale_type,"scaled")
        wd65_scaled=wd65.*XYZ_gray(i_match,2)./XYZw(2);
    elseif strcmp(lightness_type,"unscaled")
        wd65_scaled=wd65;
    end
    [lab_group] = xyz2lab(xyz_group,'user',wd65_scaled);
    %-------------end convert to PMCC white---------------
    
    for i_para = 1:size(par_ind, 1)
        current_picname = picname_check{i_para, 1}; % 当前图片名称
        if isKey(match_table_map, current_picname) 
            matched_model = match_table_map(current_picname); % 获取匹配的模特名称

            for i_model = 1:length(models)
                if contains(matched_model, models(i_model)) && ~ismember(current_picname, escape)
                    lab_model{i_model} = [lab_model{i_model}; lab_group(i_para, :)];
                    ori_labs_model{i_model} = [ori_labs_model{i_model}; ori_labs(i_para, :)];
                    picname_cor_model{i_model} = [picname_cor_model{i_model}; string(current_picname)];
                    break; % 找到匹配的模特后退出循环
                end
            end
        end
    end
end



% 遍历每个模特，绘制散点图并拟合椭圆
for i_model = 1:length(models)
    lab_used = lab_model{i_model};
    if ~isempty(lab_used)
        color=colors(i_model,:);
        % 绘制散点图
        scatter(lab_used(:, 2), lab_used(:, 3), ...
            'filled', 'MarkerEdgeColor', colors(i_model, :), ...
            'MarkerFaceColor', colors(i_model, :));
        
        % 拟合椭圆
        disp(models(i_model))
        if size(lab_used,1)>=3
            [center, mu, chi2_val, List, cov_mat, cov_mat_r] = fit95ellip_my(lab_used, 0.05, 3);
        else            
            center=mean(lab_used,1);
            mu = -inf;chi2_val = -inf;List = -inf;cov_mat = -inf;cov_mat_r = -inf;
        end
        centers_all(i_model,:)=center;
        
        
        % 保存参数
        save_folder = fullfile(sourceFolder, Dtype, 'models', '95');
        output_folder = fullfile(save_folder, 'ellipPara');
        if ~exist(output_folder, 'dir')
            mkdir(output_folder);
        end
        save(fullfile(output_folder, strcat(models(i_model), "fitRes_level.mat")), ...
            'center', 'mu', 'List');
        
        % 计算色差
        dE_mat = zeros(size(lab_used, 1));
        for i_para = 1:size(lab_used, 1)
            for j_para = 1:size(lab_used, 1)
                dE_mat(i_para, j_para) = deltaE2000(lab_used(i_para, :), lab_used(j_para, :));
            end
        end
        dE_intra{i_model, 1} = dE_mat;
        dE_mat(dE_mat == 0) = NaN;
        dE_intra_mean(i_model, 1) = nanmean(nanmean(dE_mat));
        
        % 保存椭圆图像
        output_folder = fullfile(save_folder, 'ellipsoid_sections');
        if ~exist(output_folder, 'dir')
            mkdir(output_folder);
        end
        if i_model==length(models)
            disp("d")
        end
        contour95ellip(center, mu, lab_used, chi2_val, ...
            output_folder, models(i_model), colors(i_model, :), ...
            "models",mean(ori_labs_model{i_model},1));

    end
end


concatenate_images1(output_folder,3);
% 保存结果
output_folder = fullfile(sourceFolder, Dtype, 'models', ...
    '95', 'ellipsoid_sections');
save(fullfile(output_folder, strcat("dE.mat")), ...
    'dE_intra', 'dE_intra_mean');


%% 计算dE
center_labels=centers_all;
for i_label=1:length(models)
    for j_label=1:length(models)
        dE_inter95(i_label,j_label)=...
            deltaE2000([center_labels(i_label,:)], ...
            [center_labels(j_label,:)]);
    end
end
dE_inter95(dE_inter95 == 0) = NaN;
dE_inter95_mean=nanmean(nanmean(dE_inter95));


dE{1,1}="dE_inter95";dE{1,2}="dE_intra";
dE{2,1}=dE_inter95_mean;dE{2,2}=mean(dE_intra_mean);
save(fullfile(output_folder, strcat("dE.mat")), ...
    'dE_intra', 'dE_intra_mean',"dE_inter95", ...
    "center_labels","dE_inter95_mean");
%%
% 提取每个模特的labCh五个维度
labCh_model = cell(length(models), 1);
for i_model = 1:length(models)
    lab_model_data = lab_model{i_model};
    labCh_model{i_model} = [lab_model_data, sqrt(sum(lab_model_data(:,2:3).^2, 2)), atan2d(lab_model_data(:,3), lab_model_data(:,2))];
end

% 定义维度名称
dimension_names = {'L*', 'a*', 'b*', 'C', 'h'};

% 创建输出文件夹
output_folder = fullfile(sourceFolder, Dtype, 'models', 'Nonparametric_Test');
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end

% 初始化check变量
check = cell(5, length(models)^2 + 1); % 每行对应一个维度，每列对应不同的统计结果

% 对每个维度进行Mann-Whitney U检验
for i_dim = 1:5
    % 提取当前维度的数据
    data_all = [];
    for i_model = 1:length(models)
        data_all = [data_all; labCh_model{i_model}(:, i_dim)];
    end
    
    % 进行Mann-Whitney U检验
    p_values_mannwhitney = zeros(length(models), length(models));
    for i_model1 = 1:length(models)
        for i_model2 = i_model1+1:length(models)
            [p_mannwhitney, ~] = ranksum(labCh_model{i_model1}(:, i_dim), labCh_model{i_model2}(:, i_dim));
            p_values_mannwhitney(i_model1, i_model2) = p_mannwhitney;
            p_values_mannwhitney(i_model2, i_model1) = p_mannwhitney;
        end
    end
    check{i_dim, 1} = dimension_names{i_dim}; % 维度名称
    
    % 逐个单元格保存Mann-Whitney U检验的p值
    idx = 2; % 从第二列开始保存p值
    for i_model1 = 1:length(models)
        for i_model2 = i_model1+1:length(models)
            check{i_dim, idx} = p_values_mannwhitney(i_model1, i_model2);
            idx = idx + 1;
        end
    end
    

end

% 保存check结果
output_folder = fullfile(sourceFolder, Dtype, 'models', 'Nonparametric_Test');
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end
save(fullfile(output_folder, 'check_results_models.mat'), 'check');
