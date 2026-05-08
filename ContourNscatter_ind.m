close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量
%%
dir_obs=dir("ind_ellip\ind_ellip_para_*.mat");

global_obs=load("fitRes\fitRes_level_p.mat");
global_para=global_obs.par_all;

n_obs=16;
de00_all=[];
colors = colormap(jet(n_obs)); 

for i_obs=1:n_obs
% for i_obs=1:length(dir_obs)    
    if i_obs==6
        continue
    end

    load(fullfile(dir_obs(i_obs).folder,'\',dir_obs(i_obs).name));
    [n_para,~]=size(par_ind);
    aabbh=[];
    lab_PMCC=[62.11,18.96,19.76];

    L=10:10:80;
    global_lab=[L',global_para(:,4:5)];
    ind_lab=[L',par_ind(:,4:5)];

    [de00,de00c] = deltaE2000(global_lab,ind_lab);
    

    for i_para=1:n_para
        figure(i_para);
        par=par_ind(i_para,:);
    
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
        hold on;
        s0=contour(data2,data3,y,[0.5,1],'LineColor', colors(i_obs,:),'Linewidth',0.5);
        % set(s0,'Color',colors(i_para,:)); % 设置等高线颜色
        % for k = 1:length(s0) % 遍历等高线对象
        %     set(s0(k), 'Color', colors(i_para, :)); % 设置等高线颜色
        % end

        title('BK');
    
    
    
        
        %%
        % scatter
        lab_level=lab_level_ind{i_obs,i_para};
        score_level_ind=score_level_ind_all{i_obs,i_para};
        % colormap("parula");
        % scatter(lab_level(:,2),lab_level(:,3), 40, score_level_ind, 'filled'); 
        % colorbar; % 显示颜色条
        hold on;

        scatter(par(4),par(5), 40,colors(i_obs,:) ,'filled');
    
   
    
        xlabel('a');
        ylabel('b');
        title(strcat('L=',num2str(i_para),'0'));
            %%

    
        %45°
        axis equal;

        lim_max=max(max(lab_level(:,2)),max(lab_level(:,3)))+20;
        lim_min=min(min(lab_level(:,2)),min(lab_level(:,3)))-20;
        xlim([lim_min,lim_max]);
        ylim([lim_min,lim_max]);
        hold on;

        
        saveas(i_para,strcat('ellipse_ind\ellipContourNscatter', ...
            num2str(i_obs),'_',num2str(i_para),'.jpg'));
    
    
    end
de00_all=[de00_all,de00'];
end

%%

% % 绘制颜色条
figure(); % 创建一个新的图形窗口
for i_obs = 1:n_obs
    line([i_obs, i_obs], [0, 1], 'Color', colors(i_obs,:), 'LineWidth', 8); % 绘制线条
    axis([0 n_obs+1 0 1]); % 设置轴的范围，确保所有线条都能显示
end
xlabel('Observer Index'); % x轴标签
ylabel('Color Intensity'); % y轴标签
