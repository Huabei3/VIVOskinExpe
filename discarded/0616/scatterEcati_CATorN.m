close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量

%% 定义所有需要处理的 attribute
% attributes = [1, 2, 3, 4, 5, 6,7, 8, 9,10];
attributes = [1];
attribute_names = ["Preference", "Attractiveness", "Feminine", "Cooperative", ...
    "Youth", "Healthy", "Precise reproduction",...
    "suit the environment or not", "white-skinned", "ruddy"];
attribute_names_new = ["Preference", "Attractiveness", ...
    "Feminine", "Cooperative", ...
    "Youth", "Healthy", "Fidelity","Harmony", "Fair", "Ruddy"];

picname_group=["h3k","h4k","h5k","h6k","hd65","h7k","h8k",...
    "m3k","m4k","m5k","m6k","md65","m7k","m8k",...
    "l3k","l4k","l5k","l6k","ld65","l7k","l8k"];
    wd65_64 = [94.811, 100.00, 107.304];
CT = [3000, 4000, 5000, 6000, 7000, 8000, 6500, ...
      3000, 4000, 5000, 6000, 7000, 8000, 6500, ...
      3000, 4000, 5000, 6000, 7000, 8000, 6500]';
line_style={'-',':','-.'};
plot_style={'^','<','v'};
% 定义色环上的 7 种颜色
colors = hsv(3); % 使用 hsv 色图生成 7 种颜色
lastParts = {'f06i'};
datatype=['origin','altered'];



%%

Dtype='summer';
save_folder = fullfile("ellip_pic","CATorN");

% 创建保存文件夹
if ~exist(save_folder, "dir")
    mkdir(save_folder);
end

lab_PMCC = [62.11, 18.96, 19.76];
labC_PMCC = [lab_PMCC, sqrt(lab_PMCC(1, 2)^2 + lab_PMCC(1, 3)^2)];


average_file = strcat("aveSkin\f06i\autoNhand_scaleoverLUT.mat");
average_data = load(average_file);
average_ind = average_data.average_lab_all(:, 1:3);


%% 循环处理每个 attribute
% 定义路径

source_file{1} = fullfile(['AnalyseResults1\summer\f06i\non_model\' ...
    '01Preference\ellipPara'], 'fitRes_level.mat');
source_file{2} = fullfile(['AnalyseResults1\summer\add_inLab\f06i\' ...
    'non_model\01Preference\ellipPara'], 'fitRes_level.mat');

for attribute = [1]
    fprintf('Processing attribute: %d\n', attribute);
    attribute_serial = strcat(sprintf("%02d", attribute), attribute_names(attribute));
    
    for i_datatype=1:2
        % 加载数据
        par_all=[];
        if exist(source_file{i_datatype}, 'file') % 新增 source_file4 的加载
            parData=load(source_file{i_datatype});
            par_all = parData.par_all;
        else
            par_all(1:21,1:6)=NaN;
        end
        par_inds(:,:,i_datatype,attribute)=par_all;
    end
end



lim_min_x=inf;lim_min_y=inf;lim_max_x=-inf;lim_max_y=-inf;

lim_min_x=min(lim_min_x,min(min(min(par_inds(:,4:5,:)))))-15;
lim_max_x=max(lim_max_x,max(max(max(par_inds(:,4:5,:)))))+15;
lim_min_y=min(lim_min_y,min(min(min(par_inds(:,4:5,:)))))-15;
lim_max_y=max(lim_max_y,max(max(max(par_inds(:,4:5,:)))))+15;



