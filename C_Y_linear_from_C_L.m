close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量
load("E:\documents\MATLAB\SkinColorPreferenceScale\level_data\fitRes_level.mat");
[n_level,~]=size(par_all);
C=sqrt(par_all(:,4).^2+par_all(:,5).^2);
% 
% xdata = [10,20,30,40,50,60,70,80];
% xdata=xdata';
% ydata = C;
% 
% f = @(a,xdata)(a(1)*xdata+a(2));
% 
% rmax = 0;
% 
% for t = 1:500
%     a0 = [rand,rand];
%     options = optimset('MaxFunEvals',200000);
%     a = lsqcurvefit(f,a0,xdata,ydata,[-inf,-inf],[inf,inf],options);
%     y = a(1)*xdata+a(2);
% 
%     r = corr(y,ydata);
%     if r >= rmax
%         rmax = r;
%         afinal = a;
%     end
% end
% 
% a = afinal;
% r1=rmax;
% %画图
% figure(1);
% scatter(xdata,ydata, 40, 'filled'); 
% hold on;
% x = 0:0.1:80;
% y= a(1)*x+a(2);
% text( 70,5,strcat('C=',num2str(a(1)),'*L+',num2str(a(2))), ...
%             'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'FontSize', 10);
% text( 70,10,strcat('r=',num2str(r1)), 'VerticalAlignment', ...
%     'bottom', 'HorizontalAlignment', 'right', 'FontSize', 10);
% plot(x,y);
% ax = gca; ax.XLim = [0 80];
% ay = gca; ay.YLim = [0 20];
% xlabel('L');
% ylabel('C');
% title('C-L');
% saveas(1,['E:\documents\MATLAB\SkinColorPreferenceScale\ellip_pic' ...
%     '\equation1.jpg']);
% %%
% %equation2
% xdata = [10,20,30,40,50,60,70,80];
% xdata=xdata';
% ydata = C;
% % xdata=[xdata;0.0001];
% % ydata=[ydata;0.0001];
% f = @(a,xdata)(a(1)*xdata+a(2)*xdata.^2+a(3));
% 
% rmax = 0;
% 
% for t = 1:500
%     a0 = [rand,rand,rand];
%     options = optimset('MaxFunEvals',200000);
%     a = lsqcurvefit(f,a0,xdata,ydata,[-inf,-inf,-inf],[inf,inf,inf],options);
%     y = a(1)*xdata+a(2)*xdata.^2+a(3);
% 
%     r = corr(y,ydata);
%     if r >= rmax
%         rmax = r;
%         afinal = a;
%     end
% end
% 
% a = afinal;
% r2=rmax;
% 
% %画图
% figure(2);
% % xdata(end)=[];
% % ydata(end)=[];
% scatter(xdata,ydata, 40, 'filled'); 
% hold on;
% x = 0:0.1:80;
% y= a(1)*x+a(2)*x.^2+a(3);
% text( 70,5,strcat('C=',num2str(a(1)),'*L+',num2str(a(2)),'*L^2+', ...
%     num2str(a(3))), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', ...
%     'right', 'FontSize', 10);
% text( 70,10,strcat('r=',num2str(r2)), 'VerticalAlignment', ...
%     'bottom', 'HorizontalAlignment', 'right', 'FontSize', 10);
% plot(x,y);
% ax = gca; ax.XLim = [0 80];
% ay = gca; ay.YLim = [0 20];
% xlabel('L');
% ylabel('C');
% title('C-L');
% saveas(2,['E:\documents\MATLAB\SkinColorPreferenceScale\ellip_pic' ...
%     '\equation2.jpg']);


%%
%equation3
xdata = [10,20,30,40,50,60,70,80];
xdata=xdata';
ydata = C;
xdata_re=flip(-xdata);
ydata_re=flip(-ydata);
xdata=[xdata_re;xdata];
ydata=[ydata_re;ydata];

f = @(a,xdata)(a(1)*xdata+a(2)*xdata.^2+a(3)*xdata.^3+a(4)*xdata.^4+a(5));

rmax = 0;

for t = 1:500
    a0 = [rand,rand,rand,rand,rand,rand];
    options = optimset('MaxFunEvals',200000);
    a = lsqcurvefit(f,a0,xdata,ydata,[-inf,-inf,-inf,-inf,-inf],[inf,inf,inf ...
        ,inf,inf],options);
    y = a(1)*xdata+a(2)*xdata.^2+a(3)*xdata.^3+a(4)*xdata.^4+a(5);

    r = corr(y,ydata);
    if r >= rmax
        rmax = r;
        afinal = a;
    end
end

a = afinal;
r3=rmax;

%画图
figure(3);
xdata=100*((xdata+16)/116).^3;
scatter(xdata,ydata, 40, 'filled'); 
hold on;

x = -80:0.1:80;

y= a(1)*x+a(2)*x.^2+a(3)*x.^3+a(4)*x.^4+a(5);
x=100*((x+16)/116).^3;
% text(70, 5, sprintf('C=%s*L+%s*L^2\n+%s*L^3+%s*L^4+%s', ...
%     num2str(a(1)), num2str(a(2)), num2str(a(3)), num2str(a(4)), num2str(a(5))), ...
%     'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'FontSize', 10);
%%
% 引入 Symbolic Math Toolbox 功能
syms a1 a2 a3 a4 a5 Y x
% 定义 x 关于 Y 的关系
x = 116*(Y/100)^(1/3) - 16;
% 定义 C 关于 x 的表达式
C = a1*x + a2*x^2 + a3*x^3 + a4*x^4 + a5;
% 用 Y 的表达式代替 x
C_Y = subs(C, x, 116*(Y/100)^(1/3) - 16);
% 简化表达式
simplified_C_Y = simplify(C_Y);
% 显示简化后的表达式
disp(simplified_C_Y);
%%
text( 70,10,strcat('r=',num2str(r3)), 'VerticalAlignment', ...
    'bottom', 'HorizontalAlignment', 'right', 'FontSize', 10);
plot(x,y);
ax = gca; ax.XLim = [0 60];
ay = gca; ay.YLim = [0 20];
xlabel('Y');
ylabel('C');
title('C-Y');
saveas(3,['E:\documents\MATLAB\SkinColorPreferenceScale\ellip_pic' ...
    '\C_Y_linear_from_C_L.jpg']);
save