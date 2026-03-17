% C_L 建模函数
function [r_val,RMSE,rho, p_value] = cal_rho_C_L(a_val,L_data, C_data)


    % 检查并移除包含NaN的行
    valid_indices = ~isnan(L_data) & ~isnan(C_data) & L_data > 0;
    L_valid = L_data(valid_indices);
    C_valid = C_data(valid_indices);

    % 如果有足够的数据点进行拟合
    if length(L_valid) > 3
        % 定义拟合模型
        y = (a_val(1).*log(xdata) + a_val(2));
        r_val = corr(y, C_valid);
        RMSE = sqrt(mean((C_valid - y).^2))./mean(C_valid);  
        [rho, p_value] = spearman_correlation(x, y);

    end
end

