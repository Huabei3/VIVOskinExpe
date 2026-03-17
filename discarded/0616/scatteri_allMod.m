close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量
%%
% 定义 lastParts
lastParts = {'female78i', 'female41i', 'femalevivoi', ...
             'male59i', 'male39i', 'malevivoi'};

% 初始化存储数据的容器
dataInter = table();
dataIntra = table();

% 遍历每个 lastPart
for i = 1:length(lastParts)
    % 构建文件路径
    folderPath = fullfile("D:\work\VIVOskinExpe\analyze\AlalyseResults\summer", lastParts{i}, "all");
    filePath = fullfile(folderPath, '*.xlsx'); % 假设每个 lastPart 文件夹下只有一个 xlsx 文件
    fileList = dir(filePath);
    
    % 检查是否存在文件
    if isempty(fileList)
        warning('未找到文件：%s', folderPath);
        continue;
    end
    
    % 读取当前文件
    filePath = fullfile(folderPath, fileList(1).name);
    data = readtable(filePath);
    
    % 删除 '.' 和 '..' 行
    data(strcmp(data.Folder, '.') | strcmp(data.Folder, '..'), :) = [];
    
    % 提取 Mean_STRESS_inter 和 Mean_STRESS_intra 列
    interData = data(:, {'Folder', 'Mean_STRESS_inter'});
    intraData = data(:, {'Folder', 'Mean_STRESS_intra'});
    
    % 重命名列名为 lastPart
    interData.Properties.VariableNames{'Mean_STRESS_inter'} = lastParts{i};
    intraData.Properties.VariableNames{'Mean_STRESS_intra'} = lastParts{i};
    
    % 合并数据
    if isempty(dataInter)
        dataInter = interData;
        dataIntra = intraData;
    else
        dataInter = outerjoin(dataInter, interData, 'Keys', 'Folder', 'MergeKeys', true);
        dataIntra = outerjoin(dataIntra, intraData, 'Keys', 'Folder', 'MergeKeys', true);
    end
end

% 写入新的 xlsx 文件
outputFilePath = fullfile("D:\work\VIVOskinExpe\analyze\AnalyseResults\summer", 'merged_results.xlsx');
writetable(dataInter, outputFilePath, 'Sheet', 'Mean_STRESS_inter');
writetable(dataIntra, outputFilePath, 'Sheet', 'Mean_STRESS_intra');

disp('合并完成，结果已保存到 merged_results.xlsx');
%% 定义所有需要处理的 attribute
attributes = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
attribute_names = ["Preference", "Attractiveness", "Feminine", "Cooperative", ...
    "Youth", "Healthy", "Precise reproduction", "suit the environment or not", "white-skinned", "ruddy"];
picname_group = ["h3k", "h4k", "h5k", "h6k", "h7k", "h8k", "hd65", ...
    "l3k", "l4k", "l5k", "l6k", "l7k", "l8k", "ld65", ...
    "m3k", "m4k", "m5k", "m6k", "m7k", "m8k", "md65"];
Dtype='summer';
lastParts = {'female78i', 'female41i', 'femalevivoi', ...
    'male59i', 'male39i', 'malevivoi'};
lastParts_new = {'f04i', 'f05i', 'f06i', ...
    'm04i', 'm05i', 'm06i'};
save_folder = fullfile("ellip_pic\ellipse", "combined", "single","scatter",Dtype);

% 创建保存文件夹
if ~exist(save_folder, "dir")
    mkdir(save_folder);
end

lab_PMCC = [62.11, 18.96, 19.76];
labC_PMCC = [lab_PMCC, sqrt(lab_PMCC(1, 2)^2 + lab_PMCC(1, 3)^2)];

