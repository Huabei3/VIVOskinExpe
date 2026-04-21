addpath('..\');

%% 加载数据 - 支持任意波长范围
% 设定你的目标波长范围
lb = 400;    % 起始波长
step = 10;   % 步长
ub = 700;    % 终止波长

load cie1931xyz5nm.mat
range = (lb:step:ub);  % 如 400:10:700
cmfs_data = find_spd(cie1931xyz5nm, range);
cmfs_data = cmfs_data(:, 2:end);  % 去掉波长列，只保留XYZ

fprintf('CMF维度: %dx%d (波长范围: %d:%d:%d)\n', ...
    size(cmfs_data,1), size(cmfs_data,2), lb, step, ub);

reflectance_db_path = 'R_Types.mat';

%% 创建预测器
predictor = MultiIlluminantReflectancePredictor();
predictor = predictor.load_data(cmfs_data, reflectance_db_path);
%%
VIVO_table_folder="D:\work\VIVOskinExpe\analyze\AnalyseResults_p\efit_p\scaled\resTable";
VIVO_table_file=fullfile(VIVO_table_folder,"Peggy_VIVO_table.mat");
VIVO_table_data=load(VIVO_table_file);
VIVO_table=VIVO_table_data.fit_table;
%%
picnames_groups = ["H3K","H4K","H5K","H6K","HD65","H7K","H8K",...
        "M3K","M4K","M5K","M6K","MD65","M7K","M8K",...
         "L3K","L4K","L5K","L6K","LD65","L7K","L8K"];
folder_lightbox="D:\work\VIVOskinExpe\skin_projectV7\I_render_stimuli\lightbox\lightbox";
for i_light=1:length(picnames_groups)
    file_lightbox=fullfile(folder_lightbox,strcat(picnames_groups(i_light),".mat"));
    data_lightbox=load(file_lightbox);
    light_mat=[cell2mat(data_lightbox.DATAs(1,4))'];
    light_mat=[light_mat;cell2mat(data_lightbox.DATAs(2,4))'];
    light_mat=[light_mat;cell2mat(data_lightbox.DATAs(3,4))'];
    light_spd(i_light,:)=mean(light_mat,1);
    % disp("d")
end

%% 示例：N个光源下的XYZ目标和光谱
% 假设你已经有N种光照下的XYZ值和对应的光谱
% XYZ_targets_Nx3 = [你的N行XYZ数据];
% illu_ref_NxD = [你的N行光源光谱];

% 示例数据（D个波长点，由上面的lb:step:ub决定）
D = (ub - lb) / step + 1;  % 如31
n_illuminants = 7;

XYZ_targets_Nx3 = [
    50.1, 52.3, 48.7;
    48.5, 50.1, 46.2;
    52.3, 54.1, 50.5;
    49.8, 51.5, 47.9;
    51.2, 53.0, 49.3;
    47.9, 49.5, 45.8;
    53.1, 55.0, 51.2
];

% 示例光源光谱 (用D65作为示例)
illu_ref_NxD = repmat(linspace(0.5, 1, D), n_illuminants, 1);

% 每个光源的参考白XYZ（可选）
illu_XYZ_ref_white_Nx3 = repmat([94.811, 100.0, 107.304], n_illuminants, 1);

%% 调用多光源预测
Type_idx = 3; % 使用皮肤数据库
[RefP_out, results, mean_de00, opt_info] = predictor.predict_ref_multi(...
    XYZ_targets_Nx3, illu_ref_NxD, Type_idx, illu_XYZ_ref_white_Nx3);

%% 显示结果
fprintf('光谱维度 D = %d\n', opt_info.D);
fprintf('平均CIEDE2000: %.4f\n', mean_de00);
fprintf('\n每个光源下的色差:\n');
for i = 1:length(results)
    fprintf('  光源 %d: %.4f\n', i, results(i).de00);
end

%% 可视化
wavelengths = 400:10:700;
figure;
plot(wavelengths, RefP_out / 100, 'LineWidth', 2);
xlabel('Wavelength (nm)');
ylabel('Reflectance');
title(sprintf('Optimized Spectrum (Mean DE00 = %.4f)', mean_de00));
grid on;