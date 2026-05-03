%% XLSX_L_depend.m - 将拟合参数写入Excel（所有parameter，4个nation）
% 读取 scatter_L_depend_new.m 生成的 *_all_curve_params.mat
% 每个attribute一个sheet，每个sheet包含所有6个参数的子表
% 只输出4个nation：AS, CA, SA, AF（排除"all"）

clear; clc;

%% 1. 设置路径和属性名
source_folder = 'D:\work\VIVOskinExpe\analyze\AnalyseResults_p\efit_p\unscaled\model_fullpara\d65\new\i\non_model';
attribute_names_new = ["Preference", "Attractiveness", "Feminine", "Cooperative", ...
    "Youth", "Healthy", "Fidelity", "Harmony", "Fair", "Ruddy"];

% 输出Excel文件
output_excel_file = 'D:\work\VIVOskinExpe\analyze\AnalyseResults_p\efit_p\unscaled\model_fullpara\d65\new\i\non_model\all_parameters.xlsx';

% 4个人种（排除"all"）
nation_labels = ["Asian (AS)", "Caucasian (CA)", "South Asian (SA)", "African (AF)"];
n_nations_used = 4;  % 只取前4个（排除第5个"all"）

%% 2. 检查输出文件是否已存在，如果存在则删除
if exist(output_excel_file, 'file')
    delete(output_excel_file);
end

%% 3. 循环处理每个属性
for i_attr = 1:length(attribute_names_new)
    % 4. 构建并加载.mat文件
    file_name = strcat(sprintf("%02d",i_attr), attribute_names_new(i_attr), "_all_curve_params.mat");
    file_path = fullfile(source_folder, file_name);
    
    if ~exist(file_path, 'file')
        fprintf('警告: 文件 %s 未找到，跳过此属性。\n', file_path);
        continue;
    end
    
    load(file_path);
    
    % 只取前4个nation（排除"all"）
    % 所有参数矩阵都是 5 x n_params，取第1-4行
    a_CL_all       = a_CL_all(1:n_nations_used, :);
    a_long_axis_all = a_long_axis_all(1:n_nations_used, :);
    a_short_axis_all = a_short_axis_all(1:n_nations_used, :);
    a_hue_angle_all = a_hue_angle_all(1:n_nations_used, :);
    a_theta_all   = a_theta_all(1:n_nations_used, :);
    a_alpha_all   = a_alpha_all(1:n_nations_used, :);
    rmse_CL_all   = rmse_CL_all(1:n_nations_used);
    rmse_long_axis_all = rmse_long_axis_all(1:n_nations_used);
    rmse_short_axis_all = rmse_short_axis_all(1:n_nations_used);
    rmse_hue_angle_all = rmse_hue_angle_all(1:n_nations_used);
    rmse_theta_all = rmse_theta_all(1:n_nations_used);
    rmse_alpha_all = rmse_alpha_all(1:n_nations_used);
    
    % 5. 构建数据表
    % 参数变量名（与.mat文件中的变量名一致）
    param_vars = {'a_CL_all', 'a_long_axis_all', 'a_short_axis_all', ...
                  'a_hue_angle_all', 'a_theta_all', 'a_alpha_all'};
    rmse_vars = {'rmse_CL_all', 'rmse_long_axis_all', 'rmse_short_axis_all', ...
                 'rmse_hue_angle_all', 'rmse_theta_all', 'rmse_alpha_all'};
    table_headers = {'C*', 'long axis', 'short axis', 'h', 'theta', 'alpha'};
    
    % 对 a_theta_all 进行修改（加90度，mod 180）
    a_theta_all(:, 2) = mod(a_theta_all(:, 2) + 90, 180);
    
    % 创建一个单元格数组来存储所有表格数据
    all_tables = cell(1, length(param_vars));
    
    % 遍历每个参数类型，构建子表格
    for i_param = 1:length(param_vars)
        param_data = eval(param_vars{i_param});
        rmse_data = eval(rmse_vars{i_param});
        
        % 动态生成列名
        num_params = size(param_data, 2);
        param_cols = cell(1, num_params);
        for i_col = 1:num_params
            param_cols{i_col} = ['a_' num2str(i_col)];
        end
        
        % 构建当前参数的表格
        % 第一列：nation标签，后面：参数值，最后一列：RMSE
        sub_table_data = [nation_labels(:), cellstr(num2str(param_data)), num2cell(rmse_data)];
        % 上面的写法可能有问题，改用以下方式：
        sub_table_cell = cell(n_nations_used, 1 + num_params + 1);  % nation + params + RMSE
        for i_row = 1:n_nations_used
            sub_table_cell{i_row, 1} = char(nation_labels(i_row));
            for i_col = 1:num_params
                sub_table_cell{i_row, 1 + i_col} = param_data(i_row, i_col);
            end
            sub_table_cell{i_row, end} = rmse_data(i_row);
        end
        
        % 表头行
        col_names = [{'Nation'}, param_cols, {'RMSE'}];
        
        % 组装：标题行 + 空行 + 列名 + 数据
        num_cols = size(sub_table_cell, 2);
        title_row = cell(1, num_cols);
        title_row{1} = table_headers{i_param};
        
        all_tables{i_param} = [title_row; ...
            cell(1, num_cols); ...
            col_names; ...
            sub_table_cell];
    end
    
    % 6. 将所有子表格合并为一个大的单元格数组
    final_cell_array = [];
    max_cols = 7;  % 最大列数（nation + 4个param + RMSE = 6，取7留余量）
    
    for i = 1:length(all_tables)
        current_table_data = all_tables{i};
        current_cols = size(current_table_data, 2);
        
        % 如果当前表格列数小于最大列数，用空单元格填充
        if current_cols < max_cols
            padding = cell(size(current_table_data, 1), max_cols - current_cols);
            current_table_data = [current_table_data, padding];
        end
        
        final_cell_array = [final_cell_array; current_table_data];
        
        % 在每个表格之间插入空行
        if i < length(all_tables)
            final_cell_array = [final_cell_array; cell(2, max_cols)];
        end
    end
    
    % 7. 写入Excel工作表
    sheet_name = char(attribute_names_new(i_attr));
    writecell(final_cell_array, output_excel_file, 'Sheet', sheet_name);
    
    fprintf('已成功处理并写入工作表: %s\n', sheet_name);
end

fprintf('\n所有属性数据已成功写入 %s。\n', output_excel_file);
