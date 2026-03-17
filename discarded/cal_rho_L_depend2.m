function [] = cal_rho_L_depend2(output_folder_params, output_folder_excel, attribute_serial, a_C_L, L_all, C_all, nation_color, line_style, Dtype, i_nation)
% cal_rho_L_depend2函数用于替代scatter_L_depend，直接加载现有结果并计算Spearman相关系数
% 输入参数:
%   output_folder_params - 参数保存文件夹路径
%   output_folder_excel - Excel结果保存文件夹路径
%   attribute_serial - 属性标识
%   a_C_L - 已有的C_L拟合参数
%   L_all - 所有L数据
%   C_all - 所有C数据
%   nation_color - 国家颜色
%   line_style - 线条样式
%   Dtype - 数据类型
%   i_nation - 国家索引

    % 检查并移除包含NaN的行
    valid_indices = ~isnan(L_all) & ~isnan(C_all) & L_all > 0;
    L_valid = L_all(valid_indices);
    C_valid = C_all(valid_indices);
    
    if length(L_valid) > 3
        % 使用已有的a_C_L参数计算拟合值
        if ~any(isnan(a_C_L))
            % 计算拟合值
            C_fit = a_C_L(1) * log(L_valid) + a_C_L(2);
            
            % 调用cal_rho_C_L计算Spearman相关系数
            [rho_val, p_val] = cal_rho_C_L(L_valid, C_valid);
            
            % 计算RMSE
            RMSE = sqrt(mean((C_valid - C_fit).^2)) ./ mean(C_valid);
            
            % 创建新的参数文件名，避免修改原始文件
            params_filename = fullfile(output_folder_params, strcat(attribute_serial, '_all_curve_params_rho.mat'));
            
            % 保存新的参数（包括Spearman相关系数）
            save(params_filename, 'a_C_L', 'rho_val', 'p_val', 'RMSE');
            
            % 将结果写入Excel文件
            write_results_to_excel(output_folder_excel, attribute_serial, i_nation, rho_val, p_val, RMSE);
            
            % 可选：创建简单的可视化（不进行重新拟合）
            create_visualization(output_folder_params, attribute_serial, L_valid, C_valid, C_fit, nation_color, line_style, i_nation);
        else
            warning('a_C_L参数包含NaN值，无法计算拟合值。');
        end
    end
end

function [rho_val, p_val] = cal_rho_C_L(L_data, C_data)
% cal_rho_C_L函数计算L和C之间的Spearman相关系数
% 输入参数:
%   L_data - L数据
%   C_data - C数据
% 输出参数:
%   rho_val - Spearman相关系数
%   p_val - p值

    % 检查输入数据
    valid_indices = ~isnan(L_data) & ~isnan(C_data);
    L_valid = L_data(valid_indices);
    C_valid = C_data(valid_indices);
    
    if length(L_valid) > 2
        % 计算Spearman相关系数
        [rho_val, p_val] = corr(L_valid, C_valid, 'Type', 'Spearman');
    else
        rho_val = NaN;
        p_val = NaN;
        warning('数据点不足，无法计算Spearman相关系数。');
    end
end

function [] = write_results_to_excel(output_folder_excel, attribute_serial, i_nation, rho_val, p_val, RMSE)
% write_results_to_excel函数将结果写入Excel文件
% 输入参数:
%   output_folder_excel - Excel结果保存文件夹路径
%   attribute_serial - 属性标识
%   i_nation - 国家索引
%   rho_val - Spearman相关系数
%   p_val - p值
%   RMSE - 均方根误差

    % 确保输出文件夹存在
    if ~exist(output_folder_excel, 'dir')
        mkdir(output_folder_excel);
    end
    
    % 定义Excel文件名
    excel_filename = fullfile(output_folder_excel, strcat('rho_results_', attribute_serial, '.xlsx'));
    
    % 检查文件是否存在，不存在则创建
    if ~exist(excel_filename, 'file')
        % 创建新的Excel文件并写入标题行
        xlswrite(excel_filename, {'Attribute', 'Nation', 'Spearman_rho', 'p_value', 'RMSE'}, 'Sheet1', 'A1');
        row_index = 2;
    else
        % 获取已有数据的行数，确定新数据的写入位置
        [~, ~, raw] = xlsread(excel_filename, 'Sheet1');
        row_index = size(raw, 1) + 1;
    end
    
    % 准备要写入的数据
    data_to_write = {char(attribute_serial), i_nation, rho_val, p_val, RMSE};
    
    % 写入Excel文件
    xlswrite(excel_filename, data_to_write, 'Sheet1', ['A', num2str(row_index)]);
end

function [] = create_visualization(output_folder, attribute_serial, L_valid, C_valid, C_fit, nation_color, line_style, i_nation)
% create_visualization函数创建简单的可视化图形
% 输入参数:
%   output_folder - 图形保存文件夹路径
%   attribute_serial - 属性标识
%   L_valid - 有效的L数据
%   C_valid - 有效的C数据
%   C_fit - 拟合的C数据
%   nation_color - 国家颜色
%   line_style - 线条样式
%   i_nation - 国家索引
    
    % 确保输出文件夹存在
    if ~exist(output_folder, 'dir')
        mkdir(output_folder);
    end
    
    % 创建图形
    h = figure(200 + i_nation);
    set(h, 'Name', ['Spearman Rho - ' char(attribute_serial) ' - ' num2str(i_nation)], 'NumberTitle', 'off');
    hold on;
    set(gcf, 'Color', 'white');
    
    % 绘制散点图
    scatter(L_valid, C_valid, 20, nation_color, 'filled', 'MarkerEdgeColor', 'k', 'LineWidth', 0.5);
    
    % 按照L值排序，以便正确绘制拟合曲线
    [L_sorted, sort_idx] = sort(L_valid);
    C_fit_sorted = C_fit(sort_idx);
    
    % 绘制拟合曲线
    plot(L_sorted, C_fit_sorted, 'Color', nation_color, 'LineWidth', 1, 'LineStyle', line_style);
    
    % 设置图表属性
    xlabel('L^*', 'FontSize', 12, 'FontAngle', 'italic');
    ylabel('C^*', 'FontSize', 12, 'FontAngle', 'italic');
    title(['C^* - L^* (Spearman Rho: ' num2str(corr(L_valid, C_valid, 'Type', 'Spearman'), 4) ')'], 'FontSize', 14);
    grid on;
    
    % 保存图形
    fig_filename = fullfile(output_folder, strcat(attribute_serial, '_rho_nation_', num2str(i_nation), '.jpg'));
    exportgraphics(h, fig_filename, 'Resolution', 300);
    close(h);
end