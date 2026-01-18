function ttest_results = perform_ttest_2groups(data1, data2,pathname, varargin)
% 对两组数据进行t检验（每组数据有5个维度）
% 
% 输入参数：
%   data1 - 第一组数据，n×5矩阵
%   data2 - 第二组数据，m×5矩阵
%   varargin - 可选参数：
%     'Paired' - 是否为配对样本检验，默认false
%     'Alpha' - 显著性水平，默认0.05
%     'VarianceEqual' - 方差齐性假设，true为等方差，false为异方差
%                       默认根据方差齐性检验自动选择
%     'Display' - 是否显示结果，默认true
% 
% 输出参数：
%   ttest_results - 包含所有检验结果的结构体

%% 参数解析
p = inputParser;
addRequired(p, 'data1', @isnumeric);
addRequired(p, 'data2', @isnumeric);
addParameter(p, 'Paired', false, @islogical);
addParameter(p, 'Alpha', 0.05, @(x) x>0 && x<1);
addParameter(p, 'VarianceEqual', 'auto', @(x) islogical(x) || strcmpi(x, 'auto'));
addParameter(p, 'Display', true, @islogical);
parse(p, data1, data2, varargin{:});

% 获取参数
paired_test = p.Results.Paired;
alpha = p.Results.Alpha;
variance_equal = p.Results.VarianceEqual;
display_results = p.Results.Display;

%% 数据验证
% 检查数据维度
[n1, dims1] = size(data1);
[n2, dims2] = size(data2);

if dims1 ~= 5 || dims2 ~= 5
    error('每组数据必须有5个维度');
end

if paired_test && n1 ~= n2
    error('配对检验要求两组数据样本数相同');
end

%% 初始化结果结构
ttest_results = struct();
ttest_results.Group1 = struct('N', n1, 'Means', [], 'Std', []);
ttest_results.Group2 = struct('N', n2, 'Means', [], 'Std', []);
ttest_results.Alpha = alpha;
ttest_results.Paired = paired_test;
ttest_results.Dimensions = 1:5;

% 存储各维度检验结果
ttest_results.Dim1 = [];
ttest_results.Dim2 = [];
ttest_results.Dim3 = [];
ttest_results.Dim4 = [];
ttest_results.Dim5 = [];

%% 计算基本统计量
ttest_results.Group1.Means = mean(data1, 1);
ttest_results.Group1.Std = std(data1, 0, 1);
ttest_results.Group2.Means = mean(data2, 1);
ttest_results.Group2.Std = std(data2, 0, 1);

