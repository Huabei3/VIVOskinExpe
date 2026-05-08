close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量

load("fitRes\fitRes_level_m.mat");
[n_para,~]=size(par_all);
aabbh=[];
lab_PMCC=[62.11,18.96,19.76];


for i_para=1:n_para
    figure(i_para);

    hold on;
  
    %%
    % scatter
    load(strcat("level_data\labNscore_level",num2str(i_para),"0.mat"));
    score_level=(score_level-(-3))./6;
    score_level=mean(score_level,2);
    scatter(lab_level(:,2),lab_level(:,3), 40, 'filled'); 
    % 添加条件判断，只在 L=40 或 L=80 时显示 color bar

    hold on;




    xlabel('{\ita*}');
    ylabel('{\itb*}');
    title(strcat('{\itL*}=',num2str(i_para),'0'));
        %%

    lim_max=max(max(lab_level(:,2)),max(lab_level(:,3)))+10;
    lim_min=min(min(lab_level(:,2)),min(lab_level(:,3)))-10;

    %45°
    axis equal;


    hold on;
    xlim([lim_min,lim_max]);
    ylim([lim_min,lim_max]);

    save_folder="scatterPoints";
    if ~exist(save_folder,"dir")
        mkdir(save_folder);
    end
    saveas(i_para,fullfile(save_folder,strcat('scatterPoints',num2str(i_para),'.jpg')));


end

