close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量
%% 定义所有需要处理的 attribute
attributes = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
attribute_names_new = ["Preference", "Attractiveness", "Feminine", "Cooperative", ...
    "Youth", "Healthy", "Fidelity", "Harmony", "Fair", "Ruddy"];
nations = ["AS", "CA", "SA", "AF", "all"];

lastParts = {'f04i', 'f05i', 'f06i', 'm04i', 'm05i', 'm06i',...
'f01i', 'f02i', 'f03i', 'm01i', 'm02i', 'm03i',...
'f07i', 'f08i','m07i', 'm08i',...
'f09i', 'f10i','m09i', 'm10i'};n_para = 21;iOr='i';
% lastParts = {'f04r', 'f05r', 'f06r', 'm04r', 'm05r', 'm06r',...
% 'f01r', 'f02r', 'f03r', 'm01r', 'm02r', 'm03r',...
% 'f07r', 'f08r','m07r', 'm08r',...
% 'f09r', 'f10r','m09r', 'm10r'};n_para = 14;iOr='r';


load("documents\valid_attr.mat","map");


wd65 = [94.811, 100.00, 107.304];
datai_file = 'D:\work\VIVOskinExpe\renderCode\calibResults\datai_ipv18_3.mat';
LUT=load(datai_file);
XYZw_LUT=LUT.XYZw;
line_style = {'-',':','-.'};
plot_style = {'^','<','v'};
colors = hsv(length(attributes));
genders = ["f", "m"];
obs_types = ["non_model", "model_group", "model"];
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
% 初始化重塑后的数据结构
average_reshaped = cell(5, 1); % 5个人种
par_reshaped = cell(3, 5, 1);  % 3种观察者类型 × 5个人种
lab_fit_reshaped = cell(3, 5, 1); % 3种观察者类型 × 5个人种
labCh_PMCC=[[62.11	18.96	19.76	27.39	46.18];...
            [64.15	19.56	19.63	27.71	45.10];...
            [56.01	18.25	18.72	26.14	45.72];...
            [41.06	17.37	17.94	24.97	45.93]];
labCh_PMCC(end+1,:)=mean(labCh_PMCC,1);
file_missing={};

%% 对每个属性进行Kruskal-Wallis检验，判断二维坐标是否与组别（lastPart）相关
Dtype = "VIVO_spl";obs_types=["non_model"];
output_folder = fullfile("ellip_pic", Dtype, "attr");
load(fullfile(output_folder, strcat("data_reshaped_",iOr,".mat")), "lab_fit_reshaped");

% 创建存储检验结果的单元格数组
mw_results = cell(length(obs_types), length(nations), length(attributes));

% 对每个观察者类型、人种和属性组合进行检验

for i_obs = 1:length(obs_types)
    obs_type = obs_types(i_obs);
    
    for i_nation = 1:length(nations)
        nation = nations(i_nation);
        
        % 获取当前人种的lastPart索引
        curr_nation_indices = nation_indices{i_nation};
        n_lastParts = length(curr_nation_indices);
        
        % 如果没有数据，跳过当前循环
        if n_lastParts == 0
            continue;
        end
        for i_attr = 1:length(attributes)
            attribute = attributes(i_attr);
            attribute_name = attribute_names_new(attribute);
            
            % 存储每个lastPart组别的有效数据
            valid_groups = cell(2, 1); % 第1维：a*，第2维：b*
            group_labels = {};         % 存储组标签
            
            % 提取每个lastPart组别的有效数据
            for i_lastPart = 1:n_lastParts
                lastPart_idx = curr_nation_indices(i_lastPart);
                lastPart = lastParts{lastPart_idx};
                
                % 提取当前lastPart的a*和b*值
                a_data = lab_fit_reshaped{i_obs, i_nation}(:, 2, i_lastPart, attribute);
                b_data = lab_fit_reshaped{i_obs, i_nation}(:, 3, i_lastPart, attribute);
                
                % 去除NaN值并检查样本量
                valid_a = a_data(~isnan(a_data));
                valid_b = b_data(~isnan(b_data));
                
                % 只添加样本量足够的组别
                if length(valid_a) >= 2 && length(valid_b) >= 2
                    valid_groups{1}{end+1} = valid_a;
                    valid_groups{2}{end+1} = valid_b;
                    group_labels{end+1} = lastPart;
                end
            end
            
            % 初始化检验结果
            p_values = [1, 1]; % [a*, b*]的p值
            significant = [false, false]; % [a*, b*]的显著性
            
            % 对a*和b*分别进行Kruskal-Wallis检验
            for i_dim = 1:2
                if length(valid_groups{i_dim}) >= 2
                    % 合并所有组数据用于检验
                    all_data = [];
                    group_ids = [];
                    
                    for i = 1:length(valid_groups{i_dim})
                        all_data = [all_data; valid_groups{i_dim}{i}];
                        group_ids = [group_ids; ones(length(valid_groups{i_dim}{i}), 1) * i];
                    end
                    
                    % 执行Kruskal-Wallis检验
                    [p,anovatab,stats] = kruskalwallis(all_data, group_ids);
                    % [~, p_values(i_dim)] = kruskalwallis(all_data, group_ids);
                    p_values(i_dim)=p;
                    significant(i_dim) = p_values(i_dim) < 0.05;
                end
            end
            
            % 存储检验结果
            mw_results{i_obs, i_nation, i_attr} = struct('p_value_a', p_values(1), ...
                                                         'p_value_b', p_values(2), ...
                                                         'significant_a', significant(1), ...
                                                         'significant_b', significant(2),...
                                                         'valid_groups', {group_labels});
        end
        close all;
        % 显示当前处理进度
        fprintf('完成检验: %s, %s (属性: %d/%d)\n', ...
                char(obs_type), char(nation), i_attr, length(attributes));
    end
    %创建结果表格
    results_table = table();
    for i_nation = 1:length(nations)
        nation = nations(i_nation);
        for i_attr = 1:length(attributes)
            attribute = attributes(i_attr);
            attribute_name = attribute_names_new(attribute);
            
            result = mw_results{i_obs, i_nation, i_attr};
            
            % 添加结果到表格
            new_row = table( ...
                {char(obs_type)}, ...
                {char(nation)}, ...
                attribute, ...
                {char(attribute_name)}, ...
                result.p_value_a, ...
                result.p_value_b, ...
                result.significant_a, ...
                result.significant_b, ...
                'VariableNames', {'ObserverType', 'Nation', 'AttributeID', 'AttributeName', ...
                                 'PValue_a', 'PValue_b', 'Significant_a', 'Significant_b'});
            
            results_table = [results_table; new_row];
        end
    end
    % 保存结果表格
    writetable(results_table, fullfile(output_folder, strcat(iOr,'_',obs_type,'_appearance_Kruskal_Wallis.csv')));
end
%%
