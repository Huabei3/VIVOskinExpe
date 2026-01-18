function contour95ellip(center, mu, lab_group, rho, output_folder, save_pic_name, color,variable,ori_lab_mean)
    lab_PMCC = [62.11, 18.96, 19.76];
    lab_PMCC(4)=sqrt(lab_PMCC(2).^2+lab_PMCC(3).^2);
    scatter_L = lab_group(:, 1);
    scatter_a = lab_group(:, 2);
    scatter_b = lab_group(:, 3);
    scatter_C = sqrt(lab_group(:, 2).^2+lab_group(:, 3).^2);
    scatter_h = atan2d(lab_group(:, 2),lab_group(:, 3));
    center(4)=sqrt(center(2).^2+center(3).^2);
    ori_lab_mean(4)=sqrt(ori_lab_mean(2).^2+ori_lab_mean(3).^2);



    if size(lab_group,1)<3
        h1 = figure(1);
        grid on;box on;
        hold on;
        scatter(ori_lab_mean(2), ori_lab_mean(3), 20, '+', 'LineWidth', 1, ...
        'MarkerEdgeColor',color);
        % 标注中心
        plot(center(2), center(3), 'p', 'MarkerSize', 5, ...
            'MarkerFaceColor', color, 'Color', color);

        h2 = figure(2);
        grid on;box on;
        hold on;
        scatter(ori_lab_mean(2), ori_lab_mean(1),20, '+', 'LineWidth', 1, ...
        'MarkerEdgeColor',color);
        % 标注中心
        plot(center(2), center(1), 'p', 'MarkerSize', 5, ...
            'MarkerFaceColor', color, 'Color', color);

        h3 = figure(3);
        grid on;box on;
        hold on;
        scatter(ori_lab_mean(3), ori_lab_mean(1), 20, '+', 'LineWidth', 1, ...
        'MarkerEdgeColor',color);
        % 标注中心
        plot(center(3), center(1), 'p', 'MarkerSize', 5, ...
            'MarkerFaceColor', color, 'Color', color);
        return
    end


    % a-b
    h1 = figure(1);
    grid on;box on;hold on;
    
    check_data2 = center(2) + (-20:0.2:20);
    check_data3 = center(3) + (-20:0.2:20);
    [data2, data3] = meshgrid(check_data2, check_data3);

    % 计算 f 的值
    f = mu(4) .* (data2 - center(2)).^2 + ...
        mu(5) .* (data2 - center(2)) .* (data3 - center(3)) + ...
        mu(6) .* (data3 - center(3)).^2;
    if ~strcmp(variable,"models")
        contour(data2, data3, f, [0, rho], 'Linewidth', 1, 'Color', color);
    end
    

    % scatter
    scatter(ori_lab_mean(2), ori_lab_mean(3), 20, '+', 'LineWidth', 1, ...
        'MarkerEdgeColor',color);

    % 标注中心
    plot(center(2), center(3), 'p', 'MarkerSize', 5, 'MarkerFaceColor', color, 'Color', color);
    plot(lab_PMCC(2), lab_PMCC(3), 's', 'MarkerSize', 5, ...
        'MarkerFaceColor', [1, 0.4, 0.8], 'MarkerEdgeColor', 'm');

    % 设置 xlabel 和 ylabel 为斜体
    xlabel('\textit{a*}', 'Interpreter', 'latex', 'FontSize', 12*2);
    ylabel('\textit{b*}', 'Interpreter', 'latex', 'FontSize', 12*2);

    % 设置标题为斜体
    title('\textit{a*-b*}', 'Interpreter', 'latex', 'FontSize', 12*2);

    % 设置坐标轴范围
    axis equal;
    if strcmp(variable,"makeup")
        max_lim = 30;
        min_lim = 15;
    elseif strcmp(variable,"gender")
        max_lim = round(max(max(scatter_a), max(scatter_b)))+10;
        min_lim = round(min(min(scatter_a), min(scatter_b)))-10;
    elseif strcmp(variable,"scene")
        max_lim = 45;
        min_lim = 0;
    else
        max_lim = max(max(scatter_a), max(scatter_b))+15;
        min_lim = min(min(scatter_a), min(scatter_b))-15;
    end
    x = linspace(min_lim, max_lim, 1000);
    y = x;
    plot(x, y);
    
    hAx1 = findobj(h1, 'Type', 'axes'); 
    interval=5;
    xticks(min_lim:interval:max_lim)
    yticks(min_lim:interval:max_lim)
    xlim([min_lim, max_lim]);
    ylim([min_lim, max_lim]);
    
    hold on;
    
    % 保存图像
    if strcmp(variable,"adj_D")
        exportgraphics(gcf, fullfile(output_folder, strcat(save_pic_name,'a_b.jpg')), ...
            'Resolution', 300);
    else
        exportgraphics(gcf, fullfile(output_folder, strcat('a_b.jpg')), ...
            'Resolution', 300);
    end
