function sort_lab_fit_XSLX_obs(lab_fit_reshaped, average_mean, save_path, indices_target, lightness_type, iOr)
    if iOr == 'i'
        lastParts = {'f04i', 'f05i', 'f06i', 'm04i', 'm05i', 'm06i',...
                     'f01i', 'f02i', 'f03i', 'm01i', 'm02i', 'm03i',...
                     'f07i', 'f08i', 'm07i', 'm08i',...
                     'f09i', 'f10i', 'm09i', 'm10i'};
        n_para = 21;
    else
        lastParts = {'f04r', 'f05r', 'f06r', 'm04r', 'm05r', 'm06r',...
                     'f01r', 'f02r', 'f03r', 'm01r', 'm02r', 'm03r',...
                     'f07r', 'f08r', 'm07r', 'm08r',...
                     'f09r', 'f10r', 'm09r', 'm10r'};
        n_para = 14;
    end

    % 定义固定参数
    obs_types = ["non_model", "model_group", "model"];
    attributes = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
    attribute_names = ["Preference", "Attractiveness", "Feminine", "Cooperative", ...
                       "Youth", "Healthy", "Fidelity", "Harmony", "Fair", "Ruddy"];
    nations = ["AS", "CA", "SA", "AF"];
    nation_names = ["Asian", "Caucasian", "South Asian", "African"];
    wd65 = [94.811, 100.00, 107.304];
    datai_file = 'D:\work\VIVOskinExpe\renderCode\calibResults\datai_ipv18_3.mat';
    LUT = load(datai_file);
    XYZw_LUT = LUT.XYZw;

    % 定义人种对应的lastParts索引
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
%%

    % 确保保存路径存在
    [folder, ~] = fileparts(save_path);
    if ~exist(folder, 'dir')
        mkdir(folder);
    end

    for i_nation = 1:length(nations)
        nation = nations(i_nation);
        
        % 预定义所有变量名
        var_names = {'Attribute'};
        for i_obs = 1:length(obs_types)
            obs_type = obs_types(i_obs);
            var_names = [var_names, ...
                         sprintf('%s_a', obs_type), sprintf('%s_b', obs_type), ...
                         sprintf('%s_C', obs_type), sprintf('%s_h', obs_type), ...
                         sprintf('avg_%s_a', obs_type), sprintf('avg_%s_b', obs_type), ...
                         sprintf('avg_%s_C', obs_type), sprintf('avg_%s_h', obs_type)];
        end
        
        % 创建带有所有变量名的空表
        table_data = table('Size', [0, length(var_names)], 'VariableTypes', repmat({'double'}, 1, length(var_names)));
        table_data.Properties.VariableNames = var_names;
        table_data.Attribute = categorical(); % 将属性列设为分类变量
        
        % 处理每个属性的数据
        for attribute = attributes
            row_data = {categorical(attribute_names(attribute))};
            
            for i_obs = 1:length(obs_types)
                % 获取当前人种的subject数量
                n_subjects = size(lab_fit_reshaped{i_obs, i_nation}, 3);
                
                % 获取当前人种对应的lastPart索引
                curr_nation_indices = nation_indices{i_nation};
                lab_data = lab_fit_reshaped{i_obs, i_nation}(indices_target, :, :, attribute);
                
                % 计算平均值并准备数据
                lab_g = nanmean(lab_data, 3); % 按受试者维度求平均
                lab_g = nanmean(lab_g, 1);    % 按光源维度求平均
                
                % 计算彩度和色调角度
                C_star = sqrt(lab_g(2)^2 + lab_g(3)^2);
                h_deg = atan2d(lab_g(3), lab_g(2));
                
                % 获取对应average值
                ave = mean(average_mean{i_obs, i_nation}(indices_target, :), 1);
                ave_C_star = sqrt(ave(2)^2 + ave(3)^2);
                ave_h_deg = atan2d(ave(3), ave(2));
                
                % 添加到数据行
                row_data = [row_data, lab_g(2), lab_g(3), C_star, h_deg, ave(2), ave(3), ave_C_star, ave_h_deg];
            end
            
            % 添加到表格
            new_row = cell2table(row_data, 'VariableNames', var_names);
            table_data = [table_data; new_row];
        end
        
        % 计算汇总行
        summary_row = {categorical(['Average_' nation])};
        
        for i_obs = 1:length(obs_types)
            lab_sum = zeros(1, 3);
            ave_sum = zeros(1, 3);
            
            for attribute = attributes
                lab_data = lab_fit_reshaped{i_obs, i_nation}(indices_target, :, :, attribute);
                lab_g = nanmean(lab_data, 3);
                lab_g = nanmean(lab_g, 1);
                lab_sum = lab_sum + lab_g;
                
                ave = mean(average_mean{i_obs, i_nation}(indices_target, :), 1);
                ave_sum = ave_sum + ave;
            end
            
            lab_avg = lab_sum / length(attributes);
            C_star_avg = sqrt(lab_avg(2)^2 + lab_avg(3)^2);
            h_deg_avg = atan2d(lab_avg(3), lab_avg(2));
            
            ave_avg = ave_sum / length(attributes);
            ave_C_star_avg = sqrt(ave_avg(2)^2 + ave_avg(3)^2);
            ave_h_deg_avg = atan2d(ave_avg(3), ave_avg(2));
            
            summary_row = [summary_row, lab_avg(2), lab_avg(3), C_star_avg, h_deg_avg, ...
                         ave_avg(2), ave_avg(3), ave_C_star_avg, ave_h_deg_avg];
        end
        
        % 添加汇总行到表格
        summary_table = cell2table(summary_row, 'VariableNames', var_names);
        % table_data = [table_data;summary_table];
        
        % 写入Excel文件
        % writetable(table_data, save_path, 'Sheet', nation);
        xlswrite(save_path, table_data, nation);
    end
end    