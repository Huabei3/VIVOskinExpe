function contour50ellip(par, color, output_folder, variable, ori_lab_mean, interpreter_type)
    % 参数说明：
    % par: 参数向量
    % color: 颜色
    % output_folder: 输出文件夹路径
    % variable: 变量类型标识
    % ori_lab_mean: 原始Lab数据均值
    % interpreter_type: "tex" 或 "latex"，控制坐标轴标签解释器
    
    lab_PMCC = [62.11, 18.96, 19.76];
    lab_PMCC(4) = sqrt(lab_PMCC(2).^2 + lab_PMCC(3).^2);
    
    
    % 计算中心点
    center = [par(5), par(6), par(7)]; % 假设par(5)=L*, par(6)=a*, par(7)=b*
    center(4) = sqrt(center(2).^2 + center(3).^2);
    ori_lab_mean(4) = sqrt(ori_lab_mean(2).^2 + ori_lab_mean(3).^2);
    
    % a-b 平面
    h1 = figure(1);
    grid on; box on; hold on;
    
    check_data2 = par(6) + (-30:0.2:30);
    check_data3 = par(7) + (-30:0.2:30);
    [data2, data3] = meshgrid(check_data2, check_data3);
    
    % 计算轮廓
    y = (1./(1 + par(8) * exp(sqrt(par(2) * (data2 - par(6)).^2 + ...
        par(3) * (data3 - par(7)).^2 + ...
        par(4) * (data2 - par(6)) .* (data3 - par(7)))))) .* ...
        ((par(2) * (data2 - par(6)).^2 + ...
        par(3) * (data3 - par(7)).^2 + ...
        par(4) * (data2 - par(6)) .* (data3 - par(7))) >= 0);
    
    contour(data2, data3, y, [0.5, 1], 'Linewidth', 1, 'LineStyle', '-', 'Color', color);
    
    % 绘制原始数据点
    scatter(ori_lab_mean(2), ori_lab_mean(3), 20, '+', 'LineWidth', 1, ...
        'MarkerEdgeColor', color);
    
    % 标注中心点
    plot(par(6), par(7), 'o', 'MarkerSize', 5, 'MarkerFaceColor', color, 'Color', color);
    
    % 绘制PMCC参考点
    plot(lab_PMCC(2), lab_PMCC(3), 's', 'MarkerSize', 5, ...
        'MarkerFaceColor', [1, 0.4, 0.8], 'MarkerEdgeColor', 'm');
    
    % 设置坐标轴标签和标题
    if strcmp(interpreter_type,"tex")
        xlabel('a*','Interpreter','tex','FontName','Arial','FontAngle','italic', 'FontSize',12*2);
        ylabel('b*','Interpreter','tex','FontName','Arial','FontAngle','italic', 'FontSize',12*2);
    elseif strcmp(interpreter_type,"latex")
        xlabel('\textit{a*}', 'Interpreter', 'latex', 'FontSize', 12*2);
        ylabel('\textit{b*}', 'Interpreter', 'latex', 'FontSize', 12*2);
    end
    % title('\textit{$a^*-b^*$}', 'Interpreter', 'latex', 'FontSize', 12*2);
    
    % 设置坐标轴范围
    axis equal;
    if strcmp(variable, "makeup")
        max_lim = 45;
        min_lim = 0;
    elseif strcmp(variable, "gender")
        max_lim = 45;
        min_lim = 0;
    elseif strcmp(variable, "scene")
        max_lim = 45;
        min_lim = 0;
    else
        max_lim = 45;
        min_lim = 0;
    end
    
    x = linspace(min_lim, max_lim, 1000);
    y_line = x;
    plot(x, y_line,  'LineWidth', 1,'LineStyle','--','Color','k');
    
    interval = 10;
    xticks(min_lim:interval:max_lim);
    yticks(min_lim:interval:max_lim);
    xlim([min_lim, max_lim]);
    ylim([min_lim, max_lim]);
    
    % 保存图像
    img_name=fullfile(output_folder, 'a_b_50.jpg');    
    savefig(gcf, strrep(img_name,'jpg','fig'));
    exportgraphics(gcf, img_name, 'Resolution', 300);
    
    % L-a 平面
    h2 = figure(2);
    hold on;
    grid on; box on;
    
    check_data1 = par(5) + (-30:0.2:30);
    check_data2 = par(6) + (-30:0.2:30);
    [data1, data2] = meshgrid(check_data1, check_data2);
    
    % 计算轮廓
    y = (1./(1 + par(8) * exp(sqrt(par(2) * (data2 - par(6)).^2 + ...
        par(1) * (data1 - par(5)).^2)))) .* ...
        ((par(2) * (data2 - par(6)).^2 + ...
        par(1) * (data1 - par(5)).^2) >= 0);
    
    contour(data2, data1, y, [0.5, 1], 'Linewidth', 1, 'LineStyle', '-', 'Color', color);
    
    % 绘制原始数据点
    scatter(ori_lab_mean(2), ori_lab_mean(1), 20, '+', 'LineWidth', 1, ...
        'MarkerEdgeColor', color);
    
    % 标注中心点
    plot(par(6), par(5), 'o', 'MarkerSize', 5, 'MarkerFaceColor', color, 'Color', color);
    
    % 绘制PMCC参考点
    plot(lab_PMCC(2), lab_PMCC(1), 's', 'MarkerSize', 5, ...
        'MarkerFaceColor', [1, 0.4, 0.8], 'MarkerEdgeColor', 'm');
    
    % 设置坐标轴标签和标题
    if strcmp(interpreter_type,"tex")
        xlabel('a*','Interpreter','tex','FontName','Arial','FontAngle','italic', 'FontSize',12*2);
        ylabel('L*','Interpreter','tex','FontName','Arial','FontAngle','italic', 'FontSize',12*2);
    elseif strcmp(interpreter_type,"latex")
        xlabel('\textit{a*}', 'Interpreter', 'latex', 'FontSize', 12*2);
        ylabel('\textit{L*}', 'Interpreter', 'latex', 'FontSize', 12*2);
    end
    % title('\textit{L*-a*}', 'Interpreter', 'latex', 'FontSize', 12*2);
    
    % 设置坐标轴范围
    axis equal;
    if strcmp(variable, "makeup")
        x_min_lim = round(min(par(6))) - 15;
        x_max_lim = round(max(par(6))) + 15;
        y_min_lim = round(min(par(5))) - 15;
        y_max_lim = round(max(par(5))) + 15;
    elseif strcmp(variable, "gender")
        x_min_lim = round(min(par(6))) - 15;
        x_max_lim = round(max(par(6))) + 15;
        y_min_lim = round(min(par(5))) - 15;
        y_max_lim = round(max(par(5))) + 15;
    elseif strcmp(variable, "scene")
        x_min_lim = round(min(par(6))) - 15;
        x_max_lim = round(max(par(6))) + 15;
        y_min_lim = round(min(par(5))) - 15;
        y_max_lim = round(max(par(5))) + 15;
    elseif strcmp(variable, "compare")
        x_min_lim = 0; x_max_lim = 30;
        y_min_lim = min(par(5)) - 5; y_max_lim = max(par(5)) + 5;
    else
        x_min_lim = round(min(par(6))) - 15;
        x_max_lim = round(max(par(6))) + 15;
        y_min_lim = round(min(par(5))) - 15;
        y_max_lim = round(max(par(5))) + 15;
    end
    
    xlim([x_min_lim, x_max_lim]);
    ylim([y_min_lim, y_max_lim]);
    interval = 10;
    xticks(x_min_lim:interval:x_max_lim);
    yticks(y_min_lim:interval:y_max_lim);
    
    % 保存图像
    img_name=fullfile(output_folder, 'L_a_50.jpg');    
    savefig(gcf, strrep(img_name,'jpg','fig'));
    exportgraphics(gcf, img_name, 'Resolution', 300);
    
    % L-b 平面
    h3 = figure(3);
    hold on;
    grid on; box on;
    
    check_data1 = par(5) + (-30:0.2:30);
    check_data3 = par(7) + (-30:0.2:30);
    [data1, data3] = meshgrid(check_data1, check_data3);
    
    % 计算轮廓
    y = (1./(1 + par(8) * exp(sqrt(par(3) * (data3 - par(7)).^2 + ...
        par(1) * (data1 - par(5)).^2)))) .* ...
        ((par(3) * (data3 - par(7)).^2 + ...
        par(1) * (data1 - par(5)).^2) >= 0);
    
    contour(data3, data1, y, [0.5, 1], 'Linewidth', 1, 'LineStyle', '-', 'Color', color);
    
    % 绘制原始数据点
    scatter(ori_lab_mean(3), ori_lab_mean(1), 20, '+', 'LineWidth', 1, ...
        'MarkerEdgeColor', color);
    
    % 标注中心点
    plot(par(7), par(5), 'o', 'MarkerSize', 5, 'MarkerFaceColor', color, 'Color', color);
    
    % 绘制PMCC参考点
    plot(lab_PMCC(3), lab_PMCC(1), 's', 'MarkerSize', 5, ...
        'MarkerFaceColor', [1, 0.4, 0.8], 'MarkerEdgeColor', 'm');
    
    % 设置坐标轴标签和标题
    if strcmp(interpreter_type,"tex")
        xlabel('b*','Interpreter','tex','FontName','Arial','FontAngle','italic', 'FontSize',12*2);
        ylabel('L*','Interpreter','tex','FontName','Arial','FontAngle','italic', 'FontSize',12*2);
    elseif strcmp(interpreter_type,"latex")
        xlabel('\textit{b*}', 'Interpreter', 'latex', 'FontSize', 12*2);
        ylabel('\textit{L*}', 'Interpreter', 'latex', 'FontSize', 12*2);
    end
    % title('\textit{L*-b*}', 'Interpreter', 'latex', 'FontSize', 12*2);
    
    % 设置坐标轴范围
    axis equal;
    if strcmp(variable, "makeup")
        x_min_lim = round(min(par(7))) - 25;
        x_max_lim = round(max(par(7))) + 25;
        y_min_lim = round(min(par(5))) - 25;
        y_max_lim = round(max(par(5))) + 25;
    elseif strcmp(variable, "gender")
        x_min_lim = round(min(par(7))) - 25;
        x_max_lim = round(max(par(7))) + 25;
        y_min_lim = round(min(par(5))) - 25;
        y_max_lim = round(max(par(5))) + 25;
    elseif strcmp(variable, "scene")
        x_min_lim = round(min(par(7))) - 25;
        x_max_lim = round(max(par(7))) + 25;
        y_min_lim = round(min(par(5))) - 25;
        y_max_lim = round(max(par(5))) + 25;
    else
        x_min_lim = round(min(par(7))) - 25;
        x_max_lim = round(max(par(7))) + 25;
        y_min_lim = round(min(par(5))) - 25;
        y_max_lim = round(max(par(5))) + 25;
    end
    
    xlim([x_min_lim, x_max_lim]);
    ylim([y_min_lim, y_max_lim]);
    interval = 5;
    xticks(x_min_lim:interval:x_max_lim);
    yticks(y_min_lim:interval:y_max_lim);
    
    % 保存图像
    img_name=fullfile(output_folder, 'L_b_50.jpg');    
    savefig(gcf, strrep(img_name,'jpg','fig'));
    exportgraphics(gcf, img_name, 'Resolution', 300);
    
    % L-C 平面
    h4 = figure(4);
    hold on;
    grid on; box on;
    
    % 绘制原始数据点
    scatter(ori_lab_mean(4), ori_lab_mean(1), 20, '+', 'LineWidth', 1, ...
        'MarkerEdgeColor', color);
    
    % 标注中心点
    plot(sqrt(par(6).^2 + par(7).^2), par(5), 'o', 'MarkerSize', 5, ...
        'MarkerFaceColor', color, 'Color', color);
    
    % 绘制PMCC参考点
    plot(lab_PMCC(4), lab_PMCC(1), 's', 'MarkerSize', 5, ...
        'MarkerFaceColor', [1, 0.4, 0.8], 'MarkerEdgeColor', 'm');
    
    % 设置坐标轴标签和标题
    if strcmp(interpreter_type,"tex")
        xlabel('C*','Interpreter','tex','FontName','Arial','FontAngle','italic', 'FontSize',12*2);
        ylabel('L*','Interpreter','tex','FontName','Arial','FontAngle','italic', 'FontSize',12*2);
    elseif strcmp(interpreter_type,"latex")
        xlabel('\textit{C*}', 'Interpreter', 'latex', 'FontSize', 12*2);
        ylabel('\textit{L*}', 'Interpreter', 'latex', 'FontSize', 12*2);
    end
    % title('\textit{L*-C*}', 'Interpreter', 'latex', 'FontSize', 12*2);
    
    % 设置坐标轴范围
    axis equal;
    if strcmp(variable, "makeup")
        x_min_lim = 20; x_max_lim = 40;
        y_min_lim = 50; y_max_lim = 70;
        interval = 5;
    elseif strcmp(variable, "gender")
        x_min_lim = 20; x_max_lim = 40;
        y_min_lim = 50; y_max_lim = 70;
        interval = 5;
    elseif strcmp(variable, "scene")
        x_min_lim = 20; x_max_lim = 40;
        y_min_lim = 50; y_max_lim = 70;
        interval = 5;
    elseif strcmp(variable, "compare")
        x_min_lim = 0; x_max_lim = 30;
        y_min_lim = min(par(5)) - 25; y_max_lim = max(par(5)) + 25;
        interval = 5;
    else
        x_min_lim = 20; x_max_lim = 40;
        y_min_lim = 50; y_max_lim = 70;
        interval = 5;
    end
    
    xlim([x_min_lim, x_max_lim]);
    ylim([y_min_lim, y_max_lim]);
    xticks(x_min_lim:interval:x_max_lim);
    yticks(y_min_lim:interval:y_max_lim);
    
    % 保存图像
    img_name=fullfile(output_folder, 'L_C_50.jpg');    
    savefig(gcf, strrep(img_name,'jpg','fig'));
    exportgraphics(gcf, img_name, 'Resolution', 300);
    
