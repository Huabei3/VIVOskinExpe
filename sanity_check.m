clc;clear;close all;
addpath("utils\")
%%
scale_type="unscaled";
T_folder=fullfile("ellip_pic_p\efit_p",scale_type,"attr");
T_file=fullfile(T_folder,"table_for.mat");
load(T_file);

T.obs_type      = categorical(T.obs_type);
T.iOr           = categorical(T.iOr);
T.nation_serial = categorical(T.nation_serial);
T.lastPart      = categorical(T.lastPart);
T.attribute     = categorical(T.attribute);
T.i_par         = categorical(T.i_par);   % ← 这个很重要
T.par_L = T.par(:,1);
T.par_b = T.par(:,4);
T.par_a = T.par(:,5);
T.par_C = sqrt(T.par(:,2).^2+T.par(:,3).^2);
T.par_h = atan2d(T.par(:,3),T.par(:,2));
summary(T)
groupcounts(T, ["nation_serial","attribute","obs_type"])
% 选择要检验的因变量
Yname = "par_C";   % 可换成 par_L, par_a, par_b, par_h
alpha = 0.05;
vars = ["nation_serial","attribute","obs_type","lastPart"];
% 只保留必要列，避免 NaN 干扰
Tsub = T(:, [vars Yname]);
Tsub = rmmissing(Tsub);

[G, groupKeys] = findgroups(Tsub(:, vars));

nGroups = max(G);
%% lilliefors
lillie_results = table();
row = 0;

for g = 1:nGroups
    idx = (G == g);
    y = Tsub{idx, Yname};

    % 样本太少时不做检验
    if numel(y) < 5
        continue
    end

    row = row + 1;

    [h, p] = lillietest(y, 'Alpha', alpha);

    lillie_results.row(row,1)        = g;
    lillie_results.n(row,1)          = numel(y);
    lillie_results.h(row,1)          = h;
    lillie_results.p(row,1)          = p;

    % 把分组信息补回去
    for v = 1:numel(vars)
        lillie_results.(vars(v))(row,1) = groupKeys.(vars(v))(g);
    end
end

disp("Lilliefors normality test:");
summary(lillie_results)

%%
var_results = table();
row = 0;

[G2, keys2] = findgroups(Tsub.attribute, Tsub.obs_type);

for g = 1:max(G2)
    idx = (G2 == g);
    Tg = Tsub(idx, :);

    % 至少两个 nation 才能比
    if numel(unique(Tg.nation_serial)) < 2
        continue
    end

    row = row + 1;

    y = Tg{:, Yname};
    group = Tg.nation_serial;

    % Levene（Brown–Forsythe 更稳健）
    p = vartestn(y, group, ...
        'TestType','BrownForsythe', ...
        'Display','off');

    var_results.attribute(row,1) = keys2.attribute(g);
    var_results.obs_type(row,1)  = keys2.obs_type(g);
    var_results.p(row,1)         = p;
    var_results.h(row,1)         = p < alpha;
end

disp("Variance homogeneity across nations:");
summary(var_results)

