%% check_fidelity_data.m — 检查 Fidelity 的 theta/alpha 为什么是 NaN
clear; clc;

mat_path = 'D:\work\VIVOskinExpe\analyze\AnalyseResults_p\efit_p\unscaled\model_fullpara\d65\new\i\non_model\07Fidelity_all_curve_params.mat';
load(mat_path);

nation_names = {'AS(亚洲人)', 'CA(高加索人)', 'SA(南亚人)', 'AF(非洲人)', 'all(混合人种)'};

fprintf('========== a_theta_all ==========\n');
disp(size(a_theta_all));
for i = 1:size(a_theta_all, 1)
    fprintf('%s: ', nation_names{i});
    fprintf('%f ', a_theta_all(i, :));
    fprintf('\n');
end

fprintf('\n========== a_alpha_all ==========\n');
disp(size(a_alpha_all));
for i = 1:size(a_alpha_all, 1)
    fprintf('%s: ', nation_names{i});
    fprintf('%f ', a_alpha_all(i, :));
    fprintf('\n');
end

fprintf('\n========== rmse_theta_all ==========\n');
if exist('rmse_theta_all', 'var')
    disp(rmse_theta_all');
else
    fprintf('NOT IN FILE\n');
end

fprintf('\n========== rmse_alpha_all ==========\n');
if exist('rmse_alpha_all', 'var')
    disp(rmse_alpha_all');
else
    fprintf('NOT IN FILE\n');
end

% 检查所有 attributes 的 theta/alpha 是否也有同样问题
fprintf('\n========== 所有 attribute 的 theta/alpha AF/all 检查 ==========\n');
ATTR_NAMES = ["Preference", "Attractiveness", "Feminine", "Cooperative", ...
              "Youth", "Healthy", "Fidelity", "Harmony", "Fair", "Ruddy"];
SOURCE = 'D:\work\VIVOskinExpe\analyze\AnalyseResults_p\efit_p\unscaled\model_fullpara\d65\new\i\non_model';
for i_attr = 1:length(ATTR_NAMES)
    mat_file = fullfile(SOURCE, sprintf('%02d%s_all_curve_params.mat', i_attr, ATTR_NAMES(i_attr)));
    if ~exist(mat_file, 'file')
        fprintf('%s: FILE NOT FOUND\n', ATTR_NAMES(i_attr));
        continue;
    end
    d = load(mat_file);
    theta_val = d.a_theta_all(4, 1);  % AF
    alpha_val = d.a_alpha_all(4, 1);
    fprintf('%s: theta_AF=%.2f, alpha_AF=%.2f\n', ATTR_NAMES(i_attr), theta_val, alpha_val);
end
