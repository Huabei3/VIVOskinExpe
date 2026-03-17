close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量

%% 定义所有需要处理的 attribute
attributes = [1, 2, 3, 4, 5, 6,7, 8, 9,10];
attribute_names = ["Preference", "Attractiveness", "Feminine", "Cooperative", ...
    "Youth", "Healthy", "Precise reproduction",...
    "suit the environment or not", "white-skinned", "ruddyadd"];
attribute_names_new = ["Preference", "Attractiveness", "Feminine", "Cooperative", ...
    "Youth", "Healthy", "Fidelity","Harmony", "Fair", "Ruddy"];

obs_types=["non_model","model_group","model","all"];
obs_types_new=["stranger","acquaintance","self","all"];
%---------------------------------------


nations=["AS","CA","SA","AF"];
% lastParts = {'f04iadd', 'f05iadd', 'f06iadd', ...
% 'm04iadd', 'm05iadd', 'm06iadd'};nation=nations(1);
lastParts = {'f04i', 'f05i', 'f06i', ...
'm04i', 'm05i', 'm06i'};nation=nations(1);

% lastParts = {'f01i', 'f02i', 'f03i', ...
% 'm01i', 'm02i', 'm03i'};nation=nations(2);

% lastParts = {'f07i', 'f08i', ...
% 'm07i', 'm08i'};nation=nations(3);
% 
% lastParts = {'f09i', 'f10i', ...
% 'm09i', 'm10i'};nation=nations(4);
%--------------------------------
% lastParts = {'f04r', 'f05r', 'f06r', ...
% 'm04r', 'm05r', 'm06r'};nation=nations(1);

% lastParts = {'f04r', 'f05r', 'f06r', ...
% 'm04r', 'm05r', 'm06r'};nation=nations(1);

% lastParts = {'f04r', 'f05r', 'f06r', ...
% 'm04r', 'm05r', 'm06r'};nation=nations(1);

% lastParts = {'f04r', 'f05r', 'f06r', ...
% 'm04r', 'm05r', 'm06r'};nation=nations(1);
%----------------------------------



if contains(lastParts{1},'i')
    iOr='i';n_para=21;n_used=7;
    picname_group = ["h3k", "h4k", "h5k", "h6k", "hd65", "h7k", "h8k",...
    "m3k", "m4k", "m5k", "m6k", "md65", "m7k", "m8k",...
     "l3k", "l4k", "l5k", "l6k", "ld65", "l7k", "l8k"];
    load("optmizedD\light_i.mat","CCT_light","XYZ_light");
    CT=CCT_light;
elseif contains(lastParts{1},'r')
    iOr='r';n_para=14;n_used=14;
    picname_group = ["rs01","rs02","rs03","rs04","rs05","rs06","rs07", ...
                     "rs08","rs09","rs10","rs11","rs12","rs13","rs14"];
    model_tcp_mean_inds=[];
    for i_lastPart=1:length(lastParts)
        load(fullfile("..\renderCode\light_r\model_tcp", ...
            strcat(lastParts{i_lastPart}(1:end-1),".mat")), ...
        "model_tcp_mean");
        model_tcp_mean_inds=[model_tcp_mean_inds,model_tcp_mean];
    end
    CT=mean(model_tcp_mean_inds,2);
end

wd65_64 = [94.811, 100.00, 107.304];
lab_PMCC = [62.11, 18.96, 19.76];
labC_PMCC = [lab_PMCC, sqrt(lab_PMCC(1, 2)^2 + lab_PMCC(1, 3)^2)];

