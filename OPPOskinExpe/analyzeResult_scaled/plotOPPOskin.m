clear;close all;
%%
dir_oppoSkin = dir("OPPOskin\OPPOskinColor\*.csv");
output_folder = 'AnalyseResults';
model=["1","1","2","2","3","3",...
    "4","4","5","5",...
    "1","2","3","4"];
color={'r','g','r','g','r',...
    'g','r','g','r','g',...
    'b','b','b','b'};
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

L_limits = [min(all_L) - 1, max(all_L) + 1];
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
plot(x, y, 'k-', 'LineWidth', 0.5);

title(['\textit{a*-b*}'], 'Interpreter', 'latex', 'FontSize', 12*2); % 放大3倍
xlabel(['\textit{a*}'], 'Interpreter', 'latex', 'FontSize', 12*2); % 放大3倍
ylabel(['\textit{b*}'], 'Interpreter', 'latex', 'FontSize', 12*2); % 放大3倍
axis equal;
xlim(ab_limits);
ylim(ab_limits);
outputFolder = fullfile(output_folder, 'OPPOskin');
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end
exportgraphics(gcf, fullfile(outputFolder, 'a_b.jpg'),'Resolution',150);

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
    title(['\textit{L*-b*}'], 'Interpreter', 'latex','FontSize',12*2); % 放大3倍
    xlabel('\textit{b*}', 'Interpreter', 'latex','FontSize', 12*2); % 放大3倍
    ylabel('\textit{L*}', 'Interpreter', 'latex', 'FontSize',12*2); % 放大3倍
    axis equal;
end
ITA_boundaries = [55, 41, 28, 10, -30];
% b_range = linspace(b_limits(1), b_limits(2), 200);
b_range = linspace(10, 30, 200);
for ITA = ITA_boundaries
    L_line = 50 + b_range * tand(ITA);
    plot(b_range, L_line, 'k--', 'LineWidth', 1);
    text(b_range(end), L_line(end), sprintf('%d°', ITA), 'FontSize', 8, 'Color','k');
end
% xlim(b_limits);
% ylim(L_limits);
xlim([10,30]);
ylim([50,80]);
exportgraphics(gcf, fullfile(outputFolder, 'all_L_b.jpg'),'Resolution',150);

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
    title(['\textit{L*-C*}'], 'Interpreter', 'latex', 'FontSize', 12*2); % 放大3倍
    xlabel(['\textit{C*}'], 'Interpreter', 'latex', 'FontSize', 12*2); % 放大3倍
    ylabel(['\textit{L*}'], 'Interpreter', 'latex', 'FontSize', 12*2); % 放大3倍
    axis equal;
end
xlim(C_limits);
ylim(L_limits);
exportgraphics(gcf, fullfile(outputFolder, 'L_C.jpg'),'Resolution',150);

% L-h 图
figure;
hold on;
% 绘制水平方向竖线和标注
h_lines = 48:4:64;
labels_h = {'B', 'C', 'D', 'E', 'F'};
for i = 1:length(h_lines)
    plot([h_lines(i), h_lines(i)], [55, 70], 'k--', 'LineWidth', 1);
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
    title(['\textit{L*-h }'], 'Interpreter', 'latex', 'FontSize', 12*2); % 放大3倍
    xlabel(['\textit{h}'], 'Interpreter', 'latex', 'FontSize', 12*2); % 放大3倍
    ylabel(['\textit{L*}'], 'Interpreter', 'latex', 'FontSize', 12*2); % 放大3倍
    axis equal;
end
xlim(h_limits);
ylim(L_limits);
% xlim([h_limits(1)-5,h_limits(2)]);
% ylim([L_limits(1)-5,L_limits(2)]);
exportgraphics(gcf, fullfile(outputFolder, 'L_h.jpg'),'Resolution',150);

% concatenate_images1_23(outputFolder)
concatenate_images3(outputFolder,2)