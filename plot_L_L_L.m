close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量
addpath("utils\")
%%
%-------------i-----------------
nations=["AS","CA","SA","AF"];
% lastParts = {'f04i', 'f05i', 'f06i', ...
% 'm04i', 'm05i', 'm06i'};nation=nations(1);
% lastParts = {'f01i', 'f02i', 'f03i', ...
% 'm01i', 'm02i', 'm03i'};nation=nations(2);
% lastParts = {'f07i', 'f08i', ...
% 'm07i', 'm08i'};nation=nations(3);
% 
% lastParts = {'f04i', 'f05i', 'f06i', 'm04i', 'm05i', 'm06i',...
% 'f01i', 'f02i', 'f03i', 'm01i', 'm02i', 'm03i',...
% 'f07i', 'f08i','m07i', 'm08i',...
% 'f09i', 'f10i','m09i', 'm10i'};n_para = 21;iOr='i';
%-------------rs----------------
lastParts = {'f04r', 'f05r', 'f06r', 'm04r', 'm05r', 'm06r',...
'f01r', 'f02r', 'f03r', 'm01r', 'm02r', 'm03r',...
'f07r', 'f08r','m07r', 'm08r',...
'f09r', 'f10r','m09r', 'm10r'};n_para = 14;iOr='r';
% iOr=lastParts{1}(end);
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
hmls=["H","M","L"];
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
    
    for attribute = attributes
        attribute_serial = strcat(sprintf("%02d", attribute), attribute_names_new(attribute));
        
        % Initialize a table to store data for the current attribute
        attribute_data_table = table();
        
        for i_indice=1:length(target_indices)
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
                
                % Create a cell array to store picname_group
                if iOr=='i'
                    picname_group = cell(n_para, 1);
                    for i_para = 1:n_para
                        if i_para<=size(picname_check,1)
                            picname_group{i_para} = picname_check{i_para, 1};
                        else
                            picname_group{i_para}="";
                        end
                    end
                else
                    picname_group=picnames_groups1';
                end
                
                average(:, 4) = sqrt(average(:, 2).^2 + average(:, 3).^2);
                average(:, 5) = atan2d_360(average(:, 3), average(:, 2));
    
                for i_para=target_indices{i_indice}    
                    % if i_para==13
                    %     continue
                    % end
                    
                    curr_struct=render_map(picname_check{i_para, 1});
                    E =curr_struct.E_val;
                    curr_skin_mea =curr_struct.curr_model_skin;
                    
                    % Create a new row of data
                    new_row = table( ...
                        string(lastPart),...
                        string(picname_group{i_para}), ...
                        {curr_skin_mea(1)}, ...
                        E, ...
                        labCh(i_para,1), ...
                        lab_scaled(i_para,1), ...
                        'VariableNames', {'model','picname', 'measured_skin', 'E', 'labCh', 'lab_scaled'} ...
                    );
                    
                    % Append the new row to the data table
                    attribute_data_table = [attribute_data_table; new_row];
                end
            end
        end
        % Write the complete table for the current attribute to a new sheet
        output_filename = fullfile(outputFolder, ...
                                   strcat('color_chart_data_',iOr,'.xlsx'));
        writetable(attribute_data_table, output_filename, 'Sheet', attribute_serial);
        disp("d")

        % Check if the current attribute is 1, and then plot
        if attribute == 1
            for i_indice = 1:length(target_indices)
                figure; % Create a new figure for each i_indice
                hold on;
                title(sprintf('Data for i_indice %d (Attribute 1)', i_indice));
                xlabel('lastPart');
                ylabel('Value');
                
                % Get unique lastPart values for x-axis
                unique_lastParts = unique(attribute_data_table.model);
                x_positions = 1:length(unique_lastParts);
                
                % Define colors for the data points
                colors = {'r', 'g', 'b', 'm'};
                for i_para=target_indices{i_indice}   
                    % Loop through each lastPart to get the data and plot
                    for i = 1:length(unique_lastParts)
                        model_name = unique_lastParts(i);
                        row_idx = find(strcmp(attribute_data_table.model, model_name));
                        
                        if ~isempty(row_idx)
                            % Extract the relevant values from the table
                            measured_skin_val = attribute_data_table.measured_skin{row_idx};
                            E_all = attribute_data_table.E(row_idx);
                            E_val=E_all(i_para,:);
                            labCh_val = attribute_data_table.labCh(row_idx);
                            labCh_val=labCh_val(i_para,:);
                            lab_scaled_val = attribute_data_table.lab_scaled(row_idx);
                            lab_scaled_val=lab_scaled_val(i_para,:);
                            
                            % Place text labels for each value
                            text(x_positions(i), measured_skin_val, ...
                                picnames_groups1{target_indices{i_indice}(i_para)}, ...
                                'Color', colors{1}, 'VerticalAlignment', 'bottom');
                            text(x_positions(i), E_val, ...
                                picnames_groups1{target_indices{i_indice}(i_para)}, ...
                                'Color', colors{2}, 'VerticalAlignment', 'bottom');
                            text(x_positions(i), labCh_val, ...
                                picnames_groups1{target_indices{i_indice}(i_para)}, ...
                                'Color', colors{3}, 'VerticalAlignment', 'bottom');
                            text(x_positions(i), lab_scaled_val, ...
                                picnames_groups1{target_indices{i_indice}(i_para)}, ...
                                'Color', colors{4}, 'VerticalAlignment', 'bottom');
                        end
                    end
                end
                
                % Set x-axis ticks and labels
                xticks(x_positions);
                xticklabels(unique_lastParts);
                xtickangle(45);
                
                legend('measured_skin', 'E', 'labCh', 'lab_scaled');
                hold off;
            end
        end
    end
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