%%
%     % L-a
    h2=figure(2);hold on;
    grid on;box on;
    check_data1 = center(1) + (-20:0.2:20);
    check_data2 = center(2) + (-20:0.2:20);

    [data1, data2] = meshgrid(check_data1, check_data2);

    % 计算 f 的值
    f = mu(1) .* (data1 - center(1)).^2 + ...
        mu(2) .* (data1 - center(1)) .* (data2 - center(2)) + ...
        mu(4) .* (data2 - center(2)).^2;
    if ~strcmp(variable,"models")
        contour(data2, data1, f, [0, rho], 'Linewidth', 1, 'Color', color);
    end


    % scatter
    scatter(ori_lab_mean(2), ori_lab_mean(1), 20, '+', 'LineWidth', 1, ...
       'MarkerEdgeColor',color);

    % 标注中心
    plot(center(2), center(1), 'p', 'MarkerSize', 5, 'MarkerFaceColor', color, 'Color', color);
    plot(lab_PMCC(2), lab_PMCC(1), 's', 'MarkerSize', 5, ...
        'MarkerFaceColor', [1, 0.4, 0.8], 'MarkerEdgeColor', 'm');

    % 设置 xlabel 和 ylabel 为斜体
    xlabel('\textit{a*}', 'Interpreter', 'latex', 'FontSize', 12*2);
    ylabel('\textit{L*}', 'Interpreter', 'latex', 'FontSize', 12*2);

    % 设置标题为斜体
    title('\textit{L*-a*}', 'Interpreter', 'latex', 'FontSize', 12*2);

    % 设置坐标轴范围
    hAx2 = findobj(h2, 'Type', 'axes');   
    axis equal;
    if strcmp(variable,"makeup")
        x_min_lim = round(min(scatter_a)) - 5; 
        x_max_lim = round(max(scatter_a)) + 5;
        y_min_lim = round(min(scatter_L)) - 5; 
        y_max_lim = round(max(scatter_L)) + 5;
    elseif strcmp(variable,"gender")
        x_min_lim = round(min(scatter_a)) - 10; 
        x_max_lim = round(max(scatter_a)) + 10;
        y_min_lim = round(min(scatter_L)) - 10; 
        y_max_lim = round(max(scatter_L)) + 10; 
    elseif strcmp(variable,"scene")
        x_min_lim = round(min(scatter_a)) - 15; 
        x_max_lim = round(max(scatter_a)) + 15;
        y_min_lim = round(min(scatter_L)) - 15; 
        y_max_lim = round(max(scatter_L)) + 15;   
    elseif strcmp(variable,"compare")
        x_min_lim = 0; x_max_lim = 30;
        y_min_lim = min(scatter_L) - 5; y_max_lim = max(scatter_L) + 5;    
    else
        x_min_lim = 0;x_max_lim = 30;
        y_min_lim = min(scatter_L) - 15;y_max_lim = max(scatter_L) + 15;
    end    
    xlim([x_min_lim, x_max_lim]);
    ylim([y_min_lim, y_max_lim]);    
    interval = 5;
    xticks(x_min_lim:interval:x_max_lim);
    yticks(y_min_lim:interval:y_max_lim);

    % 保存图像
    if strcmp(variable,"adj_D")
        exportgraphics(gcf, fullfile(output_folder, strcat(save_pic_name,'L_a.jpg')), 'Resolution', 300);
    else
        exportgraphics(gcf, fullfile(output_folder, strcat('L_a.jpg')), ...
            'Resolution', 300);
    end
