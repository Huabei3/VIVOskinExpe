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
g11=par_all(:,1);
g12=par_all(:,3);
g22=par_all(:,2);
A(:,1)=sqrt(2./(g11+g22-sqrt((g11-g22).^2+g12.^2)));
B(:,1)=sqrt(2./(g11+g22+sqrt((g11-g22).^2+g12.^2)));
% theta=0.5*atand(g12./(g11-g22));
% theta=0.5*atan2d_360(g12,(g11-g22));
theta=0.5*atan2d(g12,(g11-g22));
isshort=g11 < g22;
[n_para,~]=size(par_all);
% % 对于g11大于g22的情况，调整theta值
% for i_para = 1:n_para
%     if g11(i_para) > g22(i_para)
%         % 调整theta以反映长轴的倾角，并确保结果在0到360度范围内
%         theta(i_para) = mod(theta(i_para) + 90, 360);
%     else
%         % 为了保持一致性，即使不需要调整也应当确保theta在0到360度范围内
%         theta(i_para) = mod(theta(i_para), 360);
%     end
% end
list(:,6)=A;
list(:,7)=A./B;

list(:,8)=theta+90;
list(:,9)=r_all(:);

save("Z:\homes\Peggy\FirstYearMaster\MATLAB\SkinColorPreferenceScale\level_data" + ...
"\fit_List2.mat",'list');

function degree = atan2d_360(y, x)
    degree = atan2d(y, x);
    if degree < 0
        degree = degree + 360;
    end
end