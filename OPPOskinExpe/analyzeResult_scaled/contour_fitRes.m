    

close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量

%% 设置参数和文件夹路径
Dtype = "OPPO_CAT16";
output_folder = fullfile('AnalyseResults', Dtype, 'combined_plots');
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end

%%

gender_folder = fullfile('AnalyseResults', Dtype, 'gender', '95', 'ellipPara');
female_file = fullfile(gender_folder, 'ffitRes_level.mat');
male_file = fullfile(gender_folder, 'mfitRes_level.mat');

if exist(female_file, 'file') && exist(male_file, 'file')
    female_data = load(female_file);
    male_data = load(male_file);
    gender_centers = [female_data.center; male_data.center];
    fprintf('已加载性别中心数据\n');
else
    warning('性别中心数据文件不存在');
end



makeup_folder = fullfile('AnalyseResults', Dtype, 'makeup', '95', 'ellipPara');
fm_file = fullfile(makeup_folder, 'fmfitRes_level.mat');
fn_file = fullfile(makeup_folder, 'fnfitRes_level.mat');

if exist(fm_file, 'file') && exist(fn_file, 'file')
    fm_data = load(fm_file);
    fn_data = load(fn_file);
    makeup_centers = [fm_data.center; fn_data.center];
    fprintf('已加载妆容中心数据\n');
else
    warning('妆容中心数据文件不存在');
end




model_folder = fullfile('AnalyseResults', Dtype, 'models', '95', 'ellipPara');
models = {'female1', 'female2', 'female3', 'female4', 'female5', 'male1', 'male2', 'male3', 'male4'};
model_centers = [];

for i = 1:length(models)
    model_file = fullfile(model_folder, [models{i}, 'fitRes_level.mat']);
    if exist(model_file, 'file')
        model_data = load(model_file);
        model_centers = [model_centers; model_data.center];
    end
end



scene_folder = fullfile('AnalyseResults', Dtype, 'scene1', '95', 'rela', 'ellipPara');
scenes = {'inLab', 'indoorAdd', 'nightAdd', 'outdoorAdd', 'sunsetAdd'};
scene_centers = [];

for i = 1:length(scenes)
    scene_file = fullfile(scene_folder, [scenes{i}, 'fitRes_level.mat']);
    if exist(scene_file, 'file')
        scene_data = load(scene_file);
        scene_centers = [scene_centers; scene_data.center];
    end
end

combined_centers=[gender_centers;makeup_centers;model_centers;scene_centers];

% 确定各类别的数据范围
gender_count = size(gender_centers, 1);
makeup_count = size(makeup_centers, 1);
model_count = size(model_centers, 1);
scene_count = size(scene_centers, 1);

