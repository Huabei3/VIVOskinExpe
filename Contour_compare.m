close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量

load("E:\documents\MATLAB\SkinColorPreferenceScale\level_data\fitRes_level_deleted.mat");
[n_para,~]=size(par_all);
aabbh=[];
ori=load("E:\documents\MATLAB\SkinColorPreferenceScale\level_data\fitRes_level.mat");

for i_para=1:n_para
    figure(i_para);
    par=par_all(i_para,:);

    check_data2=par(4)+(-30:0.2:30);
    check_data3=par(5)+(-30:0.2:30);
    [data2,data3]=meshgrid(check_data2,check_data3);
    [row,col]=size(data2);

    a=par;
    y = (1./(1+a(6)*exp(sqrt(a(1)*(data2-a(4)).^2+a(2)*(data3-a(5)).^2+ ...
        a(3)*(data2-a(4)).*(data3-a(5)))))).*((a(1)*(data2-a(4)).^2+ ...
        a(2)*(data3-a(5)).^2+a(3)*(data2-a(4)).*(data3-a(5)))>=0);
    % mesh(data2,data3,y)
    % figure
    
    s0=contour(data2,data3,y,[0.5,1],'Linewidth',2,'LineColor', 'r');
    hold on;
    
    %原来的
    a=ori.par_all(i_para,:);
    ori_y = (1./(1+a(6)*exp(sqrt(a(1)*(data2-a(4)).^2+a(2)*(data3-a(5)).^2+ ...
        a(3)*(data2-a(4)).*(data3-a(5)))))).*((a(1)*(data2-a(4)).^2+ ...
        a(2)*(data3-a(5)).^2+a(3)*(data2-a(4)).*(data3-a(5)))>=0);
    % mesh(data2,data3,y)
    % figure
    
    s1=contour(data2,data3,ori_y,[0.5,1],'Linewidth',2,'LineColor', 'b');
    hold on;
    

    
    %%
    % scatter
    load(strcat("E:\documents\MATLAB\SkinColorPreferenceScale\level_data" + ...
    "\labNscore_level_deleted",num2str(i_para),"0.mat"));
    score_level=(score_level-(-3))./6;
    score_level=mean(score_level,2);
    scatter(lab_level(:,2),lab_level(:,3), 40, score_level, 'filled'); 
    colorbar; % 显示颜色条
    hold on;

    scatter(par(4),par(5), 40, 'filled','MarkerFaceColor', 'r');
    text(10, -10,strcat('center:(',num2str(par(4)),',',num2str(par(5)),')' ), ...
    'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'FontSize', 10,'Color', 'red'); 
    text(10, -14,strcat('perceptibility：',num2str(max(max(y)))), ...
    'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'FontSize', 10,'Color', 'red'); 
    %原来的
    scatter(ori.par_all(i_para,4),ori.par_all(i_para,5), 40, 'filled','MarkerFaceColor', 'b');
    text(34, 29,strcat('center_{ori}:(',num2str(ori.par_all(i_para,4)),',',num2str(ori.par_all(i_para,5)),')' ), ...
    'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'FontSize', 10,'Color', 'blue'); 
    text(34, 25,strcat('perceptibility_{ori}：',num2str(max(max(ori_y)))), ...
    'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'FontSize', 10,'Color', 'blue');

    xlabel('a');
    ylabel('b');
    title(strcat('L=',num2str(i_para),'0'));
        %%
 
    saveas(i_para,strcat(['E:\documents\MATLAB\SkinColorPreferenceScale\ellip_pic' ...
        '\ellipContourNscatter_compare'],num2str(i_para),'.jpg'));


end

