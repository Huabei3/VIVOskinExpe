close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量

load("fitRes\fitRes_level_m.mat");
[n_para,~]=size(par_all);

%%
%L-C
L=[10;20;30;40;50;60;70;80];
figure(1);
for i_para=1:n_para
    C_all=sqrt(par_all(:,4).^2+par_all(:,5).^2);
    scatter(C_all(i_para),L(i_para), 40, 'filled'); 
    text( C_all(i_para)+10, L(i_para),strcat('{\it L*=}',num2str(i_para),'0'), ...
            'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', ...
            'FontSize',5);
    hold on;
end


%拟合直线
    xdata = C_all(:);
    ydata = L;

    f = @(a,xdata)(a(1).*xdata+a(2));

    rmax = 0;

    for t = 1:500
        a0 = [rand,rand];
        options = optimset('MaxFunEvals',200000);
        a = lsqcurvefit(f,a0,xdata,ydata,[-inf,-inf],[inf,inf],options);
        y = a(1).*xdata+a(2);

        r = corr(y,ydata);
        if r >= rmax
            rmax = r;
            afinal = a;
        end
    end
    r_LC=rmax;
    a_LC = afinal;
%%
%45°
axis equal;
x = 0:0.1:30;
y= x;
text( 30,30,'45°', ...
            'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'FontSize', 5);
plot(x,y);
%画拟合直线
x = 0:0.1:30;
y= a_LC(1)*x+a_LC(2);
% text( 30,55,[strcat('{\itL*}=',num2str(a(1)),'×{\itC*}')], ...
%             'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'FontSize', 10);
% text( 30,50,[strcat(num2str(a(2)))], ...
%             'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'FontSize', 10);
plot(x,y);

%设置坐标
ax = gca; ax.XLim = [0 30];
ay = gca; ay.YLim = [0 90];

%%
%----------Jack-LC---------
data_Jack=[62.59, 17.66, 17.86;
    59.19, 14.59, 17.83;
    48.26, 14.53, 15.57;
    37.86, 14.21, 13.51;
    30.68, 13.23, 12.30;
    20.49, 11.48, 9.45];

contrast=[62.2, 18.9, 20.4;%PMCC
    62.66, 18.31, 19.12;%Cherry
    60.5, 20.7, 24.4];%Zeng
contrast_labCh=[contrast,sqrt(contrast(:,2).^2+contrast(:,3).^2),...
    atan2d(contrast(:,3),contrast(:,2))];

L=data_Jack(:,1);
C=sqrt(data_Jack(:,2).^2+data_Jack(:,3).^2);
figure(1);
for i_para=1:size(data_Jack,1)
    hold on;
    scatter(C(i_para),L(i_para), 40, '+','LineWidth', 1); 
    plot(contrast_labCh(1,4),contrast_labCh(1,1), ...
    's', 'MarkerFaceColor', 'm', 'MarkerSize', 5);
    plot(contrast_labCh(2,4),contrast_labCh(2,1), ...
    'p', 'MarkerFaceColor', 'g', 'MarkerSize', 5);
    plot(contrast_labCh(3,4),contrast_labCh(3,1), ...
    'p', 'MarkerFaceColor', 'b', 'MarkerSize', 5);
    text( C(i_para)+10, L(i_para),strcat('{\it L*=}',num2str(data_Jack(i_para,1))), ...
            'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', ...
            'FontSize', 5);
    
end


%拟合直线
    xdata = C(:);
    ydata = L;
    
    f = @(a,xdata)(a(1).*xdata+a(2));
   
    rmax = 0;

    for t = 1:500
        a0 = [rand,rand];
        options = optimset('MaxFunEvals',200000);
        a = lsqcurvefit(f,a0,xdata,ydata,[-inf,-inf],[inf,inf],options);
        y = a(1).*xdata+a(2);
   
        r = corr(y,ydata);
        if r >= rmax
            rmax = r;
            afinal = a;
        end
    end
    r_LC_Jack=rmax;
    a_LC_Jack = afinal;

%45°
axis equal;

%画拟合直线
x = 0:0.1:30;
y= a_LC_Jack(1)*x+a_LC_Jack(2);

plot(x,y,'LineStyle','-');

%-------------

xlabel('C_{ab}*','FontAngle','italic');
ylabel('L*','FontAngle', 'italic');
title('L*-C_{ab}*','FontAngle', 'italic');
saveas(1,['ellip_pic\linear\m\L_C.jpg']);


%%
%a-b
figure(3);
for i_para=1:n_para
    C_all=sqrt(par_all(:,4).^2+par_all(:,5).^2);
%     if i_para==5||i_para==7
%         continue
%     end
    scatter(par_all(i_para,4),par_all(i_para,5), 40, 'filled'); 
    text( par_all(i_para,4)+4,par_all(i_para,5),strcat('{\itL*}=',num2str(i_para),'0'), ...
            'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'FontSize', 10);
    hold on;
end
%%
%拟合直线
    xdata = par_all(:,4);
    ydata = par_all(:,5);

    f = @(a,xdata)(a.*xdata);

    rmax = 0;

    for t = 1:500
        a0 = rand;
        options = optimset('MaxFunEvals',200000);
        a = lsqcurvefit(f,a0,xdata,ydata,-inf,inf,options);
        y = a.*xdata;

        r = corr(y,ydata);
        if r >= rmax
            rmax = r;
            afinal = a;
        end
    end
    r_ab=rmax;
    a_ab = afinal;
%%
x = 0:0.1:20;
y= a_ab*x;
% text( 15,12,strcat('{\ita*}=',num2str(a),'×{\itb*}'), ...
%             'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'FontSize', 10);
plot(x,y);

x = 0:0.1:20;
y= x;
text( 15,15,'45°', ...
            'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'FontSize', 10);
plot(x,y);

axis equal;
ax = gca; ax.XLim = [0 20];
ay = gca; ay.YLim = [0 20];
xlabel('{\ita*}');
ylabel('{\itb*}');
title('{\ita*-b*}');
saveas(3,['ellip_pic\linear\m\a_b.jpg']);


%%
%C-LnL
L=[10;20;30;40;50;60;70;80];
LnL=log(L);
figure(4);
for i_para=1:n_para
    C_all=sqrt(par_all(:,4).^2+par_all(:,5).^2);
    scatter(LnL(i_para),C_all(i_para), 40, 'filled'); 
    text( LnL(i_para)+4,C_all(i_para), strcat('{\it L*=}',num2str(i_para),'0'), ...
            'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', ...
            'FontSize', 10);
    hold on;
end


%拟合直线
    xdata = LnL(:);
    ydata = C_all(:);
    
    f = @(a,xdata)(a(1).*xdata+a(2));
   
    rmax = 0;

    for t = 1:500
        a0 = [rand,rand];
        options = optimset('MaxFunEvals',200000);
        a = lsqcurvefit(f,a0,xdata,ydata,[-inf,-inf],[inf,inf],options);
        y = a(1).*xdata+a(2);
   
        r = corr(y,ydata);
        if r >= rmax
            rmax = r;
            afinal = a;
        end
    end
    r_CLnL=rmax;
    a_CLnL = afinal;


axis equal;

%画拟合直线
x = 0:0.1:30;
y= a_CLnL(1)*x+a_CLnL(2);

plot(x,y);

%设置坐标
ax = gca; ax.XLim = [0 max(LnL)+5];
ay = gca; ay.YLim = [0 max(C_all)+5];
xlabel('LnL*','FontAngle', 'italic');
ylabel('C_{ab}*','FontAngle','italic');

title('C_{ab}*-LnL*','FontAngle', 'italic');
saveas(4,'ellip_pic\linear\m\C-LnL.jpg');