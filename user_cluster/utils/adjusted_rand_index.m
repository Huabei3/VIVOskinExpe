function ARI = adjusted_rand_index(labels_true, labels_pred)
% compute adjusted rand index
% convert to contiguous labels
[~,~,lt] = unique(labels_true);
[~,~,lp] = unique(labels_pred);
n = numel(labels_true);
contingency = zeros(max(lt), max(lp));
for i = 1:n
    contingency(lt(i), lp(i)) = contingency(lt(i), lp(i)) + 1;
end
sumComb = @(x) sum(nchoosek_wrapper(x,2));
a = sum(sumComb(sum(contingency,2)));
b = sum(sumComb(sum(contingency,1)));
c = sumComb(contingency(:));
expected = a*b / nchoosek_wrapper(n,2);
maxIndex = 0.5*(a+b);
ARI = (c - expected) / (maxIndex - expected + eps);
end