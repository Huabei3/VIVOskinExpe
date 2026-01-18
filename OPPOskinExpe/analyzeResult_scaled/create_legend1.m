function create_legend1(tables, output_folder)
    % 输入参数：
    % tables - 字符串数组，包含图例文本
    % output_folder - 输出文件夹路径

    % 检查输入参数
    if ~isstring(tables)
        error('tables 必须是一个字符串数组');
    end
    if ~isfolder(output_folder)
        error('output_folder 不是一个有效的文件夹路径');
    end

    % 获取颜色数量
    num_colors = length(tables);

    % 创建一个新的图形窗口
    figure('Position', [0 0 800 100]); % 设置图形窗口大小
    hold on;

    % 设置颜色映射
    colors = hsv(num_colors);
    % colors = [[0,0,0];[1,0,0];[0,0,1]];

    % 绘制圆点和文本
    for i = 1:num_colors
        % 绘制圆点
        scatter(30 + (i - 1) * 200, 50, 50, colors(i, :), 'filled'); % 减小圆点大小

        % 添加文本
        text(30 + (i - 1) * 200 + 20, 50, tables(i), ... % 增加文本的水平偏移量
            'HorizontalAlignment', 'left', ...
            'VerticalAlignment', 'middle', ...
            'FontSize', 12, ...
            'Color', 'k'); % 设置文本颜色为黑色
    end
    axis off; % 关闭坐标轴
    xlim([0,30 + i * 200+50])
    ylim([0,100])

    % 保存为 JPG 文件
    % output_file = fullfile(output_folder, 'obs.jpg');
    output_file = fullfile(output_folder, 'makeup.jpg');
    % output_file = fullfile(output_folder, 'scene.jpg');
    % output_file = fullfile(output_folder, 'gender.jpg');
    exportgraphics(gcf, output_file, "Resolution", 150);
    close(gcf);
end