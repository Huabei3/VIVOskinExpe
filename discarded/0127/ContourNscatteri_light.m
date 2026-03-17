close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量

%% 定义所有需要处理的 attribute
attributes = [1, 2, 3, 4, 5, 6, 8, 9,10];
attribute_names = ["Preference", "Attractiveness", "Feminine", "Cooperative", ...
    "Youth", "Healthy", "Precise reproduction","suit the environment or not", "white-skinned", "ruddy"];
picname_group=["h3k","h4k","h5k","h6k","h7k","h8k","hd65",...
    "l3k","l4k","l5k","l6k","l7k","l8k","ld65",...
    "m3k","m4k","m5k","m6k","m7k","m8k","md65"];


lastPart = 'femalevivoi';
save_folder = fullfile("ellip_pic\ellipse", lastPart, "combined_light_contours");

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

colors = hsv(21); % 使用 hsv 色图生成 21 种渐变色
% num_groups = 3;
% num_colors_per_group = 7;
% colors = generate_colors(num_groups, num_colors_per_group);
%% 循环处理每个 attribute

for attribute = attributes
    fprintf('Processing attribute: %d\n', attribute);
    
    % 生成 attribute_serial
    attribute_serial = strcat(sprintf("%02d", attribute), attribute_names(attribute));
    
    % 定义路径
    source_file = fullfile('AlalyseResults', lastPart, attribute_serial, 'ellipPara', 'fitRes_level.mat');
    
    % 加载数据
    load(source_file);
    
    % 创建新图窗
    figure;
    hold on;
    set(gcf, 'Color', 'white');
    min_data2 = inf;
    max_data2 = -inf;
    min_data3 = inf;
    max_data3 = -inf;
    % 循环处理每个 i_para
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

        par = par_all(i_para, :);
        %CAT
        lab_bf(i_para, :) = [average(i_para, 1), par_all(i_para, 4:5)];
        CCT = CT(i_para);
        XYZw_pre(i_para, :) = CCT2xyz(CCT);
        XYZ_bf(i_para, :) = lab2xyz2(lab_bf(i_para, :), 'd65_64');
        [CCT, duv, S_out] = xyz2CCT(XYZw_pre(i_para, :), 10);
        D1 = 0.723 * (1 - 1116 / CCT + 8.64 * duv - 49266 * duv / CCT); % zhai
        D2 = 0.239 * 0.723 * (1 - 1116 / CCT); % summer
        D3 = 0.00005 * CCT + 0.1977; % OPPO
        XYZ_aft(i_para, :) = CAT16_D(XYZ_bf(i_para, :), XYZw_pre, wd65_64, 1);
        XYZ_aft1(i_para, :) = CAT16_D(XYZ_bf(i_para, :), XYZw_pre, wd65_64, D1);
        XYZ_aft2(i_para, :) = CAT16_D(XYZ_bf(i_para, :), XYZw_pre, wd65_64, D2);
        XYZ_aft3(i_para, :) = CAT16_D(XYZ_bf(i_para, :), XYZw_pre, wd65_64, D3);
        lab_aft(i_para, :) = xyz2lab(XYZ_aft(i_para, :), 'd65_64');
        lab_aft1(i_para, :) = xyz2lab(XYZ_aft1(i_para, :), 'd65_64');
        lab_aft2(i_para, :) = xyz2lab(XYZ_aft2(i_para, :), 'd65_64');
        lab_aft3(i_para, :) = xyz2lab(XYZ_aft3(i_para, :), 'd65_64');

        
        % 绘制 contour
        check_data2 = par(4) + (-30:0.2:30);
        check_data3 = par(5) + (-30:0.2:30);
        [data2, data3] = meshgrid(check_data2, check_data3);
        
        a = par;
        y = (1 ./ (1 + a(6) * exp(sqrt(a(1) * (data2 - a(4)).^2 + a(2) * (data3 - a(5)).^2 + ...
            a(3) * (data2 - a(4)) .* (data3 - a(5)))))) .* ((a(1) * (data2 - a(4)).^2 + ...
            a(2) * (data3 - a(5)).^2 + a(3) * (data2 - a(4)) .* (data3 - a(5))) >= 0);
        
        contour(data2, data3, y, [0.5, 1], 'Linewidth', 2, 'Color', colors(i_para, :), ...
            'DisplayName', picname_group(i_para));

        min_data2 = min(min_data2, min(data2(y >= 0.5)));
        max_data2 = max(max_data2, max(data2(y >= 0.5)));
        min_data3 = min(min_data3, min(data3(y >= 0.5)));
        max_data3 = max(max_data3, max(data3(y >= 0.5)));


        hold on;
                % 绘制 scatter 和 plot，颜色与 contour 相同
        scatter(par(4), par(5), 30, 'filled', 'MarkerFaceColor', colors(i_para, :));
        plot(lab_aft2(i_para, 2), lab_aft2(i_para, 3), 'p', 'MarkerSize', 10, ...
            'MarkerFaceColor', colors(i_para, :), 'MarkerEdgeColor', colors(i_para, :));
        plot(labC_PMCCpre(i_para, 2), labC_PMCCpre(i_para, 3), 's', 'MarkerSize', 10, ...
            'MarkerFaceColor', colors(i_para, :), 'MarkerEdgeColor', colors(i_para, :));
    end
    
    % 添加图例、标签和标题
    xlabel('{\ita*}');
    ylabel('{\itb*}');
    title(strcat(attribute_names(attribute)));
    
    % 设置坐标轴范围
    lim_max = max(max(max_data2), max(max_data3))+10 ;
    lim_min = min(min(min_data2), min(min_data3))-10 ;
    xlim([lim_min, lim_max]);
    ylim([lim_min, lim_max]);
    
    % 保存图像

    exportgraphics(gcf, fullfile(save_folder, strcat(attribute_serial, '.jpg')), 'Resolution', 300);
    close(gcf);
