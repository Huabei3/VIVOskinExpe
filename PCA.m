close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量

%% 定义所有需要处理的 attribute
attributes = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
attribute_names_new = ["Preference", "Attractiveness", "Feminine", "Cooperative", ...
    "Youth", "Healthy", "Fidelity","Harmony", "Fair", "Ruddy"];

lastParts = {'f04i', 'f05i', 'f06i', 'm04i', 'm05i', 'm06i',...
'f01i', 'f02i', 'f03i', 'm01i', 'm02i', 'm03i',...
'f07i', 'f08i','m07i', 'm08i',...
'f09i', 'f10i','m09i', 'm10i'};nation="all";n_para = 21;iOr='i';
%-------------rs----------------
% lastParts = {'f04r', 'f05r', 'f06r', 'm04r', 'm05r', 'm06r', ...
% 'f01r', 'f02r', 'f03r', 'm01r', 'm02r', 'm03r', ...
% 'f07r', 'f08r','m07r', 'm08r', ...
% 'f09r', 'f10r','m09r', 'm10r'};n_para = 14; iOr = 'r';

nations = ["AS","CA","SA","AF"];
nations_new=["Asian","Caucasian","South Asian","African"];
% nation = "all";
if contains(lastParts{1}, 'i')
    iOr = 'i';
    picname_group = ["h3k", "h4k", "h5k", "h6k", "hd65", "h7k", "h8k",...
    "m3k", "m4k", "m5k", "m6k", "md65", "m7k", "m8k",...
     "l3k", "l4k", "l5k", "l6k", "ld65", "l7k", "l8k"];
elseif contains(lastParts{1}, 'r')
    iOr = 'r';
    picname_group = ["rs01","rs02","rs03","rs04","rs05","rs06","rs07", ...
                     "rs08","rs09","rs10","rs11","rs12","rs13","rs14"];
end

nation_indices = cell(5, 1); % 5个人种（包括"all"）
% AS (Asian): f04i, f05i, f06i, m04i, m05i, m06i (索引1-6)
nation_indices{1} = 1:6;
% CA (Caucasian): f01i, f02i, f03i, m01i, m02i, m03i (索引7-12)
nation_indices{2} = 7:12;
% SA (South Asian): f07i, f08i, m07i, m08i (索引13-16)
nation_indices{3} = 13:16;
% AF (African): f09i, f10i, m09i, m10i (索引17-20)
nation_indices{4} = 17:20;
% all: 所有索引 (索引1-20)
nation_indices{5} = 1:20;

