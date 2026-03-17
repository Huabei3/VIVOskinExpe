close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量

%% 定义所有需要处理的 attribute
attributes = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
attribute_names_new = ["Preference", "Attractiveness", "Feminine", "Cooperative", ...
    "Youth", "Healthy", "Fidelity","Harmony", "Fair", "Ruddy"];

% lastParts = {'f04i', 'f05i', 'f06i', 'm04i', 'm05i', 'm06i',...
% 'f01i', 'f02i', 'f03i', 'm01i', 'm02i', 'm03i',...
% 'f07i', 'f08i','m07i', 'm08i',...
% 'f09i', 'f10i','m09i', 'm10i'};nation="all";n_para = 21;iOr='i';
%-------------rs----------------
lastParts = {'f04r', 'f05r', 'f06r', 'm04r', 'm05r', 'm06r',...
'f01r', 'f02r', 'f03r', 'm01r', 'm02r', 'm03r',...
'f07r', 'f08r','m07r', 'm08r',...
'f09r', 'f10r','m09r', 'm10r'};n_para = 14;iOr='r';

nations=["AS","CA","SA","AF"];
nation="all";
if contains(lastParts{1},'i')
    iOr='i';
    picname_group = ["h3k", "h4k", "h5k", "h6k", "hd65", "h7k", "h8k",...
    "m3k", "m4k", "m5k", "m6k", "md65", "m7k", "m8k",...
     "l3k", "l4k", "l5k", "l6k", "ld65", "l7k", "l8k"];
elseif contains(lastParts{1},'r')
    iOr='r';
    picname_group = ["rs01","rs02","rs03","rs04","rs05","rs06","rs07", ...
                     "rs08","rs09","rs10","rs11","rs12","rs13","rs14"];
end

Dtype = 'efit2';
 obs_types = ["non_model", "model_group", "model"];
