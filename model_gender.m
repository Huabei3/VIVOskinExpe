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
% colors = hsv(length(genders)); % 在这里不再直接使用，fimplicit3 默认有颜色
obs_types = ["non_model","model_group"];
nations = ["AS", "CA", "SA", "AF"];
iOr='i';

% 定义绘制范围的估算：根据你的数据特性调整
% 这是一个初步的范围，如果曲面显示不完整，可能需要根据你实际a(4), a(5)的变化调整
overall_x_min = -10; 
overall_x_max = 10;
overall_y_min = -10;
overall_y_max = 10;

for i_obs = 1:length(obs_types)
    obs_type = obs_types(i_obs);

    for i_nation = 1:length(nations)
        nation = nations(i_nation);
        nation_serial=strcat(num2str(i_nation),nation);
        if strcmp(nation,"AS")
            attributes = [1, 2, 3, 4, 5, 6, 7,8, 9,10];
        elseif strcmp(nation,"CA")
            attributes = [1, 3, 5, 6, 7,8, 9,10];
        else
            attributes = [1, 3, 5, 6,7, 8];
        end

        if strcmp(obs_type,"non_model")
            attributes(attributes==7)=[];
        end
    
        for attribute = attributes
            attribute_serial = strcat(sprintf("%02d", attribute), ...
                attribute_names_new(attribute));

            for i_gender=1:2
                gender=genders(i_gender);
                
                fprintf('--- Processing: ObsType=%s, Nation=%s, Gender=%s ---\n', obs_type, nation, gender);
                
                % 定义文件路径
                source_folder = fullfile('AnalyseResults1',Dtype,'50',obs_type, ...
                    iOr,attribute_serial,nation_serial,gender); % 假设你的.mat文件在这个文件夹里
                file_names = {'hd65.mat', 'md65.mat', 'ld65.mat'};

                % 存储椭圆参数和亮度值
                all_par = cell(1, length(file_names));
                all_ave_curr_z = zeros(1, length(file_names));
                
                % 加载数据
                non_exist=0;
                for i = 1:length(file_names)
                    full_path = fullfile(source_folder, file_names{i});
                    if exist(full_path, 'file')
                        data = load(full_path);
                        % 确保 par 是一个 1x6 的行向量，如果不是，需要调整
                        if iscolumn(data.par)
                            all_par{i} = data.par'; 
                        else
                            all_par{i} = data.par;
                        end
                        all_ave_curr_z(i) = data.ave_curr(1); % 亮度为第三个维度坐标
                    else
                        fprintf('文件 %s 未找到，请检查路径。跳过此组合。\n', full_path);
                        % 如果文件不存在，跳过当前组合，而不是退出整个程序
                        non_exist=1;
                    end
                end
                if non_exist
                    continue; 
                end
    
                % 检查是否成功加载了数据
                if isempty(all_ave_curr_z) || all(all_ave_curr_z == 0)
                    fprintf('没有为 ObsType=%s, Nation=%s, Gender=%s 找到有效数据。跳过。\n', obs_type, nation, gender);
                    continue;
                end
                
                % 确保亮度值是递增的，以便插值
                [sorted_z, sort_idx] = sort(all_ave_curr_z);
                % sorted_par 应该是一个 Nx6 的矩阵，便于插值
                sorted_par_matrix = zeros(length(sort_idx), 6);
                for i_para = 1:length(sort_idx)
                    sorted_par_matrix(i_para,:) = all_par{sort_idx(i_para)};
                end                
                % --- 新的插值和绘制逻辑开始 ---
                
                % 检查 sorted_par_matrix 是否包含有效数据
                if isempty(sorted_par_matrix)
                    fprintf('sorted_par_matrix 为空，无法进行插值。跳过此组合。\n');
                    continue;
                end
    
                % 确保 a(6) 始终为正值，否则 log 函数会出错
                if any(sorted_par_matrix(:,6) <= 0)
                    warning('数据中存在非正的 a(6) 值，这可能导致 log(a(6)) 错误。请检查数据。');
                    % 可以在这里对 a(6) 进行处理，例如将其设置为一个很小的正数
                    sorted_par_matrix(sorted_par_matrix(:,6) <= 0, 6) = eps; 
                end
    
                % 创建 a 参数的插值函数
                % 'spline' 插值通常比 'linear' 更平滑，但可能在外推时不稳定
                % 如果数据点较少或曲线波动大，可以尝试 'linear'
                % 'spline' 是插值方法，'linear' 是外延方法
                a1_interp = griddedInterpolant(sorted_z, sorted_par_matrix(:,1), 'spline', 'nearest');
                a2_interp = griddedInterpolant(sorted_z, sorted_par_matrix(:,2), 'spline', 'nearest');
                a3_interp = griddedInterpolant(sorted_z, sorted_par_matrix(:,3), 'spline', 'nearest');
                a4_interp = griddedInterpolant(sorted_z, sorted_par_matrix(:,4), 'spline', 'nearest');
                a5_interp = griddedInterpolant(sorted_z, sorted_par_matrix(:,5), 'spline', 'nearest');
                a6_interp = griddedInterpolant(sorted_z, sorted_par_matrix(:,6), 'spline', 'nearest');
                
                % 定义 3D 隐式函数 G(x, y, z) = 0
                % 基于你的方程： (1./(1+a(6)*exp(sqrt(A))))==0.5
                % 简化为： log(a(6)) + sqrt(A) = 0
                % 其中 A = a(1)*(x-a(4)).^2 + a(2)*(y-a(5)).^2 + a(3)*(x-a(4)).*(y-a(5))
                implicit_func = @(x,y,z) log(a6_interp(z)) + ...
                    sqrt(max(0, ... % 使用 max(0, ...) 确保根号内非负，避免NaN
                        a1_interp(z).*(x - a4_interp(z)).^2 + ...
                        a2_interp(z).*(y - a5_interp(z)).^2 + ...
                        a3_interp(z).*(x - a4_interp(z)).*(y - a5_interp(z)) ...
                    ));
                
                % 定义绘制的范围
                % x 和 y 的范围可以根据你所有 a(4) 和 a(5) 的平均值和标准差来估算
                % 或者直接使用一个足够大的范围
                % 这里使用一个相对通用的范围，你可以根据数据调整
                
                % 可以根据 a(4) 和 a(5) 的范围来动态调整绘制范围
                min_a4 = min(sorted_par_matrix(:,4))-15;
                max_a4 = max(sorted_par_matrix(:,4))+15;
                min_a5 = min(sorted_par_matrix(:,5))-15;
                max_a5 = max(sorted_par_matrix(:,5))+15;
                
                % 确保范围足够覆盖椭圆的可能扩展
                x_range = [min_a4 - 15, max_a4 + 15]; 
                y_range = [min_a5 - 15, max_a5 + 15];
                z_range = [min(sorted_z)-10, max(sorted_z)+10]; 
                
                % 如果 z_range 是单个值，fimplicit3 可能会有问题，需要确保 z_data 至少有两个不同的值
                if length(unique(sorted_z)) < 2
                    fprintf('Z数据点少于2个，无法进行Z方向插值和绘制3D曲面。跳过此组合。\n');
                    continue;
                end
    
                figure_name = sprintf('Implicit Surface - %s_%s_%s', obs_type, nation, gender);
                h_fig = figure('Name', figure_name, 'NumberTitle', 'off'); % 创建带标题的图窗
                
                % 绘制曲面
                % 'MeshDensity' 控制曲面的平滑度，值越大越平滑但计算量越大
                h_surf = fimplicit3(implicit_func, [x_range, y_range, z_range], ...
                                   'FaceAlpha', 0.6, ...      % 设置曲面透明度
                                   'EdgeColor', 'none', ...   % 不显示网格边缘线
                                   'MeshDensity', 60);         % 增加网格密度
                
                % 设置图形属性
                xlabel('X');
                ylabel('Y');
                zlabel('Z (Brightness)');
                title_str = sprintf('Interpolated Ellipsoid Surface for %s-%s-%s',obs_type, nation, gender);
                title(title_str);
                grid on;
                axis equal; % 保持坐标轴比例一致，避免变形
                view(3);    % 设置三维视角
                
                % 可选：添加颜色条，如果希望颜色反映 Z 轴值
                colormap(jet); % 使用 'jet' 颜色图，你可以选择其他，如 'parula', 'viridis' 等
                cbar = colorbar('Location', 'eastoutside'); % 获取 colorbar 对象的句柄
                cbar.Label.String = 'Brightness (Z)';      % 通过句柄设置 Label 的文本内容    
    
    
                % 保存图像
                output_folder = fullfile('AnalyseResults1',Dtype,"interp_model",obs_type,iOr,attribute_serial); 
                if ~exist(output_folder, 'dir')
                    mkdir(output_folder); % 如果文件夹不存在则创建
                end
    
                interp_data_filename = fullfile(output_folder, ...
                                                strcat(nation, gender,".mat"));           
                save(interp_data_filename, ...
                     'a1_interp', 'a2_interp', 'a3_interp', ...
                     'a4_interp', 'a5_interp', 'a6_interp', ...
                     'sorted_z'); % 也可以选择保存 sorted_z 以便后续验证或使用
    
                % 保存图像
                output_folder = fullfile( 'ellip_pic',Dtype,"interp_model",obs_type,iOr,attribute_serial); 
                if ~exist(output_folder, 'dir')
                    mkdir(output_folder); % 如果文件夹不存在则创建
                end
                output_filename = fullfile(output_folder, strcat(  nation, gender,".jpg"));
                saveas(h_fig, output_filename);
                fprintf('图形已保存到: %s\n\n', output_filename);
                close(h_fig); % 关闭当前图窗以避免内存堆积
                
                % --- 新的插值和绘制逻辑结束 ---
    
            end
        end
    end
end

fprintf('所有组合的曲面绘制和保存完成。\n');