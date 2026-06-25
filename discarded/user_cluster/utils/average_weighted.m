function weighted_mean = average_weighted( p_group, lab_group)

        % 找到 p_group > 0.5 的行
        high_score_rows = p_group > 0.5;
        
        if any(high_score_rows)
            % 加权平均
            weights = p_group(high_score_rows);
            weighted_mean = sum(lab_group(high_score_rows, :).* weights , 1, 'omitnan') / sum(weights);
            weighted_mean = weighted_mean;
        else
            % 找到 p_group 的最大值
            max_score = max(unique(p_group));
            max_score_rows = p_group == max_score;
            
            % 简单平均
            simple_mean = mean(lab_group(max_score_rows, :), 1);
            weighted_mean = simple_mean;
        end


end
