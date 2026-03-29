
clear; close all;
addpath("utils\")
%%
targetFontSize=12;
save_folder = fullfile("ellip_pic_p\ellipse", "VIVOskin");
if ~exist(save_folder, "dir")
    mkdir(save_folder);
end
model_names = ["f01", "f02", "f03", "f04", ...
               "f05", "f06", "f07", "f08", "f09", "f10", ...
               "m01", "m02", "m03", "m04", "m05", "m06", "m07", ...
               "m08", "m09", "m10"];
nations=["AS","CA","SA","AF"];
num_colors=4;
hue_values = linspace(0, 1, num_colors + 1);
hue_values = hue_values(1:end-1); 
hsv_matrix = [hue_values', 0.8 * ones(num_colors, 1), 0.8 * ones(num_colors, 1)];
colors = hsv2rgb(hsv_matrix);
colors(3,:)=[0 0 0];
colors(4,:)=[1 0.5 0];
% 定义人种对应的lastParts索引
nation_indices = cell(5, 1); % 5个人种（包括"all"）
% AS (Asian): f04i, f05i, f06i, m04i, m05i, m06i (索引1-6)
nation_indices{1} = 1:6;
% CA (Caucasian): f01i, f02i, f03i, m01i, m02i, m03i (索引7-12)  
nation_indices{2} = 7:12;
% SA (South Asian): f07i, f08i, m07i, m08i (索引13-16)
nation_indices{3} = 13:16;
% AF (African): f09i, f10i, m09i, m10i (索引17-20)
nation_indices{4} = 17:20;
% all: 所有索引 (索引1-20)
nation_indices{5} = 1:20;

labCh_PMCC=[[62.11	18.96	19.76	27.39	46.18];...
            [64.15	19.56	19.63	27.71	45.10];...
            [56.01	18.25	18.72	26.14	45.72];...
            [41.06	17.37	17.94	24.97	45.93]];

% 读取数据
Data = readtable(fullfile("combined_data1.xlsx"), 'Sheet', "labC", 'ReadVariableNames', false);
% 提取第一列为 'mean' 的行
meanRows = Data(strcmp(Data{:, 1}, 'mean'), :);
% 提取第 2 到第 5 列并转换为矩阵
lab_mean1 = meanRows(:, 2:5);
lab_mean1 = table2array(lab_mean1);
% 逐行读取数据并填充矩阵
lab_mean = zeros(size(lab_mean1)); % 初始化矩阵
for i = 1:size(lab_mean1, 1)
    for j = 1:size(lab_mean1, 2)
        cellValue = lab_mean1(i, j);
        if isnumeric(cellValue)
            lab_mean(i, j) = cellValue;
        else
            lab_mean(i, j) = str2double(cellValue); % 将字符串转换为数值
        end
    end
end
% 提取 L, a, b, C 数据
all_L = lab_mean(:, 1);
all_a = lab_mean(:, 2);
all_b = lab_mean(:, 3);
C = lab_mean(:, 4);
h = atan2d(all_b, all_a);
h_table=[mean(h),max(h),min(h)];
all_LabCh = [all_L, all_a, all_b, C, h];
% 保存数据
save(fullfile(save_folder, "VIVOskin.mat"), "all_LabCh", "model_names");
% 设置坐标轴范围
L_limits = [min(all_L) - 5, max(all_L) + 5];
a_limits = [min(all_a) - 5, max(all_a) + 5];
b_limits = [min(all_b) - 5, max(all_b) + 5];
C_limits = [min(C) - 5, max(C) + 5];
h_limits = [min(h) - 5, max(h) + 5];
ab_limits = [min(min(all_a), min(all_b)) - 5, max(max(all_a), max(all_b)) + 5];
%% 加载preference

% for i_nation=1:length(nations)
%     fitRes_file=fullfile("AnalyseResults_p\efit_p\50\unscaled\nation1\scaled", ...
%         "non_model\i\01Preference",strcat(i_nation,nations(i_nation)),"1.mat");    
%     fitRes_data=load(fitRes_file);
%     cen_nations(i_nation,:)=[average_indices_curr(1),par(1,4:5)];
% 
% end

%%

if_arrow=0;
lastParts1 = {'f01i', 'f02i', 'f03i','f04i', 'f05i', ...
    'f06i', 'f07i', 'f08i','f09i', 'f10i',...
'm01i', 'm02i', 'm03i','m04i', 'm05i', 'm06i',...
'm07i', 'm08i','m09i', 'm10i'};
lastParts2 = {'female01', 'female02', 'female03','female04', 'female05', ...
    'female06', 'female07', 'female08','female09', 'female10',...
'male01', 'male02', 'male03','male04', 'male05', 'male06',...
'male07', 'male08','male09', 'male10'};
datai_file = 'D:\work\VIVOskinExpe\renderCode\calibResults\datai_ipv18_3.mat';
LUT=load(datai_file);
XYZw_LUT=LUT.XYZw;
wd65 = [94.811, 100.00, 107.304];
for i_skin = 1:length(lab_mean)
    lastPart=lastParts1{i_skin};
    white_file = fullfile("optimizedD\whiteSquare\XYZw_white", ...
        strcat(lastPart, ".mat"));
    XYZw_white_data=load(white_file,"XYZw_white");
    XYZw_white(i_skin,:)=XYZw_white_data.XYZw_white(5,:);

    fitRes_file = fullfile("AnalyseResults_p", "efit_p", "unscaled",lastPart, ...
        "non_model", "01Preference", 'ellipPara', ...
        strcat('fitRes.mat'));
    fitRes_data=load(fitRes_file);
    labNscore_file = fullfile("AnalyseResults_p", "efit_p", "unscaled",lastPart, ...
    "non_model", "01Preference", 'labNscore', ...
    strcat('labNscore_group', lastPart, "hd65", '.mat'));
    labNscore_data=load(labNscore_file);
    cen_pre_ori(i_skin,:)=[labNscore_data.average_curr(1),fitRes_data.par_all(5,4:5)];
    xyz_ave=lab2xyz2(cen_pre_ori(i_skin,:),"user",wd65./wd65(2).*XYZw_LUT(2));
    cen_pre(i_skin,1:3)=xyz2lab(xyz_ave,'user',wd65./wd65(2).*XYZw_white(i_skin,2));

    cen_pre(i_skin,4)=sqrt(cen_pre(i_skin,2).^2+cen_pre(i_skin,3).^2);
    cen_pre(i_skin,5)=atan2d(cen_pre(i_skin,3),cen_pre(i_skin,2));
    cen_pre_20{i_skin,1}=lastParts2{i_skin};
    cen_pre_20{i_skin,2}=cen_pre(i_skin,1);
    cen_pre_20{i_skin,3}=cen_pre(i_skin,2);
    cen_pre_20{i_skin,4}=cen_pre(i_skin,3);
    cen_pre_20{i_skin,5}=cen_pre(i_skin,4);
    cen_pre_20{i_skin,6}=cen_pre(i_skin,5);
end

%% 找色卡中与preference center最接近的
% for i_skin=1:length(cen_pre)
%     model_colors{i_skin,1}=lastParts1{i_skin};
%     model_colors{i_skin,2}=[];
%     model_colors{i_skin,3}=[];
% end
% chart_folder="D:\work\VIVOskinExpe\skin_color_chart\code\document";
% chart_file=fullfile(chart_folder,"my_data.csv");
% chart_data = csvread(chart_file);  % data 为数值矩阵
% for i_row=1:length(chart_data)
%     for i_skin=1:length(cen_pre)
%         de_cell(i_row,i_skin)=deltaE2000(chart_data(i_row,:),cen_pre(i_skin,1:3));
%     end
%     [de_clo,i_clo]=min(de_cell(i_row,:));
% 
%     chart_info{i_row,1}=chart_data(i_row,1);
%     chart_info{i_row,2}=chart_data(i_row,2);
%     chart_info{i_row,3}=chart_data(i_row,3);
%     chart_info{i_row,4}=lastParts2{i_clo};
%     chart_info{i_row,5}=i_clo;
%     closest_idx(i_row,1)=i_clo;
%     closest_model{i_row,1}=lastParts2{i_clo};
%     model_colors{i_clo,2}=[model_colors{i_clo,2};chart_data(i_row,:)];
%     model_colors{i_clo,3}=[model_colors{i_clo,3};i_row];
% end
% for i_skin=1:length(cen_pre)
%     [de_cor_patch,i_cor_patch]=min(de_cell(:,i_skin));
%     cen_pre_20{i_skin,7}=i_cor_patch;
%     cen_pre_20{i_skin,8}=chart_data(i_cor_patch,1);
%     cen_pre_20{i_skin,9}=chart_data(i_cor_patch,2);
%     cen_pre_20{i_skin,10}=chart_data(i_cor_patch,3);
%     lab_mean_cell{i_skin,1}=lastParts2{i_skin};
%     lab_mean_cell{i_skin,2}=lab_mean(i_skin,1);
%     lab_mean_cell{i_skin,3}=lab_mean(i_skin,2);
%     lab_mean_cell{i_skin,4}=lab_mean(i_skin,3);
% 
% end
% head_cell={'L','a','b','model_name','model_serial'};
% tbl = cell2table(chart_info, 'VariableNames', head_cell);
% writetable(tbl, fullfile(chart_folder,"closest_info.xlsx"),'Sheet', "120 patches");
% 
% 
% head_cell1={'model_name','L','a','b','C','h','nearest patch','L_patch','a_patch','b_patch'};
% tbl = cell2table(cen_pre_20, 'VariableNames', head_cell1);
% writetable(tbl, fullfile(chart_folder,"closest_info.xlsx"),'Sheet', "20 models preferred");
% 
% head_cell2={'model_name','L','a','b'};
% tbl = cell2table(lab_mean_cell, 'VariableNames', head_cell2);
% writetable(tbl, fullfile(chart_folder,"closest_info.xlsx"),'Sheet', "20 models measured");
% save(fullfile(chart_folder,"closest_info.mat"),"model_colors","closest_model","closest_idx");
%%
% a-b 图
figure;
hold on;
for i_skin = 1:length(lab_mean)
    lastPart=lastParts1{i_skin};



    if ismember(i_skin,[1,2,3,11,12,13])
        color=colors(2,:);
    elseif ismember(i_skin,[4,5,6,14,15,16])
        color=colors(1,:);
    elseif ismember(i_skin,[7,8,17,18])
        color=colors(3,:);
    else
        color=colors(4,:);
    end
    % 根据 i_skin 的值选择颜色和样式
    if i_skin <= 10
        plot_style="o";
        plot(lab_mean(i_skin, 2), lab_mean(i_skin, 3), plot_style, ...
            'MarkerFaceColor', 'none', 'MarkerEdgeColor', color, ...
            'MarkerSize', 5, 'LineWidth', 1.5);
        % if if_arrow
        % plot(cen_pre(i_skin, 2), cen_pre(i_skin, 3), 's', ...
        %     'MarkerFaceColor', 'none', 'MarkerEdgeColor', color, ...
        %     'MarkerSize', 5, 'LineWidth', 1.5);
        % end

    else
        plot_style = 'x'; 
        plot(lab_mean(i_skin, 2), lab_mean(i_skin, 3), plot_style, ...
            'MarkerFaceColor', color, 'MarkerEdgeColor', color, ...
            'MarkerSize', 8, 'LineWidth', 1.5);
        % if if_arrow
        % plot(cen_pre(i_skin, 2), cen_pre(i_skin, 3), '+', ...
        % 'MarkerFaceColor', 'none', 'MarkerEdgeColor', color, ...
        % 'MarkerSize', 5, 'LineWidth', 1.5);
        % end
    end
    if if_arrow
    % 计算箭头偏移量
    dx = cen_pre(i_skin, 2) - lab_mean(i_skin, 2);
    dy = cen_pre(i_skin, 3) - lab_mean(i_skin, 3);

    % 第5个参数"0"表示不缩放箭头长度，LineWidth控制箭头整体粗细
    q = quiver(lab_mean(i_skin, 2), lab_mean(i_skin, 3), dx, dy, 0, ...
        'Color', color, 'LineWidth', 1.2); % 调大LineWidth可等效加粗箭头
    end
    % text(cen_pre(i_skin, 2), cen_pre(i_skin, 3), num2str(i_skin), 'Color',color, 'FontSize', 10);
    % text(cen_pre(i_skin, 2), cen_pre(i_skin, 3), model_names(i_skin), 'Color',color, 'FontSize', 8);
end
if if_arrow
for i_eth=1:size(labCh_PMCC,1)
        color=colors(i_eth,:);
        plot(labCh_PMCC(i_eth, 2), labCh_PMCC(i_eth, 3), 's', ...
        'MarkerFaceColor', "none", 'MarkerEdgeColor', color, ...
        'MarkerSize', 8, 'LineWidth', 1.5);
end
end
% 添加45°线
x = linspace(ab_limits(1), ab_limits(2), 1000);
y = x; 
plot(x, y, 'k--', 'LineWidth', 1);

% title('a^*-b^*', 'Interpreter', 'tex','FontName', 'Arial', 'FontAngle', 'italic', 'FontSize', 12*2);
xlabel('a^{*}', 'Interpreter', 'tex', 'FontName', 'Arial', 'FontAngle', 'italic', 'FontSize', 2*targetFontSize);
ylabel('b^{*}', 'Interpreter', 'tex', 'FontName', 'Arial', 'FontAngle', 'italic', 'FontSize', 2*targetFontSize);
ax = gca;


set(ax, 'FontSize', 12);
axis equal;
xlim(ab_limits);
ylim(ab_limits);
outputFolder = fullfile(save_folder, 'VIVOskin');
if if_arrow
    outputFolder=fullfile(outputFolder,"compare_with_pre");
end
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end

ax = gca;
targetFontSize=12;
set(ax, 'FontSize', targetFontSize);
set(findobj(gcf, 'Type', 'Text'), 'FontSize', targetFontSize); % 针对 LaTeX 标签
set(findobj(gcf, 'Type', 'Text'), 'FontSize', targetFontSize); % 针对 LaTeX 标签
img_name=fullfile(outputFolder, 'all_a_b.jpg');    
savefig(gcf, strrep(img_name,'jpg','fig'));
exportgraphics(gcf,img_name , 'Resolution', 150);

%%
if ~if_arrow
% L-a 图
figure;
hold on;
for i_skin = 1:length(lab_mean)
    if ismember(i_skin,[1,2,3,11,12,13])
        color=colors(2,:);
    elseif ismember(i_skin,[4,5,6,14,15,16])
        color=colors(1,:);
    elseif ismember(i_skin,[7,8,17,18])
        color=colors(3,:);
    else
        color=colors(4,:);
    end
    % 根据 i_skin 的值选择颜色和样式
    if i_skin <= 10
        plot_style="o";
        plot(lab_mean(i_skin, 2), lab_mean(i_skin, 1), plot_style, ...
            'MarkerFaceColor', 'none', 'MarkerEdgeColor', color, 'MarkerSize', 5, 'LineWidth', 1.5);
    else
        plot_style = 'x'; 
        plot(lab_mean(i_skin, 2), lab_mean(i_skin, 1), plot_style, ...
            'MarkerFaceColor', color, 'MarkerEdgeColor', color, 'MarkerSize', 8, 'LineWidth', 1.5);
    end
    % text(lab_mean(i_skin, 2), lab_mean(i_skin, 1), model_names(i_skin), 'Color', 'black', 'FontSize', 5);
end
% title('L^*-a^*', 'Interpreter', 'tex','FontName', 'Arial', 'FontAngle', 'italic', 'FontSize', 12*2);
xlabel('a^{*}', 'Interpreter', 'tex', 'FontName', 'Arial', 'FontAngle', 'italic', 'FontSize', 2*targetFontSize);
ylabel('L^{*}','Interpreter', 'tex', 'FontName', 'Arial', 'FontAngle', 'italic', 'FontSize', 2*targetFontSize);
axis equal;
xlim(a_limits);
ylim(L_limits);

ax = gca;
set(ax, 'FontSize', targetFontSize);
set(findobj(gcf, 'Type', 'Text'), 'FontSize', targetFontSize); % 针对 LaTeX 标签
img_name=fullfile(outputFolder, 'all_L_a.jpg');    
savefig(gcf, strrep(img_name,'jpg','fig'));
exportgraphics(gcf, img_name, 'Resolution', 150);

% L-b 图
figure;
hold on;
for i_skin = 1:length(lab_mean)
    if ismember(i_skin,[1,2,3,11,12,13])
        color=colors(2,:);
    elseif ismember(i_skin,[4,5,6,14,15,16])
        color=colors(1,:);
    elseif ismember(i_skin,[7,8,17,18])
        color=colors(3,:);
    else
        color=colors(4,:);
    end
    % 根据 i_skin 的值选择颜色和样式
    if i_skin <= 10
        plot_style="o";
        plot(lab_mean(i_skin, 3), lab_mean(i_skin, 1), plot_style, ...
            'MarkerFaceColor', 'none', 'MarkerEdgeColor', color, 'MarkerSize', 5, 'LineWidth', 1.5);
    else
        plot_style = 'x'; 
        plot(lab_mean(i_skin, 3), lab_mean(i_skin, 1), plot_style, ...
            'MarkerFaceColor', color, 'MarkerEdgeColor', color, 'MarkerSize', 8, 'LineWidth', 1.5);
    end
    % text(lab_mean(i_skin, 3), lab_mean(i_skin, 1), model_names(i_skin), 'Color', 'black', 'FontSize', 5);
end

% title('L^*-b^*', 'Interpreter', 'tex','FontName', 'Arial', 'FontAngle', 'italic', 'FontSize', 12*2);
xlabel('b^{*}', 'Interpreter', 'tex', 'FontName', 'Arial', 'FontAngle', 'italic', 'FontSize', 2*targetFontSize);
ylabel('L^{*}','Interpreter', 'tex', 'FontName', 'Arial', 'FontAngle', 'italic', 'FontSize', 2*targetFontSize);
axis equal;
xlim(b_limits);
ylim(L_limits);

ax = gca;
set(ax, 'FontSize', targetFontSize);
set(findobj(gcf, 'Type', 'Text'), 'FontSize', targetFontSize); % 针对 LaTeX 标签
set(findobj(gcf, 'Type', 'Text'), 'FontSize', targetFontSize); % 针对 LaTeX 标签
img_name=fullfile(outputFolder, 'all_L_b.jpg');    
savefig(gcf, strrep(img_name,'jpg','fig'));
exportgraphics(gcf, img_name, 'Resolution', 150);
end
% L-C 图
figure;
hold on;
for i_skin = 1:length(lab_mean)
    if ismember(i_skin,[1,2,3,11,12,13])
        color=colors(2,:);
    elseif ismember(i_skin,[4,5,6,14,15,16])
        color=colors(1,:);
    elseif ismember(i_skin,[7,8,17,18])
        color=colors(3,:);
    else
        color=colors(4,:);
    end
    % 根据 i_skin 的值选择颜色和样式
    if i_skin <= 10
        plot_style="o";
        plot(lab_mean(i_skin, 4), lab_mean(i_skin, 1),plot_style, ...
            'MarkerFaceColor', 'none', 'MarkerEdgeColor', color, 'MarkerSize', 5, 'LineWidth', 1.5);
        % if if_arrow
        %     plot(cen_pre(i_skin, 4), cen_pre(i_skin, 1),'s', ...
        %         'MarkerFaceColor', 'none', 'MarkerEdgeColor', color, ...
        %         'MarkerSize', 5, 'LineWidth', 1.5);
        % end
    else
        plot_style = 'x'; 
        plot(lab_mean(i_skin, 4), lab_mean(i_skin, 1),plot_style, ...
            'MarkerFaceColor', color, 'MarkerEdgeColor', color, ...
            'MarkerSize', 8, 'LineWidth', 1.5);
        % if if_arrow
        % plot(cen_pre(i_skin, 4), cen_pre(i_skin, 1),'+', ...
        % 'MarkerFaceColor', color, 'MarkerEdgeColor', color, ...
        % 'MarkerSize', 8, 'LineWidth', 1.5);
        % end
    end
    if if_arrow
    dx = cen_pre(i_skin, 4) - lab_mean(i_skin, 4);
    dy = cen_pre(i_skin, 1) - lab_mean(i_skin, 1);
    q = quiver(lab_mean(i_skin, 4), lab_mean(i_skin, 1), dx, dy, 0, ...
    'Color', color, 'LineWidth', 1.2); % 调大LineWidth可等效加粗箭头
    end
    % plot(cen_pre(i_skin, 4), cen_pre(i_skin, 1), '^', ...
    % 'MarkerFaceColor', color, 'MarkerEdgeColor', color, 'MarkerSize', 5);
    % text(cen_pre(i_skin, 4), cen_pre(i_skin, 1), model_names(i_skin), 'Color',color, 'FontSize', 8);
    % text(lab_mean(i_skin, 4), lab_mean(i_skin, 1), model_names(i_skin), 'Color', 'black', 'FontSize', 5);
end
if if_arrow
for i_eth=1:size(labCh_PMCC,1)
        color=colors(i_eth,:);
        plot(labCh_PMCC(i_eth, 4), labCh_PMCC(i_eth, 1), 's', ...
        'MarkerFaceColor', "none", 'MarkerEdgeColor', color, ...
        'MarkerSize', 8, 'LineWidth', 1.5);
end
end
% title('L^*-C_{ab}^*', 'Interpreter', 'tex','FontName', 'Arial', 'FontAngle', 'italic', 'FontSize', 12*2);
xlabel('C_{ab}^{*}','Interpreter', 'tex', 'FontName', 'Arial', 'FontAngle', 'italic', 'FontSize', 2*targetFontSize);
ylabel('L^{*}','Interpreter', 'tex', 'FontName', 'Arial', 'FontAngle', 'italic', 'FontSize', 2*targetFontSize);
set(ax, 'FontSize', 12);
axis equal;
xlim(C_limits);
ylim(L_limits);


ax = gca;
set(ax, 'FontSize', targetFontSize);
set(findobj(gcf, 'Type', 'Text'), 'FontSize', targetFontSize); % 针对 LaTeX 标签
set(findobj(gcf, 'Type', 'Text'), 'FontSize', targetFontSize); % 针对 LaTeX 标签
img_name=fullfile(outputFolder, 'all_L_C.jpg');    
savefig(gcf, strrep(img_name,'jpg','fig'));
exportgraphics(gcf,img_name, 'Resolution', 150);

% 在每个 figure 绘制完成后，执行以下统一字体操作
ax = gca;

set(ax, 'FontSize', targetFontSize);
set(findobj(gcf, 'Type', 'Text'), 'FontSize', targetFontSize); % 针对 LaTeX 标签

% 保存为 .fig
savefig(gcf, fullfile(outputFolder, 'all_L_C.fig'));



%%
if ~if_arrow
% L-h 图
figure;
hold on;
for i_skin = 1:length(lab_mean)
    % 根据 i_skin 的值选择颜色和样式
    if ismember(i_skin,[1,2,3,11,12,13])
        color=colors(2,:);
    elseif ismember(i_skin,[4,5,6,14,15,16])
        color=colors(1,:);
    elseif ismember(i_skin,[7,8,17,18])
        color=colors(3,:);
    else
        color=colors(4,:);
    end
    if i_skin <= 10
        plot_style="o";
        plot(h(i_skin), lab_mean(i_skin, 1), plot_style, ...
            'MarkerFaceColor', 'none', 'MarkerEdgeColor', color, 'MarkerSize', 5, 'LineWidth', 1.5);
    else
        plot_style = 'x'; 
        plot(h(i_skin), lab_mean(i_skin, 1), plot_style, ...
            'MarkerFaceColor', color, 'MarkerEdgeColor', color, 'MarkerSize', 8, 'LineWidth', 1.5);
    end
    % text(h(i_skin), lab_mean(i_skin, 1), model_names(i_skin), 'Color', 'black', 'FontSize', 5);
end
% title('L^*-h_{ab}', 'Interpreter', 'tex','FontName', 'Arial', 'FontAngle', 'italic', 'FontSize', 24);
xlabel('h_{ab}','Interpreter', 'tex', 'FontName', 'Arial', 'FontAngle', 'italic', 'FontSize', 2*targetFontSize);
ylabel('L^{*}','Interpreter', 'tex', 'FontName', 'Arial', 'FontAngle', 'italic', 'FontSize', 2*targetFontSize);
axis equal;
xlim(h_limits);
ylim(L_limits);


ax = gca;
set(ax, 'FontSize', targetFontSize);
set(findobj(gcf, 'Type', 'Text'), 'FontSize', targetFontSize); % 针对 LaTeX 标签
set(findobj(gcf, 'Type', 'Text'), 'FontSize', targetFontSize); % 针对 LaTeX 标签
img_name=fullfile(outputFolder, 'all_L_h.jpg');    
savefig(gcf, strrep(img_name,'jpg','fig'));
exportgraphics(gcf, img_name, 'Resolution', 150);
end
concatenate_images1(outputFolder, 5);


%%


opts.targetFontSize=12;
opts.margin=0.25;    
opts.label_type="skinVIVO";
opts.if_rotate=false;
opts.margin_type="Position";

if if_arrow
    opts.axis_limits=[[5,30,25,75];[0,25,0,25]];
    opts.axis_ticks=[10,10];
else
    opts.axis_limits=[[0,30,25,75];[0,15,25,75];[0,25,25,75];[45,68,25,75];[0,25,0,25]];
    %  L-C L-a L-b L-h a-b
    opts.axis_ticks=[10,10,10,10,10];
end
% opts.bar_interval=0.4;
adjust_fig(outputFolder, opts);
%%
s.rowStep=0.17;

if if_arrow
    s.labels_row1 = {'Asian', 'Caucasian', 'South Asian', 'African'};
    s.labels_row2 = {'female', 'male','PMCC'};
    s.markers_row2 = {'o', 'x','s'};
    s.markers_colors = [0 0 0; 0 0 0;0 0 0];
    s.markers_face_colors = [1 1 1; 1 1 1; 1 1 1];
    s.label_type="skinVIVO_compare";
    s.leg_x_shift=-0.02;
    s.if_label=true;
    
    
    num_attributes = numel(s.labels_row1);
    hue_values = linspace(0, 1, num_attributes + 1);
    hue_values = hue_values(1:end-1);
    hsv_matrix = [hue_values', 0.8 * ones(num_attributes, 1), 0.8 * ones(num_attributes, 1)];
    s.colors_row1 = hsv2rgb(hsv_matrix);
    s.colors_row1(3,:)=[0 0 0];
    s.colors_row1(4,:)=[1 0.5 0];
    s.fontSizeScale=1.2;
    %----------------------
    figFiles = {'all_a_badjusted.fig', 'all_L_Cadjusted.fig'};
    concatenate_figs_legend1(outputFolder, figFiles, 2,"","draw",s,0.15,1.2);
else

    s.labels_row1 = {'Asian', 'Caucasian', 'South Asian', 'African'};
    s.labels_row2 = {'female', 'male'};
    s.markers_row2 = {'o', 'x'};
    s.markers_colors = [0 0 0; 0 0 0];
    s.markers_face_colors = [1 1 1; 1 1 1];
    s.label_type="skinVIVO";
    s.marginL=0;
    s.fig_wh_base=[1000 900];
    s.colGap2_scale=1.5;
    s.if_label=true;
    
    num_attributes = numel(s.labels_row1);
    hue_values = linspace(0, 1, num_attributes + 1);
    hue_values = hue_values(1:end-1);
    hsv_matrix = [hue_values', 0.8 * ones(num_attributes, 1), 0.8 * ones(num_attributes, 1)];
    s.colors_row1 = hsv2rgb(hsv_matrix);
    s.colors_row1(3,:)=[0 0 0];
    s.colors_row1(4,:)=[1 0.5 0];
    s.fontSizeScale=1.2;
    %----------------------
    dir_figs=dir(fullfile(outputFolder,"*adjusted.fig"));
    for i_fig=1:length(dir_figs)
        figFiles{i_fig}=dir_figs(i_fig).name;
    end
    concatenate_figs_legend1(outputFolder, figFiles, 5,"","draw",s,0.07,1.9);
end

fullfile(pwd,outputFolder)