for i_obs = 1:length(obs_types)
    obs_type = obs_types(i_obs);
    save_folder = fullfile("AnalyseResults1", Dtype,"sum_list",obs_type );
    
    % 创建保存文件夹
    if ~exist(save_folder, "dir")
        mkdir(save_folder);
    end
    

    
    % 初始化用于存储PCA结果的变量
    pca_results = cell(length(lastParts), length(picname_group));
    
    %% 循环处理每个 lastPart
    for i_lastPart = 1:length(lastParts)
        lastPart = lastParts{i_lastPart};
        lastPart=strrep(lastPart,"add","");
    
            % 循环处理每个 attribute
        % 初始化 y 用于存储每个 attribute 的 y 值
        y = cell(length(attributes), 1);
        for attribute = attributes
            % 生成 attribute_serial
            attribute_serial = strcat(sprintf("%02d", attribute), attribute_names_new(attribute));
            if attribute==7
                obs_type_used="model_group";
            else
                obs_type_used=obs_type;
            end
            source_file4 = fullfile('AnalyseResults1', Dtype, lastPart, ...
                obs_type_used, attribute_serial, 'ellipPara', 'fitRes.mat');
            y{attribute}=[];
            % 循环处理每个 i_para（即每个 light）
    
            if exist(source_file4, 'file')
                load(source_file4);
                
                for i_para = 1:length(picname_group)
                    labNgroup_file=fullfile("AnalyseResults1",Dtype,lastPart,obs_type, ...
                        attribute_serial,"labNscore", ...
                        strcat("labNscore_group",lastPart,picname_group(i_para),".mat"));
                    if exist(labNgroup_file)
                        MSVNlab = load(labNgroup_file);
                        data2{i_para}=MSVNlab.lab_group(:,2);
                        data3{i_para}=MSVNlab.lab_group(:,3);
                        picname_check_temp{i_para,1}=picname_group(i_para);
                        picname_check_temp{i_para,2}=strcat(lastPart,picname_group(i_para));
                        picname_check{i_lastPart}=picname_check_temp;
                        par = par_all(i_para, :);
                        % 计算 y 值
                        y_temp = (1 ./ (1 + par(6) * exp(sqrt(par(1) * (data2{i_para} - par(4)).^2 + par(2) * (data3{i_para} - par(5)).^2 + ...
                            par(3) * (data2{i_para} - par(4)) .* (data3{i_para} - par(5)))))) .* ((par(1) * (data2{i_para} - par(4)).^2 + ...
                            par(2) * (data3{i_para} - par(5)).^2 + par(3) * (data2{i_para} - par(4)) .* (data3{i_para} - par(5))) >= 0);
                        
                    else
                        y_temp=NaN([33,1]);
                    end
                        y{attribute}=[y{attribute};y_temp];
                end
            end
        end
            % 计算 corr_attr
        corr_attr = zeros(length(attributes), length(attributes));
        for i_attr = attributes
            for j_attr = attributes
                if isempty(y{i_attr}) || isempty(y{j_attr})
                    corr_attr(i_attr, j_attr) = NaN;
                elseif std(y{i_attr}(:)) == 0 || std(y{j_attr}(:)) == 0
                    corr_attr(i_attr, j_attr) = NaN;
                else
                    corr_attr(i_attr, j_attr) = corr(y{i_attr}(:), y{j_attr}(:));
                end
            end
        end
    
    
    
        % 将当前 lastPart 的 corr_attr 存储到 all_corr_attr
        all_corr_attr(:,:,i_lastPart) = corr_attr;
        
        % PCA分析：以十个y{attribute}为十个维度
        % 构建10维数据矩阵
        data_matrix = [];
        for attribute = 1:length(attributes)
            if ~isempty(y{attribute})
                data_matrix = [data_matrix, y{attribute}];
            else
                % 如果某个属性的数据为空，则填充NaN
                data_matrix = [data_matrix, NaN(size(y{1}))];
            end
        end
        
        % 检查数据有效性
        if ~isempty(data_matrix) && size(data_matrix, 2) == length(attributes)
            % 移除包含NaN的行
            valid_cols = ~all(isnan(data_matrix), 1);
            valid_data = data_matrix(:,valid_cols);
            valid_rows = ~all(isnan(valid_data), 2);
            valid_data = valid_data(valid_rows,:);
            
            % 仅当有足够的有效数据时进行PCA
            if size(valid_data, 1) > length(attributes)
                % 执行PCA
                [coeff, score, latent, ~, explained] = pca(valid_data);
                
                % 存储PCA结果
                pca_results{i_lastPart, i_para} = struct(...
                    'coeff', coeff, ...
                    'score', score, ...
                    'latent', latent,...
                    'explained', explained,...
                    'data', valid_data);
                
                % PCA结果可视化
                figure('Position', [100, 100, 1200, 500]);
                
                % 第一主成分与第二主成分的散点图
                subplot(1, 2, 1);
                scatter(score(:,1), score(:,2), 30, 'filled');
                title(sprintf('PCA结果: %s - %s', lastPart, picname_group(i_para)));
                xlabel(['主成分1 (', num2str(explained(1), '%.1f'), '%)']);
                ylabel(['主成分2 (', num2str(explained(2), '%.1f'), '%)']);
                grid on;
                
                % 解释方差比例图
                subplot(1, 2, 2);
                bar(1:length(explained), explained);
                title('各主成分的解释方差比例');
                xlabel('主成分');
                ylabel('解释方差比例 (%)');
                xticks(1:length(explained));
                grid on;
                
                % 保存PCA结果图
                pca_img_folder = fullfile(save_folder, 'PCA_images');
                if ~exist(pca_img_folder, 'dir')
                    mkdir(pca_img_folder);
                end
                saveas(gcf, fullfile(pca_img_folder, sprintf('PCA_%s_%s.jpg', lastPart)));
                close(gcf);
            end
        end
    
    end

    excel_file = fullfile(save_folder,strcat(iOr,obs_type, 'corr_attr_summary.xlsx'));
    for i_lastPart = 1:length(lastParts)
        sheet_name = lastParts{i_lastPart};
        writematrix(all_corr_attr(:,:,i_lastPart), excel_file, 'Sheet', sheet_name);
    end
    corr_attr_mean=nanmean(all_corr_attr,3);
    writematrix(corr_attr_mean, excel_file, 'Sheet', "mean");
    
    
    %% 保存PCA结果
    pca_save_folder = fullfile(save_folder, 'PCA_results');
    if ~exist(pca_save_folder, 'dir')
        mkdir(pca_save_folder);
    end
    
    % 将所有PCA结果保存到一个mat文件中
    save(fullfile(pca_save_folder, 'all_pca_results.mat'), 'pca_results');
    
    % 创建PCA结果汇总表
    pca_summary = cell(length(lastParts) * length(picname_group) + 1, 5);
    pca_summary(1, :) = {'LastPart',  'PC1_Explained', 'PC2_Explained', 'PC3_Explained', 'Total_Explained'};
    
    idx = 2;
    for i_lastPart = 1:length(lastParts)
        for i_para = 1:length(picname_group)
            if ~isempty(pca_results{i_lastPart, i_para})
                pca_data = pca_results{i_lastPart, i_para};
                pca_summary(idx, :) = {
                    lastParts{i_lastPart}, ...
                    pca_data.explained(1),...
                    pca_data.explained(2),...
                    pca_data.explained(3),...
                    sum(pca_data.explained(1:min(3, length(pca_data.explained))))
                };
                idx = idx + 1;
            end
        end
    end
    
    % 保存PCA结果汇总表
    writecell(pca_summary, fullfile(pca_save_folder, strcat(iOr,'pca_summary.csv')));
    disp("Processing complete.");
end

