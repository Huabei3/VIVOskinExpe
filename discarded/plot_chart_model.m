close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量
addpath("utils\")
%%
%-------------i-----------------
nations=["AS","CA","SA","AF"];
% lastParts = {'f04i', 'f05i', 'f06i', 'm04i', 'm05i', 'm06i',...
% 'f01i', 'f02i', 'f03i', 'm01i', 'm02i', 'm03i',...
% 'f07i', 'f08i','m07i', 'm08i',...
% 'f09i', 'f10i','m09i', 'm10i'};n_para = 21;iOr='i';
%-------------rs----------------
lastParts = {'f04r', 'f05r', 'f06r', 'm04r', 'm05r', 'm06r',...
'f01r', 'f02r', 'f03r', 'm01r', 'm02r', 'm03r',...
'f07r', 'f08r','m07r', 'm08r',...
'f09r', 'f10r','m09r', 'm10r'};n_para = 14;iOr='r';
iOr=lastParts{1}(end);
Dtype = 'efit2';
attributes=[1]; % Only process attribute 1
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
load(fullfile("documents",iOr,"render_data.mat"),"render_map");
Keys = keys(render_map);
datai_file = 'D:\work\VIVOskinExpe\renderCode\calibResults\datai_ipv18_3.mat';
LUT=load(datai_file);
XYZw_LUT=LUT.XYZw;
scale_type="scaled";
hmls=["H","M","L"];
% Define a color map for each lastPart
colorMap = containers.Map();
num_attributes = length(lastParts);
hue_values = linspace(0, 1, num_attributes + 1);
hue_values = hue_values(1:end-1); 
hsv_matrix = [hue_values', 0.8 * ones(num_attributes, 1), 0.8 * ones(num_attributes, 1)];
colors = hsv2rgb(hsv_matrix);
for k = 1:length(lastParts)
    colorMap(lastParts{k}) = colors(k,:);
end
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

    % Loop through each scene (i_para) first
    for i_para = 1:length(picnames_groups)
        % For the "r" case, use the descriptive names

        scene_name = picnames_groups{i_para};

        % Create new figures for each scene to plot all lastParts on
        h1=figure();hold on;
        h2=figure();hold on;
        
        % 遍历每个 lastPart
        for lastPartIdx = 1:length(lastParts)
            lastPart = lastParts{lastPartIdx};
            if strcmp(lastPart(end),"i")||contains(lastPart,"add")
                n_para=21;
            elseif strcmp(lastPart(end),"r")
                n_para=14;
            end
            white_file = fullfile("optimizedD\card_0830",...
                strcat(lastPart, ".mat"));
            % white_file = fullfile("optimizedD\whiteSquare\XYZw_white", ...
            % strcat(lastPart, ".mat"));
            load(white_file,"XYZw_white");
            
            source_file = fullfile('AnalyseResults1', Dtype, lastPart, obs_type, ...
                strcat(sprintf("%02d", attributes(1)), attribute_names_new(attributes(1))), 'ellipPara', 'fitRes.mat');
            par_all=[];
            if exist(source_file, 'file') 
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
            for i_para_idx=1:length(picname_check)
                curr_cell=render_map(picname_check{i_para_idx, 1});
                CT(i_para_idx,1) =curr_cell{1,8};
                XYZwpre(i_para_idx,:)=curr_cell{1,9};

                D_pre(i_para_idx,1)= calculateD(CT(i_para_idx,1), 0, "efit2");
                XYZt(i_para_idx,:) = CAT16_D(XYZ_bf(i_para_idx,:), ...
                    XYZwpre(i_para_idx,:), wd65, D_pre(i_para_idx,1));                
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
                for i_para_idx=1:length(picname_check)
                    xyz_fit(i_para_idx,:)=lab2xyz2(labCh(i_para_idx,1:3),"user",wd65./wd65(2).*XYZw_LUT(2));
                    lab_scaled(i_para_idx,1:3)=xyz2lab(xyz_fit(i_para_idx,:),"user",wd65./wd65(2).*XYZw_white(i_para_idx,2));
                end
            else
                lab_scaled=labCh;
            end
            if i_para==13
            % if i_para==13 && ismember(lastPartIdx,[7:9])
                disp("d")
            end
            lab_scaled(:,4)=sqrt(lab_scaled(:,2).^2+lab_scaled(:,3).^2)';
            lab_scaled(:,5)=atan2d(lab_scaled(:,3),lab_scaled(:,2));
            
            % Get the color for the current lastPart
            if isKey(colorMap, lastPart)
                text_color = colorMap(lastPart);
            else
                text_color = [0, 0, 0]; % Default to black if not found
            end

            % Generate a shortened text label, e.g., 'f01i' -> 'f1'
            short_lastPart = [lastPart(1), lastPart(end-2:end-1)];
            
            % Plot on the shared figures
            figure(h1);
            text(lab_scaled(i_para,2),lab_scaled(i_para,3), short_lastPart, ...
                 'Color', text_color, 'HorizontalAlignment', 'center', 'FontSize', 8);
            
            figure(h2);
            text(lab_scaled(i_para,4),lab_scaled(i_para,1), short_lastPart, ...
                 'Color', text_color, 'HorizontalAlignment', 'center', 'FontSize', 8);
        end % End of lastPart loop
        
        % Set common properties and save figures for the current scene
        save_folder_base = fullfile(save_folder, "chart_by_scene", iOr, obs_type);

        figure(h1);
        title([attribute_names_new(1), ' a-b for ', scene_name]);
        if ~isempty(findall(h1, 'Type', 'ColorBar'))
            colorbar('off');
        end
        grid on;
        if iOr=="i"
            max_lim=25;
        else
            max_lim=40;
        end
        min_lim=0;
        axis equal;
        xticks(min_lim:5:max_lim)
        yticks(min_lim:5:max_lim)
        xlim([min_lim,max_lim])
        ylim([min_lim,max_lim])
        output_folder_ab = fullfile(save_folder_base, "a_b");
        if ~exist(output_folder_ab, "dir")
            mkdir(output_folder_ab);
        end
        exportgraphics(h1, fullfile(output_folder_ab, ...
            strcat(scene_name,"_a_b.jpg")),"resolution",150);
        close(h1);
        
        figure(h2);
        title([attribute_names_new(1), ' L-C for ', scene_name]);
        if ~isempty(findall(h2, 'Type', 'ColorBar'))
            colorbar('off');
        end
        grid on;
        axis equal;
        if iOr=="i"
            max_lim=80;
            min_lim=25;
        else
            max_lim=90;
            min_lim=15;
        end
        xticks(0:5:40)
        yticks(min_lim:5:max_lim)
        xlim([0,40])
        ylim([min_lim,max_lim])
        
        output_folder_lc = fullfile(save_folder_base, "L_C");
        if ~exist(output_folder_lc, "dir")
            mkdir(output_folder_lc);
        end
        exportgraphics(h2, fullfile(output_folder_lc, ...
            strcat(scene_name,"_L_C.jpg")),"resolution",150);
        close(h2);
    end % End of i_para loop

    % Run concatenation once after all plots are generated
    concatenate_images_chart(fullfile(save_folder, "chart_by_scene", iOr, obs_type, "a_b"),7);
    concatenate_images_chart(fullfile(save_folder, "chart_by_scene", iOr, obs_type, "L_C"),7);
end
function degree = atan2d_360(y, x)
    degree = atan2d(y, x);
    if degree < 0
        degree = degree + 360;
    end
end
function angle = convertAngleTo90Interval(angle)
    % 将角度转换到 [-180, 180] 区间内
    angle = mod(angle, 360);
    if angle > 180
        angle = angle - 360;
    end
    
    % 将角度转换到 [-90, 90] 区间内
    if angle > 90
        angle = angle - 180;
    elseif angle < -90
        angle = angle + 180;
    end
end