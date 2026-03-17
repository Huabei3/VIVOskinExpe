close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量
addpath("utils\")
%% 定义所有需要处理的 attribute
attributes = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
attribute_names_new = ["Preference", "Attractiveness", "Feminine", "Cooperative", ...
    "Youth", "Healthy", "Fidelity", "Harmony", "Fair", "Ruddy"];
nations = ["AS", "CA", "SA", "AF"];
lastParts = {'f04i', 'f05i', 'f06i', 'm04i', 'm05i', 'm06i',...
'f01i', 'f02i', 'f03i', 'm01i', 'm02i', 'm03i',...
'f07i', 'f08i','m07i', 'm08i',...
'f09i', 'f10i','m09i', 'm10i'};n_para = 21;iOr='i';
% lastParts = {'f04r', 'f05r', 'f06r', 'm04r', 'm05r', 'm06r',...
% 'f01r', 'f02r', 'f03r', 'm01r', 'm02r', 'm03r',...
% 'f07r', 'f08r','m07r', 'm08r',...
% 'f09r', 'f10r','m09r', 'm10r'};n_para = 14;iOr='r';
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
%% 直接按重塑后的结构加载和存储数据
for i_obs = 1:length(obs_types)
    obs_type = obs_types(i_obs);
     
    for i_nation = 4:4
    % for i_nation = 1:length(nations)
        % 获取当前人种的所有索引
        nation = nations(i_nation);
        curr_nation_indices = nation_indices{i_nation};
        n_subjects = length(curr_nation_indices);
                            % 循环处理每个 attribute
        for i_gender = 1:2
            gender=genders(i_gender);
            gender_indices = separate_genders(n_subjects, ...
                        curr_nation_indices, lastParts);
            curr_gender_indices = gender_indices{i_gender};
            par_all_inds = NaN(length(curr_gender_indices), 6); % Initialize par_all_inds
            average_cur = NaN(length(curr_gender_indices), 3); % Initialize average_cur

            for attribute = 1:length(attributes)
                attribute_serial = strcat(sprintf("%02d", attribute), attribute_names_new(attribute));
                % 为每个subject加载数据
                
                if i_obs==1&&attribute==7
                    continue
                end
                
                for i_subject = 1:length(curr_gender_indices)                      
                    subject_idx = curr_gender_indices(i_subject);
                    subject_idx1 = curr_nation_indices(curr_gender_indices(i_subject));
                    lastPart = lastParts{subject_idx1};
                    disp(lastPart)
                    iOr = lastPart(end);
                    i_para = 19;
                    average_file = fullfile("aveSkin", lastPart, "autoNhand_scaleoverLUT.mat");
                    if exist(average_file, 'file')
                        average_data = load(average_file);
                        average_cur(i_subject,:) = average_data.average_lab_all(i_para, :);
                    else
                        average_cur(i_subject,:) = NaN(1, 3);
                    end
    
                    source_file = fullfile('AnalyseResults1', Dtype, lastPart, ...
                            obs_type, attribute_serial, 'ellipPara', ...
                            strcat('fitRes.mat'));

                    if exist(source_file, 'file')
                        load(source_file,"par_all");
                        par_all = [par_all; NaN(n_para - size(par_all,1), size(par_all, 2))];
                        par_all_inds(i_subject,:)=par_all(i_para,:);   
                    else
                        warning('File not found: %s. Setting par_all to NaN.', source_file);
                        par_all_inds(i_subject,:) = NaN(1, 6); % Set to NaN if file is missing
                    end
                end
                par=mean(par_all_inds,1,"omitnan");
                ave_curr=mean(average_cur,1,"omitnan");
                nation_serial=strcat(num2str(i_nation),nation);
                fitRes_folder=fullfile("AnalyseResults1",Dtype,"50", ...
                    obs_type,iOr,attribute_serial,nation_serial,genders(i_gender));
                if ~exist(fitRes_folder,"dir")
                    mkdir(fitRes_folder);
                end
                save(fullfile(fitRes_folder,strcat(picnames_groups(i_para),".mat")), ...
                    "par","ave_curr");            
            end
        end
    end
end