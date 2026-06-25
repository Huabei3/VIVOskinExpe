% 直接检查 fitRes.mat 文件内容
close all; clc; clear;

% 检查一个具体的 fitRes.mat 文件
file_path = fullfile('AnalyseResults_p\efit_p\unscaled\f04i\non_model\01Preference\ellipPara', 'fitRes.mat');

if exist(file_path, 'file')
    fprintf('检查文件: %s\n', file_path);
    
    % 加载文件
    data = load(file_path);
    
    % 检查所有字段
    fprintf('文件包含的字段:\n');
    fields = fieldnames(data);
    for i = 1:length(fields)
        fprintf('  %s\n', fields{i});
    end
    
    % 检查 par_all
    if isfield(data, 'par_all')
        par_all = data.par_all;
        fprintf('\npar_all 大小: %s\n', mat2str(size(par_all)));
        fprintf('par_all 数据类型: %s\n', class(par_all));
        
        % 检查每一列
        for col = 1:size(par_all, 2)
            col_data = par_all(:, col);
            fprintf('  第%d列: NaN数量=%d, Inf数量=%d, 范围=[%.6f, %.6f]\n', ...
                col, sum(isnan(col_data)), sum(isinf(col_data)), ...
                min(col_data(~isnan(col_data) & ~isinf(col_data))), ...
                max(col_data(~isnan(col_data) & ~isinf(col_data))));
        end
        
        % 详细检查第6列（alpha相关）
        fprintf('\n详细检查第6列（用于计算alpha）:\n');
        col6 = par_all(:, 6);
        valid_idx = ~isnan(col6) & ~isinf(col6);
        fprintf('  有效值数量: %d/%d\n', sum(valid_idx), length(col6));
        if any(valid_idx)
            fprintf('  有效值范围: [%.10f, %.10f]\n', min(col6(valid_idx)), max(col6(valid_idx)));
            fprintf('  有效值前10个:');
            for i = 1:min(10, sum(valid_idx))
                idx = find(valid_idx, i, 'first');
                fprintf(' %.10f', col6(idx(i)));
            end
            fprintf('\n');
            
            % 检查是否 <= 0
            non_positive = col6 <= 0;
            fprintf('  非正值（<=0）数量: %d/%d\n', sum(non_positive & valid_idx), sum(valid_idx));
            
            % 检查是否接近0
            near_zero = abs(col6) < 1e-10;
            fprintf('  接近0（<1e-10）数量: %d/%d\n', sum(near_zero & valid_idx), sum(valid_idx));
        end
        
        % 计算 alpha = -log(par_all(:,6))
        fprintf('\n计算 alpha = -log(par_all(:,6)):\n');
        alpha = -log(col6);
        valid_alpha_idx = ~isnan(col6) & ~isinf(col6) & col6 > 0;
        fprintf('  可计算alpha的有效值数量: %d/%d\n', sum(valid_alpha_idx), length(col6));
        if any(valid_alpha_idx)
            alpha_valid = alpha(valid_alpha_idx);
            fprintf('  alpha有效值范围: [%.6f, %.6f]\n', min(alpha_valid), max(alpha_valid));
        end
    else
        fprintf('没有 par_all 字段\n');
    end
else
    fprintf('文件不存在: %s\n', file_path);
end

% 再检查几个其他文件
fprintf('\n=== 检查其他几个文件 ===\n');
test_files = {
    fullfile('AnalyseResults_p\efit_p\unscaled\f05i\non_model\01Preference\ellipPara', 'fitRes.mat'),
    fullfile('AnalyseResults_p\efit_p\unscaled\f06i\non_model\01Preference\ellipPara', 'fitRes.mat'),
    fullfile('AnalyseResults_p\efit_p\unscaled\m04i\non_model\01Preference\ellipPara', 'fitRes.mat')
};

for f = 1:length(test_files)
    file = test_files{f};
    if exist(file, 'file')
        data = load(file);
        if isfield(data, 'par_all')
            par_all = data.par_all;
            col6 = par_all(:, 6);
            valid_idx = ~isnan(col6) & ~isinf(col6);
            non_positive = col6 <= 0;
            fprintf('%s: 有效值=%d/%d, 非正值=%d/%d\n', ...
                fileparts(fileparts(fileparts(fileparts(file)))), ...
                sum(valid_idx), length(col6), sum(non_positive & valid_idx), sum(valid_idx));
        end
    else
        fprintf('%s: 文件不存在\n', fileparts(fileparts(fileparts(fileparts(file)))));
    end
end