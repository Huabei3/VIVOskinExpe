close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量
addpath("utils\"); % 假设 utils\ 中有 atan2d_360, convertAngleTo90Interval, lab2xyz2, CAT16_D, calculateD, xyz2lab, deltaE2000 等函数

%% --- Configuration ---
% 原始数据源配置
Dtype_old = 'efit_p';
AnalyseFolder_old = 'AnalyseResults_p';

% 新数据源配置
Dtype_new = 'efit_p_free';
AnalyseFolder_new = 'AnalyseResults_p_free';

% 通用配置
nations=["AS","CA","SA","AF"];
lastParts = {'f04i', 'f05i', 'f06i', 'm04i', 'm05i', 'm06i',...
'f01i', 'f02i', 'f03i', 'm01i', 'm02i', 'm03i',...
'f07i', 'f08i','m07i', 'm08i',...
'f09i', 'f10i','m09i', 'm10i'};
scale_type_origin = "unscaled";
attribute_names_new = ["Preference", "Attractiveness", "Feminine", "Cooperative", ...
    "Youth", "Healthy", "Fidelity","Harmony", "Fair", "Ruddy"];
obs_types = ["non_model"]; % 只处理 non_model
wd65 = [94.811, 100.00, 107.304];

% 确定 iOr 和 n_para
iOr = lastParts{1}(end);
if iOr == 'i'
    n_para = 21;
    load('optimizedD\neutral_gray\combi_XYZw_i.mat', 'XYZ_combi',"CCT_combi");
    CT = CCT_combi;
    XYZwpre = XYZ_combi;
elseif iOr == 'r'
    n_para = 14;
    % 这些变量在 'r' 模式下可能需要定义或从文件中加载
    % 示例：CT = zeros(n_para*length(lastParts)*length(attribute_names_new), 1); 
    % 示例：XYZwpre = zeros(n_para*length(lastParts)*length(attribute_names_new), 3); 
    picnames_groups1=["1负一楼商场" ,"2负一楼vivo" ,"3下沉广场", "4学校饭堂" ,"5学校小卖部",...
    "6学校星巴克", "7草地顺光" ,"8草地侧光", "9草地逆光", "10阴天场景" ,...
    "11夕阳草地逆光", "12夕阳草地侧光", "13夜景小卖部门口", "14 极夜小卖部对面"];
end

load(fullfile("documents",iOr,"render_data.mat"),"render_map");

%% --- Main Processing Loop ---
for i_obs = 1:length(obs_types)
    obs_type = obs_types(i_obs);
    
    % 定义保存的汇总 Excel 文件名 (dE版本)
    outputFolder = fullfile("AnalyseResults_p_dE", "sum_list"); % 新建一个 dE 文件夹来保存结果
    if ~exist(outputFolder,"dir")
        mkdir(outputFolder);
    end
    summary_filename_dE = fullfile( outputFolder, ...
        strcat('characteristic_dE_',iOr,'_',obs_type,'.xlsx'));  
    if exist(summary_filename_dE, 'file')
        delete(summary_filename_dE);
    end
    
    % 初始化用于 dE 汇总的表格
    concatenated_table_dE = table();
    
    % 遍历每个 lastPart
    for lastPartIdx = 1:length(lastParts)
        lastPart = lastParts{lastPartIdx};
        
        if strcmp(lastPart(end),"i")||contains(lastPart,"add")
            n_para=21;
        elseif strcmp(lastPart(end),"r")
            n_para=14;
        end
        
        % 遍历所有 attribute
        for attribute = 1:length(attribute_names_new)
            attribute_serial = strcat(sprintf("%02d", attribute), attribute_names_new(attribute));
            
            % --- 1. 加载原始数据源 (efit_p) ---
            source_file_old = fullfile(AnalyseFolder_old, Dtype_old, scale_type_origin, lastPart, obs_type, ...
                attribute_serial, 'ellipPara', 'fitRes.mat');
            par_all_old = nan(n_para, 6);
            if exist(source_file_old, 'file')
                load(source_file_old, "par_all", "picname_check");
                par_all_old(1:size(par_all, 1), :) = par_all;
            else                
                picname_check = cell(n_para, 1);
                warning('Fit data missing for old source: %s', source_file_old);
            end

            % --- 2. 加载新数据源 (efit_p_free) ---
            source_file_new = fullfile(AnalyseFolder_new, Dtype_new, scale_type_origin, lastPart, obs_type, ...
                attribute_serial, 'ellipPara', 'fitRes.mat');
            par_all_new = nan(n_para, 6);
            if exist(source_file_new, 'file')
                load(source_file_new, "par_all"); % 变量名重复，但只取 par_all
                par_all_new(1:size(par_all, 1), :) = par_all;
            else                
                warning('Fit data missing for new source: %s', source_file_new);
            end
            
            % --- 3. 获取皮肤平均Lab值 (CAT-adapted) ---
            % 皮肤平均颜色值加载和CAT适应的代码保持不变，它依赖于lastPart
            [~, ~] = gen_lastPart1(lastPart);
            lastPart_new = gen_lastPart_new(lastPart); % gen_lastPart_new 应该能处理 lastPart
            average_file = fullfile("aveSkin", strrep(lastPart_new,"add",""), ...
                "autoNhand_scaleoverLUT.mat");
            average = load(average_file);
            average_bf = average.average_lab_all(:, 1:3); % L*a*b* before CAT
            
            % CAT 适应的 Lab 值
            Lab_all = nan(n_para, 5); % L, a, b, C, h
            for i_para = 1:n_para
                if i_para <= size(average_bf, 1) % 检查是否有平均皮肤数据
                    
                    % 假设 picname_check 中有足够的 picname
                    if i_para <= size(picname_check, 1) && ~isempty(picname_check{i_para, 1})
                        curr_cell = render_map(picname_check{i_para, 1});
                        CT_curr = curr_cell{1, 8};
                        XYZwpre_curr = curr_cell{1, 9};
                        
                        XYZ_bf_curr = lab2xyz2(average_bf(i_para, :), 'd65_64');
                        D_pre_curr = calculateD(CT_curr, 0, Dtype_old); % 这里的 Dtype 应该是 Dtype_old/new 中的一个，但由于 calculateD 内部的逻辑，它可能只取决于 CT
                        XYZt_curr = CAT16_D(XYZ_bf_curr, ...
                            XYZwpre_curr, wd65, D_pre_curr);                
                        Lab_curr = xyz2lab(XYZt_curr, 'd65_64');
                        
                        Lab_all(i_para, 1:3) = Lab_curr;
                        Lab_all(i_para, 4) = sqrt(Lab_curr(2)^2 + Lab_curr(3)^2);
                        Lab_all(i_para, 5) = atan2d_360(Lab_curr(3), Lab_curr(2));
                    else
                         % 如果没有对应的渲染图名称，则使用NaN
                         Lab_all(i_para, :) = NaN;
                    end
                else
                    Lab_all(i_para, :) = NaN;
                end
            end
            
            % --- 4. 提取 L, a, b 值 ---
            % L 值来自 CAT 适应后的皮肤平均 L*
            L_old = Lab_all(:, 1); 
            L_new = Lab_all(:, 1); % 两个数据源使用相同的 L 值

            % a*, b* 值来自拟合参数 (par_all(:, 4:5))
            ab_old = par_all_old(:, 4:5);
            ab_new = par_all_new(:, 4:5);
            
            Lab_old = [L_old, ab_old];
            Lab_new = [L_new, ab_new];
            
            % --- 5. 计算 Delta E 2000 ---
            % 使用 Delta E 2000 公式比较新旧 L*a*b*
            % Lab_old 和 Lab_new 的维度应该是 n_para x 3
            dE = zeros(n_para, 1);
            for i_para = 1:n_para
                 if all(~isnan(Lab_old(i_para, :))) && all(~isnan(Lab_new(i_para, :)))
                     % **注意: 需要你提供 deltaE2000(Lab1, Lab2) 函数的实现**
                     dE(i_para) = deltaE2000(Lab_old(i_para, :), Lab_new(i_para, :));
                 else
                     dE(i_para) = NaN;
                 end
            end
            
            % --- 6. 构建新的 Table ---
            
            % 获取 picname_group
            if iOr=='i'
                picname_group = cell(n_para, 1);
                for i_para = 1:n_para
                    if i_para<=size(picname_check,1)
                        picname_group{i_para} = picname_check{i_para, 1};
                    else
                        picname_group{i_para}="";
                    end
                end
            else
                picname_group = picnames_groups1';
            end
            
            % 获取 CCT 和 E
            CCT_col = nan(n_para, 1);
            E_col = nan(n_para, 1);
            for i_para = 1:length(picname_check)
                if ~isempty(picname_check{i_para, 1}) && isKey(render_map, picname_check{i_para, 1})
                    curr_cell = render_map(picname_check{i_para, 1});
                    CCT_col(i_para) = curr_cell{1, 8};
                    E_col(i_para) = curr_cell{1, 10};
                end
            end
            
            % 整合数据
            dE_list = table( ...
                picname_group, ...
                repmat(attribute_names_new(attribute), n_para, 1), ...
                L_old, ab_old(:, 1), ab_old(:, 2), ...
                L_new, ab_new(:, 1), ab_new(:, 2), ...
                dE, ...
                CCT_col, ...
                E_col, ...
                'VariableNames', ...
                {'picname_group', 'attribute', 'L_old', 'a_old', 'b_old', ...
                 'L_new', 'a_new', 'b_new', 'dE', 'CCT', 'E'} ...
            );
            
            % 将当前 attribute 的 table 纵向拼接到汇总 table 中
            concatenated_table_dE = [concatenated_table_dE; dE_list];
        end
        
        % 将汇总 table 写入 dE 汇总 Excel 文件
        sheet_name = gen_lastPart_new(lastPart);
        writetable(concatenated_table_dE, summary_filename_dE, 'Sheet', sheet_name);
        
        % 重置 concatenated_table_dE 以便写入下一个 lastPart 的数据
        concatenated_table_dE = table(); 

    end
    
    % 对 dE 汇总文件进行平均处理
    mean_list(summary_filename_dE, n_para); % 假设有一个 mean_list 的 dE 版本
    
    disp('所有 lastPart 的 Delta E 结果已写入汇总 Excel 文件。');
end
