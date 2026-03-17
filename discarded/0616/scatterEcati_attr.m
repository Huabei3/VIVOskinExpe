close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量

%% 定义所有需要处理的 attribute
attributes = [1, 2, 3, 4, 5, 6,7, 8, 9,10];
attribute_names = ["Preference", "Attractiveness", "Feminine", "Cooperative", ...
    "Youth", "Healthy", "Precise reproduction","suit the environment or not", "white-skinned", "ruddy"];
picname_group=["h3k","h4k","h5k","h6k","h7k","h8k","hd65",...
    "l3k","l4k","l5k","l6k","l7k","l8k","ld65",...
    "m3k","m4k","m5k","m6k","m7k","m8k","md65"];
    wd65_64 = [94.811, 100.00, 107.304];
CT = [3000, 4000, 5000, 6000, 7000, 8000, 6500, ...
      3000, 4000, 5000, 6000, 7000, 8000, 6500, ...
      3000, 4000, 5000, 6000, 7000, 8000, 6500]';
line_style={'-',':','-.'};
plot_style={'^','<','v'};
% 定义色环上的 7 种颜色
colors = hsv(10); % 使用 hsv 色图生成 7 种颜色
lastParts = {'female78i', 'female41i', 'femalevivoi', 'male59i', 'male39i', 'malevivoi'};
Dtype='summer';
for lastPart_idx = 1:length(lastParts)
    lastPart = lastParts{lastPart_idx};
    save_folder = fullfile("ellip_pic\ellipse",  Dtype,"scatterCen","HD65attr");
    
    % 创建保存文件夹
    if ~exist(save_folder, "dir")
        mkdir(save_folder);
    end
    
    lab_PMCC = [62.11, 18.96, 19.76];
    labC_PMCC = [lab_PMCC, sqrt(lab_PMCC(1, 2)^2 + lab_PMCC(1, 3)^2)];
    
    model = lastPart(1:end-1);
    average_file = strcat("aveSkin", lastPart, "\autoNhand_scaleoverLUT.mat");
    average = load(average_file);
    average = average.average_lab_all(:, 1:3);

    % 创建新图窗
    figure;
    hold on;
    set(gcf, 'Color', 'white');
    %% 循环处理每个 attribute
    % for attribute = [10]
    for attribute = attributes
        fprintf('Processing attribute: %d\n', attribute);
        
        % 生成 attribute_serial
        attribute_serial = strcat(sprintf("%02d", attribute), attribute_names(attribute));
        
        % 定义路径
        source_file1 = fullfile('AnalyseResults', Dtype,lastPart,'non_model' ,attribute_serial, 'ellipPara', 'fitRes_level.mat');
        source_file2 = fullfile('AnalyseResults', Dtype,lastPart, 'model_group', attribute_serial, 'ellipPara', 'fitRes_level.mat');
        source_file3 = fullfile('AnalyseResults',Dtype, lastPart, 'model', attribute_serial, 'ellipPara', 'fitRes_level.mat');
        source_file4 = fullfile('AnalyseResults',Dtype, lastPart, 'all', attribute_serial, 'ellipPara', 'fitRes_level.mat'); % 新增 source_file4
        
        % 加载数据
        par_all4=[];
        if exist(source_file4, 'file') % 新增 source_file4 的加载
            load(source_file4);
            par_all4 = par_all;
        else
            par_all4=[];
        end

            % 循环处理当前 light_level 的 i_para
            for i_para = [5]
    
                % 计算 labC_PMCCpre
                if average(i_para, 1) <= 60
                    C_pre = 6.7421 * log(average(i_para, 1)) - 9.9816; % 亮度实验
                else
                    C_pre = 6.7421 * log(60) - 9.9816; % 亮度实验
                end
                labC_PMCCpre(i_para, 1) = average(i_para, 1);
                labC_PMCCpre(i_para, 2:3) = lab_PMCC(1, 2:3) ./ labC_PMCC(1, 4) .* C_pre;
                labC_PMCCpre(i_para, 4) = C_pre;
    
    
                % 绘制 source_file4 的 contour 或散点图 (新增部分)
                if exist('par_all4', 'var')&&~isempty(par_all4)
                    par = par_all4(i_para, :);
    
                    
                    scatter(par(4), par(5), 30, 'o','filled', ...
                        'MarkerFaceColor', colors(attribute, :));
                    attribute_char=char(attribute_serial);
                    text(par(4), par(5), ...
                        attribute_char(1:2), 'FontSize', 7, ...
                        'VerticalAlignment', 'middle');
    
                end
                
                % 绘制 PMCC 点
                plot(labC_PMCCpre(i_para, 2), labC_PMCCpre(i_para, 3), 's', 'MarkerSize', 10, ...
                    'MarkerFaceColor', 'm', 'MarkerEdgeColor', 'm');
    
            end
            
    
    
    end
    
    % 添加图例、标签和标题
    xlabel('{\ita*}');
    ylabel('{\itb*}');

    title(lastPart);
    
    % 设置坐标轴范围
    x = linspace(0, 25, 100); % 从 -10 到 10，生成 100 个点
    plot(x, x); % 'r-' 表示红色实线
    axis equal;
    xlim([3, 20]);
    ylim([5, 18]);
    
    
    % 保存图像
    if ~exist(fullfile(save_folder), "dir")
        mkdir(fullfile(save_folder));
    end
    
    exportgraphics(gcf, fullfile(save_folder, strcat(lastPart, '.jpg')), 'Resolution', 300);
    close(gcf);
    concatenate_images1(fullfile(save_folder ),3);

