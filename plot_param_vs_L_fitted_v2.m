%% plot_param_vs_L_fitted_v2.m — 重写版
%  彻底放弃 copyobj-from-fig 方案，合并图直接在目标 figure 上绘制。
%  子图宽度按 xlim 范围比例分配。所有子图统一 pbaspect('auto')，
%  plot box 填满 axes 框，高度一致，宽度可独立压缩。

close all; clc; clear;
addpath("utils\")

%% ====== 配置 ======
attr_serial = "01Preference";  attribute = 1;
iOr = 'i';  CT_type = "d65";  Dtype = 'efit_p';  obs_type = "non_model";
nations_plot = ["AS","CA","SA","AF"];  n_nations = 4;
indices_target = [5, 12, 19];

%% ====== 加载拟合参数 & 原始数据 ======
params_file = fullfile('AnalyseResults_p',Dtype,"unscaled","model_fullpara",CT_type,"new",iOr,obs_type, ...
    strcat(attr_serial,'_all_curve_params.mat'));
assert(exist(params_file,'file'), 'Missing: %s', params_file);  load(params_file);

mat_data_file = fullfile("ellip_pic_p",Dtype,CT_type,strcat("data_unscaled_reshaped_",iOr,".mat"));
assert(exist(mat_data_file,'file'), 'Missing: %s', mat_data_file);
data_loaded = load(mat_data_file);
par_reshaped = data_loaded.par_reshaped;  lab_fit_reshaped = data_loaded.lab_fit_reshaped;

%% ====== 提取散点数据 ======
[L_cell, C_cell, h_cell, al_cell, as_cell, th_cell, al_cell2] = deal(cell(n_nations,1));  % alpha → al_cell2
for iN = 1:n_nations
    lab_d = lab_fit_reshaped{1,iN}(indices_target,:,:,attribute);
    par_d = par_reshaped{1,iN}(indices_target,:,:,attribute);
    [nt,~,ns] = size(lab_d);
    lab_g = reshape(permute(lab_d,[1 3 2]), nt*ns, 3);
    par_g = reshape(permute(par_d,[1 3 2]), nt*ns, 6);
    valid = ~any(isnan(lab_g),2) & ~any(isnan(par_g),2);
    Lv = lab_g(valid,1);  pv = par_g(valid,:);

    C_cell{iN} = sqrt(pv(:,4).^2 + pv(:,5).^2);
    h_cell{iN} = mod(atan2d(pv(:,5),pv(:,4)), 360);

    a_vals = -log(pv(:,6));  a_vals(isinf(a_vals)|isnan(a_vals)) = NaN;
    al_cell2{iN} = a_vals;

    lam00 = pv(:,1)./a_vals.^2;  lam01 = pv(:,3)./a_vals.^2./2;  lam11 = pv(:,2)./a_vals.^2;
    th_raw = 0.5*atan2d(2*lam01, lam00-lam11);
    A = lam00.*cosd(th_raw).^2 - lam01.*sind(2*th_raw) + lam11.*sind(th_raw).^2;
    B = lam00.*sind(th_raw).^2 + lam01.*sind(2*th_raw) + lam11.*cosd(th_raw).^2;
    A(A<=0)=NaN; B(B<=0)=NaN;
    al_cell{iN} = sqrt(1./A);  as_cell{iN} = sqrt(1./B);
    th_cell{iN} = th_raw - 360 + 90;

    L_cell{iN} = Lv;
end

%% ====== 颜色 ======
hue4 = linspace(0, 1, 5)';  hue4 = hue4(1:4);
hsv_m = [hue4, 0.8*ones(4,1), 0.8*ones(4,1)];
colors = hsv2rgb(hsv_m);  colors(3,:)=[0 0 0];  colors(4,:)=[1 0.5 0];

output_dir = fullfile('ellip_pic_p',Dtype,CT_type,'param_vs_L_fitted');
if ~exist(output_dir,'dir'), mkdir(output_dir); end

%% ====== 定义 6 张子图 ======
% col: {Y_cell, a_fit, fit_func, xlabel_str, xlim_vec, safe_name}
defs = {
  C_cell,  a_CL_all(1:4,:),         @(a,L)a(1)*log(L)+a(2),           '\itC^*_{\rmab}',  [0,30],   'Cstar';
  h_cell,  a_hue_angle_all(1:4,:),  @(a,L)a(1)*ones(size(L)),         '\ith \rm(°)',     [30,60],  'h';
  al_cell, a_long_axis_all(1:4,:),  @(a,L)a(1)*L.^3+a(2)*L.^2+a(3)*L+a(4), '\ita_{\rmmaj}', [0,20], 'along';
  as_cell, a_short_axis_all(1:4,:), @(a,L)a(1)*L.^3+a(2)*L.^2+a(3)*L+a(4), '\itb_{\rmmin}', [0,20], 'ashort';
  th_cell, a_theta_all(1:4,:),      @(a,L)(a(1)-270)*ones(size(L)),   '\itθ \rm(°)',     [0,100],  'theta';
  al_cell2,a_alpha_all(1:4,:),      @(a,L)a(1)*ones(size(L)),         '\itα',            [-5,10],  'alpha';
};
N = size(defs,1);
x_ranges = cellfun(@(v)diff(v), defs(:,5));

%% ====== 辅助函数：在一套 axes 上画 scatter + curve + 调 label 位置 ======
function draw_one_ax(ax, Y_cell, L_cell, a_fit, fit_f, xlim_v, xlab, colors)
    nN = length(Y_cell);
    for iN = 1:nN
        Yv = Y_cell{iN}; Lv = L_cell{iN};
        scatter(ax, Yv, Lv, 18, colors(iN,:), 'filled', ...
                'MarkerFaceAlpha',0.3, 'MarkerEdgeColor',colors(iN,:));
        Lfit = linspace(min(Lv),max(Lv),200)';
        Yfit = fit_f(a_fit(iN,:), Lfit);
        plot(ax, Yfit, Lfit, '-', 'Color',colors(iN,:), 'LineWidth',2);
    end
    xlim(ax, xlim_v);  ylim(ax, [0,70]);
    pbaspect(ax, 'auto');  % 所有子图统一：plot box 填满 axes，x/y 独立缩放
    box(ax, 'on');  ax.FontSize = 10;
    xlabel(ax, xlab, 'FontSize',12);
    ylabel(ax, '\itL^*', 'FontSize',12);

    % 调 label 偏移：xlabel 靠近 0.5fs，ylabel 远离 0.8fs
    xr = diff(xlim_v);  yr = 70;
    xl = ax.XLabel;  xp = xl.Position;  xl.Position = [xp(1), xp(2)-0.04*yr, xp(3)];
    yl = ax.YLabel;  yp = yl.Position;  yl.Position = [yp(1)-0.16*xr, yp(2), yp(3)];
end

%% ====== Step 1: 保存独立的 .fig ======
fprintf('===== Saving individual .fig files =====\n');
for sp = 1:N
    fig = figure('Visible','off','Position',[100,100,800,600]);
    ax = axes('Parent',fig);
    hold(ax,'on');
    draw_one_ax(ax, defs{sp,1}, L_cell, defs{sp,2}, defs{sp,3}, defs{sp,5}, defs{sp,4}, colors);
    hold(ax,'off');
    savefig(fig, fullfile(output_dir, sprintf('%s_vs_L_fitted.fig', defs{sp,6})));
    close(fig);
end
fprintf('  Done.\n');

%% ====== Step 2: 合并大图（核心：比例宽度 + 直接绘制）======
fprintf('===== Building merged figure =====\n');
figW = 2000;  figH = 420;
main_fig = figure('Name','All Params vs L*','Units','pixels', ...
                  'Position',[100,100,figW,figH], 'Visible','off');

% ------ 布局参数（normalized）------
marginL   = 0.06;    % 左留白
marginR   = 0.03;    % 右留白
marginTop = 0.06;    % 顶部留白
legendH   = 0.26;    % 底部 legend 高度（含间距），拉远~1.2fs
gap       = 0.008;   % 子图间最小间距

availableW = 1 - marginL - marginR;
availableH = 1 - marginTop - legendH;

% 每个子图的归一化宽度 = (x_range / 70) * availableH * (figH/figW)
% 这样 axis equal 的 plot box 恰好填满 [w, availableH] 的矩形
w_raw = x_ranges / 70 * availableH * figH / figW;

% ---- 手动调整个别子图宽度（1=正常，<1=压缩，>1=扩宽）----
% 所有子图统一 pbaspect('auto')，plot box 撑满 axes，高度一致，宽度可独立压缩
w_scale = ones(N,1);
w_scale(5) = 0.55;   % theta: xlim [0,100] 太宽，压缩到 55%
w_raw = w_raw .* w_scale;
total_w = sum(w_raw) + gap*(N-1);

% 如果 total_w < availableW，均匀扩大间距和边距
if total_w <= availableW
    extra = availableW - total_w;
    extra_gap = extra / N;  % 每个子图左右各半份 = per-subplot extra
else
    extra_gap = 0;
    % 总宽不足 → 缩放 w_raw
    scale = (availableW - gap*(N-1)) / sum(w_raw);
    w_raw = w_raw * scale;
end

% 计算每个 axes 的 left
left_pos = zeros(N,1);
cursor = marginL;
for sp = 1:N
    left_pos(sp) = cursor + extra_gap/2;
    cursor = left_pos(sp) + w_raw(sp) + extra_gap/2 + gap;
end

% 逐子图绘制
for sp = 1:N
    ax = axes('Parent', main_fig, 'Units','normalized', ...
              'Position', [left_pos(sp), legendH, w_raw(sp), availableH]);
    hold(ax, 'on');
    draw_one_ax(ax, defs{sp,1}, L_cell, defs{sp,2}, defs{sp,3}, defs{sp,5}, defs{sp,4}, colors);
    hold(ax, 'off');
end

% ------ 手动 legend（远离主图 ~1 fontsize）------
legAx = axes('Parent',main_fig,'Units','normalized', ...
             'Position',[0.08, 0.0, 0.84, legendH-0.08], ...
             'Color','none','Visible','off');
hold(legAx,'on'); xlim(legAx,[0,1]); ylim(legAx,[0,1]);
nation_labels = {"亚洲人","高加索人","南亚人","非洲人"};
pad = 0.10;  step = 1/(length(nation_labels)+0.3);
for k = 1:length(nation_labels)
    tx = pad + (k-1)*step;
    plot(legAx, tx, 0.5, 'o','MarkerFaceColor',colors(k,:), ...
         'MarkerEdgeColor','none','MarkerSize',10);
    text(legAx, tx+0.025, 0.5, nation_labels{k}, ...
         'FontSize',12,'VerticalAlignment','middle');
end
hold(legAx,'off');

%% ====== 保存 ======
savefig(main_fig, fullfile(output_dir, 'all_params_vs_L_merged.fig'));
exportgraphics(main_fig, fullfile(output_dir, 'all_params_vs_L_merged.png'), 'Resolution',150);
fprintf('  Merged figure saved.\n');
close(main_fig);
fprintf('===== All done. Output: %s =====\n', fullfile(pwd, output_dir));