wd65_64 = [94.811, 100.00, 107.304];
CT = [3000, 4000, 5000, 6000, 7000, 8000, 6500, ...
      3000, 4000, 5000, 6000, 7000, 8000, 6500, ...
      3000, 4000, 5000, 6000, 7000, 8000, 6500]';
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
        lim_max=-inf;
        lim_min=inf;
        
        % 生成 attribute_serial
        attribute_serial = strcat(sprintf("%02d", attribute), attribute_names(attribute));
        
        % 循环处理每个 lastPart
        for lastPart_idx = 1:length(lastParts)
            lastPart = lastParts{lastPart_idx};
            
            % 定义路径
            source_file1 = fullfile('AlalyseResults', lastPart, attribute_serial, 'ellipPara', 'fitRes_level.mat');
            source_file2 = fullfile('AlalyseResults', lastPart, 'model_group', attribute_serial, 'ellipPara', 'fitRes_level.mat');
            source_file3 = fullfile('AlalyseResults', lastPart, 'model', attribute_serial, 'ellipPara', 'fitRes_level.mat');
            source_file4 = fullfile('AlalyseResults', lastPart, 'all', attribute_serial, 'ellipPara', 'fitRes_level.mat'); % 新增 source_file4
            
            % 加载数据
             par_all4 = [];

            if exist(source_file4, 'file') % 新增 source_file4 的加载
                load(source_file4);
                par_all4 = par_all;
            else
                par_all4 = [];
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
            if ~isempty(par_all4)
                par = par_all4(i_para, :);
                %CAT PMCC
                lab_bf(i_para, :) = [average(i_para, 1), par(4), par(5)];
                CCT = CT(i_para);
                XYZw_pre(i_para, :) = CCT2xyz(CCT);
                XYZ_bf(i_para, :) = lab2xyz2(lab_bf(i_para, :), 'd65_64');
                [CCT, duv, S_out] = xyz2CCT(XYZw_pre(i_para, :), 10);
                D1 = 0.723 * (1 - 1116 / CCT + 8.64 * duv - 49266 * duv / CCT); % zhai
                D2 = 0.239 * 0.723 * (1 - 1116 / CCT); % summer
                D3 = 0.00005 * CCT + 0.1977; % OPPO
                XYZ_aft(i_para, :) = CAT16_D(XYZ_bf(i_para, :),  XYZw_pre(i_para, :),wd65_64, 1);
                XYZ_aft1(i_para, :) = CAT16_D(XYZ_bf(i_para, :), XYZw_pre(i_para, :), wd65_64, D1);
                XYZ_aft2(i_para, :) = CAT16_D(XYZ_bf(i_para, :), XYZw_pre(i_para, :), wd65_64, D2);
                XYZ_aft3(i_para, :) = CAT16_D(XYZ_bf(i_para, :),  XYZw_pre(i_para, :),wd65_64, D3);
                lab_aft(i_para, :) = xyz2lab(XYZ_aft(i_para, :), 'd65_64');
                lab_aft1(i_para, :) = xyz2lab(XYZ_aft1(i_para, :), 'd65_64');
                lab_aft2(i_para, :) = xyz2lab(XYZ_aft2(i_para, :), 'd65_64');
                lab_aft3(i_para, :) = xyz2lab(XYZ_aft3(i_para, :), 'd65_64');
                if strcmp(Dtype,'full')
                    lab_aft_used=lab_aft;
                elseif strcmp(Dtype,'zhai')
                    lab_aft_used=lab_aft1;
                elseif strcmp(Dtype,'summer')
                    lab_aft_used=lab_aft2;
                elseif strcmp(Dtype,'OPPO')
                    lab_aft_used=lab_aft3;
                end
                
                text(lab_aft_used(i_para, 2), lab_aft_used(i_para, 3), ...
                    lastParts_new{lastPart_idx}, 'FontSize', 8, 'VerticalAlignment', 'middle');
                if lastParts_new{lastPart_idx}(1)=='f'
                    scatter(lab_aft_used(i_para, 2), lab_aft_used(i_para, 3), ...
                    30, 'v', 'filled', 'MarkerFaceColor', colors(lastPart_idx, :));
                elseif lastParts_new{lastPart_idx}(1)=='m'
                    scatter(lab_aft_used(i_para, 2), lab_aft_used(i_para, 3), ...
                    30, '^', 'filled', 'MarkerFaceColor', colors(lastPart_idx, :));
                end
                lim_max=max(lim_max,max(lab_aft_used(i_para,2),lab_aft_used(i_para,3)));
                lim_min=min(lim_min,min(lab_aft_used(i_para,2),lab_aft_used(i_para,3)));
            end
        end
        
        % 绘制 PMCC 点
        plot(labC_PMCCpre(i_para, 2), labC_PMCCpre(i_para, 3), 's', 'MarkerSize', 10, ...
            'MarkerFaceColor', 'm', 'MarkerEdgeColor', 'm');
        text(labC_PMCCpre(i_para, 2), labC_PMCCpre(i_para, 3),'PMCC', ...
            'FontSize', 8, 'VerticalAlignment', 'middle');
        lim_max=max(lim_max,max(labC_PMCCpre(i_para,2),labC_PMCCpre(i_para,3)));
        lim_min=min(lim_min,min(labC_PMCCpre(i_para,2),labC_PMCCpre(i_para,3)));

        % 添加图例、标签和标题
        xlabel('{\ita*}');
        ylabel('{\itb*}');
        title(strcat('Light: ', picname_group(i_para), ' - ', attribute_serial));
        lim_max=lim_max+2;
        lim_min=lim_min-2;
        % 设置坐标轴范围
        xlim([0, 22]);
        ylim([0, 22]);
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
legend_names = lastParts_new;
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
    % line([10, 10], [4 + i*0.5, 4 + i*0.5], 'Color', 'k', 'LineWidth', 2, 'LineStyle', line_styles{i});
    text(15, 4 + i*0.5, source_names{i}, 'FontSize', 8, 'VerticalAlignment', 'middle');
end
% plot(4, 4, 'p', 'MarkerSize', 8, 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k');
% text(15,4, 'PMCC', 'FontSize', 8, 'VerticalAlignment', 'middle');

% 调整图窗大小以确保所有内容可见
set(gcf, 'Position', [100, 100, 1200, 400]); % 设置图窗宽度为 1200，高度为 400

% 保存图例图
if ~exist(fullfile(save_folder, "legend"), "dir")
    mkdir(fullfile(save_folder, "legend"));
end
exportgraphics(gcf, fullfile(save_folder, "legend", 'combined_lights_legend.jpg'), 'Resolution', 300);

close(gcf);