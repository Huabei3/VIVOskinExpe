close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量
load("E:\documents\MATLAB\SkinColorPreferenceScale\level_data\fitRes_level.mat");
[n_level,~]=size(par_all);
C=sqrt(par_all(:,4).^2+par_all(:,5).^2);

xdata = [10,20,30,40,50,60,70,80];
xdata=xdata';
ydata = C;
xdata=xdata/100;
ydata=ydata/100;
f = @(a,xdata)(a(1)*log10(xdata)+a(2));

rmax = 0;

for t = 1:500
    a0 = [rand,rand];
    options = optimset('MaxFunEvals',200000);
    a = lsqcurvefit(f,a0,xdata,ydata,[-inf,-inf],[inf,inf],options);
    y = a(1)*log10(xdata)+a(2);

    r = corr(y,ydata);
    if r >= rmax
        rmax = r;
        afinal = a;
    end
end

a = afinal;
r1=rmax;
%画图
figure(1);
scatter(xdata,ydata, 40, 'filled'); 
hold on;
x = 0:0.0001:1;
y= a(1)*log10(x+0.0385)+a(2);
text( 0.9,0.05,strcat('C*=',num2str(a(1)),'*log10(L*)+',num2str(a(2))), ...
            'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'FontSize', 10);
plot(x,y);
ax = gca; ax.XLim = [0 1];
ay = gca; ay.YLim = [0 0.18];
xlabel('L*');
ylabel('C*');
title('C*-L*');
saveas(1,['E:\documents\MATLAB\SkinColorPreferenceScale\ellip_pic' ...
    '\equation1_star.jpg']);
%%
%equation2
xdata=[xdata;0.0001];
ydata=[ydata;0.0001];
f = @(a,xdata)(a(1)*log10(xdata)+a(2)*log10(xdata).^2+a(3));

rmax = 0;

for t = 1:500
    a0 = [rand,rand,rand];
    options = optimset('MaxFunEvals',200000);
    a = lsqcurvefit(f,a0,xdata,ydata,[-inf,-inf,-inf],[inf,inf,inf],options);
    y = a(1)*log10(xdata)+a(2)*log10(xdata).^2+a(3);

    r = corr(y,ydata);
    if r >= rmax
        rmax = r;
        afinal = a;
    end
end

a = afinal;
r2=rmax;

%画图
figure(2);
xdata(end)=[];
ydata(end)=[];
scatter(xdata,ydata, 40, 'filled'); 
hold on;
x = 0:0.0001:1;
y= a(1)*log10(x+0.0215)+a(2)*log10(x+0.0215).^2+a(3);
text( 0.9,0.05,strcat('C*=',num2str(a(1)),'*log10(L*)+',num2str(a(2)),'*log10(L*)^2+', ...
    num2str(a(3))), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'FontSize', 10);
plot(x,y);
ax = gca; ax.XLim = [0 1];
ay = gca; ay.YLim = [0 0.2];
xlabel('L*');
ylabel('C*');
title('C*-L*');
saveas(2,['E:\documents\MATLAB\SkinColorPreferenceScale\ellip_pic' ...
    '\equation2_star.jpg']);

% figure(3);
% x1data=log10(xdata/100);
% y1data=ydata
% scatter(x1data,y1data, 40, 'filled'); 
% hold on;
% x = 0:0.1:80;
% x1=log10(x/100);
% y1= a(1)*x1+a(2)*x1.^2+a(3);
% plot(x1,y1);
% xlabel('log10(L/100)');
% ylabel('C');
% title('C-log10(L/100)');
% saveas(3,['E:\documents\MATLAB\SkinColorPreferenceScale\ellip_pic' ...
%     '\equation2_1.jpg']);

