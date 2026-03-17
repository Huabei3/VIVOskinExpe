close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量

%% 定义所有需要处理的 attribute
attributes = [1, 2, 3, 4, 5, 6, 8, 9, 10];
attribute_names = ["Preference", "Attractiveness", "Feminine", "Cooperative", ...
    "Youth", "Healthy", "Precise reproduction", "suit the environment or not", "white-skinned", "ruddy"];
picname_group = ["h3k", "h4k", "h5k", "h6k", "h7k", "h8k", "hd65", ...
    "l3k", "l4k", "l5k", "l6k", "l7k", "l8k", "ld65", ...
    "m3k", "m4k", "m5k", "m6k", "m7k", "m8k", "md65"];

lastPart = 'female78i';
save_folder = fullfile("ellip_pic\ellipse", lastPart, "mNnm");

% 创建保存文件夹
if ~exist(save_folder, "dir")
    mkdir(save_folder);
end

lab_PMCC = [62.11, 18.96, 19.76];
labC_PMCC = [lab_PMCC, sqrt(lab_PMCC(1, 2)^2 + lab_PMCC(1, 3)^2)];

model = lastPart(1:end-1);
[lastPart1, model1] = gen_lastPart1(lastPart);
lastPart_new = gen_lastPart_new(lastPart1);
disp([lastPart, lastPart_new]);
average_file = strcat("..\renderCode\aveSkinByHand2\", lastPart_new, "\autoNhand_scaleoverLUT.mat");
average = load(average_file);
average = average.average_lab_all(:, 1:3);

wd65_64 = [94.811, 100.00, 107.304];
CT = [3000, 4000, 5000, 6000, 7000, 8000, 6500, ...
      3000, 4000, 5000, 6000, 7000, 8000, 6500, ...
      3000, 4000, 5000, 6000, 7000, 8000, 6500]';

% 定义色环上的 7 种颜色
colors = hsv(7); % 使用 hsv 色图生成 7 种颜色

%% 循环处理每个 attribute
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

for attribute = attributes
    fprintf('Processing attribute: %d\n', attribute);
    
    % 生成 attribute_serial
    attribute_serial = strcat(sprintf("%02d", attribute), attribute_names(attribute));
    
    % 定义路径
    source_file1 = fullfile('AlalyseResults', lastPart, attribute_serial, 'ellipPara', 'fitRes_level.mat');
    source_file2 = fullfile('AlalyseResults', lastPart, 'model_group', attribute_serial, 'ellipPara', 'fitRes_level.mat');
    source_file3 = fullfile('AlalyseResults', lastPart, 'model', attribute_serial, 'ellipPara', 'fitRes_level.mat');
    % 加载数据
    if exist(source_file1, 'file')
        load(source_file1);
        par_all1 = par_all;
    end
    if exist(source_file2, 'file')
        load(source_file2);
        par_all2 = par_all;
    end
    if exist(source_file3, 'file')
        load(source_file3);
        par_all3 = par_all;
    end
    
    % 对每个 i_para 分别画图
    for i_para = 1:21
        % 创建新图窗
        figure;
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

        % 绘制 source_file1 的 contour
        if exist('par_all1', 'var')
            par = par_all1(i_para, :);
            check_data2 = par(4) + (-30:0.2:30);
            check_data3 = par(5) + (-30:0.2:30);
            [data2, data3] = meshgrid(check_data2, check_data3);
            y = (1 ./ (1 + par(6) * exp(sqrt(par(1) * (data2 - par(4)).^2 + par(2) * (data3 - par(5)).^2 + ...
                par(3) * (data2 - par(4)) .* (data3 - par(5)))))) .* ((par(1) * (data2 - par(4)).^2 + ...
                par(2) * (data3 - par(5)).^2 + par(3) * (data2 - par(4)) .* (data3 - par(5))) >= 0);
            contour(data2, data3, y, [0.5, 1], 'Linewidth', 1, 'Color', colors(mod(i_para-1, 7)+1, :), ...
                'DisplayName', picname_group(i_para), 'LineStyle', '-');
            scatter(par(4), par(5), 30, 'filled', 'MarkerFaceColor', colors(mod(i_para-1, 7)+1, :));
        end
        
        % 绘制 source_file2 的 contour
        if exist('par_all2', 'var')
            par = par_all2(i_para, :);
            check_data2 = par(4) + (-30:0.2:30);
            check_data3 = par(5) + (-30:0.2:30);
            [data2, data3] = meshgrid(check_data2, check_data3);
            y = (1 ./ (1 + par(6) * exp(sqrt(par(1) * (data2 - par(4)).^2 + par(2) * (data3 - par(5)).^2 + ...
                par(3) * (data2 - par(4)) .* (data3 - par(5)))))) .* ((par(1) * (data2 - par(4)).^2 + ...
                par(2) * (data3 - par(5)).^2 + par(3) * (data2 - par(4)) .* (data3 - par(5))) >= 0);
            contour(data2, data3, y, [0.5, 1], 'Linewidth', 1, 'Color', colors(mod(i_para-1, 7)+1, :), ...
                'DisplayName', picname_group(i_para), 'LineStyle', '--');
            scatter(par(4), par(5), 30, '^', 'filled', 'MarkerFaceColor', colors(mod(i_para-1, 7)+1, :));
        end
        
        % 绘制 source_file3 的 contour 或散点图
        if exist('par_all3', 'var')
            par = par_all3(i_para, :);
            if all(par([1:3, 6]) == 0)
                % 如果 par_all3(i_para, [1:3, 6]) 都等于 0，只绘制菱形散点图
                scatter(par(4), par(5), 30, 'd', 'filled', 'MarkerFaceColor', colors(mod(i_para-1, 7)+1, :));
            else
                % 否则，使用 ':' 线型绘制等高线图
                check_data2 = par(4) + (-30:0.2:30);
                check_data3 = par(5) + (-30:0.2:30);
                [data2, data3] = meshgrid(check_data2, check_data3);
                y = (1 ./ (1 + par(6) * exp(sqrt(par(1) * (data2 - par(4)).^2 + par(2) * (data3 - par(5)).^2 + ...
                    par(3) * (data2 - par(4)) .* (data3 - par(5)))))) .* ((par(1) * (data2 - par(4)).^2 + ...
                    par(2) * (data3 - par(5)).^2 + par(3) * (data2 - par(4)) .* (data3 - par(5))) >= 0);
                contour(data2, data3, y, [0.5, 1], 'Linewidth', 1, 'Color', colors(mod(i_para-1, 7)+1, :), ...
                    'DisplayName', picname_group(i_para), 'LineStyle', ':');
                scatter(par(4), par(5), 30, 'd', 'filled', 'MarkerFaceColor', colors(mod(i_para-1, 7)+1, :));
            end
        end
        
        % 绘制 PMCC 点
        plot(labC_PMCCpre(i_para, 2), labC_PMCCpre(i_para, 3), 's', 'MarkerSize', 10, ...
            'MarkerFaceColor', 'm', 'MarkerEdgeColor', 'm');
        
        % 添加图例、标签和标题
        xlabel('{\ita*}');
        ylabel('{\itb*}');
        title(strcat(attribute_names(attribute), ' - ', picname_group(i_para)));
        
        % 设置坐标轴范围
        xlim([lim_min, lim_max]);
        ylim([lim_min, lim_max]);
        
        % 保存图像
        if ~exist(fullfile(save_folder, picname_group(i_para)), "dir")
            mkdir(fullfile(save_folder, picname_group(i_para)));
        end
        exportgraphics(gcf, fullfile(save_folder, picname_group(i_para), strcat(attribute_serial, "_", picname_group(i_para), '.jpg')), 'Resolution', 300);
        close(gcf);
    end
end

