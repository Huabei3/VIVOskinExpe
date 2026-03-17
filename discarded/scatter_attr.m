close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量
%% 定义所有需要处理的 attribute
attributes = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
attribute_names_new = ["Preference", "Attractiveness", "Feminine", "Cooperative", ...
    "Youth", "Healthy", "Fidelity", "Harmony", "Fair", "Ruddy"];
nations = ["AS", "CA", "SA", "AF", "all"];

% lastParts = {'f04i', 'f05i', 'f06i', 'm04i', 'm05i', 'm06i',...
% 'f01i', 'f02i', 'f03i', 'm01i', 'm02i', 'm03i',...
% 'f07i', 'f08i','m07i', 'm08i',...
% 'f09i', 'f10i','m09i', 'm10i'};n_para = 21;iOr='i';
lastParts = {'f04r', 'f05r', 'f06r', 'm04r', 'm05r', 'm06r',...
'f01r', 'f02r', 'f03r', 'm01r', 'm02r', 'm03r',...
'f07r', 'f08r','m07r', 'm08r',...
'f09r', 'f10r','m09r', 'm10r'};n_para = 14;iOr='r';


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
average_reshaped = cell(5, 2); % 5个人种 × 2种性别
par_reshaped = cell(3, 5, 2);  % 3种观察者类型 × 5个人种 × 2种性别
lab_fit_reshaped = cell(3, 5, 2); % 3种观察者类型 × 5个人种 × 2种性别
labCh_PMCC=[[62.11	18.96	19.76	27.39	46.18];...
            [64.15	19.56	19.63	27.71	45.10];...
            [56.01	18.25	18.72	26.14	45.72];...
            [41.06	17.37	17.94	24.97	45.93]];
labCh_PMCC(end+1,:)=mean(labCh_PMCC,1);
file_missing={};
Dtype = 'VIVO_spl';




%% 直接按重塑后的结构加载和存储数据
for i_obs = 1:length(obs_types)
    obs_type = obs_types(i_obs);
    
    for i_nation = 1:length(nations)
        % 获取当前人种的所有索引
        nation=nations(i_nation);
        curr_nation_indices = nation_indices{i_nation};
        
        % 遍历性别
        for i_gender = 1:length(genders)
            gender_indices = [];
            
            % 找到当前性别的所有索引
            for idx = curr_nation_indices
                if strcmp(lastParts{idx}(1), genders(i_gender))
                    gender_indices = [gender_indices, idx];
                end
            end
            if i_nation==2&&i_gender==2
                disp("d")
            end
            if ~isempty(gender_indices)
                % 为当前性别和人种组合初始化数据数组
                n_subjects = length(gender_indices);
                par_current = zeros(n_para, 6, n_subjects, length(attributes));
                lab_fit_current = zeros(n_para, 3, n_subjects, length(attributes));
                average_current = zeros(n_para, 3, n_subjects);
                
                % 为每个subject加载数据
                for i_subject = 1:n_subjects
                    subject_idx = gender_indices(i_subject);
                    lastPart = lastParts{subject_idx};
                    iOr = lastPart(end);
                    % 加载平均肤色数据
                    average_file = fullfile("aveSkin", lastPart, "autoNhand_scaleoverLUT.mat");
                    if exist(average_file, 'file')
                        average_data = load(average_file);
                        average_current(:, :, i_subject) = average_data.average_lab_all(:, 1:3);
                    else
                        average_current(:, :, i_subject) = NaN(n_para, 3);
                    end
                    white_file = fullfile("optmizedD\whiteSquare\XYZw_white", ...
                        strcat(lastPart, ".mat"));
                    load(white_file,"XYZw_white");
                    
                    % 循环处理每个 attribute
                    for i_attr = 1:length(attributes)
                        attribute = attributes(i_attr);
                        attribute_serial = strcat(sprintf("%02d", attribute), attribute_names_new(attribute));
                        
                        % 定义路径
                        source_file = fullfile('AnalyseResults1', Dtype, lastPart, obs_type, attribute_serial, 'ellipPara', 'fitRes.mat');
                        
                        % 加载数据
                        if exist(source_file, 'file')
                            par_all_data = load(source_file);
                            par_all = par_all_data.par_all;
                            par_current(:, :, i_subject, i_attr) = par_all;
                            lab_bf=[average_current(:, 1, i_subject), par_all(:,4:5)];
                            xyz_fit=[];lab_scaled=[];
                            for i_para=1:size(par_all,1)                                
                                xyz_fit(i_para,:)=lab2xyz2(lab_bf(i_para,:),"user",wd65./wd65(2).*XYZw_LUT(2));
                                lab_scaled(i_para,:)=xyz2lab(xyz_fit(i_para,:),"user",wd65./wd65(2).*XYZw_white(i_para,2));
                            end
                            lab_fit_current(:, :, i_subject, i_attr) = lab_scaled;
                            
                        else
                            par_current(:, :, i_subject, i_attr) = NaN(n_para, 6);
                            lab_fit_current(:, :, i_subject, i_attr) = NaN(n_para, 3);
                            file_missing{end+1,1}=lastPart;
                            file_missing{end,2}=obs_type;
                            file_missing{end,3}=attribute_serial;
                        end
                    end
                end
                
                % 存储到重塑后的数据结构中
                par_reshaped{i_obs, i_nation, i_gender} = par_current;
                lab_fit_reshaped{i_obs, i_nation, i_gender} = lab_fit_current;
                
                % average_reshaped只需要存储一次（不依赖于观察者类型）
                if i_obs == 1
                    average_reshaped{i_nation, i_gender} = average_current;
                end
            else
                % 如果没有找到对应的性别索引，设置为空
                par_reshaped{i_obs, i_nation, i_gender} = [];
                lab_fit_reshaped{i_obs, i_nation, i_gender} = [];
                if i_obs == 1
                    average_reshaped{i_nation, i_gender} = [];
                end
            end
            average_mean{i_obs, i_nation, i_gender}=nanmean(average_reshaped{i_nation, i_gender} ,3);       
            lab_fit_mean{i_obs, i_nation, i_gender}=nanmean(lab_fit_reshaped{i_obs,i_nation, i_gender} ,3);            
            par_mean{i_obs,i_nation,i_gender}=nanmean(par_reshaped{i_obs,i_nation,i_gender},3);
        end
    end
    disp("d")
