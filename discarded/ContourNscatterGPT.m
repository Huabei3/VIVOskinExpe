
close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量
load("E:\documents\MATLAB\SkinColorPreferenceScale\level_data\fitRes_level.mat");
[n_level,~]=size(par_all);
for i_level=1:n_level
    figure(i_level);
    a=par_all(i_level,:);
    % 定义data2和data3的范围，这里以a4和a5为中心创建一个网格
    data2Range = linspace(a(4)-30, a(4)+30, 1000);
    data3Range = linspace(a(5)-30, a(5)+30, 1000);
    
    [data2, data3] = meshgrid(data2Range, data3Range);
    
    % 计算y值
    y = (1./(1 + a(6)*exp(sqrt(a(1)*(data2-a(4)).^2 + a(2)*(data3-a(5)).^2 + ...
        a(3)*(data2-a(4)).*(data3-a(5)))))) .* ...
        ((a(1)*(data2-a(4)).^2 + a(2)*(data3-a(5)).^2 + a(3)*(data2-a(4)).*(data3-a(5))) >= 0);
    
    % 使用contour函数画出y=0.5的轮廓
    figure; % 创建一个新图形窗口
    axis equal;
    contour(data2, data3, y, [0.5 0.5], 'LineWidth', 2); % 画出y=0.5的轮廓线
    xlabel('data2');
    ylabel('data3');
    hold on;
    %%
    load(strcat("E:\documents\MATLAB\SkinColorPreferenceScale\level_data" + ...
    "\labNscore_level",num2str(i_level),"0.mat"));
    score_level=(score_level-(-3))./6;
    score_level=mean(score_level,2);
    scatter(lab_level(:,2),lab_level(:,3), 40, score_level, 'filled'); 
    colorbar; % 显示颜色条
    hold on;
    par=par_all(i_level,:);
    scatter(par(4),par(5), 40, 'filled');
   text(10, -10,strcat('center:(',num2str(par(4)),',',num2str(par(5)),')'), ...
    'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'FontSize', 10); 
    xlabel('a');
    ylabel('b');
    title(strcat('L=',num2str(i_level)));
    %%
    %30°
    axis equal;
    x = linspace(a(4)-15, a(4)+15, 1000);
    y= tand(30)*(x-a(4))+a(5);;
    text( 30,10,'30°', ...
                'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'FontSize', 10);
    plot(x,y);
    hold on;

    %45°
    axis equal;
    x = linspace(a(4)-15, a(4)+15, 1000);
    y= tand(45)*(x-a(4))+a(5);
    text( 30,20,'45°', ...
                'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'FontSize', 10);
    plot(x,y);
    hold on;
    %60°
    axis equal;
    x = linspace(a(4)-15, a(4)+15, 1000);
    y= tand(60)*(x-a(4))+a(5);
    text( 30,30,'60°', ...
                'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'FontSize', 10);
    plot(x,y);
    hold on;
%%
    saveas(i_level,strcat(['E:\documents\MATLAB\SkinColorPreferenceScale\ellip_pic' ...
        '\ellipContourNscatterGPT'],num2str(i_level),'.jpg'));
end