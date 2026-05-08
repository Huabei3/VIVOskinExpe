close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量
% load("fitRes\fitRes_level_z_dire_r.mat");
load("fitRes\fitRes_level_m.mat");
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
theta=0.5*atan2d_360(2*lambda01,(lambda00-lambda11));
isshort=lambda00 < lambda11;
[n_para,~]=size(par_all);


A=lambda00.*cosd(theta).^2-lambda01.*sind(2*theta)+lambda11.*sind(theta).^2;
B=lambda00.*sind(theta).^2+lambda01.*sind(2*theta)+lambda11.*cosd(theta).^2;
aabb(:,1)=sqrt(1./A);
aabb(:,2)=sqrt(1./B);
A=aabb(:,1);
B=aabb(:,2);

list(:,6)=aabb(:,1);
list(:,7)=aabb(:,1)./aabb(:,2);
list(:,8)=theta-90;
list(:,9)=r_all(:);

save("level_data_m\fit_List.mat",'list');

function degree = atan2d_360(y, x)
    degree = atan2d(y, x);
    if degree < 0
        degree = degree + 360;
    end
end