Dtype='VIVO_spl';obs_type="non_model";
for i_obstype=1:1
    save_folder = fullfile("ellip_pic\ellipse1", ...
        Dtype,strcat(nation,iOr,obs_type),"CT");
    % 创建保存文件夹
    if ~exist(save_folder, "dir")
        mkdir(save_folder);
    end
    for lastPart_idx = 1:length(lastParts)
        lastPart = lastParts{lastPart_idx};
        model = lastPart(1:end-1);
        
        [lastPart1, model1] = gen_lastPart1(lastPart);
        lastPart_new=gen_lastPart_new(lastPart1);
        disp([lastPart,lastPart_new])
        average_file = fullfile("aveSkin", strrep(lastPart_new,"add",""), "autoNhand_scaleoverLUT.mat");
        average_data = load(average_file);
        average_inds(:,:,lastPart_idx) = average_data.average_lab_all(:, 1:3);
    
        % for attribute = attributes
        for attribute = [1]
            fprintf('Processing attribute: %d\n', attribute);
            
            % 生成 attribute_serial
            attribute_serial = strcat(sprintf("%02d", attribute), attribute_names_new(attribute));
        
            source_file_used = fullfile('AnalyseResults1', Dtype, lastPart, ...
                obs_types(i_obstype), attribute_serial, ...
                'ellipPara', 'fitRes.mat');
            
            % 加载数据
            par_all4=[];
            if exist(source_file_used, 'file')
                load(source_file_used);
                par_all4 = par_all;
            else
                par_all4(1:n_para,1:6)=NaN;
            end
            par_inds(:,:,lastPart_idx,attribute)=par_all4;
        end
    end
    average=nanmean(average_inds,3);
    par_all4=nanmean(par_inds,3);
    
    %% 循环处理每个 attribute
    lim_min_x=min(min(min(par_all4(1:n_used,4,:,:))));
    lim_max_x=max(max(max(par_all4(1:n_used,4,:,:))));
    lim_min_y=min(min(min(par_all4(1:n_used,5,:,:))));
    lim_max_y=max(max(max(par_all4(1:n_used,5,:,:))));
    
    % 确定CT值范围，添加安全扩展以确保颜色分散
    CT_range = CT(1:n_used);
    CT_min = min(CT_range);
    CT_max = max(CT_range);
    for attribute = [1]
    % for attribute = attributes
        figure();
        hold on;
        set(gcf, 'Color', 'white');
        
        % 创建颜色映射（从蓝色到红色）
        cmap = colormap('jet');
        cmap = flipud(cmap);  % 翻转颜色映射，让红色对应低值，蓝色对应高值
        cmap=cmap*0.7;
        for i_para = 1:n_used
            % 计算 labC_PMCCpre
            if average(i_para, 1) <= 60
                C_pre = 6.7421 * log(average(i_para, 1)) - 9.9816;
            else
                C_pre = 6.7421 * log(60) - 9.9816;
            end
            labC_PMCCpre(i_para, 1) = average(i_para, 1);
            labC_PMCCpre(i_para, 2:3) = lab_PMCC(1, 2:3) ./ labC_PMCC(1, 4) .* C_pre;
            labC_PMCCpre(i_para, 4) = C_pre;
    
            % 绘制散点，颜色由CT值决定
            if exist('par_all4', 'var') && ~isempty(par_all4)
                par = par_all4(i_para, :,1,attribute);
                
                % 根据CT值映射颜色
                ct_norm = (CT(i_para) - CT_min) / (CT_max - CT_min);
                color_idx = round(ct_norm * (size(cmap, 1) - 1)) + 1;
                point_color = cmap(color_idx, :);
                
                % text(par(4)+1, par(5), sprintf("%04d",CT(i_para)), ...
                %     'FontSize', 6, 'VerticalAlignment', 'middle');
                text(par(4), par(5), picname_group(i_para), ...
                    'FontSize', 8, 'VerticalAlignment', 'middle', ...
                    'Color',point_color);
                % scatter(par(4), par(5), 30, 'o', 'filled', ...
                %     'MarkerFaceColor', point_color, 'MarkerEdgeColor', point_color);
            end         
        end
        
        % 绘制 PMCC 点
        plot(mean(labC_PMCCpre(1:n_used, 2)), mean(labC_PMCCpre(1:n_used, 3)), 's', 'MarkerSize', 10, ...
            'MarkerFaceColor', 'm', 'MarkerEdgeColor', 'm');
        text(mean(labC_PMCCpre(1:n_used, 2)), mean(labC_PMCCpre(1:n_used, 3)),'PMCC', ...
            'FontSize', 8, 'VerticalAlignment', 'middle');
        
        % 添加图例、标签和标题
        xlabel('{\ita*}');
        ylabel('{\itb*}');
        title(strcat(obs_types_new(i_obstype),attribute_names_new(attribute),'a-b'));
        
        % 添加颜色条
        cb = colorbar;
        cb.Label.String = 'CT (K)';
        caxis([CT_min, CT_max]);  % 这是关键！设置颜色轴的数据范围        
        colormap(cmap);
  
        
        % 设置坐标轴范围
        x = linspace(0, 25, 100);
        plot(x, x);
        axis equal;      
        xlim([lim_min_x, lim_max_x]);
        ylim([lim_min_y, lim_max_y]);
        
        % 保存图像
        attribute_serial = strcat(sprintf("%02d", attribute), attribute_names_new(attribute));
        if ~exist(fullfile(save_folder, 'a_b'),"dir")
            mkdir(fullfile(save_folder, 'a_b'));
        end
        exportgraphics(gcf, fullfile(save_folder, 'a_b',strcat(attribute_serial,  'a-b.jpg')), 'Resolution', 300);
        close(gcf);
    end
    concatenate_images1(fullfile(save_folder, 'a_b') ,5);
end