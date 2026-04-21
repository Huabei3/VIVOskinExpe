function [s, s_mean, a, b] = silhouette_de2000(lab, labels)
% silhouette_de2000  Silhouette using CIEDE2000 distance in CIELAB.
%   lab    : Nx3 CIELAB
%   labels : Nx1 cluster labels
% Outputs:
%   s      : Nx1 silhouette values
%   s_mean : mean silhouette
%   a, b   : within-cluster and nearest-cluster mean distances

lab = double(lab);
labels = labels(:);
n = size(lab,1);
assert(size(lab,2) == 3, 'lab must be Nx3');
assert(numel(labels) == n, 'labels length must match lab rows');

u = unique(labels);
k = numel(u);
idx_by_cluster = cell(k,1);
for i = 1:k
    idx_by_cluster{i} = find(labels == u(i));
end

s = zeros(n,1);
a = zeros(n,1);
b = zeros(n,1);

for i = 1:n
    ci = find(u == labels(i), 1, 'first');
    in_idx = idx_by_cluster{ci};
    if numel(in_idx) <= 1
        a(i) = 0;
    else
        others = in_idx(in_idx ~= i);
        d = deltaE2000(repmat(lab(i,:), numel(others), 1), lab(others,:));
        a(i) = mean(d);
    end

    bmin = inf;
    for c = 1:k
        if c == ci || isempty(idx_by_cluster{c})
            continue;
        end
        idx = idx_by_cluster{c};
        d = deltaE2000(repmat(lab(i,:), numel(idx), 1), lab(idx,:));
        bmin = min(bmin, mean(d));
    end
    if isfinite(bmin)
        b(i) = bmin;
    else
        b(i) = 0;
    end

    denom = max(a(i), b(i));
    if denom == 0
        s(i) = 0;
    else
        s(i) = (b(i) - a(i)) / denom;
    end
end

s_mean = mean(s);
end
