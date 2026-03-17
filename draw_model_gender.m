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

% 定义 L* 值的绘制范围和步长，用于生成连续曲面
L_plot_min = 20; % 假设的最小L*值
L_plot_max = 90; % 假设的最大L*值
num_L_steps = 30; % L* 轴上的步数
L_plot = linspace(L_plot_min, L_plot_max, num_L_steps);

% 定义 a* 和 b* 的网格，用于等高线或曲面
grid_res = 100; % 网格分辨率

% 定义一维坐标向量，用于 isosurface 和 isonormals
x_coords = linspace(overall_x_min, overall_x_max, grid_res); % a* 的一维坐标
y_coords = linspace(overall_y_min, overall_y_max, grid_res); % b* 的一维坐标
l_coords = L_plot; % L* 的一维坐标 (已经是)

for i_obs = 1:length(obs_types)
    obs_type = obs_types(i_obs);
    for i_nation = 1:length(nations)
        nation = nations(i_nation);
        nation_serial = strcat(num2str(i_nation), nation);
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

                fprintf('--- Generating 3D Surface for: ObsType=%s, Nation=%s, Gender=%s, Attribute=%s ---\n', obs_type, nation, gender, attribute_names_new(attribute));

                % 构造参数文件的路径并加载
                save_folder_fit_params = fullfile('AnalyseResults1', Dtype, 'scale_factor_fit_results', obs_type, iOr, nation, gender);
                param_file_path = fullfile(save_folder_fit_params, sprintf('a_scale_%s.mat', attribute_serial));

                if exist(param_file_path, 'file')
                    param_data = load(param_file_path);
                    a_scale = param_data.a_scale;
                    a_CL = param_data.a_CL;
                    
                    if isfield(param_data, 'all_par') && ~isempty(param_data.all_par)
                        a1_base_original = param_data.all_par{1}; % 使用第一个 hml 的 par 作为基准
                        if isempty(a1_base_original) || any(isnan(a1_base_original))
                            fprintf('基准参数 a1_base_original 为空或包含NaN，跳过当前组合的3D曲面生成。\n');
                            continue;
                        end
                    else
                         fprintf('param_data 中未找到 all_par 或为空，无法获取基准参数。跳过当前组合的3D曲面生成。\n');
                         continue;
                    end
                    
                    if isfield(param_data, 'all_ave_curr_z') && ~isempty(param_data.all_ave_curr_z)
                        L_actual_min = min(param_data.all_ave_curr_z);
                        L_actual_max = max(param_data.all_ave_curr_z);
                        l_coords = linspace(L_actual_min, L_actual_max, num_L_steps); % 更新 L_plot
                    else
                        fprintf('警告：未找到 all_ave_curr_z，使用默认L*范围 [%.1f, %.1f]。\n', L_plot_min, L_plot_max);
                    end

                else
                    fprintf('未找到参数文件 %s。跳过此组合的3D曲面生成。\n', param_file_path);
                    continue;
                end
                
                % --- 核心修改：重新定义 meshgrid 以匹配 Z_surface 的维度顺序 ---
                % 我们希望 X 轴是 a*，Y 轴是 b*，Z 轴是 L*
                % Z_surface 的维度顺序是 (a*, b*, L*)，即 (grid_res, grid_res, num_L_steps)
                % meshgrid 仍然使用一维坐标向量生成三维网格
                [X_grid, Y_grid, L_grid_for_meshgrid] = meshgrid(x_coords, ... % X 对应 a*
                                                                 y_coords, ... % Y 对应 b*
                                                                 l_coords); % Z 对应 L*
                
                % 初始化 3D 曲面数据存储
                Z_surface = zeros(grid_res, grid_res, num_L_steps);

                % 遍历每个 L* 值，计算对应的 f1_final 表面
                for i_L = 1:num_L_steps
                    current_L = l_coords(i_L); % 使用更新后的 l_coords

                    % 计算当前 L* 对应的 scale_factor
                    current_scale_factor = a_scale(1) .* log(current_L) + a_scale(2);

                    % 补偿 a1_base 的中心 (a*, b*)
                    a1_base_compensated = a1_base_original; % 使用原始基准参数的副本
                    
                    C_aft = (a_CL(1) .* log(current_L) + a_CL(2));
                    C_bf = sqrt(a1_base_compensated(4).^2 + a1_base_compensated(5).^2);
                    if C_bf ~= 0 % 避免除以零
                        a1_base_compensated(4:5) = a1_base_compensated(4:5) .* (C_aft ./ C_bf);
                    else
                        fprintf('警告：基准中心在原点，L*=%f 时的中心补偿无法按比例进行。\n', current_L);
                    end

                    % 定义当前 L* 下的 f1_final 函数
                    f1_current_L = @(xdata) (1./(1+a1_base_compensated(6)*exp(sqrt(a1_base_compensated(1)*(xdata(:,1)-a1_base_compensated(4)).^2+a1_base_compensated(2)*(xdata(:,2)-a1_base_compensated(5)).^2 ...
                        +a1_base_compensated(3)*(xdata(:,1)-a1_base_compensated(4)).*(xdata(:,2)-a1_base_compensated(5)))))).*current_scale_factor;
                    
                    % 针对当前 L*，从 X_grid 和 Y_grid 中取出对应切片的数据
                    current_X_slice = X_grid(:,:,i_L);
                    current_Y_slice = Y_grid(:,:,i_L);
                    
                    % 将切片数据转换为 N x 2 格式以传入 f1_current_L
                    XY_data_slice = [current_X_slice(:), current_Y_slice(:)];

                    % 计算当前 L* 对应的曲面 Z 值
                    Z_current_L_flat = f1_current_L(XY_data_slice);
                    Z_surface(:,:,i_L) = reshape(Z_current_L_flat, grid_res, grid_res);
                end

                % 绘制 3D 曲面
                h_fig_3d = figure('Name', sprintf('3D Surface for %s-%s-%s-%s', obs_type, nation, gender, attribute_names_new(attribute)));
                
                isovalue = 0.5; 
                
                % 获取 patch 句柄，以便传递给 isonormals
                patch_handle = patch(isosurface(X_grid, Y_grid, L_grid_for_meshgrid, Z_surface, isovalue), 'FaceColor', 'blue', 'EdgeColor', 'none', 'FaceAlpha', 0.6);
                
                % --- 核心修改：为 isonormals 提供一维坐标向量 ---
                isonormals(X_grid, Y_grid, L_grid_for_meshgrid, Z_surface, patch_handle); % 仍然需要 patch_handle
                % 或者更常用且可能更稳定的方式是使用一维向量作为网格定义
                % isonormals(x_coords, y_coords, l_coords, Z_surface, patch_handle);

                xlabel('a*');
                ylabel('b*');
                zlabel('L* (Brightness)'); % 确保 L* 是 Z 轴
                title(sprintf('3D Contour Surface (f1_final = %.1f) for %s %s %s (%s)', isovalue, obs_type, nation, gender, attribute_names_new(attribute)));
                view(3); % 3D 视图
                grid on;
                axis tight;
                camlight; % 添加光源
                lighting gouraud; % Gouraud 光照，使表面更平滑

                % 保存 3D 曲面图
                save_folder_3d_surfaces = fullfile('AnalyseResults1', Dtype, '3D_Surfaces', obs_type, iOr, nation, gender);
                if ~exist(save_folder_3d_surfaces, 'dir')
                    mkdir(save_folder_3d_surfaces);
                end
                saveas(h_fig_3d, fullfile(save_folder_3d_surfaces, sprintf('3DSurface_%s_%s_%s_%s.png', obs_type, nation, gender, attribute_serial)));
                saveas(h_fig_3d, fullfile(save_folder_3d_surfaces, sprintf('3DSurface_%s_%s_%s_%s.fig', obs_type, nation, gender, attribute_serial))); % 保存fig文件以便后续编辑
                close(h_fig_3d); % 关闭图窗
            end
        end
    end
end
fprintf('所有组合的 3D 曲面生成和保存完成。\n');

