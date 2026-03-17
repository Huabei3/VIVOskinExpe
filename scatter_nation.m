close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量
%% 定义所有需要处理的 attribute
attributes = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

attribute_names_new = ["Preference", "Attractiveness", "Feminine", "Cooperative", ...
    "Youth", "Healthy", "Fidelity", "Harmony", "Fair", "Ruddy"];
nations = ["AS", "CA", "SA", "AF"];

% lastParts = {'f04i', 'f05i', 'f06i', 'm04i', 'm05i', 'm06i',...
% 'f01i', 'f02i', 'f03i', 'm01i', 'm02i', 'm03i',...
% 'f07i', 'f08i','m07i', 'm08i',...
% 'f09i', 'f10i','m09i', 'm10i'};n_para = 21;iOr='i';
lastParts = {'f04r', 'f05r', 'f06r', 'm04r', 'm05r', 'm06r',...
'f01r', 'f02r', 'f03r', 'm01r', 'm02r', 'm03r',...
'f07r', 'f08r','m07r', 'm08r',...
'f09r', 'f10r','m09r', 'm10r'};n_para = 14;iOr='r';
if iOr == 'i'
    indices_target = [5, 12, 19];
else
    indices_target = 1:14;
end

load("documents\valid_attr.mat","map");


wd65 = [94.811, 100.00, 107.304];
datai_file = 'D:\work\VIVOskinExpe\renderCode\calibResults\datai_ipv18_3.mat';
LUT=load(datai_file);
XYZw_LUT=LUT.XYZw;
line_style = {'-',':','-.'};
plot_style = {'v','^'};

