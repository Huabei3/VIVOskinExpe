function [ch, W, B, centroids] = calinski_harabasz_de2000(lab, labels)
% calinski_harabasz_de2000  Calinski-Harabasz using CIEDE2000 distance.
%   lab    : Nx3 CIELAB
%   labels : Nx1 cluster labels
% Outputs:
%   ch        : Calinski-Harabasz index
%   W, B      : within- and between-group dispersion (scalar)
%   centroids : Kx3 cluster centroids (mean LAB)
%
% Note: W and B are scalar analogs of scatter, where
% (xi - ui)(xi - ui)^T is replaced by (deltaE2000(xi, ui))^2.

lab = double(lab);
labels = labels(:);
n = size(lab,1);
assert(size(lab,2) == 3, 'lab must be Nx3');
assert(numel(labels) == n, 'labels length must match lab rows');

u = unique(labels);
k = numel(u);
centroids = zeros(k,3);
nk = zeros(k,1);

for i = 1:k
    idx = labels == u(i);
    nk(i) = nnz(idx);
    centroids(i,:) = mean(lab(idx,:), 1);
end

global_centroid = mean(lab, 1);

W = 0;
for i = 1:k
    if nk(i) == 0
        continue;
    end
    idx = find(labels == u(i));
    d = deltaE2000(repmat(centroids(i,:), numel(idx), 1), lab(idx,:));
    W = W + sum(d.^2);
end

B = 0;
for i = 1:k
    if nk(i) == 0
        continue;
    end
    d = deltaE2000(centroids(i,:), global_centroid);
    B = B + nk(i) * (d.^2);
end

if k <= 1 || n <= k
    ch = NaN;
else
    ch = (B / (k - 1)) / (W / (n - k));
end
end
