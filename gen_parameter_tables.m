%% gen_parameter_tables.m
% 从 *_all_curve_params.mat 提取参数，按草稿5.3格式生成 xlsx
% 每个 attribute 一个 sheet
% v2: θ 值执行 mod(theta+90,360) 调整；数字保留2位小数；
%     参数块间不空行；用 writecell 写 xlsx（'Sheet' 参数追加 sheet）
% 用法: 在 MATLAB 命令行运行:  gen_parameter_tables

clear; clc;

SOURCE = 'D:\work\VIVOskinExpe\analyze\AnalyseResults_p\efit_p\unscaled\model_fullpara\d65\new\i\non_model';
OUT_DIR = fullfile(SOURCE, 'parameters_table');
if ~exist(OUT_DIR, 'dir')
    mkdir(OUT_DIR);
end
OUT_FILE = fullfile(OUT_DIR, 'all_parameters.xlsx');

ATTR_NAMES = ["Preference", "Attractiveness", "Feminine", "Cooperative", ...
              "Youth", "Healthy", "Fidelity", "Harmony", "Fair", "Ruddy"];
NATION_NAMES = {'亚洲人', '高加索人', '南亚人', '非洲人', '混合人种'};
N_NATIONS = 5;

% 参数块定义: {mat_key_prefix, display_name, n_params, has_model, is_angular}
% is_angular=true 时对该参数执行 mod(theta+90,360)
PARAM_BLOCKS = {
    {'CL',         'C*_ab', 2, true,  false};
    {'long_axis',  'a_maj', 4, true,  false};
    {'short_axis', 'b_min', 4, true,  false};
    {'hue_angle',  'h_ab',  1, false, false};
    {'theta',      'theta',  1, false, true };
    {'alpha',      'alpha',  1, false, false};
};

fprintf('开始生成 %s ...\n', OUT_FILE);

% === 先删除目标文件（writecell 第一次调用会创建文件）===
if exist(OUT_FILE, 'file')
    delete(OUT_FILE);
    fprintf('已删除旧文件\n');
end

% 用于收集 NaN 报告
nan_report = {};

for i_attr = 1:length(ATTR_NAMES)
    attr_name = char(ATTR_NAMES(i_attr));
    mat_file = fullfile(SOURCE, sprintf('%02d%s_all_curve_params.mat', i_attr, attr_name));
    if ~exist(mat_file, 'file')
        fprintf('WARNING: %s not found, skipping\n', mat_file);
        continue;
    end
    
    % 加载数据
    d = load(mat_file);
    
    % 构建当前 sheet 的 cell 数组
    sheet_data = cell(50, N_NATIONS + 1);
    
    row = 1;
    % 第1行: 空 + nation 名称
    sheet_data{row, 1} = '';
    for j = 1:N_NATIONS
        sheet_data{row, j+1} = NATION_NAMES{j};
    end
    
    row = 2;
    for b = 1:size(PARAM_BLOCKS, 1)
        block_key  = PARAM_BLOCKS{b}{1};
        block_disp = PARAM_BLOCKS{b}{2};
        n_params   = PARAM_BLOCKS{b}{3};
        has_model  = PARAM_BLOCKS{b}{4};
        is_angular = PARAM_BLOCKS{b}{5};
        
        a_key   = sprintf('a_%s_all', block_key);
        r_key   = sprintf('r_%s_all', block_key);
        rmse_key = sprintf('rmse_%s_all', block_key);
        
        if ~isfield(d, a_key)
            fprintf('  WARNING: %s not found in %s, skipping block %s\n', a_key, mat_file, block_key);
            continue;
        end
        
        a_all = d.(a_key);
        
        % 收集 NaN 信息
        for ni = 1:size(a_all, 1)
            if all(isnan(a_all(ni, :)))
                nan_report{end+1} = sprintf('%s x %s: a_%s_all 全为 NaN', attr_name, NATION_NAMES{ni}, block_key);
            end
        end
        
        if isfield(d, r_key)
            r_all = d.(r_key);
        else
            r_all = nan(size(a_all, 1), 1);
        end
        if isfield(d, rmse_key)
            rmse_all = d.(rmse_key);
        else
            rmse_all = nan(size(a_all, 1), 1);
        end
        
        % --- θ 角度调整: mod(theta+90, 360) ---
        if is_angular
            for ni = 1:size(a_all, 1)
                for pj = 1:size(a_all, 2)
                    if ~isnan(a_all(ni, pj))
                        a_all(ni, pj) = mod(a_all(ni, pj) + 90, 360);
                    end
                end
            end
        end
        
        % 参数块标题行
        sheet_data{row, 1} = block_disp;
        row = row + 1;
        
        if has_model
            % a1, a2, ..., aN
            for p = 1:n_params
                sheet_data{row, 1} = sprintf('a%d', p);
                for j = 1:N_NATIONS
                    val = a_all(j, p);
                    if isnan(val)
                        sheet_data{row, j+1} = '--';
                    else
                        sheet_data{row, j+1} = round(val, 2);
                    end
                end
                row = row + 1;
            end
            % r 行
            sheet_data{row, 1} = 'r';
            for j = 1:N_NATIONS
                val = r_all(j);
                if isnan(val)
                    sheet_data{row, j+1} = '--';
                else
                    sheet_data{row, j+1} = round(val, 2);
                end
            end
            row = row + 1;
            % rmse 行
            sheet_data{row, 1} = 'rmse';
            for j = 1:N_NATIONS
                val = rmse_all(j);
                if isnan(val)
                    sheet_data{row, j+1} = '--';
                else
                    sheet_data{row, j+1} = round(val, 2);
                end
            end
            row = row + 1;
        else
            % 标量参数: 只有一行"平均值"
            sheet_data{row, 1} = '平均值';
            for j = 1:N_NATIONS
                val = a_all(j, 1);
                if isnan(val)
                    sheet_data{row, j+1} = '--';
                else
                    sheet_data{row, j+1} = round(val, 2);
                end
            end
            row = row + 1;
        end
        % 参数块之间不空行
    end
    
    % 裁剪
    sheet_data = sheet_data(1:row-1, :);
    
    % 安全处理：确保 NaN 全部替换为 '--'（防止 cell 数组中残留数值 NaN）
    for r = 1:size(sheet_data, 1)
        for c = 1:size(sheet_data, 2)
            if iscell(sheet_data) && isnumeric(sheet_data{r, c}) && isnan(sheet_data{r, c})
                sheet_data{r, c} = '--';
            end
        end
    end
    
    % 写入 xlsx（用 writecell + 'Sheet' 参数追加 sheet）
    % writecell 在文件已存在时，指定 'Sheet' 会创建新 sheet 而不覆盖已有 sheet
    writecell(sheet_data, OUT_FILE, 'Sheet', attr_name);
    
    fprintf('Sheet "%s" done (%d rows)\n', attr_name, row-1);
end

fprintf('\n完成！文件保存在:\n  %s\n', OUT_FILE);

% === 报告 NaN 情况 ===
if ~isempty(nan_report)
    fprintf('\n========== NaN 参数报告 ==========\n');
    for k = 1:length(nan_report)
        fprintf('  %s\n', nan_report{k});
    end
else
    fprintf('\n所有参数均无 NaN。\n');
end
