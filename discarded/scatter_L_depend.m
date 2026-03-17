% 主脚本开始
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
r_excel_output_folder = fullfile("AnalyseResults1", Dtype, "sum_list");
if ~exist(r_excel_output_folder, 'dir')
    mkdir(r_excel_output_folder);
end
obs_types = ["non_model"]; % 恢复所有观察者类型
% obs_types = ["non_model", "model_group"]; % 恢复所有观察者类型
dE = {};
% 遍历观察者类型
for i_obs = 1:length(obs_types)
    obs_type = obs_types(i_obs);
    % 用于存储当前 obs_type 下所有 attribute 的 r 值，以便写入 Excel
    r_values_for_excel_C_L = zeros(length(attributes), length(nations));
    r_values_for_excel_long_axis = zeros(length(attributes), length(nations));
    r_values_for_excel_short_axis = zeros(length(attributes), length(nations));
    r_values_for_excel_hue_angle = zeros(length(attributes), length(nations));
    r_values_for_excel_theta = zeros(length(attributes), length(nations));
    r_values_for_excel_alpha = zeros(length(attributes), length(nations)); % 新增 alpha 的 r 值存储
    % 确保线条样式和散点样式索引在有效范围内
    line_style_idx = min(i_obs, length(line_styles));
    plot_style_idx = min(i_obs, length(plot_styles));
    % 遍历属性
    for idx_attribute = 1:length(attributes) % 使用新的索引来遍历 attributes 数组
        attribute = attributes(idx_attribute);
        attribute_serial = strcat(sprintf("%02d", attribute), attribute_names_new(attribute));
        attribute_serial = gen_attribute_new(attribute_serial); % 假设此函数已定义
        % 初始化拟合参数存储
        a_CL_all = zeros(length(nations), 2);
        r_CL_all = zeros(length(nations), 1);
        a_long_axis_all = zeros(length(nations), 4); % 三次函数 4 个参数
        r_long_axis_all = zeros(length(nations), 1);
        a_short_axis_all = zeros(length(nations), 4); % 三次函数 4 个参数
        r_short_axis_all = zeros(length(nations), 1);
        a_hue_angle_all = zeros(length(nations), 2); % 线性函数 2 个参数
        r_hue_angle_all = zeros(length(nations), 1);
        a_theta_all = zeros(length(nations), 2); % 线性函数 2 个参数
        r_theta_all = zeros(length(nations), 1);
        a_alpha_all = zeros(length(nations), 2); % 新增 alpha 线性函数 2 个参数
        r_alpha_all = zeros(length(nations), 1); % 新增 alpha r 值
        % 按人种分组处理
        for i_nation = 1:length(nations)
            nation = nations(i_nation);
            % 获取当前人种的lastPart索引
            curr_nation_indices = nation_indices{i_nation};
            if attribute == 7
                i_obs_used = 2;
            else
                i_obs_used = i_obs;
            end
            
            % 获取 lab_fit_reshaped 和 par_reshaped 数据
            lab_data = lab_fit_reshaped{i_obs_used, i_nation}(indices_target, :, :, attribute);
            par_data = par_reshaped{i_obs_used, i_nation}(indices_target, :, :, attribute);
            % 重组数据为 (n_targets*n_subjects)×3 或 (n_targets*n_subjects)×6 的矩阵
            [n_targets, n_channels_lab, n_subjects] = size(lab_data);
            [~, n_channels_par, ~] = size(par_data);
            lab_g = reshape(permute(lab_data, [1 3 2]), n_targets * n_subjects, n_channels_lab);
            par_g = reshape(permute(par_data, [1 3 2]), n_targets * n_subjects, n_channels_par);
            % 检查并移除包含NaN的行
            valid_rows_lab = ~any(isnan(lab_g), 2);
            valid_rows_par = ~any(isnan(par_g), 2);
            % 合并有效行，确保 L, C, par_all 数据一致
            valid_overall_rows = valid_rows_lab & valid_rows_par;
            L_all = lab_g(valid_overall_rows, 1);
            
            % 从 par_g 中提取椭圆参数并计算长短轴、倾角和色调角
            par_all_valid = par_g(valid_overall_rows, :);
            C_all = sqrt(par_all_valid(:,4).^2 + par_all_valid(:,5).^2);

            alpha_values=-log(par_all_valid(:,6));
            alpha_values(isinf(alpha_values) | isnan(alpha_values)) = NaN;
            lambda00 = par_all_valid(:, 1) ./ alpha_values.^2;
            lambda01 = par_all_valid(:, 3) ./ alpha_values.^2 ./ 2;
            lambda10 = par_all_valid(:, 3) ./ alpha_values.^2 ./ 2;
            lambda11 = par_all_valid(:, 2) ./ alpha_values.^2;

            % 椭圆倾角 theta
            % 使用 atan2d 替代 atan2d_360，因为 atan2d_360 可能是自定义函数，如果不存在会报错
            % 假设 atan2d_360 只是将 atan2d 结果转换为 [0, 360) 范围
            theta = 0.5 * atan2d(2 * lambda01, (lambda00 - lambda11));
            theta = mod(theta, 360); % 确保在 [0, 360) 范围内
            % 长短轴
            A = lambda00 .* cosd(theta).^2 - lambda01 .* sind(2 * theta) + lambda11 .* sind(theta).^2;
            B = lambda00 .* sind(theta).^2 + lambda01 .* sind(2 * theta) + lambda11 .* cosd(theta).^2;
            
            lambda00_re = (A + B) / 2 + (A - B) / 2 .* cosd(2 .* theta);
            lambda11_re = (A + B) / 2 - (A - B) / 2 .* cosd(2 .* theta);
            lambda01_re = (A - B) / 2 .* sind(2 .* theta);

            
            
            % 检查 A 和 B 是否有负值或非实数，这可能导致 sqrt 错误
            A(A <= 0) = NaN;
            B(B <= 0) = NaN;
            long_axis = sqrt(1 ./ A);
            short_axis = sqrt(1 ./ B);
            A_rotated = 1 ./ (long_axis.^2);
            B_rotated = 1 ./ (short_axis.^2);
            lambda00_re1 = (A_rotated + B_rotated) / 2 + (A_rotated - B_rotated) / 2 .* cosd(2 .* theta);
            lambda11_re1 = (A_rotated + B_rotated) / 2 - (A_rotated - B_rotated) / 2 .* cosd(2 .* theta);
            lambda01_re1 = (A_rotated - B_rotated) / 2 .* sind(2 .* theta);

            % 色调角 atan2d_360(par_all(:, 5), par_all(:, 4))
            hue_angle = atan2d(par_all_valid(:, 5), par_all_valid(:, 4));
            hue_angle = mod(hue_angle, 360); % 确保在 [0, 360) 范围内

            [par,lambda00,lambda11,lambda01,A_rotated,B_rotated] = calculate_par_from_ellipse(hue_angle, C_all, long_axis, short_axis, theta, alpha_values);
            par_1 = ellipse_features_to_par(hue_angle, C_all, long_axis, short_axis, theta, alpha_values);
            colors=hsv(3);
            plot_contour(par_all_valid(1,:),colors(1,:));
            plot_contour(par(1,:),colors(2,:));
            plot_contour(par_1(1,:),colors(3,:));
            % --- 调用建模函数并保存结果 ---
            % C_L 建模
            [r_C_L, a_C_L] = model_C_L(L_all, C_all, attribute_serial, colors(i_nation, :), line_styles{line_style_idx}, Dtype, iOr, i_nation);
            r_CL_all(i_nation) = r_C_L;
            a_CL_all(i_nation, :) = a_C_L;
            % 长轴建模
            [r_long_axis, a_long_axis] = model_long_axis(L_all, long_axis, attribute_serial, colors(i_nation, :), line_styles{line_style_idx}, Dtype, iOr, i_nation);
            r_long_axis_all(i_nation) = r_long_axis;
            a_long_axis_all(i_nation, :) = a_long_axis;
            % 短轴建模
            [r_short_axis, a_short_axis] = model_short_axis(L_all, short_axis, attribute_serial, colors(i_nation, :), line_styles{line_style_idx}, Dtype, iOr, i_nation);
            r_short_axis_all(i_nation) = r_short_axis;
            a_short_axis_all(i_nation, :) = a_short_axis;
            % 色调角建模
            [r_hue_angle, a_hue_angle] = model_hue_angle(L_all, hue_angle, attribute_serial, colors(i_nation, :), line_styles{line_style_idx}, Dtype, iOr, i_nation);
            r_hue_angle_all(i_nation) = r_hue_angle;
            a_hue_angle_all(i_nation, :) = a_hue_angle;
            % 椭圆倾角 theta 建模
            [r_theta, a_theta] = model_theta(L_all, theta, attribute_serial, colors(i_nation, :), line_styles{line_style_idx}, Dtype, iOr, i_nation);
            r_theta_all(i_nation) = r_theta;
            a_theta_all(i_nation,:) = a_theta; 
            
            % 新增：alpha 建模
            [r_alpha, a_alpha] = model_alpha(L_all, alpha_values, attribute_serial, colors(i_nation, :), line_styles{line_style_idx}, Dtype, iOr, i_nation);
            r_alpha_all(i_nation) = r_alpha;
            a_alpha_all(i_nation, :) = a_alpha;
        end
        % 将当前 attribute 的 r_all 值存入总的 r_values_for_excel 矩阵
        r_values_for_excel_C_L(idx_attribute, :) = r_CL_all';
        r_values_for_excel_long_axis(idx_attribute, :) = r_long_axis_all';
        r_values_for_excel_short_axis(idx_attribute, :) = r_short_axis_all';
        r_values_for_excel_hue_angle(idx_attribute, :) = r_hue_angle_all';
        r_values_for_excel_theta(idx_attribute, :) = r_theta_all';
        r_values_for_excel_alpha(idx_attribute, :) = r_alpha_all'; % 保存 alpha 的 r 值
        % 保存拟合参数
        output_folder_params = fullfile('ellip_pic', Dtype, iOr, obs_type);
        if ~exist(output_folder_params, 'dir')
            mkdir(output_folder_params);
        end
        save(fullfile(output_folder_params, strcat(attribute_serial, '_all_curve_params.mat')), ...
            'a_CL_all', 'r_CL_all', 'a_long_axis_all', 'r_long_axis_all', ...
            'a_short_axis_all', 'r_short_axis_all', 'a_hue_angle_all', ...
            'r_hue_angle_all', 'a_theta_all', 'r_theta_all', ...
            'a_alpha_all', 'r_alpha_all', ... % 保存 alpha 拟合参数
            'nations', 'attribute', 'obs_type');
    end
    % --- 将 r_values_for_excel 写入 Excel 文件 ---
    excel_col_names = nations;
    full_header = ["Attribute", excel_col_names];
    % C_L 相关性写入
    excel_filename_C_L = fullfile(r_excel_output_folder, strcat('correlation_C_L_', iOr, '_', obs_type, '.xlsx'));
    data_to_write_C_L = [cellstr(attribute_names_new(attributes))', num2cell(r_values_for_excel_C_L)];
    writecell([full_header; data_to_write_C_L], excel_filename_C_L, 'WriteMode', 'overwrite');
    fprintf('已将 %s 的 C_L 相关性矩阵写入 Excel 文件。\n', obs_type);
    % 长轴相关性写入
    excel_filename_long_axis = fullfile(r_excel_output_folder, strcat('correlation_long_axis_', iOr, '_', obs_type, '.xlsx'));
    data_to_write_long_axis = [cellstr(attribute_names_new(attributes))', num2cell(r_values_for_excel_long_axis)];
    writecell([full_header; data_to_write_long_axis], excel_filename_long_axis, 'WriteMode', 'overwrite');
    fprintf('已将 %s 的长轴相关性矩阵写入 Excel 文件。\n', obs_type);
    % 短轴相关性写入
    excel_filename_short_axis = fullfile(r_excel_output_folder, strcat('correlation_short_axis_', iOr, '_', obs_type, '.xlsx'));
    data_to_write_short_axis = [cellstr(attribute_names_new(attributes))', num2cell(r_values_for_excel_short_axis)];
    writecell([full_header; data_to_write_short_axis], excel_filename_short_axis, 'WriteMode', 'overwrite');
    fprintf('已将 %s 的短轴相关性矩阵写入 Excel 文件。\n', obs_type);
    % 色调角相关性写入
    excel_filename_hue_angle = fullfile(r_excel_output_folder, strcat('correlation_hue_angle_', iOr, '_', obs_type, '.xlsx'));
    data_to_write_hue_angle = [cellstr(attribute_names_new(attributes))', num2cell(r_values_for_excel_hue_angle)];
    writecell([full_header; data_to_write_hue_angle], excel_filename_hue_angle, 'WriteMode', 'overwrite');
    fprintf('已将 %s 的色调角相关性矩阵写入 Excel 文件。\n', obs_type);
    % 椭圆倾角相关性写入
    excel_filename_theta = fullfile(r_excel_output_folder, strcat('correlation_theta_', iOr, '_', obs_type, '.xlsx'));
    data_to_write_theta = [cellstr(attribute_names_new(attributes))', num2cell(r_values_for_excel_theta)];
    writecell([full_header; data_to_write_theta], excel_filename_theta, 'WriteMode', 'overwrite');
    fprintf('已将 %s 的椭圆倾角相关性矩阵写入 Excel 文件。\n', obs_type);

    % 新增：alpha 相关性写入
    excel_filename_alpha = fullfile(r_excel_output_folder, strcat('correlation_alpha_', iOr, '_', obs_type, '.xlsx'));
    data_to_write_alpha = [cellstr(attribute_names_new(attributes))', num2cell(r_values_for_excel_alpha)];
    writecell([full_header; data_to_write_alpha], excel_filename_alpha, 'WriteMode', 'overwrite');
    fprintf('已将 %s 的 Alpha 相关性矩阵写入 Excel 文件。\n', obs_type);

    % --- Excel 写入结束 ---
    % 假设 concatenate_images1 函数已定义
    output_folder_C_L_curve_fit = fullfile("ellip_pic", Dtype, "C_L", iOr, "curve_fit");
    concatenate_images1(output_folder_C_L_curve_fit, 5); % 合并 C_L 曲线图
    % 这里可以添加其他曲线图的合并调用
    % output_folder_long_axis_curve_fit = fullfile("ellip_pic", Dtype, "long_axis", iOr, "curve_fit");
    % concatenate_images1(output_folder_long_axis_curve_fit, 5);
end
% 主脚本结束

