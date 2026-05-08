close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量
%%
%画图
load("E:\documents\MATLAB\SkinColorPreferenceScale\level_data\fitRes_level.mat");
[n_level,~]=size(par_all);
aabbh=[];vari=[];abcdef=[];aabb=[];

colors=["#0072BD","#D95319","#EDB120","#7E2F8E","#77AC30","#0072BD",...
    "#D95319","#EDB120","#7E2F8E","#77AC30","#7E2F8E","#77AC30"];
figure(1);
for i_level=1:n_level
%     figure(i_level);
    syms y
    syms z
    par=par_all(i_level,:);
    s =par(2)*(y-par(6)).^2+par(3)*(z-par(7)).^2+par(4)*(y-par(6)).*(z-par(7)); 
    N = coeffs(expand(s));
    f=par(8)^2-N(1);
    d=N(4);
    c=N(3);
    e=N(2);
    b=N(5);
    a=N(6);
    a0=par(6);
    b0=par(7);
    [aa,bb,h,x0,y0,r,delta] = my_ellipsefig1(a,b,c,d,e,f,colors(i_level));
%     [aa,bb,aerfa,x0,y0]= my_ellipsefig1(a,b,c,d,e,f,colors(i_para));
    aa=double(aa);bb=double(bb);
%     h=double(h);
    abcdef=[abcdef;[double(a),double(b),double(c),double(d),double(e),double(f)]];
%     aabbh=[aabbh;[aa,bb,h]];
    aabb=[aabb;[aa,bb]];
    vari=[vari;[double(x0),double(y0),double(r),double(delta)]];
    axis equal;
    hold on;
    xlabel('a*','FontSize',15);
    ylabel('b*','FontSize',15);
    
    plot(par(6),par(7),'.','Color',colors(i_level),'MarkerSize',20);
%     saveas( i_level, strcat(['E:\documents\MATLAB\SkinColorPreferenceScale\ellip_pic\' ...
%         'ellip'],num2str(i_level),'.jpg'));

end
saveas(1,['E:\documents\MATLAB\SkinColorPreferenceScale\ellip_pic\' ...
    'ellip.jpg']);

