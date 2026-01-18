function mean_cen_with_scatter(lab_group, MSV_group)
    % 绘制等高线

    hold on;

    % 绘制散点图
    scatter(lab_group(:, 2), lab_group(:, 3), 40, MSV_group, 'filled');
    hold on;



       % 添加坐标轴和参考线
    lim_max = max(max(lab_group(:, 2)), max(lab_group(:, 3))) + 10;
    lim_min = min(min(lab_group(:, 2)), min(lab_group(:, 3))) - 10;
    line([0, 0], [lim_min, lim_max], 'Color', 'k', 'LineStyle', '--'); % x=0
    line([lim_min, lim_max], [0, 0], 'Color', 'k', 'LineStyle', '--'); % y=0
    refline(1, 0); % 45 度线

    % 设置图形属性
    axis equal;
    xlim([lim_min, lim_max]);
    ylim([lim_min, lim_max]);
    xlabel('{\ita*}');
    ylabel('{\itb*}');
    title('Contour Plot with Scatter');
    hold off;
end