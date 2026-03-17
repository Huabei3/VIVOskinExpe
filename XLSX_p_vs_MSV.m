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
obs_types = ["non_model"];
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
load(fullfile("documents",iOr,"render_data2.mat"),"render_map");
Keys = keys(render_map);
% 创建一个存放所有结果的单元格数组
all_results = cell(0, 8); % 7列: nation, attribute, lastPart, picture, max, min, mean, std

% Excel文件的保存路径
save_folder="ellip_pic_p\efit_p";
if ~exist(save_folder,"dir")
    mkdir(save_folder);
end
excel_file = fullfile(save_folder,strcat('deltaE2000_results',iOr,'.xlsx'));

for i_obs = 1:length(obs_types)
    obs_type = obs_types(i_obs);
    for attribute = attributes
        attribute_serial = strcat(sprintf("%02d", attribute), ...
            attribute_names_new(attribute));
        
        for i_nation = 1:length(nations)
            % 获取当前人种的所有索引
            nation = nations(i_nation);
            curr_nation_indices = nation_indices{i_nation};
            n_subjects = length(curr_nation_indices);
            
            for i_subject = 1:n_subjects
                subject_idx = curr_nation_indices(i_subject);
                lastPart = lastParts{subject_idx};
                
                % 加载数据
                fitRes_file=fullfile("AnalyseResults1",Dtype,lastPart,obs_type, ...
                    attribute_serial,"ellipPara","fitRes.mat");
                fitRes_file1=fullfile("AnalyseResults_p",Dtype,"unscaled",lastPart,obs_type, ...
                    attribute_serial,"ellipPara","fitRes.mat");
                fitRes_file2=fullfile("AnalyseResults_p","efit_p","unscaled",lastPart,obs_type, ...
                    attribute_serial,"ellipPara","fitRes.mat");
                
                % 检查文件是否存在，如果不存在则跳过
                if ~exist(fitRes_file, 'file') || ~exist(fitRes_file1, 'file') || ~exist(fitRes_file2, 'file')
                    fprintf('Skipping %s, files not found.\n', lastPart);
                    continue;
                end

                ditRes_data=load(fitRes_file);
                ditRes_data1=load(fitRes_file1);
                ditRes_data2=load(fitRes_file2);
                par_all=ditRes_data.par_all;
                par_all1=ditRes_data1.par_all;
                par_all2=ditRes_data2.par_all;
                
                for i_para=1:size(par_all,1)
                    curr_struct=render_map(strcat(lastPart,picnames_groups(i_para)));
                    average =curr_struct.average;

 
                    % 获取L, a, b值
                    lab1 = [average(1),par_all(i_para, 4:5)];
                    lab2 = [average(1),par_all1(i_para, 4:5)];
                    lab3 = [average(1),par_all2(i_para, 4:5)];
                    if strcmp(lastPart,"f02i")
                        disp("d")
                    end    
                    % 忽略nan值
                    if any(isnan(lab1)) || any(isnan(lab2)) || any(isnan(lab3))
                        continue;
                    end
                    
                    % 计算deltaE2000
                    deltaE_1_2 = deltaE2000(lab1, lab2);
                    deltaE_1_3 = deltaE2000(lab1, lab3);
                    deltaE_2_3 = deltaE2000(lab2, lab3);
                    
                    % 创建一个包含所有deltaE值的数组
                    all_deltaE = [deltaE_1_2, deltaE_1_3, deltaE_2_3];
                    
                    % 计算统计数据
                    max_val = max(all_deltaE);
                    min_val = min(all_deltaE);
                    mean_val = nanmean(all_deltaE); % 使用 nanmean 忽略NaN
                    std_val = nanstd(all_deltaE);   % 使用 nanstd 忽略NaN
                    
                    % 写入结果到all_results
                    all_results(end+1, :) = {nation, attribute_names_new(attribute), ...
                        lastPart, picnames_groups(i_para), ...
                        max_val, min_val, mean_val, std_val};
                end
            end
        end
    end
end

% 创建表格
results_table = cell2table(all_results, 'VariableNames', ...
    {'Nation', 'Attribute', 'Subject', 'Picture', 'DeltaE_Max', 'DeltaE_Min', 'DeltaE_Mean', 'DeltaE_Std'});

% 将表格写入Excel文件
writetable(results_table, excel_file);

disp('计算完成，结果已保存到 deltaE2000_results.xlsx');