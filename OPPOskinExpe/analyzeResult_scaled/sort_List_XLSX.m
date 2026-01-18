close all; % 关闭所有图窗
clc;       % 清空命令窗口par_ind
clear;     % 清除工作区所有变量
%%
% 假设已知椭球的参数
Dtype="zhai";
lastParts=["inLab","indoorAdd","nightAdd","outdoorAdd","sunsetAdd","recen"];
outputFolder=fullfile( "AnalyseResults",Dtype,"sum_list");
if ~exist(outputFolder,"dir")
    mkdir(outputFolder);
end
% 定义保存的汇总 Excel 文件名
summary_filename = fullfile(outputFolder,...
    strcat('list_para_.xlsx'));

% 如果汇总文件已存在，删除它以确保新数据写入
if exist(summary_filename, 'file')
    delete(summary_filename);
end
for i_lastPart=1:length(lastParts)
    lastPart=lastParts(i_lastPart);
    fitRes_folder = fullfile('AnalyseResults',Dtype,lastPart);
    load(fullfile(fitRes_folder, "ellipPara_scaled", "fitRes_level.mat"));
    [n_group, ~] = size(par_ind);
    para_male03_reCen=[0.378109190629304	0.560055917263319	0.326122976647669	-0.405912362260582	58.1372607560459	17.4948491661083	14.9741962386804	0.00196132607563268	0.973828373501098];
    

    % 初始化列表用于存储计算结果
    list1 = zeros(n_group, 14);
    list2 = zeros(n_group, 14);% 分别是中心坐标x0, y0, z0, a, b, c, alpha, beta, gamma, a/b, a/c, b/c
    aabbcc2=[];
    
    for i_group = 1:n_group
        % 提取参数 a
        a = par_ind(i_group, :);
    
        % 中心坐标
        x0 = a(6);
        y0 = a(7);
        z0 = a(5);
        % Ax^2 + Bxy + Cy^2 + Dxz + Eyz + Fz^2 + Gx + Hy + Iz + J = 0
        % 计算标准形式的椭球方程系数
        A = a(2);
        B = a(4);
        C = a(3);
        D = 0; % 如果涉及 z 轴
        E = 0; % 如果涉及 z 轴
        F = a(1);
        G = - (2 *a(2) * a(6) + a(4) * a(7));
        H = -2*a(3)*a(7)-a(4)*a(6);
        I = -2*a(1)*a(5); % 如果涉及 z 轴
        J = a(1) * a(5)^2 + a(2) * a(6)^2 + a(3) * a(7)^2 + a(4) * a(6) * a(7)-(-log(a(8)))^2;
        % 旋转角度计算示例
    
        alpha = 0.5 * atan2d_360(B, A - C);%z
        beta = 0.5 * atan2d_360(E, C - F);%x
        gamma = 0.5 * atan2d_360(D, F - A);%y
    
        AA1=A.*cosd(alpha).^2+(B/2).*sind(2*alpha)+C.*sind(alpha).^2;
        BB1=A.*sind(alpha).^2-(B/2).*sind(2*alpha)+C.*cosd(alpha).^2;
        % AA1=A.*cosd(alpha).^2-(B/2).*sind(2*alpha)+C.*sind(alpha).^2;
        % BB1=A.*sind(alpha).^2+(B/2).*sind(2*alpha)+C.*cosd(alpha).^2;
        CC1=F;
        aa=sqrt(1./AA1);
        bb=sqrt(1./BB1);
        cc=sqrt(1./CC1);
        aa2=sqrt(2./(A+C-sqrt((A-C).^2+B.^2)));
        bb2=sqrt(2./(A+C+sqrt((A-C).^2+B.^2)));
        cc2=sqrt(1./F);
        % aabbcc2=[aabbcc2;aa2,bb2,cc2];
        
        % 示例半轴长度提取
        % aa = sqrt(1 / A);
        % bb = sqrt(1 / C);
        % cc = sqrt(1 / F);
    
        ab_ratio=aa/bb;%ab
        bc_ratio=bb/cc;%bl
        ca_ratio=cc/aa;%al
    
        ab_ratio2=aa2/bb2;%ab
        bc_ratio2=bb2/cc2;%bl
        ca_ratio2=cc2/aa2;%al
    
    
        C=sqrt(x0.^2+y0.^2);
        h=atan2d_360(y0,x0);
        % 将结果存储到 list 中
        list1(i_group, :) = [ z0, x0, y0, aa,bb, cc,  alpha,beta,gamma, ab_ratio,bc_ratio, ca_ratio,C,h];
        list2(i_group, :) = [ z0, x0, y0, aa2,bb2, cc2,  alpha,beta,gamma, ab_ratio2,bc_ratio2, ca_ratio2,C,h];
    end
    
    list2(end+1,:)=mean(list2,1);
    picname_check{end+1,1}="mean";
    picname_check=cell2table(picname_check(:,1));
    % 将 list 转换为 table
    list_table = array2table(list2, 'VariableNames', ...
        {'L', 'a', 'b','aa', 'bb','cc', 'alpha', 'beta', 'gamma','ab_ratio','bc_ratio', 'ca_ratio','C','h'});
    list_table=[picname_check,list_table];
    % 保存包含 theta 的文件
    writetable(list_table, summary_filename, 'Sheet', lastPart );    
end
disp("done");



% 将角度转换到 360 度范围内的函数
function degree = atan2d_360(y, x)
    degree = atan2d(y, x);
    if degree < 0
        degree = degree + 360;
    end
end