% 创建颜色数组
total_count = size(combined_centers, 1);
if total_count > 0
    H = linspace(0, 1, total_count + 1); % 加1是为了避免最后一个值为1（和0重复）
    H = H(1:end-1); % 去掉最后一个值
    S = 0.8 * ones(1, total_count);
    V = 0.8 * ones(1, total_count);
    colors = hsv2rgb([H; S; V]');
    
    % 定义每个类别的plot_style
    plot_styles = cell(total_count, 1);
    plot_styles(1:gender_count) = {'o'}; % gender使用圆形标记
    plot_styles(gender_count+1:gender_count+makeup_count) = {'^'}; % makeup使用三角形标记
    plot_styles(gender_count+makeup_count+1:gender_count+makeup_count+model_count) = {'s'}; % model使用方形标记
    plot_styles(gender_count+makeup_count+model_count+1:end) = {'d'}; % scene使用菱形标记
    
    % 定义显示名称
    display_names = cell(total_count, 1);
    if gender_count >= 1, display_names{1} = '女性'; end
    if gender_count >= 2, display_names{2} = '男性'; end
    if makeup_count >= 1, display_names{gender_count+1} = '化妆女性'; end
    if makeup_count >= 2, display_names{gender_count+2} = '未化妆女性'; end
    for i = 1:model_count
        display_names{gender_count+makeup_count+i} = ['模特', num2str(i)];
    end
    scene_names = {'实验室', '室内', '夜晚', '户外', '日落'};
    for i = 1:min(scene_count, length(scene_names))
        display_names{gender_count+makeup_count+model_count+i} = scene_names{i};
    end
else
    warning('没有可用的中心数据进行绘图');
end

%% 绘制组合图表
% 绘制a*b*图
figure;
grid on; box on; hold on;
axis equal;
title('各类别中心值对比 (a*-b*)', 'FontSize', 14);
xlabel('a*', 'FontSize', 12);
ylabel('b*', 'FontSize', 12);

% 使用combined_centers统一绘图，按类别使用不同的plot_style
if exist('combined_centers', 'var') && ~isempty(combined_centers) && exist('colors', 'var') && exist('plot_styles', 'var')
    for i_row = 1:size(combined_centers, 1)
        if i_row <= length(display_names) && ~isempty(display_names{i_row})
            name = display_names{i_row};
        else
            name = ['数据点', num2str(i_row)];
        end
        plot(combined_centers(i_row, 2), combined_centers(i_row, 3), plot_styles{i_row}, ...
             'MarkerSize', 10, 'MarkerFaceColor', colors(i_row,:), 'DisplayName', name);
    end
    legend('show', 'Location', 'Best');
else
    warning('缺少必要的数据或样式信息，无法绘制a-b图');
end


% axis padded: 调整坐标轴范围，为图形添加内边距，确保所有数据点和标记完整显示
axis padded;
saveas(gcf, fullfile(output_folder, 'combined_a_b.png'), 'png');

% 绘制L*C*图
figure;
grid on; box on; hold on;
axis equal;
title('各类别中心值对比 (L*-C*)', 'FontSize', 14);
xlabel('C*', 'FontSize', 12);
ylabel('L*', 'FontSize', 12);

% 计算C值并使用combined_centers统一绘图
if exist('combined_centers', 'var') && ~isempty(combined_centers) && exist('colors', 'var') && exist('plot_styles', 'var')
    combined_C = sqrt(combined_centers(:,2).^2 + combined_centers(:,3).^2);
    for i_row = 1:size(combined_centers, 1)
        if i_row <= length(display_names) && ~isempty(display_names{i_row})
            name = display_names{i_row};
        else
            name = ['数据点', num2str(i_row)];
        end
        plot(combined_C(i_row), combined_centers(i_row, 1), plot_styles{i_row}, ...
             'MarkerSize', 10, 'MarkerFaceColor', colors(i_row,:), 'DisplayName', name);
    end
    legend('show', 'Location', 'Best');
else
    warning('缺少必要的数据或样式信息，无法绘制L-C图');
end


% axis padded: 调整坐标轴范围，为图形添加内边距，确保所有数据点和标记完整显示
axis padded;
saveas(gcf, fullfile(output_folder, 'combined_L_C.png'), 'png');

% 绘制L*h*图
figure;
grid on; box on; hold on;
title('各类别中心值对比 (L*-h*)', 'FontSize', 14);
xlabel('h* (角度)', 'FontSize', 12);
ylabel('L*', 'FontSize', 12);

% 计算h值并使用combined_centers统一绘图
if exist('combined_centers', 'var') && ~isempty(combined_centers) && exist('colors', 'var') && exist('plot_styles', 'var')
    combined_h = atan2d(combined_centers(:,3), combined_centers(:,2));
    % 转换为0-360度
    combined_h(combined_h < 0) = combined_h(combined_h < 0) + 360;
    
    for i_row = 1:size(combined_centers, 1)
        if i_row <= length(display_names) && ~isempty(display_names{i_row})
            name = display_names{i_row};
        else
            name = ['数据点', num2str(i_row)];
        end
        plot(combined_h(i_row), combined_centers(i_row, 1), plot_styles{i_row}, ...
             'MarkerSize', 10, 'MarkerFaceColor', colors(i_row,:), 'DisplayName', name);
    end
    legend('show', 'Location', 'Best');
else
    warning('缺少必要的数据或样式信息，无法绘制L-h图');
end


% axis padded: 调整坐标轴范围，为图形添加内边距，确保所有数据点和标记完整显示
axis padded;
saveas(gcf, fullfile(output_folder, 'combined_L_h.png'), 'png');

fprintf('组合图表已保存到 %s\n', output_folder);


