function D = calculateD(CCT, duv, Dtype,E)
    % 输入参数：
    %   CCT - 一个列向量，表示色温（单位：K）
    %   duv - 一个列向量，表示色温对应的duv值
    %   Dtype - 字符串，表示计算D的类型（'OPPO', 'summer', 'zhai', 'VIVO_quadra'）
    % 输出：
    %   D - 计算后的D值，与CCT和duv的大小相同

    % 初始化D
    if contains(Dtype, "CAT16")||contains(Dtype, "cherry")
        D = zeros(size(CCT));
        F=0.8;
        omega=2*pi*(1-cos(pi/36));
        S=0.0124; %164.07*75.57*(10^(-6))
        LA=E./S.*omega;
    end

    % 根据Dtype计算D
    if strcmp(Dtype, 'ZHU_Zhai')
        D = 1.015 * (1 - 2178.96 ./ CCT + 6.67 * duv - 47181.20 * duv ./ CCT);
    elseif strcmp(Dtype, 'HK_Poly')
        D = 0.538 * (1 - 2178.96 ./ CCT + 6.67 * duv - 47181.20 * duv ./ CCT);
    elseif strcmp(Dtype, 'KAIST')
        D = 0.793 * (1 - 2178.96 ./ CCT + 6.67 * duv - 47181.20 * duv ./ CCT);
    elseif strcmp(Dtype, 'ZJU_Peng_500')
        D = 0.796 * (1 - 2178.96 ./ CCT + 6.67 * duv - 47181.20 * duv ./ CCT);       
    elseif strcmp(Dtype, 'ZJU_Peng_1000')
        D = 0.762 * (1 - 2178.96 ./ CCT + 6.67 * duv - 47181.20 * duv ./ CCT);


    else
        error('unknown Dtype');
    end
    D=min(D,1);
end