close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量
load("fitRes\fitRes_level_p.mat");
[n_level,~]=size(par_all);
list=zeros(n_level,9);%分别是L、a、b、C、h、A、A/B、theta、coefficients
L=[10;20;30;40;50;60;70;80];
list(:,1)=L;
list(:,2:3)=par_all(:,4:5);
list(:,4)=sqrt(par_all(:,4).^2+par_all(:,5).^2);
list(:,5)=atan2d_360(par_all(:,5),par_all(:,4));

lambda00=par_all(:,1);
lambda01=par_all(:,3)/2;
lambda10=par_all(:,3)/2;
lambda11=par_all(:,2);
theta=zeros(n_level,1);
principalAxis_all=[];
for i_level=1:n_level
    Q = [lambda00(i_level,1), lambda01(i_level,1); lambda10(i_level,1),... 
        lambda11(i_level,1)];
    
    % 求解特征值
    [V, D] = eig(Q);
    [~, maxIndex] = max(diag(D));
    principalAxis = V(:, maxIndex);
    principalAxis_all=[principalAxis_all,principalAxis];
    % 计算倾角
    theta1(i_level,1) = atan2(principalAxis(2), principalAxis(1));
    
    % 将倾角转换为度
    theta1(i_level,1) = rad2deg(theta1(i_level,1));
%     theta1(i_level,1) = mod(theta1(i_level,1), 360);
    % 特征值是椭圆长短轴的平方的倒数
    lambda = diag(D);
    
    % 如果特征值为正，则计算长短轴
        if all(lambda > 0)
            % 长短轴长度的平方
            A(i_level,1)=min(lambda);
            B(i_level,1)=max(lambda);
        
        end
theta2(i_level,1)=0.5*atan2(par_all(i_level,3),par_all(i_level,1)-par_all(i_level,2));
theta2(i_level,1) = rad2deg(theta2(i_level,1));
end
aabb(:,1)=sqrt(1./A);
aabb(:,2)=sqrt(1./B);
A=aabb(:,1);
B=aabb(:,2);
theta3=0.5*atand(2*lambda01./(-lambda00+lambda11));


list(:,6)=aabb(:,1);
list(:,7)=aabb(:,1)./aabb(:,2);
list(:,8)=theta1-90;
list(:,9)=r_all(:);
A1=lambda00.*cosd(theta1).^2-lambda01.*sind(2*theta1)+lambda11.*sind(theta1).^2;

save("Z:\homes\Peggy\FirstYearMaster\MATLAB\SkinColorPreferenceScale\level_data" + ...
"\fit_List1_deleted.mat",'list');

function degree = atan2d_360(y, x)
    degree = atan2d(y, x);
    if degree < 0
        degree = degree + 360;
    end
end