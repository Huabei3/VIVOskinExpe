clear;clc;close all;
addpath("utils\")
interpreter_type="tex";  % 可选 "tex" 或 "latex"
%%
dir_oppoSkin = dir("OPPOskin\OPPOskinColor\*.csv");
output_folder = 'AnalyseResults';
model=["1","1","2","2","3","3",...
    "4","4","5","5",...
    "1","2","3","4"];
color={'r','g','r','g','r',...
    'g','r','g','r','g',...
    'b','b','b','b'};
num_attributes=3;
hue_values = linspace(0, 1, num_attributes + 1);
hue_values = hue_values(1:end-1);
hsv_matrix = [hue_values', 0.8 * ones(num_attributes, 1), 0.8 * ones(num_attributes, 1)];
colors_gender = hsv2rgb(hsv_matrix);
colors_gender(3,:)=[0 0 1];
for i_row=1:length(color)
    if ismember(i_row,[1,3,5,7,9])
        color{i_row}=colors_gender(1,:);
    elseif ismember(i_row,[2,4,6,8,10])
        color{i_row}=colors_gender(2,:);
    else
        color{i_row}=colors_gender(3,:);
    end
end

% Initialize storage for coordinates
all_L = [];all_a = [];all_b = [];
makeup=[1,3,5,7,9];
% Iterate through all files to calculate total average
picname=[];
for i_skin = 1:length(dir_oppoSkin)
    lab = readtable(fullfile(dir_oppoSkin(i_skin).folder, dir_oppoSkin(i_skin).name));
    picname=[picname;{dir_oppoSkin(i_skin).name(1:end-4)}];
    lab(1, :) = [];

    % Convert table to array
    lab = table2array(lab(:, 12:14)); % Take columns 12 to 14
    lab_mean = mean(lab, 1);

    % Store coordinates
    all_L = [all_L; lab_mean(1)];
    all_a = [all_a; lab_mean(2)];
    all_b = [all_b; lab_mean(3)];
    lab_OPPO{i_skin,1}=dir_oppoSkin(i_skin).name(1:end-4);
    lab_OPPO{i_skin,2}=lab_mean;
end
C=sqrt(all_a.^2+all_b.^2);
h=atan2d(all_b,all_a);
all_LabCh=[all_L,all_a,all_b,C,h];

% Calculate ITA and skin classifications
num_models = length(all_L);
ITA_vals = zeros(num_models, 1);
skin_classifications_cell = cell(num_models, 1);

for i = 1:num_models
    L = all_L(i);
    b = all_b(i);

    ITA_val = atand((L - 50) / b);
    ITA_vals(i) = ITA_val;

    if ITA_val > 55
        skin_classification_val = 'Very light';
    elseif ITA_val > 41 && ITA_val <= 55
        skin_classification_val = 'Light';
    elseif ITA_val > 28 && ITA_val <= 41
        skin_classification_val = 'Intermediate';
    elseif ITA_val > 10 && ITA_val <= 28
        skin_classification_val = 'Tan';
    elseif ITA_val > -30 && ITA_val <= 10
        skin_classification_val = 'Brown';
    elseif ITA_val <= -30
        skin_classification_val = 'Dark';
    else
        skin_classification_val = 'Unknown';
    end
    skin_classifications_cell{i} = skin_classification_val;
end


% Create a table to combine numerical and cell array data
all_LabCh_with_ITA = table(picname,all_L, all_a, all_b, C, h, ITA_vals, skin_classifications_cell, ...
    'VariableNames', {'picname','L', 'a', 'b', 'Chroma', 'Hue', 'ITA', 'SkinClassification'});

save_folder="OPPOskin";
if ~exist(save_folder,"dir")
    mkdir(save_folder);
end
save(fullfile(save_folder,"OPPOskin.mat"),"all_LabCh_with_ITA","picname","lab_OPPO");


%%
% 设置坐标轴范围

L_limits = [min(all_L) - 3, max(all_L) + 1];
a_limits = [min(all_a) - 1, max(all_a) + 1];
b_limits = [min(all_b) - 1, max(all_b) + 1];
C_limits = [min(C)- 1, max(C) + 1];
h_limits = [min(h)- 1, max(h) + 1];
ab_limits = [min(min(all_a), min(all_b)) - 1, max(max(all_a), max(all_b)) + 1];

for i_skin = 1:length(dir_oppoSkin)
    lab = readtable(fullfile(dir_oppoSkin(i_skin).folder, dir_oppoSkin(i_skin).name));
    lab(1, :) = [];
    
    % 将表格转换为数组
    lab = table2array(lab(:, 12:14)); % 取第12到14列
    lab_mean(i_skin,:) = mean(lab, 1);
end

% a-b 图
figure;
hold on;
for i_skin = 1:length(dir_oppoSkin)   
    plot(lab_mean(i_skin,2), lab_mean(i_skin,3), 'ro', ...
        'MarkerFaceColor', color{i_skin}, ...
        'MarkerEdgeColor', color{i_skin},...
        'MarkerSize', 5);
    text(lab_mean(i_skin,2)+0.2, lab_mean(i_skin,3), model(i_skin), ...
        'Color', 'k', 'FontSize', 8*2); % 放大3倍
    
    if ismember(i_skin,[1,3,5,7,9])
            quiver(lab_mean(i_skin + 1, 2), lab_mean(i_skin + 1, 3), ...
                lab_mean(i_skin, 2) - lab_mean(i_skin + 1, 2), ...
                lab_mean(i_skin, 3) - lab_mean(i_skin + 1, 3), ...
                0, 'Color', 'k', 'AutoScale', false, 'MaxHeadSize', 0.5);
    end
end
% 添加45°线
x = linspace(ab_limits(1), ab_limits(2), 1000);
y = x; % 45°线的方程是 y = x
plot(x, y, 'LineWidth', 1,'LineStyle','--','Color','k');

% title(['\textit{a*-b*}'], 'Interpreter', 'latex', 'FontSize', 12*2); % 放大3倍
if strcmp(interpreter_type,"tex")
    xlabel('a*','Interpreter','tex','FontName','Arial','FontAngle','italic', 'FontSize',12*2);
    ylabel('b*','Interpreter','tex','FontName','Arial','FontAngle','italic', 'FontSize',12*2);
elseif strcmp(interpreter_type,"latex")
    xlabel(['\textit{a*}'], 'Interpreter', 'latex', 'FontSize', 12*2);
    ylabel(['\textit{b*}'], 'Interpreter', 'latex', 'FontSize', 12*2);
end
axis equal;
xlim(ab_limits);
ylim(ab_limits);
outputFolder = fullfile(output_folder, 'OPPOskin');
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end


ax = gca;
targetFontSize=12;
set(ax, 'FontSize', targetFontSize);
set(findobj(gcf, 'Type', 'Text'), 'FontSize', targetFontSize); % 针对 LaTeX 标签
set(findobj(gcf, 'Type', 'Text'), 'FontSize', targetFontSize); % 针对 LaTeX 标签
set(allchild(ax), 'Clipping', 'on');
img_name=fullfile(outputFolder, 'a_b.jpg');    
savefig(gcf, strrep(img_name,'jpg','fig'));

exportgraphics(gcf, img_name,'Resolution',150);

% % L-a 图
% figure;
% hold on;
% for i_skin = 1:length(dir_oppoSkin)
%     plot(lab_mean(i_skin,2), lab_mean(i_skin,1), 'ro', ...
%         'MarkerFaceColor', color{i_skin}, ...
%         'MarkerEdgeColor', color{i_skin},...
%         'MarkerSize', 5);
%     text(lab_mean(i_skin,2)+0.2, lab_mean(i_skin,1), ...
%         model(i_skin), 'Color', 'k', 'FontSize', 8*3); % 放大3倍
% 
%     if ismember(i_skin,[1,3,5,7,9])
%             quiver(lab_mean(i_skin + 1, 2), lab_mean(i_skin + 1, 1), ...
%                 lab_mean(i_skin, 2) - lab_mean(i_skin + 1, 2), ...
%                 lab_mean(i_skin, 1) - lab_mean(i_skin + 1, 1), ...
%                 0, 'Color', 'k', 'AutoScale', false, 'MaxHeadSize', 0.5);
%     end
%     title('L-a', 'FontSize', 12*3); % 放大3倍
%     xlabel('a', 'FontSize', 12*3); % 放大3倍
%     ylabel('L', 'FontSize', 12*3); % 放大3倍
%     axis equal;
% end
% xlim(a_limits);
% ylim(L_limits);
% exportgraphics(gcf, fullfile(outputFolder, 'all_L_a.jpg'),'Resolution',150);
% 
% L-b 图
figure;
hold on;
b_limits1=[10,30];
L_limits1=[50,80];
for i_skin = 1:length(dir_oppoSkin)    

    plot(lab_mean(i_skin,3), lab_mean(i_skin,1), 'ro', ...
        'MarkerFaceColor', color{i_skin}, ...
        'MarkerEdgeColor', color{i_skin},...
        'MarkerSize', 5);
    text(lab_mean(i_skin,3)+0.2, lab_mean(i_skin,1), ...
        model(i_skin), 'Color', 'k', 'FontSize', 8*2); % 放大3倍
    if ismember(i_skin,[1,3,5,7,9])
            quiver(lab_mean(i_skin + 1, 3), lab_mean(i_skin + 1, 1), ...
                lab_mean(i_skin, 3) - lab_mean(i_skin + 1, 3), ...
                lab_mean(i_skin, 1) - lab_mean(i_skin + 1, 1), ...
                0, 'Color', 'k', 'AutoScale', false, 'MaxHeadSize', 0.5);
    end
    % title(['\textit{L*-b*}'], 'Interpreter', 'latex','FontSize',12*2); % 放大3倍
    if strcmp(interpreter_type,"tex")
        xlabel('b*','Interpreter','tex','FontName','Arial','FontAngle','italic', 'FontSize',12*2);
        ylabel('L*','Interpreter','tex','FontName','Arial','FontAngle','italic', 'FontSize',12*2);
    elseif strcmp(interpreter_type,"latex")
        xlabel('\textit{b*}', 'Interpreter', 'latex','FontSize', 12*2);
        ylabel('\textit{L*}', 'Interpreter', 'latex', 'FontSize',12*2);
    end
    axis equal;
end
ITA_boundaries = [55, 41, 28, 10, -30];
b_range = linspace(b_limits1(1), b_limits1(2), 200);

for ITA = ITA_boundaries
    L_line = 50 + b_range * tand(ITA);
    plot(b_range, L_line, 'k--', 'LineWidth', 1);
    if 50 + b_limits1(2) * tand(ITA) > L_limits1(2)
        b_intersect = (L_limits1(2) - 50) / tand(ITA);
        text(b_intersect, L_limits1(2), sprintf(' %d°', ITA), ...
            'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'center', 'FontSize', 9);
    else
        % 否则正常放在右边界
        text(b_limits1(2), L_line(end), sprintf(' %d°', ITA), ...
            'VerticalAlignment', 'middle', 'FontSize', 9);
    end
end
xlim(b_limits1);
ylim(L_limits1);



ax = gca;
targetFontSize=12;
set(ax, 'FontSize', targetFontSize);
set(findobj(gcf, 'Type', 'Text'), 'FontSize', targetFontSize); % 针对 LaTeX 标签
set(findobj(gcf, 'Type', 'Text'), 'FontSize', targetFontSize); % 针对 LaTeX 标签
set(allchild(ax), 'Clipping', 'on');
img_name=fullfile(outputFolder, 'all_L_b.jpg');    
savefig(gcf, strrep(img_name,'jpg','fig'));
exportgraphics(gcf, img_name,'Resolution',150);

% L-C 图
figure;
hold on;
for i_skin = 1:length(dir_oppoSkin)
    plot(C(i_skin), lab_mean(i_skin, 1), 'ro', ...
        'MarkerFaceColor', color{i_skin}, ...
        'MarkerEdgeColor', color{i_skin},...
        'MarkerSize', 5);
    text(C(i_skin)+0.2, lab_mean(i_skin, 1), ...
        model(i_skin), 'Color', 'k', 'FontSize', 8*2); % 放大3倍

    if ismember(i_skin,[1,3,5,7,9])
            quiver(C(i_skin + 1), lab_mean(i_skin + 1, 1), ...
                C(i_skin) - C(i_skin + 1), ...
                lab_mean(i_skin, 1) - lab_mean(i_skin + 1, 1), ...
                0, 'Color', 'k', 'AutoScale', false, 'MaxHeadSize', 0.5);
    end
    % title(['\textit{L*-C*}'], 'Interpreter', 'latex', 'FontSize', 12*2); % 放大3倍
    if strcmp(interpreter_type,"tex")
        xlabel('C*','Interpreter','tex','FontName','Arial','FontAngle','italic', 'FontSize',12*2);
        ylabel('L*','Interpreter','tex','FontName','Arial','FontAngle','italic', 'FontSize',12*2);
    elseif strcmp(interpreter_type,"latex")
        xlabel(['\textit{C*}'], 'Interpreter', 'latex', 'FontSize', 12*2);
        ylabel(['\textit{L*}'], 'Interpreter', 'latex', 'FontSize', 12*2);
    end
    axis equal;
end
xlim(C_limits);
ylim(L_limits);

ax = gca;
targetFontSize=12;
set(ax, 'FontSize', targetFontSize);
set(findobj(gcf, 'Type', 'Text'), 'FontSize', targetFontSize); % 针对 LaTeX 标签
set(findobj(gcf, 'Type', 'Text'), 'FontSize', targetFontSize); % 针对 LaTeX 标签
set(allchild(ax), 'Clipping', 'on');
img_name=fullfile(outputFolder, 'L_C.jpg');    
savefig(gcf, strrep(img_name,'jpg','fig'));
exportgraphics(gcf, img_name,'Resolution',150);

% L-h 图
figure;
hold on;
% 绘制水平方向竖线和标注

h_lines = h_limits(1):4:h_limits(2);
labels_h = {'B', 'C', 'D', 'E', 'F'};
for i = 1:length(h_lines)
    plot([h_lines(i), h_lines(i)], [L_limits(1), L_limits(2)], 'k--', 'LineWidth', 1);
    if i <= length(labels_h)
        text(h_lines(i)+2, 57, labels_h{i}, 'HorizontalAlignment', 'center', 'FontSize', 12,'color','g');
    end
end

% 绘制垂直方向横线和标注
L_lines = 55:3:70;
labels_L = {'5', '4', '3', '2', '1'};
for i = 1:length(L_lines)
    plot([48, 64], [L_lines(i), L_lines(i)], 'k--', 'LineWidth', 1);
    if i <= length(labels_L)
        text(49, L_lines(i)+1.5, labels_L{i}, 'VerticalAlignment', 'middle', 'FontSize', 12,'color','g');
    end
end

for i_skin = 1:length(dir_oppoSkin)
    plot(h(i_skin), lab_mean(i_skin, 1), 'ro', ...
        'MarkerFaceColor', color{i_skin}, ...
        'MarkerEdgeColor', color{i_skin},...
        'MarkerSize', 5);
    text(h(i_skin)+0.2, lab_mean(i_skin, 1), ...
        model(i_skin), 'Color', 'k', 'FontSize', 8*2); % 放大3倍

    if ismember(i_skin,[1,3,5,7,9])
            quiver(h(i_skin + 1), lab_mean(i_skin + 1, 1), ...
                h(i_skin) - h(i_skin + 1), ...
                lab_mean(i_skin, 1) - lab_mean(i_skin + 1, 1), ...
                0, 'Color', 'k', 'AutoScale', false, 'MaxHeadSize', 0.5);
    end
    % title(['\textit{L*-h }'], 'Interpreter', 'latex', 'FontSize', 12*2); % 放大3倍
    if strcmp(interpreter_type,"tex")
        xlabel('h','Interpreter','tex','FontName','Arial','FontAngle','italic', 'FontSize',12*2);
        ylabel('L*','Interpreter','tex','FontName','Arial','FontAngle','italic', 'FontSize',12*2);
    elseif strcmp(interpreter_type,"latex")
        xlabel(['\textit{h}'], 'Interpreter', 'latex', 'FontSize', 12*2);
        ylabel(['\textit{L*}'], 'Interpreter', 'latex', 'FontSize', 12*2);
    end
    axis equal;
end
xlim(h_limits);
ylim(L_limits);
% xlim([h_limits(1)-5,h_limits(2)]);
% ylim([L_limits(1)-5,L_limits(2)]);


ax = gca;
targetFontSize=15;
set(ax, 'FontSize', targetFontSize);
set(findobj(gcf, 'Type', 'Text'), 'FontSize', targetFontSize); % 针对 LaTeX 标签
set(findobj(gcf, 'Type', 'Text'), 'FontSize', targetFontSize); % 针对 LaTeX 标签
set(allchild(ax), 'Clipping', 'on');
img_name=fullfile(outputFolder, 'L_h.jpg');    
savefig(gcf, strrep(img_name,'jpg','fig'));

exportgraphics(gcf, img_name,'Resolution',150);

% concatenate_images1_23(outputFolder)
concatenate_images3(outputFolder,2)


%%
opts.targetFontSize=12;
opts.margin=0.6;    
opts.label_type="skinOPPO";
opts.if_rotate=false;
opts.margin_type="Position";
% opts.bar_interval=0.4;
adjust_fig(outputFolder, opts);
%%


s.labels_row1 = {'女性带妆', '女性素颜', '男性'};
s.labels_row2 = {};
s.markers_row2 = {};
s.markers_colors = [];
s.markers_face_colors = [];
s.label_type="skinOPPO";
s.marginL=0;
s.fig_wh_base=[1000 900];
s.label_fontSize=12;
s.if_label=1;

num_attributes = numel(s.labels_row1);
hue_values = linspace(0, 1, num_attributes + 1);
hue_values = hue_values(1:end-1);
hsv_matrix = [hue_values', 0.8 * ones(num_attributes, 1), 0.8 * ones(num_attributes, 1)];
s.colors_row1 = hsv2rgb(hsv_matrix);
s.colors_row1(3,:)=[0 0 1];
s.interpreter_type=interpreter_type;  
%----------------------
dir_figs=dir(fullfile(outputFolder,"*adjusted.fig"));
for i_fig=1:length(dir_figs)
    figFiles{i_fig}=dir_figs(i_fig).name;
end
s.label_x_offset=-0.06;
s.label_y_offset=-0.06;
s.fontSizeScale=1;
concatenate_figs_legend1(outputFolder, figFiles, 2,"","draw",s,0.25,0.08);


fullfile(pwd,outputFolder)