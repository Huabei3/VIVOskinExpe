% 检查 n_drop_params 结构体
addpath("utils\");
close all; clc;

output_mat_folder = fullfile("D:\work\VIVOskinExpe\analyze\AnalyseResults_p\efit_p\unscaled\model_fullpara", ...
    "d65\new\i\non_model\1_drop");

nations = ["AS", "CA", "SA", "AF", "all"];
attribute_names = ["Preference", "Attractiveness", "Feminine", "Cooperative", ...
    "Youth", "Healthy", "Fidelity", "Harmony", "Fair", "Ruddy"];

for i_n = 1:length(nations)
    nation = nations(i_n);
    mat_file = fullfile(output_mat_folder, sprintf("%s_n_drop1.mat", nation));
    if exist(mat_file, 'file')
        fprintf('\n=== %s ===\n', nation);
        data = load(mat_file);
        subjects = fieldnames(data);
        fprintf('受试者数量: %d\n', length(subjects));
        for i_subj = 1:length(subjects)
            subj = subjects{i_subj};
            attrs = fieldnames(data.(subj));
            fprintf('  %s: 属性数量 %d\n', subj, length(attrs));
            % 检查每个属性的 a_C_L
            for i_attr = 1:length(attrs)
                attr = attrs{i_attr};
                a_C_L = data.(subj).(attr).a_C_L;
                if any(isnan(a_C_L))
                    fprintf('    %s: a_C_L = [%f, %f] (包含NaN)\n', attr, a_C_L(1), a_C_L(2));
                end
            end
        end
    else
        fprintf('\n=== %s: 文件不存在 ===\n', nation);
    end
end