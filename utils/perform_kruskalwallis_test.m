function kruskal_results = perform_kruskalwallis_test(data_cell, group_names, save_path, varargin)
% 对多组数据进行Kruskal-Wallis检验并导出结果到Excel
% 
% 输入参数：
%   data_cell - 包含各组数据的元胞数组，每个元胞为n×d矩阵
%               例如：{data_group1, data_group2, data_group3}
%   group_names - 组名元胞数组，例如：{'Group1', 'Group2', 'Group3'}
%   save_path - 保存Excel文件的路径
%   varargin - 可选参数：
%     'Alpha' - 显著性水平，默认0.05
%     'Display' - 是否显示结果，默认true
%     'Filename' - Excel文件名，默认'kruskal_wallis_results.xlsx'
%     'MultipleComparison' - 是否进行事后多重比较，默认true
% 
% 输出参数：
%   kruskal_results - 包含所有检验结果的结构体

%% 参数解析
p = inputParser;
addRequired(p, 'data_cell', @iscell);
addRequired(p, 'group_names', @iscell);
addRequired(p, 'save_path', @ischar);
addParameter(p, 'Alpha', 0.05, @(x) x>0 && x<1);
addParameter(p, 'Display', true, @islogical);
addParameter(p, 'Filename', 'kruskal_wallis_results.xlsx', @ischar);
addParameter(p, 'MultipleComparison', true, @islogical);
parse(p, data_cell, group_names, save_path, varargin{:});

% 获取参数
alpha = p.Results.Alpha;
display_results = p.Results.Display;
filename = p.Results.Filename;
do_multiple_comparison = p.Results.MultipleComparison;

%% 数据验证
k = length(data_cell);  % 组数
if k < 2
    error('至少需要2组数据进行比较');
end

if length(group_names) ~= k
    error('组名数量必须与数据组数一致');
end

% 检查每组数据的维度
dims = zeros(1, k);
for i = 1:k
    if ~isnumeric(data_cell{i})
        error('第%d组数据必须是数值矩阵', i);
    end
    dims(i) = size(data_cell{i}, 2);
end

if any(dims ~= dims(1))
    error('所有组的数据必须有相同的维度数');
end

num_dims = dims(1);
if num_dims ~= 5
    warning('检测到每组数据有%d个维度，但函数设计用于处理5个维度', num_dims);
end

%% 初始化结果结构
kruskal_results = struct();
kruskal_results.GroupNames = group_names;
kruskal_results.NumGroups = k;
kruskal_results.NumDimensions = num_dims;
kruskal_results.Alpha = alpha;

% 存储各组统计信息
for i = 1:k
    kruskal_results.(['Group_' num2str(i)]) = struct(...
        'Name', group_names{i}, ...
        'N', size(data_cell{i}, 1), ...
        'Medians', median(data_cell{i}, 1), ...
        'IQRs', iqr(data_cell{i}, 1), ...
        'Means', mean(data_cell{i}, 1), ...
        'StdDevs', std(data_cell{i}, 0, 1) ...
    );
end

% 存储各维度检验结果
for dim = 1:num_dims
    kruskal_results.(['Dim_' num2str(dim)]) = [];
end

