% 测试 model_C_L_BIC 函数的行为
close all; clc; clear;

% 测试1：正常数据
fprintf('=== 测试1：正常数据 ===\n');
L_test = [20; 30; 40; 50; 60];
C_test = [10; 12; 14; 16; 18];
[a_C_L, RSS, BIC, k] = model_C_L_BIC(L_test, C_test, 4);
fprintf('  正常数据: a_C_L = [%s], RSS = %s, BIC = %s, k = %d\n', ...
    mat2str(a_C_L), mat2str(RSS), mat2str(BIC), k);

% 测试2：包含NaN的数据
fprintf('\n=== 测试2：包含NaN的数据 ===\n');
L_test2 = [20; NaN; 40; 50; 60];
C_test2 = [10; 12; 14; NaN; 18];
[a_C_L2, RSS2, BIC2, k2] = model_C_L_BIC(L_test2, C_test2, 4);
fprintf('  包含NaN数据: a_C_L = [%s], RSS = %s, BIC = %s, k = %d\n', ...
    mat2str(a_C_L2), mat2str(RSS2), mat2str(BIC2), k2);

% 测试3：数据点不足
fprintf('\n=== 测试3：数据点不足（n=2） ===\n');
L_test3 = [20; 30];
C_test3 = [10; 12];
[a_C_L3, RSS3, BIC3, k3] = model_C_L_BIC(L_test3, C_test3, 4);
fprintf('  数据点不足: a_C_L = [%s], RSS = %s, BIC = %s, k = %d\n', ...
    mat2str(a_C_L3), mat2str(RSS3), mat2str(BIC3), k3);

% 测试4：L <= 0 的数据
fprintf('\n=== 测试4：L <= 0 的数据 ===\n');
L_test4 = [-10; 0; 30; 40; 50];
C_test4 = [5; 8; 12; 14; 16];
[a_C_L4, RSS4, BIC4, k4] = model_C_L_BIC(L_test4, C_test4, 4);
fprintf('  L <= 0数据: a_C_L = [%s], RSS = %s, BIC = %s, k = %d\n', ...
    mat2str(a_C_L4), mat2str(RSS4), mat2str(BIC4), k4);

% 测试5：实际数据（从调试脚本中提取）
fprintf('\n=== 测试5：实际数据 ===\n');
L_real = [14.38; 18.02; 21.66; 28.94; 34.31; 39.67; 45.03; 50.39; 55.75; 56.05; 50.69; 45.33; 39.97; 34.61; 29.25];
C_real = [8.87; 11.48; 12.27; 13.29; 14.08; 14.57; 15.30; 16.03; 16.98; 18.92; 17.43; 16.21; 15.29; 14.42; 13.42];
[a_C_L5, RSS5, BIC5, k5] = model_C_L_BIC(L_real, C_real, 4);
fprintf('  实际数据: a_C_L = [%s], RSS = %s, BIC = %s, k = %d\n', ...
    mat2str(a_C_L5, 4), mat2str(RSS5, 4), mat2str(BIC5, 4), k5);

% 测试6：检查 model_C_L_BIC 内部逻辑
fprintf('\n=== 测试6：model_C_L_BIC 内部逻辑 ===\n');
fprintf('  手动调用 fit_with_restarts:\n');
n_params = 2;
options = optimset('MaxFunEvals', 500000, 'Display', 'off');
f = @(a, x) a(1)*log(x) + a(2);
valid_indices = ~isnan(L_real) & ~isnan(C_real) & L_real > 0;
L_valid = L_real(valid_indices);
C_valid = C_real(valid_indices);
n = length(L_valid);
fprintf('  L_valid大小: %d, C_valid大小: %d\n', length(L_valid), length(C_valid));

% 直接调用 lsqcurvefit 测试
try
    a0 = [1, 1];
    a = lsqcurvefit(f, a0, L_valid, C_valid, -inf(1,2), inf(1,2), options);
    y = f(a, L_valid);
    rss = sum((C_valid - y).^2);
    fprintf('  lsqcurvefit成功: a = [%.4f, %.4f], RSS = %.4f\n', a(1), a(2), rss);
catch ME
    fprintf('  lsqcurvefit失败: %s\n', ME.message);
end

% 测试 fit_with_restarts 函数
fprintf('\n  测试 fit_with_restarts 函数:\n');
[a_best, RSS_best] = fit_with_restarts(f, L_valid, C_valid, 2, options);
fprintf('  fit_with_restarts结果: a_best = [%s], RSS_best = %.4f\n', ...
    mat2str(a_best, 4), RSS_best);