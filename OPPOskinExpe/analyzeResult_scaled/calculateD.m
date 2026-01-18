function D = calculateD(CCT, duv, Dtype)
    % 输入参数：
    %   CCT - 一个列向量，表示色温（单位：K）
    %   duv - 一个列向量，表示色温对应的duv值
    %   Dtype - 字符串，表示计算D的类型（'OPPO', 'summer', 'zhai', 'VIVO_quadra'）
    % 输出：
    %   D - 计算后的D值，与CCT和duv的大小相同

    % 初始化D
    D = zeros(size(CCT));

    % 根据Dtype计算D
    if strcmp(Dtype, "OPPO")
        D = 0.00005 * CCT + 0.1977;
    elseif strcmp(Dtype, "summer")
        D = 0.239 * 0.723 * (1 - 1116 ./ CCT);
    elseif strcmp(Dtype, 'zhai')
        D = 0.723 * (1 - 1116 ./ CCT + 8.64 * duv - 49266 * duv ./ CCT);
    elseif strcmp(Dtype, 'zhai_adjusted')
        D = 0.5*0.723 * (1 - 1116 ./ CCT + 8.64 * duv - 49266 * duv ./ CCT);
    elseif strcmp(Dtype, 'VIVO_quadra')
        a = [-3.35279606378243e-08, 0.000173542463734851, 0.498076343205087];
        D(CCT <= 6500) = a(1) * CCT(CCT <= 6500).^2 + a(2) * CCT(CCT <= 6500) + a(3);
        D(CCT > 6500) = 1;
    elseif strcmp(Dtype, 'VIVO_summer')
        a = [-3.35279606378243e-08, 0.000173542463734851, 0.498076343205087];
        D(CCT <= 6500) = a(1) * CCT(CCT <= 6500).^2 + a(2) * CCT(CCT <= 6500) + a(3);
        D(CCT > 6500) = 0.239 * 0.723 * (1 - 1116 ./ CCT);
    elseif strcmp(Dtype, 'full')
        D=1;
    elseif strcmp(Dtype,'OPPO_CAT16')
        F=0.8;
        omega=2*pi*(1-cos(pi/36));
        S=0.0124; %164.07*75.57*(10^(-6))
        E=38.793053141978900;%仅对于OPPO实验XYZ_gray=[37.013049998090246,38.793053141978900,46.598658451998140]
        LA=E./S.*omega;
        D = F*(1-(1/3.6)*exp((-LA-42)/92));      %0.797797968820369
    elseif strcmp(Dtype,'efit_p')
        a=[0.9193 500.1675];
        D=a(1).*(1-a(2)./CCT);
    else
        error('unknown Dtype');
    end
end