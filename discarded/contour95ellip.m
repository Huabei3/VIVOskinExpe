function contour95ellip(center,mu,lab_group,rho,output_folder,scene_name)
    
    lab_PMCC=[62.11,18.96,19.76];
    scatter_L = lab_group(:, 1);
    scatter_a = lab_group(:, 2);
    scatter_b = lab_group(:, 3);
    % a-b
    figure(1);
    subplot('Position', [0.1, 0.4, 0.8, 0.55]); % 调整绘制区域位置和尺寸
    
    check_data2 = center(2) + (-20:0.2:20);
    check_data3 = center(3) + (-20:0.2:20);
    [data2, data3] = meshgrid(check_data2, check_data3);

    % 计算 y 的值

    f=    mu(4).*(data2 -center(2)).^2+...
    mu(5).*(data2 -center(2)).*(data3-center(3))+...
    mu(6).*(data3-center(3)).^2;

    contour(data2, data3, f, [0,rho], 'Linewidth', 2);
    hold on;

    % scatter  
    scatter(scatter_a, scatter_b, 10,  'o','LineWidth', 0.5);

        % 标注中心
    plot(center(2), center(3), 'p', 'MarkerSize', 5, 'MarkerFaceColor', 'r','Color','r');
    plot(lab_PMCC(2), lab_PMCC(3),  's', 'MarkerSize', 5, ...
            'MarkerFaceColor', [1, 0.4, 0.8], 'MarkerEdgeColor', 'm');

    % 在图下方空白区域添加椭球中心坐标和 center0_render
    annotation('textbox', [0.1, 0.02, 0.8, 0.25], 'String', ...
        sprintf(['red\x2605 fit center: [%.2f, %.2f] hue:%.2f\n ' ...
        'pink square PMCC: [%.2f, %.2f]' ...
        '45° Line: y = x\n' ...
        'o: render points \n'], ...
         center(2), center(3), atan2d(center(3),center(2)) , ...
         lab_PMCC(2), lab_PMCC(3)), ...
        'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
        'BackgroundColor', 'white', 'EdgeColor', 'black', 'FontSize', 6);
    xlabel('a');
    ylabel('b');
    max_lim=max(max(scatter_a),max(scatter_b))+5;
    min_lim=min(min(scatter_a),min(scatter_b))-5;
    x = linspace(min_lim, max_lim, 1000);
    % y = tand(45) * (x - center(2)) + center(3);
    y=x;
    plot(x, y);
    axis equal;
    xlim([min_lim,max_lim]);
    ylim([min_lim,max_lim]);
    
    title(strcat('a\_b ',scene_name));

    hold on;

    saveas(gcf, fullfile(output_folder, 'a_b',strcat('a_b', scene_name,'.jpg')));



        % L_a
    figure(2);
    subplot('Position', [0.1, 0.4, 0.8, 0.55]); % 调整绘制区域位置和尺寸

    check_data1 = center(1) + (-20:0.2:20);
    check_data2 = center(2) + (-20:0.2:20);
    
    [data1, data2] = meshgrid(check_data1, check_data2);

    % 计算 y 的值

    f=mu(1).*(data1-center(1)).^2+...
    mu(2).*(data1-center(1)).*(data2 -center(2))+...
    mu(4).*(data2 -center(2)).^2;

    contour(data2, data1, f, [0,  rho], 'Linewidth', 2);
    hold on;

    % scatter  
    scatter(scatter_a, scatter_L, 10,  'o','LineWidth', 0.5);

        % 标注中心
    plot(center(2), center(1), 'p', 'MarkerSize', 5, 'MarkerFaceColor', 'r','Color','r');
    plot(lab_PMCC(2), lab_PMCC(1),  's', 'MarkerSize', 5, ...
            'MarkerFaceColor', [1, 0.4, 0.8], 'MarkerEdgeColor', 'm');

    % 在图下方空白区域添加椭球中心坐标和 center0_render
    annotation('textbox', [0.1, 0.02, 0.8, 0.25], 'String', ...
        sprintf(['red\x2605 fit center: [%.2f, %.2f] hue:%.2f\n ' ...
        'pink square PMCC: [%.2f, %.2f]' ...
        '45° Line: y = x\n' ...
        'o: render points \n'], ...
         center(2), center(1), atan2d(center(3),center(2)) , ...
         lab_PMCC(2), lab_PMCC(1)), ...
        'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
        'BackgroundColor', 'white', 'EdgeColor', 'black', 'FontSize', 6);
    xlabel('a');
    ylabel('L');

    axis equal;
    xlim([min(scatter_a)-5,max(scatter_a)+5]);
    ylim([min(scatter_L)-15,max(scatter_L)+15]);
    
    title(strcat('L\_a ',scene_name));

    hold on;

    saveas(gcf, fullfile(output_folder,'L_a', strcat('L_a', scene_name,'.jpg')));


        % L_b
    figure(3);
    subplot('Position', [0.1, 0.4, 0.8, 0.55]); % 调整绘制区域位置和尺寸
    
    check_data1 = center(1) + (-20:0.2:20);
    check_data3 = center(3) + (-20:0.2:20);
    [data1, data3] = meshgrid(check_data1, check_data3);

    % 计算 y 的值

    f=    mu(1).*(data1-center(1)).^2+...
    mu(3).*(data1-center(1)).*(data3-center(3))+...
    mu(6).*(data3-center(3)).^2;

    contour(data3, data1, f, [0, rho], 'Linewidth', 2);
    hold on;

    % scatter  
    scatter(scatter_b, scatter_L, 10,  'o','LineWidth', 0.5);

        % 标注中心
    plot(center(3), center(1), 'p', 'MarkerSize', 5, 'MarkerFaceColor', 'r','Color','r');
    plot(lab_PMCC(3), lab_PMCC(1),  's', 'MarkerSize', 5, ...
            'MarkerFaceColor', [1, 0.4, 0.8], 'MarkerEdgeColor', 'm');

    % 在图下方空白区域添加椭球中心坐标和 center0_render
    annotation('textbox', [0.1, 0.02, 0.8, 0.25], 'String', ...
        sprintf(['red\x2605 fit center: [%.2f, %.2f] hue:%.2f\n ' ...
        'pink square PMCC: [%.2f, %.2f]' ...
        '45° Line: y = x\n' ...
        'o: render points \n'], ...
         center(3), center(1), atan2d(center(3),center(2)) , ...
         lab_PMCC(3), lab_PMCC(1)), ...
        'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
        'BackgroundColor', 'white', 'EdgeColor', 'black', 'FontSize', 6);
    xlabel('b');
    ylabel('L');

    axis equal;
    xlim([min(scatter_b)-5,max(scatter_b)+5]);
    ylim([min(scatter_L)-15,max(scatter_L)+15]);
    
    title(strcat('L\_b ',scene_name));

    hold on;

    saveas(gcf, fullfile(output_folder, 'L_b',strcat('L_b', scene_name,'.jpg')));

end