%% 对每个维度分别进行Kruskal-Wallis检验
for dim = 1:num_dims
    fprintf('\n=== 正在进行维度 %d 的Kruskal-Wallis检验 ===\n', dim);
    
    % 准备当前维度的数据
    all_data = [];
    group_labels = [];
    
    for i = 1:k
        current_data = data_cell{i}(:, dim);
        all_data = [all_data; current_data];
        group_labels = [group_labels; i * ones(size(current_data))];
    end
    
    % 执行Kruskal-Wallis检验
    [p_val, tbl, stats] = kruskalwallis(all_data, group_labels, 'off');
    
    % 获取卡方统计量和自由度
    chi2_stat = tbl{2, 5};  % 卡方统计量
    df = tbl{2, 3};         % 自由度
    
    % 判断显著性
    if p_val < alpha
        significance = sprintf('显著 (p<%.3f)', alpha);
        is_significant = true;
    else
        significance = sprintf('不显著 (p>%.3f)', alpha);
        is_significant = false;
    end
    
    % 计算效应量 (Epsilon-squared)
    N = length(all_data);  % 总样本数
    epsilon_squared = (chi2_stat - df) / (N - 1);
    
    % 解释效应量大小
    if epsilon_squared < 0.01
        effect_size_str = '很小';
    elseif epsilon_squared < 0.06
        effect_size_str = '小';
    elseif epsilon_squared < 0.14
        effect_size_str = '中等';
    else
        effect_size_str = '大';
    end
    
    % 存储主要结果
    dim_result = struct();
    dim_result.Dimension = dim;
    dim_result.Chi2 = chi2_stat;
    dim_result.DF = df;
    dim_result.PValue = p_val;
    dim_result.Epsilon2 = epsilon_squared;
    dim_result.EffectSize = effect_size_str;
    dim_result.Significance = significance;
    dim_result.IsSignificant = is_significant;
    
    % 存储各组的描述性统计
    for i = 1:k
        current_data = data_cell{i}(:, dim);
        dim_result.(['Group' num2str(i) '_Median']) = median(current_data);
        dim_result.(['Group' num2str(i) '_IQR']) = iqr(current_data);
        dim_result.(['Group' num2str(i) '_Mean']) = mean(current_data);
        dim_result.(['Group' num2str(i) '_Std']) = std(current_data);
        dim_result.(['Group' num2str(i) '_N']) = length(current_data);
    end
    
    % 存入结果结构
    kruskal_results.(['Dim_' num2str(dim)]) = dim_result;
    
    %% 进行事后多重比较（如果总体显著）
    if do_multiple_comparison && is_significant && k > 2
        fprintf('  总体检验显著，进行Dunn事后检验...\n');
        
        % 使用Dunn事后检验

        % 使用MATLAB的multcompare函数
        [c, m, h, gnames] = multcompare(stats, 'Display', 'off', 'CType', 'dunn-sidak');
        
        % 存储事后比较结果
        dim_result.PostHoc = struct();
        dim_result.PostHoc.Comparisons = c;
        dim_result.PostHoc.GroupNames = gnames;
        dim_result.PostHoc.Means = m;
        
        % 解析比较结果
        num_comparisons = size(c, 1);
        posthoc_results = cell(num_comparisons + 1, 6);
        posthoc_results{1, 1} = '比较组';
        posthoc_results{1, 2} = '差值';
        posthoc_results{1, 3} = '下限';
        posthoc_results{1, 4} = '上限';
        posthoc_results{1, 5} = 'p值';
        posthoc_results{1, 6} = '显著性';
        
        for comp = 1:num_comparisons
            group1_idx = c(comp, 1);
            group2_idx = c(comp, 2);
            diff = c(comp, 3);  % 估计差值
            lower = c(comp, 4); % 置信区间下限
            upper = c(comp, 5); % 置信区间上限
            p_posthoc = c(comp, 6); % p值
            
            group1_name = group_names{group1_idx};
            group2_name = group_names{group2_idx};
            
            if p_posthoc < alpha/k  % Bonferroni校正
                sig_str = '显著';
            else
                sig_str = '不显著';
            end
            
            posthoc_results{comp+1, 1} = sprintf('%s vs %s', group1_name, group2_name);
            posthoc_results{comp+1, 2} = diff;
            posthoc_results{comp+1, 3} = lower;
            posthoc_results{comp+1, 4} = upper;
            posthoc_results{comp+1, 5} = p_posthoc;
            posthoc_results{comp+1, 6} = sig_str;
        end
        
        dim_result.PostHocTable = posthoc_results;
        

    else
        dim_result.PostHoc = [];
        dim_result.PostHocTable = [];
    end
    
    % 更新结果结构
    kruskal_results.(['Dim_' num2str(dim)]) = dim_result;
    
    %% 显示当前维度结果
    if display_results
        fprintf('卡方统计量: %.4f\n', chi2_stat);
        fprintf('自由度: %d\n', df);
        fprintf('p值: %.6f\n', p_val);
        fprintf('效应量 (ε²): %.4f (%s)\n', epsilon_squared, effect_size_str);
        fprintf('结果: %s\n\n', significance);
        
        % 显示各组中位数
        fprintf('各组的描述性统计:\n');
        fprintf('%-15s %-10s %-10s %-10s %-10s %-10s\n', ...
            '组名', '样本数', '中位数', 'IQR', '均值', '标准差');
        fprintf('%s\n', repmat('-', 65, 1));
        
        for i = 1:k
            current_data = data_cell{i}(:, dim);
            fprintf('%-15s %-10d %-10.4f %-10.4f %-10.4f %-10.4f\n', ...
                group_names{i}, ...
                length(current_data), ...
                median(current_data), ...
                iqr(current_data), ...
                mean(current_data), ...
                std(current_data));
        end
    end
