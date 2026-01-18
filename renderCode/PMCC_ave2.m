clear; clc; close all;
%%

% load("OPPOskin\matchTable.mat","match_table");
% load("OPPOskin\OPPOskin.mat","all_LabCh");
load("findCen_srgb_scaled\autoNhand_srgb_scaled.mat", ...
    "average_lab2","XYZw_pre_pic","de002");

% load("Z:\homes\Peggy\oppoSkinExperi\analyzeResult\CATed\iNrs\CATedPre.mat");
wd65=[94.813  100.000  107.262];
lab_PMCC=[62.11,18.96,19.76];

lab_PMCC_rep=repmat(lab_PMCC,length(average_lab2),1);
de00=deltaE2000(average_lab2,lab_PMCC_rep);
de00=de00';
de00_ab=deltaE2000(average_lab2,[average_lab2(:,1),lab_PMCC_rep(:,2:3)]);
de00_ab=de00_ab';
de00_La=deltaE2000(average_lab2,[lab_PMCC_rep(:,1),average_lab2(:,2),lab_PMCC_rep(:,3)]);
de00_La=de00_La';
de00_Lb=deltaE2000(average_lab2,[lab_PMCC_rep(:,1:2),average_lab2(:,3)]);
de00_Lb=de00_Lb';


filename = 'Z:\homes\Peggy\oppoSkinExperi\points48.xlsx';                               %文件名
num_points = readmatrix(filename); 
num_center = num_points(53,:); 
num_points(50:53,:)=[];
num_points=num_points-repmat(num_points(49,:),49,1);

set_points=cell(49,1);
for i_oriPic=1:length(average_lab2)
    set_points{i_oriPic,:}=repmat(average_lab2(i_oriPic,:),49,1)+num_points;
end

files=dir("Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\*.jpg");

save_folder="ave2_PMCC";
% 检查并创建保存文件夹
if ~exist(save_folder, 'dir')
    mkdir(save_folder);
end

color='k';
for i_oriPic=1:length(average_lab2)
    %a_b
    figure((i_oriPic-1)*3+1);
    subplot('Position', [0.1, 0.3, 0.8, 0.6]); % 调整绘制区域位置和尺寸
    hold on;
    scatter_Lab=set_points{i_oriPic,:};
    scatter(scatter_Lab(1:16,2), scatter_Lab(1:16,3), 30, 'o','LineWidth', 0.5);
    % 标注中心
    plot(average_lab2(i_oriPic,2), average_lab2(i_oriPic,3), 'p', 'MarkerSize', 15, 'MarkerFaceColor', color);
    plot(lab_PMCC(1,2), lab_PMCC(1,3),  's', 'MarkerSize', 15, ...
        'MarkerFaceColor', [1, 0.4, 0.8], 'MarkerEdgeColor', color);

    title(strcat("OPPOskin\_PMCC\_a\_b\_",sprintf("%02d",i_oriPic),".jpg"));

    annotation('textbox', [0.1, 0.05, 0.8, 0.2], 'String', ...
    sprintf(['de00:%d de00_{ab}:%d\n' ...
    'de00_{La}:%d de00_{Lb}:%d'], ...
     de00(i_oriPic,1),de00_ab(i_oriPic,1),de00_La(i_oriPic,1),de00_Lb(i_oriPic,1)), ...
    'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
    'BackgroundColor', 'white', 'EdgeColor', 'black', 'FontSize', 8);
    output_folder=fullfile(save_folder,"a_b");
    % 检查并创建保存文件夹
    if ~exist(output_folder, 'dir')
        mkdir(output_folder);
    end    
    saveas((i_oriPic-1)*3+1,fullfile(output_folder,strcat('OPPOskin PMCC ab ',sprintf("%02d",i_oriPic),".jpg")));
    
    
    %L-a
    figure((i_oriPic-1)*3+2);
    hold on;
    scatter_Lab=set_points{i_oriPic,:};
    scatter(scatter_Lab(33:48,2), scatter_Lab(33:48,1), 30, 'o','LineWidth', 0.5);
    % 标注中心
    plot(average_lab2(i_oriPic,2), average_lab2(i_oriPic,1), 'p', 'MarkerSize', 15, 'MarkerFaceColor', color);
    plot(lab_PMCC(1,2), lab_PMCC(1,1),  's', 'MarkerSize', 15, ...
        'MarkerFaceColor', [1, 0.4, 0.8], 'MarkerEdgeColor', color);
    title(strcat("OPPOskin\_PMCC\_L\_a\_",sprintf("%02d",i_oriPic),".jpg"));
    output_folder=fullfile(save_folder,"L_a");
    % 检查并创建保存文件夹
    if ~exist(output_folder, 'dir')
        mkdir(output_folder);
    end
    saveas((i_oriPic-1)*3+2,fullfile(output_folder,sprintf("OPPOskin PMCC La %02d.jpg",i_oriPic)));
    
    %L_b
    figure((i_oriPic-1)*3+3);
    hold on;
    scatter_Lab=set_points{i_oriPic,:};
    scatter(scatter_Lab(17:32,3), scatter_Lab(17:32,1), 30, 'o','LineWidth', 0.5);
    % 标注中心
    plot(average_lab2(i_oriPic,3), average_lab2(i_oriPic,1), 'p', 'MarkerSize', 15, 'MarkerFaceColor', color);
    plot(lab_PMCC(1,3), lab_PMCC(1,1),  's', 'MarkerSize', 15, ...
        'MarkerFaceColor', [1, 0.4, 0.8], 'MarkerEdgeColor', color);
    title(strcat("OPPOskin\_PMCC\_L\_b\_",sprintf("%02d",i_oriPic),".jpg"));
    output_folder=fullfile(save_folder,"L_b");
    % 检查并创建保存文件夹
    if ~exist(output_folder, 'dir')
        mkdir(output_folder);
    end
    saveas((i_oriPic-1)*3+3,fullfile(output_folder,strcat('OPPOskin and PMCC Lb ',sprintf("%02d",i_oriPic),".jpg")));
end