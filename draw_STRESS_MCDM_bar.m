clear;clc;close all;
%%
%画intra STRESS
load("STRESS\STRESS_m.mat",'STRESS_inter1','STRESS_inter','STRESS_intra1','STRESS_intra');

% 计算条形宽度
barWidth = 0.5;

% 绘制分组条形图
% bar(MCDM_inter_all, 'grouped', 'barwidth', barWidth);

y=STRESS_intra;
x=1:1:16;
figure(1);
bar(x,y, 'grouped', 'barwidth', barWidth);
% 设置条形颜色


% 添加标题和标签
title('intra-observer difference');
xlabel('observer');
ylabel('STRESS_{intra}');

saveas(1,"ellip_pic\STRESS\STRESS_m.jpg");
List_STRESS_intra=[mean(STRESS_intra),max(STRESS_intra),std(STRESS_intra)];

%%
% %画MCDM
% % 假设 data 是 18x8 的数据矩阵
% load(strcat("level_data_m\MCDM_all\labNscore_level_MCDM_all.mat"));
% 
% % 计算条形宽度
% barWidth = 0.5;
% 
% % 绘制分组条形图
% % bar(MCDM_inter_all, 'grouped', 'barwidth', barWidth);
% 
% y=nanmean(MCDM_inter_all_00);
% x=10:10:80;
% figure(1);
% bar(x,y, 'grouped', 'barwidth', barWidth);
% % 设置条形颜色
% % colors = {'red', 'green', 'blue', 'cyan', 'magenta', 'yellow', 'black', 'white'};
% % for i = 1:8
% %     for j = 1:16
% %         set(bar(j, i), 'FaceColor', colors{i});
% %     end
% % end
% 
% % 添加标题和标签
% title('inter-observer difference');
% xlabel('{\itL*}');
% ylabel('MCDM({\itΔE}_{00})');
% 
% saveas(1,"ellip_pic\MCDM\MCDM_m.jpg");