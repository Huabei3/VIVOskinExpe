close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量
addpath("utils\")
%% 定义所有需要处理的 attribute
attributes = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

attribute_names_new = ["Preference", "Attractiveness", "Feminine", "Cooperative", ...
    "Youth", "Healthy", "Fidelity", "Harmony", "Fair", "Ruddy"];
nations = ["AS", "CA", "SA", "AF"];

% lastParts = {'f04i', 'f05i', 'f06i', 'm04i', 'm05i', 'm06i',...
% 'f01i', 'f02i', 'f03i', 'm01i', 'm02i', 'm03i',...
% 'f07i', 'f08i','m07i', 'm08i',...
% 'f09i', 'f10i','m09i', 'm10i'};n_para = 21;iOr='i';

lastParts = {'f04r', 'f05r', 'f06r', 'm04r', 'm05r', 'm06r',...
'f01r', 'f02r', 'f03r', 'm01r', 'm02r', 'm03r',...
'f07r', 'f08r','m07r', 'm08r',...
'f09r', 'f10r','m09r', 'm10r'};n_para = 14;iOr='r';


load("documents\valid_attr.mat","map");


wd65 = [94.811, 100.00, 107.304];
datai_file = 'D:\work\VIVOskinExpe\renderCode\calibResults\datai_ipv18_3.mat';
LUT=load(datai_file);
XYZw_LUT=LUT.XYZw;
line_style = {'-',':','-.'};
plot_style = {'^','<','v'};

genders = ["f", "m"]; % 定义性别数组
colors = hsv(length(genders));
obs_types = ["non_model","model_group"];
% obs_types = ["non_model", "model_group", "model"];
% 定义人种对应的lastParts索引
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
% 初始化重塑后的数据结构
average_reshaped = cell(5, 1); % 5个人种
labCh_PMCC=[[62.11	18.96	19.76	27.39	46.18];...
            [64.15	19.56	19.63	27.71	45.10];...
            [56.01	18.25	18.72	26.14	45.72];...
            [41.06	17.37	17.94	24.97	45.93]];
labCh_PMCC(end+1,:)=mean(labCh_PMCC,1);
file_missing={};
Dtype = 'efit2';
if iOr=='i'
    picnames_groups = ["h3k","h4k","h5k","h6k","hd65","h7k","h8k",...
            "m3k","m4k","m5k","m6k","md65","m7k","m8k",...
             "l3k","l4k","l5k","l6k","ld65","l7k","l8k"];
elseif iOr=='r'
    picnames_groups = ["rs01","rs02","rs03","rs04","rs05","rs06","rs07", ...
             "rs08","rs09","rs10","rs11","rs12","rs13","rs14"];
end


%% 直接按重塑后的结构加载和存储数据
for i_obs = 1:length(obs_types)
    obs_type = obs_types(i_obs);
    for i_para = 1:n_para        
        for i_nation = 1:length(nations)
            clear("lab_curr");clear("MSV_curr");
            % 获取当前人种的所有索引
            nation = nations(i_nation);
            curr_nation_indices = nation_indices{i_nation};
            n_subjects = length(curr_nation_indices);
            % 为每个subject加载数据
            for i_subject = 1:n_subjects
                subject_idx = curr_nation_indices(i_subject);
                lastPart = lastParts{subject_idx};
                iOr = lastPart(end);

                average_file = fullfile("aveSkin", lastPart, "autoNhand_scaleoverLUT.mat");
                if exist(average_file, 'file')
                    average_data = load(average_file);
                    average_cur(i_subject,:) = average_data.average_lab_all(i_para, :);
                else
                    average_cur(i_subject,:) = NaN(1, 3);
                end
                % 循环处理每个 attribute
                for attribute = 1:length(attributes)
                    attribute_serial = strcat(sprintf("%02d", attribute), attribute_names_new(attribute));
                    % 定义源文件路径
                    source_file = fullfile('AnalyseResults1', Dtype, lastPart, ...
                        obs_type, attribute_serial, 'labNscore', ...
                        strcat('labNscore_group', lastPart, picnames_groups{i_para}, '.mat'));

                    % 加载数据
                    if exist(source_file, 'file')
                        if attribute==1
                            load(source_file, "lab_group", "MSV_group", "picname_check","lab_bfCAT");
                        else
                            load(source_file,  "MSV_group", "picname_check");
                        end
                    else
                        % 如果文件不存在，填充NaN
                        lab_group = NaN(33, 3);
                        MSV_group = NaN(33, 1);
                        file_missing{end+1,1} = lastPart;
                        file_missing{end,2} = obs_type;
                        file_missing{end,3} = attribute_serial;
                        file_missing{end,4} = picnames_groups{i_para};
                    end
                    if attribute==1
                        lab_curr(:,:,i_subject) = lab_group;
                    end
                    if i_obs==1 && i_nation==2 && i_para==5
                        
                        [CCT,XYZwpre]=find_CCT_combi(strcat(lastPart,picnames_groups(i_para)));
                        disp("d")
                    end
                    MSV_curr(:,i_subject, attribute) = MSV_group;
                end
            end
            lab_reshaped{i_obs, i_nation,i_para} = lab_curr;
            MSV_reshaped{i_obs, i_nation,i_para} = MSV_curr;
            % 存储平均数据（只在第一个观察者类型时存储）
            if i_obs == 1
                average_reshaped{i_nation,i_para} = average_cur;
                for i_gender=1:2
                    gender_indices = separate_genders(n_subjects, ...
                        curr_nation_indices, lastParts);
                    average_nations_cur(i_nation,:)=mean(average_cur(gender_indices{i_gender},:),1);
                    average_nations{i_obs,i_para,i_gender} =average_nations_cur;

                end
            end

        end


    end
    disp("d")
end

%% 保存数据
save_folder = fullfile("ellip_pic", Dtype,"50");
if ~exist(save_folder, "dir")
    mkdir(save_folder);
end
% 保存重塑后的数据
save(fullfile(save_folder,"gender", strcat("data_reshaped_", iOr, ".mat")), ...
     "lab_reshaped", "MSV_reshaped", "average_reshaped");

fprintf('数据已成功保存到 %s\n', fullfile(fullfile(save_folder,"gender"), strcat("data_reshaped_", iOr, ".mat")));
%% 

load(fullfile("ellip_pic",Dtype,"50\gender", ...
    strcat("data_reshaped_", iOr, ".mat")));
% 定义一个函数来分离性别索引
function gender_indices = separate_genders(n_subjects, curr_nation_indices, lastParts)
    gender_indices = cell(2, 1); % f和m的索引
    for i_subject = 1:n_subjects
        subject_idx = curr_nation_indices(i_subject);
        lastPart = lastParts{subject_idx};
        if lastPart(1) == 'f'
            gender_indices{1} = [gender_indices{1}, i_subject];
        elseif lastPart(1) == 'm'
            gender_indices{2} = [gender_indices{2}, i_subject];
        end
    end
end
%%
hue_values = linspace(0, 1, length(nations) + 1);hue_values = hue_values(1:end-1); 
hsv_matrix = [hue_values', 0.8 * ones(length(nations), 1), 0.8 * ones(length(nations), 1)];
colors = hsv2rgb(hsv_matrix);
line_style = {'-',':'};
plot_style = {'v','^'};

% 定义indices_target
if iOr == 'i'
    indices_target = [5, 12, 19];
else
    indices_target = 1:14;
end

% 初始化四维元胞数组来存储所有参数
parNr_all = cell(length(obs_types), length(nations), 2, length(attributes));

for i_obs = 1:length(obs_types)
    obs_type = obs_types(i_obs);

    for attribute = 1:length(attributes)
        attribute_serial = strcat(sprintf("%02d", attribute), ...
            attribute_names_new(attribute));
        figure(attribute); hold on;
        

        for i_nation = 1:length(nations)
            % 获取当前人种的所有索引
            nation = nations(i_nation);
            curr_nation_indices = nation_indices{i_nation};
            n_subjects = length(curr_nation_indices);
            gender_indices = separate_genders(n_subjects, ...
                curr_nation_indices, lastParts);

            % 为每个性别处理数据
            for i_gender = 1:2
                curr_gender_indices = gender_indices{i_gender};
                for i_para = indices_target   
                    lab_group = [];
                    MSV_group = [];
                    if i_obs==1 && i_nation==2 && i_para==5
                        disp("d")
                    end
                    % 收集所有subject的数据
                    for i_subject = 1:length(curr_gender_indices)                      
                        subject_idx = curr_gender_indices(i_subject);
                        lab_curr = lab_reshaped{i_obs, i_nation, i_para};
                        MSV_curr = MSV_reshaped{i_obs, i_nation, i_para};
                        lab_group =[lab_group; ...
                            mean(lab_curr(:,:,subject_idx),3,'omitnan')];
                        MSV_group =[MSV_group;...
                            mean(MSV_curr(:,subject_idx,attribute),2,'omitnan')];
                    end
                    disp("d")
                end
 
                
                if ~all(isnan(MSV_group(:)))
                    [par_mean, r_mean] = ...
                        calculate_weighted_or_simple_mean(MSV_group, lab_group);
                    mean_cen(1) = mean(lab_group(:,1));
                    mean_cen(2:3) = par_mean(1,4:5);
                    
                    % 去掉nan
                    nan_rows = any(isnan(lab_group), 2);
                    lab_group = lab_group(~nan_rows, :);
                    MSV_group = MSV_group(~nan_rows, :);

                    [par, r, y] = my_ellipsoidfit3_dy(lab_group, MSV_group, mean_cen);
                    parNr_all{i_obs, i_nation, i_gender, attribute} = [par, r];

                    Contour50(par, lab_group, MSV_group, "gender", ...
                       average_nations{1,i_para,i_gender}, ...
                       colors(i_nation,:), line_style{i_gender}, ...
                       plot_style{i_gender}, attribute_serial);
                end
                
            end
        end
        
       
        output_folder = fullfile(save_folder,"gender",iOr,obs_type);
        if ~exist(output_folder, "dir")
            mkdir(output_folder);
        end
        saveas(attribute, fullfile(output_folder, ...
            strcat(attribute_serial,".jpg")));
        close(attribute);  % 关闭当前图形
    end
    
    concatenate_images1(output_folder,5);
    save(fullfile(output_folder,"fitRes.mat"),"parNr_all");
end