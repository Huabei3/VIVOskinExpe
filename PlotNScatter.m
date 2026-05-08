close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量

load("E:\documents\MATLAB\SkinColorPreferenceScale\level_data\fitRes_level.mat");
[n_para,~]=size(par_all);
aabbh=[];

% colors=["#0072BD","#D95319","#EDB120","#7E2F8E",...
%     '#191970','#000080','#6495ED',...
% '#483D8B','#6A5ACD','#7B68EE',...
% 'cyan','red','green','blue'];

% figure(1);
for i_para=1:n_para
    figure(i_para);
    par=par_all(i_para,:);

    syms y
    syms z

    s =par(2)*(y-par(6)).^2+par(3)*(z-par(7)).^2+par(4)*(y-par(6)).*(z-par(7)); 
    Ex=expand(s);
    N = coeffs(expand(s));
    % 画一般椭圆：ax*x+bx*y+c*y*y+d*x+e*y = f
    f=par(8)^2-double(N(1));
    d=double(N(4));
    c=double(N(3));
    e=double(N(2));
    b=double(N(5));
    a=double(N(6));


    check_data2=par(6)+(-30:0.2:30);
    check_data3=par(7)+(-30:0.2:30);
    [data2,data3]=meshgrid(check_data2,check_data3);
%     [row,col]=size(data2);
    y=a*data2.^2+b*data3.^2+c*data2.*data3+d*data2+e*data3-f;
    % 画一般椭圆：ax*x+bx*y+c*y*y+d*x+e*y = f

    
    s0=contour(data2,data3,y,[0,1],'Linewidth',2);
    hold on;
    title('BK');
    scatter(x0,y0, 40, score_level, 'filled'); 


    
    %%
    % scatter
    load(strcat("E:\documents\MATLAB\SkinColorPreferenceScale\level_data" + ...
    "\labNscore_level",num2str(i_para),"0.mat"));
    score_level=(score_level-(-3))./6;
    score_level=mean(score_level,2);
    scatter(lab_level(:,2),lab_level(:,3), 40, score_level, 'filled'); 
    colorbar; % 显示颜色条
    hold on;
%     for i_point = 1:length(lab_level(:,2))
%         if i_para==1||i_para==2
%            text(lab_level(i_point,2), lab_level(i_point,3), sprintf('%.2f', score_level(i_point)), ...
%             'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'FontSize', 4); 
%         else
%            text(lab_level(i_point,2), lab_level(i_point,3), sprintf('%.2f', score_level(i_point)), ...
%             'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'FontSize', 8); 
%         end
%     end
    scatter(par(6),par(7), 40, 'filled');
   text(10, -10,strcat('center:(',num2str(par(6)),',',num2str(par(7)),')'), ...
    'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'FontSize', 10); 
    xlabel('a');
    ylabel('b');
    title(strcat('L=',num2str(i_para)));
    saveas(i_para,strcat(['E:\documents\MATLAB\SkinColorPreferenceScale\ellip_pic' ...
        '\ellipContourNscatter'],num2str(i_para),'.jpg'));


end
% saveas(1,['E:\documents\MATLAB\SkinColorPreferenceScale\ellip_pic\' ...
%     'ellipContour.jpg']);