end

%% 计算全局坐标轴范围
% 初始化极值变量
lim_min_x = inf;  % a*轴最小边界初始化为正无穷
lim_min_y = inf;  % b*轴最小边界初始化为正无穷
lim_max_x = -inf; % a*轴最大边界初始化为负无穷
lim_max_y = -inf; % b*轴最大边界初始化为负无穷

% 遍历所有可能的数据组合计算全局极值
for i_nation = 1:length(nations)
    for i_gender = 1:length(genders)
        for i_obs = 1:length(obs_types)  % 只考虑第一个观察者类型
            obs_type=obs_types(i_obs);
            for attribute = attributes
                if exist('lab_fit_mean', 'var') && ~isempty(lab_fit_mean{i_obs, i_nation, i_gender})
                    lab = lab_fit_mean{i_obs, i_nation, i_gender}(5, :, 1, attribute);
                    if ~isempty(lab)
                        lim_min_x = min(lim_min_x, lab(2));
                        lim_max_x = max(lim_max_x, lab(2));
                        lim_min_y = min(lim_min_y, lab(3));
                        lim_max_y = max(lim_max_y, lab(3));
                    end
                end
            end
            
            % 考虑PMCC点
            lim_min_x = min(lim_min_x, labCh_PMCC(i_nation, 2));
            lim_max_x = max(lim_max_x, labCh_PMCC(i_nation, 2));
            lim_min_y = min(lim_min_y, labCh_PMCC(i_nation, 3));
            lim_max_y = max(lim_max_y, labCh_PMCC(i_nation, 3));
        end
    end
end

% 添加边距
lim_min_x = lim_min_x - 1;
lim_max_x = lim_max_x + 1;
lim_min_y = lim_min_y - 1;
lim_max_y = lim_max_y + 1;

% 确保x和y轴范围相同，以保持等比例显示
range_x = lim_max_x - lim_min_x;
range_y = lim_max_y - lim_min_y;
max_range = max(range_x, range_y);

% 调整范围使x和y轴的刻度间隔相同
lim_min_x = (lim_min_x + lim_max_x - max_range) / 2;
lim_max_x = (lim_min_x + lim_max_x + max_range) / 2;
lim_min_y = (lim_min_y + lim_max_y - max_range) / 2;
lim_max_y = (lim_min_y + lim_max_y + max_range) / 2;

%% 绘图循环
for i_obs=1:length(obs_types)
    obs_type=obs_types(i_obs);
    for i_nation = 1:length(nations)
        nation=nations(i_nation);
        nation_serial=strcat(sprintf("%02d",i_nation),nation);
        for i_gender=1:2
            figure;
            hold on;
            set(gcf, 'Color', 'white');

            
            for attribute = attributes
                attribute_serial = strcat(sprintf("%02d", attribute), attribute_names_new(attribute));
                % for i_para = [5]
                    if strcmp(iOr,"i")
                        target_indices=[15,12,19];
                    elseif strcmp(iOr,"r")
                        target_indices=1:14;
                    end
                    lab=[];
                    if exist('lab_fit_mean', 'var')&&~isempty(lab_fit_mean{i_obs,i_nation,i_gender})
                        lab = lab_fit_mean{i_obs,i_nation,i_gender}(target_indices, :,1,attribute); 
                        lab=mean(lab,1);
                        scatter(lab(2), lab(3), 30, 'o','filled', ...
                            'MarkerFaceColor', colors(attribute, :));
                        attribute_char=char(attribute_serial);
                        text(lab(2), lab(3), ...
                            attribute_char(1:2), 'FontSize', 5, ...
                            'VerticalAlignment', 'middle','Color','k');
                        hold on;
                    end
                % end
                
                plot(labCh_PMCC(i_nation, 2), labCh_PMCC(i_nation, 3), 's', 'MarkerSize', 10, ...
                    'MarkerFaceColor', 'm', 'MarkerEdgeColor', 'm');
            end        
        
        
            % 添加图例、标签和标题
            xlabel('{\ita*}');
            ylabel('{\itb*}');
            title(strcat(genders(i_gender),"a-b"));
            
            % 设置坐标轴范围为全局计算的范围
            axis equal;
            xlim([lim_min_x, lim_max_x]);
            ylim([lim_min_y, lim_max_y]);
            x = linspace(lim_min_x, lim_max_x, 100); % 从 0 到 25，生成 100 个点
            plot(x, x); % 绘制y=x的直线，即45°线
            % 创建保存文件夹
            save_folder = fullfile("ellip_pic", Dtype,"attr", obs_type,iOr);
            if ~exist(save_folder, "dir")
                mkdir(save_folder);
            end
            exportgraphics(gcf, fullfile(save_folder, strcat(nation_serial,genders(i_gender), 'scatter_attr.jpg')), 'Resolution', 300);
            close(gcf);
        end
    end
end