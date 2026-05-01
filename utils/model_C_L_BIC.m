function [a_val, RSS, BIC, k] = model_C_L_BIC(L_data, C_data, fit_CL_type)
% MODEL_C_L_BIC  对 C*-L* 关系进行多种候选公式拟合，返回拟合参数、RSS、BIC 和参数数
%
% 输入:
%   L_data      - L* 数据向量 (Nx1)
%   C_data      - C* 数据向量 (Nx1)
%   fit_CL_type - 公式类型编号:
%       1 = 常数:       C = a1                     (k=1)
%       2 = 线性:       C = a1*L + a2              (k=2)
%       3 = 二次:       C = a1*L^2 + a2*L + a3     (k=3)
%       4 = 对数:       C = a1*log(L) + a2         (k=2)
%       5 = 分段线性-常数: C = a1*L + a2 (L<=L0), C = a3 (L>L0)  (k=3, L0为拟合参数)
%
% 输出:
%   a_val - 拟合参数向量
%   RSS   - 残差平方和 sum((C_pred - C_true)^2)
%   BIC   - 贝叶斯信息准则: n*log(RSS/n) + k*log(n)
%   k     - 参数数量

a_val = NaN;
RSS = NaN;
BIC = NaN;
k = NaN;

% --- 检查并移除 NaN ---
valid_indices = ~isnan(L_data) & ~isnan(C_data) & L_data > 0;
L_valid = L_data(valid_indices);
C_valid = C_data(valid_indices);
n = length(L_valid);

if n < k_minimum(fit_CL_type)
    return;
end

options = optimset('MaxFunEvals', 500000, 'Display', 'off');

switch fit_CL_type
    case 1  % 常数: C = a1
        k = 1;
        a_val = mean(C_valid);
        RSS = sum((C_valid - a_val).^2);

    case 2  % 线性: C = a1*L + a2
        k = 2;
        f = @(a, x) a(1)*x + a(2);
        [a_val, RSS] = fit_with_restarts(f, L_valid, C_valid, 2, options);

    case 3  % 二次: C = a1*L^2 + a2*L + a3
        k = 3;
        f = @(a, x) a(1)*x.^2 + a(2)*x + a(3);
        [a_val, RSS] = fit_with_restarts(f, L_valid, C_valid, 3, options);

    case 4  % 对数: C = a1*log(L) + a2
        k = 2;
        % 确保 L > 0 (已由 valid_indices 保证)
        f = @(a, x) a(1)*log(x) + a(2);
        [a_val, RSS] = fit_with_restarts(f, L_valid, C_valid, 2, options);

    case 5  % 分段线性-常数: C = a1*L + a2 (L<=L0), C = a3 (L>L0)
        k = 3;  % a1, a2, a3 (L0 作为第4个参数一起拟合, k=4)
        k = 4;  % a1, a2, a3, L0
        f_seg = @(a, x) segmented_linear_const(x, a);
        % L0 的搜索范围: [min(L), max(L)]
        L0_min = min(L_valid);
        L0_max = max(L_valid);
        lb = [-inf, -inf, -inf, L0_min];
        ub = [inf, inf, inf, L0_max];
        [a_val, RSS] = fit_with_restarts_seg(f_seg, L_valid, C_valid, lb, ub, options);

    otherwise
        warning('未知的 fit_CL_type: %d', fit_CL_type);
        return;
end

% --- 计算 BIC ---
if ~isnan(RSS) && RSS > 0
    BIC = n * log(RSS / n) + k * log(n);
end

end


%% ========== 辅助函数 ==========

function kmin = k_minimum(fit_CL_type)
% 返回每种公式所需的最小数据点数
switch fit_CL_type
    case 1, kmin = 1;
    case 2, kmin = 3;
    case 3, kmin = 4;
    case 4, kmin = 3;
    case 5, kmin = 5;  % 4个参数 + 分段结构
    otherwise, kmin = 1;
end
end


function [a_best, RSS_best] = fit_with_restarts(f, L_valid, C_valid, n_params, options)
% 多次随机初始化的 lsqcurvefit
a_best = NaN(1, n_params);
RSS_best = inf;
n_restarts = 500;

for t = 1:n_restarts
    a0 = randn(1, n_params);
    try
        a = lsqcurvefit(f, a0, L_valid, C_valid, ...
            -inf(1, n_params), inf(1, n_params), options);
        y = f(a, L_valid);
        rss = sum((C_valid - y).^2);
        if rss < RSS_best
            RSS_best = rss;
            a_best = a;
        end
    catch
        continue;
    end
end
end


function [a_best, RSS_best] = fit_with_restarts_seg(f_seg, L_valid, C_valid, lb, ub, options)
% 分段模型的多次随机初始化
n_params = length(lb);
a_best = NaN(1, n_params);
RSS_best = inf;
n_restarts = 1000;

for t = 1:n_restarts
    a0 = zeros(1, n_params);
    a0(1) = randn;       % a1
    a0(2) = randn * 10;  % a2 (偏置量级较大)
    a0(3) = randn * 20;  % a3 (C*常数项)
    a0(4) = min(L_valid) + rand * (max(L_valid) - min(L_valid)); % L0
    try
        a = lsqcurvefit(f_seg, a0, L_valid, C_valid, lb, ub, options);
        y = f_seg(a, L_valid);
        rss = sum((C_valid - y).^2);
        if rss < RSS_best
            RSS_best = rss;
            a_best = a;
        end
    catch
        continue;
    end
end
end


function C_pred = segmented_linear_const(L, a)
% 分段线性-常数模型
% a(1) = a1, a(2) = a2, a(3) = a3 (常数), a(4) = L0 (断点)
a1 = a(1);
a2 = a(2);
a3 = a(3);
L0 = a(4);

C_pred = zeros(size(L));
low_mask = L <= L0;
high_mask = L > L0;

C_pred(low_mask) = a1 * L(low_mask) + a2;
C_pred(high_mask) = a3;
end
