close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量
addpath("utils\")
%%
%-------------i-----------------
nations=["AS","CA","SA","AF"];
% Move figure creation and settings outside the main loops
h1=figure(1);
hold on;
h2=figure(2);
hold on;
lastPart_types=[1,2];
% Initialize a structure to store all data for later use in the callback
all_plot_data = struct('a', [], 'b', [], 'L', [], 'C', [], 'E', [], ...
    'picname', {}, 'attribute', {}, 'lastpart', {});
data_idx = 0; % Index for adding data to the structure
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
    Dtype = 'efit2';
    attributes=[1,2,3,4,5,6,7,8,9,10];
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
        target_indices{1}=5;
        target_indices{2}=12;
        target_indices{3}=19;
        % target_indices{4}=[5,12,19];
        CT = CCT_combi;
        XYZwpre=XYZ_combi;
    elseif iOr=='r'
        picnames_groups = ["rs01","rs02","rs03","rs04","rs05","rs06","rs07", ...
                 "rs08","rs09","rs10","rs11","rs12","rs13","rs14"];
        picnames_groups1=["1负一楼商场" ,"2负一楼vivo" ,"3下沉广场", "4学校饭堂" ,"5学校小卖部",...
        "6学校星巴克", "7草地顺光" ,"8草地侧光", "9草地逆光", "10阴天场景" ,...
        "11夕阳草地逆光", "12夕阳草地侧光", "13夜景小卖部门口", "14 极夜小卖部对面"];
        target_indices{1}=1:14;
    end
    load(fullfile("documents",iOr,"render_data2.mat"),"render_map");
    Keys = keys(render_map);
    datai_file = 'D:\work\VIVOskinExpe\renderCode\calibResults\datai_ipv18_3.mat';
    LUT=load(datai_file);
    XYZw_LUT=LUT.XYZw;
    scale_type="scaled";
    hmls=["H","M","L","all"];
    
    % 预定义颜色和标记样式
    colors = lines(length(attributes)); % 使用内置颜色图
    for i_obs=1:length(obs_types)
        obs_type=obs_types(i_obs);
        
        % 定义保存的汇总 Excel 文件名
        outputFolder=fullfile( "AnalyseResults1",Dtype,"sum_list");
        if ~exist(outputFolder,"dir")
            mkdir(outputFolder);
        end
        
        summary_filename = fullfile( outputFolder, ...
            strcat('characteristic_para_',iOr,'_',obs_type,'.xlsx'));  
        if exist(summary_filename, 'file')
            delete(summary_filename);
        end
        summary_filename1 = fullfile( outputFolder, ...
        strcat('average_',iOr,'.xlsx'));    
        if exist(summary_filename1, 'file')
            delete(summary_filename1);
        end
        for i_indice=1:length(target_indices)
            
            % ⚠️ Move figure settings to be called just once
            figure(h1);
            if iOr=='i'
                title(["All Attributes",hmls(i_indice),"a-b"])
            else
                title(["All Attributes","a-b"])
            end
            grid on;
            axis equal;
            if iOr=="i"
                max_lim_ab=35;
            else
                max_lim_ab=50;
            end
            min_lim_ab=0;
            xticks(min_lim_ab:5:max_lim_ab)
            yticks(min_lim_ab:5:max_lim_ab)
            xlim([min_lim_ab,max_lim_ab])
            ylim([min_lim_ab,max_lim_ab])
            
            figure(h2);
            if iOr=='i'
                title(["All Attributes",hmls(i_indice),"L-C"])
            else
                title(["All Attributes","L-C"])
            end
            grid on;
            axis equal;
            if iOr=="i"
                max_lim_lc=100;
                min_lim_lc=25;
            else
                max_lim_lc=100;
                min_lim_lc=15;
            end
            xticks(0:5:50)
            yticks(min_lim_lc:5:max_lim_lc)
            xlim([0,50])
            ylim([min_lim_lc,max_lim_lc])
    
            
            % Initialize arrays to hold data for vectorized plotting
            all_a = [];
            all_b = [];
            all_L = [];
            all_C = [];
            all_E = [];
            
            % 遍历所有 attribute
            for attribute = attributes
                attribute_serial = strcat(sprintf("%02d", attribute), attribute_names_new(attribute));
                
                % 遍历每个 lastPart
                for lastPartIdx = 1:length(lastParts)
                    lastPart = lastParts{lastPartIdx};
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
                    
                    % 定义保存的 Excel 文件名
                    output_folder=fullfile("sum_list", Dtype,obs_type,lastPart);
                    if ~exist(output_folder,"dir")
                        mkdir(output_folder);
                    end
                    output_filename = fullfile(output_folder, 'ellip_list_all.xlsx');
                    % 如果文件已存在，删除它们以确保新数据写入
                    if exist(output_filename, 'file')
                        delete(output_filename);
                    end
                 
                    % 初始化汇总数据
                    concatenated_table = table();
                    concatenated_table1 = table();
                
                    source_file = fullfile('AnalyseResults1', Dtype, lastPart, obs_type, ...
                        attribute_serial, 'ellipPara', 'fitRes.mat');
                    par_all=[];
                    if exist(source_file, 'file') % 新增 source_file4 的加载
                        load(source_file,"parNr_all","par_all","picname_check");
                    else                
                        par_all(1:n_para,1:6)=NaN;
                        parNr_all(1:n_para,1:7)=NaN;
                    end
            
                    slashes = strfind(source_file, '\');
                    
                    save_folder = fullfile("ellip_pic", Dtype );
                    if ~exist(save_folder, "dir")
                        mkdir(save_folder);
                    end
                    
                    model = lastPart(1:end-1);
                    
                    [lastPart1, model1] = gen_lastPart1(lastPart);
                    lastPart_new = gen_lastPart_new(lastPart1);
                    
                    average_file = fullfile("aveSkin", strrep(lastPart_new,"add",""), ...
                        "autoNhand_scaleoverLUT.mat");
                    average = load(average_file);
                    average_bf = average.average_lab_all(:, 1:3);
                    %late CAT
                    XYZ_bf=lab2xyz2(average_bf,'d65_64');
                    for i_para=1:length(picname_check)
                        curr_struct=render_map(picname_check{i_para, 1});
                        CT(i_para,1) =curr_struct.CCT_val;
                        XYZwpre(i_para,:)=curr_struct.XYZw_pre_val;
        
                        D_pre(i_para,1)= calculateD(CT(i_para,1), 0, "efit2");
                        XYZt(i_para,:) = CAT16_D(XYZ_bf(i_para,:), ...
                            XYZwpre(i_para,:), wd65, D_pre(i_para,1));                
                    end
                    average = xyz2lab(XYZt, 'd65_64');
                    L = average(:, 1);
                    labCh(:, 1) = L;
                    par_all=[par_all;...
                                nan(size(labCh,1)-size(par_all,1),size(par_all,2))];
                    labCh(:, 2:3) = par_all(:, 4:5);
                    labCh(:, 4) = sqrt(par_all(:, 4).^2 + par_all(:, 5).^2);
                    labCh(:, 5) = atan2d_360(par_all(:, 5), par_all(:, 4));
                    
                    if strcmp(scale_type,"scaled")
                        for i_para=1:length(picname_check)
                            xyz_fit(i_para,:)=lab2xyz2(labCh(i_para,1:3),"user",wd65./wd65(2).*XYZw_LUT(2));
                            lab_scaled(i_para,1:3)=xyz2lab(xyz_fit(i_para,:),"user",wd65./wd65(2).*XYZw_white(i_para,2));
                        end
                    else
                        lab_scaled=labCh;
                    end
                    lab_scaled(:,4)=sqrt(lab_scaled(:,2).^2+lab_scaled(:,3).^2)';
                    lab_scaled(:,5)=atan2d(lab_scaled(:,3),lab_scaled(:,2));
                    
                    % ⚠️ Collect data into the structure instead of plotting here
                    for i_para=target_indices{i_indice}    
                        if i_para==13
                            continue
                        end
                        curr_struct=render_map(picname_check{i_para, 1});
                        E =curr_struct.E_val;
                        
                        % Store data with associated metadata
                        data_idx = data_idx + 1;
                        all_plot_data(data_idx).a = lab_scaled(i_para,2);
                        all_plot_data(data_idx).b = lab_scaled(i_para,3);
                        all_plot_data(data_idx).L = lab_scaled(i_para,1);
                        all_plot_data(data_idx).C = lab_scaled(i_para,4);
                        all_plot_data(data_idx).E = E;
                        all_plot_data(data_idx).picname = picnames_groups(i_para);
                        all_plot_data(data_idx).attribute = attribute_names_new(attribute);
                        all_plot_data(data_idx).lastpart = lastPart;
                    end
                end
            end
            
            % ⚠️ Perform vectorized plotting after the loops, using the collected data
            all_a = [all_plot_data.a];
            all_b = [all_plot_data.b];
            all_L = [all_plot_data.L];
            all_C = [all_plot_data.C];
            all_E = [all_plot_data.E];
            
            figure(h1);
            scatter(all_a, all_b, 10, all_E, 'filled');
            
            figure(h2);
            scatter(all_C, all_L, 10, all_E, 'filled');
            
            % ⚠️ Add colorbar and colormap just once
            figure(h1);
            colorbar;
            colormap(h1, 'gray');
            
            figure(h2);
            colorbar;
            colormap(h2, 'gray');
        end
    end
end
% --- Interactive Plotting Logic (New) ---
figure(h1);
disp('h1 (a*-b*) interactive mode enabled. Use the buttons below.');
uicontrol('Parent', h1, 'Style', 'pushbutton', 'String', 'Select Region', ...
    'Position', [10 10 100 30], 'Callback', {@select_region, h1});
uicontrol('Parent', h1, 'Style', 'pushbutton', 'String', 'Export Outliers', ...
    'Position', [120 10 120 30], 'Callback', {@export_outliers, h1, 'ab', all_plot_data});
figure(h2);
disp('h2 (L*-C*) interactive mode enabled. Use the buttons below.');
uicontrol('Parent', h2, 'Style', 'pushbutton', 'String', 'Select Region', ...
    'Position', [10 10 100 30], 'Callback', {@select_region, h2});
uicontrol('Parent', h2, 'Style', 'pushbutton', 'String', 'Export Outliers', ...
    'Position', [120 10 120 30], 'Callback', {@export_outliers, h2, 'LC', all_plot_data});
% --- End of Interactive Plotting Logic ---
figure(h1);
legend('show','Location','bestoutside');
hold off;
if isscalar(lastPart_types)
    output_folder = fullfile(save_folder,"color_chart_combined",iOr,obs_type,"a_b");
else
    output_folder = fullfile(save_folder,"color_chart_combined",obs_type,"a_b");
end
if ~exist(output_folder, "dir")
    mkdir(output_folder);
end
exportgraphics(h1, fullfile(output_folder, ...
    strcat('all_attributes_a_b.jpg')),"resolution",150);
figure(h2);
legend('show','Location','bestoutside');
hold off;
if isscalar(lastPart_types)
    output_folder = fullfile(save_folder,"color_chart_combined",iOr,obs_type,"L_C");
else
    output_folder = fullfile(save_folder,"color_chart_combined",obs_type,"L_C");
end
if ~exist(output_folder, "dir")
    mkdir(output_folder);
end
exportgraphics(h2, fullfile(output_folder, ...
    strcat('all_attributes_L_C.jpg')),"resolution",150);
% --- New Callback Functions ---
% Callback for the "Select Region" button
function select_region(~, ~, fig_handle)
    figure(fig_handle);
    disp('Draw a rectangle on the plot. Double-click to finish.');
    
    % Clear any existing rectangle
    existing_rect = findobj(fig_handle, 'Type', 'hggroup', 'Tag', 'interactive_rect');
    if ~isempty(existing_rect)
        delete(existing_rect);
    end
    
    % Let the user draw a new rectangle and store it
    h_rect = imrect(gca);
    set(h_rect, 'Tag', 'interactive_rect');
    
    % Store the handle of the rectangle object in the figure's UserData
    fig_handle.UserData.rect_handle = h_rect;
end
% Callback for the "Export Outliers" button
function export_outliers(~, ~, fig_handle, plot_type, all_plot_data)
    % Get the rectangle handle from figure's UserData
    if isfield(fig_handle.UserData, 'rect_handle') && isvalid(fig_handle.UserData.rect_handle)
        h_rect = fig_handle.UserData.rect_handle;
        position = getPosition(h_rect);
        
        % Get the coordinates of the selected rectangle
        x_min = position(1);
        y_min = position(2);
        x_max = position(1) + position(3);
        y_max = position(2) + position(4);
    else
        disp('No region selected. Please click "Select Region" and draw a box first.');
        return;
    end
    
    % Define file path and coordinate names
    output_folder = fullfile("AnalyseResults1", "efit2", "outliers");
    if ~exist(output_folder, "dir")
        mkdir(output_folder);
    end
    
    if strcmp(plot_type, 'ab')
        x_coords = [all_plot_data.a];
        y_coords = [all_plot_data.b];
        filename = fullfile(output_folder, 'outliers_ab_plot.xlsx');
        coord_names = {'a*', 'b*'};
    else % 'LC'
        x_coords = [all_plot_data.C];
        y_coords = [all_plot_data.L];
        filename = fullfile(output_folder, 'outliers_LC_plot.xlsx');
        coord_names = {'C*', 'L*'};
    end
    
    % Find points outside the selected rectangle
    outside_indices = find(x_coords < x_min | x_coords > x_max | y_coords < y_min | y_coords > y_max);
    
    if isempty(outside_indices)
        disp('No points found outside the selected region.');
        return;
    end
    
    % Initialize a table to store the results
    outliers_table = table();
    
    % Loop through the outside points and get their details
    for i = 1:length(outside_indices)
        idx = outside_indices(i);
        point_data = all_plot_data(idx);
        
        % Determine which direction the point is outside
        if x_coords(idx) < x_min
            direction_x = 'Left';
        elseif x_coords(idx) > x_max
            direction_x = 'Right';
        else
            direction_x = 'Within';
        end
        
        if y_coords(idx) < y_min
            direction_y = 'Below';
        elseif y_coords(idx) > y_max
            direction_y = 'Above';
        else
            direction_y = 'Within';
        end
        
        % Concatenate the directions
        direction_out = '';
        if ~strcmp(direction_y, 'Within')
            direction_out = direction_y;
        end
        if ~strcmp(direction_x, 'Within')
            if ~isempty(direction_out)
                direction_out = [direction_out ' and ' direction_x];
            else
                direction_out = direction_x;
            end
        end
        if isempty(direction_out)
            direction_out = 'Within Box'; % Should not happen but as a safeguard
        end
        
        new_row = table(...
            {char(point_data.picname)}, ...
            {char(point_data.attribute)}, ...
            {char(point_data.lastpart)}, ...
            [x_coords(idx), y_coords(idx)], ...
            {direction_out}, ...
            'VariableNames', {'Picname', 'Attribute', 'LastPart', 'Coordinates', 'Out_Direction'});
        
        outliers_table = [outliers_table; new_row];
    end
    
    % 1. Remove rows with NaN values before saving
    nan_rows = any(isnan(table2array(outliers_table(:, {'Coordinates'}))), 2);
    outliers_table(nan_rows, :) = [];
    
    % 2. Create a new table for the rectangle coordinates
    rect_table = table(...
        {'X_min'; 'Y_min'; 'X_max'; 'Y_max'}, ...
        [x_min; y_min; x_max; y_max], ...
        'VariableNames', {'Coordinate', 'Value'});
    
    % Write the tables to different sheets in the same Excel file
    writetable(outliers_table, filename, 'Sheet', 'Outliers');
    writetable(rect_table, filename, 'Sheet', 'Rectangle Coordinates');
    
    disp(['Outliers and rectangle coordinates written to: ' filename]);
end
% The helper functions remain the same
function degree = atan2d_360(y, x)
    degree = atan2d(y, x);
    if degree < 0
        degree = degree + 360;
    end
end
function [lastPart1, model1] = gen_lastPart1(lastPart)
    % A placeholder for your actual gen_lastPart1 logic
    lastPart1 = lastPart;
    model1 = lastPart;
end
function lastPart_new = gen_lastPart_new(lastPart1)
    % A placeholder for your actual gen_lastPart_new logic
    lastPart_new = lastPart1;
end