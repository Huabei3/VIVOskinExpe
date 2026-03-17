close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量
%% 定义所有需要处理的 attribute
attributes = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

attribute_names_new = ["Preference", "Attractiveness", "Feminine", "Cooperative", ...
    "Youth", "Healthy", "Fidelity", "Harmony", "Fair", "Ruddy"];
nations = ["AS", "CA", "SA", "AF"];

lastParts = {'f04i', 'f05i', 'f06i', 'm04i', 'm05i', 'm06i',...
'f01i', 'f02i', 'f03i', 'm01i', 'm02i', 'm03i',...
'f07i', 'f08i','m07i', 'm08i',...
'f09i', 'f10i','m09i', 'm10i'};n_para = 21;iOr='i';

% lastParts = {'f04r', 'f05r', 'f06r', 'm04r', 'm05r', 'm06r',...
% 'f01r', 'f02r', 'f03r', 'm01r', 'm02r', 'm03r',...
% 'f07r', 'f08r','m07r', 'm08r',...
% 'f09r', 'f10r','m09r', 'm10r'};n_para = 14;iOr='r';
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
% 定义线条样式和散点样式（根据i_obs索引选择）
line_styles = {'-', '--', ':', '-.'};  % 为不同i_obs设置不同线条样式
plot_styles = {'o', '+', 'd', '^'};    % 为不同i_obs设置不同散点样式
genders = ["f", "m"]; % 定义性别数组
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
                    par_all=[par_all;nan(size(par_current,1)-size(par_all,1),size(par_all,2))];
                    par_current(:, :, i_subject, i_attr) = par_all;                    
                    lab_bf=[average_current(:, 1, i_subject), par_all(:,4:5)];

                    lab_fit_current(:, :, i_subject, i_attr) = lab_bf;
                    
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
save(fullfile(output_folder,strcat("data_unscaled_reshaped_",iOr,".mat")),"par_mean","average_mean", ...
    "lab_fit_reshaped","file_missing","par_reshaped","average_reshaped");
%% 为每个观察者类型、人种和属性分别处理数据（按人种分组拟合）
obs_types = ["non_model","model_group"]; % 恢复所有观察者类型
dE = {};

% 遍历观察者类型
for i_obs = 1:length(obs_types)
    obs_type = obs_types(i_obs);
    
    % 确保线条样式和散点样式索引在有效范围内
    line_style_idx = min(i_obs, length(line_styles));
    plot_style_idx = min(i_obs, length(plot_styles));
    
    % 遍历属性
    for attribute = attributes
        attribute_serial = strcat(sprintf("%02d", attribute), attribute_names_new(attribute));
        attribute_serial = gen_attribute_new(attribute_serial);
        
        % 创建新的图形窗口
        h = figure(attribute);
        hold on;
        set(gcf, 'Color', 'white');
        
        % 初始化拟合参数存储
        a_CL_all = zeros(length(nations), 2);
        r_CL_all = zeros(length(nations), 1);
        
        % 按人种分组处理
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
                % 提取L和C值进行曲线拟合
                L = lab_g_valid(:, 1);  % L*值
                C = sqrt(lab_g_valid(:, 2).^2 + lab_g_valid(:, 3).^2);  % C*值 = sqrt(a*² + b*²)
                
                % 确保数据有效
                valid_indices = ~isnan(L) & ~isnan(C) & L > 0;
                L_valid = L(valid_indices);
                C_valid = C(valid_indices);
                
                % 如果有足够的数据点进行拟合
                if length(L_valid) > 3
                    % 定义拟合模型
                    f = @(a,xdata)(a(1).*log(xdata)+a(2));
                    
                    % 多次随机初始化以找到最佳拟合
                    rmax = 0;
                    for t = 1:500
                        a0 = [rand, rand];
                        options = optimset('MaxFunEvals', 200000);
                        a = lsqcurvefit(f, a0, L_valid, C_valid, [-inf, -inf], [inf, inf], options);
                        y = f(a, L_valid);
                        
                        r = corr(y, C_valid);
                        if r >= rmax
                            rmax = r;
                            afinal = a;
                        end
                    end
                    
                    % 保存拟合结果
                    r_CL_all(i_nation) = rmax;
                    a_CL_all(i_nation, :) = afinal;
                    
                    % 根据i_obs选择散点样式
                    % scatter_style = plot_styles{plot_style_idx};
                    % scatter(C_valid, L_valid, 30, colors(i_nation, :), scatter_style, 'filled', 'MarkerEdgeAlpha', 0.5);
                    
                    % 根据i_obs选择线条样式
                    line_style = line_styles{line_style_idx};
                    % 绘制拟合曲线
                    x = min(L_valid):0.1:max(L_valid);
                    y = f(afinal, x);
                    plot(y, x, 'Color', colors(i_nation, :), 'LineWidth', 1, 'LineStyle', line_style);
                    
                    % 亮度实验曲线
                    x2 = 10:0.1:70;
                    y2 = 6.7421*log(x2)-9.9816;
                    if i_nation == 1
                        plot(y2, x2, 'Color', 'k', 'LineWidth', 1, 'LineStyle', ':');
                    end
                    
                    % 添加图例条目
                    legend_entry = [nation, ' (r = ', num2str(rmax, '%.3f'), ')'];
                    legend_entries{i_nation} = legend_entry;
                end
            end
        end
        a_CL_whole{i_obs,attribute}=a_CL_all;
        % 设置图表属性
        ylabel('L_{ab}^*', 'FontSize', 12, 'FontAngle', 'italic');
        xlabel('C^*', 'FontSize', 12, 'FontAngle', 'italic');
        title(attribute_serial, 'FontSize', 14);
        grid on;
        
        % 设置坐标轴范围和刻度间隔
        axis equal
        interval = 10;  
        xticks(0:interval:35);
        yticks(0:interval:80);
        ylim([0, 80]);
        xlim([0, 35]);


        % 保存图片
        output_folder = fullfile('ellip_pic', Dtype, 'C_L', iOr, 'curve_fit');
        if ~exist(output_folder, 'dir')
            mkdir(output_folder);
        end
        exportgraphics(h, fullfile(output_folder, strcat(attribute_serial, '.jpg')), 'Resolution', 300);
        
        % 保存拟合参数
        output_folder_params = fullfile('ellip_pic', Dtype, 'C_L', iOr, obs_type);
        if ~exist(output_folder_params, 'dir')
            mkdir(output_folder_params);
        end
        save(fullfile(output_folder_params, strcat(attribute_serial, '_curve_params.mat')), ...
            'a_CL_all', 'r_CL_all', 'nations', 'attribute', 'obs_type');
    end
    output_folder = fullfile("ellip_pic", Dtype, "C_L", iOr, "curve_fit");
    concatenate_images1(output_folder, 5);
end