close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量

%% 定义所有需要处理的 attribute
attributes = [1, 2, 3, 4, 5, 6,7, 8, 9,10];
attribute_names = ["Preference", "Attractiveness", "Feminine", "Cooperative", ...
    "Youth", "Healthy", "Precise reproduction","suit the environment or not", "white-skinned", "ruddy"];
picname_group=["h3k","h4k","h5k","h6k","h7k","h8k","hd65",...
    "l3k","l4k","l5k","l6k","l7k","l8k","ld65",...
    "m3k","m4k","m5k","m6k","m7k","m8k","md65"];
hml=['h','m','l'];
lastParts = {'female78i', 'female41i', 'femalevivoi', 'male59i', 'male39i', 'malevivoi'};
Dtype='summer';
for lastPart_idx = 1:length(lastParts)
    lastPart = lastParts{lastPart_idx};
    
    save_folder = fullfile("ellip_pic\ellipse", lastPart, Dtype,"convert_L","combined_light_contours");
    
    % 创建保存文件夹
    if ~exist(save_folder, "dir")
        mkdir(save_folder);
    end
    
    lab_PMCC = [62.11, 18.96, 19.76];
    labC_PMCC = [lab_PMCC, sqrt(lab_PMCC(1, 2)^2 + lab_PMCC(1, 3)^2)];
    
    model = lastPart(1:end-1);
    [lastPart1, model1] = gen_lastPart1(lastPart);
    lastPart_new=gen_lastPart_new(lastPart1);
    disp([lastPart,lastPart_new])
    average_file = strcat("..\renderCode\aveSkinByHand2\", lastPart_new, "\autoNhand_scaleoverLUT.mat");
    average = load(average_file);
    average = average.average_lab_all(:, 1:3);
    
    wd65_64 = [94.811, 100.00, 107.304];
    CT = [3000, 4000, 5000, 6000, 7000, 8000, 6500, ...
          3000, 4000, 5000, 6000, 7000, 8000, 6500, ...
          3000, 4000, 5000, 6000, 7000, 8000, 6500]';
    line_style={'-',':','-.'};
    plot_style={'^','<','v'};
    % 定义色环上的 7 种颜色
    % colors = hsv(7); % 使用 hsv 色图生成 7 种颜色
    colors={'r','g','b'};
    
    
    %% 循环处理每个 attribute
    % for attribute = [10]
    for attribute = attributes
        fprintf('Processing attribute: %d\n', attribute);
        
        % 生成 attribute_serial
        attribute_serial = strcat(sprintf("%02d", attribute), attribute_names(attribute));
        
        % 定义路径
        source_file1 = fullfile('AlalyseResults', lastPart, attribute_serial, 'ellipPara', 'fitRes_level.mat');
        source_file2 = fullfile('AlalyseResults', lastPart, 'model_group', attribute_serial, 'ellipPara', 'fitRes_level.mat');
        source_file3 = fullfile('AlalyseResults', lastPart, 'model', attribute_serial, 'ellipPara', 'fitRes_level.mat');
        source_file4 = fullfile('AlalyseResults', lastPart, 'all', attribute_serial, 'ellipPara', 'fitRes_level.mat'); % 新增 source_file4
        
        % 加载数据
        par_all4=[];
        if exist(source_file4, 'file') % 新增 source_file4 的加载
            load(source_file4);
            par_all4 = par_all;
        else
            par_all4=[];
        end
        
         
            % 创建新图窗
            figure;
            hold on;
            set(gcf, 'Color', 'white');
    
            % 计算 labC_PMCCpre
            L_h=mean(average(1:7, 1));
            L_l=mean(average(8:15, 1));
            L_m=mean(average(15:21, 1));
            if L_h <= 60
                C_pre = 6.7421 * log(L_h) - 9.9816; % 亮度实验
            else
                C_pre = 6.7421 * log(60) - 9.9816; % 亮度实验
            end
            labC_PMCCpre(1, 1) = L_h;
            labC_PMCCpre(1, 2:3) = lab_PMCC(1, 2:3) ./ labC_PMCC(1, 4) .* C_pre;
            labC_PMCCpre(1, 4) = C_pre;
    
            if exist('par_all4', 'var')&&~isempty(par_all4)
                lab_par4pre=par_all4;
                C_all4=sqrt(par_all4(:, 4).^2+par_all4(:, 5).^2);
                lab_par4pre(:, 4:5) = par_all4(:, 4:5) ./ C_all4(:) .* C_pre;
    
                centers_pre=[repmat(L_h,size(lab_par4pre,1),1),lab_par4pre(:,4:5)];
                
                %拟合95%椭圆
                gcf2=figure(2);
                hold on;
                centers_hml{1,1}=centers_pre(1:7,:);%h
                centers_hml{1,2}=centers_pre(15:21,:);%m
                centers_hml{1,3}=centers_pre(8:15,:);%l

                for i_hml=1:3
                [center_fit{1,i_hml},mu{1,i_hml},chi2_val{1,i_hml},List{1,i_hml}] =...
                    fit95ellip_my(centers_hml{1,i_hml}, 0.05, 2);
                    % 在 centers_CT{1,i_hml} 的位置上添加 CT(i_hml) 的文本标注
                text(center_fit{1,i_hml}(1, 2)+0.2, center_fit{1,i_hml}(1, 3), ...
                num2str(hml(i_hml)), 'FontSize', 8, 'Color', 'k');
                end

                center_all=mean(centers_pre,1);
                for i_col=1:3
                    for i_row=1:3
                        de_intra_hml(i_col,i_row)=deltaE2000(center_fit{1,i_col},center_fit{1,i_row});
                    end
                end
                for i_CT=1:7
    
                    for i_hml=1:3
                        de_inter_hml(i_hml,i_CT)=deltaE2000(centers_hml{1,i_hml}(i_CT,:),center_fit{1,i_hml});
                    end
                end
                %保存
                output_folder=fullfile("AlalyseResults",Dtype,lastPart, ...
                    "all",attribute_serial,"ellipPara95");
                if ~exist(output_folder,"dir")
                    mkdir(output_folder);
                end
                save(fullfile(output_folder,"hml.mat"), ...
                    "center_fit","mu","chi2_val","List");

                if ~exist(fullfile(save_folder,"check_ellipse","comp_hml"),"dir")
                    mkdir(fullfile(save_folder,"check_ellipse","comp_hml"));
                end
                exportgraphics(gcf,fullfile(save_folder,"check_ellipse","comp_hml", ...
                    strcat(attribute_serial,".jpg")),'resolution',300)
                close(gcf2);
                if attribute==10
                    concatenate_images1(fullfile(save_folder,"check_ellipse","comp_hml"),5);
                end
            end
            de_hml_cell{lastPart_idx,attribute,1}=de_inter_hml;
            de_hml_cell{lastPart_idx,attribute,2}=de_intra_hml;

            mask = ~eye(size(de_intra_hml)); % ~eye 生成一个非对角线的逻辑矩阵
            de_hml_non_diag = de_inter_hml(mask); % 提取非对角线元素  

            de_hml_all(lastPart_idx,attribute,1)=mean(de_hml_non_diag(:));
            de_hml_all(lastPart_idx,attribute,2)=mean(mean(de_intra_hml));
            % 循环处理当前 light_level 的 i_para
            for i_para = 1:21
    
                % 绘制 source_file4 的 contour 或散点图 (新增部分)
                if exist('par_all4', 'var')&&~isempty(par_all4)
    
                    par = lab_par4pre(i_para, :);
    
                    % 否则，使用 '-' 线型绘制等高线图
                    check_data2 = par(4) + (-30:0.2:30);
                    check_data3 = par(5) + (-30:0.2:30);
                    [data2, data3] = meshgrid(check_data2, check_data3);
                    y = (1 ./ (1 + par(6) * exp(sqrt(par(1) * (data2 - par(4)).^2 + par(2) * (data3 - par(5)).^2 + ...
                        par(3) * (data2 - par(4)) .* (data3 - par(5)))))) .* ((par(1) * (data2 - par(4)).^2 + ...
                        par(2) * (data3 - par(5)).^2 + par(3) * (data2 - par(4)) .* (data3 - par(5))) >= 0);
                    light_level=floor((i_para-1)/ 7)+1;
                    % contour(data2, data3, y, [0.5, 1], 'Linewidth', 1, 'Color', colors(mod(i_para-1, 7)+1, :), ...
                    %     'DisplayName', picname_group(i_para), 'LineStyle', line_style{light_level});
                    % scatter(par(4), par(5), 30, plot_style{light_level}, 'filled', 'MarkerFaceColor', colors{light_level});
                    text(par(4), par(5), picname_group(i_para), 'FontSize', 8, 'VerticalAlignment', 'middle','Color',colors{light_level});
    
                end
                
                % 绘制 PMCC 点
                plot(labC_PMCCpre(1, 2), labC_PMCCpre(1, 3), 's', 'MarkerSize', 10, ...
                    'MarkerFaceColor', 'm', 'MarkerEdgeColor', 'm');
    
            end
            
            % 添加图例、标签和标题
            xlabel('{\ita*}');
            ylabel('{\itb*}');
            title(strcat(attribute_names(attribute)));
            
            % 设置坐标轴范围
            lim_max = 20;
            lim_min = 0;
            line([0, 0], [lim_min, lim_max], 'Color', 'k', 'LineStyle', '--'); % x=0
            line([lim_min, lim_max], [0, 0], 'Color', 'k', 'LineStyle', '--'); % y=0
            refline(1, 0); % 45 度线
            xlim([0, 20]);
            ylim([0, 20]);
    
                % 在图片右下角添加 de_CT_all(lastPart_idx,attribute,1) 和 de_attrs{attribute, 4} 的值
            text(18, 2, sprintf('dE inter CT: %.2f\ndE intra CT: %.2f', ...
            de_hml_all(lastPart_idx,attribute,1), de_hml_all(lastPart_idx,attribute,2)), ...
            'FontSize', 10, 'Color', 'k', 'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom');
            
            % 保存图像
            if ~exist(fullfile(save_folder), "dir")
                mkdir(fullfile(save_folder));
            end
            exportgraphics(gcf, fullfile(save_folder, strcat(attribute_serial, '.jpg')), 'Resolution', 300);
            close(gcf);
    
    end
    
    
    concatenate_images1(fullfile(save_folder ),5);
end

de_inter_mean=mean(mean(de_hml_all(:,:,1)));
de_intra_mean=mean(mean(de_hml_all(:,:,2)));


output_folder=fullfile("AlalyseResults",Dtype,"dE95centers");
if ~exist(output_folder,"dir")
    mkdir(output_folder);
end
save(fullfile(output_folder,"dE_hml.mat"), ...
    "de_hml_all","de_hml_cell","de_intra_mean","de_inter_mean");

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





% 绘制上三角形 + "model-group"
plot(2, 4.5, '^', 'MarkerSize', 8, 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k');
text(3.5, 4.5, 'high-luminance', 'FontSize', 8, 'VerticalAlignment', 'middle');


plot(2, 5, '<', 'MarkerSize', 8, 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k');
text(3.5, 5, 'mid-luminance', 'FontSize', 8, 'VerticalAlignment', 'middle');


plot(2, 5.5, 'v', 'MarkerSize', 8, 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k');
text(3.5, 5.5, 'low-luminance', 'FontSize', 8, 'VerticalAlignment', 'middle');
%PMCC
plot(14, 4, 's', 'MarkerSize', 8, 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k');
text(15, 4, 'PMCC', 'FontSize', 8, 'VerticalAlignment', 'middle');

line([10, 14], [4.5, 4.5], 'Color', 'k', 'LineWidth', 2, 'LineStyle', '-');
text(15, 4.5, 'high-luminance', 'FontSize', 8, 'VerticalAlignment', 'middle');


line([10, 14], [5, 5], 'Color', 'k', 'LineWidth', 2, 'LineStyle', '-.');
text(15, 5, 'mid-luminance', 'FontSize', 8, 'VerticalAlignment', 'middle');


line([10, 14], [5.5, 5.5], 'Color', 'k', 'LineWidth', 2, 'LineStyle', ':');
text(15, 5.5, 'low-luminance', 'FontSize', 8, 'VerticalAlignment', 'middle');


% 调整图窗大小以确保所有内容可见
set(gcf, 'Position', [100, 100, 1200, 600]); % 设置图窗宽度为 1200，高度为 400

% 保存图例图
if ~exist(fullfile(save_folder, "legend"), "dir")
    mkdir(fullfile(save_folder, "legend"));
end
exportgraphics(gcf, fullfile(save_folder, "legend", strcat(lastPart, '_lights_legend.jpg')), 'Resolution', 300);

close(gcf);