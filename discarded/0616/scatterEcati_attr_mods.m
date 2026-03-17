close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量

%% 定义所有需要处理的 attribute
attributes = [1, 2, 3, 4, 5, 6,7, 8, 9,10];
attribute_names = ["Preference", "Attractiveness", "Feminine", "Cooperative", ...
    "Youth", "Healthy", "Precise reproduction","suit the environment or not", "white-skinned", "ruddyadd"];
attribute_names_new = ["Preference", "Attractiveness", "Feminine", "Cooperative", ...
    "Youth", "Healthy", "Fidelity","Harmony", "Fair", "Ruddy"];
picname_group=["h3k","h4k","h5k","h6k","h7k","h8k","hd65",...
    "l3k","l4k","l5k","l6k","l7k","l8k","ld65",...
    "m3k","m4k","m5k","m6k","m7k","m8k","md65"];
    wd65_64 = [94.811, 100.00, 107.304];
CT = [3000, 4000, 5000, 6000, 7000, 8000, 6500, ...
      3000, 4000, 5000, 6000, 7000, 8000, 6500, ...
      3000, 4000, 5000, 6000, 7000, 8000, 6500]';
line_style={'-',':','-.'};
plot_style={'^','<','v'};
% 定义色环上的 7 种颜色
colors = hsv(10); % 使用 hsv 色图生成 7 种颜色
    lastParts = {'f04iadd', 'f05iadd', 'f06iadd', ...
    'm04iadd', 'm05iadd', 'm06iadd'};
    gender=['f','m'];
obs_types=["non_model","model_group","model","all"];
obs_types_new=["stranger","aquantance","self","all"];

%%

cm700d = readcell('combined_data1.xlsx'); % 使用 readcell 读取数据，不自动解析表头
cm700d_res = {}; % 初始化结果 cell 数组
% 初始化变量
current_model = '';
mean_row = [];
% 遍历数据
for i = 1:size(cm700d, 1)
    row = cm700d(i, :); % 当前行数据
    cell_data = row{1}; % 当前行的第一个单元格内容
    if ischar(cell_data) && (startsWith(cell_data, 'f0') || startsWith(cell_data, 'm0')) && ~strcmp(cell_data, 'mean')
        current_model = cell_data;
    elseif strcmp(cell_data, 'mean') && ~isempty(current_model)
        cm700d_res{end+1, 1} = current_model; % model 名称
        cm700d_res{end, 2} = str2double(row{2});
        cm700d_res{end, 3} = str2double(row{3});
        cm700d_res{end, 4} = str2double(row{4}); % 对应的 mean 值
    end
end

