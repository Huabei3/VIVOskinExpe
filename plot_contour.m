function plot_contour(par,color)
    % 绘制仅包含等高线的图形，输入参数为par
    % par: 包含椭圆参数的向量，格式与原函数兼容
    figure(1);hold on;
    
    % 确定数据范围（以中心点为基准扩展）
    center_x = par(4);
    center_y = par(5);
    
    % 计算合适的数据范围，确保完整显示等高线
    range_extend = 30;  % 扩展范围，可根据需要调整
    check_data2 = center_x + (-range_extend:0.2:range_extend);
    check_data3 = center_y + (-range_extend:0.2:range_extend);
    [data2, data3] = meshgrid(check_data2, check_data3);

    % 计算等高线数据
    a = par;
    y = (1./(1 + a(6) * exp(sqrt(a(1) * (data2 - a(4)).^2 + a(2) * (data3 - a(5)).^2 + ...
        a(3) * (data2 - a(4)) .* (data3 - a(5)))))) .* ((a(1) * (data2 - a(4)).^2 + ...
        a(2) * (data3 - a(5)).^2 + a(3) * (data2 - a(4)) .* (data3 - a(5))) >= 0);

    % 绘制等高线
    contour(data2, data3, y, [0.5, 1], 'Linewidth', 1,'Color',color);
    hold on;

    % 绘制拟合中心点
    scatter(par(4), par(5), 30, 'filled', 'MarkerEdgeColor', 'k');
    hold on;

    % 添加坐标轴和参考线
    % 计算合适的坐标范围
    lim_max = max([max(check_data2), max(check_data3)]) + 5;
    lim_min = min([min(check_data2), min(check_data3)]) - 5;
    line([0, 0], [lim_min, lim_max], 'Color', color, 'LineStyle', '--', 'LineWidth', 1); % x=0
    line([lim_min, lim_max], [0, 0], 'Color', color, 'LineStyle', '--', 'LineWidth', 1); % y=0
    refline(1, 0); % 45度线

    % 设置图形属性
    axis equal;
    xlim([lim_min, lim_max]);
    ylim([lim_min, lim_max]);
    xlabel('{\ita*}');
    ylabel('{\itb*}');
    title('Contour Plot');
end
