close all; % 关闭所有图窗
clc;       % 清空命令窗口h
clear;     % 清除工作区所有变量

%% 定义所有需要处理的 attribute
attributes = [1, 2, 3, 4, 5, 6, 8, 9,10];
attribute_names = ["Preference", "Attractiveness", "Feminine", "Cooperative", ...
    "Youth", "Healthy", "Precise reproduction","suit the environment or not", "white-skinned", "ruddy"];
picname_group=["h3k","h4k","h5k","h6k","h7k","h8k","hd65",...
    "l3k","l4k","l5k","l6k","l7k","l8k","ld65",...
    "m3k","m4k","m5k","m6k","m7k","m8k","md65"];
%% 循环处理每个 attribute
% for attribute = [9]
for attribute = attributes
    fprintf('Processing attribute: %d\n', attribute);
    
    % 生成 attribute_serial
    attribute_serial = strcat(sprintf("%02d", attribute), attribute_names(attribute));
    
    % 定义路径
    lastPart = 'femalevivoi';
    source_file = fullfile('AlalyseResults', lastPart, attribute_serial, 'ellipPara', 'fitRes_level.mat');
    save_folder = fullfile("ellip_pic\ellipse", lastPart, attribute_serial);
    
    % 创建保存文件夹
    if ~exist(save_folder, "dir")
        mkdir(save_folder);
    end
    
    % 加载数据
    model = lastPart(1:end-1);
    load(source_file);
    [lastPart1, model1] = gen_lastPart1(lastPart);
    average_file = strcat("..\renderCode\aveSkinByHand2\", lastPart1, "\autoNhand_scaleoverLUT.mat");
    average = load(average_file);
    average = average.average_lab_all(:, 1:3);
    
    [n_para, ~] = size(par_all);
    
    lab_PMCC = [62.11, 18.96, 19.76];
    labC_PMCC = [lab_PMCC, sqrt(lab_PMCC(1, 2)^2 + lab_PMCC(1, 3)^2)];
    
    %% late CAT
    wd65_64 = [94.811, 100.00, 107.304];
    CT = [3000, 4000, 5000, 6000, 7000, 8000, 6500, ...
          3000, 4000, 5000, 6000, 7000, 8000, 6500, ...
          3000, 4000, 5000, 6000, 7000, 8000, 6500]';
    
    for i_para = 1:n_para
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
    
    %% 加载 labNscore 数据
    dir_labNgroup = dir(fullfile("AlalyseResults", lastPart, attribute_serial, "labNscore\*.mat"));
    load(fullfile("AlalyseResults",lastPart,attribute_serial, ...
        "delete_log\row_delete_data.mat"),"row_delete_all");
    for i_para = 1:n_para
        delete_row=row_delete_all{i_para,1}{1,1};
        figure(i_para);
        subplot('Position', [0.1, 0.3, 0.8, 0.6]); % 调整绘制区域位置和尺寸
        par = par_all(i_para, :);
        
        check_data2 = par(4) + (-30:0.2:30);
        check_data3 = par(5) + (-30:0.2:30);
        [data2, data3] = meshgrid(check_data2, check_data3);
        [row, col] = size(data2);
        
        a = par;
        y = (1 ./ (1 + a(6) * exp(sqrt(a(1) * (data2 - a(4)).^2 + a(2) * (data3 - a(5)).^2 + ...
            a(3) * (data2 - a(4)) .* (data3 - a(5)))))) .* ((a(1) * (data2 - a(4)).^2 + ...
            a(2) * (data3 - a(5)).^2 + a(3) * (data2 - a(4)) .* (data3 - a(5))) >= 0);
        
        s0 = contour(data2, data3, y, [0.5, 1], 'Linewidth', 2,'EdgeColor', 'k');
        hold on;
        
        % scatter
        MSVNlab = load(fullfile(dir_labNgroup(i_para).folder, dir_labNgroup(i_para).name));
        lab_group = MSVNlab.lab_group;
        MSV_group = MSVNlab.MSV_group;
        [max_MSV{attribute,i_para},max_ind{attribute,i_para}]=max(MSV_group);
        % scatter(lab_group(:, 2), lab_group(:, 3), 40, MSV_group, 'filled');
        valid_indices = setdiff(1:size(lab_group, 1), delete_row); % 获取未被删除的索引
        scatter(lab_group(valid_indices, 2), lab_group(valid_indices, 3), ...
            40, MSV_group(valid_indices), 'filled');
        hold on;    
        scatter(lab_group(delete_row, 2), lab_group(delete_row, 3), ...
            40, MSV_group(delete_row), 'o');

        if mod(i_para, 7) == 0
            colorbar; % 显示颜色条
        end
        hold on;
        
        scatter(par(4), par(5), 30,'k', 'filled');
        plot(lab_aft2(i_para, 2), lab_aft2(i_para, 3), 'p', 'MarkerSize', 10, ...
            'MarkerFaceColor', [0, 0, 1], 'MarkerEdgeColor', [0, 0, 1]); % 蓝色
        plot(labC_PMCCpre(i_para, 2), labC_PMCCpre(i_para, 3), 's', 'MarkerSize', 10, ...
            'MarkerFaceColor', [1, 0.4, 0.8], 'MarkerEdgeColor', [1, 0.4, 0.8]); % 保持原色
        
        annotation('textbox', [0.1, 0.02, 0.8, 0.15], 'String', ...
            sprintf(['fit center: [%.2f, %.2f] hue:%.2f°\n ' ...
                    'lab_{CATed}(summer): [%.2f, %.2f] hue:%.2f°\n' ...
                    'PMCC: [%.2f, %.2f] hue:%.2f°\n' ...
                    '45° Line: y = x'], ...
                    a(4), a(5), atan2d(a(5), a(4)), ...
                    lab_aft2(i_para, 2), lab_aft2(i_para, 3), ...
                    atan2d(lab_aft2(i_para, 3), lab_aft2(i_para, 2)), ...
                    labC_PMCCpre(2), labC_PMCCpre(3), atan2d(labC_PMCCpre(3), labC_PMCCpre(2))), ...
            'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
            'BackgroundColor', 'white', 'EdgeColor', 'black', 'FontSize', 8);
        
        xlabel('{\ita*}');
        ylabel('{\itb*}');
        % title(strcat(attribute_names(attribute), picname_check{i_para, 1}(length(lastPart) + 1:end)));
        title(strcat(attribute_names(attribute), picname_group(i_para)));

        lim_max = max(max(lab_group(:, 2)), max(lab_group(:, 3))) + 10;
        lim_min = min(min(lab_group(:, 2)), min(lab_group(:, 3))) - 10;
        line([0, 0], [lim_min, lim_max], 'Color', 'k', 'LineStyle', '--'); % x=0
        line([lim_min, lim_max], [0, 0], 'Color', 'k', 'LineStyle', '--'); % y=0
        refline(1, 0); % 45 度线
        
        hold on;
        axis equal;
        xlim([lim_min, lim_max]);
        ylim([lim_min, lim_max]);
        
        set(gcf, 'Color', 'white');
        % 保存图像
        exportgraphics(gcf, fullfile(save_folder, strcat(picname_group(i_para), '.jpg')), 'Resolution', 300);

        close(i_para); % 关闭当前图窗
    end
    
    % 拼接当前 attribute 的所有图像
    concatenate_images(save_folder, attribute_serial);
end
%%
save(fullfile(save_folder,"max.mat"),"max_ind","max_MSV");