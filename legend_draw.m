function create_legend(output_folder, legend_type, num_per_row)
    % 输入参数：
    % output_folder - 输出文件夹路径
    % legend_type - 图例类型
    % num_per_row - 可选参数，每行显示的标签数量，默认值为4
    
    % 设置默认每行显示数量
    if nargin < 3 || isempty(num_per_row)
        num_per_row = 4;
    end
    
    % 根据图例类型定义标签文本
    if strcmp(legend_type,"compare_nation_thesis")
        prev_folder="D:\work\VIVOskinExpe\analyze\ellip_pic_p\efit_p\compare_thesis_pre";
        % 增加文件存在性检查，避免加载失败
        if exist(fullfile(prev_folder,"author_colors.mat"), 'file')
            load(fullfile(prev_folder,"author_colors.mat"),"author_all","prev_cell");
            length_color=size(prev_cell,1);
            hue_values = linspace(0, 1, length_color + 1);hue_values = hue_values(1:end-1);
            hsv_matrix = [hue_values', 0.8 * ones(length_color, 1), 0.8 * ones(length_color, 1)];
            colors_ori = hsv2rgb(hsv_matrix);
            
            tables=[];colors=[];curr=1;
            for i_prev=1:size(prev_cell,1)
                for i_eth1=1:min(size(prev_cell{i_prev,1},1),4)
                    if prev_cell{i_prev,1}(i_eth1,2)
                        tables{curr,1}=strrep(prev_cell{i_prev,2}," et al.","");
                        curr=curr+1;
                        colors=[colors;colors_ori(i_prev,:)];
                        break
                    end
                end
            end
            disp("d")
        else
            warning('author_colors.mat 文件不存在，已跳过该部分加载');
            tables = {};
            colors = [];
        end
    elseif strcmp(legend_type,"VIVO_skin_with_pre")
        tables=["Asian","Caucasian","South Asian","African"];
    elseif strcmp(legend_type,"preNori")
        tables=["喜好中心","原图肤色"];
    elseif strcmp(legend_type,"contour_level")||strcmp(legend_type,"compare_thesis_my")
        tables=["$L^*$=10","$L^*$=20","$L^*$=30","$L^*$=40",...
            "$L^*$=50","$L^*$=60","$L^*$=70","$L^*$=80"];
    elseif strcmp(legend_type,"attr")||strcmp(legend_type,"attr_black_ch")
        tables = ["喜好的", "有吸引力的", "女性化的", "友善的", ...
    "年轻的", "健康的",  "与环境适配的", "白皙的", "红润的"];  
    else
        error('不支持的图例类型：%s', legend_type);
    end
    
    % 处理空tables的情况
    if isempty(tables)
        warning('标签列表为空，无法生成图例');
        return;
    end
    
    num_colors = length(tables);
    
    % 检查输出文件夹是否存在
    if ~isfolder(output_folder)
        error('output_folder 不是一个有效的文件夹路径：%s', output_folder);
    end

    % 计算行数和列数
    num_rows = ceil(num_colors / num_per_row);  % 总行数（向上取整）
    num_cols = num_per_row;                   % 每行列数
    
    % 单个标签的尺寸设置（可根据需要调整）
    label_width = 200;    % 每个标签占用的宽度
    label_height = 30;    % 每行占用的高度
    margin_x = 50;        % 水平边距
    margin_y = 50;        % 垂直边距
    
    % 计算图形窗口大小
    fig_width = margin_x * 2 + num_cols * label_width;
    fig_height = margin_y * 2 + num_rows * label_height;
    
    % 创建图形窗口
    fig = figure('Position', [100 100 fig_width fig_height]); 
    hold on;

    % 设置颜色映射
    if strcmp(legend_type,"attr")
        num_attributes = length(tables);  % 适配实际标签数量
        hue_values = linspace(0, 1, num_attributes + 1);
        hue_values = hue_values(1:end-1); 
        hsv_matrix = [hue_values', 0.8 * ones(num_attributes, 1), 0.8 * ones(num_attributes, 1)];
        colors = hsv2rgb(hsv_matrix);
    elseif strcmp(legend_type,"preNori")
        colors = [[1,0,0];[0,0,1]];
    elseif ~strcmp(legend_type,"compare_nation_thesis")  % 避免重复定义
        hue_values = linspace(0, 1, length(tables) + 1);
        hue_values = hue_values(1:end-1); 
        hsv_matrix = [hue_values', 0.8 * ones(length(tables), 1), 0.8 * ones(length(tables), 1)];
        colors = hsv2rgb(hsv_matrix);
    end

    % 绘制圆点和文本（支持换行）
    if strcmp(legend_type,"compare_nation_thesis")
        text_size = 10;
    else
        text_size = 15;
    end
    
    % 确保colors维度匹配
    if size(colors,1) ~= num_colors && ~isempty(colors)
        warning('颜色数量与标签数量不匹配，重新生成颜色');
        hue_values = linspace(0, 1, num_colors + 1);
        hue_values = hue_values(1:end-1); 
        hsv_matrix = [hue_values', 0.8 * ones(num_colors, 1), 0.8 * ones(num_colors, 1)];
        colors = hsv2rgb(hsv_matrix);
    end
    
    for i = 1:num_colors
        % 计算当前标签所在的行和列（从1开始）
        row_idx = ceil(i / num_per_row);    % 行索引
        col_idx = mod(i - 1, num_per_row) + 1;  % 列索引
        
        % 计算当前标签的坐标
        x_pos = margin_x + (col_idx - 1) * label_width;
        y_pos = fig_height - margin_y - (row_idx - 1) * label_height;
        
        % 绘制彩色圆点/字符
        if strcmp(legend_type,"compare_nation_thesis") && ~isempty(tables{i})
            char_table=char(tables{i});
            text(x_pos, y_pos, char_table(1), ...
            'HorizontalAlignment', 'left', ...
            'VerticalAlignment', 'middle', ...
            'FontSize', text_size, ...
            'Color', colors(i, :),'FontWeight', 'bold');            
        elseif strcmp(legend_type,"attr_black_ch")
            serials=["1","2","3","4","5","6","7","8","9","10"];
            char_table=char(serials{i});
            text(x_pos-20, y_pos, char_table, ...
            'HorizontalAlignment', 'left', ...
            'VerticalAlignment', 'middle', ...
            'FontSize', text_size, ...
            'Color', 'k','FontWeight', 'bold');  
        else
            if ~isempty(colors)
                scatter(x_pos, y_pos, 200, colors(i, :), '', 'filled');
            else
                scatter(x_pos, y_pos, 200, 'k', '', 'filled'); % 默认黑色
            end
        end
        
        % 绘制标签文本（向右偏移）
        if ~isempty(tables(i))
            text(x_pos + 20, y_pos, tables(i), ...
                'HorizontalAlignment', 'left', ...
                'VerticalAlignment', 'middle', ...
                'FontSize', text_size, ...
                'Color', 'k', 'Interpreter', 'latex');
        end
    end

    % 额外标记绘制逻辑优化
    extra_height = 0;
    if strcmp(legend_type,"contour_level")
        % 计算额外标记的位置（放在最后一行下方）
        x1 = margin_x;
        x3 = margin_x + 3*label_width;
        y_pos = margin_y + extra_height;
        
        % 绘制男女标记
        plot(x1, y_pos, 'o', 'MarkerSize', 10, 'MarkerFaceColor', 'k', 'Color', 'k', 'LineWidth', 1.5);    
        plot(x3, y_pos, 's', 'MarkerSize', 16, 'MarkerFaceColor', 'm', 'Color', 'm', 'LineWidth', 1.5);

        % 添加文本
        text(x1 + 40, y_pos, "不同明度喜好中心", ...
            'HorizontalAlignment', 'left', ...
            'VerticalAlignment', 'middle', ...
            'FontSize', 12, ...
            'Color', 'k');
        text(x3 + 40, y_pos, "PMCC", ...
            'HorizontalAlignment', 'left', ...
            'VerticalAlignment', 'middle', ...
            'FontSize', 12, ...
            'Color', 'k');
        
        extra_height = label_height;
        
    elseif strcmp(legend_type,"VIVO_skin_with_pre")
        % 计算额外标记的位置（放在最后一行下方）
        x1 = margin_x;
        x2 = margin_x + 3*label_width;
        x3 = margin_x;
        x4 = margin_x + 3*label_width;
        y_pos1 = margin_y + extra_height;
        y_pos2 = margin_y + extra_height-30;
        
        % 绘制男女标记
        plot(x1, y_pos1, 'o', 'MarkerSize', 10, 'MarkerFaceColor', 'none', 'Color', 'k', 'LineWidth', 1.5);    
        plot(x2, y_pos1, 'x', 'MarkerSize', 16, 'MarkerFaceColor', 'none', 'Color', 'k', 'LineWidth', 1.5);
        plot(x3, y_pos2, 's', 'MarkerSize', 10, 'MarkerFaceColor', 'none', 'Color', 'k', 'LineWidth', 1.5);    
        plot(x4, y_pos2, '+', 'MarkerSize', 16, 'MarkerFaceColor', 'none', 'Color', 'k', 'LineWidth', 1.5);
        
        % 添加文本
        text(x1 + 40, y_pos1, "female original", ...
            'HorizontalAlignment', 'left', ...
            'VerticalAlignment', 'middle', ...
            'FontSize', 12, 'Color', 'k');
        text(x2 + 40, y_pos1, "male original", ...
            'HorizontalAlignment', 'left', ...
            'VerticalAlignment', 'middle', ...
            'FontSize', 12, 'Color', 'k');
        text(x3 + 40, y_pos2, "female preference", ...
            'HorizontalAlignment', 'left', ...
            'VerticalAlignment', 'middle', ...
            'FontSize', 12, 'Color', 'k');
        text(x4 + 40, y_pos2, "male preference", ...
            'HorizontalAlignment', 'left', ...
            'VerticalAlignment', 'middle', ...
            'FontSize', 12, 'Color', 'k');
        
        extra_height = label_height + 100;
        
    elseif strcmp(legend_type,"compare_thesis_my")||strcmp(legend_type,"compare_nation_thesis")
        % 计算额外标记的位置（放在最后一行下方）
        if strcmp(legend_type,"compare_nation_thesis")
            margin_x=margin_x+1.5*label_width;
        end
        x1 = margin_x;
        x3 = margin_x + 3*label_width;
        x2 = margin_x + 1.5*label_width;
        y_pos = margin_y + extra_height;
        
        % 绘制实验标记
        plot(x1, y_pos, 'x', 'MarkerSize', 10, 'MarkerFaceColor', 'k', ...
            'Color', 'k', 'LineWidth', 1.5);   
        plot(x2, y_pos, 'p', 'MarkerSize', 10, 'MarkerFaceColor', 'k', ...
            'Color', 'k', 'LineWidth', 1.5);   
        plot(x3, y_pos, 'o', 'MarkerSize', 10, 'MarkerFaceColor', 'k', ...
            'Color', 'k', 'LineWidth', 1.5);

        % 添加文本
        text(x1 + 40, y_pos, "实验一", 'HorizontalAlignment', 'left', ...
            'VerticalAlignment', 'middle', 'FontSize', 12, 'Color', 'k');
        text(x2 + 40, y_pos, "实验二", 'HorizontalAlignment', 'left', ...
            'VerticalAlignment', 'middle', 'FontSize', 12, 'Color', 'k');
        text(x3 + 40, y_pos, "实验三", 'HorizontalAlignment', 'left', ...
            'VerticalAlignment', 'middle', 'FontSize', 12, 'Color', 'k');
        
        extra_height = label_height;
    end

    % 调整窗口高度以容纳额外标记
    if extra_height > 0
        fig_height = fig_height + extra_height;
        set(fig, 'Position', [100 100 fig_width fig_height]);
    end

    % 关闭坐标轴并设置显示范围
    axis off; 
    xlim([0, fig_width]);
    ylim([0, fig_height]);

    % 保存为 JPG 文件
    output_file = fullfile(output_folder, strcat("z_", legend_type, '.jpg'));
    exportgraphics(fig, output_file, 'Resolution', 150, 'ContentType', 'image');

    close(fig);
end

% ==================== 测试代码 ====================
% 单独创建测试脚本（推荐）或放在函数外部执行
clear; clc;

% 选择要测试的图例类型
% legend_type = "VIVO_skin_with_pre";
% legend_type = "preNori";
% legend_type = "attr";
% legend_type = "contour_level";
% legend_type = "attr_black_ch";
legend_type = "compare_thesis_my";
% 设置输出路径（使用相对路径，避免绝对路径问题）
Dtype = "efit_p";
output_folder = fullfile(pwd, 'AnalyseResults_p', Dtype, 'legend');

% 创建输出文件夹（如果不存在）
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end

% 正确调用函数（关键：确保传入足够的参数）
create_legend(output_folder, legend_type, 4);
output_folder


%%
% function create_legend(output_folder, legend_type, num_per_row)
%     % 输入参数：
%     % output_folder - 输出文件夹路径
%     % legend_type - 图例类型
%     % num_per_row - 可选参数，每行显示的标签数量，默认值为4
% 
%     % 设置默认每行显示数量
%     if nargin < 3 || isempty(num_per_row)
%         num_per_row = 4;
%     end
% 
%     % 根据图例类型定义标签文本
%     if strcmp(legend_type,"compare_nation_thesis")
%         prev_folder="D:\work\VIVOskinExpe\analyze\ellip_pic_p\efit_p\compare_thesis_pre";
%         load(fullfile(prev_folder,"author_colors.mat"),"author_all","prev_cell");
%         length_color=size(prev_cell,1);
%         hue_values = linspace(0, 1, length_color + 1);hue_values = hue_values(1:end-1);
%         hsv_matrix = [hue_values', 0.8 * ones(length_color, 1), 0.8 * ones(length_color, 1)];
%         colors_ori = hsv2rgb(hsv_matrix);
% 
%         tables=[];colors=[];curr=1;
%         for i_prev=1:size(prev_cell,1)
%             for i_eth1=1:min(size(prev_cell{i_prev,1},1),4)
%                 if prev_cell{i_prev,1}(i_eth1,2)
%                     tables{curr,1}=strrep(prev_cell{i_prev,2}," et al.","");
%                     curr=curr+1;
%                     colors=[colors;colors_ori(i_prev,:)];
%                     break
% 
%                 end
%             end
% 
%         end
%         disp("d")
%     elseif strcmp(legend_type,"VIVO_skin_with_pre")
%         tables=["Asian","Caucasian","South Asian","African"];
%     elseif strcmp(legend_type,"preNori")
%         % tables=["preference","original"];
%         tables=["喜好中心","原图肤色"];
%     elseif strcmp(legend_type,"contour_level")||strcmp(legend_type,"compare_thesis_my")
%         tables=["$L^*$=10","$L^*$=20","$L^*$=30","$L^*$=40",...
%             "$L^*$=50","$L^*$=60","$L^*$=70","$L^*$=80"];
%     elseif strcmp(legend_type,"attr")||strcmp(legend_type,"attr_black_ch")
%         % 示例：模拟10个属性标签
%         tables = ["喜好的", "有吸引力的", "女性化的", "友善的", ...
%     "年轻的", "健康的",  "与环境适配的", "白皙的", "红润的"];  
% 
%     end
% 
%     num_colors = length(tables);
% 
%     % 检查输出文件夹是否存在
%     if ~isfolder(output_folder)
%         error('output_folder 不是一个有效的文件夹路径');
%     end
% 
%     % 计算行数和列数
%     num_rows = ceil(num_colors / num_per_row);  % 总行数（向上取整）
%     num_cols = num_per_row;                   % 每行列数
% 
%     % 单个标签的尺寸设置（可根据需要调整）
%     label_width = 200;    % 每个标签占用的宽度
%     label_height = 30;    % 每行占用的高度
%     margin_x = 50;        % 水平边距
%     margin_y = 50;        % 垂直边距
% 
%     % 计算图形窗口大小
%     fig_width = margin_x * 2 + num_cols * label_width;
%     fig_height = margin_y * 2 + num_rows * label_height;
% 
%     % 创建图形窗口
%     figure('Position', [100 100 fig_width fig_height]); 
%     hold on;
% 
%     % 设置颜色映射
%     if strcmp(legend_type,"attr")
%         num_attributes = 10;
%         hue_values = linspace(0, 1, num_attributes + 1);
%         hue_values = hue_values(1:end-1); 
%         hsv_matrix = [hue_values', 0.8 * ones(num_attributes, 1), 0.8 * ones(num_attributes, 1)];
%         colors = hsv2rgb(hsv_matrix);
%     elseif strcmp(legend_type,"preNori")
%         colors = [[1,0,0];[0,0,1]];
%     else
%         hue_values = linspace(0, 1, length(tables) + 1);
%         hue_values = hue_values(1:end-1); 
%         hsv_matrix = [hue_values', 0.8 * ones(length(tables), 1), 0.8 * ones(length(tables), 1)];
%         colors = hsv2rgb(hsv_matrix);
%     end
% 
%     % 绘制圆点和文本（支持换行）
%     if strcmp(legend_type,"compare_nation_thesis")
%         text_size = 10;
%     else
%         text_size = 15;
%     end
%     for i = 1:num_colors
%         % 计算当前标签所在的行和列（从1开始）
%         row_idx = ceil(i / num_per_row);    % 行索引
%         col_idx = mod(i - 1, num_per_row) + 1;  % 列索引
% 
%         % 计算当前标签的坐标
%         x_pos = margin_x + (col_idx - 1) * label_width;
%         y_pos = fig_height - margin_y - (row_idx - 1) * label_height;
% 
%         % 绘制彩色圆点
%         if strcmp(legend_type,"compare_nation_thesis")
%             char_table=char(tables{i});
%             text(x_pos, y_pos, char_table(1), ...
%             'HorizontalAlignment', 'left', ...
%             'VerticalAlignment', 'middle', ...
%             'FontSize', text_size, ...
%             'Color', colors(i, :),'FontWeight', 'bold');            
%         elseif strcmp(legend_type,"attr_black_ch")
%             serials=["1","2","3","4","5","6","7","8","9","10"];
%             char_table=char(serials{i});
%             text(x_pos-20, y_pos, char_table, ...
%             'HorizontalAlignment', 'left', ...
%             'VerticalAlignment', 'middle', ...
%             'FontSize', text_size, ...
%             'Color', 'k','FontWeight', 'bold');  
%         else
%             scatter(x_pos, y_pos, 200, colors(i, :), '', 'filled');
%         end
%         % 绘制标签文本（向右偏移）
%         text(x_pos + 20, y_pos, tables(i), ...
%             'HorizontalAlignment', 'left', ...
%             'VerticalAlignment', 'middle', ...
%             'FontSize', text_size, ...
%             'Color', 'k', 'Interpreter', 'latex');
%     end
% 
%     % VIVOskin类型的额外标记（适配换行布局）
%     if strcmp(legend_type,"contour_level")
%         % 计算额外标记的位置（放在最后一行下方）
%         x1 = margin_x;
%         x3 = margin_x + 3*label_width;
%         y_pos = margin_y;
% 
%         % 绘制男女标记
%         plot(x1, y_pos, 'o', 'MarkerSize', 10, 'MarkerFaceColor', 'k', 'Color', 'k', 'LineWidth', 1.5);    
%         plot(x3, y_pos, 's', 'MarkerSize', 16, 'MarkerFaceColor', 'm', 'Color', 'm', 'LineWidth', 1.5);
% 
%         % 添加文本
%         text(x1 + 40, y_pos, "不同明度喜好中心", ...
%             'HorizontalAlignment', 'left', ...
%             'VerticalAlignment', 'middle', ...
%             'FontSize', 12, ...
%             'Color', 'k');
%         text(x3 + 40, y_pos, "PMCC", ...
%             'HorizontalAlignment', 'left', ...
%             'VerticalAlignment', 'middle', ...
%             'FontSize', 12, ...
%             'Color', 'k');
% 
%         % 调整窗口高度以容纳额外标记
%         fig_height = fig_height + label_height;
%         set(gcf, 'Position', [100 100 fig_width fig_height]);
%     % VIVOskin类型的额外标记（适配换行布局）
%     if strcmp(legend_type,"VIVO_skin_with_pre")
%         % 计算额外标记的位置（放在最后一行下方）
%         x1 = margin_x;
%         x2 = margin_x + 3*label_width;
%         x3 = margin_x;
%         x4 = margin_x + 3*label_width;
%         y_pos1 = margin_y+100;
%         y_pos2 = margin_y;
% 
%         % 绘制男女标记
%         plot(x1, y_pos1, 'o', 'MarkerSize', 10, 'MarkerFaceColor', 'k', 'Color', 'k', 'LineWidth', 1.5);    
%         plot(x2, y_pos1, 'x', 'MarkerSize', 16, 'MarkerFaceColor', 'k', 'Color', 'k', 'LineWidth', 1.5);
%         plot(x3, y_pos2, 's', 'MarkerSize', 10, 'MarkerFaceColor', 'k', 'Color', 'k', 'LineWidth', 1.5);    
%         plot(x4, y_pos2, '+', 'MarkerSize', 16, 'MarkerFaceColor', 'k', 'Color', 'k', 'LineWidth', 1.5);
%         % 添加文本
%         text(x1 + 40, y_pos1, "female original", ...
%             'HorizontalAlignment', 'left', ...
%             'VerticalAlignment', 'middle', ...
%             'FontSize', 12, ...
%             'Color', 'k');
%         text(x2 + 40, y_pos1, "male original", ...
%             'HorizontalAlignment', 'left', ...
%             'VerticalAlignment', 'middle', ...
%             'FontSize', 12, ...
%             'Color', 'k');
% 
%                 % 添加文本
%         text(x3 + 40, y_pos2, "female preference", ...
%             'HorizontalAlignment', 'left', ...
%             'VerticalAlignment', 'middle', ...
%             'FontSize', 12, ...
%             'Color', 'k');
%         text(x4 + 40, y_pos2, "male preference", ...
%             'HorizontalAlignment', 'left', ...
%             'VerticalAlignment', 'middle', ...
%             'FontSize', 12, ...
%             'Color', 'k');
% 
%         % 调整窗口高度以容纳额外标记
%         fig_height = fig_height + label_height;
%         set(gcf, 'Position', [100 100 fig_width fig_height]);
%     elseif strcmp(legend_type,"compare_thesis_my")||strcmp(legend_type,"compare_nation_thesis")
%         % 计算额外标记的位置（放在最后一行下方）
%         if strcmp(legend_type,"compare_nation_thesis")
%             margin_x=margin_x+1.5*label_width;
%         end
%         x1 = margin_x;
%         x3 = margin_x + 3*label_width;
%         x2 = margin_x + 1.5*label_width;
%         y_pos = margin_y;
% 
%         % 绘制男女标记
%         plot(x1, y_pos, 'x', 'MarkerSize', 10, 'MarkerFaceColor', 'k', ...
%             'Color', 'k', 'LineWidth', 1.5);   
%         plot(x2, y_pos, 'p', 'MarkerSize', 10, 'MarkerFaceColor', 'k', ...
%             'Color', 'k', 'LineWidth', 1.5);   
%         plot(x3, y_pos, 'o', 'MarkerSize', 10, 'MarkerFaceColor', 'k', ...
%             'Color', 'k', 'LineWidth', 1.5);
% 
%         % 添加文本
%         text(x1 + 40, y_pos, "实验一", ...
%             'HorizontalAlignment', 'left', ...
%             'VerticalAlignment', 'middle', ...
%             'FontSize', 12, ...
%             'Color', 'k');
%         text(x2 + 40, y_pos, "实验二", ...
%             'HorizontalAlignment', 'left', ...
%             'VerticalAlignment', 'middle', ...
%             'FontSize', 12, ...
%             'Color', 'k');
%         text(x3 + 40, y_pos, "实验三", ...
%             'HorizontalAlignment', 'left', ...
%             'VerticalAlignment', 'middle', ...
%             'FontSize', 12, ...
%             'Color', 'k');
% 
%         % 调整窗口高度以容纳额外标记
%         fig_height = fig_height + label_height;
%         set(gcf, 'Position', [100 100 fig_width fig_height]);
%     end
% 
%     % 关闭坐标轴并设置显示范围
%     axis off; 
%     xlim([0, fig_width]);
%     ylim([0, fig_height]);
% 
%     % 保存为 JPG 文件
%     output_file = fullfile(output_folder, strcat("z_", legend_type, '.jpg'));
%     exportgraphics(gcf, output_file, 'Resolution', 150, 'ContentType', 'image');
% 
%     close(gcf);
% end
% 
% % 测试代码
% % 测试1：默认每行4个标签
% 
% % legend_type = "preNori";
% % legend_type = "attr";
% % legend_type = "compare_nation_thesis";
% % legend_type = "compare_thesis_my";
% % legend_type = "contour_level";
% % legend_type = "attr_black_ch";
% legend_type = "VIVO_skin_with_pre";
% Dtype = "efit_p";
% output_folder = fullfile('AnalyseResults_p', Dtype, 'legend');
% if ~exist(output_folder, 'dir')
%     mkdir(output_folder);
% end
% % create_legend(output_folder, legend_type,5);
% create_legend(output_folder, legend_type,4);
% disp(output_folder);
% % 测试2：指定每行2个标签
% % create_legend(output_folder, "attr", 2);
% 
% % 测试3：测试VIVOskin类型（带额外标记）
% % create_legend(output_folder, "VIVOskin", 3);
% 
% 
% 
% 
% %%