end

%% 创建结果汇总表格并导出到Excel
full_path = fullfile(save_path, filename);
fprintf('\n=== 正在导出结果到Excel文件: %s ===\n', full_path);

% 确保目录存在
if ~exist(save_path, 'dir')
    mkdir(save_path);
end

%% 创建工作簿

    % 删除已存在的文件
    if exist(full_path, 'file')
        delete(full_path);
    end
    
    %% 工作表1: 汇总结果
    total_columns = 6 + k * 3;  % 6个基础列 + k组 * 3列(每组)
    summary_table = cell(num_dims + 2, 4 + k*3);
    
    % 表头
    summary_table{1, 1} = '维度';
    summary_table{1, 2} = '卡方值';
    summary_table{1, 3} = '自由度';
    summary_table{1, 4} = 'p值';
    summary_table{1, 5} = '效应量(ε²)';
    summary_table{1, 6} = '显著性';
    
    % 添加各组统计信息的表头
    col_idx = 7;
    for i = 1:k
        if col_idx <= total_columns
            summary_table{1, col_idx} = sprintf('%s-N', group_names{i});
        end
        if (col_idx+1) <= total_columns
            summary_table{1, col_idx+1} = sprintf('%s-中位数', group_names{i});
        end
        if (col_idx+2) <= total_columns
            summary_table{1, col_idx+2} = sprintf('%s-IQR', group_names{i});
        end
        col_idx = col_idx + 3;
    end
    
    % 填充数据
    for dim = 1:num_dims
        r = kruskal_results.(['Dim_' num2str(dim)]);
        
        summary_table{dim+1, 1} = dim;
        summary_table{dim+1, 2} = r.Chi2;
        summary_table{dim+1, 3} = r.DF;
        summary_table{dim+1, 4} = r.PValue;
        summary_table{dim+1, 5} = r.Epsilon2;
        summary_table{dim+1, 6} = r.Significance;
        
        col_idx = 7;
        for i = 1:k
            summary_table{dim+1, col_idx} = r.(['Group' num2str(i) '_N']);
            summary_table{dim+1, col_idx+1} = r.(['Group' num2str(i) '_Median']);
            summary_table{dim+1, col_idx+2} = r.(['Group' num2str(i) '_IQR']);
            col_idx = col_idx + 3;
        end
    end
    
    % 写入Excel
    writecell(summary_table, full_path, 'Sheet', '汇总结果');
    
    %% 工作表2: 详细结果（每个维度一个表格）
    % 创建一个包含所有维度详细结果的工作表
    detailed_table = {};
    row_idx = 1;
    
    for dim = 1:num_dims
        r = kruskal_results.(['Dim_' num2str(dim)]);
        
        % 添加维度标题
        detailed_table{row_idx, 1} = sprintf('=== 维度 %d ===', dim);
        row_idx = row_idx + 1;
        
        % 添加检验结果
        detailed_table{row_idx, 1} = 'Kruskal-Wallis检验结果:';
        row_idx = row_idx + 1;
        
        results_subtable = {
            '统计量', '值';
            '卡方值', r.Chi2;
            '自由度', r.DF;
            'p值', r.PValue;
            '效应量(ε²)', r.Epsilon2;
            '效应大小', r.EffectSize;
            '显著性', r.Significance;
        };
        
        for i = 1:size(results_subtable, 1)
            detailed_table{row_idx, 1} = results_subtable{i, 1};
            detailed_table{row_idx, 2} = results_subtable{i, 2};
            row_idx = row_idx + 1;
        end
        
        % 空行
        row_idx = row_idx + 1;
        
        % 添加各组描述性统计
        detailed_table{row_idx, 1} = '各组描述性统计:';
        row_idx = row_idx + 1;
        
        desc_header = {'组名', '样本数', '中位数', 'IQR', '均值', '标准差'};
        for i = 1:length(desc_header)
            detailed_table{row_idx, i} = desc_header{i};
        end
        row_idx = row_idx + 1;
        
        for i = 1:k
            detailed_table{row_idx, 1} = group_names{i};
            detailed_table{row_idx, 2} = r.(['Group' num2str(i) '_N']);
            detailed_table{row_idx, 3} = r.(['Group' num2str(i) '_Median']);
            detailed_table{row_idx, 4} = r.(['Group' num2str(i) '_IQR']);
            detailed_table{row_idx, 5} = r.(['Group' num2str(i) '_Mean']);
            detailed_table{row_idx, 6} = r.(['Group' num2str(i) '_Std']);
            row_idx = row_idx + 1;
        end
        
        % 添加事后比较结果（如果存在）
        if ~isempty(r.PostHocTable)
            row_idx = row_idx + 1;
            detailed_table{row_idx, 1} = '事后多重比较结果(Dunn检验):';
            row_idx = row_idx + 1;
            
            % 复制事后比较表
            posthoc_table = r.PostHocTable;
            for i = 1:size(posthoc_table, 1)
                for j = 1:size(posthoc_table, 2)
                    detailed_table{row_idx, j} = posthoc_table{i, j};
                end
                row_idx = row_idx + 1;
            end
        end
        
        % 添加分隔空行
        row_idx = row_idx + 2;
    end
    
    % 写入详细结果工作表
    writecell(detailed_table, full_path, 'Sheet', '详细结果');
    
    %% 工作表3: 效应量解释
    effect_table = {
        '效应量(ε²)范围', '效应大小解释', '说明';
        '< 0.01', '很小', '几乎没有实际意义';
        '0.01 - 0.06', '小', '有轻微效应';
        '0.06 - 0.14', '中等', '有中等效应';
        '> 0.14', '大', '有大的效应';
        '', '', '';
        '注:', 'ε² = (χ² - df) / (N - 1)', '其中N为总样本数';
        '', '', '';
        '显著性水平:', sprintf('α = %.3f', alpha), '';
        '多重比较校正:', 'Bonferroni校正', 'p < α/比较次数';
    };
    
    writecell(effect_table, full_path, 'Sheet', '效应量解释');
    
    %% 工作表4: 原始数据统计（可选）
    % 创建原始数据统计工作表
    raw_stats_table = cell(k * num_dims + 2, 6);
    raw_stats_table{1, 1} = '组名';
    raw_stats_table{1, 2} = '维度';
    raw_stats_table{1, 3} = '样本数';
    raw_stats_table{1, 4} = '最小值';
    raw_stats_table{1, 5} = '最大值';
    raw_stats_table{1, 6} = '范围';
    
    row_idx = 2;
    for i = 1:k
        for dim = 1:num_dims
            current_data = data_cell{i}(:, dim);
            
            raw_stats_table{row_idx, 1} = group_names{i};
            raw_stats_table{row_idx, 2} = dim;
            raw_stats_table{row_idx, 3} = length(current_data);
            raw_stats_table{row_idx, 4} = min(current_data);
            raw_stats_table{row_idx, 5} = max(current_data);
            raw_stats_table{row_idx, 6} = max(current_data) - min(current_data);
            
            row_idx = row_idx + 1;
        end
    end
    
    writecell(raw_stats_table, full_path, 'Sheet', '原始数据统计');
    
    fprintf('Excel文件已成功创建: %s\n', full_path);
    fprintf('包含以下工作表:\n');
    fprintf('  1. 汇总结果 - 所有维度的检验结果汇总\n');
    fprintf('  2. 详细结果 - 每个维度的详细检验结果\n');
    fprintf('  3. 效应量解释 - 效应量大小的解释标准\n');
    fprintf('  4. 原始数据统计 - 各组的描述性统计\n');
    


