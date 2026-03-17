
function cens_field = build_cens_field_illuminance(T)
%BUILD_CENS_FIELD_ILLUMINANCE Group LabCh by illuminance clusters (<2).

lab_center = extract_lab_center(T);
if size(lab_center, 2) ~= 3
    error("lab_center must be Nx3, got %dx%d", size(lab_center, 1), size(lab_center, 2));
end

L = lab_center(:, 1);
a = lab_center(:, 2);
b = lab_center(:, 3);
C = sqrt(a.^2 + b.^2);
h = mod(atan2d(b, a) + 360, 360);
lab_ch = [L, a, b, C, h];
for i_row=1:size(T.illuminance,1)
illum(i_row,1) = T.illuminance{i_row,1};
end
valid = ~isnan(illum) & ~any(isnan(lab_ch), 2);
illum = illum(valid);
lab_ch = lab_ch(valid, :);

if isempty(illum)
    cens_field = cell(0, 2);
    return;
end

[illum_sorted, order] = sort(illum);
cluster_id_sorted = zeros(size(illum_sorted));
cluster_id_sorted(1) = 1;
cluster_min = illum_sorted(1);
for i = 2:numel(illum_sorted)
    if (illum_sorted(i) - cluster_min) <= 2
        cluster_id_sorted(i) = cluster_id_sorted(i-1);
    else
        cluster_id_sorted(i) = cluster_id_sorted(i-1) + 1;
        cluster_min = illum_sorted(i);
    end
end

cluster_id = zeros(size(illum));
cluster_id(order) = cluster_id_sorted;

n_clusters = max(cluster_id_sorted);
cens_field = cell(n_clusters, 3);
for c = 1:n_clusters
    rows = (cluster_id == c);
    cens_field{c, 1} = lab_ch(rows, :);
    cens_field{c, 2} = mean(illum(rows));
    cens_field{c, 3} = illum(rows);
end
end
