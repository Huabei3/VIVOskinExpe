function D = calculateD_par(CCT, duv, Dtype,E,par)
    % 输入参数：
    %   CCT - 一个列向量，表示色温（单位：K）
    %   duv - 一个列向量，表示色温对应的duv值
    %   Dtype - 字符串，表示计算D的类型（'OPPO', 'summer', 'zhai', 'VIVO_quadra'）
    % 输出：
    %   D - 计算后的D值，与CCT和duv的大小相同

    % 初始化D
    D = zeros(size(CCT));
    F=0.8;
    omega=2*pi*(1-cos(pi/36));
    S=0.0124; %164.07*75.57*(10^(-6))
    LA=E./S.*omega;

    % 根据Dtype计算D
    if strcmp(Dtype,'VIVO_spl')
        a=par;
        D = (CCT <= a(1)) .* (a(3) + a(4)*(CCT - a(1))) + ...
            (CCT > a(1) & CCT <= a(2)) .* (a(3) + a(5)*(CCT - a(1))) + ...
            (CCT > a(2)) .* ((a(3) + a(5)*(a(2) - a(1))) + a(6)*(CCT - a(2)));
    else
        error('unknown Dtype');
    end
    D=min(D,1);
end