%% 显示最终汇总
if display_results
    fprintf('\n=== Kruskal-Wallis检验完成 ===\n');
    fprintf('总组数: %d\n', k);
    fprintf('维度数: %d\n', num_dims);
    fprintf('显著性水平: α = %.3f\n', alpha);
    
    % 显示显著性总结
    fprintf('\n显著性总结:\n');
    for dim = 1:num_dims
        r = kruskal_results.(['Dim_' num2str(dim)]);
        fprintf('维度 %d: %s (p=%.6f, ε²=%.4f)\n', ...
            dim, r.Significance, r.PValue, r.Epsilon2);
    end
end

%% 可选：绘制箱线图（如果组数不多）
if display_results && k <= 5
    plot_choice = input('\n是否绘制箱线图？(y/n): ', 's');
    if strcmpi(plot_choice, 'y')
        figure('Position', [100, 100, 1200, 800]);
        
        for dim = 1:min(num_dims, 5)  % 最多显示5个维度
            subplot(2, 3, dim);
            
            % 准备当前维度数据
            plot_data = [];
            for i = 1:k
                plot_data = [plot_data; data_cell{i}(:, dim)];
            end
            
            % 创建组标签
            plot_labels = {};
            for i = 1:k
                plot_labels = [plot_labels; repmat(group_names(i), size(data_cell{i}, 1), 1)];
            end
            
            % 绘制箱线图
            boxplot(plot_data, plot_labels);
            title(sprintf('维度 %d - 箱线图', dim));
            ylabel('值');
            grid on;
            
            % 添加显著性标注
            r = kruskal_results.(['Dim_' num2str(dim)]);
            if r.IsSignificant
                text(0.5, 0.95, sprintf('p=%.4f**', r.PValue), ...
                    'Units', 'normalized', 'HorizontalAlignment', 'center', ...
                    'FontWeight', 'bold', 'Color', 'r');
            else
                text(0.5, 0.95, sprintf('p=%.4f', r.PValue), ...
                    'Units', 'normalized', 'HorizontalAlignment', 'center');
            end
        end
        
        if num_dims > 5
            subplot(2, 3, 6);
            text(0.5, 0.5, sprintf('共%d个维度\n显示前5个', num_dims), ...
                'HorizontalAlignment', 'center', 'FontSize', 12);
        end
        
        sgtitle('Kruskal-Wallis检验 - 各组数据分布');
        
        % 保存图片
        save_plot = input('是否保存箱线图？(y/n): ', 's');
        if strcmpi(save_plot, 'y')
            plot_filename = fullfile(save_path, 'kruskal_wallis_boxplots.png');
            saveas(gcf, plot_filename);
            fprintf('箱线图已保存: %s\n', plot_filename);
        end
    end
end
end