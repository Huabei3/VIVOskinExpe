
%%
close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量
%% Load Data
load("neutral24\white.mat","CCT","XYZ_gray","result_cell");
load("OPPOskin\matchTable_map.mat");
load("neutral24\global_ratio.mat");
% Organize XYZ_gray data by scene
XYZ_gray_scene{1}=XYZ_gray(1:14,:);
XYZ_gray_scene{2}=XYZ_gray(15:24,:);
XYZ_gray_scene{3}=XYZ_gray(25:34,:);
XYZ_gray_scene{4}=XYZ_gray(35:44,:);
XYZ_gray_scene{5}=XYZ_gray(44:52,:);
% Remove specific entries based on original code logic
XYZ_gray_scene{2}(5,:)=[];
XYZ_gray_scene{5}([1,2,3,8],:)=[];
% Calculate CCT and mean CCT for each scene
for i_lastPart=1:5
    CCTpre{i_lastPart,1}=xyz2CCT(XYZ_gray_scene{i_lastPart},10);
    CCTpre{i_lastPart,1}=CCTpre{i_lastPart,1}';
    CCT_mean(i_lastPart,1)=mean(CCTpre{i_lastPart,1},1);
end
%% Define Parameters
lastParts=["inLab","indoorAdd","nightAdd","outdoorAdd","sunsetAdd"];
Dtype="OPPO_CAT16";
lightness_type="rela";
% Define the maximum limit for both x and y axes
max_lim = 30; % You can adjust this value as needed
%% Plotting Model Individual Data Across Scenes
scene_ind_file=fullfile("AnalyseResults\OPPO_CAT16\ellipPara_scaled\scene_ind\fitRes_level_.mat");
data=load(scene_ind_file);

% --- New outer loop: Iterate through models ---
for i_model=1:9 % Assuming there are 9 models based on your original loop
    figure(i_model); % Create a new figure for each model
    clf;       % Clear the current figure for each new plot
    hold on;
    set(gcf, 'Color', 'white'); % Set figure background to white

    % --- New inner loop: Iterate through lastParts (scenes) for the current model ---
    for i_lastPart=1:length(lastParts)
        lastPart = lastParts(i_lastPart);
        
        par=data.par_all_per_scene{i_model,i_lastPart};
        if isempty(par)
            continue
        end
        ave_L=mean(data.lab_type_per_scene{i_model,i_lastPart}(:,1));
        lab=[ave_L,par(6:7)];
        xyz_scene_ind=lab2xyz(lab,"d65_64");
        rgb_scene_ind=xyz2srgb(xyz_scene_ind)./255;
        
        scatter(lab(2), lab(3), 50, 'o', 'filled', ...
        'MarkerFaceColor', rgb_scene_ind, 'MarkerEdgeColor', 'k', 'LineWidth', 0.5);
        
        % Label each point with the scene name
        text(lab(2), lab(3), ...
         strrep(lastPart,"Add",""), 'FontSize', 6, ...
        'VerticalAlignment', 'top', 'Color', 'k');
    end

% --- Add Labels and Title ---
    xlabel('{\ita*}', 'FontSize', 10);
    ylabel('{\itb*}', 'FontSize', 10);
    % Title now indicates the current model
    h_title = title([sprintf('Model %d Across Scenes', i_model),"",""], 'FontSize', 12);
    

    
    % --- Set Axis Limits ---
    axis equal;
    xlim([0, max_lim]);
    ylim([0, max_lim]);
    
    % --- Draw y=x reference line ---
    x = linspace(0, max_lim, 100);
    plot(x, x, 'k--', 'LineWidth', 0.8);
    
    % --- Draw angle lines and labels ---
    for theta = 0:5:90 % Angles from 0 to 90 degrees, every 5 degrees
        m = tan(deg2rad(theta)); % Calculate slope from angle in radians
        
        % Calculate points for the line
        x_line = linspace(0, max_lim, 100);
        y_line = m * x_line;
        
        % Only plot points within the defined y-limits and x-limits
        valid_line_idx = (y_line >= 0) & (y_line <= max_lim) & (x_line >= 0) & (x_line <= max_lim);
        plot(x_line(valid_line_idx), y_line(valid_line_idx), 'k:', 'LineWidth', 0.5);
        
        % Add angle label at the edge of the plot
        if theta == 90 % Handle vertical line separately to avoid division by zero
            label_x = 0;
            label_y = max_lim;
            text(label_x, label_y, sprintf('%d°', theta), 'VerticalAlignment', 'top', ...
                 'HorizontalAlignment', 'left', 'FontSize', 7, 'Color', 'k');
        elseif theta == 0 % Handle horizontal line
            label_x = max_lim;
            label_y = 0;
            text(label_x, label_y, sprintf('%d°', theta), 'VerticalAlignment', 'bottom', ...
                 'HorizontalAlignment', 'right', 'FontSize', 7, 'Color', 'k');
        else
            % Determine where to place the label (either x_max or y_max)
            if m * max_lim <= max_lim % Line intersects the right boundary (x = max_lim)
                label_x = max_lim;
                label_y = m * max_lim;
            else % Line intersects the top boundary (y = max_lim)
                label_y = max_lim;
                label_x = max_lim / m;
            end
            text(label_x, label_y, sprintf('%d°', theta), 'VerticalAlignment', 'bottom', ...
                 'HorizontalAlignment', 'right', 'FontSize', 7, 'Color', 'k');
        end
    end
    % --- Save Picture ---
    output_folder=fullfile("AnalyseResults",Dtype,"model_ind_across_scenes"); % Changed output folder name
    if ~exist(output_folder, 'dir')
        mkdir(output_folder);
    end
    % Save filename now includes model number
    exportgraphics(gcf,fullfile(output_folder,strcat('Model_', num2str(i_model), ".jpg")), 'Resolution', 300);
end
concatenate_images(output_folder, 4);