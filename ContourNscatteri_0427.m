close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量
%这一版是为了对比先CAT和后CAT研究为什么先CAT就会出现chroma过小的情况
%% 定义所有需要处理的 attribute
attributes = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
attribute_names_new = ["Preference", "Attractiveness", "Feminine", "Cooperative", ...
    "Youth", "Healthy", "Fidelity","Harmony", "Fair", "Ruddy"];

% lastParts = {'f04i'};
lastParts = {'f04r'};
iOr='r';
Dtype={'summer','noCAT'};
obs_type="non_model";
save_folder = fullfile("ellip_pic\ellipse", "test","summer");

% 创建保存文件夹
if ~exist(save_folder, "dir")
    mkdir(save_folder);
end

lab_PMCC = [62.11, 18.96, 19.76];
labC_PMCC = [lab_PMCC, sqrt(lab_PMCC(1, 2)^2 + lab_PMCC(1, 3)^2)];

% 定义色环上的 6 种颜色（每个 lastPart 一种颜色）
colors = hsv(3); % 使用 hsv 色图生成 6 种颜色

% 定义线型（每个 source_file 一种线型）
line_styles = {'-', '--', ':', '-.'};

%% 统计所有图的公共 lim_min 和 lim_max
[lim_min, lim_max] = calculate_global_limits(lastParts, attributes, attribute_names_new);
%% 求这几个lastPart的平均average
if iOr == 'i'
    len_group=21;
elseif iOr == 'r'
    len_group=14;
