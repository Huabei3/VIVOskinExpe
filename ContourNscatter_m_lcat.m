close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量

load("fitRes\fitRes_level_m.mat");
[n_para,~]=size(par_all);
aabbh=[];
lab_PMCC=[62.11,18.96,19.76];
%%
%late CAT
wd65_64=[94.811 100.00 107.304];
L=10:10:80;
lab_bf=[L',par_all(:,4:5)];
%------
% RGBw_pre=[142.0000  105.0000   86.3333];%眼白
% % RGBw_pre=[221.6158      220.4345       213.295];
% XYZw_pre=srgb2xyz(RGBw_pre./255);



XYZw_pre=[82.899171244283790,86.782992208213000,75.037090964697270];
XYZw_pre=XYZw_pre./XYZw_pre(2).*wd65_64(2);
%----
XYZ_bf=lab2xyz2(lab_bf,'user',XYZw_pre);

[CCT,duv,S_out] = xyz2CCT(XYZw_pre,10);
D1=0.723*(1-1116/CCT+8.64*duv-49266*duv/CCT);
D2=0.239*0.723*(1-1116/CCT);

for i_para=1:size(par_all,1)
    % XYZ_aft(i_para,:) = CAT16(XYZ_bf(i_para,:), XYZw_pre, wd65_64, 100, 1);
    XYZ_aft1(i_para,:) = CAT16_D(XYZ_bf(i_para,:), XYZw_pre, wd65_64, D1);
    XYZ_aft2(i_para,:) = CAT16_D(XYZ_bf(i_para,:), XYZw_pre, wd65_64, D2);
end
% lab_aft=xyz2lab(XYZ_aft,'d65_64');
lab_aft1=xyz2lab(XYZ_aft1,'d65_64');
lab_aft2=xyz2lab(XYZ_aft2,'d65_64');

lab_CAT1=lab_aft1;

%%
for i_para=1:n_para
    figure(i_para);
    subplot('Position', [0.1, 0.3, 0.8, 0.6]); % 调整绘制区域位置和尺寸
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

    s0=contour(data2,data3,y,[0.5,1],'Linewidth',2);
    hold on;





    %%
    % scatter
    load(strcat("level_data\labNscore_level",num2str(i_para),"0.mat"));
    score_level=(score_level-(-3))./6;
    score_level=mean(score_level,2);
    scatter(lab_level(:,2),lab_level(:,3), 40, score_level, 'filled'); 
    % 添加条件判断，只在 L=40 或 L=80 时显示 color bar
    if i_para == 4 || i_para == 8
        colorbar; % 显示颜色条
    end
    hold on;

    scatter(par(4),par(5), 40, 'filled');
    % plot(lab_aft(i_para,2), lab_aft(i_para,3),  'p', 'MarkerSize', 10, ...
    % 'MarkerFaceColor', [1 0 0]);
    % plot(lab_aft1(i_para,2), lab_aft1(i_para,3),  'p', 'MarkerSize', 10, ...
    % 'MarkerFaceColor', [0 1 1]);
    plot(lab_CAT1(i_para,2), lab_CAT1(i_para,3),  'p', 'MarkerSize', 10, ...
    'MarkerFaceColor', "b","MarkerEdgeColor","b");
    
    plot(lab_PMCC(2), lab_PMCC(3),  's', 'MarkerSize', 10, ...
        'MarkerFaceColor', [1, 0.4, 0.8], 'MarkerEdgeColor', [1, 0.4, 0.8]);

    annotation('textbox', [0.1, 0.02, 0.8, 0.15], 'String', ...
        sprintf(['fit center: [%.2f, %.2f] hue:%.2f°\n ' ...
        'fit center after CAT: [%.2f, %.2f] hue:%.2f°\n '...
        'PMCC: [%.2f, %.2f] hue:%.2f°\n' ...
        '45° Line: y = x' ], ...
         a(4), a(5), atan2d(a(5),a(4)) , ...
         lab_CAT1(i_para,2), lab_CAT1(i_para,3), ...
            atan2d(lab_CAT1(i_para,3),lab_CAT1(i_para,2)) , ...
         lab_PMCC(2), lab_PMCC(3), atan2d(lab_PMCC(3),lab_PMCC(2))), ...
        'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
        'BackgroundColor', 'white', 'EdgeColor', 'black', 'FontSize', 8);


    xlabel('{\ita*}');
    ylabel('{\itb*}');
    title(strcat('{\itL*}=',num2str(i_para),'0'));
        %%

    lim_max=max(max(lab_level(:,2)),max(lab_level(:,3)))+30;
    lim_min=min(min(lab_level(:,2)),min(lab_level(:,3)))-10;

    %45°
    axis equal;

    x = linspace(lim_min, lim_max, 1000);
    y= x;
    text( 20,20,'45°', ...
                'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'FontSize', 10);
    plot(x,y);

    hold on;
    xlim([lim_min,lim_max]);
    ylim([lim_min,lim_max]);

    save_folder="ellip_pic\ellipse_m_cat\summer";
    if ~exist(save_folder,"dir")
        mkdir(save_folder);
    end
    saveas(i_para,fullfile(save_folder,strcat('ellipContourNscatter',num2str(i_para),'.jpg')));


end



%%
%draw L-C,a-b
%%
%L-C
L=[10;20;30;40;50;60;70;80];
% L=lab_CAT(:,1);
figure();
% lab_CAT(i_para,2), lab_CAT(i_para,3)
C_all=sqrt(lab_CAT1(:,2).^2+lab_CAT1(:,3).^2);
for i_para=1:n_para

    scatter(C_all(i_para),L(i_para), 40, 'filled'); 
    text( C_all(i_para)+10, L(i_para),strcat('{\it L*=}',num2str(L(i_para,1))), ...
            'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', ...
            'FontSize', 8);
    hold on;
end

% L_C(:,1)=L;
% L_C(:,2)=1/1.242926153.*C_all;
% L_C(:,3)=0.73815/1.242926153.*C_all;
% save("Z:\homes\Peggy\VIVOskinExpe\Hassel_downsampled\HD65\cropped\CardMasked\L_C.mat","L_C");
%%
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
max_lim=max(C_all(:))+10;
% x = 0:0.1:max_lim;
% y= x;
% text( 20,15,'45°', ...
%             'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'FontSize', 10);
% plot(x,y);
%画拟合直线
x = 0:0.1:max_lim;
y= a_LC(1)*x+a_LC(2);
% text( 30,55,[strcat('{\itL*}=',num2str(a(1)),'×{\itC*}')], ...
%             'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'FontSize', 10);
% text( 30,50,[strcat(num2str(a(2)))], ...
%             'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'FontSize', 10);
plot(x,y);

%设置坐标

ax = gca; ax.XLim = [0 max_lim];
ay = gca; ay.YLim = [0 90];
xlabel('C_{ab}*','FontAngle','italic');
ylabel('L*','FontAngle', 'italic');
title('L*-C_{ab}*','FontAngle', 'italic');
saveas(gcf,['ellip_pic\linear\m\CATed\L_C.jpg']);


%%
%a-b
figure();
C_all=sqrt(lab_CAT1(:,2).^2+lab_CAT1(:,3).^2);
for i_para=1:n_para

%     if i_para==5||i_para==7
%         continue
%     end
    scatter(lab_CAT1(i_para,2),lab_CAT1(i_para,3), 40, 'filled'); 
    text( lab_CAT1(i_para,2)+4,lab_CAT1(i_para,3),strcat('{\it L*=}',num2str(L(i_para,1))), ...
            'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'FontSize', 8);
    hold on;
end
%%
%拟合直线
    xdata = lab_CAT1(:,2);
    ydata = lab_CAT1(:,3);

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
axis equal;
max_lim=max(max(lab_CAT1(:,2)),max(lab_CAT1(:,3)))+10;
x = 0:0.1:max_lim;
y= a_ab*x;
% text( 15,12,strcat('{\ita*}=',num2str(a),'×{\itb*}'), ...
%             'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'FontSize', 10);
plot(x,y);

x = 0:0.1:max_lim;
y= x;
text( 15,15,'45°', ...
            'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'FontSize', 10);
plot(x,y);


ax = gca; ax.XLim = [0 max_lim];
ay = gca; ay.YLim = [0 max_lim];
xlabel('{\ita*}');
ylabel('{\itb*}');
title('{\ita*-b*}');
saveas(gcf,['ellip_pic\linear\m\CATed\a_b.jpg']);




%%
%L-C无截距
% L=[10;20;30;40;50;60;70;80];
% % L=lab_CAT(:,1);
% figure();
% C_all=sqrt(lab_CAT(:,2).^2+lab_CAT(:,3).^2);
% for i_para=1:n_para
% 
%     scatter(C_all(i_para),L(i_para), 40, 'filled'); 
%     text( C_all(i_para)+10, L(i_para),strcat('{\it L*=}',num2str(L(i_para,1))), ...
%             'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', ...
%             'FontSize', 8);
%     hold on;
% end
% 
% 
% %拟合直线
%     xdata = C_all(:);
%     ydata = L;
% 
%     f = @(a,xdata)(a.*xdata);
% 
%     rmax = 0;
% 
%     for t = 1:500
%         a0 = rand;
%         options = optimset('MaxFunEvals',200000);
%         a = lsqcurvefit(f,a0,xdata,ydata,-inf,inf,options);
%         y = a.*xdata;
% 
%         r = corr(y,ydata);
%         if r >= rmax
%             rmax = r;
%             afinal = a;
%         end
%     end
%     r_LC=rmax;
%     a_LC = afinal;
% %%
% %45°
% axis equal;
% max_lim=max(C_all(:))+10;
% x = 0:0.1:max_lim;
% y= x;
% text( 20,15,'45°', ...
%             'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'FontSize', 10);
% plot(x,y);
% %画拟合直线
% x = 0:0.1:max_lim;
% y= a_LC*x;
% 
% plot(x,y);
% 
% %设置坐标
% 
% ax = gca; ax.XLim = [0 max_lim];
% ay = gca; ay.YLim = [0 90];
% xlabel('C_{ab}*','FontAngle','italic');
% ylabel('L*','FontAngle', 'italic');
% title('L*-C_{ab}*','FontAngle', 'italic');
% saveas(gcf,['ellip_pic\linear\m\CATed\noIntercept\L_C_noIntercept.jpg']);