%
    % L-b
    h3=figure(3);hold on;
    grid on;box on;

    check_data1 = center(1) + (-20:0.2:20);
    check_data3 = center(3) + (-20:0.2:20);
    [data1, data3] = meshgrid(check_data1, check_data3);

    % 计算 f 的值
    f = mu(1) .* (data1 - center(1)).^2 + ...
        mu(3) .* (data1 - center(1)) .* (data3 - center(3)) + ...
        mu(6) .* (data3 - center(3)).^2;
    if ~strcmp(variable,"models")
        contour(data3, data1, f, [0, rho], 'Linewidth', 1, 'Color', color);
    end


    % scatter
    scatter(ori_lab_mean(3), ori_lab_mean(1), 20, '+', 'LineWidth', 1, ...
        'MarkerEdgeColor',color);

    % 标注中心
    plot(center(3), center(1), 'p', 'MarkerSize', 5, 'MarkerFaceColor', color, 'Color', color);
    plot(lab_PMCC(3), lab_PMCC(1), 's', 'MarkerSize', 5, ...
        'MarkerFaceColor', [1, 0.4, 0.8], 'MarkerEdgeColor', 'm');

    % 设置 xlabel 和 ylabel 为斜体
    xlabel('\textit{b*}', 'Interpreter', 'latex', 'FontSize', 12*2);
    ylabel('\textit{L*}', 'Interpreter', 'latex', 'FontSize', 12*2);

    % 设置标题为斜体
    title(['\textit{L*-b* }'], 'Interpreter', 'latex', 'FontSize', 12*2);

    % 设置坐标轴范围
    hAx3 = findobj(h3, 'Type', 'axes'); 
    axis equal;
    if strcmp(variable,"makeup")
        x_min_lim = round(min(scatter_b)) - 5; 
        x_max_lim = round(max(scatter_b)) + 5;
        y_min_lim = round(min(scatter_L)) - 5; 
        y_max_lim = round(max(scatter_L)) + 5;
    elseif strcmp(variable,"gender")
        x_min_lim = round(min(scatter_b)) - 10; 
        x_max_lim = round(max(scatter_b)) + 10;
        y_min_lim = round(min(scatter_L)) - 10; 
        y_max_lim = round(max(scatter_L)) + 10;
    elseif strcmp(variable,"scene")
        x_min_lim = round(min(scatter_b)) - 15; 
        x_max_lim = round(max(scatter_b)) + 15;
        y_min_lim = round(min(scatter_L)) - 15; 
        y_max_lim = round(max(scatter_L)) + 15;
    else
        x_min_lim = 0; x_max_lim = 30;
        y_min_lim = min(scatter_L) - 15; y_max_lim = max(scatter_L) + 15;
    end    
    xlim([x_min_lim, x_max_lim]);
    ylim([y_min_lim, y_max_lim]);    
    interval = 5;
    xticks(x_min_lim:interval:x_max_lim);
    yticks(y_min_lim:interval:y_max_lim);


    % 保存图像
    if strcmp(variable,"adj_D")
        exportgraphics(gcf, fullfile(output_folder, strcat(save_pic_name,'L_b.jpg')), ...
            'Resolution', 300);
    else
        exportgraphics(gcf, fullfile(output_folder, strcat('L_b.jpg')), ...
            'Resolution', 300);
    end

%%
    % L-C
    h4=figure(4);hold on;
    grid on;box on;
 
    % scatter
    scatter(ori_lab_mean(4), ori_lab_mean(1), 20, '+', 'LineWidth', 1, ...
       'MarkerEdgeColor',color);

    % 标注中心
    plot(center(4), center(1), 'p', 'MarkerSize', 5, 'MarkerFaceColor', color, 'Color', color);
    plot(lab_PMCC(4), lab_PMCC(1), 's', 'MarkerSize', 5, ...
        'MarkerFaceColor', [1, 0.4, 0.8], 'MarkerEdgeColor', 'm');

    % 设置 xlabel 和 ylabel 为斜体
    xlabel('\textit{C*}', 'Interpreter', 'latex', 'FontSize', 12*2);
    ylabel('\textit{L*}', 'Interpreter', 'latex', 'FontSize', 12*2);

    % 设置标题为斜体
    title('\textit{L*-C*}', 'Interpreter', 'latex', 'FontSize', 12*2);

    % 设置坐标轴范围
    hAx4 = findobj(h4, 'Type', 'axes');   
    axis equal;
    if strcmp(variable,"makeup")
        x_min_lim = round(min(scatter_C)) - 5; 
        x_max_lim = round(max(scatter_C)) + 5;
        y_min_lim = round(min(scatter_L)) - 5; 
        y_max_lim = round(max(scatter_L)) + 5;
        interval = 5;
    elseif strcmp(variable,"gender")
        x_min_lim = round(min(scatter_C)) - 10; 
        x_max_lim = round(max(scatter_C)) + 10;
        y_min_lim = round(min(scatter_L)) - 10; 
        y_max_lim = round(max(scatter_L)) + 10;
        interval = 5;
    elseif strcmp(variable,"scene")
        x_min_lim = 20; x_max_lim = 40;
        y_min_lim = 50; y_max_lim = 70;
        interval = 5;
    elseif strcmp(variable,"compare")
        x_min_lim = 0; x_max_lim = 30;
        y_min_lim = min(scatter_L) - 5; y_max_lim = max(scatter_L) + 5;
        interval = 5;
    else
        x_min_lim = 0; x_max_lim = 30;
        y_min_lim = min(scatter_L) - 15; y_max_lim = max(scatter_L) + 15;
        interval = 5;
    end    
    xlim([x_min_lim, x_max_lim]);
    ylim([y_min_lim, y_max_lim]);
    xticks(x_min_lim:interval:x_max_lim);
    yticks(y_min_lim:interval:y_max_lim);
    
    
    % 保存图像
    if strcmp(variable,"adj_D")
        exportgraphics(gcf, fullfile(output_folder, strcat(save_pic_name,'L_C.jpg')), 'Resolution', 300);
    else
        exportgraphics(gcf, fullfile(output_folder, strcat('L_C.jpg')), ...
            'Resolution', 300);
    end
  
end