end

concatenate_images1(save_folder,5);


%% 绘制图例图
figure;
hold on;
set(gcf, 'Color', 'white');

% 设置图例图的位置和大小
axis([0 70 0 4]); % 增加 x 轴范围，y 轴范围固定为 4
axis off;

% 反转 attributes 的顺序
reversed_picname_group = flip(picname_group);
reversed_colors = flip(colors, 1);

% 绘制颜色和对应的 attribute_serial
for i_para = 1:length(reversed_picname_group)
    % 计算当前行和列
    row = mod(i_para - 1, 3) + 1; % 每列 3 个
    col = floor((i_para - 1) / 3) + 1; % 共 7 列
    
    % 绘制颜色块
    rectangle('Position', [2 + (col - 1) * 8, row, 1, 0.8], 'FaceColor', reversed_colors(i_para, :), 'EdgeColor', 'k');
    % 添加 attribute_serial 文本
    text(3.5 + (col - 1) * 8, row + 0.5, reversed_picname_group(i_para), 'FontSize', 12, 'VerticalAlignment', 'middle');
end

% 绘制五角星 + "CATed"
plot(2, 4.5, 'p', 'MarkerSize', 15, 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k');
text(3.5, 4.5, 'CATed', 'FontSize', 12, 'VerticalAlignment', 'middle');

% 绘制圆形 + "center"
plot(2, 5.5, 'o', 'MarkerSize', 15, 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k');
text(3.5, 5.5, 'center', 'FontSize', 12, 'VerticalAlignment', 'middle');

% 绘制正方形 + "PMCC"
plot(2, 6.5, 's', 'MarkerSize', 15, 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k');
text(3.5, 6.5, 'PMCC', 'FontSize', 12, 'VerticalAlignment', 'middle');

% 调整图窗大小以确保所有内容可见
set(gcf, 'Position', [100, 100, 1200, 300]); % 设置图窗宽度为 1200，高度为 300

% 保存图例图
if ~exist(fullfile(save_folder,"legend"),"dir")
    mkdir(fullfile(save_folder,"legend"));
end
exportgraphics(gcf, fullfile(save_folder,"legend" ,strcat(lastPart, '_lights_legend.jpg')), 'Resolution', 300);

close(gcf);





function colors = generate_colors(num_groups, num_colors_per_group)
    % 生成分色系的颜色矩阵
    % 输入：
    %   num_groups - 色系的数量（例如 3 组）
    %   num_colors_per_group - 每组颜色的数量（例如每组 7 个颜色）
    % 输出：
    %   colors - 生成的颜色矩阵，大小为 (num_groups * num_colors_per_group, 3)

    % 初始化颜色矩阵
    num_colors = num_groups * num_colors_per_group;
    colors = zeros(num_colors, 3);

    % 定义色相范围
    hue_ranges = linspace(0, 1, num_groups + 1); % 将色相范围分为 num_groups 段

    % 生成颜色
    for group = 1:num_groups
        % 当前组的色相范围
        hue_start = hue_ranges(group);
        hue_end = hue_ranges(group + 1);

        % 生成当前组的颜色
        for i = 1:num_colors_per_group
            hue = hue_start + (i - 1) * (hue_end - hue_start) / num_colors_per_group; % 色相均匀分布
            saturation = 0.8; % 高饱和度
            value = 0.8; % 高明度
            colors((group - 1) * num_colors_per_group + i, :) = hsv2rgb([hue, saturation, value]);
        end
    end
end