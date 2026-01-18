% 读取数据
data = [
    65.62  16.51  20.23  26.11  50.78;  % Female1
    70.09  18.71  24.83  31.09  53.00;  % Female2
    64.36  17.02  21.37  27.32  51.46;  % female3
    58.29  17.76  18.07  25.34  45.50;  % Female4
    60.40  16.63  17.65  24.26  46.70;  % Female5
    58.92  18.45  19.71  27.00  46.90;  % Male1
    59.75  17.70  21.37  27.75  50.37;  % Male2
    67.18  20.52  20.72  29.16  45.28;  % Male3
    60.02  17.02  19.77  26.09  49.28;  % Male4
    61.82  17.20  19.42  25.94  48.46;  % Female
    60.90  18.22  20.30  27.27  48.09;  % Male
    65.89  18.54  23.51  29.94  51.74;  % With makeup
    66.01  18.24  22.95  29.32  51.53;  % Without makeup
    65.19  19.08  23.00  29.89  50.32;  % In-lab
    59.22  18.34  19.56  26.81  46.85;  % Indoor
    61.78  16.70  19.72  25.84  49.74;  % Night
    57.49  16.20  17.25  23.66  46.81;  % Outdoor
    62.87  16.17  14.94  22.02  42.75]; % Sunset

% 样本标签
labels = {'Female1', 'Female2', 'female3', 'Female4', 'Female5', ...
          'Male1', 'Male2', 'Male3', 'Male4', 'Female', 'Male', ...
          'With makeup', 'Without makeup', 'In-lab', 'Indoor', ...
          'Night', 'Outdoor', 'Sunset'};

% 提取需要绘图的数据列 (L*, C*, h)
L_values = data(:, 1);   % L*列
C_values = data(:, 4);   % C*列
h_values = data(:, 5);   % h列

% 设置图形保存路径
output_folder = 'ellip_pic\LCH_BarCharts';
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end

% 1. 绘制L*的柱状图
figure('Name', 'L* Values', 'Position', [100, 100, 1000, 600]);
bar(L_values, 'FaceColor', [0.2, 0.5, 0.8]);  % 蓝色
set(gca, 'XTick', 1:length(labels), 'XTickLabel', labels, ...
    'XTickLabelRotation', 45, 'FontSize', 10);

title('\textit{L*}', 'Interpreter', 'latex','FontSize', 14, 'FontWeight', 'bold');
ylabel('\textit{L*}', 'Interpreter', 'latex','FontSize', 12);
grid on;
box on;
ylim([min(L_values)-2, max(L_values)+2]); 
yticks(round(min(L_values)-2):5: round(max(L_values)+2));
exportgraphics(gcf, fullfile(output_folder, 'L_values.jpg'), 'Resolution', 300);

% 2. 绘制C*的柱状图
figure('Name', 'C* Values', 'Position', [100, 200, 1000, 600]);
bar(C_values, 'FaceColor', [0.8, 0.3, 0.3]);  % 红色
set(gca, 'XTick', 1:length(labels), 'XTickLabel', labels, ...
    'XTickLabelRotation', 45, 'FontSize', 10);

title('\textit{C*}', 'Interpreter', 'latex','FontSize', 14, 'FontWeight', 'bold');
ylabel('\textit{C*}', 'Interpreter', 'latex','FontSize', 12);
grid on;
box on;
ylim([min(C_values)-2, max(C_values)+2]); 
yticks(round(min(C_values)-2):5: round(max(C_values)+2));% 调整Y轴范围
exportgraphics(gcf, fullfile(output_folder, 'C_values.jpg'), 'Resolution', 300);

% 3. 绘制h的柱状图
figure('Name', 'h Values', 'Position', [100, 300, 1000, 600]);
bar(h_values, 'FaceColor', [0.3, 0.7, 0.3]);  % 绿色
set(gca, 'XTick', 1:length(labels), 'XTickLabel', labels, ...
    'XTickLabelRotation', 45, 'FontSize', 10);
title('\textit{h}', 'Interpreter', 'latex','FontSize', 14, 'FontWeight', 'bold');
ylabel('\textit{h}', 'Interpreter', 'latex','FontSize', 12);
grid on;
box on;
ylim([min(h_values)-2, max(h_values)+2]);  
yticks(round(min(h_values)-2):5: round(max(h_values)+2));% 调整Y轴范围
exportgraphics(gcf, fullfile(output_folder, 'h_values.jpg'), 'Resolution', 300);

% 提示信息
disp('柱状图已生成并保存到以下文件夹:');
disp(fullfile(pwd, output_folder));
concatenate_images3(output_folder,1)
