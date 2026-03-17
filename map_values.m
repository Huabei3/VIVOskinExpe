function mapped = map_values(input)
    % 定义输入和对应的输出映射关系
    from = [-3, -2, -1, 1, 2, 3];
    to = [1, 2, 3, 4, 5, 6];
    
    % 初始化输出数组
    mapped = zeros(size(input));
    
    % 遍历输入元素并进行映射
    for i = 1:length(input)
        % 找到当前元素在from数组中的索引
        idx = find(from == input(i), 1);
        
        % 检查是否找到有效索引
        if ~isempty(idx)
            mapped(i) = to(idx);
        else
            % 对于不在映射范围内的元素，这里返回NaN
            mapped(i) = NaN;
            warning('输入元素 %d 不在映射范围内', input(i));
        end
    end
end