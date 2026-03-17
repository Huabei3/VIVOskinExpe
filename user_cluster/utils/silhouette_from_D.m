function s = silhouette_from_D(D, labels)
% compute silhouette values from pairwise distance matrix D and labels
n = size(D,1);
clusters = unique(labels);
k = numel(clusters);
s = zeros(n,1);
for i = 1:n
    ci = labels(i);
    idx_same = (labels==ci);
    idx_same(i) = false;
    if sum(idx_same) == 0
        ai = 0;
    else
        ai = mean(D(i, idx_same));
    end
    % b: minimum mean distance to other clusters
    bvals = inf(k-1,1); t=1;
    for c = clusters'
        if c==ci, continue; end
        idxc = (labels==c);
        bvals(t) = mean(D(i, idxc));
        t = t+1;
    end
    bi = min(bvals);
    % silhouette
    denom = max(ai, bi);
    if denom == 0
        s(i) = 0;
    else
        s(i) = (bi - ai) / denom;
    end
end
end