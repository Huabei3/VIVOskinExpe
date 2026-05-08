function create_custom_legend(output_folder, data_cell, use_chinese, legend_type)
    % 输入参数：
    % output_folder - 输出文件夹路径
    % data_cell - 包含数据的cell数组，每行格式为：
    %   {英文标签, 中文标签, [R,G,B], 标识符}
    % use_chinese - 逻辑值，true使用中文标签，false使用英文标签
    % varargin - 可选参数：
    %   'text_size' - 字体大小，默认15
    %   'marker_size' - 标记大小，默认100
    %   'y_spacing' - 纵坐标间距，默认50
    %   'x_start' - 起始x坐标，默认50
    %   'row_spacing' - 行间距，默认80
    
    % 解析可选参数
    % p = inputParser;
    % addParameter(p, 'text_size', 15, @isnumeric);
    % addParameter(p, 'marker_size', 100, @isnumeric);
    % addParameter(p, 'y_spacing', 100, @isnumeric);
    % addParameter(p, 'x_start', 50, @isnumeric);
    % addParameter(p, 'row_spacing', 120, @isnumeric);
    % parse(p, varargin{:});
    
    % text_size = p.Results.text_size;
    % marker_size = p.Results.marker_size;
    % y_spacing = p.Results.y_spacing;
    % x_start = p.Results.x_start;
    % row_spacing = p.Results.row_spacing;

    text_size = 10;
    marker_size = 100;
    y_spacing = 100;
    x_start = 50;
    row_spacing = 100;
    % 验证输入数据
    if ~iscell(data_cell)
        error('data_cell 必须是一个cell数组');
    end
    
    num_rows = size(data_cell, 1);
    
    % 检查文件夹
    if ~isfolder(output_folder)
        mkdir(output_folder);
    end
    
    % 创建图形窗口
    figure('Position', [0 0 1200, max(400, num_rows * row_spacing)]);
    hold on;
    axis off;
    
    % 绘制每一行
    for i = 1:num_rows
        row_data = data_cell(i, :);
        
        if length(row_data) < 4
            error('第 %d 行数据不完整，需要4列数据', i);
        end
        
        % 提取数据
        eng_label = row_data{1};
        chn_label = row_data{2};
        color_rgb = row_data{3};
        identifier = row_data{4};

        if startsWith(row_data{1},"Park et al. (2006)")
            identifier="Pa";
        elseif startsWith(row_data{1},"Peng et al. (2020)")
            identifier="P3";
        elseif startsWith(row_data{1},"Peng et al. (2023)")
            identifier="P";
        elseif startsWith(row_data{1},"Zeng et al. (2010)")
            identifier="Z1";
        elseif startsWith(row_data{1},"Zeng et al. (2011)")
            identifier="Z";
        elseif startsWith(row_data{1},"Yano et al. (1998)")
            identifier="Yn";
        elseif startsWith(row_data{1},"Yamamoto et al. (2002)")
            identifier="Ym";
        end

        
        % 验证颜色数据
        if ~isnumeric(color_rgb) || length(color_rgb) ~= 3
            error('第 %d 行的颜色数据无效', i);
        end
        
        % 计算y坐标（从顶部开始）
        y_pos = (num_rows - i) * y_spacing + 50;
        
        % 绘制标识符（使用指定颜色）
        if startsWith(chn_label,"实验")
            scatter(x_start, y_pos, 20, row_data{4}, 'LineWidth', 1, ...
                'MarkerEdgeColor',color_rgb,'MarkerFaceColor',color_rgb);
        elseif startsWith(chn_label,"PMC")
            plot(x_start, y_pos, 's', 'MarkerSize', 4, ...
            'MarkerFaceColor', "none", 'MarkerEdgeColor', color_rgb);

        else
        text(x_start, y_pos, identifier, ...
            'FontSize', text_size, ...
            'VerticalAlignment', 'middle', ...
            'HorizontalAlignment', 'center', ...
            'Color', color_rgb, ...
            'FontWeight', 'bold');
        end
        
        % 绘制标签
        if use_chinese
            label_text = chn_label;
        else
            label_text = eng_label;
        end
        
        text(x_start + 40, y_pos, label_text, ...
            'FontSize', text_size, ...
            'VerticalAlignment', 'middle', ...
            'HorizontalAlignment', 'left', ...
            'Color', 'k');
    end
    
    % 设置坐标轴范围
    xlim([0, 1200]);
    ylim([0, num_rows * row_spacing + 50]);
    
    % 保存图像
    if use_chinese
        lang_suffix = 'chn';
    else
        lang_suffix = 'eng';
    end
    
    output_file = fullfile(output_folder, sprintf('x_%s_%s.jpg', legend_type,lang_suffix));
    exportgraphics(gcf, output_file, 'Resolution', 1500, 'ContentType', 'image');
    
    close(gcf);
    fprintf('图例已保存至: %s\n', output_file);

end

% 创建输出文件夹