end
average_sum=zeros(len_group,3);
for lastPart_idx = 1:length(lastParts)
    lastPart = lastParts{lastPart_idx};
    if lastPart(end) == 'i'
        picnames_groups = ["h3k","h4k","h5k","h6k","hd65","h7k","h8k", ...
                        "m3k","m4k","m5k","m6k","md65","m7k","m8k",...
                         "l3k","l4k","l5k","l6k","ld65","l7k","l8k"];
    elseif lastPart(end) == 'r'
        picnames_groups = ["rs01","rs02","rs03","rs04","rs05","rs06","rs07", ...
                     "rs08","rs09","rs10","rs11","rs12","rs13","rs14"];
    end
    model = lastPart(1:end-1);
    [lastPart1, model1] = gen_lastPart1(lastPart);
    lastPart_new=gen_lastPart_new(lastPart1);
    disp([lastPart,lastPart_new])
    average_file = strcat("aveSkin\", lastPart_new, "\autoNhand_scaleoverLUT.mat");
    average_ind = load(average_file);
    average_ind = average_ind.average_lab_all(:, 1:3);
    average_sum=average_sum+average_ind;
end
average=average_sum./length(lastParts);
%% 循环处理每个 i_para（即每个 light）

for attribute = attributes
    fprintf('Processing attribute: %d\n', attribute);
    for i_para = 1:len_group
        % 创建新图窗
        figure;
        hold on;
        set(gcf, 'Color', 'white');
        
        % 生成 attribute_serial
        attribute_serial = strcat(sprintf("%02d", attribute), attribute_names_new(attribute));
        
        % 循环处理每个 lastPart
        for lastPart_idx = 1:length(lastParts)
            lastPart = lastParts{lastPart_idx};
            
            % 定义路径
            source_file{1} = fullfile('AnalyseResults1', "summer",lastPart, ...
                obs_type,attribute_serial, 'ellipPara', 'fitRes_level.mat');
            source_file{2} = fullfile('AnalyseResults1', "noCAT",lastPart, ...
                obs_type,attribute_serial, 'ellipPara', 'fitRes_level.mat');
            % 加载数据
            for i_Dtype=1:2
                par_all_used{i_Dtype}=[];
                if exist(source_file{i_Dtype}, 'file') % 新增 source_file 的加载
                    load(source_file{i_Dtype},"par_all");
                    par_all_used{i_Dtype} = par_all;
                else
                    par_all_used{i_Dtype}=[];
                end
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


            markers={"o","+"};
            mark_size=[30,20];
            % 绘制 source_file 的 contour 或散点图 (新增部分)
            for i_Dtype=1:2
                if ~isempty(par_all_used{i_Dtype})
                    par = par_all_used{i_Dtype}(i_para, :);
                    check_data2 = par(4) + (-30:0.2:30);
                    check_data3 = par(5) + (-30:0.2:30);
                    [data2, data3] = meshgrid(check_data2, check_data3);
                    y = (1 ./ (1 + par(6) * exp(sqrt(par(1) * (data2 - par(4)).^2 + par(2) * (data3 - par(5)).^2 + ...
                        par(3) * (data2 - par(4)) .* (data3 - par(5)))))) .* ((par(1) * (data2 - par(4)).^2 + ...
                        par(2) * (data3 - par(5)).^2 + par(3) * (data2 - par(4)) .* (data3 - par(5))) >= 0);
                    contour(data2, data3, y, [0.5, 1], 'Linewidth', 1, 'Color', colors(i_Dtype, :), ...
                        'DisplayName', strcat(lastPart, ' - source4'), 'LineStyle', '-');
                
                    fit_center(i_para,:)=[average(i_para,1),par(4), par(5)];
                    [CCT] = find_CCT(strcat(lastPart,'_',picnames_groups(i_para)));
                    if i_Dtype==2    
                        scatter(par(4), par(5), 30, 'o', 'filled', 'MarkerFaceColor', colors(i_Dtype, :));
                        fit_center(i_para,:)=CAT_lab2lab2(fit_center(i_para,:),"summer",CCT,"back");
                        par(4:5)=fit_center(i_para,2:3);
                    end
                    %scatter D65下拟合中心
                    scatter(par(4), par(5), mark_size(i_Dtype), 'v', 'filled', 'MarkerFaceColor', colors(i_Dtype, :));
                end
                %scatter CAT到拍摄光源下的拟合中心
                fit_center_CATed(i_para,:)=CAT_lab2lab1(fit_center(i_para,:),"summer",CCT,"fore");
                scatter(fit_center_CATed(i_para,2),fit_center_CATed(i_para,3), ...
                    mark_size(i_Dtype), '^', 'filled', 'MarkerFaceColor', colors(i_Dtype, :));
                %scatter渲染点
                labNscore_folder = fullfile('AnalyseResults1', ...
                    Dtype{i_Dtype}, lastPart,obs_type, ...
                    attribute_serial);
                dir_labNgroup = dir(fullfile(labNscore_folder, 'labNscore', ...
                strcat('labNscore_group', lastPart,...
                picnames_groups(i_para),'*.mat')));
                if ~isempty(dir_labNgroup)
                    labNgroup_file=fullfile(dir_labNgroup(1).folder, dir_labNgroup(1).name);
                end
                if exist(labNgroup_file,"file")
                    MSVNlab = load(labNgroup_file);
                    lab_group = MSVNlab.lab_group; % 原始 lab_group
                    MSV_group = MSVNlab.MSV_group; % 原始 MSV_group
                    scatter(lab_group(:, 2), lab_group(:, 3), 20, MSV_group, "Marker",markers(i_Dtype));
                    if i_Dtype==2    
                        lab_group_back=CAT_lab2lab1(lab_group,"summer",CCT,"back");
                        scatter(lab_group_back(:, 2), lab_group_back(:, 3), 20, MSV_group, "Marker","*");
                        
                    end
                end
            end


            
        end
        
        % 绘制 PMCC 点
        plot(labC_PMCCpre(i_para, 2), labC_PMCCpre(i_para, 3), 's', 'MarkerSize', 10, ...
            'MarkerFaceColor', 'm', 'MarkerEdgeColor', 'm');

        % 添加图例、标签和标题
        xlabel('{\ita*}');
        ylabel('{\itb*}');
        title(strcat('Light: ', picnames_groups(i_para), ' - ', attribute_serial));
        
        % 设置坐标轴范围
        xlim([-20, 60]);
        ylim([-20, 60]);
        % xlim([lim_min, lim_max]);
        % ylim([lim_min, lim_max]);
        
        % 保存图像
        if ~exist(fullfile(save_folder, attribute_serial), "dir")
            mkdir(fullfile(save_folder, attribute_serial));
        end
        exportgraphics(gcf, fullfile(save_folder, attribute_serial, strcat(picnames_groups(i_para), '_', attribute_serial, '.jpg')), 'Resolution', 300);
        close(gcf);
    end
    
end
for attribute = attributes
    attribute_serial = strcat(sprintf("%02d", attribute), attribute_names_new(attribute));
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


