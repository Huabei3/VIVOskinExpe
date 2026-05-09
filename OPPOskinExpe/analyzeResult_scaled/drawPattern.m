close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量

interpreter_type="tex";  % 可选 "tex" 或 "latex"

%% 读取数据
num_points = readmatrix('points48.xlsx'); 
num_points(50:53,:) = []; % 删除第 50 到 53 行

%% 创建保存图表的文件夹
output_folder = 'documents\rendering_pattern';
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end

%% 绘制 a-b 图
h1 = figure(1);
grid on; box on;
hold on;
scatter(num_points(1:16,2), num_points(1:16,3), 10*2, 'o', 'LineWidth', 0.5, ...
    'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'k'); % 点改为实心
if strcmp(interpreter_type,"tex")
    xlabel('a*','Interpreter','tex','FontName','Arial','FontAngle','italic', 'FontSize',12*2);
    ylabel('b*','Interpreter','tex','FontName','Arial','FontAngle','italic', 'FontSize',12*2);
elseif strcmp(interpreter_type,"latex")
    xlabel('\textit{a*}', 'Interpreter', 'latex','FontSize', 12*2);
    ylabel('\textit{b*}', 'Interpreter', 'latex','FontSize', 12*2);
end
% title('\textit{a*-b*}', 'Interpreter', 'latex','FontSize', 12*2);

% 计算坐标轴范围
min_lim = min(min(num_points(:,2)), min(num_points(:,3))) -1; % 最小值
max_lim = max(max(num_points(:,2)), max(num_points(:,3))) +1; % 最大值

% 添加 45° 线
line([min_lim, max_lim], [min_lim, max_lim], ...
     'Color', 'k', 'LineStyle', '--', 'LineWidth',1); % 蓝色实线，宽度为1
axis equal; % 保持比例
% 设置坐标轴范围
xlim([min_lim, max_lim]); % x 轴范围
ylim([min_lim, max_lim]); % y 轴范围


% 保存图表
img_name=fullfile(output_folder, '1.jpg');    
savefig(gcf, strrep(img_name,'jpg','fig'));
exportgraphics(h1, img_name, 'Resolution', 150);

%% 绘制 L-a 图
h2 = figure(2);
grid on; box on;
hold on;
scatter(num_points(17:32,3), num_points(17:32,1), 10*2, 'o', 'LineWidth', 0.5, ...
    'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'k'); % 点改为实心
if strcmp(interpreter_type,"tex")
    xlabel('a*','Interpreter','tex','FontName','Arial','FontAngle','italic', 'FontSize',12*2);
    ylabel('L*','Interpreter','tex','FontName','Arial','FontAngle','italic', 'FontSize',12*2);
elseif strcmp(interpreter_type,"latex")
    xlabel('\textit{a*}', 'Interpreter', 'latex','FontSize', 12*2);
    ylabel('\textit{L*}', 'Interpreter', 'latex','FontSize', 12*2);
end
% title('\textit{L*-a*}', 'Interpreter', 'latex','FontSize', 12*2);
axis equal; % 保持比例
% 设置坐标轴范围
xlim([min(num_points(:,3))-1, max(num_points(:,3))+1]); % 设置 x 轴范围
ylim([min(num_points(:,1))-15, max(num_points(:,1))+1]); % 设置 y 轴范围


% 保存图表
img_name=fullfile(output_folder, '2.jpg');    
savefig(gcf, strrep(img_name,'jpg','fig'));
exportgraphics(h2, img_name, 'Resolution', 150);

%% 绘制 L-b 图
h3 = figure(3);
grid on; box on;
hold on;
scatter(num_points(33:48,2), num_points(33:48,1), 10*2, 'o', 'LineWidth', 0.5, ...
    'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'k'); % 点改为实心
if strcmp(interpreter_type,"tex")
    xlabel('b*','Interpreter','tex','FontName','Arial','FontAngle','italic', 'FontSize',12*2);
    ylabel('L*','Interpreter','tex','FontName','Arial','FontAngle','italic', 'FontSize',12*2);
elseif strcmp(interpreter_type,"latex")
    xlabel('\textit{b*}', 'Interpreter', 'latex','FontSize', 12*2);
    ylabel('\textit{L*}', 'Interpreter', 'latex','FontSize', 12*2);
end
% title('\textit{L*-b*}', 'Interpreter', 'latex','FontSize', 12*2);
axis equal; % 保持比例
% 设置坐标轴范围
xlim([min(num_points(:,2))-1, max(num_points(:,2))+1]); % 设置 x 轴范围
ylim([min(num_points(:,1))-15, max(num_points(:,1))+1]); % 设置 y 轴范围


% 保存图表
img_name=fullfile(output_folder, '3.jpg');    
savefig(gcf, strrep(img_name,'jpg','fig'));
exportgraphics(h3, img_name, 'Resolution', 150);
% concatenate_images1_23(output_folder);


%%
% concatenate_images1(output_folder,2);
outputFolder=fullfile(output_folder, "gender",'ellipPara_scaled');
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end
% save(fullfile(outputFolder, "fitRes_level.mat"),...
%     "lab_f","p_f","lab_m","p_m", ...
%     "par_all","r_all",'picname_cor_f','picname_cor_m');

fullfile(pwd,output_folder)
%%

opts.targetFontSize=12;
opts.margin=0.18;    
opts.label_type="pattern";
opts.if_rotate=false;



adjust_fig(output_folder, opts);
%%
text_type="ch";
if strcmp(text_type,"eng")
    s.labels_row1 = {};
    s.labels_row2 = {};
elseif strcmp(text_type,"ch")
    s.labels_row1 = {};
    s.labels_row2 = {};
end

s.markers_row2 = {};
s.markers_colors = [];
s.markers_face_colors=[];
s.colors_row1 = [];

s.interpreter_type=interpreter_type;  % 传递给concatenate_figs_legend1
s.sidePad=0.2;
s.if_label=1;
s.marginL=0;
s.leg_x_shift=-0.1;
s.h_space_scale=0.7;
s.posY_shift=0.2;
s.rowStep=0.2;
%----------------------
dir_figs=dir(fullfile(output_folder,"*adjusted.fig"));   
clear("figFiles");i_fig1=1;
for i_fig=1:length(dir_figs)
    figFiles{i_fig1}=dir_figs(i_fig).name;
    i_fig1=i_fig1+1;
end

legend_file="";
s.tickFontScale = 0.9; 
s.fontSizeScale=1.2;
s.label_x_offset=-0.02;
s.label_y_offset=-0.01;
concatenate_figs_legend1(output_folder, figFiles, 3,legend_file,"draw",s,0.15,0.4);


fullfile(pwd,output_folder)