% Van Song (2025) method: k-means clustering in CIELAB for selection
clear; clc; close all;
addpath("utils\")
%%
% Data source (same as M1_2_s1)
load("lab_data.mat","lab_all","lab_pre");
attr_type = "pre"; % "all" or "pre"
if strcmp(attr_type,"all")
    lab1 = lab_all;
    attr_serial = "2";
else
    lab1 = lab_pre;
    attr_serial = "1";
end
xyz_cen=lab2xyz2(lab1,"d65_64");
XYZw_D65=[94.811 100.00 107.304];
Iab_cen=XYZ2sUCS(xyz_cen,XYZw_D65);
% k-means settings (Van Song uses k-means in CIELAB)
N = 70;              % number of clusters (k); change as needed
replicates = 20;
max_iter = 1000;
rng(0);             % reproducible

opts = statset('MaxIter', max_iter, 'Display', 'final');
[cluster_id, centers] = kmeans(Iab_cen, N, ...
    'Distance', 'sqeuclidean', ...
    'Replicates', replicates, ...
    'Start', 'plus', ...
    'Options', opts);

% Select nearest real sample to each centroid (sample selection)
idselect = zeros(N,1);
for i = 1:N
    members = find(cluster_id == i);
    if ~isempty(members)
        d2 = sum((lab1(members,:) - centers(i,:)).^2, 2);
        [~, k] = min(d2);
        idselect(i) = members(k);
    else
        d2 = sum((lab1 - centers(i,:)).^2, 2);
        [~, k] = min(d2);
        idselect(i) = k;
    end
end

labs = lab1(idselect,:);

% Save results
save_folder = fullfile("res", attr_type, "vansong_selection_sUCS");
if ~exist(save_folder,"dir")
    mkdir(save_folder);
end
save(fullfile(save_folder,"lab_selected.mat"), ...
    "idselect","labs","lab1","centers","cluster_id","attr_type","attr_serial");
[s, s_mean, a, b] = silhouette_de2000(lab1, cluster_id);
[ch, W, B, centroids] = calinski_harabasz_de2000(lab1, cluster_id);
disp([s_mean,ch]);
disp([mean(a),mean(b), W, B]);

% Optional quick check plot
pic_folder = fullfile(save_folder, "pic");
if ~exist(pic_folder,"dir")
    mkdir(pic_folder);
end
h_ab = figure;
plot(lab1(:,2), lab1(:,3), '.', 'Color', [0.8 0.8 0.8], 'MarkerSize', 6); hold on;
plot(labs(:,2), labs(:,3), 'k*', 'MarkerSize', 6);
grid on; axis equal;
xlabel('a*'); ylabel('b*');
title(sprintf('Van Song k-means selection: k=%d', N));
exportgraphics(h_ab, fullfile(pic_folder, sprintf("ab_vansong_%s.jpg", attr_serial)), "Resolution", 150);

% L*-C* plot
C_all = sqrt(lab1(:,2).^2 + lab1(:,3).^2);
C_sel = sqrt(labs(:,2).^2 + labs(:,3).^2);
hc = figure;
plot(C_all, lab1(:,1), '.', 'Color', [0.8 0.8 0.8], 'MarkerSize', 6); hold on;
plot(C_sel, labs(:,1), 'k*', 'MarkerSize', 6);
grid on; axis equal;
xlabel('C*'); ylabel('L*');
title(sprintf('Van Song L*-C*: k=%d', N));
exportgraphics(hc, fullfile(pic_folder, sprintf("lc_vansong_%s.jpg", attr_serial)), "Resolution", 150);
