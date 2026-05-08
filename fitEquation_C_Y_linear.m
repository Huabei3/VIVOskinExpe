close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量
load("E:\documents\MATLAB\SkinColorPreferenceScale\level_data\fitRes_level.mat");
[n_level,~]=size(par_all);
C=sqrt(par_all(:,4).^2+par_all(:,5).^2);
%%
xdata = [10,20,30,40,50,60,70,80];
xdata=xdata';
xdata=100*((xdata+16)/116).^3;
ydata = C;
xdata_re=flip(-xdata);
ydata_re=flip(-ydata);
xdata=[xdata_re;xdata];
ydata=[ydata_re;ydata];

f = @(a,xdata)(a(1)*xdata+a(2)*xdata.^3+a(3));

rmax = 0;

for t = 1:500
    a0 = [rand,rand,rand];
    options = optimset('MaxFunEvals',200000);
    a = lsqcurvefit(f,a0,xdata,ydata,[-inf,-inf,-inf],[inf,inf,inf],options);
    y = a(1)*xdata+a(2)*xdata.^3+a(3);

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

scatter(xdata,ydata, 40, 'filled'); 
hold on;
x = -80:0.1:80;
y= (a(1)*x+a(2)*x.^3+a(3));
% text(70, 5, sprintf('C=%s*Y+%s*Y^2\n+%s*Y^3+%s*Y^4+%s', ...
%     num2str(a(1)), num2str(a(2)), num2str(a(3)), num2str(a(4)), num2str(a(5))), ...
%     'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'FontSize', 10);
text( 70,10,strcat('r=',num2str(r3)), 'VerticalAlignment', ...
    'bottom', 'HorizontalAlignment', 'right', 'FontSize', 10);
plot(x,y);
ax = gca; ax.XLim = [0 80];
ay = gca; ay.YLim = [0 20];
xlabel('Y');
ylabel('C');
title('C-Y');
saveas(3,['E:\documents\MATLAB\SkinColorPreferenceScale\ellip_pic' ...
    '\C_Y_linear.jpg']);