classdef MultiIlluminantReflectancePredictor < handle
    % MultiIlluminantReflectancePredictor: 多光源反射光谱预测器
    % 输入N个(XYZ_target, illu_spd)对，优化一个光谱使其在所有光源下的平均CIEDE2000最小
    
    properties (Access = private)
        CMFs_xyz_data       % (Dx3 double) 标准观察者颜色匹配函数 
        ReflectanceDB       % (struct) 反射光谱数据库
        isDataLoaded        % (logical) 标记数据是否已加载
    end
    
    methods
        function obj = MultiIlluminantReflectancePredictor()
            obj.isDataLoaded = false;
        end
        
        function obj = load_data(obj, cmfs_data_input, reflectance_db_path)
            % load_data: 加载颜色匹配函数和反射光谱数据库
            % cmfs_data_input: Dx3 double, D是波长点数
            if isnumeric(cmfs_data_input) && size(cmfs_data_input,2) == 3
                obj.CMFs_xyz_data = cmfs_data_input;
            else
                error('CMF数据必须是一个Dx3的double类型矩阵。');
            end
            if exist(reflectance_db_path, 'file')
                obj.ReflectanceDB = load(reflectance_db_path);
            else
                error('反射光谱数据库文件 "%s" 未找到。', reflectance_db_path);
            end
            obj.isDataLoaded = true;
        end
        
        function [RefP_out, results_per_illuminant, mean_de00, optimization_info] = predict_ref_multi(...
                obj, XYZ_targets_Nx3, illu_ref_NxD, Type_idx, illu_XYZ_ref_white_Nx3)
            % predict_ref_multi: 多光源反射光谱预测
            %
            % 输入:
            %   XYZ_targets_Nx3 (Nx3 double): N个样本在各自光源下的目标XYZ值
            %   illu_ref_NxD (NxD double): N个光源的光谱 (D是波长点数，如31对应400:10:700)
            %   Type_idx (integer): 数据库类型索引 (0-'all', 1-'coating', 2-'printing', 3-'skin', ...)
            %   illu_XYZ_ref_white_Nx3 (Nx3 double, optional): N个光源的参考白XYZ值，用于Lab转换
            %
            % 输出:
            %   RefP_out (1xD double): 优化的反射光谱 (0-100范围)
            %   results_per_illuminant: 每个光源下的预测结果
            %   mean_de00 (scalar): 平均CIEDE2000
            %   optimization_info: 优化信息
            
            if ~obj.isDataLoaded
                error('请先调用 load_data 方法加载所需数据。');
            end
            
            [n_illuminants, D] = size(illu_ref_NxD);
            
            if size(XYZ_targets_Nx3,1) ~= n_illuminants
                error('XYZ_targets和illu_ref的行数必须一致。');
            end
            
            % 检查CMFs维度是否匹配
            if size(obj.CMFs_xyz_data,1) ~= D
                error('CMF数据的行数(%d)必须与illu_ref的列数(%d)一致', size(obj.CMFs_xyz_data,1), D);
            end
            
            % 如果没有提供illu_XYZ_ref_white，使用默认白点
            if nargin < 5 || isempty(illu_XYZ_ref_white_Nx3)
                illu_XYZ_ref_white_Nx3 = repmat([95, 100, 105], n_illuminants, 1);
            end
            
            % 获取数据库
            rdata = obj.get_reflectance_data(Type_idx);
            
            % 检查数据库光谱维度是否匹配
            if size(rdata,2) ~= D
                error('数据库光谱的列数(%d)必须与illu_ref的列数(%d)一致', size(rdata,2), D);
            end
            
            % 为每个光源计算归一化SPD和A矩阵
            S_illuminants = cell(n_illuminants, 1);
            A_matrices = cell(n_illuminants, 1);
            
            for i = 1:n_illuminants
                S_custom = illu_ref_NxD(i, :)';
                
                % 归一化使理想白板Y=100
                Y_unnormalized = sum(obj.CMFs_xyz_data(:,2) .* S_custom);
                normalization_ratio = 100.0 / Y_unnormalized;
                S_illuminants{i} = S_custom * normalization_ratio;
                
                % A矩阵: CMFs * SPD (3xD)
                A_matrices{i} = (obj.CMFs_xyz_data .* S_illuminants{i})';
            end
            
            % 初始猜测：从数据库中选择最接近的
            initial_ref = obj.get_initial_guess(XYZ_targets_Nx3(1,:), illu_XYZ_ref_white_Nx3(1,:), rdata);
            
            % 使用fmincon优化
            lb = zeros(D,1);
            ub = ones(D,1);
            
            options = optimoptions('fmincon', ...
                'Algorithm', 'interior-point', ...
                'Display', 'off', ...
                'MaxIterations', 1000, ...
                'MaxFunctionEvaluations', 5000);
            
            objective = @(ref) obj.compute_multi_illuminant_objective(...
                ref, XYZ_targets_Nx3, illu_XYZ_ref_white_Nx3, A_matrices);
            
            [ref_optimized, ~, exitflag, output] = fmincon(objective, initial_ref, ...
                [], [], [], [], lb, ub, [], options);
            
            % 计算最终结果
            RefP_out = ref_optimized' * 100.0; % 转为0-100
            
            results_per_illuminant = struct();
            mean_de00 = 0;
            
            for i = 1:n_illuminants
                XYZ_pred = A_matrices{i} * ref_optimized;
                lab_target = xyz2lab(XYZ_targets_Nx3(i,:), 'user', illu_XYZ_ref_white_Nx3(i,:));
                lab_pred = xyz2lab(XYZ_pred', 'user', illu_XYZ_ref_white_Nx3(i,:));
                de00 = deltaE2000(lab_target, lab_pred);
                
                results_per_illuminant(i).XYZ_pred = XYZ_pred';
                results_per_illuminant(i).lab_pred = lab_pred;
                results_per_illuminant(i).de00 = de00;
                
                mean_de00 = mean_de00 + de00;
            end
            mean_de00 = mean_de00 / n_illuminants;
            
            optimization_info.exitflag = exitflag;
            optimization_info.output = output;
            optimization_info.D = D;
        end
    end
    
    methods (Access = private)
        function rdata = get_reflectance_data(obj, Type_idx)
            if Type_idx == 1
                rdata = obj.ReflectanceDB.R_Coating;
            elseif Type_idx == 2
                rdata = obj.ReflectanceDB.R_Printing;
            elseif Type_idx == 3
                rdata = obj.ReflectanceDB.R_Skin;
            elseif Type_idx == 4
                rdata = obj.ReflectanceDB.R_Plastics;
            elseif Type_idx == 5
                rdata = obj.ReflectanceDB.R_Textile;
            elseif Type_idx == 6
                rdata = obj.ReflectanceDB.R_Cotton;
            elseif Type_idx == 7
                rdata = obj.ReflectanceDB.R_Polyester;
            elseif Type_idx == 0
                rdata = obj.ReflectanceDB.R_alltypes;
            else
                error('未知的Type_idx: %d', Type_idx);
            end
        end
        
        function initial_ref = get_initial_guess(obj, XYZ_target, XYZ_ref_white, rdata)
            % 从数据库中选择与目标XYZ色差最小的作为初始猜测
            lab_target = xyz2lab(XYZ_target, 'user', XYZ_ref_white);
            
            n_db = size(rdata, 1);
            D = size(rdata, 2);
            lab_db = zeros(n_db, 3);
            
            for i = 1:n_db
                ref_0_1 = rdata(i,:) / 100.0;
                XYZ_calc = obj.CMFs_xyz_data' * ref_0_1';
                XYZ_calc = XYZ_calc / XYZ_calc(2) * 100;
                lab_db(i,:) = xyz2lab(XYZ_calc', 'user', XYZ_ref_white);
            end
            
            % 找最小的
            [~, idx] = min(arrayfun(@(i) deltaE2000(lab_db(i,:), lab_target), 1:n_db));
            initial_ref = rdata(idx, :)' / 100.0;
        end
        
        function obj_value = compute_multi_illuminant_objective(obj, ref_Dx1, ...
                XYZ_targets_Nx3, illu_XYZ_ref_white_Nx3, A_matrices)
            % 计算所有光源下的平均CIEDE2000
            n_illuminants = size(XYZ_targets_Nx3, 1);
            total_de00 = 0;
            
            for i = 1:n_illuminants
                XYZ_pred = A_matrices{i} * ref_Dx1;
                lab_target = xyz2lab(XYZ_targets_Nx3(i,:), 'user', illu_XYZ_ref_white_Nx3(i,:));
                lab_pred = xyz2lab(XYZ_pred', 'user', illu_XYZ_ref_white_Nx3(i,:));
                de00 = deltaE2000(lab_target, lab_pred);
                total_de00 = total_de00 + de00;
            end
            
            obj_value = total_de00 / n_illuminants;
        end
    end
end