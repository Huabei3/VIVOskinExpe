function mc = calc_mean_cen(lab_group, p_group)
% CALC_MEAN_CEN  由 lab_group + p_group 计算加权均值中心 mean_cen (1×3)
%
%   L* 取 lab_group 第1列的算术均值；
%   a*, b* 取 calculate_weighted_or_simple_mean 返回的偏好中心（par_mean 第4、5列）。
%
%   输入：
%     lab_group - N×3 矩阵，Lab 值
%     p_group   - N×1 向量，opinion scores
%
%   输出：
%     mc - 1×3 向量 [L*, a*, b*]，若输入为空则返回 [NaN NaN NaN]

mc = nan(1, 3);
if isempty(lab_group) || isempty(p_group)
    return;
end

[par_mean, ~] = calculate_weighted_or_simple_mean(p_group, lab_group);
mc(1)   = mean(lab_group(:, 1), 'omitnan');
mc(2:3) = par_mean(1, 4:5);

end