%% 对每个维度分别进行t检验
for dim = 1:5
    % 提取当前维度的数据
    data1_dim = data1(:, dim);
    data2_dim = data2(:, dim);
    
    % 自动判断方差齐性（如果设置为'auto'）
    if ischar(variance_equal) && strcmpi(variance_equal, 'auto')
        % 进行方差齐性检验
        [~, p_var] = vartest2(data1_dim, data2_dim);
        equal_var = p_var > alpha;  % 如果p>alpha，则接受方差齐性假设
    else
        equal_var = variance_equal;
    end
    
    if paired_test
        % 配对样本t检验
        [h, p_val, ci, stats] = ttest(data1_dim, data2_dim, 'Alpha', alpha);
        test_type = '配对样本t检验';
    else
        % 独立样本t检验
        if equal_var
            [h, p_val, ci, stats] = ttest2(data1_dim, data2_dim, 'Alpha', alpha, 'Vartype', 'equal');
            test_type = '独立样本t检验（等方差）';
        else
            [h, p_val, ci, stats] = ttest2(data1_dim, data2_dim, 'Alpha', alpha, 'Vartype', 'unequal');
            test_type = '独立样本t检验（异方差）';
        end
    end
    
    % 计算效应量（Cohen's d）
    if paired_test
        % 配对样本的Cohen's d
        diff_data = data1_dim - data2_dim;
        cohen_d = mean(diff_data) / std(diff_data);
    else
        % 独立样本的Cohen's d
        pooled_std = sqrt(((n1-1)*std(data1_dim)^2 + (n2-1)*std(data2_dim)^2) / (n1+n2-2));
        cohen_d = (mean(data1_dim) - mean(data2_dim)) / pooled_std;
    end
    
    % 判断显著性
    if h == 1
        significance = sprintf('显著 (p<%.3f)', alpha);
    else
        significance = sprintf('不显著 (p>%.3f)', alpha);
    end
    
    % 存储结果到结构体
    dim_result = struct();
    dim_result.Dimension = dim;
    dim_result.TestType = test_type;
    dim_result.Hypothesis = h;
    dim_result.PValue = p_val;
    dim_result.ConfidenceInterval = ci;
    dim_result.tStatistic = stats.tstat;
    dim_result.DegreesOfFreedom = stats.df;
    dim_result.CohenD = cohen_d;
    dim_result.Significance = significance;
    dim_result.Mean1 = mean(data1_dim);
    dim_result.Mean2 = mean(data2_dim);
    dim_result.Std1 = std(data1_dim);
    dim_result.Std2 = std(data2_dim);
    dim_result.EqualVariance = equal_var;
    
    % 存入结果结构
    switch dim
        case 1
            ttest_results.Dim1 = dim_result;
        case 2
            ttest_results.Dim2 = dim_result;
        case 3
            ttest_results.Dim3 = dim_result;
        case 4
            ttest_results.Dim4 = dim_result;
        case 5
            ttest_results.Dim5 = dim_result;
    end
    
    % 显示结果
    if display_results
        fprintf('\n=== 维度 %d ===\n', dim);
        fprintf('检验类型: %s\n', test_type);
        fprintf('样本数: 组1=%d, 组2=%d\n', n1, n2);
        fprintf('均值: 组1=%.4f, 组2=%.4f\n', mean(data1_dim), mean(data2_dim));
        fprintf('标准差: 组1=%.4f, 组2=%.4f\n', std(data1_dim), std(data2_dim));
        fprintf('t统计量: %.4f\n', stats.tstat);
        fprintf('自由度: %.2f\n', stats.df);
        fprintf('p值: %.6f\n', p_val);
        fprintf('95%%置信区间: [%.4f, %.4f]\n', ci(1), ci(2));
        fprintf('效应量 (Cohen''s d): %.4f\n', cohen_d);
        fprintf('结果: %s\n', significance);
        
        % 解释效应量
        if abs(cohen_d) < 0.2
            effect_size = '很小';
        elseif abs(cohen_d) < 0.5
            effect_size = '小';
        elseif abs(cohen_d) < 0.8
            effect_size = '中等';
        else
            effect_size = '大';
        end
        fprintf('效应量大小: %s\n', effect_size);
    end
end

%% 多重比较校正（可选）
if display_results
    fprintf('\n=== 多重比较校正建议 ===\n');
    fprintf('您进行了5次独立的t检验，可以考虑进行多重比较校正：\n');
    fprintf('1. Bonferroni校正: 将显著性水平调整为 %.6f\n', alpha/5);
    fprintf('2. FDR校正: 控制错误发现率\n');
end

%% 结果汇总表格
if display_results
    fprintf('\n=== 结果汇总 ===\n');
    fprintf('%-8s %-12s %-12s %-10s %-10s %-12s %-12s %-15s\n', ...
        '维度', '均值1', '均值2', 'p值', 't值', 'Cohen''s d', '效应量', '显著性');
    fprintf('%s\n', repmat('-', 85, 1));
    
    for dim = 1:5
        switch dim
            case 1
                r = ttest_results.Dim1;
            case 2
                r = ttest_results.Dim2;
            case 3
                r = ttest_results.Dim3;
            case 4
                r = ttest_results.Dim4;
            case 5
                r = ttest_results.Dim5;
        end
        
        % 判断效应量大小
        d_abs = abs(r.CohenD);
        if d_abs < 0.2
            effect_str = '很小';
        elseif d_abs < 0.5
            effect_str = '小';
        elseif d_abs < 0.8
            effect_str = '中等';
        else
            effect_str = '大';
        end
        
        fprintf('%-8d %-12.4f %-12.4f %-10.6f %-10.4f %-12.4f %-12s %-15s\n', ...
            dim, r.Mean1, r.Mean2, r.PValue, r.tStatistic, r.CohenD, effect_str, r.Significance);
    end
end

