close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量
addpath("utils\")
%%
% data_type="old";
data_type="likeVIVO";
% Dtype="noCAT";
Dtype="efit_p";

scale_type="scaled";
% scale_type="unscaled";

if strcmp(data_type,"old")
    save_folder="AnalyseResults_p\old\fitRes";
    load("fitRes\fitRes_level_m.mat");
elseif strcmp(data_type,"likeVIVO")
    save_folder=fullfile("AnalyseResults_p",Dtype,scale_type,"fitRes");
    load(fullfile(save_folder,"fitRes_level_p.mat"));
end
pic_folder=fullfile(save_folder,"ellip_levels");
if ~exist(pic_folder,"dir")
    mkdir(pic_folder);
end
labCh_PMCC=[[62.11	18.96	19.76	27.39	46.18];...
        [64.15	19.56	19.63	27.71	45.10];...
        [56.01	18.25	18.72	26.14	45.72];...
        [41.06	17.37	17.94	24.97	45.93]];

XYZw_pre=[99.8408323170247,	100,	67.3098058505433];
XYZw_ori_PMCC=[0.824896999038825	0.845965324097912	0.747165892096635]*100;

% load("fitRes\fitRes_level_m.mat");
n_para=size(par_all,1);
wd65_64 = [94.811, 100.00, 107.304];
XYZw_PMCC=[0.824896999038825	0.845965324097912	0.747165892096635]*100;
% lab_ori=[63.4304   13.6518   31.2004];
%%

hue_values = linspace(0, 1, n_para + 1);hue_values = hue_values(1:end-1); 
hsv_matrix = [hue_values', 0.8 * ones(n_para, 1), 0.8 * ones(n_para, 1)];
colors = hsv2rgb(hsv_matrix);

figure();hold on;
for i_level=1:n_para
    par=par_all(i_level,:);
    check_data2 = par(4) + (-30:0.2:30);
    check_data3 = par(5) + (-30:0.2:30);
    [data2, data3] = meshgrid(check_data2, check_data3);
    [row, col] = size(data2);
    
    % 计算等高线数据
    a = par;
    y = (1./(1+a(6)*exp(sqrt(a(1)*(data2-a(4)).^2+a(2)*(data3-a(5)).^2+ ...
        a(3)*(data2-a(4)).*(data3-a(5)))))).*((a(1)*(data2-a(4)).^2+ ...
        a(2)*(data3-a(5)).^2+a(3)*(data2-a(4)).*(data3-a(5)))>=0);
    
    % 绘制等高线
    color=colors(i_level,:);
    s0 = contour(data2, data3, y, [0.5, 1], 'LineWidth', 1, ...
         'Color', color);
    hold on;
    % 绘制特殊点
    plot(par(4), par(5), 'o', 'MarkerSize', 4, ...
        'MarkerFaceColor', color, 'Color', color);
end
% 设置坐标轴标签和标题
xlabel('\textit{$a^*$}', 'Interpreter', 'latex', 'FontSize', 12*2);
ylabel('\textit{$b^*$}', 'Interpreter', 'latex', 'FontSize', 12*2);
% 设置标题为斜体
% title('\textit{$a^*-b^*$}', 'Interpreter', 'latex', 'FontSize', 12*2);
lim_min = 0;
lim_max = 40;
hold on;
axis equal;
xlim([lim_min, lim_max]);
ylim([lim_min, lim_max]);
plot(labCh_PMCC(1,2), labCh_PMCC(1,3), 's', 'MarkerSize', 5, ...
    'MarkerFaceColor', 'm', 'MarkerEdgeColor','m');
x = lim_min:0.1:lim_max;
plot(x,x,"Color","k",'LineStyle','--','LineWidth',1);

img_name=fullfile(pic_folder,"contour_levels.jpg");    
savefig(gcf, strrep(img_name,'jpg','fig'));
exportgraphics(gcf,img_name);

%%

opts.targetFontSize=12;
opts.margin=0.12;    
opts.label_type="level";
opts.if_rotate=false;

adjust_fig(pic_folder, opts);


s.labels_row1 = {"$L^*$=10","$L^*$=20","$L^*$=30","$L^*$=40",...
"$L^*$=50","$L^*$=60","$L^*$=70","$L^*$=80"};
s.colors_row1=colors;
s.labels_row2 = {"喜好中心","PMCC"};
s.Gap2_scale=1.5;

s.markers_row2 = {'o','s'};
s.markers_colors = [0 0 0; 1 0 1];
s.markers_face_colors=[0 0 0; 1 0 1];

s.sidePad=0.2;
s.if_label=0;

s.marginL=0.25;
s.leg_x_shift=-0.18;
s.h_space_scale=0.7;
s.posY_shift=0.2;
s.rowStep=0.3;
s.n_col1=4;
s.n_col2=2;


%----------------------
dir_figs=dir(fullfile(pic_folder,"*adjusted.fig"));   
clear("figFiles");i_fig1=1;
for i_fig=1:length(dir_figs)
    figFiles{i_fig1}=dir_figs(i_fig).name;
    i_fig1=i_fig1+1;
end

legend_file="";
concatenate_figs_legend1(pic_folder, figFiles, 1,legend_file,"draw",s,0.15,1.3);


fullfile(pwd,pic_folder)