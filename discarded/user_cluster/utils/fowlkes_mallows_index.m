function FMI = fowlkes_mallows_index(labels_true, labels_pred)
    % Fowlkes-Mallows Index
    [~,~,lt] = unique(labels_true);
    [~,~,lp] = unique(labels_pred);
    n = numel(labels_true);
    contingency = zeros(max(lt), max(lp));
    for i = 1:n
        contingency(lt(i), lp(i)) = contingency(lt(i), lp(i)) + 1;
    end
    TP = sum(contingency(:).^2) - n;  % sum_{ij} C_ij choose 2 = sum C_ij^2 - n all divided by 2 but we adjust formula
    % better compute pair counts exactly
    tp = 0; fp = 0; fn = 0;
    % pairs in same pred and true = TP
    for i = 1:size(contingency,1)
        for j = 1:size(contingency,2)
            tp = tp + nchoosek_wrapper(contingency(i,j),2);
        end
    end
    % pairs in same pred
    for j = 1:size(contingency,2)
        s = sum(contingency(:,j));
        fp = fp + nchoosek_wrapper(s,2);
    end
    % pairs in same true
    for i = 1:size(contingency,1)
        s = sum(contingency(i,:));
        fn = fn + nchoosek_wrapper(s,2);
    end
    % FMI = TP / sqrt( (TP+FP)*(TP+FN) )
    FMI = tp / sqrt( (fp) * (fn) + eps );
end
