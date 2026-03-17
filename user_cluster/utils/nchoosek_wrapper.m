function v = nchoosek_wrapper(x,k)
% vectorized nCk for k=2
x = x(:);
v = zeros(size(x));
idx = x>=2;
v(idx) = x(idx).*(x(idx)-1)/2;
end