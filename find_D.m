function D = find_D(CCT, duv, Dtype)
    % 输入参数：
    % CCT - 一个列向量，表示色温
    % duv - 一个标量或与 CCT 同长度的向量，表示色差
    % Dtype - 字符串，表示计算 D 的类型
    % 输出参数：
    % D - 一个列向量，计算得到的 D 值

    % 初始化输出 D
    D = zeros(size(CCT));

    % 根据 Dtype 的值进行不同的计算
    if strcmp(Dtype, "OPPO")
        D = 0.00005 * CCT + 0.1977;
    elseif strcmp(Dtype, "summer")
        D = 0.239 * 0.723 * (1 - 1116 ./ CCT); % summer
    elseif strcmp(Dtype, 'zhai')
        D = 0.723 * (1 - 1116 ./ CCT + 8.64 * duv - 49266 * duv ./ CCT); % zhai
    elseif strcmp(Dtype, 'VIVO_3sec')   
        a = [5000, 6500, 0.877457958129589, 8.806393623712550e-05, -5.419897901302469e-04, 2.566090248335773e-04];
        CCT = min(CCT, 8000); % 如果 CCT > 8000，则取 8000
        D = (CCT <= a(1)) .* (a(3) + a(4) * (CCT - a(1))) + ...
            (CCT > a(1) & CCT <= a(2)) .* (a(3) + a(5) * (CCT - a(1))) + ...
            (CCT > a(2)) .* ((a(3) + a(5) * (a(2) - a(1))) + a(6) * (CCT - a(2)));
    elseif strcmp(Dtype, 'VIVO_3sec_theo')
        a = [5000, 6500, 1.020458486365946, 1.271174498057603e-04, -7.688089445339436e-04, 2.887348158238644e-04];
        CCT = min(CCT, 8000); % 如果 CCT > 8000，则取 8000
        D = (CCT <= a(1)) .* (a(3) + a(4) * (CCT - a(1))) + ...
            (CCT > a(1) & CCT <= a(2)) .* (a(3) + a(5) * (CCT - a(1))) + ...
            (CCT > a(2)) .* ((a(3) + a(5) * (a(2) - a(1))) + a(6) * (CCT - a(2)));
    else
        error('未知的 Dtype 类型');
    end
end