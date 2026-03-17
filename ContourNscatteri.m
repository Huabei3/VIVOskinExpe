close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量
%% 
lastPart='femalevivoi';
attribute=1;

attribute_names=["Preference","Attractiveness","Feminine","Cooperative",...
    "Youth","Healthy","suit the environment or not","white-skinned","ruddy"];
attribute_serial=strcat(sprintf("%02d",attribute),attribute_names(attribute));

source_file=fullfile('AlalyseResults',lastPart, ...
    attribute_serial,'ellipPara','fitRes_level.mat');
slashes = strfind(source_file, '\');

save_folder=fullfile("ellip_pic\ellipse",lastPart,attribute_serial);
if ~exist(save_folder,"dir")
    mkdir(save_folder);
end

model = lastPart(1:end-1);
load(source_file);
[lastPart1,model1]= gen_lastPart1(lastPart);
average_file=strcat("..\renderCode\aveSkinByHand2\",lastPart1,"\autoNhand_scaleoverLUT.mat");
average=load(average_file);
average=average.average_lab_all(:,1:3);

[n_para,~]=size(par_all);

lab_PMCC=[62.11,18.96,19.76];
labC_PMCC=[lab_PMCC,sqrt(lab_PMCC(1,2)^2+lab_PMCC(1,3)^2)];
%% late CAT
wd65_64=[94.811 100.00 107.304];
CT=[3000,4000,5000,6000,7000,8000,6500,...
    3000,4000,5000,6000,7000,8000,6500,...
    3000,4000,5000,6000,7000,8000,6500]';
for i_para=1:n_para
    lab_bf(i_para,:)=[average(i_para,1),par_all(i_para,4:5)];
    CCT=CT(i_para);
    XYZw_pre(i_para,:)=CCT2xyz(CCT);
    % XYZ_bf(i_para,:)=lab2xyz2(lab_bf(i_para,:),'user',XYZw_pre);
    XYZ_bf(i_para,:)=lab2xyz2(lab_bf(i_para,:),'d65_64');
    [CCT,duv,S_out] = xyz2CCT(XYZw_pre(i_para,:),10);
    D1=0.723*(1-1116/CCT+8.64*duv-49266*duv/CCT);%zhai
    D2=0.239*0.723*(1-1116/CCT);%summer
    D3=0.00005*CCT+0.1977;%OPPO
    XYZ_aft(i_para,:) = CAT16_D(XYZ_bf(i_para,:), XYZw_pre, wd65_64,  1);
    XYZ_aft1(i_para,:) = CAT16_D(XYZ_bf(i_para,:), XYZw_pre, wd65_64, D1);
    XYZ_aft2(i_para,:) = CAT16_D(XYZ_bf(i_para,:), XYZw_pre, wd65_64, D2);
    XYZ_aft3(i_para,:) = CAT16_D(XYZ_bf(i_para,:), XYZw_pre, wd65_64, D3);
    lab_aft(i_para,:)=xyz2lab(XYZ_aft(i_para,:),'d65_64');
    lab_aft1(i_para,:)=xyz2lab(XYZ_aft1(i_para,:),'d65_64');
    lab_aft2(i_para,:)=xyz2lab(XYZ_aft2(i_para,:),'d65_64');
    lab_aft3(i_para,:)=xyz2lab(XYZ_aft3(i_para,:),'d65_64');

    %计算labC_PMCCpre
    if average(i_para,1)<=60
        C_pre=6.7421*log(average(i_para,1))-9.9816;%亮度实验
    else
        C_pre=6.7421*log(60)-9.9816;%亮度实验
    end
    labC_PMCCpre(i_para,1)=average(i_para,1);
    labC_PMCCpre(i_para,2:3)=lab_PMCC(1,2:3)./labC_PMCC(1,4).*C_pre;
    labC_PMCCpre(i_para,4)=C_pre;
end
% lab_CAT=lab_aft1;Dtype="zhai";
% lab_CAT=lab_aft2;Dtype="summer";
% lab_CAT=lab_aft3;Dtype="D3";
%%

dir_labNgroup=dir(fullfile("AlalyseResults",lastPart,attribute_serial,"labNscore\*.mat"));

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





    %scatter
    MSVNlab=load(fullfile(dir_labNgroup(i_para).folder,dir_labNgroup(i_para).name));
    lab_group=MSVNlab.lab_group;
    MSV_group=MSVNlab.MSV_group;

    scatter(lab_group(:,2),lab_group(:,3), 40, MSV_group, 'filled'); 
    % 添加条件判断，只在 L=40 或 L=80 时显示 color bar
    if mod(i_para,7)==0
        colorbar; % 显示颜色条
    end
    hold on;

    scatter(par(4),par(5), 30, 'filled');
% plot(lab_aft(i_para,2), lab_aft(i_para,3),  'p', 'MarkerSize', 10, ...
%     'MarkerFaceColor', [1 0 0], 'MarkerEdgeColor', [1 0 0]); % 红色
% plot(lab_aft1(i_para,2), lab_aft1(i_para,3),  'p', 'MarkerSize', 10, ...
%     'MarkerFaceColor', [0 1 0], 'MarkerEdgeColor', [0 1 0]); % 绿色
plot(lab_aft2(i_para,2), lab_aft2(i_para,3),  'p', 'MarkerSize', 10, ...
    'MarkerFaceColor', [0 0 1], 'MarkerEdgeColor', [0 0 1]); % 蓝色
% plot(lab_aft3(i_para,2), lab_aft3(i_para,3),  'p', 'MarkerSize', 10, ...
%     'MarkerFaceColor', [1 1 0], 'MarkerEdgeColor', [1 1 0]); % 黄色
plot(labC_PMCCpre(i_para,2), labC_PMCCpre(i_para,3),  's', 'MarkerSize', 10, ...
    'MarkerFaceColor', [1, 0.4, 0.8], 'MarkerEdgeColor', [1, 0.4, 0.8]); % 保持原色

    annotation('textbox', [0.1, 0.02, 0.8, 0.15], 'String', ...
        sprintf(['fit center: [%.2f, %.2f] hue:%.2f°\n ' ...
                'lab_{CATed}(summer): [%.2f, %.2f] hue:%.2f°\n' ...
        'PMCC: [%.2f, %.2f] hue:%.2f°\n' ...
        '45° Line: y = x' ], ...
         a(4), a(5), atan2d(a(5),a(4)) , ...
          lab_aft2(i_para,2), lab_aft2(i_para,3), ...
          atan2d(lab_aft2(i_para,3),lab_aft2(i_para,2)) , ...
         labC_PMCCpre(2), labC_PMCCpre(3), atan2d(labC_PMCCpre(3),labC_PMCCpre(2))), ...
        'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
        'BackgroundColor', 'white', 'EdgeColor', 'black', 'FontSize', 8);


    xlabel('{\ita*}');
    ylabel('{\itb*}');
    title(strcat(attribute_names(attribute),picname_check{i_para,1}(length(lastPart)+1:end)));
        %%

    lim_max=max(max(lab_group(:,2)),max(lab_group(:,3)))+10;
    lim_min=min(min(lab_group(:,2)),min(lab_group(:,3)))-10;
    % 添加 x=0 和 y=0 的轴
    line([0, 0], [lim_min, lim_max], 'Color', 'k', 'LineStyle', '--'); % x=0
    line([lim_min, lim_max], [0, 0], 'Color', 'k', 'LineStyle', '--'); % y=0

    % 添加 45 度线
    refline(1, 0); % 斜率为 1，截距为 0 的直线


    hold on;
    axis equal;
    xlim([lim_min,lim_max]);
    ylim([lim_min,lim_max]);
    

    saveas(i_para,fullfile(save_folder,strcat('ContourNscatter',sprintf("%d",i_para),'.jpg')));


end



%%

function [lastPart1,model1]= gen_lastPart1(lastPart)
    model=lastPart(1:end-1);
    iOr=lastPart(end);
    if strcmp(model,'femalevivo')
        model1='femaleVIVO';
    elseif strcmp(lastPart,'malevivo')
        model1='maleVIVO';
    else
        model1=model;
    end
    lastPart1=strcat(model1,iOr);
end