Dtype = 'efit2';
% obs_types = ["model_group", "model"];
obs_types = ["non_model", "model_group", "model"];
for i_obs = 1:length(obs_types)
    obs_type = obs_types(i_obs);
    save_folder = fullfile("AnalyseResults1", Dtype, "sum_list");

    % 创建保存文件夹
    if ~exist(save_folder, "dir")
        mkdir(save_folder);
    end

    %% 初始化用于存储PCA结果的变量
    pca_results = cell(length(nations), 1);

    %% 循环处理每个 nation
    for i_nation = 1:length(nations)
        current_nation_indices = nation_indices{i_nation};

        % 初始化 y 用于存储每个 attribute 的 y 值
        y = cell(length(attributes), 1);
        for attribute = attributes
            % 生成 attribute_serial
            attribute_serial = strcat(sprintf("%02d", attribute), attribute_names_new(attribute));
            if attribute == 7
                obs_type_used = "model_group";
            else
                obs_type_used = obs_type;
            end

            % 遍历当前 nation 下的所有 lastPart
            y{attribute} = [];
            for i_lastPart = current_nation_indices
                lastPart = lastParts{i_lastPart};
                lastPart = strrep(lastPart, "add", "");              

                for i_para = 1:length(picname_group)
                    labNgroup_file = fullfile("AnalyseResults1", Dtype, lastPart, obs_type, ...
                        attribute_serial, "labNscore", ...
                        strcat("labNscore_group", lastPart, picname_group(i_para), ".mat"));
                    if exist(labNgroup_file)
                        MSVNlab = load(labNgroup_file);
                        y_temp = MSVNlab.MSV_group;  
                    else
                        y_temp = NaN([33,1]);
                    end
                    y{attribute} = [y{attribute}; y_temp];
                end
            end
        end

        % PCA分析：以十个y{attribute}为十个维度
        % 构建10维数据矩阵
        data_matrix = []; pcn = [];
        for attribute = 1:length(attributes)
            if ~isempty(y{attribute})
                data_matrix = [data_matrix, y{attribute}];
            else
                % 如果某个属性的数据为空，则填充NaN
                data_matrix = [data_matrix, NaN(size(y{1}))];
            end
            attribute_serial = strcat(sprintf("%02d", attribute), attribute_names_new(attribute));
            pcn = [pcn; attribute_serial];
        end
        

        % 检查数据有效性
        if ~isempty(data_matrix) && size(data_matrix, 2) == length(attributes)
            % 移除包含NaN的行
            valid_cols = ~all(isnan(data_matrix), 1);
            valid_data = data_matrix(:, valid_cols);
            valid_rows = ~all(isnan(valid_data), 2);
            valid_data = valid_data(valid_rows, :);
            valid_data = fillmissing(valid_data, 'nearest');
            pcn = pcn(valid_cols, :);
            

            % 仅当有足够的有效数据时进行PCA
            if size(valid_data, 1) > length(attributes)
                % 执行PCA
                [coeff, score, latent, ~, explained] = pca(valid_data);

                % 存储PCA结果
                pca_results{i_nation} = struct(...
                    'coeff', coeff, ...
                    'score', score, ...
                    'latent', latent, ...
                    'explained', explained, ...
                    'data', valid_data);

                % 新增字段：记录最大主成分占比的 attribute_serial
                [~, maxPC] = max(abs(coeff), [], 1);    % 每个样本最大主成分所在的列索引
                max_attribute = pcn(maxPC);  % 记录最大主成分对应的 attribute_serial
                pcn_nations{i_nation}=pcn(maxPC);

                % 在pca_results中新增一列保存最大主成分的 attribute_serial
                pca_results{i_nation}.max_attribute = max_attribute;

                % PCA结果可视化
                figure('Position', [100, 100, 1200, 500]);

                % 第一主成分与第二主成分的散点图
                subplot(1, 2, 1);
                scatter(score(:,1), score(:,2), 30, 'filled');
                title(sprintf('PCA结果: %s', nations(i_nation)));
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
                pca_img_folder = fullfile(save_folder, 'PCA_images',obs_type);
                if ~exist(pca_img_folder, 'dir')
                    mkdir(pca_img_folder);
                end
                saveas(gcf, fullfile(pca_img_folder, sprintf('PCA_%s.jpg', nations(i_nation))));
                close(gcf);
            end
        end
    end

    %% 保存PCA结果
    pca_save_folder = fullfile(save_folder, 'PCA_results',obs_type);
    if ~exist(pca_save_folder, 'dir')
        mkdir(pca_save_folder);
    end
    
    % 将所有PCA结果保存到一个mat文件中
    save(fullfile(pca_save_folder, 'all_pca_results.mat'), 'pca_results');
    
    % 创建PCA结果汇总表
    max_pcs = max(cellfun(@(x) length(x.explained), pca_results));
    
    % 初始化pca_summary的表格，列数等于所有nation的最大主成分数 * 2（每个主成分包含解释方差和对应的max_attribute）
    pca_summary = cell(length(nations) + 1, 2 * max_pcs + 1);  % 第一列是nation，接下来的每列分别是每个主成分的explained和对应的max_attribute
    
    % 设置表头：第一列是nation，接下来的每列分别是每个主成分的explained和对应的max_attribute
    header = {'Nation'};
    for i_pc = 1:max_pcs
        header = [header, {sprintf('PC%d_Explained', i_pc), sprintf('PC%d_Max_Attribute', i_pc)}];
    end
    pca_summary(1, :) = header;
    
    idx = 2;
    for i_nation = 1:length(nations)
        if ~isempty(pca_results{i_nation})
            pca_data = pca_results{i_nation};
            row = {nations_new(i_nation)};  % 开始这一行，先加入nation
    
            % 获取当前nation对应的explained和max_attribute的数量
            num_pcs_current = length(pca_data.explained);
    
            % 对每个主成分输出解释方差和对应的max_attribute
            for i_pc = 1:max_pcs
                if i_pc <= num_pcs_current
                    row = [row, pca_data.explained(i_pc), pca_data.max_attribute{i_pc}];
                else
                    % 如果当前主成分不存在，填充NaN
                    row = [row, NaN, 'NaN'];
                end
            end
    
            pca_summary(idx, :) = row;  % 添加到汇总表
            idx = idx + 1;
        end
    end
    
    % 保存PCA结果汇总表
    writecell(pca_summary, fullfile(pca_save_folder, strcat(iOr,obs_type, 'pca_summary.csv')));
    disp("Processing complete.");
    
    %% 为每个nation保存max_attribute和explained数据到不同工作表中
    pca_summary_file = fullfile(pca_save_folder, strcat(iOr, obs_type,'pca_summary.xlsx'));
    
    for i_nation = 1:length(nations)
        if ~isempty(pca_results{i_nation})
            pca_data = pca_results{i_nation};
            pcn = pcn_nations{i_nation};  % 获取对应的 pcn
            
            % 获取 max_attribute 和 explained
            max_attribute = pca_data.max_attribute;
            explained = pca_data.explained;
            
            % 创建包含explained和max_attribute的表格
            max_attribute_table = table(pcn', explained');
    
            % 写入到对应的工作表中
            sheet_name = nations(i_nation);
            writetable(max_attribute_table, pca_summary_file, 'Sheet', sheet_name);
        end
    end


end