genders = ["f", "m"]; % 定义性别数组
scale_type="scaled";
% 生成色相值（H），范围从0到1
hue_values = linspace(0, 1, length(nations) + 1);hue_values = hue_values(1:end-1); 
hsv_matrix = [hue_values', 0.8 * ones(length(nations), 1), 0.8 * ones(length(nations), 1)];
colors = hsv2rgb(hsv_matrix);


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
Dtype = 'efit2';

% 定义一个函数来分离性别索引
function gender_indices = separate_genders(n_subjects, curr_nation_indices, lastParts)
    gender_indices = cell(2, 1); % f和m的索引
    for i_subject = 1:n_subjects
        subject_idx = curr_nation_indices(i_subject);
        lastPart = lastParts{subject_idx};
        if lastPart(1) == 'f'
            gender_indices{1} = [gender_indices{1}, i_subject];
        elseif lastPart(1) == 'm'
            gender_indices{2} = [gender_indices{2}, i_subject];
        end
    end
end

%% 直接按重塑后的结构加载和存储数据
for i_obs = 1:length(obs_types)
    obs_type = obs_types(i_obs);
    
    for i_nation = 1:length(nations)
        % 获取当前人种的所有索引
        nation=nations(i_nation);
        curr_nation_indices = nation_indices{i_nation};
        
        % 为当前人种组合初始化数据数组
        n_subjects = length(curr_nation_indices);
        par_current = zeros(n_para, 6, n_subjects, length(attributes));
        lab_fit_current = zeros(n_para, 3, n_subjects, length(attributes));
        average_current = zeros(n_para, 3, n_subjects);
        
        % 为每个subject加载数据
        for i_subject = 1:n_subjects
            subject_idx = curr_nation_indices(i_subject);
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
            white_file = fullfile("optimizedD\whiteSquare\XYZw_white", ...
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
                    par_all=[par_all;NaN(size(par_current,1)-size(par_all,1),size(par_all,2))];
                    par_current(:, :, i_subject, i_attr) =par_all;
                    lab_bf=[average_current(:, 1, i_subject), par_all(:,4:5)];
                    xyz_fit=[];lab_scaled=[];
                    if strcmp(scale_type,"scaled")
                        for i_para=1:size(par_all,1)                                
                            xyz_fit(i_para,:)=lab2xyz2(lab_bf(i_para,:),"user",wd65./wd65(2).*XYZw_LUT(2));
                            lab_scaled(i_para,:)=xyz2lab(xyz_fit(i_para,:),"user",wd65./wd65(2).*XYZw_white(i_para,2));
                        end
                        lab_fit_current(:, :, i_subject, i_attr) = lab_scaled;
                    elseif strcmp(scale_type,"unscaled")
                        lab_fit_current(:, :, i_subject, i_attr) = lab_bf;
                    end
                    
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
        par_reshaped{i_obs, i_nation} = par_current;
        lab_fit_reshaped{i_obs, i_nation} = lab_fit_current;
        
        % average_reshaped只需要存储一次（不依赖于观察者类型）
        if i_obs == 1
            average_reshaped{i_nation} = average_current;
        end
        
        average_mean{i_obs, i_nation}=nanmean(average_reshaped{i_nation} ,3);       
        par_mean{i_obs,i_nation}=nanmean(par_reshaped{i_obs,i_nation},3);
        average_nation_temp(i_nation,:)=mean(average_mean{i_obs, i_nation}(indices_target,:));
        
    end
    average_nations{i_obs}=average_nation_temp;
end
%% 保存
output_folder=fullfile("ellip_pic", Dtype);
if ~exist(output_folder,"dir")
    mkdir(output_folder);
end
save(fullfile(output_folder,strcat("data_reshaped_",iOr,".mat")),"par_mean","average_mean", ...
    "lab_fit_reshaped","file_missing","par_reshaped","average_reshaped");
%% 计算全局坐标轴范围
% 初始化极值变量
lim_min_x = inf;  % a*轴最小边界初始化为正无穷
lim_min_y = inf;  % b*轴最小边界初始化为正无穷
lim_max_x = -inf; % a*轴最大边界初始化为负无穷
lim_max_y = -inf; % b*轴最大边界初始化为负无穷

% 遍历所有可能的数据组合计算全局极值
for i_nation = 1:length(nations)
    for i_obs = 1:length(obs_types)
        obs_type=obs_types(i_obs);
        % 获取当前人种的subject数量
        n_subjects = size(lab_fit_reshaped{i_obs, i_nation}, 3);
        if n_subjects == 0
            continue;
        end
        
        % 获取当前人种对应的lastPart索引
        curr_nation_indices = nation_indices{i_nation};
        

        for attribute = attributes
            lab = lab_fit_reshaped{i_obs,i_nation}(5, :, :, attribute);
            if ~all(isnan(lab(:)))
                lab_mean = mean(lab, 3);
                lim_min_x = min(lim_min_x, lab_mean(2));
                lim_max_x = max(lim_max_x, lab_mean(2));
                lim_min_y = min(lim_min_y, lab_mean(3));
                lim_max_y = max(lim_max_y, lab_mean(3));
            end
        end

        
        % 考虑PMCC点
        lim_min_x = min(lim_min_x, labCh_PMCC(i_nation, 2));
        lim_max_x = max(lim_max_x, labCh_PMCC(i_nation, 2));
        lim_min_y = min(lim_min_y, labCh_PMCC(i_nation, 3));
        lim_max_y = max(lim_max_y, labCh_PMCC(i_nation, 3));
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



%% 为每个观察者类型、人种和属性分别处理数据（按人种分组拟合）
obs_types = ["non_model","model_group"];
dE = {};


% 遍历观察者类型
for i_obs = 1:length(obs_types)
    obs_type = obs_types(i_obs);
    
% 遍历属性
    for attribute = attributes
        attribute_serial = strcat(sprintf("%02d", attribute), attribute_names_new(attribute));
        
        % 按人种分组处理（排除"all"组别）
        for i_nation = 1:length(nations)
            nation = nations(i_nation);
            
            % 获取当前人种的lastPart索引
            curr_nation_indices = nation_indices{i_nation};
            
            if attribute==7
                i_obs_used=2;
            else
                i_obs_used=i_obs;
            end
            lab_data = lab_fit_reshaped{i_obs_used, i_nation}(indices_target, :, :, attribute);
            
            % 重组数据为 (n_targets*n_subjects)×3 的矩阵
            [n_targets, n_channels, n_subjects] = size(lab_data);
            lab_g = reshape(permute(lab_data, [1 3 2]), n_targets*n_subjects, n_channels);

           % 检查并移除包含NaN的行
            valid_rows = ~any(isnan(lab_g), 2);  % 找出所有不包含NaN的行
            lab_g_valid = lab_g(valid_rows, :);  % 提取有效行
            
            % 仅当存在有效数据时执行后续操作
            if ~isempty(lab_g_valid)
                % 拟合95%椭圆（使用无NaN的数据）
                [center_g, mu_g, chi2_val_g, List_g, cov_mat_g, cov_mat_r_g] = fit95ellip_my(lab_g_valid, 0.05, 2);
                center_g_label{i_nation} = center_g;
                
                % 保存参数
                save_folder = fullfile('ellip_pic', Dtype, scale_type,'nation', iOr);
                output_folder_params = fullfile(save_folder, 'ellipPara');
                if ~exist(output_folder_params, 'dir')
                    mkdir(output_folder_params);
                end
                save(fullfile(output_folder_params, ...
                    strcat(iOr, obs_type, nation, attribute_serial, "95ellip.mat")), ...
                    'center_g', 'mu_g', 'List_g');
                
                % 画椭圆（使用无NaN的数据）
                if strcmp(scale_type,"scaled")
                    average_used=NaN(size(average_nations{i_obs}));
                else
                    average_used=average_nations{i_obs};
                end
                h = figure(attribute);
                contour95ellip(center_g, mu_g, lab_g_valid, chi2_val_g, ...
                    colors(i_nation, :), ...         % 按人种设置颜色
                    line_style{1},...                % 按性别设置线条样式
                    'o', ...               % 按性别设置标记样式
                    "nation", mean(lab_g_valid, 1), h, ...
                    average_used,attribute_serial);
                
                % 保存图片
                output_folder_plot = fullfile(save_folder, 'ellipsoid_sections');
                if ~exist(output_folder_plot, 'dir')
                    mkdir(output_folder_plot);
                end
                exportgraphics(h, fullfile(output_folder_plot, ...
                    strcat(iOr, obs_type, attribute_serial, '.jpg')), ...
                    'Resolution', 300);
                
                % 计算色差（使用无NaN的数据）
                dE_mat_g = zeros(size(lab_g_valid, 1));
                for i_para = 1:size(lab_g_valid, 1)
                    for j_para = 1:size(lab_g_valid, 1)
                        dE_mat_g(i_para, j_para) = deltaE2000(lab_g_valid(i_para, :), lab_g_valid(j_para, :));
                    end
                end
                dE_mat_g(dE_mat_g == 0) = NaN;
                
                % 存储平均色差
                dE_intra{i_nation, 1} = nanmean(nanmean(dE_mat_g));
            end
        end

        
        % 记录跨性别色差（仅在数据有效时）
        if ~all(isnan(lab_g(:))) && exist('center_g_label', 'var') && length(center_g_label) == 2
            dE{end+1, 1} = obs_type;
            dE{end, 2} = iOr;
            dE{end, 3} = nation;
            dE{end, 4} = attribute_serial;
            for i_nation=1:length(nations)
                dE{end, end+1} = dE_intra{i_nation, 1};
            end
            % 计算色差矩阵的平均值（排除对角线元素）
            mean_deltaE = nanmean(deltaE_matrix(~eye(n_nations, 'logical')));
            dE{end, end+1} = mean_deltaE;  % 记录平均跨组别色差        
        end
    end
    close all
end

save_folder = fullfile("ellip_pic",Dtype,scale_type,"nation",iOr,"ellipsoid_sections");
concatenate_images1(save_folder,5);
