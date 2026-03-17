% 原始数据
function plot_3D(data)
% 提取数据列
    y = data(:,2);  % 第二列作为自变量y
    z = data(:,3);  % 第三列作为自变量z
    x = data(:,1);  % 第一列作为因变量x
    
    % 创建插值网格
    [Y,Z] = meshgrid(linspace(min(y), max(y), 100), linspace(min(z), max(z), 100));
    
    % 使用griddata函数进行插值
    X = griddata(y, z, x, Y, Z, 'cubic');
    
    % 创建3D图形
    figure('Position', [100, 100, 800, 600]);
    
    % 绘制3D散点图
    scatter3(y, z, x, 50, x, 'filled', 'MarkerEdgeColor', 'k', 'MarkerFaceAlpha', 0.7);
    hold on;
    
    % 绘制插值曲面
    surf(Y, Z, X, 'FaceAlpha', 0.8, 'EdgeAlpha', 0.3);
    
    % 设置图形属性
    grid on;
    xlabel('Y 变量');
    ylabel('Z 变量');
    zlabel('X 变量');
    title('3D散点图与插值曲面');
    colorbar;
    
    % 设置视角
    view(30, 20);
    
    % 调整光照效果
    lighting gouraud;
    material shiny;
end