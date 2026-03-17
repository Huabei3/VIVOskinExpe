close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量

%% 定义所有需要处理的 attribute
% attributes = [ 8, 9,10];
attributes = [1, 2, 3, 4, 5, 6, 8, 9,10];
attribute_names = ["Preference", "Attractiveness", "Feminine", "Cooperative", ...
    "Youth", "Healthy", "Precise reproduction",...
    "suit the environment or not", "white-skinned", "ruddyadd"];
attribute_names_new = ["Preference", "Attractiveness", "Feminine", "Cooperative", ...
    "Youth", "Healthy", "Fidelity","Harmony", "Fair", "Ruddy"];
picname_group=["h3k","h4k","h5k","h6k","hd65","h7k","h8k",...
    "m3k","m4k","m5k","m6k","md65","m7k","m8k",...
    "l3k","l4k","l5k","l6k","ld65","l7k","l8k"];
wd65_64 = [94.811, 100.00, 107.304];
CT = [3000, 4000, 5000, 6000, 6500, 7000, 8000, ...
      3000, 4000, 5000, 6000, 6500, 7000, 8000, ...
      3000, 4000, 5000, 6000, 6500, 7000, 8000]';
obs_types=["non_model"];
obs_types_new=["stranger"];

% 定义色环上的 7 种颜色

