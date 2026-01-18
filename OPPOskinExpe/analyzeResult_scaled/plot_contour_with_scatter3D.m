function plot_contour_with_scatter3D(par, lab_group, MSV_group,save_folder,label)
    % 绘制等高线
        % 绘制等高线
    %--------------------a-b---------------------
    check_data2 = par(6) + (-30:0.2:30);
    check_data3 = par(7) + (-30:0.2:30);
    [data2, data3] = meshgrid(check_data2, check_data3);
    
    a = par;
    % 计算 y 的值
    y = (1./(1 + a(8) * exp(sqrt(a(2) * (data2 - a(6)).^2 + a(3) * (data3 - a(7)).^2 + ...
        a(4) * (data2 - a(6)) .* (data3 - a(7)))))).*((a(2) * (data2 - a(6)).^2 + ...
        a(3) * (data3 - a(7)).^2 + a(4) * (data2 - a(6)) .* (data3 - a(7))) >= 0);


    figure(1);hold on;
    contour(data2, data3, y, [0.5, 1], 'Linewidth', 2);
    hold on;

    % 绘制散点图
    scatter(lab_group(:, 2), lab_group(:, 3), 40, MSV_group, 'filled');
    hold on;

    % 绘制拟合中心点
    scatter(par(6), par(7), 30, 'filled');
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
    output_folder=fullfile(save_folder,"a_b");
    if ~exist(output_folder,"dir")
        mkdir(output_folder);
    end
    exportgraphics(gcf,fullfile(output_folder,strcat(label,"a_b.jpg")),"Resolution",150);
    close(gcf)
    %---------------------------L-a--------------------------------
    check_data2 = par(6) + (-30:0.2:30);
    check_data1 = par(5) + (-30:0.2:30);
    [data2, data1] = meshgrid(check_data2, check_data1);

    y = (1./(1 + a(8) * exp(sqrt(a(2) * (data2 - a(6)).^2 + ...
        a(1) * (data1 - a(5)).^2)))).*((a(2) * (data2 - a(6)).^2 + ...
    a(1) * (data1 - a(5)).^2) >= 0);

    figure();hold on;
    contour(data2, data1, y, [0.5, 1], 'Linewidth', 2);
    hold on;

    % 绘制散点图
    scatter(lab_group(:, 2), lab_group(:, 1), 40, MSV_group, 'filled');
    hold on;

    % 绘制拟合中心点
    scatter(par(6), par(5), 30, 'filled');
    hold on;


    % 计算 x 轴上下限 (第一列数据)
    x_max = max(lab_group(:, 2)) + 10;
    x_min = min(lab_group(:, 2)) - 10;
    
    y_max = max(lab_group(:, 1)) + 10;
    y_min = min(lab_group(:, 1)) - 10;

    % 设置图形属性
    axis equal;
    xlim([x_min, x_max]);
    ylim([y_min, y_max]);
    xlabel('{\ita*}');
    ylabel('{\itL*}');
    title('Contour Plot with Scatter');
    hold off;
    output_folder=fullfile(save_folder,"L_a");
    if ~exist(output_folder,"dir")
        mkdir(output_folder);
    end
    exportgraphics(gcf,fullfile(output_folder,strcat(label,"L_a.jpg")),"Resolution",150);
    close(gcf)
    %-----------------------------------------------------------
end