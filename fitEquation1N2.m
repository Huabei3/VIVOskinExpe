close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量
load("E:\documents\MATLAB\SkinColorPreferenceScale\level_data\fitRes_level.mat");
[n_level,~]=size(par_all);
C=sqrt(par_all(:,4).^2+par_all(:,5).^2);

xdata = [10,20,30,40,50,60,70,80];
xdata=xdata';
ydata = C;

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
x = 0:0.1:80;
y= a(1)*log10((x+3.85))+a(2);
text( 70,5,strcat('C=',num2str(a(1)),'*log10(L)+',num2str(a(2))), ...
            'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'FontSize', 10);
text( 70,10,strcat('r=',num2str(r1)), 'VerticalAlignment', ...
    'bottom', 'HorizontalAlignment', 'right', 'FontSize', 10);
plot(x,y);
ax = gca; ax.XLim = [0 80];
ay = gca; ay.YLim = [0 20];
xlabel('L');
ylabel('C');
title('C-L');
saveas(1,['E:\documents\MATLAB\SkinColorPreferenceScale\ellip_pic' ...
    '\equation1.jpg']);
%%
%equation2
xdata = [10,20,30,40,50,60,70,80];
xdata=xdata';
ydata = C;
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
x = 0:0.1:80;
y= a(1)*log10((x+2.79))+a(2)*log10((x+2.79)).^2+a(3);
text( 70,5,strcat('C=',num2str(a(1)),'*log10(L)+',num2str(a(2)),'*log10(L)^2+', ...
    num2str(a(3))), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', ...
    'right', 'FontSize', 10);
text( 70,10,strcat('r=',num2str(r2)), 'VerticalAlignment', ...
    'bottom', 'HorizontalAlignment', 'right', 'FontSize', 10);
plot(x,y);
ax = gca; ax.XLim = [0 80];
ay = gca; ay.YLim = [0 20];
xlabel('L');
ylabel('C');
title('C-L');
saveas(2,['E:\documents\MATLAB\SkinColorPreferenceScale\ellip_pic' ...
    '\equation2.jpg']);

% figure(3);
% x1data=log10(xdata);
% y1data=ydata
% scatter(x1data,y1data, 40, 'filled'); 
% hold on;
% x = 0:0.1:80;
% x1=log10(x);
% y1= a(1)*x1+a(2)*x1.^2+a(3);
% plot(x1,y1);
% xlabel('log10(L)');
% ylabel('C');
% title('C-log10(L)');
% saveas(3,['E:\documents\MATLAB\SkinColorPreferenceScale\ellip_pic' ...
%     '\equation2_1.jpg']);

