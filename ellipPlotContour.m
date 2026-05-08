close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量

load("E:\documents\MATLAB\SkinColorPreferenceScale\level_data\fitRes_level.mat");
[n_para,~]=size(par_all);
aabbh=[];

colors=["#0072BD","#D95319","#EDB120","#7E2F8E",...
    '#191970','#000080','#6495ED',...
'#483D8B','#6A5ACD','#7B68EE',...
'cyan','red','green','blue'];

figure(1);
for i_para=1:n_para
% figure(i_para);
    %     f(L,y,z)=@(L,y,z)par(2)*(y-par(6)).^2+par(3)*(z-par(7)).^2+par(4)*(y-par(6)).*(z-par(7))-...
    % (lg(par(8)).^2-par(1)*(L-par(5).^2));
       
    %     figure(i_para);
    
    %     par=par_all(i_para,:);
    %     L=par(5);
    % 
    %     x=linspace(par(6)-5,par(6)+5,300);
    %     y=linspace(par(7)-5,par(7)+5,300);
    % 
    %     [X,Y]=meshgrid(x,y);
    % %     Z=par(2)*(X-par(6)).^2+par(3)*(Y-par(7)).^2+par(4)*(X-par(6)).*(Y-par(7))-...
    % %     (log(par(8)).^2);
    % %     P=1./(1+par(8).*(exp(par(1)*sqrt((L-par(5)).^2+par(2)*(X-par(6)).^2+...
    % %     par(3)*(Y-par(7)).^2+par(4)*(X-par(6)).*(Y-par(7))))));
    % 
    %     P = (1./(1+par(8)*exp(par(1)*sqrt((L-par(5)).^2+par(2)*(X-par(6)).^2+ ...
    %         par(3)*(Y-par(7)).^2+par(4)*(X-par(6)).*(Y-par(7))))))...
    %     .*(((L-par(5)).^2+par(2)*(X-par(6)).^2+par(3)*(Y-par(7)).^2+ ...
    %     par(4)*(X-par(6)).*(Y-par(7)))>=0);
    % 
    %     v=[0.5,1];
    %     contour(X,Y,P,v,'color',colors(i_para));
    %     hold on;
    par=par_all(i_para,:);
    check_data1=par(5);
    check_data2=par(6)+(-30:0.2:30);
    check_data3=par(7)+(-30:0.2:30);
    [data2,data3]=meshgrid(check_data2,check_data3);
    [row,col]=size(data2);
    data1=check_data1*ones(row,col);
    a=par;
    y = (1./(1+a(8)*exp(a(1)*sqrt((data1-a(5)).^2+a(2)*(data2-a(6)).^2+a(3)*(data3...
    -a(7)).^2+a(4)*(data2-a(6)).*(data3-a(7)))))).*(((data1-a(5)).^2+a(2)*(data2-a(6)).^2 ...
    +a(3)*(data3-a(7)).^2+a(4)*(data2-a(6)).*(data3-a(7)))>=0);
    % mesh(data2,data3,y)
    % figure
    s0=contour(data2,data3,y,[0.5,1],'Linewidth',2,'color',colors(i_para));
    hold on;
    title('BK');
%     saveas(i_para,strcat(['E:\documents\MATLAB\SkinColorPreferenceScale\ellip_pic' ...
%         '\ellipContour'],num2str(i_para),'.jpg'));
%     figure(i_para+1);
%     Fig = mesh(data2,data3,y);
end
saveas(1,['E:\documents\MATLAB\SkinColorPreferenceScale\ellip_pic\' ...
    'ellipContour.jpg']);
