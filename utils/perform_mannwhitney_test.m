function results = perform_mannwhitney_test(data1, data2, group_names, save_path, varargin)
% Mann-Whitney U检验（两独立样本非参数检验）
% 
% 输入参数：
%   data1 - 第一组数据，n×d矩阵
%   data2 - 第二组数据，m×d矩阵
%   group_names - 组名，如{'Group1', 'Group2'}
%   save_path - 保存Excel文件的路径
%   varargin - 可选参数：
%     'Alpha' - 显著性水平，默认0.05
%     'Display' - 是否显示结果，默认true
%     'Filename' - Excel文件名，默认'mannwhitney_results.xlsx'
% 
% 输出参数：
%   results - 包含检验结果的结构体

%% 参数解析
p = inputParser;
addRequired(p, 'data1', @isnumeric);
addRequired(p, 'data2', @isnumeric);
addRequired(p, 'group_names', @iscell);
addRequired(p, 'save_path', @ischar);
addParameter(p, 'Alpha', 0.05, @(x) x>0 && x<1);
addParameter(p, 'Display', true, @islogical);
addParameter(p, 'Filename', 'mannwhitney_results.xlsx', @ischar);
parse(p, data1, data2, group_names, save_path, varargin{:});

alpha = p.Results.Alpha;
display_results = p.Results.Display;
filename = p.Results.Filename;

%% 数据验证
if length(group_names) ~= 2
    error('需要2个组名');
end

[n1, d1] = size(data1);
[n2, d2] = size(data2);

if d1 ~= d2
    error('两组数据的维度必须相同');
end

num_dims = d1;

%% 初始化结果结构
results = struct();
results.Group1 = struct('Name', group_names{1}, 'N', n1, 'Medians', []);
results.Group2 = struct('Name', group_names{2}, 'N', n2, 'Medians', []);
results.Alpha = alpha;
results.NumDimensions = num_dims;

% 对每个维度进行检验
p_values = zeros(num_dims, 1);
U_stats = zeros(num_dims, 1);
ranksums = zeros(num_dims, 1);
med_diff = zeros(num_dims, 1);
is_significant = false(num_dims, 1);

for dim = 1:num_dims
    % 提取当前维度数据
    x = data1(:, dim);
    y = data2(:, dim);
    
    % 计算中位数和差异
    med1 = median(x);
    med2 = median(y);
    med_diff(dim) = med1 - med2;
    
    % 执行Mann-Whitney U检验
    [p_val, h, stats] = ranksum(x, y, 'alpha', alpha);
    
    p_values(dim) = p_val;
    U_stats(dim) = stats.ranksum;
    is_significant(dim) = h;
    
    % 计算效应量 (r = Z/√N)
    if isfield(stats, 'zval')
        Z = stats.zval;
        N = n1 + n2;
        r_effect = abs(Z) / sqrt(N);  % Rosenthal's r
    else
        r_effect = NaN;
    end
    
    % 存储维度结果
    results.(['Dim_' num2str(dim)]) = struct(...
        'PValue', p_val, ...
        'UStatistic', U_stats(dim), ...
        'Hypothesis', h, ...
        'Median1', med1, ...
        'Median2', med2, ...
        'MedianDiff', med_diff(dim), ...
        'EffectSize', r_effect, ...
        'Significant', h, ...
        'Significance', ifelse(h, '显著', '不显著') ...
    );
end

%% 存储结果
results.PValues = p_values;
results.UStatistics = U_stats;
results.MedianDiffs = med_diff;
results.IsSignificant = is_significant;
results.Dimensions = 1:num_dims;

