close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量

%% 定义所有需要处理的 attribute
attributes = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
attribute_names = ["Preference", "Attractiveness", "Feminine", "Cooperative", ...
    "Youth", "Healthy", "Precise reproduction", "suit the environment or not", "white-skinned", "ruddy"];
picname_group = ["h3k", "h4k", "h5k", "h6k", "h7k", "h8k", "hd65", ...
    "l3k", "l4k", "l5k", "l6k", "l7k", "l8k", "ld65", ...
    "m3k", "m4k", "m5k", "m6k", "m7k", "m8k", "md65"];

lastParts = {'female78i', 'female41i', 'femalevivoi', 'male59i', 'male39i', 'malevivoi'};
Dtype='summer';
save_folder = fullfile("ellip_pic\ellipse", "combined", "single",Dtype);

% 创建保存文件夹
if ~exist(save_folder, "dir")
    mkdir(save_folder);
end

lab_PMCC = [62.11, 18.96, 19.76];
labC_PMCC = [lab_PMCC, sqrt(lab_PMCC(1, 2)^2 + lab_PMCC(1, 3)^2)];

% 定义色环上的 6 种颜色（每个 lastPart 一种颜色）
colors = hsv(length(lastParts)); % 使用 hsv 色图生成 6 种颜色

% 定义线型（每个 source_file 一种线型）
line_styles = {'-', '--', ':', '-.'};