end
%% 绘制图例图
figure;
hold on;
set(gcf, 'Color', 'white');

% 设置图例图的位置和大小
axis([0 70 0 6]); % 增加 y 轴范围以容纳更多内容
axis off;

% 定义图例的 7 个颜色块和对应的名字
legend_names =["Preference", "Attractiveness", "Feminine", "Cooperative", ...
    "Youth", "Healthy", "Fidelity","Harmony", "Fair", "Ruddy"];
legend_colors = hsv(10); % 使用 hsv 色图生成 7 种颜色

% 绘制颜色块和对应的名字
for i = 1:length(legend_names)
    % 计算当前行和列
    row = mod(i - 1, 3) + 1; % 每列 3 个
    col = floor((i - 1) / 3) + 1; % 共 3 列
    
    % 绘制颜色块
    rectangle('Position', [2 + (col - 1) * 8, row, 1, 0.8], 'FaceColor', legend_colors(i, :), 'EdgeColor', 'k');
    % 添加名字文本
    text(3.5 + (col - 1) * 8, row + 0.5, legend_names(i), 'FontSize', 8, 'VerticalAlignment', 'middle');
end




% 
% % 绘制上三角形 + "model-group"
% plot(2, 4.5, '^', 'MarkerSize', 8, 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k');
% text(3.5, 4.5, 'high-luminance', 'FontSize', 8, 'VerticalAlignment', 'middle');
% 
% 
% plot(2, 5, '<', 'MarkerSize', 8, 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k');
% text(3.5, 5, 'mid-luminance', 'FontSize', 8, 'VerticalAlignment', 'middle');
% 
% 
% plot(2, 5.5, 'v', 'MarkerSize', 8, 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k');
% text(3.5, 5.5, 'low-luminance', 'FontSize', 8, 'VerticalAlignment', 'middle');
% %PMCC
% plot(14, 4, 's', 'MarkerSize', 8, 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k');
% text(15, 4, 'PMCC', 'FontSize', 8, 'VerticalAlignment', 'middle');
% 
% line([10, 14], [4.5, 4.5], 'Color', 'k', 'LineWidth', 2, 'LineStyle', '-');
% text(15, 4.5, 'high-luminance', 'FontSize', 8, 'VerticalAlignment', 'middle');
% 
% 
% line([10, 14], [5, 5], 'Color', 'k', 'LineWidth', 2, 'LineStyle', '-.');
% text(15, 5, 'mid-luminance', 'FontSize', 8, 'VerticalAlignment', 'middle');
% 
% 
% line([10, 14], [5.5, 5.5], 'Color', 'k', 'LineWidth', 2, 'LineStyle', ':');
% text(15, 5.5, 'low-luminance', 'FontSize', 8, 'VerticalAlignment', 'middle');


% 调整图窗大小以确保所有内容可见
set(gcf, 'Position', [100, 100, 1200, 600]); % 设置图窗宽度为 1200，高度为 400

% 保存图例图
if ~exist(fullfile(save_folder, "legend"), "dir")
    mkdir(fullfile(save_folder, "legend"));
end
exportgraphics(gcf, fullfile(save_folder, "legend", strcat(lastPart, '_lights_legend.jpg')), 'Resolution', 300);

close(gcf);