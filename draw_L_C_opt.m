close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量
addpath("utils\")
%%
% data_type="old";
data_type="likeVIVO";
% Dtype="noCAT";
Dtype="efit_p";
interpreter_type="tex";  % 可选 "tex" 或 "latex"
if strcmp(data_type,"old")
    save_folder="AnalyseResults_p\old\fitRes";
    load("fitRes\fitRes_level_m.mat");
elseif strcmp(data_type,"likeVIVO")
    save_folder=fullfile("AnalyseResults_p",Dtype,"unscaled\fitRes");
    load(fullfile(save_folder,"fitRes_level_p.mat"));
end
pic_folder=fullfile(save_folder,"pic");
if ~exist(pic_folder,"dir")
    mkdir(pic_folder);
end

XYZw_pre=[99.8408323170247,	100,	67.3098058505433];
XYZw_ori_PMCC=[0.824896999038825	0.845965324097912	0.747165892096635]*100;

% load("fitRes\fitRes_level_m.mat");
[n_para,~]=size(par_all);
wd65_64 = [94.811, 100.00, 107.304];
XYZw_PMCC=[0.824896999038825	0.845965324097912	0.747165892096635]*100;
% lab_ori=[63.4304   13.6518   31.2004];


%获取CAT后原图平均肤色
lab_ori=[60.7058960025472	13.5867770770776	29.5041665069650];
XYZ_ori_bf=lab2xyz2(lab_ori,"d65_64");
XYZ_ori_aft = SimpleTwostepCAT (XYZ_ori_bf,XYZw_ori_PMCC,wd65_64,wd65_64,"CAT16",1,1);
lab_ori_aft=xyz2lab(XYZ_ori_aft,"d65_64");
%这个是原图不做处理提取到的肤色

%见test里面find PMCC white against display white 
%%
%L-C
L=[10;20;30;40;50;60;70;80];

% figure(1);
C_all=sqrt(par_all(:,4).^2+par_all(:,5).^2);
Lab_cen=[L,par_all(:,4:5)];

for i_level=1:size(par_all,1)
    xyz_bf=lab2xyz2(lab_ori_aft,"d65_64");
    xyz_target(i_level,:)=lab2xyz2(Lab_cen(i_level,:),"d65_64");
    xyz_fit_scaled(i_level,:)=xyz_bf./xyz_bf(2).*xyz_target(i_level,2);
    lab_scaled(i_level,:)=xyz2lab(xyz_fit_scaled(i_level,:),"d65_64");
 
end

lab_scaled(:,4)=sqrt(lab_scaled(:,2).^2+lab_scaled(:,3).^2);
lab_scaled(:,5)=atan2d(lab_scaled(:,3),lab_scaled(:,2));
% L=lab_scaled(:,1);


%% C=a1*L+a2
figure(4);hold on;
scatter(C_all(:),L(:), 40, 'filled',"MarkerFaceColor",'r'); 
% scatter(lab_scaled(:,4),lab_scaled(:,1), 30, 'filled',"MarkerFaceColor",'b');
ax = gca; ax.XLim = [0 max(C_all)+25];
ay = gca; ay.YLim = [0 max(L)+5];
if strcmp(interpreter_type,"tex")
    xlabel('C_{ab}^*','Interpreter','tex','FontName','Arial','FontAngle','italic', 'FontSize',12*2);
    ylabel('L^*','Interpreter','tex','FontName','Arial','FontAngle','italic', 'FontSize',12*2);
elseif strcmp(interpreter_type,"latex")
    xlabel('\textit{$C_{ab}^*$}', 'Interpreter', 'latex', 'FontSize', 12*2);
    ylabel('\textit{$L^*$}', 'Interpreter', 'latex', 'FontSize', 12*2);
end
% title('\textit{$C_{ab}^*-L^*$}','Interpreter', 'latex','FontSize', 12*2);

% saveas(4,fullfile('ellip_pic\linear\m\C_L_curve.jpg'));
% exportgraphics(gcf,fullfile(pic_folder,'C_L_scatter.jpg'),"Resolution",150);

%---------------拟合直线(全部点)-----------------
xdata = L(:);
ydata = C_all(:);

f = @(a,xdata)(a(1).*xdata+a(2));

rmax = 0;

for t = 1:500
    a0 = [rand,rand];
    options = optimset('MaxFunEvals',200000);
    a = lsqcurvefit(f,a0,xdata,ydata,[-inf,-inf],[inf,inf],options);
    y = a(1).*xdata+a(2);

    r = corr(y,ydata);
    if r >= rmax
        rmax = r;
        afinal = a;
    end
end
r_CL=rmax;
a_CL = afinal;

%------------------拟合直线(去除70-80)---------
xdata = L(1:end-2);
ydata = C_all(1:end-2);

f = @(a,xdata)(a(1).*xdata+a(2));

rmax = 0;

for t = 1:500
    a0 = [rand,rand];
    options = optimset('MaxFunEvals',200000);
    a = lsqcurvefit(f,a0,xdata,ydata,[-inf,-inf],[inf,inf],options);
    y = a(1).*xdata+a(2);

    r = corr(y,ydata);
    if r >= rmax
        rmax = r;
        afinal = a;
    end
end
r_CL1=rmax;
a_CL1 = afinal;

%-----------------



axis equal;

%画拟合直线
x = min(L):0.1:max(L);
y= a_CL(1)*x+a_CL(2);
y1= a_CL1(1)*x+a_CL1(2);
% y2=6.7421*log(x)-9.9816;%亮度实验
plot(y,x,"Color","r");
plot(y1,x,"Color","r","LineStyle","--");

%设置坐标
ax = gca; ax.XLim = [0 max(C_all)+25];
ay = gca; ay.YLim = [0 max(L)+5];
if strcmp(interpreter_type,"tex")
    xlabel('C_{ab}^*','Interpreter','tex','FontName','Arial','FontAngle','italic', 'FontSize',12*2);
    ylabel('L^*','Interpreter','tex','FontName','Arial','FontAngle','italic', 'FontSize',12*2);
elseif strcmp(interpreter_type,"latex")
    xlabel('\textit{$C_{ab}^*$}', 'Interpreter', 'latex', 'FontSize', 12*2);
    ylabel('\textit{$L^*$}', 'Interpreter', 'latex', 'FontSize', 12*2);
end
% title('\textit{$C_{ab}^*-L^*$}','Interpreter', 'latex','FontSize', 12*2);

% saveas(4,fullfile('ellip_pic\linear\m\C_L_curve.jpg'));

img_name=fullfile(pic_folder,'C_L_curve.jpg');    
savefig(gcf, strrep(img_name,'jpg','fig'));
exportgraphics(gcf,img_name,"Resolution",150);
close(gcf)
%%
figure(1);hold on;
scatter(Lab_cen(:,2),Lab_cen(:,3), 40, 'filled',"MarkerFaceColor",'r'); 
scatter(lab_scaled(:,2),lab_scaled(:,3), 30, 'filled',"MarkerFaceColor",'b');
%------------------拟合直线--------
xdata = Lab_cen(:,2);
ydata = Lab_cen(:,3);

f = @(a,xdata)(a(1).*xdata+a(2));

rmax = 0;

for t = 1:500
    a0 = [rand,rand];
    options = optimset('MaxFunEvals',200000);
    a = lsqcurvefit(f,a0,xdata,ydata,[-inf,-inf],[inf,inf],options);
    y = a(1).*xdata+a(2);

    r = corr(y,ydata);
    if r >= rmax
        rmax = r;
        afinal = a;
    end
end
r_ab=rmax;
a_ab = afinal;

%-----------------
%%
axis equal;
max_lim=max(max(Lab_cen(:,2)),max(Lab_cen(:,3)))+5;
%画拟合直线
x = 0:0.1:max_lim;
y= a_ab(1)*x+a_ab(2);

% y2=6.7421*log(x)-9.9816;%亮度实验
plot(x,y,"Color","r");
plot(x,x,"Color","k","LineStyle","--");
% plot(y1,x,"Color","g");

%设置坐标

ax = gca; ax.XLim = [0 max_lim];
ay = gca; ay.YLim = [0 max_lim];
if strcmp(interpreter_type,"tex")
    xlabel('a*','Interpreter','tex','FontName','Arial','FontAngle','italic', 'FontSize',12*2);
    ylabel('b*','Interpreter','tex','FontName','Arial','FontAngle','italic', 'FontSize',12*2);
    % title('a*-b*','FontAngle', 'italic');
elseif strcmp(interpreter_type,"latex")
    xlabel('\textit{$a^*$}', 'Interpreter', 'latex', 'FontSize', 12*2);
    ylabel('\textit{$b^*$}', 'Interpreter', 'latex', 'FontSize', 12*2);
    % title('\textit{$a^*-b^*$}','Interpreter', 'latex','FontSize', 12*2);
end

% saveas(4,fullfile('ellip_pic\linear\m\C_L_curve.jpg'));
img_name=fullfile(pic_folder,'ab_curve.jpg');    
savefig(gcf, strrep(img_name,'jpg','fig'));
exportgraphics(gcf,img_name,"Resolution",150);
close(gcf)
%%
concatenate_images1(pic_folder,4);
%%
Lab_cen(:,4)=sqrt(Lab_cen(:,2).^2+Lab_cen(:,3).^2);
Lab_cen(:,5)=atan2d(Lab_cen(:,3),Lab_cen(:,2));

result_matrix(:,1)=Lab_cen(:,1);
result_matrix(:,2:3)=Lab_cen(:,4:5);
result_matrix(:,4:5)=lab_scaled(:,4:5);
result_matrix(:,6:7)=Lab_cen(:,4:5)-lab_scaled(:,4:5);
result_matrix(:,8)=r_all;
result_matrix(end+1,:)=mean(result_matrix,1);


%%

opts.targetFontSize=12;
opts.margin=0.12;    
opts.label_type="L_C";
opts.if_rotate=false;

adjust_fig(pic_folder, opts);
%%
text_type="ch";
if strcmp(text_type,"eng")
    s.labels_row1 = {'preference center','original'};
    s.labels_row2 = {};
elseif strcmp(text_type,"ch")
    s.labels_row1 = {"喜好中心","原图肤色"};
    s.labels_row2 = {};
end

s.markers_row2 = {};
s.markers_colors = [];
s.markers_face_colors=[];

s.sidePad=0.2;
s.if_label=1;
s.colors_row1 = [1 0 0; 0 0 1];
s.marginL=0;
s.leg_x_shift=0.04;
s.h_space_scale=0.7;
s.posY_shift=0.2;
s.rowStep=0.2;
s.interpreter_type=interpreter_type;  % 传递给concatenate_figs_legend1
%----------------------
dir_figs=dir(fullfile(pic_folder,"*adjusted.fig"));   
clear("figFiles");i_fig1=1;
for i_fig=1:length(dir_figs)
    figFiles{i_fig1}=dir_figs(i_fig).name;
    i_fig1=i_fig1+1;
end

legend_file="";
s.label_x_offset=-0.025;
s.label_y_offset=-0.025;
concatenate_figs_legend1(pic_folder, figFiles, 2,legend_file,"draw",s,0.15,0.8);


fullfile(pwd,pic_folder)