%% 显示结果
if display_results
    fprintf('\n=== Mann-Whitney U检验结果 ===\n');
    fprintf('组1: %s (n=%d)\n', group_names{1}, n1);
    fprintf('组2: %s (n=%d)\n', group_names{2}, n2);
    fprintf('显著性水平: α = %.3f\n\n', alpha);
    
    fprintf('%-10s %-12s %-12s %-10s %-10s %-12s %-15s\n', ...
        '维度', '组1中位数', '组2中位数', '中位数差', 'U统计量', 'p值', '显著性');
    fprintf('%s\n', repmat('-', 75, 1));
    
    for dim = 1:num_dims
        fprintf('%-10d %-12.4f %-12.4f %-10.4f %-10.0f %-12.6f %-15s\n', ...
            dim, ...
            results.(['Dim_' num2str(dim)]).Median1, ...
            results.(['Dim_' num2str(dim)]).Median2, ...
            med_diff(dim), ...
            U_stats(dim), ...
            p_values(dim), ...
            ifelse(is_significant(dim), '显著**', '不显著'));
    end
    
    % 显著性总结
    sig_count = sum(is_significant);
    fprintf('\n总计: %d/%d个维度显著 (p<%.3f)\n', sig_count, num_dims, alpha);
end

%% 导出到Excel
full_path = fullfile(save_path, filename);
if exist(save_path, 'dir')
    fprintf('\n=== 正在导出结果到Excel文件: %s ===\n', full_path);
    
    % 创建结果表
    results_table = cell(num_dims + 2, 9);
    results_table{1, 1} = '维度';
    results_table{1, 2} = '组1中位数';
    results_table{1, 3} = '组2中位数';
    results_table{1, 4} = '中位数差';
    results_table{1, 5} = 'U统计量';
    results_table{1, 6} = 'p值';
    results_table{1, 7} = '效应量(r)';
    results_table{1, 8} = '显著性';
    results_table{1, 9} = '结论';
    
    for dim = 1:num_dims
        dim_result = results.(['Dim_' num2str(dim)]);
        
        results_table{dim+1, 1} = dim;
        results_table{dim+1, 2} = dim_result.Median1;
        results_table{dim+1, 3} = dim_result.Median2;
        results_table{dim+1, 4} = dim_result.MedianDiff;
        results_table{dim+1, 5} = dim_result.UStatistic;
        results_table{dim+1, 6} = dim_result.PValue;
        results_table{dim+1, 7} = dim_result.EffectSize;
        results_table{dim+1, 8} = ifelse(dim_result.Significant, '是', '否');
        results_table{dim+1, 9} = dim_result.Significance;
    end
    
    % 汇总行
    results_table{num_dims+2, 1} = '汇总';
    results_table{num_dims+2, 2} = sprintf('组1样本数: %d', n1);
    results_table{num_dims+2, 3} = sprintf('组2样本数: %d', n2);
    results_table{num_dims+2, 6} = sprintf('α = %.3f', alpha);
    results_table{num_dims+2, 8} = sprintf('%d/%d显著', sum(is_significant), num_dims);
    
    % 写入Excel
    writecell(results_table, full_path, 'Sheet', 'Mann-Whitney检验结果');
    
    fprintf('结果已保存到: %s\n', full_path);
end

%% 绘制箱线图
if display_results && num_dims <= 6
    plot_choice = input('\n是否绘制箱线图？(y/n): ', 's');
    if strcmpi(plot_choice, 'y')
        figure('Position', [100, 100, 1200, 800]);
        
        for dim = 1:num_dims
            subplot(2, ceil(num_dims/2), dim);
            
            % 准备数据
            x = data1(:, dim);
            y = data2(:, dim);
            
            % 绘制箱线图
            boxplot([x; y], [ones(size(x)); 2*ones(size(y))], ...
                'Labels', group_names);
            
            title(sprintf('维度 %d (p=%.4f)', dim, p_values(dim)));
            ylabel('值');
            grid on;
            
            % 添加显著性标注
            if is_significant(dim)
                text(1.5, max([x; y])*0.95, '**', ...
                    'HorizontalAlignment', 'center', ...
                    'FontSize', 16, 'FontWeight', 'bold', 'Color', 'r');
            end
        end
        
        sgtitle('Mann-Whitney U检验 - 数据分布比较');
        
        % 保存图片
        save_plot = input('是否保存箱线图？(y/n): ', 's');
        if strcmpi(save_plot, 'y')
            plot_filename = fullfile(save_path, 'mannwhitney_boxplots.png');
            saveas(gcf, plot_filename);
            fprintf('箱线图已保存: %s\n', plot_filename);
        end
    end
end
end

%% 辅助函数
function result = ifelse(condition, true_val, false_val)
if condition
    result = true_val;
else
    result = false_val;
end
end