clc;clear;close all;
% 读取Excel文件中的第一列和第二列数据
% 假设文件名为data.xlsx，数据从第一行开始
[data, headers] = xlsread('..\points_added_33.xlsx');

% 提取第一列和第二列数据
x = data(:, 1);  % 第一列数据作为x轴
y = data(:, 2);  % 第二列数据作为y轴

% 创建图形
figure;
scatter(x, y, 20, 'k', 'filled');  % 绘制散点图，点大小50，蓝色，填充
% title("pre-selected points",  'FontSize', 12*2);
% 添加标题和轴标签
% title('第一列和第二列数据关系图', 'FontSize', 14);
xlabel('\textit{a*}', 'Interpreter', 'latex', 'FontSize', 12*2);
ylabel('\textit{b*}', 'Interpreter', 'latex', 'FontSize', 12*2);

lim_max = max(max(x), max(y)) + 5;
lim_min = min(min(x), min(y)) - 5;

% 添加 x=0 和 y=0 的轴
line([0, 0], [lim_min, lim_max], 'Color', 'k', 'LineStyle', '--'); % x=0
line([lim_min, lim_max], [0, 0], 'Color', 'k', 'LineStyle', '--'); % y=0

% 添加 45 度线
rl = refline(1, 0);  % 斜率为1，截距为0的直线
set(rl, 'Color', 'k', 'LineStyle', '--', 'LineWidth', 1.2);  % 设置为黑色虚线

% 设置图形属性
hold on;
axis equal;
xlim([lim_min, lim_max]);
ylim([lim_min, lim_max]);
exportgraphics(gcf,fullfile("ellip_pic_p_free","pre_selected_points.jpg"),"Resolution",150);