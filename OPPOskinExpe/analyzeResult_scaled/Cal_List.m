close all; % 关闭所有图窗
clc;       % 清空命令窗口par_ind
clear;     % 清除工作区所有变量
%%
% 假设已知椭球的参数
Dtype="OPPO_CAT16";
lastParts=["inLab","indoorAdd","nightAdd","outdoorAdd","sunsetAdd","recen"];
for i_lastPart=1:length(lastParts)
    lastPart=lastParts(i_lastPart);
    fitRes_folder = fullfile('AnalyseResults',Dtype,lastPart);
    load(fullfile(fitRes_folder, "ellipPara_scaled", "fitRes_level.mat"));
    [n_group, ~] = size(par_ind);
    para_male03_reCen=[0.378109190629304	0.560055917263319	0.326122976647669	-0.405912362260582	58.1372607560459	17.4948491661083	14.9741962386804	0.00196132607563268	0.973828373501098];
    
    if contains(fitRes_folder, 'inLab')
        picname_group = [
            "female1makeup", "female1nomakeup",  "female2makeup",  "female2nomakeup", ...
            "female3makeup",  "female3nomakeup", "female4makeup", "female4nomakeup", ...
            "female5makeup", "female5nomakeup", "male1", "male2", ...
            "male3", "male4"];
    elseif contains(fitRes_folder, 'indoor')
        picname_group = [
            "indoor01", "indoor02", "indoor03", ...
            "indoor04", "indoor05", "indoor06", "indoor07", ...
            "indoor08", "indoor09", "indoor10"];
    elseif contains(fitRes_folder, 'night')
        picname_group = ["night01", "night02", "night03", ...
            "night04", "night05", "night06", "night07", ...
            "night08", "night09", "night10"];
    elseif contains(fitRes_folder, 'outdoor')
        picname_group = ["outdoor01", "outdoor02", "outdoor03", ...
            "outdoor04", "outdoor05", "outdoor06", "outdoor07", ...
            "outdoor08", "outdoor09", "outdoor10"];
    elseif contains(fitRes_folder, 'sunset')
        picname_group = ["sunset01", "sunset02", "sunset03", ...
            "sunset04", "sunset05", "sunset06", "sunset07", ...
            "sunset08"];
    end
    
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
    
    % 保存结果
    output_folder = fullfile(fitRes_folder, 'List');
    if ~exist(output_folder, 'dir')
        mkdir(output_folder);
    end
    save(fullfile(output_folder, "list.mat"), 'list1','list2');
end
disp("done");



% 将角度转换到 360 度范围内的函数
function degree = atan2d_360(y, x)
    degree = atan2d(y, x);
    if degree < 0
        degree = degree + 360;
    end
end



%%
%原理说明
%对于椭圆：
% Ax^2 + Bxy + Cy^2 + Dx + Ey + F = 0
% x^T Q x = 1
% 其中，x = [x; y]，矩阵 Q 定义为：
% Q = [A, B/2;
%      B/2, C]
% Qv = λv
% Q = [λ00, λ01;
%      λ10, λ11]
% 注意 λ01 = λ10。
% 为了找到旋转角度 θ，使得旋转后的矩阵 Q' 为对角矩阵，我们需要解如下方程：
% Qv = λv
% 设旋转矩阵为：
% R(θ) = [cos(θ), -sin(θ);
%         sin(θ), cos(θ)]
% 我们希望找到一个角度 θ，使得：
% R(θ)^T Q R(θ) = [λ1, 0;
%                  0, λ2]
% 通过特征值分解，我们得到：
% det(Q - λI) = 0
% |λ00 - λ, λ01;
%  λ10, λ11 - λ| = 0
% λ1,2 = [(λ00 + λ11) ± sqrt((λ00 - λ11)^2 + 4*λ01^2)] / 2
% 旋转角度 θ 可以从特征向量中找到。特征向量对应于特征值 λ1 和 λ2：
% 对角化后的矩阵的旋转角度可以通过：
% tan(2θ) = 2λ01 / (λ00 - λ11)
% 通过 atan2d 函数得到：
% θ = 0.5 * atan2d(2λ01, λ00 - λ11)
% 为了适应整个360度的范围，atan2d_360 函数确保结果在0到360度之间。
% 因此，有公式：
% theta = 0.5 * atan2d_360(2 * lambda01, (lambda00 - lambda11));
%对于椭球：
% Ax^2 + Bxy + Cy^2 + Dxz + Eyz + Fz^2 + Gx + Hy + Iz + J = 0

% A = a(2);
% B = a(4);
% C = a(3);
% D = 0; % 如果涉及 z 轴
% E = 0; % 如果涉及 z 轴
% F = a(1);
% G = - (2 *a(2) * a(6) + a(4) * a(7));
% H = -2*a(3)*a(7)-a(4)*a(6);
% I = -2*a(1)*a(5); % 如果涉及 z 轴
% J = a(1) * a(5)^2 + a(2) * a(6)^2 + a(3) * a(7)^2 + a(4) * a(6) * a(7)-(-log(a(8)))^2;
% 假设绕z轴旋转角为alpha、绕x轴为beta，绕y轴为gamma
% 因为肤色椭球公式里只有一个旋转项，故只有alpha有值
% 旋转矩阵为R(alpha)=[cosd(alpha),-sind(alpha),0;
%           sind(alpha),cosd(alpha),0;
%             0, 0, 1];
% Q=[lambda00,lambda01,0;
% lambda10,lambda11,0;
% 0,0,lambda22]
% 即Q=[A,B/2,0;
% B/2,C,0;
% 0,0,F];
% R(alpha)'*Q*R(alpha)=[lambda1,0;0,lambda2];
% 分块矩阵
% R(alpha)=[cosd(alpha),-sind(alpha),0;
%           sind(alpha),cosd(alpha),0;
%             0, 0, 1];=[AM,0;0,1];
% Q=[lambda00,lambda01,0;
% lambda10,lambda11,0;
% 0,0,lambda22]
% =[BM,0;
% 0,lambda22];

% [AM',0;0,1]*[BM,0;0,lambda22]*[AM,0;0,1]=[CM,0;0,lambda22]即是
%CM=[lambda1,0;0,lambda2]
% [AM'*BM*AM,0;
% 0,lambda22]=[lambda1,0;0,lambda2]
% 特征根lambda1和2分别是椭圆状况下两个特征根，lambda3是lambda22=F