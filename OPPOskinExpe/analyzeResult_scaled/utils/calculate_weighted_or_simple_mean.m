function [cen,r] = calculate_weighted_or_simple_mean(MSV_group, lab_group)

        % 找到 MSV_group > 0.5 的行
        high_score_rows = MSV_group > 0.5;
        if any(high_score_rows)
            % 加权平均
            weights = MSV_group(high_score_rows);
            weighted_mean = sum(lab_group(high_score_rows, :) .* weights, 1) / sum(weights);
            cen = weighted_mean;
        else
            % 找到 MSV_group 的最大值
            max_score = max(unique(MSV_group));
            max_score_rows = MSV_group == max_score;
            
            % 简单平均
            simple_mean = mean(lab_group(max_score_rows,:), 1);
            cen = simple_mean;
        end
        r=0;
        

end
