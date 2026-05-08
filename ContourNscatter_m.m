close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量
addpath("utils\")
%%
load("fitRes\fitRes_level_m.mat");
[n_para,~]=size(par_all);
aabbh=[];
lab_PMCC=[62.11,18.96,19.76];
%%
%late CAT
wd65_64=[94.811 100.00 107.304];
L=10:10:80;
lab_bf=[L',par_all(:,4:5)];
RGBw_pre=[142.0000  105.0000   86.3333];%眼白
XYZw_pre=srgb2xyz(RGBw_pre./255);
XYZw_pre=XYZw_pre./XYZw_pre(2).*wd65_64(2);
XYZ_bf=lab2xyz2(lab_bf,'user',XYZw_pre);

[CCT,duv,S_out] = xyz2CCT(XYZw_pre,10);
D1=0.723*(1-1116/CCT+8.64*duv-49266*duv/CCT);
D2=0.239*0.723*(1-1116/CCT);
D3=0.239*0.723*(1-1116/CCT+8.64*duv-49266*duv/CCT);

for i_para=1:size(par_all,1)
    XYZ_aft(i_para,:) = CAT16_D(XYZ_bf(i_para,:), XYZw_pre, wd65_64, D3);
    % XYZ_aft(i_para,:) = CAT16(XYZ_bf(i_para,:), XYZw_pre, wd65_64, 100, 1);
    XYZ_aft1(i_para,:) = CAT16_D(XYZ_bf(i_para,:), XYZw_pre, wd65_64, D1);
    XYZ_aft2(i_para,:) = CAT16_D(XYZ_bf(i_para,:), XYZw_pre, wd65_64, D2);
end
lab_aft=xyz2lab(XYZ_aft,'d65_64');
lab_aft1=xyz2lab(XYZ_aft1,'d65_64');
lab_aft2=xyz2lab(XYZ_aft2,'d65_64');
%%
for i_para=1:n_para
    figure(i_para);
    subplot('Position', [0.1, 0.4, 0.8, 0.55]);
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
    plot(lab_aft(i_para,2), lab_aft(i_para,3),  'p', 'MarkerSize', 15, ...
    'MarkerFaceColor', 'r');
    plot(lab_aft1(i_para,2), lab_aft1(i_para,3),  'p', 'MarkerSize', 15, ...
    'MarkerFaceColor', 'g');
    plot(lab_aft2(i_para,2), lab_aft2(i_para,3),  'p', 'MarkerSize', 15, ...
    'MarkerFaceColor', 'b');
    plot(lab_PMCC(2), lab_PMCC(3),  's', 'MarkerSize', 15, ...
        'MarkerFaceColor', [1, 0.4, 0.8], 'MarkerEdgeColor', [1, 0.4, 0.8]);

    text(10, -5,strcat('center:(',num2str(par(4),'%.3f'),',',num2str(par(5), '%.3f'),')' ), ...
    'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'FontSize', 10); 
    text(10, -8,strcat('zscore：',num2str(max(max(y)), '%.3f')), ...
    'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'FontSize', 10); 


    xlabel('{\ita*}');
    ylabel('{\itb*}');
    title(strcat('{\itL*}=',num2str(i_para),'0'));
        %%

    lim_max=max(max(lab_level(:,2)),max(lab_level(:,3)))+30;
    lim_min=min(min(lab_level(:,2)),min(lab_level(:,3)))-10;

    %45°
    axis equal;
    % x = linspace(a(4)-15, a(4)+15, 1000);
    % y= tand(45)*(x-a(4))+a(5);
    x = linspace(lim_min, lim_max, 1000);
    y= x;
    text( 20,20,'45°', ...
                'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'FontSize', 10);
    plot(x,y);

    hold on;
    xlim([lim_min,lim_max]);
    ylim([lim_min,lim_max]);

    annotation('textbox', [0.1, 0.02, 0.8, 0.25], 'String', ...
    sprintf(['red point: fit center: [%.2f, %.2f] hue:%.2f\n ' ...
    '\x2605 cat 100 1 center: [%.2f, %.2f] hue:%.2f\n' ...
    '\x2605 cat D1 fit center: [%.2f, %.2f] hue:%.2f\n' ...
    '\x2605 cat D2 fit center: [%.2f, %.2f]  hue:%.2f\n ' ...
    '\x25A0 PMCC: [%.2f, %.2f] ' ...
    '45° Line: y = x\n'], ...
     par(4),par(5),atan2d(par(5),par(4)), ...
     lab_aft(i_para,2), lab_aft(i_para,3),atan2d(lab_aft(i_para,3),lab_aft(i_para,2)), ...
     lab_aft1(i_para,2), lab_aft1(i_para,3),atan2d(lab_aft1(i_para,3),lab_aft1(i_para,2)), ...
     lab_aft2(i_para,2), lab_aft2(i_para,3),atan2d(lab_aft2(i_para,3),lab_aft2(i_para,2)), ...
     lab_PMCC(2), lab_PMCC(3)), ...
    'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
    'BackgroundColor', 'white', 'EdgeColor', 'black', 'FontSize', 6);


    save_folder="ellip_pic\ellipse_m_cat";
    if ~exist(save_folder,"dir")
        mkdir(save_folder);
    end
    saveas(i_para,fullfile(save_folder,strcat('ellipContourNscatter',num2str(i_para),'.jpg')));


end