%% 创建结果表格（可用于导出）
if display_results
    fprintf('\n=== 创建结果表格 ===\n');
    
    % 创建结果矩阵
    results_matrix = cell(6, 9);
    results_matrix{1, 1} = '维度';
    results_matrix{1, 2} = '组1均值';
    results_matrix{1, 3} = '组1标准差';
    results_matrix{1, 4} = '组2均值';
    results_matrix{1, 5} = '组2标准差';
    results_matrix{1, 6} = 't值';
    results_matrix{1, 7} = 'p值';
    results_matrix{1, 8} = 'Cohen''s d';
    results_matrix{1, 9} = '显著性';
    
    for dim = 1:5
        switch dim
            case 1
                r = ttest_results.Dim1;
            case 2
                r = ttest_results.Dim2;
            case 3
                r = ttest_results.Dim3;
            case 4
                r = ttest_results.Dim4;
            case 5
                r = ttest_results.Dim5;
        end
        
        results_matrix{dim+1, 1} = dim;
        results_matrix{dim+1, 2} = r.Mean1;
        results_matrix{dim+1, 3} = r.Std1;
        results_matrix{dim+1, 4} = r.Mean2;
        results_matrix{dim+1, 5} = r.Std2;
        results_matrix{dim+1, 6} = r.tStatistic;
        results_matrix{dim+1, 7} = r.PValue;
        results_matrix{dim+1, 8} = r.CohenD;
        results_matrix{dim+1, 9} = r.Significance;
    end
    
    disp(cell2table(results_matrix(2:end, :), 'VariableNames', results_matrix(1, :)));
end

%% 可选：导出结果到Excel
% if display_results
        filename='ttest_results.xlsx';
        if filename ~= 0
            fullpath = fullfile(pathname, filename);
            
            % 写入详细结果
            detailed_results = {};
            detailed_results{1, 1} = '维度';
            detailed_results{1, 2} = '检验类型';
            detailed_results{1, 3} = '组1样本数';
            detailed_results{1, 4} = '组2样本数';
            detailed_results{1, 5} = '组1均值';
            detailed_results{1, 6} = '组1标准差';
            detailed_results{1, 7} = '组2均值';
            detailed_results{1, 8} = '组2标准差';
            detailed_results{1, 9} = 't统计量';
            detailed_results{1, 10} = '自由度';
            detailed_results{1, 11} = 'p值';
            detailed_results{1, 12} = '95%CI下限';
            detailed_results{1, 13} = '95%CI上限';
            detailed_results{1, 14} = 'Cohen''s d';
            detailed_results{1, 15} = '显著性';
            
            for dim = 1:5
                switch dim
                    case 1
                        r = ttest_results.Dim1;
                    case 2
                        r = ttest_results.Dim2;
                    case 3
                        r = ttest_results.Dim3;
                    case 4
                        r = ttest_results.Dim4;
                    case 5
                        r = ttest_results.Dim5;
                end
                
                detailed_results{dim+1, 1} = dim;
                detailed_results{dim+1, 2} = r.TestType;
                detailed_results{dim+1, 3} = n1;
                detailed_results{dim+1, 4} = n2;
                detailed_results{dim+1, 5} = r.Mean1;
                detailed_results{dim+1, 6} = r.Std1;
                detailed_results{dim+1, 7} = r.Mean2;
                detailed_results{dim+1, 8} = r.Std2;
                detailed_results{dim+1, 9} = r.tStatistic;
                detailed_results{dim+1, 10} = r.DegreesOfFreedom;
                detailed_results{dim+1, 11} = r.PValue;
                detailed_results{dim+1, 12} = r.ConfidenceInterval(1);
                detailed_results{dim+1, 13} = r.ConfidenceInterval(2);
                detailed_results{dim+1, 14} = r.CohenD;
                detailed_results{dim+1, 15} = r.Significance;
            end
            
            % 写入Excel
            writetable(cell2table(detailed_results(2:end, :), 'VariableNames', detailed_results(1, :)), ...
                      fullpath, 'Sheet', '详细结果');
            
            % 写入汇总结果
            summary_results = results_matrix;
            writetable(cell2table(summary_results(2:end, :), 'VariableNames', summary_results(1, :)), ...
                      fullpath, 'Sheet', '汇总结果');
            
            fprintf('结果已保存到: %s\n', fullpath);
        end

% end
end