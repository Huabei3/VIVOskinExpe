% Data from the table
CCT = [6401, 7099, 7295, 7957, 9671];
L = [59.22, 61.78, 65.19, 57.49, 62.87];
C = [26.81, 25.84, 29.89, 23.66, 22.02];
h = [46.85, 49.74, 50.32, 46.81, 42.75];

L_ori = [52.97, 55.01, 58.86, 51.74, 58.19];
C_ori = [30.62, 25.37, 34.53, 23.52, 20.82];
h_ori = [51.79, 52.00, 54.09, 50.24, 43.89];

% Scene names
sceneNames = {'Indoor', 'Night', 'In-lab', 'Outdoor', 'Sunset'};
save_folder = "ellip_pic";
if ~exist(save_folder, "dir")
    mkdir(save_folder)
end
%% X positions (use CCT as true x, but relabel ticks)
x = CCT;

%% --- Plot 1: L vs. L_ori ---
figure;
bar(x, [L; L_ori]', 'BarWidth', 0.8);
title('\textit{L*}', 'Interpreter', 'latex', 'FontSize', 14, 'FontWeight', 'bold');
ylabel('\textit{L*}', 'Interpreter', 'latex', 'FontSize', 12);
xticks(x);                     % tick at CCT positions
xticklabels(sceneNames);       % show scene names
xtickangle(45);
% 调整L*图的y轴范围
ylim([50, 70]);
yticks(50:5:70);
exportgraphics(gcf, fullfile(save_folder, 'L_vs_Lori.jpg'), 'Resolution', 300);

%% --- Plot 2: C vs. C_ori ---
figure;
bar(x, [C; C_ori]', 'BarWidth', 0.8);

title('\textit{C*}', 'Interpreter', 'latex', 'FontSize', 14, 'FontWeight', 'bold');
ylabel('\textit{C*}', 'Interpreter', 'latex', 'FontSize', 12);
xticks(x);
xticklabels(sceneNames);
xtickangle(45);
% 调整C*图的y轴范围
ylim([20, 35]);
yticks(20:5:35);
exportgraphics(gcf, fullfile(save_folder, 'C_vs_Cori.jpg'), 'Resolution', 300);

%% --- Plot 3: h vs. h_ori ---
figure;
b=bar(x, [h; h_ori]', 'BarWidth', 0.8);
title('\textit{h}', 'Interpreter', 'latex', 'FontSize', 14, 'FontWeight', 'bold');
ylabel('\textit{h}', 'Interpreter', 'latex', 'FontSize', 12);
xticks(x);
xticklabels(sceneNames);
xtickangle(45);
% 调整h图的y轴范围
ylim([40, 60]);
yticks(40:5:60);
exportgraphics(gcf, fullfile(save_folder, 'h_vs_hori.jpg'), 'Resolution', 300);
% 假设 concatenate_images3 函数用于拼接图像，若没有此函数可根据需求补充或忽略
concatenate_images3(save_folder, 1)

% 获取默认颜色
defaultColors = get(b, {'FaceColor'});
fprintf('L*图默认颜色:\n');
for i = 1:length(defaultColors)
    fprintf('  数据集%d: RGB = [%.3f, %.3f, %.3f]\n', i, defaultColors{i}(1), defaultColors{i}(2), defaultColors{i}(3));
end