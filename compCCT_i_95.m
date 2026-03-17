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

lastParts = {'female78i', 'female41i', 'femalevivoi', 'male59i', 'male39i', 'malevivoi'};

for lastPart_idx = 1:length(lastParts)
    lastPart = lastParts{lastPart_idx};

    Dtype='summer';
    save_folder = fullfile("ellip_pic\ellipse", lastPart, Dtype,"comp_CCT","combined_light_contours");
    
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
    colors = hsv(7); % 使用 hsv 色图生成 7 种颜色
    % colors={'r','g','b'};
    
    
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
            figure(1);
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
    
                centers_hml{1,1}=centers_pre(1:7,:);%h
                centers_hml{1,2}=centers_pre(15:21,:);%m
                centers_hml{1,3}=centers_pre(8:15,:);%l
                gcf2=figure(2);
                hold on;
                for i_CT=1:7
                    center_CT_temp=[centers_hml{1,1}(i_CT,:); ...
                        centers_hml{1,2}(i_CT,:);...
                        centers_hml{1,3}(i_CT,:)];
                    centers_CT{1,i_CT}=center_CT_temp;
                    %拟合95%椭圆
                    [center_fit{1,i_CT},mu{1,i_CT},chi2_val{1,i_CT},List{1,i_CT}] =...
                        fit95ellip_my(centers_CT{1,i_CT}, 0.05, 2);
                        % 在 centers_CT{1,i_CT} 的位置上添加 CT(i_CT) 的文本标注
                    text(center_fit{1,i_CT}(1, 2)+0.2, center_fit{1,i_CT}(1, 3), ...
                        num2str(CT(i_CT)), 'FontSize', 8, 'Color', 'k');
                    %画椭圆
                    % contour95ellipV(center_fit{1,i_CT},mu{1,i_CT},centers_CT{1,i_CT},chi2_val);
                    for i_hml=1:3
                        de_intra_CT(i_hml,i_CT)=deltaE2000(centers_hml{1,i_hml}(i_CT,:),center_fit{1,i_CT});
                    end
                end

                
                for i_col=1:7
                    for i_row=1:7
                        de_inter_CT(i_col,i_row)=deltaE2000(center_fit{1,i_col},center_fit{1,i_row});
                    end
                end
                output_folder=fullfile("AlalyseResults",Dtype,lastPart, ...
                    "all",attribute_serial,"ellipPara95");
                if ~exist(output_folder,"dir")
                    mkdir(output_folder);
                end
                save(fullfile(output_folder,"CT.mat"), ...
                    "center_fit","mu","chi2_val","List");

                if ~exist(fullfile(save_folder,"check_ellipse","comp_CT"),"dir")
                    mkdir(fullfile(save_folder,"check_ellipse","comp_CT"));
                end
                exportgraphics(gcf,fullfile(save_folder,"check_ellipse","comp_CT", ...
                    strcat(attribute_serial,".jpg")),'resolution',300)
                close(gcf2);
            end
            de_CT_cell{lastPart_idx,attribute,1}=de_inter_CT;
            de_CT_cell{lastPart_idx,attribute,2}=de_intra_CT;

            mask = ~eye(size(de_intra_CT)); % ~eye 生成一个非对角线的逻辑矩阵
            de_CT_non_diag = de_inter_CT(mask); % 提取非对角线元素  

            de_CT_all(lastPart_idx,attribute,1)=mean(de_CT_non_diag(:));
            de_CT_all(lastPart_idx,attribute,2)=mean(mean(de_intra_CT));

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
                    text(par(4), par(5), picname_group(i_para), 'FontSize', 8, ...
                        'VerticalAlignment', 'middle', 'Color', colors(mod(i_para-1,7)+1, :));
    
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
            de_CT_all(lastPart_idx,attribute,1), de_CT_all(lastPart_idx,attribute,2)), ...
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

de_intra_mean=mean(mean(de_CT_all(:,:,1)));
de_inter_mean=mean(mean(de_CT_all(:,:,2)));

output_folder=fullfile("AlalyseResults",Dtype,"dE95centers");
if ~exist(output_folder,"dir")
    mkdir(output_folder);
end
save(fullfile(output_folder,"dE.mat"), ...
    "de_CT_all","de_CT_cell","de_intra_mean","de_inter_mean");

%%
% 初始化汇总表格
summary_table = table();

% 循环处理每个 lastPart 和 attribute
for lastPart_idx = 1:length(lastParts)
    lastPart = lastParts{lastPart_idx};
    
    for attribute = attributes
        % 获取当前 lastPart 和 attribute 的 de_CT_non_diag 和 de_intra_CT
        de_CT_non_diag = de_CT_cell{lastPart_idx, attribute, 1};
        de_intra_CT = de_CT_cell{lastPart_idx, attribute, 2};
        
        % 计算 de_CT_non_diag 的统计量
        de_CT_non_diag_max = max(de_CT_non_diag(:));
        de_CT_non_diag_min = min(de_CT_non_diag(:));
        de_CT_non_diag_mean = mean(de_CT_non_diag(:));
        de_CT_non_diag_std = std(de_CT_non_diag(:));
        
        % 计算 de_intra_CT 的统计量
        de_intra_CT_max = max(de_intra_CT(:));
        de_intra_CT_min = min(de_intra_CT(:));
        de_intra_CT_mean = mean(de_intra_CT(:));
        de_intra_CT_std = std(de_intra_CT(:));
        
        % 创建当前 lastPart 和 attribute 的统计行
        current_row = table(lastPart, attribute, ...
            de_CT_non_diag_max, de_CT_non_diag_min, de_CT_non_diag_mean, de_CT_non_diag_std, ...
            de_intra_CT_max, de_intra_CT_min, de_intra_CT_mean, de_intra_CT_std, ...
            'VariableNames', {'lastPart', 'attribute', ...
            'de_CT_non_diag_max', 'de_CT_non_diag_min', 'de_CT_non_diag_mean', 'de_CT_non_diag_std', ...
            'de_intra_CT_max', 'de_intra_CT_min', 'de_intra_CT_mean', 'de_intra_CT_std'});
        
        % 将当前行添加到汇总表格中
        summary_table = [summary_table; current_row];
    end
end

% 保存汇总表格到 Excel 文件
output_folder = fullfile("AlalyseResults", Dtype, "dE95centers");
if ~exist(output_folder, "dir")
    mkdir(output_folder);
end
output_file = fullfile(output_folder, "summary_statistics.xlsx");
writetable(summary_table, output_file);

disp(['汇总表格已保存到: ', output_file]);
