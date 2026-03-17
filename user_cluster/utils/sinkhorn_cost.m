function cost = sinkhorn_cost(C, a, b, lambda, maxiter, tol)
% sinkhorn_cost: compute entropy-regularized OT cost between discrete distributions
% C: m x n cost matrix (nonnegative)
% a: m x 1 normalized weights sum 1
% b: n x 1 normalized weights sum 1
% lambda: regularization (>0)
% returns transport cost (sum T.*C)

[m,n] = size(C);
% convert cost to kernel (Gibbs)
K = exp(-C / lambda);   % may underflow for small lambda or large C
K(K<eps) = eps;
u = ones(m,1);
v = ones(n,1);
for it = 1:maxiter
    u_prev = u;
    u = a ./ (K * v);
    v = b ./ (K' * u);
    if any(~isfinite(u)) || any(~isfinite(v))
        % numerical issue, break
        break;
    end
    if max(abs(u-u_prev)) < tol
        break;
    end
end
T = diag(u) * K * diag(v);
cost = sum(T(:) .* C(:));
end