%% 求这几个lastPart的平均average
average_sum=zeros(21,3);
for lastPart_idx = 1:length(lastParts)
    lastPart = lastParts{lastPart_idx};
    model = lastPart(1:end-1);
    [lastPart1, model1] = gen_lastPart1(lastPart);
    lastPart_new=gen_lastPart_new(lastPart1);
    disp([lastPart,lastPart_new])
    average_file = strcat("..\renderCode\aveSkinByHand2\", lastPart_new, "\autoNhand_scaleoverLUT.mat");
    average_ind = load(average_file);
    average_ind = average_ind.average_lab_all(:, 1:3);
    average_sum=average_sum+average_ind;
end
average=average_sum./length(lastParts);
%% 循环处理每个 i_para（即每个 light）
for i_para = 1:21
    fprintf('Processing light: %d\n', i_para);
    
    % 循环处理每个 attribute
    for attribute = attributes
        % 创建新图窗
        figure;
        hold on;
        set(gcf, 'Color', 'white');
        
        % 生成 attribute_serial
        attribute_serial = strcat(sprintf("%02d", attribute), attribute_names(attribute));
        
        % 循环处理每个 lastPart
        for lastPart_idx = 1:length(lastParts)
            lastPart = lastParts{lastPart_idx};
            
            % 定义路径
            source_file1 = fullfile('AlalyseResults', Dtype,lastPart, attribute_serial, 'ellipPara', 'fitRes_level.mat');
            source_file2 = fullfile('AlalyseResults', Dtype,lastPart, 'model_group', attribute_serial, 'ellipPara', 'fitRes_level.mat');
            source_file3 = fullfile('AlalyseResults',Dtype, lastPart, 'model', attribute_serial, 'ellipPara', 'fitRes_level.mat');
            source_file4 = fullfile('AlalyseResults', Dtype,lastPart, 'all', attribute_serial, 'ellipPara', 'fitRes_level.mat'); % 新增 source_file4
            for i_obs=1:4
                % 加载数据
                par_all_used = [];
                if exist(source_file{i_obs}, 'file') % 新增 source_file4 的加载
                    load(source_file{i_obs});
                    par_all_used = par_all;
                else
                    par_all_used=[];
                end
                
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
                if ~isempty(par_all_used)
                    par = par_all_used(i_para, :);
                    check_data2 = par(4) + (-30:0.2:30);
                    check_data3 = par(5) + (-30:0.2:30);
                    [data2, data3] = meshgrid(check_data2, check_data3);
                    y = (1 ./ (1 + par(6) * exp(sqrt(par(1) * (data2 - par(4)).^2 + par(2) * (data3 - par(5)).^2 + ...
                        par(3) * (data2 - par(4)) .* (data3 - par(5)))))) .* ((par(1) * (data2 - par(4)).^2 + ...
                        par(2) * (data3 - par(5)).^2 + par(3) * (data2 - par(4)) .* (data3 - par(5))) >= 0);
                    contour(data2, data3, y, [0.5, 1], 'Linewidth', 1, 'Color', colors(lastPart_idx, :), ...
                        'DisplayName', strcat(lastPart, ' - source4'), 'LineStyle', '-');
                    scatter(par(4), par(5), 30, 'v', 'filled', 'MarkerFaceColor', colors(lastPart_idx, :));
                end
            end
        end
        
        % 绘制 PMCC 点
        plot(labC_PMCCpre(i_para, 2), labC_PMCCpre(i_para, 3), 's', 'MarkerSize', 10, ...
            'MarkerFaceColor', 'm', 'MarkerEdgeColor', 'm');

        % 添加图例、标签和标题
        xlabel('{\ita*}');
        ylabel('{\itb*}');
        title(strcat('Light: ', picname_group(i_para), ' - ', attribute_serial));
        
        % 设置坐标轴范围
        xlim([-20, 60]);
        ylim([-20, 60]);
        % xlim([lim_min, lim_max]);
        % ylim([lim_min, lim_max]);
        
        % 保存图像
        if ~exist(fullfile(save_folder, attribute_serial), "dir")
            mkdir(fullfile(save_folder, attribute_serial));
        end
        exportgraphics(gcf, fullfile(save_folder, attribute_serial, strcat(picname_group(i_para), '_', attribute_serial, '.jpg')), 'Resolution', 300);
        close(gcf);
    end
    
end
for attribute = attributes
    attribute_serial = strcat(sprintf("%02d", attribute), attribute_names(attribute));
    concatenate_images1(fullfile(save_folder,attribute_serial ),7);
end
%% 绘制图例图
figure;
hold on;
set(gcf, 'Color', 'white');

% 设置图例图的位置和大小
axis([0 70 0 6]); % 增加 y 轴范围以容纳更多内容
axis off;

% 定义图例的 6 个颜色块和对应的名字
legend_names = lastParts;
legend_colors = hsv(length(lastParts)); % 使用 hsv 色图生成 6 种颜色

% 绘制颜色块和对应的名字
for i = 1:length(legend_names)
    % 计算当前行和列
    row = mod(i - 1, 3) + 1; % 每列 3 个
    col = floor((i - 1) / 3) + 1; % 共 3 列
    
    % 绘制颜色块
    rectangle('Position', [2 + (col - 1) * 8, row, 1, 0.8], 'FaceColor', legend_colors(i, :), 'EdgeColor', 'k');
    % 添加名字文本
    text(3.5 + (col - 1) * 8, row + 0.5, legend_names{i}, 'FontSize', 12, 'VerticalAlignment', 'middle');
end


% 绘制线型和对应的 source_file
line_styles = {'-', '--', ':', '-.'};
plot_styles = {'o', '^', 'd', 'v'};
source_names = {'non-model-group', 'model-group', 'model', 'all'};
for i = 1:length(line_styles)
    plot(4, 4 + i*0.5, plot_styles{i}, 'MarkerSize', 8, 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k');
    line([10, 10], [4 + i*0.5, 4 + i*0.5], 'Color', 'k', 'LineWidth', 2, 'LineStyle', line_styles{i});
    text(15, 4 + i*0.5, source_names{i}, 'FontSize', 8, 'VerticalAlignment', 'middle');
end
plot(4, 4, 'p', 'MarkerSize', 8, 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k');
text(15,4, 'PMCC', 'FontSize', 8, 'VerticalAlignment', 'middle');

% 调整图窗大小以确保所有内容可见
set(gcf, 'Position', [100, 100, 1200, 400]); % 设置图窗宽度为 1200，高度为 400

% 保存图例图
if ~exist(fullfile(save_folder, "legend"), "dir")
    mkdir(fullfile(save_folder, "legend"));
end
exportgraphics(gcf, fullfile(save_folder, "legend", 'combined_lights_legend.jpg'), 'Resolution', 300);

close(gcf);