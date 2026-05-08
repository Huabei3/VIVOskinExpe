function rgb_gain_filled=my_fillnan(rgb_gain_map)
    [row, col, dep] = size(rgb_gain_map);
    rgb_gain_filled = rgb_gain_map;
    
    for k = 1:dep
        for i = 1:row
            vec = rgb_gain_map(i, :, k);
            % 1. 构建列索引和有效数据点
            idx = 1:col;
            mask = ~isnan(vec);
            if sum(mask) == 0
                % 整行都是NaN，填充为0（可自定义）
                vec_filled = zeros(1, col);
            else
                % 2. 线性插值，'extrap' 外插边缘
                vec_filled = interp1(idx(mask), vec(mask), idx, 'linear', 'extrap');
            end
            rgb_gain_filled(i, :, k) = vec_filled;
        end
    end
end