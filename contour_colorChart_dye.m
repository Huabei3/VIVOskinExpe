close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量
addpath("utils\")
%%
%-------------i-----------------
nations=["AS","CA","SA","AF"];
% Move figure creation and settings outside the main loops
lastPart_types=[2,1];
% --- Initialize a single figure to hold all plots ---
h_combined = figure();
hold on;
title('Combined Ellipse Contours');
xlabel('{\ita*}');
ylabel('{\itb*}');
grid on;
axis equal;
% --- Initialize arrays to store all data for combined plotting ---
all_par = {};
all_lab_groups = {};
all_msv_groups = {};
all_min_a = inf;
all_max_a = -inf;
all_min_b = inf;
all_max_b = -inf;
all_lastPart_labels = {};
all_nation_labels = {};
all_attribute_labels = {};
all_scene_labels = {};

% --- New Switch for Plotting Mode ---
attri_type = "pre"; % Set to "pre" for Attribute 1 only, or "all" for Attributes 1-9
if strcmp(attri_type, "pre")
    attributes = [1];
else
    attributes = [1,2,3,4,5,6,7,8,9];
end
nation_indices = cell(5, 1); % 5个人种（包括"all"）
% AS (Asian): f04i, f05i, f06i, m04i, m05i, m06i (索引1-6)
nation_indices{1} = 1:6;
% CA (Caucasian): f01i, f02i, f03i, m01i, m02i, m03i (索引7-12)
nation_indices{2} = 7:12;
% SA (South Asian): f07i, f08i, m07i, m08i (索引13-16)
nation_indices{3} = 13:16;
% AF (African): f09i, f10i, m09i, m10i (索引17-20)
nation_indices{4} = 17:20;
% all: 所有索引 (索引1-20)
nation_indices{5} = 1:20;
% --- New Switch for Color Type ---
color_type = "nation"; % Options: "model", "nation", "attr", "scene"
scale_type_origin="unscaled";
num_colors = 20;
if strcmp(color_type, "nation")
    num_colors = length(nations);
elseif strcmp(color_type, "attr")
    num_colors = length(attributes);
elseif strcmp(color_type, "scene")
    num_colors = 14+3; 
elseif strcmp(color_type, "model")
    num_colors = 20; 
end
hue_values = linspace(0, 1, num_colors + 1);
hue_values = hue_values(1:end-1); 
hsv_matrix = [hue_values', 0.8 * ones(num_colors, 1), 0.8 * ones(num_colors, 1)];
line_colors = hsv2rgb(hsv_matrix);

% 初始化重塑后的数据结构
for i_lastParts=lastPart_types
    clear("target_indices");
    if i_lastParts==1
        lastParts = {'f04i', 'f05i', 'f06i', 'm04i', 'm05i', 'm06i',...
        'f01i', 'f02i', 'f03i', 'm01i', 'm02i', 'm03i',...
        'f07i', 'f08i','m07i', 'm08i',...
        'f09i', 'f10i','m09i', 'm10i'};n_para = 21;iOr='i';
    else
        %-------------rs----------------
        lastParts = {'f04r', 'f05r', 'f06r', 'm04r', 'm05r', 'm06r',...
        'f01r', 'f02r', 'f03r', 'm01r', 'm02r', 'm03r',...
        'f07r', 'f08r','m07r', 'm08r',...
        'f09r', 'f10r','m09r', 'm10r'};n_para = 14;iOr='r';
    end
    iOr=lastParts{1}(end);
    Dtype = 'efit_p';
    attribute_names = ["Preference", "Attractiveness", "Feminine", "Cooperative", ...
        "Youth", "Healthy", "Precise reproduction", "suit the environment or not",...
        "white-skinned", "ruddyadd"];
    attribute_names_new = ["Preference", "Attractiveness", "Feminine", "Cooperative", ...
        "Youth", "Healthy", "Fidelity","Harmony", "Fair", "Ruddy"];
    obs_types=["non_model"];
    % obs_types=["non_model","model_group","model"];
    wd65 = [94.811, 100.00, 107.304];
    if iOr =='i'
        picnames_groups = ["h3k","h4k","h5k","h6k","hd65","h7k","h8k",...
                        "m3k","m4k","m5k","m6k","md65","m7k","m8k",...
                         "l3k","l4k","l5k","l6k","ld65","l7k","l8k"];
        load('optimizedD\neutral_gray\combi_XYZw_i.mat', 'XYZ_combi',"CCT_combi");
        target_indices_plot = [5, 12, 19];
        CT = CCT_combi;
        XYZwpre=XYZ_combi;
    elseif iOr=='r'
        picnames_groups = ["rs01","rs02","rs03","rs04","rs05","rs06","rs07", ...
                 "rs08","rs09","rs10","rs11","rs12","rs13","rs14"];
        picnames_groups1=["1负一楼商场" ,"2负一楼vivo" ,"3下沉广场", "4学校饭堂" ,"5学校小卖部",...
        "6学校星巴克", "7草地顺光" ,"8草地侧光", "9草地逆光", "10阴天场景" ,...
        "11夕阳草地逆光", "12夕阳草地侧光", "13夜景小卖部门口", "14 极夜小卖部对面"];
        target_indices_plot = 1:14;
    end
    load(fullfile("documents",iOr,"render_data2.mat"),"render_map");
    Keys = keys(render_map);
    datai_file = 'D:\work\VIVOskinExpe\renderCode\calibResults\datai_ipv18_3.mat';
    LUT=load(datai_file);
    XYZw_LUT=LUT.XYZw;
    scale_type="scaled";
    hmls=["H","M","L","all"];
    for i_obs=1:length(obs_types)
        obs_type=obs_types(i_obs);
        
        for attribute = attributes
            attribute_serial = strcat(sprintf("%02d", attribute), attribute_names_new(attribute));
            for lastPartIdx = 1:length(lastParts)
                lastPart = lastParts{lastPartIdx};
                
                % Determine nation index
                i_nation = 0;
                for n_idx = 1:length(nations)
                    if ismember(lastPartIdx, nation_indices{n_idx})
                        i_nation = n_idx;
                        break;
                    end
                end

                if strcmp(lastPart(end),"i")||contains(lastPart,"add")
                    n_para=21;
                elseif strcmp(lastPart(end),"r")
                    n_para=14;
                end
                if iOr=='r'
                    white_file = fullfile("optimizedD\card_0830",...
                        strcat(lastPart, ".mat"));
                elseif iOr=='i'
                    white_file = fullfile("optimizedD\whiteSquare\XYZw_white", ...
                    strcat(lastPart, ".mat"));
                end
                load(white_file,"XYZw_white");
                source_file = fullfile('AnalyseResults_p', Dtype, scale_type_origin,lastPart, obs_type, ...
                    attribute_serial, 'ellipPara', 'fitRes.mat');
                par_all=[];
                if exist(source_file, 'file')
                    load(source_file,"parNr_all","par_all","picname_check");
                else
                    par_all(1:n_para,1:6)=NaN;
                    parNr_all(1:n_para,1:7)=NaN;
                end
                
                % Now, loop through the target_indices_plot to collect data
                for i_para = target_indices_plot
                    
                    if iOr == 'r' && ismember(lastPart, ["f04r","m01r"]) && ismember(i_para, [14])
                        continue;
                    end
                    if iOr == 'r' && ismember(attribute, [4,8]) && ismember(lastPart, ["f04r","f05r","m01r","f07r"]) && ismember(i_para, [6,14])
                        continue;
                    end
                    par = par_all(i_para, :);
                    par(:,6)=exp(log(par(:,6))/30);
                    if any(isnan(par))
                        fprintf('Skipping data collection for %s, index %d due to NaN values.\n', lastPart, i_para);
                        continue;
                    end
                    % Store par data and label for plotting
                    all_par{end+1} = par;
                    all_lastPart_labels{end+1} = lastPartIdx;
                    all_nation_labels{end+1} = i_nation;
                    all_attribute_labels{end+1} = attribute;
                    if i_lastParts==2
                        all_scene_labels{end+1} = 3+i_para; 
                    else
                        if i_para==5
                            all_scene_labels{end+1} = 1; 
                        elseif i_para==12
                            all_scene_labels{end+1} = 2; 
                        elseif i_para==19
                            all_scene_labels{end+1} = 3; 
                        end
                    end% Unique scene index
                    % Store scatter data if available
                    dir_labNgroup = dir(fullfile("AlalyseResults",lastPart,attribute_serial,"labNscore\*.mat"));
                    if ~isempty(dir_labNgroup) && i_para <= length(dir_labNgroup)
                        MSVNlab = load(fullfile(dir_labNgroup(i_para).folder, dir_labNgroup(i_para).name));
                        all_lab_groups{end+1} = MSVNlab.lab_group;
                        all_msv_groups{end+1} = MSVNlab.MSV_group;
                        
                        % Update global min/max for scatter data
                        all_min_a = min(all_min_a, min(MSVNlab.lab_group(:,2)));
                        all_max_a = max(all_max_a, max(MSVNlab.lab_group(:,2)));
                        all_min_b = min(all_min_b, min(MSVNlab.lab_group(:,3)));
                        all_max_b = max(all_max_b, max(MSVNlab.lab_group(:,3)));
                    end
                    
                    % Update global min/max for ellipse centers
                    all_min_a = min(all_min_a, par(4));
                    all_max_a = max(all_max_a, par(4));
                    all_min_b = min(all_min_b, par(5));
                    all_max_b = max(all_max_b, par(5));
                end
            end
        end
    end
end
%% --- Plotting all collected data on a single figure ---
% Iterate through all collected ellipse parameters and plot contours
for i = 1:length(all_par)
    par = all_par{i};
    
    % Determine the color index based on the new switch
    switch color_type
        case "model"
            color_index = all_lastPart_labels{i};
        case "nation"
            color_index = all_nation_labels{i};
        case "attr"
            color_index = all_attribute_labels{i};
        case "scene"
            color_index = all_scene_labels{i};
    end
    
    check_data2 = par(4) + (-30:0.2:30);
    check_data3 = par(5) + (-30:0.2:30);
    [data2, data3] = meshgrid(check_data2, check_data3);
    a = par;
    y = (1./(1+a(6)*exp(sqrt(a(1)*(data2-a(4)).^2+a(2)*(data3-a(5)).^2+ ...
        a(3)*(data2-a(4)).*(data3-a(5)))))).*((a(1)*(data2-a(4)).^2+ ...
        a(2)*(data3-a(5)).^2+a(3)*(data2-a(4)).*(data3-a(5)))>=0);
        
    % Plot contour with the assigned color and thinner line
    plot_handle = contour(data2, data3, y, [0.5, 1], 'Color', line_colors(color_index, :), 'Linewidth', 0.1);
    
    % Plot the center point with the same color
    scatter(par(4), par(5), 0.5, 'filled', 'MarkerFaceColor', line_colors(color_index, :), 'MarkerEdgeColor', line_colors(color_index, :));
    % Update global min/max for contour points
    all_min_a = min(all_min_a, min(check_data2));
    all_max_a = max(all_max_a, max(check_data2));
    all_min_b = min(all_min_b, min(check_data3));
    all_max_b = max(all_max_b, max(check_data3));
end
% Iterate through all collected scatter data and plot (optional)
for i = 1:length(all_lab_groups)
    scatter(all_lab_groups{i}(:,2), all_lab_groups{i}(:,3), 2, all_msv_groups{i}, 'filled');
end
% Set final plot limits
buffer = 5; % Add a small buffer to the limits
% xlim([all_min_a - buffer, all_max_a + buffer]);
% ylim([all_min_b - buffer, all_max_b + buffer]);
xlim([ -5, 25]);
ylim([ -5, 25]);
% Add x=0, y=0, and 45-degree lines
line([0, 0], [all_min_b - buffer, all_max_b + buffer], 'Color', 'k', 'LineStyle', '--', 'Linewidth', 1);
line([all_min_a - buffer, all_max_a + buffer], [0, 0], 'Color', 'k', 'LineStyle', '--', 'Linewidth', 1);
refline(1, 0);
% Finalize and save the figure
hold off;
save_folder = fullfile("ellip_pic_p", Dtype,"combined_plots",attri_type,color_type);
if ~exist(save_folder, "dir")
    mkdir(save_folder);
end
saveas(h_combined, fullfile(save_folder, 'Combined_Ellipses.jpg'));
function [lastPart1,model1]= gen_lastPart1(lastPart)
    model=lastPart(1:end-1);
    iOr=lastPart(end);
    if strcmp(model,'femalevivo')
        model1='femaleVIVO';
    elseif strcmp(lastPart,'malevivo')
        model1='maleVIVO';
    else
        model1=model;
    end
    lastPart1=strcat(model1,iOr);
end
function lastPart_new = gen_lastPart_new(lastPart1)
    if contains(lastPart1,'malevivo')
        lastPart_new = 'maleVIVOi';
    elseif contains(lastPart1,'femalevivo')
        lastPart_new = 'femaleVIVOi';
    else
        lastPart_new=lastPart1;
    end
end