function labels = spectral_clustering_from_D(D, K)
% simple spectral clustering from distance matrix D
n = size(D,1);
% similarity matrix: RBF with sigma = median heuristic
pair_d = D(triu(true(n),1));
sigma = median(pair_d(pair_d>0));
if isempty(sigma) || sigma==0
    sigma = 1;
end
S = exp(-(D.^2) ./ (2*sigma^2));
% degree + normalized laplacian
d = sum(S,2);
Dmat = diag(d);
L = Dmat - S;
% normalized Laplacian
D_inv_sqrt = diag(1 ./ sqrt(d + eps));
Lsym = D_inv_sqrt * L * D_inv_sqrt;
% eigenvectors of Lsym (smallest K)
opts.issym = true;
[evecs, ~] = eigs(Lsym, K, 'smallestabs', opts);
% row normalize
Y = bsxfun(@rdivide, evecs, sqrt(sum(evecs.^2,2))+eps);
% kmeans on rows
labels = kmeans(real(Y), K, 'Replicates', 10);
end