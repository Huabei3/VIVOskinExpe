close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量

%% 定义所有需要处理的 attribute
attributes = [1, 2, 3, 4, 5, 6,7, 8, 9,10];

attribute_names_new = ["Preference", "Attractiveness", "Feminine", "Cooperative", ...
    "Youth", "Healthy", "Fidelity","Harmony", "Fair", "Ruddy"];
wd65_64 = [94.811, 100.00, 107.304];
nations=["AS","CA","SA","AF"];
lastParts = {'f04i', 'f05i', 'f06i', ...
'm04i', 'm05i', 'm06i'};
% lastParts = {'f04r', 'f05r', 'f06r', ...
% 'm04r', 'm05r', 'm06r'};
nation=nations(1);
if contains(lastParts{1},'i')
    iOr='i';n_para=21;
    picname_group = ["h3k", "h4k", "h5k", "h6k", "hd65", "h7k", "h8k",...
    "m3k", "m4k", "m5k", "m6k", "md65", "m7k", "m8k",...
     "l3k", "l4k", "l5k", "l6k", "ld65", "l7k", "l8k"];
    idx_ranges=[5,12,19];
elseif contains(lastParts{1},'r')
    iOr='r';n_para=14;
    picname_group = ["rs01","rs02","rs03","rs04","rs05","rs06","rs07", ...
                     "rs08","rs09","rs10","rs11","rs12","rs13","rs14"];
    idx_ranges=1:14;
end

Dtype = 'VIVO_CAT16';obs_type="non_model";
obs_types=["non_model","model_group","model","all"];
obs_types_new=["stranger","acquaintance","self","all"];
% 定义色环上的 7 种颜色
hsvColors = zeros(length(lastParts), 3);
hsvColors(:, 1) = linspace(0, 1, length(lastParts));
hsvColors(:, 2) = 0.7;
hsvColors(:, 3) = 0.7;
colors = hsv2rgb(hsvColors);

for i_obstype=1:1
    save_folder = fullfile("ellip_pic\ellipse1", ...
        Dtype,strcat(nation,iOr,obs_type),"model");
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
        average_file = fullfile("aveSkin", lastPart_new, "autoNhand_scaleoverLUT.mat");
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
                par_all4(1:n_para,1:6)=NaN;
            end
            par_inds(:,:,lastPart_idx,attribute)=par_all4;
        end
    end
    par_inds_mean=nanmean(par_inds,3);
    average=nanmean(average_inds,3);
    %a-b
    lim_min_x=min(min(min(par_inds(idx_ranges,4,:,:))))-1;
    lim_max_x=max(max(max(par_inds(idx_ranges,4,:,:))))+1;
    lim_min_y=min(min(min(par_inds(idx_ranges,5,:,:))))-1;
    lim_max_y=max(max(max(par_inds(idx_ranges,5,:,:))))+1;
    
    
    condition = (par_inds(:, 5, :, :) < 2); % 逻辑条件
    indices = find(condition); % 找到满足条件的线性索引
    [dim1, dim3, dim4] = ind2sub([2, 6, 10], indices);
    dim2 = 5 * ones(size(dim1));
    coordinates = [dim1, dim2, dim3, dim4];
    values = par_inds(condition);
    
    %% 循环处理每个 attribute
    plot_style={'^','v','o'};
    for attribute = [1]
    % for attribute = attributes
    
        attribute_serial = strcat(sprintf("%02d", attribute), attribute_names_new(attribute));
    

        for i_para = 1:size(par_inds_mean,1)
            % 计算 labC_PMCCpre
            if average(i_para, 1) <= 60
                C_pre = 6.7421 * log(average(i_para, 1)) - 9.9816; % 亮度实验
            else
                C_pre = 6.7421 * log(60) - 9.9816; % 亮度实验
            end
            labC_PMCCpre(i_para, 1) = average(i_para, 1);
            labC_PMCCpre(i_para, 2:3) = lab_PMCC(1, 2:3) ./ labC_PMCC(1, 4) .* C_pre;
            labC_PMCCpre(i_para, 4) = C_pre;
        end
        for idx = idx_ranges
            figure();
            hold on;
            set(gcf, 'Color', 'white');
            for lastPart_idx = 1:length(lastParts)
                lastPart = lastParts{lastPart_idx};
                lastPart_new=gen_lastPart_new(lastPart);
                lastPart_new=char(lastPart_new);
                par_all_used=par_inds(:,:,lastPart_idx,attribute);
                
                % 绘制 source_file_used 的 contour 或散点图 (新增部分)
                if exist('par_all_used', 'var')&&~isempty(par_all_used)
                    par = par_all_used(idx, :);
                    text(par(:,4),par(:,5),  lastPart_new(1:end-1), ...
                        'FontSize', 7, 'VerticalAlignment', 'middle', ...
                        'Color',colors(lastPart_idx, :));
                    % scatter(par(:,4),par(:,5),  30, ...
                    %     plot_style{idx}, 'filled', ...
                    %     'MarkerFaceColor', colors(idx, :));
                end
            end
            % 绘制 PMCC 点
            plot(labC_PMCCpre(idx, 2), labC_PMCCpre(idx, 3), 's', 'MarkerSize', 10, ...
                'MarkerFaceColor', 'm', 'MarkerEdgeColor', 'm');
            text(labC_PMCCpre(idx, 2), labC_PMCCpre(idx, 3),'PMCC', ...
                'FontSize', 8, 'VerticalAlignment', 'middle');
                    % 添加图例、标签和标题
            xlabel('{\ita*}');
            ylabel('{\itb*}');
            title(strcat(obs_types_new(i_obstype),attribute_names_new(attribute),lastPart));
        
            % 设置坐标轴范围
            x = linspace(0, 25, 100); % 从 -10 到 10，生成 100 个点
            plot(x, x); % 'r-' 表示红色实线
            axis equal;
            xlim([lim_min_x, lim_max_x]);
            ylim([lim_min_y, lim_max_y]);
            output_folder=fullfile(save_folder, attribute_serial);
            if ~exist(output_folder,"dir")
                mkdir(output_folder);
            end
            exportgraphics(gcf, fullfile(output_folder, ...
                strcat(picname_group(idx),  '.jpg')), 'Resolution', 300);
            close(gcf);
        end

    concatenate_images1(fullfile(output_folder) ,7);
    end
    
end

