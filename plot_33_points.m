% 读取Excel文件中的数据
% 假设Excel文件名为 'data.xlsx'，数据在Sheet1�?
filename = 'documents\points_added_33.xlsx';  % 修改为您的文件名
sheet = 1;  % 或��使用工作表名称，如 'Sheet1'

% 读取Excel文件中的两列数据
% 这里假设读取A列和B列，您可以根据实际情况调整列范围
data = xlsread(filename, sheet, 'A:B');

% 提取两列数据
x_data = data(:, 1);  % 第一列作为x数据
y_data = data(:, 2);  % 第二列作为y数据

% 创建图形窗口
figure('Position', [100, 100, 800, 600]);  % 设置图形窗口大小

% 绘制散点�?
scatter(x_data, y_data, 'filled', 'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'k', 'SizeData', 50);

% 设置坐标轴标签和标题


% 设置坐标轴范�?
lim_max = 25;
lim_min = -25;

% 添加 x=0 �?y=0 的轴
hold on;
line([0, 0], [lim_min, lim_max], 'Color', 'k', 'LineStyle', '--', 'LineWidth', 1.5); % x=0
line([lim_min, lim_max], [0, 0], 'Color', 'k', 'LineStyle', '--', 'LineWidth', 1.5); % y=0

% 添加 45 度线
href = refline(1, 0);  % 创建参��线对象
set(href, 'Color', 'k', 'LineStyle', '--', 'LineWidth', 1.5);  % 设置属��?

% 设置图形属��?
% grid on;
% grid minor;
box on;
axis equal;
xlim([lim_min, lim_max]);
ylim([lim_min, lim_max]);
% set(gca, 'FontSize', 12, 'FontWeight', 'bold');
% legend('数据�?, 'Location', 'best');
ax = gca;
targetFontSize=12;
set(ax, 'FontSize', targetFontSize);

set(findobj(gcf, 'Type', 'Text'), 'FontSize', targetFontSize); % 针对 LaTeX 标签
xlabel('\Delta a^{*}','Interpreter','tex','FontName','Arial','FontAngle','italic','FontSize',1.5*targetFontSize);
ylabel('\Delta b^{*}','Interpreter','tex','FontName','Arial','FontAngle','italic','FontSize',1.5*targetFontSize);
% title('散点�?, 'FontSize', 14*2, 'FontWeight', 'bold');

%%


outputFolder="documents";
img_name=fullfile(outputFolder,"points_added_33.jpg");    
savefig(gcf, strrep(img_name,'jpg','fig'));
exportgraphics(gcf,img_name,"Resolution",600);
fullfile(pwd,outputFolder)