colors(1:7,:)='r';
colors(8:14,:)='g';
colors(15:21,:)='b';
lastParts = {'f04i', 'f05i', 'f06i', ...
'm04i', 'm05i', 'm06i'};  
Dtype='summer';
for i_obstype=1:1
    save_folder = fullfile("ellip_pic\ellipse1",  Dtype, ...
        "scatterCen","hml","average",obs_types(i_obstype));
    % 创建保存文件夹
    if ~exist(save_folder, "dir")
        mkdir(save_folder);
    end
    
    lab_PMCC = [62.11, 18.96, 19.76];
    labC_PMCC = [lab_PMCC, sqrt(lab_PMCC(1, 2)^2 + lab_PMCC(1, 3)^2)];
    
  
    for lastPart_idx = 1:length(lastParts)
        lastPart = lastParts{lastPart_idx};
    
        model = lastPart(1:end-1);
        [lastPart1, model1] = gen_lastPart1(lastPart);
        lastPart_new=gen_lastPart_new(lastPart1);
        disp([lastPart,lastPart_new])
        average_file = fullfile("aveSkin", strrep(lastPart_new,"add",""), ...
            "\autoNhand_scaleoverLUT.mat");
        average_data = load(average_file);
        average_inds(:,:,lastPart_idx) = average_data.average_lab_all(:, 1:3);
        for attribute = attributes
            fprintf('Processing attribute: %d\n', attribute);        
            % 生成 attribute_serial
            attribute_serial = strcat(sprintf("%02d", attribute), attribute_names_new(attribute));
            % 定义路径
            source_file_used = fullfile('AnalyseResults1', Dtype, lastPart, ...
                obs_types(i_obstype), attribute_serial, ...
                'ellipPara', 'fitRes.mat'); % 新增 source_file_used
            
            par_all4=[];
            if exist(source_file_used, 'file') % 新增 source_file_used 的加载
                load(source_file_used);
                par_all4 = par_all;
            else
                par_all4(1:21,1:6)=NaN;
            end
            par_inds(:,:,lastPart_idx,attribute)=par_all4;
        end
    end
    
    average=nanmean(average_inds,3);
    par_all4=nanmean(par_inds,3);
    %a-b
    lim_min_x=min(min(min(par_all4([5,12,19],4,:,:))))-1;
    lim_max_x=max(max(max(par_all4([5,12,19],4,:,:))))+1;
    lim_min_y=min(min(min(par_all4([5,12,19],5,:,:))))-1;
    lim_max_y=max(max(max(par_all4([5,12,19],5,:,:))))+1;
    
    % %% a-b
    % for attribute = attributes
    %     fprintf('Processing attribute: %d\n', attribute);
    %     par_all_used=par_all4(:,:,1,attribute);
    %     % 生成 attribute_serial
    %     attribute_serial = strcat(sprintf("%02d", attribute), attribute_names_new(attribute));
    % 
    %     figure();
    %     hold on;
    %     set(gcf, 'Color', 'white');
    %     for i_para = 1:length(par_all_used)
    %         % 计算 labC_PMCCpre
    %         if average(i_para, 1) <= 60
    %             C_pre = 6.7421 * log(average(i_para, 1)) - 9.9816; % 亮度实验
    %         else
    %             C_pre = 6.7421 * log(60) - 9.9816; % 亮度实验
    %         end
    %         labC_PMCCpre(i_para, 1) = average(i_para, 1);
    %         labC_PMCCpre(i_para, 2:3) = lab_PMCC(1, 2:3) ./ labC_PMCC(1, 4) .* C_pre;
    %         labC_PMCCpre(i_para, 4) = C_pre;
    %     end
    %     for i_para = [5,12,19]
    %         % 绘制 source_file_used 的 contour 或散点图 (新增部分)
    %         if exist('par_all_used', 'var')&&~isempty(par_all_used)
    %             par = par_all_used(i_para, :);
    % 
    %             text(par(4), par(5), picname_group(i_para), 'FontSize', 8, 'VerticalAlignment', 'middle');
    %             scatter(par(4), par(5), 30, 'o', 'filled', 'MarkerFaceColor', colors(floor((i_para-1)/7)+1, :));
    % 
    %         end
    % 
    % 
    % 
    %     end
    %                 % 绘制 PMCC 点
    %     plot(labC_PMCCpre(7, 2), labC_PMCCpre(7, 3), 's', 'MarkerSize', 10, ...
    %         'MarkerFaceColor', 'm', 'MarkerEdgeColor', 'm');
    %     text(labC_PMCCpre(7, 2), labC_PMCCpre(7, 3),'h-PMCC', ...
    %         'FontSize', 8, 'VerticalAlignment', 'middle');
    % 
    %     plot(labC_PMCCpre(14, 2), labC_PMCCpre(14, 3), 's', 'MarkerSize', 10, ...
    %         'MarkerFaceColor', 'm', 'MarkerEdgeColor', 'm');
    %     text(labC_PMCCpre(14, 2), labC_PMCCpre(14, 3),'l-PMCC', ...
    %         'FontSize', 8, 'VerticalAlignment', 'middle');
    % 
    %     plot(labC_PMCCpre(21, 2), labC_PMCCpre(21, 3), 's', 'MarkerSize', 10, ...
    %         'MarkerFaceColor', 'm', 'MarkerEdgeColor', 'm');
    %     text(labC_PMCCpre(21, 2), labC_PMCCpre(21, 3),'m-PMCC', ...
    %         'FontSize', 8, 'VerticalAlignment', 'middle');
    % 
    %     % 添加图例、标签和标题
    %     xlabel('{\ita*}');
    %     ylabel('{\itb*}');
    %     title(strcat(obs_types_new(i_obstype),attribute_names_new(attribute)));
    % 
    %     % 设置坐标轴范围
    %     x = linspace(0, 25, 100); % 从 -10 到 10，生成 100 个点
    %     plot(x, x); % 'r-' 表示红色实线
    %     axis equal;
    %     xlim([lim_min_x, lim_max_x]);
    %     ylim([lim_min_y, lim_max_y]);
    %     if ~exist(fullfile(save_folder, 'a_b'),"dir")
    %         mkdir(fullfile(save_folder, 'a_b'));
    %     end
    %     exportgraphics(gcf, fullfile(save_folder, 'a_b',strcat(attribute_serial,  '.jpg')), 'Resolution', 300);
    %     close(gcf);
    % 
    % end
    % concatenate_images1(fullfile(save_folder, 'a_b') ,5);
    %% C-L
    for attribute = attributes
       
        
        fprintf('Processing attribute: %d\n', attribute);
        par_all_used=par_all4(:,:,1,attribute);
        % 生成 attribute_serial
        attribute_serial = strcat(sprintf("%02d", attribute), attribute_names_new(attribute));
        attribute_serialnew=gen_attribute_new(attribute_serial);
        figure(1);
        hold on;
         if ~(i_obstype==1&&attribute==7)
            set(gcf, 'Color', 'white'); 
            C=sqrt(par_all_used([5,12,19],4).^2+par_all_used([5,12,19],5).^2);
            L=average([5,12,19],1);
            hold on;
            scatter(L,C, 40, '+','LineWidth', 1); 
        
        %拟合曲线
            xdata = L;
            ydata = C;
        
            f = @(a,xdata)(a(1).*log(xdata)+a(2));
        
            rmax = 0;
        
            for t = 1:500
                a0 = [rand,rand];
                options = optimset('MaxFunEvals',200000);
                a = lsqcurvefit(f,a0,xdata,ydata,[-inf,-inf],[inf,inf],options);
                y = a(1).*log(xdata)+a(2);
        
                r = corr(y,ydata);
                if r >= rmax
                    rmax = r;
                    afinal = a;
                end
            end
            r_CL=rmax;
            a_CL = afinal;
        
            axis equal;
            max_lim=max(L(:))+10;
            
            %画拟合直线
            x = 0:0.1:max_lim;
            y= a_CL(1)*log(x)+a_CL(2);
            % y1=8.4412*log(x)-10.859;
            y2=6.7421*log(x)-9.9816;%亮度实验
            % y3=5.648268903337794*log(x)-7.382104283246091;
            plot(x,y,"Color","r");
            plot(x,y2,"Color","b");
            
            
            %设置坐标
            
            % ax = gca; ax.XLim = [0 max_lim];
            % ay = gca; ay.YLim = [0 20];
            xlabel('L_{ab}*','FontAngle','italic');
            ylabel('C*','FontAngle', 'italic');
        end
        title(strcat(obs_types_new(i_obstype),attribute_serialnew,' C*-L_{ab}*'),'FontAngle', 'italic');
    
        output_folder=fullfile(save_folder, 'C_L');
        if ~exist(output_folder,"dir")
            mkdir(output_folder);
        end
        exportgraphics(gcf,fullfile(output_folder,strcat(attribute_serialnew,'.jpg')),"Resolution",150);
        close(1)
    end
    concatenate_images1(output_folder ,5);
