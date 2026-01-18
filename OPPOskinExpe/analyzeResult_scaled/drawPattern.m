close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量

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
xlabel('\textit{a*}', 'Interpreter', 'latex','FontSize', 12*2);
ylabel('\textit{b*}', 'Interpreter', 'latex','FontSize', 12*2);
title('\textit{a*-b*}', 'Interpreter', 'latex','FontSize', 12*2);

% 计算坐标轴范围
min_lim = min(min(num_points(:,2)), min(num_points(:,3))) -1; % 最小值
max_lim = max(max(num_points(:,2)), max(num_points(:,3))) +1; % 最大值

% 添加 45° 线
line([min_lim, max_lim], [min_lim, max_lim], ...
     'Color', 'b', 'LineStyle', '-', 'LineWidth', 0.5); % 蓝色实线，宽度为1
axis equal; % 保持比例
% 设置坐标轴范围
xlim([min_lim, max_lim]); % x 轴范围
ylim([min_lim, max_lim]); % y 轴范围


% 保存图表
exportgraphics(h1, fullfile(output_folder, '1.jpg'), 'Resolution', 150);

%% 绘制 L-a 图
h2 = figure(2);
grid on; box on;
hold on;
scatter(num_points(17:32,3), num_points(17:32,1), 10*2, 'o', 'LineWidth', 0.5, ...
    'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'k'); % 点改为实心
xlabel('\textit{a*}', 'Interpreter', 'latex','FontSize', 12*2);
ylabel('\textit{L*}', 'Interpreter', 'latex','FontSize', 12*2);
title('\textit{L*-a*}', 'Interpreter', 'latex','FontSize', 12*2);
axis equal; % 保持比例
% 设置坐标轴范围
xlim([min(num_points(:,3))-1, max(num_points(:,3))+1]); % 设置 x 轴范围
ylim([min(num_points(:,1))-15, max(num_points(:,1))+1]); % 设置 y 轴范围


% 保存图表
exportgraphics(h2, fullfile(output_folder, '2.jpg'), 'Resolution', 150);

%% 绘制 L-b 图
h3 = figure(3);
grid on; box on;
hold on;
scatter(num_points(33:48,2), num_points(33:48,1), 10*2, 'o', 'LineWidth', 0.5, ...
    'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'k'); % 点改为实心
xlabel('\textit{b*}', 'Interpreter', 'latex','FontSize', 12*2);
ylabel('\textit{L*}', 'Interpreter', 'latex','FontSize', 12*2);
title('\textit{L*-b*}', 'Interpreter', 'latex','FontSize', 12*2);
axis equal; % 保持比例
% 设置坐标轴范围
xlim([min(num_points(:,2))-1, max(num_points(:,2))+1]); % 设置 x 轴范围
ylim([min(num_points(:,1))-15, max(num_points(:,1))+1]); % 设置 y 轴范围


% 保存图表
exportgraphics(h3, fullfile(output_folder, '3.jpg'), 'Resolution', 150);
concatenate_images1_23(output_folder);