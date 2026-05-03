%% gen_BIC_tables.m
%  为 BIC 文件夹下每个 formula 生成参数表格 xlsx
%  每个 formula 一个 xlsx，每个 attribute 一个 sheet
%  参照论文附录3格式：行=人种，列=参数

clc; clear;

%% ========== 配置 ==========
base_BIC_folder = 'D:\work\VIVOskinExpe\analyze\AnalyseResults_p\efit_p\unscaled\model_fullpara\d65\new\i\non_model\BIC';

formula_names = {"Constant", "Linear", "Quadratic", "Logarithmic", "Piecewise-Lin-Con"};
% 每个 formula 的参数名（根据 model_C_L_BIC.m 的 case 编号）
% 1=Constant:      a1
% 2=Linear:        a1, a2
% 3=Quadratic:     a1, a2, a3
% 4=Logarithmic:   a1, a2
% 5=Piecewise:      a1, a2, a3, L0
param_names_cell = {
    {'a1'};
    {'a1', 'a2'};
    {'a1', 'a2', 'a3'};
    {'a1', 'a2'};
    {'a1', 'a2', 'a3', 'L0'}
};

nations_long = {'Asian (AS)', 'Caucasian (CA)', 'South Asian (SA)', 'African (AF)', 'All'};

attributes = [1,2,3,4,5,6,7,8,9,10];
attr_names = {"Preference", "Attractiveness", "Feminine", "Cooperative", ...
    "Youth", "Healthy", "Fidelity", "Harmony", "Fair", "Ruddy"};

%% ========== 遍历每个 formula ==========
for j = 1:length(formula_names)
    formula_name = formula_names{j};
    formula_folder = fullfile(base_BIC_folder, formula_name);
    
    if ~exist(formula_folder, 'dir')
        warning('文件夹不存在: %s', formula_folder);
        continue;
    end
    
    param_names = param_names_cell{j};
    n_params = length(param_names);
    
    % xlsx 文件路径（放在 formula 文件夹下）
    xlsx_path = fullfile(formula_folder, strcat('BIC_params_', formula_name, '.xlsx'));
    
    % 如果已存在则删除
    if exist(xlsx_path, 'file')
        delete(xlsx_path);
    end
    
    fprintf('\n处理 formula: %s\n', formula_name);
    
    %% ===== 遍历每个 attribute，写入一个 sheet =====
    for idx_attr = 1:length(attributes)
        attr_idx = attributes(idx_attr);
        attr_name = char(attr_names{idx_attr});
        sheet_name = sprintf('%02d%s', attr_idx, attr_name);
        
        % 读取该 attribute 的 mat 文件
        mat_file = fullfile(formula_folder, sprintf('%02d%s_BIC_curve_params.mat', attr_idx, attr_name));
        
        if ~exist(mat_file, 'file')
            fprintf('  缺失: %s\n', mat_file);
            continue;
        end
        
        data = load(mat_file);
        a_val_all = data.a_val_all;   % cell array, nations × params
        RSS_all   = data.RSS_all;     % nations × 1
        BIC_all   = data.BIC_all;     % nations × 1
        k_all     = data.k_all;       % nations × 1
        
        n_nations = length(nations_long);
        
        % ===== 构建表格内容（参照论文附录3格式）=====
        % 表格结构：
        %   列1 = Nation, 列2~1+n_params = 参数, 列2+n_params~ = k,RSS,BIC
        %   行 = 各人种（AS, CA, SA, AF, All）
        
        n_nations_actual = size(a_val_all, 1);  % 应该是 5
        n_cols = 1 + n_params + 3;  % Nation + params + k/RSS/BIC
        
        % 表头行
        sheet_col_headers = [{"Nation"}, param_names, {"k", "RSS", "BIC"}];
        
        % 表格数据（含人种名列）
        table_data = cell(n_nations_actual, n_cols);
        for i_nat = 1:n_nations_actual
            % 第1列：人种名称
            table_data{i_nat, 1} = char(nations_long(i_nat));
            % 第2~1+n_params列：拟合参数
            params_i = a_val_all{i_nat};
            for p = 1:min(n_params, length(params_i))
                table_data{i_nat, 1 + p} = params_i(p);
            end
            % 最后3列：k, RSS, BIC
            table_data{i_nat, 1 + n_params + 1} = k_all(i_nat);
            table_data{i_nat, 1 + n_params + 2} = RSS_all(i_nat);
            table_data{i_nat, 1 + n_params + 3} = BIC_all(i_nat);
        end
        
        % 组装 sheet 数据（表头 + 数据）
        sheet_data = [sheet_col_headers; table_data];
        
        % 写入 xlsx
        writecell(sheet_data, xlsx_path, 'Sheet', sheet_name);
        
        fprintf('  已写入 sheet: %s\n', sheet_name);
    end
    
    fprintf('  已保存: %s\n', xlsx_path);
end

fprintf('\n========== 完成！==========\n');
