close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量

%% 定义所有需要处理的 attribute
attributes = [1, 2, 3, 4, 5, 6,7, 8, 9,10];
attribute_names = ["Preference", "Attractiveness", "Feminine", "Cooperative", ...
    "Youth", "Healthy", "Precise reproduction",...
    "suit the environment or not", "white-skinned", "ruddyadd"];
attribute_names_new = ["Preference", "Attractiveness", "Feminine", "Cooperative", ...
    "Youth", "Healthy", "Fidelity","Harmony", "Fair", "Ruddy"];
picname_group=["h3k","h4k","h5k","h6k","h7k","h8k","hd65",...
    "l3k","l4k","l5k","l6k","l7k","l8k","ld65",...
    "m3k","m4k","m5k","m6k","m7k","m8k","md65"];
wd65_64 = [94.811, 100.00, 107.304];
CT = [3000, 4000, 5000, 6000, 7000, 8000, 6500, ...
      3000, 4000, 5000, 6000, 7000, 8000, 6500, ...
      3000, 4000, 5000, 6000, 7000, 8000, 6500]';
obs_types=["non_model","model_group","model","all"];
obs_types_new=["stranger","acquaintance","self","all"];
% 定义色环上的 7 种颜色
colors=hsv(3);


Dtype='summer';
for i_obstype=1:4
    save_folder = fullfile("ellip_pic\ellipse",  Dtype, ...
        "scatterCen","mod_hml","average",obs_types(i_obstype));
    % 创建保存文件夹
    if ~exist(save_folder, "dir")
        mkdir(save_folder);
    end
    
    lab_PMCC = [62.11, 18.96, 19.76];
    labC_PMCC = [lab_PMCC, sqrt(lab_PMCC(1, 2)^2 + lab_PMCC(1, 3)^2)];
    
    lastParts = {'female78i', 'female41i', 'femalevivoi', 'male59i', 'male39i', 'malevivoi'};
    
    for lastPart_idx = 1:length(lastParts)
        lastPart = lastParts{lastPart_idx};
    
        model = lastPart(1:end-1);
        [lastPart1, model1] = gen_lastPart1(lastPart);
        lastPart_new=gen_lastPart_new(lastPart1);
        disp([lastPart,lastPart_new])
        average_file = strcat("..\renderCode\aveSkinByHand2\", lastPart_new, "\autoNhand_scaleoverLUT.mat");
        average_data = load(average_file);
        average_inds(:,:,lastPart_idx) = average_data.average_lab_all(:, 1:3);
        for attribute = attributes
            fprintf('Processing attribute: %d\n', attribute);        
            % 生成 attribute_serial
            attribute_serial = strcat(sprintf("%02d", attribute), attribute_names(attribute));
            % 定义路径
            source_file_used = fullfile('AnalyseResults', Dtype, lastPart, ...
                obs_types(i_obstype), attribute_serial, ...
                'ellipPara', 'fitRes_level.mat'); % 新增 source_file_used

            par_all4=[];
            if exist(source_file_used, 'file') % 新增 source_file_used 的加载
                load(source_file_used);
                par_all4 = par_all;
            else
                par_all4(1:21,1:6)=NaN;
            end
            par_inds(:,:,lastPart_idx,attribute)=par_all4;
        end
    end
    par_inds_mean=nanmean(par_inds,3);
    average=nanmean(average_inds,3);
    %a-b
    lim_min_x=min(min(min(par_inds([7,14,21],4,:,:))))-1;
    lim_max_x=max(max(max(par_inds([7,14,21],4,:,:))))+1;
    lim_min_y=min(min(min(par_inds([7,14,21],5,:,:))))-1;
    lim_max_y=max(max(max(par_inds([7,14,21],5,:,:))))+1;
    
    
    condition = (par_inds(:, 5, :, :) < 2); % 逻辑条件
    indices = find(condition); % 找到满足条件的线性索引
    [dim1, dim3, dim4] = ind2sub([2, 6, 10], indices);
    dim2 = 5 * ones(size(dim1));
    coordinates = [dim1, dim2, dim3, dim4];
    values = par_inds(condition);
    
    %% 循环处理每个 attribute
    idx_ranges=[7;14;21];
    plot_style={'^','v','o'};
    for attribute = attributes
    
        attribute_serial = strcat(sprintf("%02d", attribute), attribute_names(attribute));
    
        figure();
        hold on;
        set(gcf, 'Color', 'white');
        for i_para = 1:size(par_inds_mean,1)
            % 计算 labC_PMCCpre
            if average(i_para, 1) <= 60
                C_pre = 6.7421 * log(average(i_para, 1)) - 9.9816; % 亮度实验
            else
                C_pre = 6.7421 * log(60) - 9.9816; % 亮度实验
            end
            labC_PMCCpre(i_para, 1) = average(i_para, 1);
            labC_PMCCpre(i_para, 2:3) = lab_PMCC(1, 2:3) ./ labC_PMCC(1, 4) .* C_pre;
            labC_PMCCpre(i_para, 4) = C_pre;
        end
        
        for lastPart_idx = 1:length(lastParts)
            lastPart = lastParts{lastPart_idx};
            lastPart_new=gen_lastPart_new(lastPart);
            lastPart_new=char(lastPart_new);
            par_all_used=par_inds(:,:,lastPart_idx,attribute);
            for i_level = 1:3
                % 绘制 source_file_used 的 contour 或散点图 (新增部分)
                if exist('par_all_used', 'var')&&~isempty(par_all_used)
                    par = par_all_used(idx_ranges(i_level,:), :);
                    i_D65=idx_ranges(i_level,end);
                    text(par(:,4),par(:,5),  lastPart_new(1:end-1), ...
                        'FontSize', 7, 'VerticalAlignment', 'middle', ...
                        'Color',colors(i_level, :));
                    % scatter(par(:,4),par(:,5),  30, ...
                    %     plot_style{i_level}, 'filled', ...
                    %     'MarkerFaceColor', colors(i_level, :));
                end
            end
        end
        % 绘制 PMCC 点
        plot(labC_PMCCpre(7, 2), labC_PMCCpre(7, 3), 's', 'MarkerSize', 10, ...
            'MarkerFaceColor', 'm', 'MarkerEdgeColor', 'm');
        text(labC_PMCCpre(7, 2), labC_PMCCpre(7, 3),'h-PMCC', ...
            'FontSize', 8, 'VerticalAlignment', 'middle');
    
        plot(labC_PMCCpre(14, 2), labC_PMCCpre(14, 3), 's', 'MarkerSize', 10, ...
            'MarkerFaceColor', 'm', 'MarkerEdgeColor', 'm');
        text(labC_PMCCpre(14, 2), labC_PMCCpre(14, 3),'l-PMCC', ...
            'FontSize', 8, 'VerticalAlignment', 'middle');
    
        plot(labC_PMCCpre(21, 2), labC_PMCCpre(21, 3), 's', 'MarkerSize', 10, ...
            'MarkerFaceColor', 'm', 'MarkerEdgeColor', 'm');
        text(labC_PMCCpre(21, 2), labC_PMCCpre(21, 3),'m-PMCC', ...
            'FontSize', 8, 'VerticalAlignment', 'middle');
    
        % 添加图例、标签和标题
        xlabel('{\ita*}');
        ylabel('{\itb*}');
        title(strcat(obs_types_new(i_obstype),attribute_names_new(attribute)));
    
        % 设置坐标轴范围
        x = linspace(0, 25, 100); % 从 -10 到 10，生成 100 个点
        plot(x, x); % 'r-' 表示红色实线
        axis equal;
        xlim([lim_min_x, lim_max_x]);
        ylim([lim_min_y, lim_max_y]);
        if ~exist(fullfile(save_folder, 'a_b'),"dir")
            mkdir(fullfile(save_folder, 'a_b'));
        end
        exportgraphics(gcf, fullfile(save_folder, 'a_b',strcat(attribute_serial,  '.jpg')), 'Resolution', 300);
        close(gcf);
    
    end
    concatenate_images1(fullfile(save_folder, 'a_b') ,5);
end

%% 绘制图例图
figure;
hold on;
set(gcf, 'Color', 'white');
lastParts_new = {'f04i', 'f05i', 'f06i', ...
    'm04i', 'm05i', 'm06i'};
hml=["H","L","M"];
% 设置图例图的位置和大小
axis([0 70 0 6]); % 增加 y 轴范围以容纳更多内容
axis off;

% 定义图例的 6 个颜色块和对应的名字
legend_names = hml;
legend_colors = hsv(length(hml)); % 使用 hsv 色图生成 6 种颜色

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


% % 绘制线型和对应的 source_file
% line_styles = {'-', '--', ':'};
% plot_styles = {'^', 'o', 'v'};
% source_names = {'high luminance', 'medium luminance', 'low luminance'};
% for i = 1:length(line_styles)
%     plot(4, 4 + i*0.5, plot_styles{i}, 'MarkerSize', 8, 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k');
%     % line([10, 10], [4 + i*0.5, 4 + i*0.5], 'Color', 'k', 'LineWidth', 2, 'LineStyle', line_styles{i});
%     text(15, 4 + i*0.5, source_names{i}, 'FontSize', 8, 'VerticalAlignment', 'middle');
% end
% % plot(4, 4, 'p', 'MarkerSize', 8, 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k');
% % text(15,4, 'PMCC', 'FontSize', 8, 'VerticalAlignment', 'middle');

% 调整图窗大小以确保所有内容可见
set(gcf, 'Position', [100, 100, 1200, 400]); % 设置图窗宽度为 1200，高度为 400

% 保存图例图
if ~exist(fullfile(save_folder, "legend"), "dir")
    mkdir(fullfile(save_folder, "legend"));
end
exportgraphics(gcf, fullfile(save_folder, "legend", 'combined_lights_legend.jpg'), 'Resolution', 300);

close(gcf);