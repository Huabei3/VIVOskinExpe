close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量

%% 定义所有需要处理的 attribute
attributes = [1, 2, 3, 4, 5, 6, 7,8, 9, 10];
attribute_names = ["Preference", "Attractiveness", "Feminine", "Cooperative", ...
    "Youth", "Healthy", "Precise reproduction", "suit the environment or not", "white-skinned", "ruddy"];
picname_group = ["h3k", "h4k", "h5k", "h6k", "h7k", "h8k", "hd65", ...
    "l3k", "l4k", "l5k", "l6k", "l7k", "l8k", "ld65", ...
    "m3k", "m4k", "m5k", "m6k", "m7k", "m8k", "md65"];

lastPart = 'male59i';
save_folder = fullfile("ellip_pic\ellipse", lastPart, "combined_attributes","mNnm");

% 创建保存文件夹
if ~exist(save_folder, "dir")
    mkdir(save_folder);
end

lab_PMCC = [62.11, 18.96, 19.76];
labC_PMCC = [lab_PMCC, sqrt(lab_PMCC(1, 2)^2 + lab_PMCC(1, 3)^2)];

model = lastPart(1:end-1);
[lastPart1, model1] = gen_lastPart1(lastPart);
average_file = strcat("..\renderCode\aveSkinByHand2\", lastPart1, "\autoNhand_scaleoverLUT.mat");
average = load(average_file);
average = average.average_lab_all(:, 1:3);

wd65_64 = [94.811, 100.00, 107.304];
CT = [3000, 4000, 5000, 6000, 7000, 8000, 6500, ...
      3000, 4000, 5000, 6000, 7000, 8000, 6500, ...
      3000, 4000, 5000, 6000, 7000, 8000, 6500]';

group_type=["non_model_group","model_group","model"];

%% 定义颜色、线型和标记
colors = hsv(length(attributes)); % 为每个 attribute 分配颜色
line_styles = {'-', '--', ':','-.'};   % 为每个 source_file 分配线型
markers = {'o', '^', 'd','v'};        % 为每个 source_file 分配标记

%% 算lim_min、lim_max
lim_min=inf; lim_max=-inf;
for attribute = attributes
    fprintf('Processing attribute: %d\n', attribute);
    
    % 生成 attribute_serial
    attribute_serial = strcat(sprintf("%02d", attribute), attribute_names(attribute));
    
    % 定义路径
    source_file1 = fullfile('AlalyseResults', lastPart, attribute_serial, 'ellipPara', 'fitRes_level.mat');
    source_file2 = fullfile('AlalyseResults', lastPart, 'model_group', attribute_serial, 'ellipPara', 'fitRes_level.mat');
    source_file3 = fullfile('AlalyseResults', lastPart, 'model', attribute_serial, 'ellipPara', 'fitRes_level.mat');
    
    % 调用函数计算 lim_min 和 lim_max
    [lim_min, lim_max] = calculate_limits(source_file1, source_file2, source_file3,lim_min, lim_max);
end
%% 循环处理每个 i_para
for i_para = 1:21 % 假设 par_all 有 21 行
    figure(i_para);
    hold on;
    set(gcf, 'Color', 'white');
    
    % 计算 labC_PMCCpre
    if average(i_para, 1) <= 60
        C_pre = 6.7421 * log(average(i_para, 1)) - 9.9816; % 亮度实验
    else
        C_pre = 6.7421 * log(60) - 9.9816; % 亮度实验
    end
    labC_PMCCpre(i_para, 1) = average(i_para, 1);
    labC_PMCCpre(i_para, 2:3) = lab_PMCC(1, 2:3) ./ labC_PMCC(1, 4) .* C_pre;
    labC_PMCCpre(i_para, 4) = C_pre;
    %CAT PMCC
    labPMCC_bf(i_para, :) = [average(i_para, 1), labC_PMCCpre(i_para, 2:3)];
    CCT = CT(i_para);
    disp(CCT)
    XYZw_pre(i_para, :) = CCT2xyz(CCT);
    XYZ_bf(i_para, :) = lab2xyz2(labPMCC_bf(i_para, :), 'd65_64');
    [CCT, duv, S_out] = xyz2CCT(XYZw_pre(i_para, :), 10);
    D1 = 0.723 * (1 - 1116 / CCT + 8.64 * duv - 49266 * duv / CCT); % zhai
    D2 = 0.239 * 0.723 * (1 - 1116 / CCT); % summer
    D3 = 0.00005 * CCT + 0.1977; % OPPO
    XYZ_aft(i_para, :) = CAT16_D(XYZ_bf(i_para, :),  wd65_64,XYZw_pre(i_para, :), 1);
    XYZ_aft1(i_para, :) = CAT16_D(XYZ_bf(i_para, :),  wd65_64,XYZw_pre(i_para, :), D1);
    XYZ_aft2(i_para, :) = CAT16_D(XYZ_bf(i_para, :),  wd65_64,XYZw_pre(i_para, :), D2);
    XYZ_aft3(i_para, :) = CAT16_D(XYZ_bf(i_para, :),  wd65_64,XYZw_pre(i_para, :), D3);
    labPMCC_aft(i_para, :) = xyz2lab(XYZ_aft(i_para, :), 'd65_64');
    labPMCC_aft1(i_para, :) = xyz2lab(XYZ_aft1(i_para, :), 'd65_64');
    labPMCC_aft2(i_para, :) = xyz2lab(XYZ_aft2(i_para, :), 'd65_64');
    labPMCC_aft3(i_para, :) = xyz2lab(XYZ_aft3(i_para, :), 'd65_64');

    % 循环处理每个 attribute
    for idx = 1:length(attributes)
        attribute = attributes(idx);
        fprintf('Processing i_para: %d, attribute: %d\n', i_para, attribute);
        
        % 生成 attribute_serial
        attribute_serial = strcat(sprintf("%02d", attribute), attribute_names(attribute));
        
        % 定义路径
        source_file1 = fullfile('AlalyseResults', lastPart, attribute_serial, 'ellipPara', 'fitRes_level.mat');
        source_file2 = fullfile('AlalyseResults', lastPart, 'model_group', attribute_serial, 'ellipPara', 'fitRes_level.mat');
        source_file3 = fullfile('AlalyseResults', lastPart, 'model', attribute_serial, 'ellipPara', 'fitRes_level.mat');
        source_file4 = fullfile('AlalyseResults', lastPart, 'all', attribute_serial, 'ellipPara', 'fitRes_level.mat');
        % 加载数据并绘制
        source_files = {source_file1, source_file2, source_file3,source_file4};
        for source_idx = 1:length(source_files)
            if source_idx==4
                disp("4")
            end
            source_file = source_files{source_idx};
            if exist(source_file, 'file')
                load(source_file);
                par = par_all(i_para, :);
                if all(par([1:3, 6]) == 0)
                    % 如果 par_all3(i_para, [1:3, 6]) 都等于 0，只绘制菱形散点图
                    scatter(par(4), par(5), 30, markers{source_idx}, 'filled', ...
                        'MarkerFaceColor', colors(idx, :), 'MarkerEdgeColor', colors(idx, :));
                else
                    % 绘制 contour
                    check_data2 = par(4) + (-30:0.2:30);
                    check_data3 = par(5) + (-30:0.2:30);
                    [data2, data3] = meshgrid(check_data2, check_data3);
                    
                    a = par;
                    y = (1 ./ (1 + a(6) * exp(sqrt(a(1) * (data2 - a(4)).^2 + a(2) * (data3 - a(5)).^2 + ...
                        a(3) * (data2 - a(4)) .* (data3 - a(5)))))) .* ((a(1) * (data2 - a(4)).^2 + ...
                        a(2) * (data3 - a(5)).^2 + a(3) * (data2 - a(4)) .* (data3 - a(5))) >= 0);
                    
                    contour(data2, data3, y, [0.5, 1], 'Linewidth', 1, ...
                        'Color', colors(idx, :), 'LineStyle', line_styles{source_idx}); 
                    
                    
                    % 绘制 scatter 和 plot
                    scatter(par(4), par(5), 30, markers{source_idx}, 'filled', ...
                        'MarkerFaceColor', colors(idx, :), 'MarkerEdgeColor', colors(idx, :));

                end
                plot(labC_PMCCpre(i_para, 2), labC_PMCCpre(i_para, 3), 's', 'MarkerSize', 10, ...
                    'MarkerFaceColor', 'm', 'MarkerEdgeColor','m');
                % plot(labPMCC_aft(i_para, 2), labPMCC_aft(i_para, 3), 's', 'MarkerSize', 10, ...
                %     'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'r');
                plot(labPMCC_aft1(i_para, 2), labPMCC_aft1(i_para, 3), 's', 'MarkerSize', 10, ...
                    'MarkerFaceColor', 'g', 'MarkerEdgeColor', 'g');
                plot(labPMCC_aft2(i_para, 2), labPMCC_aft2(i_para, 3), 's', 'MarkerSize', 10, ...
                    'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'b');
                plot(labPMCC_aft3(i_para, 2), labPMCC_aft3(i_para, 3), 's', 'MarkerSize', 10, ...
                    'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k');
            end
        end
    end

    % 设置坐标轴范围
    xlim([lim_min, lim_max]);
    ylim([lim_min, lim_max]);

    % 添加标签和标题
    xlabel('{\ita*}');
    ylabel('{\itb*}');
    title(strcat(lastPart, ' - ', picname_group(i_para)));

    
    % 保存图像
    exportgraphics(gcf, fullfile(save_folder, strcat(lastPart, '_', picname_group(i_para), ".jpg")), 'Resolution', 300);
    close(i_para); % 关闭当前图窗
end
concatenate_images1(save_folder,7);

%% 绘制图例图
figure;
hold on;
set(gcf, 'Color', 'white');

% 设置图例图的位置和大小
axis([0 20 0 length(attributes) + 10]); % 增加 x 和 y 轴范围
axis off;

% 反转 attributes 的顺序
reversed_attributes = flip(attributes);
reversed_colors = flip(colors, 1);

% 绘制颜色和对应的 attribute_serial
for idx = 1:length(reversed_attributes)
    % 绘制颜色块
    rectangle('Position', [1, idx, 1, 0.8], 'FaceColor', reversed_colors(idx, :), 'EdgeColor', 'k');
    % 添加 attribute_serial 文本
    text(2.5, idx + 0.4, attribute_names(reversed_attributes(idx)), 'FontSize', 12, 'VerticalAlignment', 'middle');
end



% 绘制圆形 + "non-model-group"
plot(2, length(reversed_attributes) + 2, 'o', 'MarkerSize', 8, 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k');
text(3.5, length(reversed_attributes) + 2, 'non-model-group', 'FontSize', 12, 'VerticalAlignment', 'middle');

% 绘制上三角形 + "model-group"
plot(2, length(reversed_attributes) + 3, '^', 'MarkerSize', 8, 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k');
text(3.5, length(reversed_attributes) + 3, 'model-group', 'FontSize', 12, 'VerticalAlignment', 'middle');

% 绘制菱形 + "model"
plot(2, length(reversed_attributes) + 4, 'd', 'MarkerSize', 8, 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k');
text(3.5, length(reversed_attributes) + 4, 'model', 'FontSize', 12, 'VerticalAlignment', 'middle');

% 绘制正方形 + "all"
plot(2, length(reversed_attributes) + 5, 'v', 'MarkerSize', 8, 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k');
text(3.5, length(reversed_attributes) + 5, 'all', 'FontSize', 12, 'VerticalAlignment', 'middle');

% 绘制实线 + "non_group_model"
line([10, 14], [length(reversed_attributes) + 2, length(reversed_attributes) + 2], 'Color', 'k', 'LineWidth', 2, 'LineStyle', '-');
text(15, length(reversed_attributes) + 2, 'non\_model\_group', 'FontSize', 12, 'VerticalAlignment', 'middle');

% 绘制虚线 + "group_model"
line([10, 14], [length(reversed_attributes) + 3, length(reversed_attributes) + 3], 'Color', 'k', 'LineWidth', 2, 'LineStyle', '--');
text(15, length(reversed_attributes) + 3, 'model\_group', 'FontSize', 12, 'VerticalAlignment', 'middle');

% 绘制点线 + "group_self"
line([10, 14], [length(reversed_attributes) + 4, length(reversed_attributes) + 4], 'Color', 'k', 'LineWidth', 2, 'LineStyle', ':');
text(15, length(reversed_attributes) + 4, 'model', 'FontSize', 12, 'VerticalAlignment', 'middle');
% 绘制点线 + "all"
line([10, 14], [length(reversed_attributes) + 5, length(reversed_attributes) + 5], 'Color', 'k', 'LineWidth', 2, 'LineStyle', '-.');
text(15, length(reversed_attributes) + 5, 'all', 'FontSize', 12, 'VerticalAlignment', 'middle');

% 绘制正方形 + "PMCC"
plot(10, length(reversed_attributes) -1, 's', 'MarkerSize', 8, 'MarkerFaceColor', 'g', 'MarkerEdgeColor', 'g');
text(15, length(reversed_attributes) -1, 'PMCC CAted zhai', 'FontSize', 12, 'VerticalAlignment', 'middle');
% 绘制正方形 + "PMCC"
plot(10, length(reversed_attributes) , 's', 'MarkerSize', 8, 'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'b');
text(15, length(reversed_attributes) , 'PMCC CATed summer', 'FontSize', 12, 'VerticalAlignment', 'middle');
% 绘制正方形 + "PMCC"
plot(10, length(reversed_attributes) +1, 's', 'MarkerSize', 8, 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k');
text(15, length(reversed_attributes) +1, 'PMCC CATed last-exp', 'FontSize', 12, 'VerticalAlignment', 'middle');
% 绘制正方形 + "PMCC"
plot(10, length(reversed_attributes) -2, 's', 'MarkerSize', 8, 'MarkerFaceColor', 'm', 'MarkerEdgeColor', 'm');
text(15, length(reversed_attributes) -2, 'PMCC', 'FontSize', 12, 'VerticalAlignment', 'middle');
% 调整图窗大小以确保所有内容可见
set(gcf, 'Position', [100, 100, 600, 800]); % 设置图窗宽度为 600，高度为 800

% 保存图例图
if ~exist(fullfile(save_folder,"legend"),"dir")
    mkdir(fullfile(save_folder,"legend"));
end

exportgraphics(gcf, fullfile(save_folder,'legend', strcat(lastPart, '_legend.jpg')), 'Resolution', 300);

close(gcf);