Dtype = "efit_p";
output_folder = fullfile('ellip_pic_p', Dtype, 'legend');
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end
% label_type="only_my";
% label_type="include_this";
label_type="exclude_this";
% label_type="include_VIVO";
load(fullfile("ellip_pic_p\efit_p\compare_thesis_pre", ...
    "exclude_this","author_colors.mat"));
i_del = [];
exclude_authors = {"Sangers et al. (1994)", "Zeng et al. (2009)", ...
                  "Zeng et al. (2010)", "Kuang et al. (2005)", "Peng et al. (2020)"};
for i_author = 1:length(author_all)
    for i_ex=1:length(exclude_authors)
        if startsWith(author_all{i_author, 1}, exclude_authors{i_ex})
            i_del = [i_del, i_author];
            break
        end
    end
    % if startsWith(author_all{i_author, 1}, "")
    % elseif startsWith(author_all{i_author, 1}, "")
    % end

end
author_all(i_del,:)=[];
% 生成英文图例
% create_custom_legend(output_folder, author_all, false, ...
%     'text_size', 14, ...
%     'y_spacing', 60, ...
%     'row_spacing', 70);
legend_type=strcat("preference",label_type);
% legend_type="impression";
% 生成中文图例
% 如果label_type是"include_this"，添加额外的实验标签
% length_color=8;
% hue_values = linspace(0, 1, length_color + 1);hue_values = hue_values(1:end-1);
% hsv_matrix = [hue_values', 0.8 * ones(length_color, 1), 0.8 * ones(length_color, 1)];
% colors = hsv2rgb(hsv_matrix);
length_color=4;
hue_values = linspace(0, 1, length_color + 1);hue_values = hue_values(1:end-1);
hsv_matrix = [hue_values', 0.8 * ones(length_color, 1), 0.8 * ones(length_color, 1)];
colors_temp = hsv2rgb(hsv_matrix);
colors=[[0.7 0 0];[0 0.5 0];[0 0 0];[1 0.5 0];[0.2 0.2 1];
    [1 0 1];[0.5 0.5 0.5];
    [1, 0.75, 0.8];[0.6, 0.2, 0.8];[0.6, 0.4, 0.2]];
colors(1:2,:)=colors_temp(1:2,:);
if strcmp(label_type, "include_this")||strcmp(label_type, "only_my")||strcmp(label_type, "include_VIVO")
    % 定义6个实验的标签数据
    % 格式：{英文标签, 中文标签, [R,G,B], 标识符}
    % 这里使用不同的颜色，您可以根据需要修改颜色值
    if strcmp(label_type, "include_VIVO")
        experiment_labels = {
     
            {'This research (Asian)', '实验三（亚洲人）', colors(1,:), 'o'};      
            {'This research (Caucasian)', '实验三（高加索人）', colors(2,:), 'o'}; 
            {'This research (South Asian)', '实验三（南亚人）', colors(3,:), 'o'}; 
            {'This research (African)', '实验三（非洲人）', colors(4,:), 'o'}  
            {'PMC chart (Asian)', 'PMCC（亚洲人）', colors(1,:), 's'}  
            {'PMC chart (Caucasian)', 'PMCC（高加索人）', colors(2,:), 's'}  
            {'PMC chart (South Asian)', 'PMCC（南亚人）', colors(3,:), 's'} 
            {'PMC chart (African)', 'PMCC（非洲人）', colors(4,:), 's'} 
        };
    else
        experiment_labels = {
            {'Exp 1', '实验一', [0,0,0], 'x'};      
            {'Exp 2', '实验二', [0,0,0], 'p'};       
            {'Exp 3 (Asian)', '实验三（亚洲人）', colors(1,:), 'o'};      
            {'Exp 3 (Caucasian)', '实验三（高加索人）', colors(2,:), 'o'}; 
            {'Exp 3 (South Asian)', '实验三（南亚人）', colors(3,:), 'o'}; 
            {'Exp 3 (African)', '实验三（非洲人）', colors(4,:), 'o'}  
            {'PMC chart (Asian)', 'PMCC（亚洲人）', colors(1,:), 's'}  
            {'PMC chart (Caucasian)', 'PMCC（高加索人）', colors(2,:), 's'}  
            {'PMC chart (South Asian)', 'PMCC（南亚人）', colors(3,:), 's'} 
            {'PMC chart (African)', 'PMCC（非洲人）', colors(4,:), 's'} 
        };
    end
    
    
    % 将实验标签添加到原始数据后面
    for i_extra=1:size(experiment_labels,1)
        author_all{end+1,1}=experiment_labels{i_extra,1}{1,1};
        author_all{end,2}=experiment_labels{i_extra,1}{1,2};
        author_all{end,3}=experiment_labels{i_extra,1}{1,3};
        author_all{end,4}=experiment_labels{i_extra,1}{1,4};
    end
    if strcmp(label_type, "only_my")
        author_all=author_all(35:37,:);
    end
end


create_custom_legend(output_folder, author_all, true, legend_type);
% create_custom_legend(output_folder, author_all, false, legend_type);

fullfile(pwd,output_folder)


% "D:\work\FirstYearMaster\SkinColorPreferenceScale";