end
%%
% %L-C
% C=sqrt(par_all4(:,4,:,:).^2+par_all4(:,5,:,:).^2);
% lim_min_x=min(min(min(C([5,12,19],1,:,:))))-1;
% lim_max_x=max(max(max(C([5,12,19],1,:,:))))+1;
% lim_min_y=min(min(min(average([5,12,19], 1))))-1;
% lim_max_y=max(max(max(average([5,12,19], 1))))+1;
% % for attribute = [10]
% for attribute = attributes
%     fprintf('Processing attribute: %d\n', attribute);
%     par_all_used=par_all4(:,:,1,attribute);
%     % 生成 attribute_serial
%     attribute_serial = strcat(sprintf("%02d", attribute), attribute_names_new(attribute));
% 
%         % 创建新图窗
%     figure();
%     hold on;
%     set(gcf, 'Color', 'white');
%     for i_para = 1:length(par_all_used)
%         % 计算 labC_PMCCpre
%         if average(i_para, 1) <= 60
%             C_pre = 6.7421 * log(average(i_para, 1)) - 9.9816; % 亮度实验
%         else
%             C_pre = 6.7421 * log(60) - 9.9816; % 亮度实验
%         end
%         labC_PMCCpre(i_para, 1) = average(i_para, 1);
%         labC_PMCCpre(i_para, 2:3) = lab_PMCC(1, 2:3) ./ labC_PMCC(1, 4) .* C_pre;
%         labC_PMCCpre(i_para, 4) = C_pre;
%     end
%     for i_para = [5,12,19]
%         % 绘制 source_file_used 的 contour 或散点图 (新增部分)
%         if exist('par_all_used', 'var')&&~isempty(par_all_used)
%             par = par_all_used(i_para, :);
% 
%             text(sqrt(par(4).^2+par(5).^2),average(i_para, 1),  picname_group(i_para), 'FontSize', 8, 'VerticalAlignment', 'middle');
%             scatter(sqrt(par(4).^2+par(5).^2),average(i_para, 1),  30, 'o', 'filled', 'MarkerFaceColor', colors(floor((i_para-1)/7)+1, :));
% 
%         end
% 
% 
% 
%     end
%                 % 绘制 PMCC 点
%     plot(labC_PMCCpre(7, 4), labC_PMCCpre(7, 1), 's', 'MarkerSize', 10, ...
%         'MarkerFaceColor', 'm', 'MarkerEdgeColor', 'm');
%     text(labC_PMCCpre(7, 4), labC_PMCCpre(7, 1),'h-PMCC', ...
%         'FontSize', 8, 'VerticalAlignment', 'middle');
% 
%     plot(labC_PMCCpre(14, 4), labC_PMCCpre(14, 1), 's', 'MarkerSize', 10, ...
%         'MarkerFaceColor', 'm', 'MarkerEdgeColor', 'm');
%     text(labC_PMCCpre(14, 4), labC_PMCCpre(14, 1),'l-PMCC', ...
%         'FontSize', 8, 'VerticalAlignment', 'middle');
% 
%     plot(labC_PMCCpre(21, 4), labC_PMCCpre(21, 1), 's', 'MarkerSize', 10, ...
%         'MarkerFaceColor', 'm', 'MarkerEdgeColor', 'm');
%     text(labC_PMCCpre(21, 4), labC_PMCCpre(21, 1),'m-PMCC', ...
%         'FontSize', 8, 'VerticalAlignment', 'middle');
% 
%     % 添加图例、标签和标题
%     xlabel('{\itC*}');
%     ylabel('{\itL*}');
%     title(strcat(attribute_names_new(attribute)));
% 
%     % 设置坐标轴范围
%     x = linspace(0, 25, 100); % 从 -10 到 10，生成 100 个点
%     xlim([lim_min_x, lim_max_x]);
%     ylim([lim_min_y, lim_max_y]);
%     if ~exist(fullfile(save_folder, 'L_C'),"dir")
%         mkdir(fullfile(save_folder, 'L_C'));
%     end
%     exportgraphics(gcf, fullfile(save_folder, 'L_C',strcat(attribute_serial,  '.jpg')), 'Resolution', 300);
%     close(gcf);
% 
% end
% concatenate_images1(fullfile(save_folder, 'L_C') ,5);
%% 绘制图例图
figure;
hold on;
set(gcf, 'Color', 'white');

