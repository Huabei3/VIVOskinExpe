function plot_n_drop_scatter_contour(ipr_fig, nation_serial, dropped_lastPart, attr_name, pcn_n, train_indices, pic_folder)
% plot_n_drop_scatter_contour
% 封装 scatter_L_depend_n_drop1.m 的绘图逻辑
%
% 输入:
%   ipr_fig          - struct, 含 lab_group, p_group, lab_undrop, p_undrop,
%                      par_ell, par_exp, par_fullpara, L_val_model
%   nation           - string, 当前 nation
%   dropped_lastPart - string, 被 drop 的 subject 标签
%   attr_name        - string, attribute 名称
%   pcn_n            - string, 当前 pcn 名称
%   train_indices    - vector, 训练集索引（用于统计 undrop 人数）
%   pic_folder       - string, 图片保存根目录

    if isempty(ipr_fig.lab_group) || isempty(ipr_fig.p_group)
        return;  % 无散点数据则跳过
    end

    fig = figure('Visible', 'on');
    hold on;

    % --- scatter: dropped subject（实心圆）---
    scatter(ipr_fig.lab_group(:, 2), ipr_fig.lab_group(:, 3), ...
        40, ipr_fig.p_group, 'filled');

    % --- scatter: undropped subjects（空心圆，灰色边缘）---
    if ~isempty(ipr_fig.lab_undrop) && ~isempty(ipr_fig.p_undrop)
        scatter(ipr_fig.lab_undrop(:, 2), ipr_fig.lab_undrop(:, 3), ...
            25, ipr_fig.p_undrop, ...
            'MarkerFaceColor', 'none', 'MarkerEdgeColor', [0.5 0.5 0.5], 'LineWidth', 0.8);
    end

    % --- contour: par_ell（红色实线）---
    if ~isempty(ipr_fig.par_ell)
        par = ipr_fig.par_ell;
        check_d2 = par(4) + (-30:0.2:30);
        check_d3 = par(5) + (-30:0.2:30);
        [d2, d3] = meshgrid(check_d2, check_d3);
        y_c = (1./(1 + par(6) * exp(sqrt(par(1)*(d2-par(4)).^2 + par(2)*(d3-par(5)).^2 ...
            + par(3)*(d2-par(4)).*(d3-par(5)))))) .* ...
            ((par(1)*(d2-par(4)).^2 + par(2)*(d3-par(5)).^2 ...
            + par(3)*(d2-par(4)).*(d3-par(5))) >= 0);
        contour(d2, d3, y_c, [0.5, 1], ...
            'LineStyle', '-', 'LineColor', 'r', 'LineWidth', 2);
        scatter(par(4), par(5), 60, 'r', 'filled', 'Marker', 'x');
    end

    % --- contour: par_exp（黑色虚线，dropped subject 原椭圆）---
    if ~isempty(ipr_fig.par_exp) && length(ipr_fig.par_exp) >= 6
        par_e = ipr_fig.par_exp;
        check_d2_e = par_e(4) + (-30:0.2:30);
        check_d3_e = par_e(5) + (-30:0.2:30);
        [d2e, d3e] = meshgrid(check_d2_e, check_d3_e);
        y_e = (1./(1 + par_e(6) * exp(sqrt(par_e(1)*(d2e-par_e(4)).^2 + par_e(2)*(d3e-par_e(5)).^2 ...
            + par_e(3)*(d2e-par_e(4)).*(d3e-par_e(5)))))) .* ...
            ((par_e(1)*(d2e-par_e(4)).^2 + par_e(2)*(d3e-par_e(5)).^2 ...
            + par_e(3)*(d2e-par_e(4)).*(d3e-par_e(5))) >= 0);
        contour(d2e, d3e, y_e, [0.5, 1], ...
            'LineStyle', '--', 'LineColor', 'k', 'LineWidth', 1.5);
    end

    % --- contour: par_fullpara（蓝色实线）---
    if ~isempty(ipr_fig.par_fullpara) && length(ipr_fig.par_fullpara) >= 6
        par_fp = ipr_fig.par_fullpara;
        check_d2_fp = par_fp(4) + (-30:0.2:30);
        check_d3_fp = par_fp(5) + (-30:0.2:30);
        [d2fp, d3fp] = meshgrid(check_d2_fp, check_d3_fp);
        y_fp = (1./(1 + par_fp(6) * exp(sqrt(par_fp(1)*(d2fp-par_fp(4)).^2 + par_fp(2)*(d3fp-par_fp(5)).^2 ...
            + par_fp(3)*(d2fp-par_fp(4)).*(d3fp-par_fp(5)))))) .* ...
            ((par_fp(1)*(d2fp-par_fp(4)).^2 + par_fp(2)*(d3fp-par_fp(5)).^2 ...
            + par_fp(3)*(d2fp-par_fp(4)).*(d3fp-par_fp(5))) >= 0);
        contour(d2fp, d3fp, y_fp, [0.5, 1], ...
            'LineStyle', '-', 'LineColor', 'b', 'LineWidth', 2);
    end

    % --- 参考线 ---
    all_a = ipr_fig.lab_group(:, 2);
    all_b = ipr_fig.lab_group(:, 3);
    lim_max = max(max(all_a), max(all_b)) + 10;
    lim_min = min(min(all_a), min(all_b)) - 10;
    line([0, 0], [lim_min, lim_max], 'Color', [0.5 0.5 0.5], 'LineStyle', '--');
    line([lim_min, lim_max], [0, 0], 'Color', [0.5 0.5 0.5], 'LineStyle', '--');
    refline(1, 0);

    axis equal;
    xlim([lim_min, lim_max]);
    ylim([lim_min, lim_max]);
    xlabel('{\ita*}');  ylabel('{\itb*}');
    n_undrop = length(train_indices);
    title_str = sprintf('%s | %s | drop=%s | undrop=%d | attr=%s | L=%.1f', ...
        nation_serial, pcn_n, dropped_lastPart, n_undrop, attr_name, ipr_fig.L_val_model);
    title(title_str, 'Interpreter', 'none');
    colorbar;

    % --- 图例 ---
    lgd_h = [];
    lgd_l = {};
    if ~isempty(ipr_fig.par_ell)
        [~, h1] = contour(d2, d3, y_c, [0.5, 1], ...
            'LineStyle', '-', 'LineColor', 'r', 'LineWidth', 2);
        lgd_h(end+1) = h1; lgd_l{end+1} = 'par_{ell} (fit)'; %#ok<AGROW>
    end
    if ~isempty(ipr_fig.par_exp) && length(ipr_fig.par_exp) >= 6
        [~, h2] = contour(d2e, d3e, y_e, [0.5, 1], ...
            'LineStyle', '--', 'LineColor', 'k', 'LineWidth', 1.5);
        lgd_h(end+1) = h2; lgd_l{end+1} = 'par_{all} (orig)'; %#ok<AGROW>
    end
    if ~isempty(ipr_fig.par_fullpara) && length(ipr_fig.par_fullpara) >= 6
        [~, h3] = contour(d2fp, d3fp, y_fp, [0.5, 1], ...
            'LineStyle', '-', 'LineColor', 'b', 'LineWidth', 2);
        lgd_h(end+1) = h3; lgd_l{end+1} = 'par_{fullpara}'; %#ok<AGROW>
    end
    % 实心/空心散点的图例占位符
    ph1 = plot(NaN, NaN, 'o', 'MarkerSize', 6, ...
        'MarkerFaceColor', [0.8 0.4 0.4], 'MarkerEdgeColor', 'none');
    ph2 = plot(NaN, NaN, 'o', 'MarkerSize', 6, ...
        'MarkerFaceColor', 'none', 'MarkerEdgeColor', [0.5 0.5 0.5], 'LineWidth', 0.8);
    lgd_h = [lgd_h, ph1, ph2]; %#ok<AGROW>
    lgd_l = [lgd_l, {'o solid : dropped subj'}, {'o hollow: undropped'}]; %#ok<AGROW>
    if ~isempty(lgd_h)
        legend(lgd_h, lgd_l, 'Location', 'best', 'FontSize', 7);
    end

    hold off;

    % --- 保存图片 ---
    pic_subdir = fullfile(pic_folder, nation, dropped_lastPart);
    if ~exist(pic_subdir, 'dir'), mkdir(pic_subdir); end
    pic_name = sprintf('%s_%s_%s_%s.png', nation_serial, dropped_lastPart, attr_name, pcn_n);
    pic_path = fullfile(pic_subdir, pic_name);
    saveas(fig, pic_path);
    close(fig);
end