end





% function contour50ellip(par, color,output_folder,variable,ori_lab_mean)
%     lab_PMCC = [62.11, 18.96, 19.76];
%     lab_PMCC(4)=sqrt(lab_PMCC(2).^2+lab_PMCC(3).^2);
%     par(5) = lab_group(:, 1);
%     par(6) = lab_group(:, 2);
%     par(7) = lab_group(:, 3);
%     par(6).^2 + par(7).^2) = sqrt(lab_group(:, 2).^2+lab_group(:, 3).^2);
%     scatter_h = atan2d(lab_group(:, 2),lab_group(:, 3));
%     center(4)=sqrt(center(2).^2+center(3).^2);
%     ori_lab_mean(4)=sqrt(ori_lab_mean(2).^2+ori_lab_mean(3).^2);
%     %%
%     % a-b
%     h1 = figure(1);
%     grid on;box on;hold on;
%     a=par;
%     check_data2 = par(6) + (-30:0.2:30);
%     check_data3 = par(7) + (-30:0.2:30);
%     [data2, data3] = meshgrid(check_data2, check_data3);
%     y = (1./(1 + a(8) * exp(sqrt(a(2) * (data2 - a(6)).^2 + a(3) * (data3 - a(7)).^2 + ...
%     a(4) * (data2 - a(6)) .* (data3 - a(7)))))).*((a(2) * (data2 - a(6)).^2 + ...
%     a(3) * (data3 - a(7)).^2 + a(4) * (data2 - a(6)) .* (data3 - a(7))) >= 0);
%     contour(data2, data3, y, [0.5, 1], 'Linewidth', 1,'LineStyle','-','Color', color);
%     % 标注中心
%     plot(par(6), par(7), 'o', 'MarkerSize', 5, 'MarkerFaceColor', color, 'Color', color);
% 
% 
% %%
% %     % L-a
%     h2=figure(2);hold on;
%     grid on;box on;
%     check_data1 = par(5) + (-30:0.2:30);
%     check_data2 = par(6) + (-30:0.2:30);
% 
%     [data1, data2] = meshgrid(check_data1, check_data2);
%     y = (1./(1 + a(8) * exp(sqrt(a(2) * (data2 - a(6)).^2 + ...
%         a(1) * (data1 - a(5)).^2)))).*((a(2) * (data2 - a(6)).^2 + ...
%         a(1) * (data1 - a(5)).^2) >= 0);
% 
%     contour(data2, data1, y, [0.5, 1], 'Linewidth', 1,'LineStyle','-','Color', color);
%     % 标注中心
%     plot(par(6), par(5), 'o', 'MarkerSize', 5, 'MarkerFaceColor', color, 'Color', color);
% 
% %
%     % L-b
%     h3=figure(3);hold on;
% 
%     check_data1 = par(5) + (-30:0.2:30);
%     check_data3 = par(7) + (-30:0.2:30);
%     [data1, data3] = meshgrid(check_data1, check_data3);
% 
%     y = (1./(1 + a(8) * exp(sqrt(a(3) * (data3 - a(7)).^2 + ...
%         a(1) * (data1 - a(5)).^2)))).*((a(3) * (data3 - a(7)).^2 + ...
%         a(1) * (data1 - a(5)).^2) >= 0);
% 
%     contour(data3, data1, y, [0.5, 1], 'Linewidth', 1,'LineStyle','-','Color', color);
%     % 标注中心
%     plot(par(7), par(5), 'o', 'MarkerSize', 5, 'MarkerFaceColor', color, 'Color', color);
% 
% 
% %%
%     % L-C
%     h4=figure(4);hold on;
% 
%     % 标注中心
%     plot(sqrt(par(6).^2+par(7).^2), par(5), 'o', 'MarkerSize', 5, ...
%         'MarkerFaceColor', color, 'Color', color);
% 
% 
% 
% 
% end