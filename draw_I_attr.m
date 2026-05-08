close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量
addpath("utils\")
%%
fitRes_folder="fitRes/sUCS";
load(fullfile(fitRes_folder,"fitRes_level_p.mat"));
[n_para,~]=size(par_all);

wd65_64=[94.811 100.00 107.304];
XYZw_pre=[33.521517698541395,34.853121228819360,29.380539268455140];
% XYZw_pre=[82.899171244283790,86.782992208213000,75.037090964697270];
XYZw_pre=XYZw_pre./XYZw_pre(2).*wd65_64(2);
XYZ_96white=[124.035328150026	128.030968697676	143.941971778570];
load("documents\Y_mean.mat");

output_folder="fitRes\sUCS\I_attr";
if ~exist(output_folder,"dir")
    mkdir(output_folder);
end

%%
%L-C
attributes=["J", "Q", "C", "M", "h", "H"];
I=I_mean_all;
Iab_all=[I_mean_all,par_all(:,4:5)];
XYZ_all=lab2xyz2(Iab_all,"d65_31");
La=xyz_mean(:,2).*XYZ_96white(2);
for i_para=1:n_para
    [JQCMhH(i_para,1), JQCMhH(i_para,2), JQCMhH(i_para,3), ...
        JQCMhH(i_para,4), JQCMhH(i_para,5), JQCMhH(i_para,6)] = ...
    XYZ2sCAM(XYZ_all(i_para,:), XYZw_pre, xyz_mean(i_para,2), La(i_para,:), 'dark');
end
figure(1);
% for i_attr=1:n_para
%     [J, Q, C_1, M, h, H] = XYZ2sCAM(XYZ_all, XYZw_pre, Yb, La, 'dark');
% 
%     scatter(J(i_para),I(i_para), 40, 'filled'); 
%     text( J(i_para)+10, I(i_para),strcat('{\it L*=}',num2str(i_para),'0'), ...
%             'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', ...
%             'FontSize',5);
%     hold on;
% end
pic_folder="ellip_pic\sUCS";
if ~exist(pic_folder,"dir")
    mkdir(pic_folder);
end
for i_attr=1:size(JQCMhH,2)

%拟合直线
    xdata = I;
    ydata = JQCMhH(:,i_attr);

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
    r_linear(i_attr,:)=rmax;
    a_linear(i_attr,:) = afinal;
end
save(fullfile(output_folder,"I_attr_linear.mat"),"a_linear","r_linear");

%%
for i_attr=1:size(JQCMhH,2)
    %45°
    figure(i_attr);hold on;
    
    max_ver=max(I)+5;    
    min_ver=min(I)-5;

    max_hor=max(JQCMhH(:,i_attr))+5;
    min_hor=min(JQCMhH(:,i_attr))-5;
    if i_attr>=5
        max_hor=max(JQCMhH(:,i_attr))+50;
        min_hor=min(JQCMhH(:,i_attr))-50;
    end
    axis equal;
    afinal=a_linear(i_attr,:);

    %画拟合直线
    x = 0:0.1:90;
    y= afinal(1)*x+afinal(2);

    plot(y,x);

    scatter(JQCMhH(:,i_attr),I, 40, 'filled'); 
    
    %设置坐标
    span_hor=max_hor-(min_hor);
    span_ver=max_ver-(min_ver);
    
    % 生成整数刻度值
    xtick_values = round(linspace(min_hor, max_hor, 11));
    ytick_values = round(linspace(min_ver, max_ver, 11));
    
    % 设置刻度位置和标签
    xticks(xtick_values);
    yticks(ytick_values);
    xticklabels(arrayfun(@num2str, xtick_values, 'UniformOutput', false));
    yticklabels(arrayfun(@num2str, ytick_values, 'UniformOutput', false));
    
    title(attributes(i_attr));
    axis equal;
    ax = gca; ax.XLim = [min_hor-5 max_hor+5];
    ay = gca; ay.YLim = [min_ver-5 max_ver+5];

    
    exportgraphics(gcf,fullfile(pic_folder,strcat(attributes(i_attr),".jpg")), ...
        "resolution",150);
    close(gcf)
end






%%
% 续写：plot against Iab_all(:,2)与Iab_all(:,3)
figure(size(JQCMhH,2)+1);
scatter(Iab_all(:,2), Iab_all(:,3), 40, 'filled');
xlabel('a*');
ylabel('b*');
title('a* vs b*');
grid on;
axis equal;

% 设置坐标轴刻度以10为间隔
max_a = max(Iab_all(:,2));
max_b = max(Iab_all(:,3));
min_a = min(Iab_all(:,2));
min_b = min(Iab_all(:,3));
xlim([min_a-5, max_a+5]);
ylim([min_b-5, max_b+5]);
xticks(floor(min_a/10)*10:10:ceil(max_a/10)*10);
yticks(floor(min_b/10)*10:10:ceil(max_b/10)*10);

exportgraphics(gcf,fullfile(pic_folder,"a_vs_b.jpg"), "resolution",150);
close(gcf)