% 设置图例图的位置和大小
axis([0 70 0 6]); % 增加 y 轴范围以容纳更多内容
axis off;

% 定义图例的 7 个颜色块和对应的名字
legend_names = ["3k", "4k", "5k", "6k", "7k", "8k", "d65"];
legend_colors = hsv(7); % 使用 hsv 色图生成 7 种颜色

% 绘制颜色块和对应的名字
for i = 1:length(legend_names)
    % 计算当前行和列
    row = mod(i - 1, 3) + 1; % 每列 3 个
    col = floor((i - 1) / 3) + 1; % 共 3 列
    
    % 绘制颜色块
    rectangle('Position', [2 + (col - 1) * 8, row, 1, 0.8], 'FaceColor', legend_colors(i, :), 'EdgeColor', 'k');
    % 添加名字文本
    text(3.5 + (col - 1) * 8, row + 0.5, legend_names(i), 'FontSize', 12, 'VerticalAlignment', 'middle');
end





% 调整图窗大小以确保所有内容可见
set(gcf, 'Position', [100, 100, 1200, 600]); % 设置图窗宽度为 1200，高度为 400

% 保存图例图
if ~exist(fullfile(save_folder, "legend"), "dir")
    mkdir(fullfile(save_folder, "legend"));
end
exportgraphics(gcf, fullfile(save_folder, "legend", strcat(lastPart, '_lights_legend.jpg')), 'Resolution', 300);

close(gcf);