for attribute = [1]
    fprintf('Processing attribute: %d\n', attribute);
    attribute_serial = strcat(sprintf("%02d", attribute), attribute_names_new(attribute));
        % 循环处理当前 light_level 的 i_para     
        Lab1=[average_ind(:,1),par_inds(:,4:5,1)];
        Lab2=[average_ind(:,1),par_inds(:,4:5,2)];
        
        dE = deltaE2000(Lab1,Lab2);
        for i_para = 1:21
            figure;
            hold on;
            set(gcf, 'Color', 'white');
            for i_datatype=1:2
                % 计算 labC_PMCCpre
                if average_ind(i_para, 1) <= 60
                    C_pre(i_para, 1) = 6.7421 * log(average_ind(i_para, 1)) - 9.9816; % 亮度实验
                else
                    C_pre(i_para, 1) = 6.7421 * log(60) - 9.9816; % 亮度实验
                end
                labC_PMCCpre(i_para, 1) = average_ind(i_para, 1);
                labC_PMCCpre(i_para, 2:3) = lab_PMCC(1, 2:3) ./ labC_PMCC(1, 4) .* C_pre(i_para, 1);
                labC_PMCCpre(i_para, 4) = C_pre(i_para, 1);
                % 绘制 source_file4 的 contour 或散点图 (新增部分)
                hold on;
                if exist('par_inds', 'var')&&~isempty(par_inds(:,:,i_datatype))
                    par = par_inds(i_para,:,i_datatype);                
                    scatter(par(4), par(5), 30, 'o','filled', ...
                        'MarkerFaceColor', colors(i_datatype, :));
                    attribute_char=char(attribute_serial);
                    text(par(4), par(5), ...
                        picname_group(i_para), 'FontSize', 7, ...
                        'VerticalAlignment', 'middle');
                    [CCT] = find_CCT(strcat("f06i",picname_group(i_para)));


                    check_data2 = par(4) + (-30:0.2:30);
                    check_data3 = par(5) + (-30:0.2:30);
                    [data2, data3] = meshgrid(check_data2, check_data3);
                    y = (1 ./ (1 + par(6) * exp(sqrt(par(1) * (data2 - par(4)).^2 + par(2) * (data3 - par(5)).^2 + ...
                        par(3) * (data2 - par(4)) .* (data3 - par(5)))))) .* ((par(1) * (data2 - par(4)).^2 + ...
                        par(2) * (data3 - par(5)).^2 + par(3) * (data2 - par(4)) .* (data3 - par(5))) >= 0);
                    contour(data2, data3, y, [0.5, 1], 'Linewidth', 1, 'Color', colors(i_datatype, :), ...
                         'LineStyle', '-');
                    text(lim_min_x+15, lim_min_y+15, ...
                        sprintf("dE:%d",dE(i_para)), 'FontSize', 7, ...
                        'VerticalAlignment', 'middle');

                end
                plot(labC_PMCCpre(i_para, 2), labC_PMCCpre(i_para, 3), 's', 'MarkerSize', 10, ...
                    'MarkerFaceColor', 'm', 'MarkerEdgeColor', 'm');
                
            end        
            colors_Dtype=hsv(5);
            D_types={"full","zhai","summer","OPPO"};
            dE_cell{i_para,1}=picname_group(i_para);
            dE_cell{i_para,2}=dE(i_para);
            
            for i_Dtype = 1:4
                Lab1_CATed=CAT_lab2lab1(Lab1, ...
                    D_types{i_Dtype},CCT,"fore");
                scatter(Lab1_CATed(i_para,2), Lab1_CATed(i_para,3), 30, 'p','filled', ...
                    'MarkerFaceColor', colors_Dtype(i_Dtype, :));
                if i_para==1
                    text(Lab1_CATed(i_para,2), Lab1_CATed(i_para,3), ...
                    D_types{i_Dtype}, 'FontSize', 7, ...
                    'VerticalAlignment', 'middle');
                end
                dE_cell{i_para,2+i_Dtype}=deltaE2000(Lab2(i_para,:),Lab1_CATed(i_para,:));
            end
            datai_file = '..\renderCode\calibResults\datai_ipv35_3.mat';
            LUT=load(datai_file);
            XYZw_LUT=LUT.XYZw;
            backgroundGray_file="..\renderCode\backgroundGray\i\backGroundGrayf06i.mat";
            load(backgroundGray_file,"xyz_gray");
            LA=xyz_gray(i_para,2);
            Lab1_CATed=CAT_lab2lab2(Lab1, ...
                "CAT16",CCT,"fore",LA);
            scatter(Lab1_CATed(i_para,2), Lab1_CATed(i_para,3), 30, 'p','filled', ...
                'MarkerFaceColor', colors_Dtype(5, :));
            dE_cell{i_para,3+i_Dtype}=deltaE2000(Lab2(i_para,:),Lab1_CATed(i_para,:));

                % 添加图例、标签和标题
            xlabel('{\ita*}');
            ylabel('{\itb*}');
            
            title(strcat(datatype(i_datatype),"a-b"));
            
            % 设置坐标轴范围
            x = linspace(0, 25, 100); % 从 -10 到 10，生成 100 个点
            plot(x, x); % 'r-' 表示红色实线
            axis equal;
            xlim([lim_min_x, lim_max_x]);
            ylim([lim_min_y, lim_max_y]);
            exportgraphics(gcf, fullfile(save_folder, ...
                strcat(picname_group(i_para), 'scatterEcat_attr_a_b.jpg')), ...
                'Resolution', 300);
            close(gcf);

    end
    

    
    
    
    % 保存图像
    if ~exist(fullfile(save_folder), "dir")
        mkdir(fullfile(save_folder));
    end  
    
    
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


% 调整图窗大小以确保所有内容可见
set(gcf, 'Position', [100, 100, 1200, 600]); % 设置图窗宽度为 1200，高度为 400

% 保存图例图
if ~exist(fullfile(save_folder, "legend"), "dir")
    mkdir(fullfile(save_folder, "legend"));
end
exportgraphics(gcf, fullfile(save_folder, "legend", strcat( '_lights_legend.jpg')), 'Resolution', 300);

close(gcf);