function [mean_cen] = calculate_weighted_or_simple_mean3D( MSV_group_original, lab_group_original)

        % 找到 MSV_group_original > 0.5 的行
        high_score_rows = MSV_group_original > 0.5;
        
        if any(high_score_rows)
            % 加权平均
            weights = MSV_group_original(high_score_rows);
            weighted_mean = sum(lab_group_original(high_score_rows, :).* weights , 1, 'omitnan') / sum(weights);
            mean_cen = weighted_mean;
        else
            % 找到 MSV_group_original 的最大值
            max_score = max(unique(MSV_group_original));
            max_score_rows = MSV_group_original == max_score;
            
            % 简单平均
            simple_mean = mean(lab_group_original(max_score_rows, :), 1);
            mean_cen = simple_mean;
        end
        


end
