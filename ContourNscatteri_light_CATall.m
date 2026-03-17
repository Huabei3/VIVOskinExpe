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

lastPart = 'male59i';
Dtype='summer';
save_folder = fullfile("ellip_pic\ellipse", lastPart, Dtype,"combined_light_contours");

% 创建保存文件夹
if ~exist(save_folder, "dir")
    mkdir(save_folder);
end

lab_PMCC = [62.11, 18.96, 19.76];
labC_PMCC = [lab_PMCC, sqrt(lab_PMCC(1, 2)^2 + lab_PMCC(1, 3)^2)];

model = lastPart(1:end-1);
[lastPart1, model1] = gen_lastPart1(lastPart);
lastPart_new=gen_lastPart_new(lastPart1);
disp([lastPart,lastPart_new])
average_file = strcat("..\renderCode\aveSkinByHand2\", lastPart_new, "\autoNhand_scaleoverLUT.mat");
average = load(average_file);
average = average.average_lab_all(:, 1:3);

wd65_64 = [94.811, 100.00, 107.304];
CT = [3000, 4000, 5000, 6000, 7000, 8000, 6500, ...
      3000, 4000, 5000, 6000, 7000, 8000, 6500, ...
      3000, 4000, 5000, 6000, 7000, 8000, 6500]';
line_style={'-',':','-.'};
plot_style={'^','<','v'};
% 定义色环上的 7 种颜色
colors = hsv(7); % 使用 hsv 色图生成 7 种颜色

%% 统计所有图的公共 lim_min 和 lim_max
lim_min = inf;
lim_max = -inf;
for attribute = attributes
    fprintf('Processing attribute: %d\n', attribute);
    
    % 生成 attribute_serial
    attribute_serial = strcat(sprintf("%02d", attribute), attribute_names(attribute));
    
    % 定义路径
    source_file1 = fullfile('AlalyseResults', Dtype,lastPart, attribute_serial, 'ellipPara', 'fitRes_level.mat');
    source_file2 = fullfile('AlalyseResults', Dtype,lastPart, 'model_group', attribute_serial, 'ellipPara', 'fitRes_level.mat');
    source_file3 = fullfile('AlalyseResults',Dtype ,lastPart, 'model', attribute_serial, 'ellipPara', 'fitRes_level.mat');
    source_file4 = fullfile('AlalyseResults', Dtype,lastPart, 'all', attribute_serial, 'ellipPara', 'fitRes_level.mat'); % 新增 source_file4
    
    % 加载数据
    if exist(source_file4, 'file') % 新增 source_file4 的加载
        load(source_file4);
        par_all4 = par_all;
    end
    
    % 循环处理每个 i_para
    for i_para = 1:21

        if exist('par_all4', 'var') % 新增 source_file4 的处理
            par = par_all4(i_para, :);
            check_data2 = par(4) + (-30:0.2:30);
            check_data3 = par(5) + (-30:0.2:30);
            [data2, data3] = meshgrid(check_data2, check_data3);
            y = (1 ./ (1 + par(6) * exp(sqrt(par(1) * (data2 - par(4)).^2 + par(2) * (data3 - par(5)).^2 + ...
                par(3) * (data2 - par(4)) .* (data3 - par(5)))))) .* ((par(1) * (data2 - par(4)).^2 + ...
                par(2) * (data3 - par(5)).^2 + par(3) * (data2 - par(4)) .* (data3 - par(5))) >= 0);
            lim_min = min(lim_min, min(data2(y >= 0.5)));
            lim_max = max(lim_max, max(data2(y >= 0.5)));
            lim_min = min(lim_min, min(data3(y >= 0.5)));
            lim_max = max(lim_max, max(data3(y >= 0.5)));
        end
    end
end

%% 循环处理每个 attribute
% for attribute = [10]
for attribute = attributes
    fprintf('Processing attribute: %d\n', attribute);
    
    % 生成 attribute_serial
    attribute_serial = strcat(sprintf("%02d", attribute), attribute_names(attribute));
    
    % 定义路径
    source_file1 = fullfile('AlalyseResults', lastPart, attribute_serial, 'ellipPara', 'fitRes_level.mat');
    source_file2 = fullfile('AlalyseResults', lastPart, 'model_group', attribute_serial, 'ellipPara', 'fitRes_level.mat');
    source_file3 = fullfile('AlalyseResults', lastPart, 'model', attribute_serial, 'ellipPara', 'fitRes_level.mat');
    source_file4 = fullfile('AlalyseResults', lastPart, 'all', attribute_serial, 'ellipPara', 'fitRes_level.mat'); % 新增 source_file4
    
    % 加载数据
    par_all4=[];
    if exist(source_file4, 'file') % 新增 source_file4 的加载
        load(source_file4);
        par_all4 = par_all;
    else
        par_all4=[];
    end
    
     
        % 创建新图窗
        figure;
        hold on;
        set(gcf, 'Color', 'white');
        
        % 循环处理当前 light_level 的 i_para
        for i_para = 1:21

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

                % 否则，使用 '-' 线型绘制等高线图
                check_data2 = par(4) + (-30:0.2:30);
                check_data3 = par(5) + (-30:0.2:30);
                [data2, data3] = meshgrid(check_data2, check_data3);
                y = (1 ./ (1 + par(6) * exp(sqrt(par(1) * (data2 - par(4)).^2 + par(2) * (data3 - par(5)).^2 + ...
                    par(3) * (data2 - par(4)) .* (data3 - par(5)))))) .* ((par(1) * (data2 - par(4)).^2 + ...
                    par(2) * (data3 - par(5)).^2 + par(3) * (data2 - par(4)) .* (data3 - par(5))) >= 0);
                light_level=floor((i_para-1)/ 7)+1;
                contour(data2, data3, y, [0.5, 1], 'Linewidth', 1, 'Color', colors(mod(i_para-1, 7)+1, :), ...
                    'DisplayName', picname_group(i_para), 'LineStyle', line_style{light_level});
                scatter(par(4), par(5), 30, plot_style{light_level}, 'filled', 'MarkerFaceColor', colors(mod(i_para-1, 7)+1, :));

            end
            
            % 绘制 PMCC 点
            plot(labC_PMCCpre(i_para, 2), labC_PMCCpre(i_para, 3), 's', 'MarkerSize', 10, ...
                'MarkerFaceColor', 'm', 'MarkerEdgeColor', 'm');

        end
        
        % 添加图例、标签和标题
        xlabel('{\ita*}');
        ylabel('{\itb*}');
        title(strcat(attribute_names(attribute)));
        
        % 设置坐标轴范围
        % xlim([lim_min, lim_max]);
        % ylim([lim_min, lim_max]);
        xlim([-20, 60]);
        ylim([-20, 60]);
        
        % 保存图像
        if ~exist(fullfile(save_folder), "dir")
            mkdir(fullfile(save_folder));
        end
        exportgraphics(gcf, fullfile(save_folder, strcat(attribute_serial, '.jpg')), 'Resolution', 300);
        close(gcf);

end


concatenate_images1(fullfile(save_folder ),5);


%% 绘制图例图
figure;
hold on;
set(gcf, 'Color', 'white');

% 设置图例图的位置和大小
axis([0 70 0 6]); % 增加 y 轴范围以容纳更多内容
axis off;

% 定义图例的 7 个颜色块和对应的名字
legend_names = ["3k", "4k", "5k", "6k", "7k", "8k", "d65"];
legend_colors = hsv(7); % 使用 hsv 色图生成 7 种颜色

% 绘制颜色块和对应的名字
for i = 1:length(legend_names)
    % 计算当前行和列
    row = mod(i - 1, 3) + 1; % 每列 3 个
    col = floor((i - 1) / 3) + 1; % 共 3 列
    
    % 绘制颜色块
    rectangle('Position', [2 + (col - 1) * 8, row, 1, 0.8], 'FaceColor', legend_colors(i, :), 'EdgeColor', 'k');
    % 添加名字文本
    text(3.5 + (col - 1) * 8, row + 0.5, legend_names(i), 'FontSize', 12, 'VerticalAlignment', 'middle');
end





% 绘制上三角形 + "model-group"
plot(2, 4.5, '^', 'MarkerSize', 8, 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k');
text(3.5, 4.5, 'high-luminance', 'FontSize', 8, 'VerticalAlignment', 'middle');


plot(2, 5, '<', 'MarkerSize', 8, 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k');
text(3.5, 5, 'mid-luminance', 'FontSize', 8, 'VerticalAlignment', 'middle');


plot(2, 5.5, 'v', 'MarkerSize', 8, 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k');
text(3.5, 5.5, 'low-luminance', 'FontSize', 8, 'VerticalAlignment', 'middle');
%PMCC
plot(14, 4, 's', 'MarkerSize', 8, 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k');
text(15, 4, 'PMCC', 'FontSize', 8, 'VerticalAlignment', 'middle');

line([10, 14], [4.5, 4.5], 'Color', 'k', 'LineWidth', 2, 'LineStyle', '-');
text(15, 4.5, 'high-luminance', 'FontSize', 8, 'VerticalAlignment', 'middle');


line([10, 14], [5, 5], 'Color', 'k', 'LineWidth', 2, 'LineStyle', '-.');
text(15, 5, 'mid-luminance', 'FontSize', 8, 'VerticalAlignment', 'middle');


line([10, 14], [5.5, 5.5], 'Color', 'k', 'LineWidth', 2, 'LineStyle', ':');
text(15, 5.5, 'low-luminance', 'FontSize', 8, 'VerticalAlignment', 'middle');


% 调整图窗大小以确保所有内容可见
set(gcf, 'Position', [100, 100, 1200, 600]); % 设置图窗宽度为 1200，高度为 400

% 保存图例图
if ~exist(fullfile(save_folder, "legend"), "dir")
    mkdir(fullfile(save_folder, "legend"));
end
exportgraphics(gcf, fullfile(save_folder, "legend", strcat(lastPart, '_lights_legend.jpg')), 'Resolution', 300);

close(gcf);