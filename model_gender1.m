% 清理工作区和命令行
clear;
clc;
close all;
addpath("utils\") % 确保 'utils' 文件夹在 MATLAB 路径中

%%
% 你需要定义 Dtype 的值，根据你的实际文件结构
Dtype = 'efit2'; % <--- 请在这里设置你的 Dtype 值，例如 'someDataType'
attribute_names_new = ["Preference", "Attractiveness", "Feminine", "Cooperative", ...
    "Youth", "Healthy", "Fidelity", "Harmony", "Fair", "Ruddy"];
genders = ["f", "m"]; % 定义性别数组
obs_types = ["non_model","model_group"];
nations = ["AS", "CA", "SA", "AF"];
iOr='i';

% 定义绘制范围的估算：根据你的数据特性调整
% 这是一个初步的范围，如果曲面显示不完整，可能需要根据你实际a(4), a(5)的变化调整
overall_x_min = -30;
overall_x_max = 30;
overall_y_min = -30;
overall_y_max = 30;

% 定义用于不同 hml 类型（hd65, md65, ld65）的颜色
colors_hml = hsv(3); % 例如，使用 hsv colormap 生成3种不同的颜色
file_names = {'hd65.mat', 'md65.mat', 'ld65.mat'};

for i_obs = 1:length(obs_types)
    obs_type = obs_types(i_obs);
    for i_nation = 1:length(nations)
        nation = nations(i_nation);
        nation_serial = strcat(num2str(i_nation), nation);
        model = find_typical_model(i_nation); % 假设 find_typical_model 存在并返回字符串
        lastPart=strcat(model,iOr);

        if strcmp(nation,"AS")
            attributes = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
        elseif strcmp(nation,"CA")
            attributes = [1, 3, 5, 6, 7, 8, 9, 10];
        else
            attributes = [1, 3, 5, 6, 7, 8];
        end

        if strcmp(obs_type,"non_model")
            attributes(attributes==7)=[];
        end

        for attribute = attributes
            attribute_serial = strcat(sprintf("%02d", attribute), ...
                attribute_names_new(attribute));
            for i_gender=1:2
                gender=genders(i_gender);

                fprintf('--- Processing: ObsType=%s, Nation=%s, Gender=%s, Attribute=%s ---\n', obs_type, nation, gender, attribute_names_new(attribute));

                % 定义文件路径
                source_folder = fullfile('AnalyseResults1',Dtype,'50',obs_type, ...
                    iOr,attribute_serial,nation_serial,gender);
                labNgroup_folder = fullfile("AnalyseResults1",Dtype,lastPart,obs_type, ...
                    attribute_serial,"labNscore");
                
                % 加载 C_L 数据
                C_L_data_path = fullfile('ellip_pic', Dtype, 'C_L', iOr, obs_type, ...
                    strcat(attribute_serial, '_curve_params.mat'));
                if exist(C_L_data_path, 'file')
                    C_L_data = load(C_L_data_path);
                    % 确保 a_CL_all 的维度与 i_nation 匹配
                    a_CL = C_L_data.a_CL_all(i_nation,:);
                else
                    fprintf('文件 %s 未找到，无法进行亮度补偿。跳过此组合。\n', C_L_data_path);
                    continue; % 跳过当前循环的剩余部分
                end

                % 存储椭圆参数、亮度值和 lab_group 数据
                all_par = cell(1, length(file_names));
                all_ave_curr_z = zeros(1, length(file_names));
                all_lab_group = cell(1, length(file_names));

                % 标记是否找到有效数据
                found_valid_data = false;

                for i_hml = 1:length(file_names)
                    full_path = fullfile(source_folder, file_names{i_hml});
                    labNgroup_file = fullfile(labNgroup_folder, ...
                        strcat("labNscore_group", lastPart, file_names{i_hml}));

                    if exist(full_path, 'file') && exist(labNgroup_file, 'file')
                        data = load(full_path);
                        labNgroup_data = load(labNgroup_file, "lab_group");

                        if iscolumn(data.par)
                            all_par{i_hml} = data.par';
                        else
                            all_par{i_hml} = data.par;
                        end
                        all_ave_curr_z(i_hml) = data.ave_curr(1);
                        all_lab_group{i_hml} = labNgroup_data.lab_group;
                        found_valid_data = true; % 至少找到一组有效数据
                    else
                        fprintf('文件 %s 或 %s 未找到，跳过此组合的此hml数据。\n', full_path, labNgroup_file);
                    end
                end

                % 检查是否成功加载了数据
                if ~found_valid_data || all(cellfun(@isempty, all_par))
                    fprintf('没有为 ObsType=%s, Nation=%s, Gender=%s, Attribute=%s 找到有效数据。跳过。\n', obs_type, nation, gender, attribute_names_new(attribute));
                    continue;
                end

                % 创建一个新的图窗来绘制所有 hml 级别的等高线
                h_fig_contour = figure('Name', sprintf('Contours for %s-%s-%s-%s', obs_type, nation, gender, attribute_names_new(attribute)));
                hold on;
                grid on;
                axis equal;

                % 确定当前图的绘制范围
                current_x_min = overall_x_min;
                current_x_max = overall_x_max;
                current_y_min = overall_y_min;
                current_y_max = overall_y_max;
                
                % 遍历所有 hml 级别并绘制
                legend_entries = {};
                % 初始化 a1_base 为第一个有效数据的参数
                a1_base = []; 
                for k = 1:length(all_par)
                    if ~isempty(all_par{k}) && ~any(isnan(all_par{k})) % 检查是否为空且不含 NaN
                        a1_base = all_par{k};
                        break; % 找到第一个非空且不含 NaN 的参数作为基准
                    end
                end

                if isempty(a1_base)
                    fprintf('未能找到用于 f1 基准的有效参数（可能为空或含NaN）。跳过当前组合。\n');
                    close(h_fig_contour); % 关闭当前图窗
                    continue;
                end
                
                % 初始化 scale_factor 数组用于存储每个 hml 的值
                scale_factor_values = zeros(length(file_names), 1);

                for i_hml = 1:length(file_names)
                    a_current_hml = all_par{i_hml};
                    lab_group_current_hml = all_lab_group{i_hml};

                    if isempty(a_current_hml) || isempty(lab_group_current_hml) || any(isnan(a_current_hml))
                        fprintf('跳过 %s 的数据，原因：参数为空、lab_group为空或参数中包含 NaN。\n', file_names{i_hml});
                        continue;
                    end
                    
                    % 根据亮度对 a1_base 的中心进行补偿
                    % 注意：这里直接修改了 a1_base，这意味着每次迭代都会基于被修改的 a1_base 进行计算
                    % 如果希望每次都基于原始的 a1_base，需要在此处复制一份
                    a1_base_compensated = a1_base; % 创建一个副本进行补偿
                    
                    C_aft = (a_CL(1) .* log(all_ave_curr_z(i_hml)) + a_CL(2));
                    C_bf = sqrt(a1_base_compensated(4).^2 + a1_base_compensated(5).^2);
                    if C_bf ~= 0 % 避免除以零
                        a1_base_compensated(4:5) = a1_base_compensated(4:5) .* (C_aft ./ C_bf);
                    else
                        % 如果 C_bf 为零，说明初始中心在原点，无法按比例缩放，可以考虑跳过或采取其他处理
                        fprintf('警告：a1_base 的中心在原点，无法进行亮度补偿。跳过 %s 的补偿。\n', file_names{i_hml});
                    end
                    
                    % 定义函数 f
                    f_current = @(xdata) (1./(1+a_current_hml(6)*exp(sqrt(a_current_hml(1)*(xdata(:,1)-a_current_hml(4)).^2+a_current_hml(2)*(xdata(:,2)-a_current_hml(5)).^2 ...
                        +a_current_hml(3)*(xdata(:,1)-a_current_hml(4)).*(xdata(:,2)-a_current_hml(5))))));
                    % 预测 f 的值
                    y_f_pred = f_current(lab_group_current_hml(:, 2:3));

                    % 定义函数 f1 (需要求 scale_factor)，使用补偿后的 a1_base
                    f1_to_optimize = @(scale_factor_val, xdata) (1./(1+a1_base_compensated(6)*exp(sqrt(a1_base_compensated(1)*(xdata(:,1)-a1_base_compensated(4)).^2+a1_base_compensated(2)*(xdata(:,2)-a1_base_compensated(5)).^2 ...
                        +a1_base_compensated(3)*(xdata(:,1)-a1_base_compensated(4)).*(xdata(:,2)-a1_base_compensated(5)))))).*scale_factor_val;
                    
                    % 使用 lsqcurvefit 找到最佳的 scale_factor
                    initial_scale_factor = 1.0;
                    opts = optimoptions('lsqcurvefit', 'Display', 'off');
                    [scale_factor_values(i_hml), ~] = lsqcurvefit(f1_to_optimize, initial_scale_factor, lab_group_current_hml(:, 2:3), y_f_pred, [], [], opts);
                    
                    % 重新定义 f1，包含找到的 scale_factor 和补偿后的 a1_base
                    f1_final = @(xdata) (1./(1+a1_base_compensated(6)*exp(sqrt(a1_base_compensated(1)*(xdata(:,1)-a1_base_compensated(4)).^2+a1_base_compensated(2)*(xdata(:,2)-a1_base_compensated(5)).^2 ...
                        +a1_base_compensated(3)*(xdata(:,1)-a1_base_compensated(4)).*(xdata(:,2)-a1_base_compensated(5)))))).*scale_factor_values(i_hml);
                    
                    % 绘制 f1 的等高线 (实线)
                    h_f1 = fcontour(@(x,y) f1_final([x,y]), [current_x_min current_x_max current_y_min current_y_max], ...
                        'LevelList', [0.5, 1], 'LineStyle', '-');
                    set(h_f1, 'LineColor', colors_hml(i_hml,:));
                    set(h_f1, 'LineWidth', 1.5);
                    legend_entries{end+1} = sprintf('f1 (%s, Scaled)', file_names{i_hml}(1:end-4));

                    % 绘制 f 的等高线 (虚线)
                    h_f = fcontour(@(x,y) f_current([x,y]), [current_x_min current_x_max current_y_min current_y_max], ...
                        'LevelList', [0.5, 1], 'LineStyle', '--');
                    set(h_f, 'LineColor', colors_hml(i_hml,:));
                    set(h_f, 'LineWidth', 1.5);
                    legend_entries{end+1} = sprintf('f (%s)', file_names{i_hml}(1:end-4));

                    % 散点绘制 lab_group 数据
                    scatter(lab_group_current_hml(:,2), lab_group_current_hml(:,3), 30, colors_hml(i_hml,:), 'filled', 'MarkerFaceAlpha', 0.5);
                    legend_entries{end+1} = sprintf('Data Points (%s)', file_names{i_hml}(1:end-4));
                end

                % 添加 x=0 和 y=0 的轴
                line([0, 0], [overall_y_min, overall_y_max], 'Color', 'k', 'LineStyle', '--', 'DisplayName', 'X=0 Axis'); % x=0
                line([overall_x_min, overall_x_max], [0, 0], 'Color', 'k', 'LineStyle', '--', 'DisplayName', 'Y=0 Axis'); % y=0
                
                % 添加 45 度线
                plot([min(overall_x_min, overall_y_min), max(overall_x_max, overall_y_max)], ...
                     [min(overall_x_min, overall_y_min), max(overall_x_max, overall_y_max)], ...
                     'Color', [0.5 0.5 0.5], 'LineStyle', ':', 'DisplayName', '45 Degree Line');

                xlabel('a*');
                ylabel('b*');
                title(sprintf('Contours for %s %s %s (%s)', obs_type, nation, gender, attribute_names_new(attribute)));
                legend(legend_entries, 'Location', 'bestoutside');
                xlim([overall_x_min, overall_x_max]);
                ylim([overall_y_min, overall_y_max]);

                % 保存等高线图
                save_folder_contour = fullfile('AnalyseResults1', Dtype, 'ContourPlots', obs_type, nation, gender, attribute_serial);
                if ~exist(save_folder_contour, 'dir')
                    mkdir(save_folder_contour);
                end
                saveas(h_fig_contour, fullfile(save_folder_contour, sprintf('Contours_%s_%s_%s_%s.png', obs_type, nation, gender, attribute_serial)));
                close(h_fig_contour); % 关闭当前图窗以节省内存

                %%% 新增部分：拟合 scale_factor 曲线并保存 %%%
                % 确保 all_ave_curr_z 不包含零或负值，因为 log 函数
                valid_indices = all_ave_curr_z > 0 & scale_factor_values ~= 0;
                if sum(valid_indices) >= 2 % 至少需要两个有效点进行拟合
                    L_values_for_fit = all_ave_curr_z';
                    SF_values_for_fit = scale_factor_values;

                    % 定义拟合函数: scale_factor = a_scale(1) * log(L) + a_scale(2)
                    fit_func = @(coeffs, L) coeffs(1) .* log(L) + coeffs(2);
                    
                    % 初始猜测值
                    initial_coeffs = [0.1, 0.5]; 
                    
                    % 使用 lsqcurvefit 进行拟合
                    opts_fit = optimoptions('lsqcurvefit', 'Display', 'off');
                    [a_scale, resnorm, ~, exitflag, output] = lsqcurvefit(fit_func, initial_coeffs, L_values_for_fit, SF_values_for_fit, [], [], opts_fit);

                    % 保存 a_scale 参数
                    save_folder_fit_params = fullfile('AnalyseResults1', Dtype, 'scale_factor_fit_results', obs_type,iOr, nation, gender);
                    if ~exist(save_folder_fit_params, 'dir')
                        mkdir(save_folder_fit_params);
                    end
                    save(fullfile(save_folder_fit_params, sprintf('a_scale_%s.mat', attribute_serial)), ...
                        'a_scale', "a_CL","L_values_for_fit","SF_values_for_fit","all_ave_curr_z","all_par");
                    fprintf('拟合参数 a_scale 已保存到 %s。\n', save_folder_fit_params);

                    % 绘制拟合曲线
                    h_fig_fit = figure('Name', sprintf('Scale Factor Fit for %s-%s-%s-%s', obs_type, nation, gender, attribute_names_new(attribute)));
                    scatter(L_values_for_fit, SF_values_for_fit, 'o', 'DisplayName', 'Data Points');
                    hold on;
                    
                    % 绘制拟合曲线
                    L_plot = linspace(min(L_values_for_fit), max(L_values_for_fit), 100);
                    SF_fitted = fit_func(a_scale, L_plot);
                    plot(L_plot, SF_fitted, 'r-', 'LineWidth', 1.5, 'DisplayName', 'Fitted Curve');
                    
                    xlabel('Average Current L*');
                    ylabel('Scale Factor');
                    title(sprintf('Scale Factor vs. L* for %s %s %s (%s)', obs_type, nation, gender, attribute_names_new(attribute)));
                    legend('Location', 'best');
                    grid on;

                    % 保存拟合曲线图
                    save_folder_fit_curves = fullfile('AnalyseResults1', Dtype, 'scale_factor_curves', obs_type, iOr,nation, gender);
                    if ~exist(save_folder_fit_curves, 'dir')
                        mkdir(save_folder_fit_curves);
                    end
                    saveas(h_fig_fit, fullfile(save_folder_fit_curves, sprintf('ScaleFactor_Curve_%s_%s_%s_%s.png', obs_type, nation, gender, attribute_serial)));
                    close(h_fig_fit); % 关闭图窗
                else
                    fprintf('数据点不足（少于2个）或无效，无法拟合 scale_factor 曲线，跳过此组合。\n');
                end
            end
        end
    end
end
fprintf('所有组合的曲面绘制、拟合和保存完成。\n');

