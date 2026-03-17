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
overall_x_min = -30;
overall_x_max = 30;
overall_y_min = -30;
overall_y_max = 30;
% 定义用于不同 hml 类型（hd65, md65, ld65）的颜色
colors_hml = hsv(3); % 例如，使用 hsv colormap 生成3种不同的颜色
file_names = {'hd65.mat', 'md65.mat', 'ld65.mat'};

% --- 控制开关 ---
% 强制使用 'axes_match' 优化，不再提供 lsqcurvefit 选项
fit_type = 'axes_match'; % 尽管我们移除了第一轮绘图，这个变量仍指示了拟合 scale_factor 的方法
optimization_label = 'AxesMatch'; % 直接定义优化标签

for i_obs = 1:length(obs_types)
    obs_type = obs_types(i_obs);
    for i_nation = 1:length(nations)
        nation = nations(i_nation);
        nation_serial = strcat(num2str(i_nation), nation);
        % find_typical_model 假设已在别处定义
        model = find_typical_model(i_nation);
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
                
                % 加载 C_L 数据 (a_CL 参数)
                C_L_data_path = fullfile('ellip_pic', Dtype, 'C_L', iOr, obs_type, ...
                    strcat(attribute_serial, '_curve_params.mat'));
                if exist(C_L_data_path, 'file')
                    C_L_data = load(C_L_data_path);
                    % 确保 a_CL_all 的维度与 i_nation 匹配
                    a_CL = C_L_data.a_CL_all(i_nation,:);
                else
                    fprintf('文件 %s 未找到，无法进行亮度补偿。跳过此组合。\n', C_L_data_path);
                    continue; 
                end
                % 存储椭圆参数、亮度值和 lab_group 数据
                all_par = cell(1, length(file_names));
                all_ave_curr_z = zeros(1, length(file_names));
                all_lab_group = cell(1, length(file_names));
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
                % 初始化 a1_base 为第一个有效数据的参数，作为基准椭圆参数
                a1_base = []; 
                for k = 1:length(all_par)
                    if ~isempty(all_par{k}) && ~any(isnan(all_par{k})) 
                        a1_base = all_par{k};
                        break; 
                    end
                end
                if isempty(a1_base)
                    fprintf('未能找到用于 f1 基准的有效参数（可能为空或含NaN）。跳过当前组合。\n');
                    continue;
                end
                
                % 初始化 scale_factor_values 数组，用于存储优化得到的缩放因子
                scale_factor_values = zeros(length(file_names), 1);
                
                % 优化选项
                opts_min = optimset('Display', 'off'); % 用于 fminbnd

                % --- 计算 scale_factor_values (AxesMatch 优化) ---
                for i_hml = 1:length(file_names)
                    a_current_hml = all_par{i_hml};
                    if isempty(a_current_hml) || any(isnan(a_current_hml))
                        fprintf('跳过 %s 的 scale_factor 计算，原因：参数为空或包含 NaN。\n', file_names{i_hml});
                        % 为无效数据点设置一个默认值，或者 NaN，确保数组长度一致
                        scale_factor_values(i_hml) = NaN; 
                        continue;
                    end
                    
                    % 获取当前 hml 椭圆的轴长
                    [A_current_hml, B_current_hml, ~] = calculate_ellipse_axes_from_par(a_current_hml);
                    
                    % 定义目标函数：最小化轴长平均值的差异
                    objective_func_axes = @(sf) objective_function_for_axes_match(sf, a1_base, a_CL, all_ave_curr_z(i_hml), A_current_hml, B_current_hml);
                    
                    % fminbnd 适用于单变量函数，需要定义搜索区间
                    lower_bound = 0.01;
                    upper_bound = 20.0; % 根据实际情况调整此范围
                    
                    % 优化找到最佳的 scale_factor
                    [scale_factor_values(i_hml), ~] = fminbnd(objective_func_axes, lower_bound, upper_bound, opts_min);
                end
                
                %%% 拟合 scale_factor 曲线并保存 %%%
                % 确保只有有效的 L* 和 scale_factor 值参与拟合
                valid_indices = all_ave_curr_z > 0 & scale_factor_values ~= 0 & ~isnan(scale_factor_values) & ~isinf(scale_factor_values);

                if sum(valid_indices) >= 2 
                    L_values_for_fit = all_ave_curr_z'; 
                    SF_values_for_fit = scale_factor_values; 
                    
                    % 定义拟合函数: scale_factor = a_scale(1) * log(L) + a_scale(2)
                    fit_func = @(coeffs, L) coeffs(1) .* log(L) + coeffs(2);
                    
                    % 初始猜测值
                    initial_coeffs = [0.1, 0.5]; 
                    
                    % 使用 lsqcurvefit 进行拟合，得到最终的 a_scale
                    opts_fit_curve = optimoptions('lsqcurvefit', 'Display', 'off');
                    [a_scale, ~, ~, ~, ~] = lsqcurvefit(fit_func, initial_coeffs, L_values_for_fit, SF_values_for_fit, [], [], opts_fit_curve);
                    
                    % 保存 a_scale 参数 (以及 a_CL, L_values_for_fit, etc.)
                    save_folder_fit_params = fullfile('AnalyseResults1', Dtype, 'scale_factor_fit_results', obs_type,iOr, nation, gender);
                    if ~exist(save_folder_fit_params, 'dir')
                        mkdir(save_folder_fit_params);
                    end
                    % 将 a1_base 也保存下来，以便 get_par_fr_SF 可以访问原始基准参数
                    save(fullfile(save_folder_fit_params, sprintf('a_scale_%s.mat', attribute_serial)), ...
                        'a_scale', "a_CL","L_values_for_fit","SF_values_for_fit","all_ave_curr_z","all_par", "a1_base"); 
                    fprintf('拟合参数 a_scale 已保存到 %s。\n', save_folder_fit_params);

                    % 绘制拟合曲线图
                    h_fig_fit = figure('Name', sprintf('Scale Factor Fit for %s-%s-%s-%s', obs_type, nation, gender, attribute_names_new(attribute)));
                    scatter(L_values_for_fit, SF_values_for_fit, 'o', 'DisplayName', 'Data Points');
                    hold on;
                    
                    L_plot = linspace(min(L_values_for_fit), max(L_values_for_fit), 100);
                    SF_fitted = fit_func(a_scale, L_plot);
                    plot(L_plot, SF_fitted, 'r-', 'LineWidth', 1.5, 'DisplayName', 'Fitted Curve');
                    
                    xlabel('Average Current L*');
                    ylabel('Scale Factor');
                    title(sprintf('Scale Factor vs. L* for %s %s %s (%s)', obs_type, nation, gender, attribute_names_new(attribute)));
                    legend('Location', 'best');
                    grid on;
                    save_folder_fit_curves = fullfile('AnalyseResults1', Dtype, 'scale_factor_curves', obs_type, iOr,nation, gender);
                    if ~exist(save_folder_fit_curves, 'dir')
                        mkdir(save_folder_fit_curves);
                    end
                    saveas(h_fig_fit, fullfile(save_folder_fit_curves, sprintf('ScaleFactor_Curve_%s_%s_%s_%s.png', obs_type, nation, gender, attribute_serial)));
                    close(h_fig_fit); % 关闭图窗

                    % --- 绘制最终等高线图 (使用 get_par_fr_SF 逻辑) ---
                    h_fig_contour_get_par_fr_SF = figure('Name', sprintf('Contours (get_par_fr_SF Logic) for %s-%s-%s-%s', obs_type, nation, gender, attribute_names_new(attribute)));
                    hold on;
                    grid on;
                    axis equal;
                    % 确定当前图的绘制范围 - get_par_fr_SF Plot
                    current_x_min = overall_x_min;
                    current_x_max = overall_x_max;
                    current_y_min = overall_y_min;
                    current_y_max = overall_y_max;
                    legend_entries_get_par_fr_SF = {};
                    for i_hml = 1:length(file_names)
                        a_current_hml = all_par{i_hml};
                        lab_group_current_hml = all_lab_group{i_hml};
                        
                        if isempty(a_current_hml) || isempty(lab_group_current_hml) || any(isnan(a_current_hml))
                            continue; % 跳过无效数据
                        end
                        % 定义函数 f (实际拟合的椭圆)，用于比较
                        f_current = @(xdata) (1./(1+a_current_hml(6)*exp(sqrt(a_current_hml(1)*(xdata(:,1)-a_current_hml(4)).^2+a_current_hml(2)*(xdata(:,2)-a_current_hml(5)).^2 ...
                            +a_current_hml(3)*(xdata(:,1)-a_current_hml(4)).*(xdata(:,2)-a_current_hml(5))))));
                        
                        % --- 调用 get_par_fr_SF 来获取用于绘图的 par_adjusted ---
                        % get_par_fr_SF 期望 all_par 是一个 cell 数组，且其第一个元素是基准参数
                        % 注意：get_par_fr_SF 函数需要确保存在并已添加到路径中
                        par_plot = get_par_fr_SF(all_ave_curr_z(i_hml), a_scale, a_CL, {a1_base});
                        
                        % 定义 f1_final，使用 get_par_fr_SF 得到的 par_plot
                        f1_final_from_get_par_fr_SF = @(x,y) (1./(1+par_plot(6)*exp(sqrt(par_plot(1)*(x-par_plot(4)).^2+par_plot(2)*(y-par_plot(5)).^2 ...
                            +par_plot(3)*(x-par_plot(4)).*(y-par_plot(5))))));
                        
                        % 绘制 f1_final_from_get_par_fr_SF 的等高线 (实线)
                        h_f1_final = fcontour(f1_final_from_get_par_fr_SF, [current_x_min current_x_max current_y_min current_y_max], ...
                            'LevelList', [0.5, 1], 'LineStyle', '-');
                        set(h_f1_final, 'LineColor', colors_hml(i_hml,:));
                        set(h_f1_final, 'LineWidth', 1.5);
                        legend_entries_get_par_fr_SF{end+1} = sprintf('f1 (get_par_fr_SF, %s)', file_names{i_hml}(1:end-4));
                        
                        % 绘制 f (实际) 的等高线 (虚线)
                        h_f_final = fcontour(@(x,y) f_current([x,y]), [current_x_min current_x_max current_y_min current_y_max], ...
                            'LevelList', [0.5, 1], 'LineStyle', '--');
                        set(h_f_final, 'LineColor', colors_hml(i_hml,:));
                        set(h_f_final, 'LineWidth', 1.5);
                        legend_entries_get_par_fr_SF{end+1} = sprintf('f (Actual, %s)', file_names{i_hml}(1:end-4));
                        % 散点绘制 lab_group 数据
                        scatter(lab_group_current_hml(:,2), lab_group_current_hml(:,3), 30, colors_hml(i_hml,:), 'filled', 'MarkerFaceAlpha', 0.5);
                        legend_entries_get_par_fr_SF{end+1} = sprintf('Data Points (%s)', file_names{i_hml}(1:end-4));
                    end
                    % 添加 x=0 和 y=0 的轴
                    line([0, 0], [overall_y_min, overall_y_max], 'Color', 'k', 'LineStyle', '--', 'DisplayName', 'X=0 Axis'); 
                    line([overall_x_min, overall_x_max], [0, 0], 'Color', 'k', 'LineStyle', '--', 'DisplayName', 'Y=0 Axis');
                    
                    % 添加 45 度线
                    plot([min(overall_x_min, overall_y_min), max(overall_x_max, overall_y_max)], ...
                         [min(overall_x_min, overall_y_min), max(overall_x_max, overall_y_max)], ...
                         'Color', [0.5 0.5 0.5], 'LineStyle', ':', 'DisplayName', '45 Degree Line');
                    xlabel('a*');
                    ylabel('b*');
                    title(sprintf('Contours (get_par_fr_SF Logic) for %s %s %s (%s)', obs_type, nation, gender, attribute_names_new(attribute)));
                    xlim([overall_x_min, overall_x_max]);
                    ylim([overall_y_min, overall_y_max]);
                    % 保存最终等高线图
                    save_folder_contour_get_par_fr_SF = fullfile('AnalyseResults1', ...
                        Dtype, 'ContourPlots_get_par_fr_SF_Logic', obs_type, ...
                        nation, gender, attribute_serial);
                    if ~exist(save_folder_contour_get_par_fr_SF, 'dir')
                        mkdir(save_folder_contour_get_par_fr_SF);
                    end
                    saveas(h_fig_contour_get_par_fr_SF, fullfile(save_folder_contour_get_par_fr_SF, sprintf('Contours_get_par_fr_SF_%s_%s_%s_%s.png', obs_type, nation, gender, attribute_serial)));
                    close(h_fig_contour_get_par_fr_SF); % 关闭图窗
                else
                    fprintf('数据点不足（少于2个）或无效，无法拟合 scale_factor 曲线，跳过此组合的 get_par_fr_SF 绘图。\n');
                end
            end
        end
    end
end
fprintf('所有组合的曲面绘制、拟合和保存完成。\n');