lab_cm700d=cm700d_res([4:6,14:16],2:4);
lab_cm700d=cell2mat(lab_cm700d);
lab_cm700d(:,4)=sqrt(lab_cm700d(:,2).^2+lab_cm700d(:,3).^2);
%%
for i_obstype=1:1
    for lastPart_idx = 1:length(lastParts)
        lastPart = lastParts{lastPart_idx};
        Dtype='summer';
        save_folder = fullfile("ellip_pic\ellipse1",  Dtype, ...
            "scatterCen","HD65attr_ave","withcm700d",obs_types(i_obstype));
        
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
        average_file = strcat("aveSkin\", strrep(lastPart_new,"add",""), "\autoNhand_scaleoverLUT.mat");
        average_data = load(average_file);
        average_inds(:,:,lastPart_idx) = average_data.average_lab_all(:, 1:3);
    
    
        %% 循环处理每个 attribute
        % for attribute = [10]
        for attribute = attributes
            fprintf('Processing attribute: %d\n', attribute);
            attribute_serial = strcat(sprintf("%02d", attribute), attribute_names_new(attribute));
            
            % 定义路径
            source_file{1} = fullfile('AnalyseResults1', Dtype,lastPart,'non_model', attribute_serial, 'ellipPara', 'fitRes_level.mat');
            source_file{2} = fullfile('AnalyseResults1',  Dtype,lastPart, 'model_group', attribute_serial, 'ellipPara', 'fitRes_level.mat');
            source_file{3} = fullfile('AnalyseResults1', Dtype, lastPart, 'model', attribute_serial, 'ellipPara', 'fitRes_level.mat');
            source_file{4} = fullfile('AnalyseResults1',  Dtype,lastPart, 'all', attribute_serial, 'ellipPara', 'fitRes_level.mat'); % 新增 source_file4
            
            % 加载数据
            par_all=[];
            if exist(source_file{i_obstype}, 'file') % 新增 source_file4 的加载
                parData=load(source_file{i_obstype});
                par_all = parData.par_all;
            else
                par_all(1:21,1:6)=NaN;
            end
            par_inds(:,:,lastPart_idx,attribute)=par_all;
        end
    end
    for lastPart_idx = 1:length(lastParts)
        average{lastPart_idx}=nanmean(average_inds(:,:,lastPart_idx),3);
        par_all4{lastPart_idx}=nanmean(par_inds(:,:,lastPart_idx,:),3);
    end
    
    % 初始化变量
    mean_par_all4_5_4 = [];
    mean_par_all4_5_5 = [];
    
    % 遍历 lastParts，提取每个单元格中的 (5,4,:,:) 和 (5,5,:,:)
    for lastPart_idx = 1:length(lastParts)
        mean_par_all4_5_4 = cat(3, mean_par_all4_5_4, par_all4{lastPart_idx}(5,4,:,:));
        mean_par_all4_5_5 = cat(3, mean_par_all4_5_5, par_all4{lastPart_idx}(5,5,:,:));
    end
    % 沿第 3 维（即 lastPart_idx 维）求平均值
    mean_par_all4_5_4 = squeeze(mean(mean_par_all4_5_4, 3));
    mean_par_all4_5_5 = squeeze(mean(mean_par_all4_5_5, 3));
    % 计算 lim_min_x 和 lim_max_x
    lim_min_x = min(mean_par_all4_5_4(:)) - 3;
    lim_max_x = max(mean_par_all4_5_4(:)) + 3;
    % 计算 lim_min_y 和 lim_max_y
    lim_min_y = min(mean_par_all4_5_5(:)) - 3;
    lim_max_y = max(mean_par_all4_5_5(:)) + 3;

    for lastPart_idx = 1:length(lastParts)
        lastPart = lastParts{lastPart_idx};
        figure;
        hold on;
        set(gcf, 'Color', 'white');
        for attribute = attributes
            fprintf('Processing attribute: %d\n', attribute);
            attribute_serial = strcat(sprintf("%02d", attribute), attribute_names_new(attribute));
                % 循环处理当前 light_level 的 i_para
                for i_para = [5]
                % for i_para = 1:21
        
                    % 计算 labC_PMCCpre
                    if average{lastPart_idx}(i_para, 1) <= 60
                        C_pre(i_para, 1) = 6.7421 * log(average{lastPart_idx}(i_para, 1)) - 9.9816; % 亮度实验
                    else
                        C_pre(i_para, 1) = 6.7421 * log(60) - 9.9816; % 亮度实验
                    end
                    labC_PMCCpre(i_para, 1) = average{lastPart_idx}(i_para, 1);
                    labC_PMCCpre(i_para, 2:3) = lab_PMCC(1, 2:3) ./ labC_PMCC(1, 4) .* C_pre(i_para, 1);
                    labC_PMCCpre(i_para, 4) = C_pre(i_para, 1);
    
                    lab_cm700d_pre(i_para, 1) = average{lastPart_idx}(i_para, 1);
                    lab_cm700d_pre(i_para, 2:3) = lab_cm700d(lastPart_idx, 2:3) ./ lab_cm700d(lastPart_idx, 4) .* C_pre(i_para, 1);
                    lab_cm700d_pre(i_para, 4) = C_pre(i_para, 1);
                    % 绘制 source_file4 的 contour 或散点图 (新增部分)
                    hold on;
                    if exist('par_all4', 'var')&&~isempty(par_all4{lastPart_idx})
                        par = par_all4{lastPart_idx}(i_para, :,attribute);                
                        scatter(par(4), par(5), 30, 'o','filled', ...
                            'MarkerFaceColor', colors(attribute, :));
                        attribute_char=char(attribute_serial);
                        text(par(4), par(5), ...
                            attribute_char(1:2), 'FontSize', 7, ...
                            'VerticalAlignment', 'middle');
                    end
                    plot(labC_PMCCpre(i_para, 2), labC_PMCCpre(i_para, 3), 's', 'MarkerSize', 10, ...
                        'MarkerFaceColor', 'm', 'MarkerEdgeColor', 'm');
                    % plot(lab_cm700d(lastPart_idx, 2), lab_cm700d(lastPart_idx, 3), 'p', 'MarkerSize', 10, ...
                    %     'MarkerFaceColor', 'm', 'MarkerEdgeColor', 'm');
                    plot(lab_cm700d_pre(i_para, 2), lab_cm700d_pre(i_para, 3), 'p', 'MarkerSize', 10, ...
                        'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'b');
                end        
        end
        
        % 添加图例、标签和标题
        xlabel('{\ita*}');
        ylabel('{\itb*}');
        
        lastPart_new=gen_lastPart_new(lastPart);
        title(strcat(obs_types_new(i_obstype),' ',lastPart_new,' ',"a-b"));
        
        % 设置坐标轴范围
        x = linspace(0, 25, 100); % 从 -10 到 10，生成 100 个点
        plot(x, x); % 'r-' 表示红色实线
        axis equal;
        xlim([lim_min_x, lim_max_x]);
        ylim([lim_min_y, lim_max_y]);
        
        
        
        % 保存图像
        if ~exist(fullfile(save_folder), "dir")
            mkdir(fullfile(save_folder));
        end
        
        exportgraphics(gcf, fullfile(save_folder, strcat(lastPart_new, 'scatterEcat_attr_a_b.jpg')), 'Resolution', 300);
        close(gcf);
    end
concatenate_images1(fullfile(save_folder) ,3);

end

% %L-a
% for i_gender=1:2
%     C{i_gender} = sqrt(par_inds(:, 4, range{i_gender}, :).^2 + ...
%     par_inds(:, 5, range{i_gender}, :).^2);
% end
% lim_min_x=inf;lim_min_y=inf;lim_max_x=-inf;lim_max_y=-inf;
% for i_gender=1:2
%     lim_min_x =min(lim_min_x,min(min(min(C{i_gender}(7, 1, :, :)))))  - 1;
%     lim_max_x = max(lim_max_x,max(max(max(C{i_gender}(7, 1, :, :))))) + 1;
%     lim_min_y = min(lim_min_y,min(min(average{i_gender}(7,1, :)))) - 1;
%     lim_max_y = max(lim_max_y,max(max(average{i_gender}(7,1,:)))) + 1;
% end
% for i_gender=1:2
%     figure;
%     hold on;
%     set(gcf, 'Color', 'white');
%     for attribute = attributes
%         fprintf('Processing attribute: %d\n', attribute);
%         attribute_serial = strcat(sprintf("%02d", attribute), attribute_names_new(attribute));
%             % 循环处理当前 light_level 的 i_para
%             for i_para = [7]
% 
%                 hold on;
%                 if exist('par_all4', 'var')&&~isempty(par_all4{i_gender})
%                     par = par_all4{i_gender}(i_para, :,attribute);                
%                     scatter(C{i_gender}(i_para,1,1,attribute), average{i_gender}(i_para,1), 30, 'o','filled', ...
%                         'MarkerFaceColor', colors(attribute, :));
%                     attribute_char=char(attribute_serial);
%                     text(C{i_gender}(i_para,1,1,attribute), average{i_gender}(i_para,1), ...
%                         attribute_char(1:2), 'FontSize', 7, ...
%                         'VerticalAlignment', 'middle');
%                 end
%                 plot(C_pre(i_para, 1), labC_PMCCpre(i_para, 1), 's', 'MarkerSize', 10, ...
%                     'MarkerFaceColor', 'm', 'MarkerEdgeColor', 'm');
%             end        
%     end
% 
%     % 添加图例、标签和标题
%     xlabel('{\ita*}');
%     ylabel('{\itb*}');
% 
%     title(strcat(gender(i_gender),"L-a"));
% 
%     % 设置坐标轴范围
%     axis equal;
%     xlim([lim_min_x, lim_max_x]);
%     ylim([lim_min_y, lim_max_y]);
% 
%     exportgraphics(gcf, fullfile(save_folder, strcat(gender(i_gender), 'scatterEcat_attr_L_a1.jpg')), 'Resolution', 300);
%     close(gcf);
% end
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
exportgraphics(gcf, fullfile(save_folder, "legend", strcat(lastPart, '_lights_legend.jpg')), 'Resolution', 300);

close(gcf);


% 创建一个新图形窗口
figure;


% 绘制正方形
annotation('textbox', [0.1, 0.6, 0.1, 0.1], 'String', '■', 'FontSize', 20, 'EdgeColor', 'none', 'HorizontalAlignment', 'center'); % 正方形图标
annotation('textbox', [0.25, 0.6, 0.2, 0.1], 'String', 'PMCC', 'FontSize', 12, 'EdgeColor', 'none', 'HorizontalAlignment', 'left'); % 在正方形后面添加文本

% 绘制五角星
annotation('textbox', [0.1, 0.4, 0.1, 0.1], 'String', '★', 'FontSize', 20, 'EdgeColor', 'none', 'HorizontalAlignment', 'center'); % 五角星图标
annotation('textbox', [0.25, 0.4, 0.2, 0.1], 'String', 'CM700d', 'FontSize', 12, 'EdgeColor', 'none', 'HorizontalAlignment', 'left'); % 在五角星后面添加文本

% 关闭坐标轴（因为这里没有用到数据坐标系）
axis off;

exportgraphics(gcf, fullfile(save_folder, "legend", strcat(lastPart, 'icon.jpg')), 'Resolution', 300);

close(gcf);
