
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
Dtype = 'efit_p_free';
if iOr=='i'
    picnames_groups = ["h3k","h4k","h5k","h6k","hd65","h7k","h8k",...
            "m3k","m4k","m5k","m6k","md65","m7k","m8k",...
             "l3k","l4k","l5k","l6k","ld65","l7k","l8k"];
elseif iOr=='r'
    picnames_groups = ["rs01","rs02","rs03","rs04","rs05","rs06","rs07", ...
             "rs08","rs09","rs10","rs11","rs12","rs13","rs14"];
end



save_folder = fullfile("ellip_pic_p_free", Dtype,"p_vs_free_CAT");
% save_folder = fullfile("ellip_pic_p_free", Dtype,"p_vs_MSV");
if ~exist(save_folder, "dir")
    mkdir(save_folder);
end

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
            
            % 合并所有受试者数据
            lab_group = [];
            MSV_group = [];
            for i_subject = 1:n_subjects
                subject_idx = curr_nation_indices(i_subject);
                lastPart = lastParts{subject_idx};

                % labNscore_file = fullfile('AnalyseResults1', Dtype, lastPart, ...
                %     obs_type_used, attribute_serial, 'labNscore', ...
                %     strcat('labNscore_group', lastPart, picnames_groups{i_para}, '.mat'));
                % labNscore_file1 =fullfile("AnalyseResults_p\efit2\unscaled",lastPart, ...
                %     obs_type_used, attribute_serial, 'labNscore', ...
                %     strcat('labNscore_group', lastPart, picnames_groups{i_para}, '.mat'));
                % % 加载数据
                % if exist(labNscore_file, 'file')
                %     load(labNscore_file, "lab_group", "MSV_group", "picname_check");
                % end

                % fitRes_file=fullfile("AnalyseResults_p","efit_p","unscaled",lastPart,obs_type, ...
                %     attribute_serial,"ellipPara","fitRes.mat");
                % fitRes_file1=fullfile("AnalyseResults_p_free","efit_p","unscaled",lastPart,obs_type, ...
                %     attribute_serial,"ellipPara","fitRes.mat");
                % fitRes_file2=fullfile("AnalyseResults_p_free","efit_p_free","unscaled",lastPart,obs_type, ...
                %     attribute_serial,"ellipPara","fitRes.mat");

                fitRes_file1=fullfile("AnalyseResults_p","noCAT","unscaled",lastPart,obs_type, ...
                    attribute_serial,"ellipPara","fitRes.mat");
                fitRes_file2=fullfile("AnalyseResults_p_free","noCAT","unscaled",lastPart,obs_type, ...
                    attribute_serial,"ellipPara","fitRes.mat");


                % ditRes_data=load(fitRes_file);
                ditRes_data1=load(fitRes_file1);
                ditRes_data2=load(fitRes_file2);

                % par_all=ditRes_data.par_all;
                par_all1=ditRes_data1.par_all;
                par_all2=ditRes_data2.par_all;

                for i_para=1:size(par_all1,1)
                    figure(1); hold on;
                    a = par_all1(i_para,:);
                    check_data2 = a(4) + (-30:0.2:30);
                    check_data3 = a(5) + (-30:0.2:30);
                    [data2, data3] = meshgrid(check_data2, check_data3);
                    [row, col] = size(data2);
                    % 
                    % 
                    % y = (1./(1+a(6)*exp(sqrt(a(1)*(data2-a(4)).^2+a(2)*(data3-a(5)).^2+ ...
                    %     a(3)*(data2-a(4)).*(data3-a(5)))))).*((a(1)*(data2-a(4)).^2+ ...
                    %     a(2)*(data3-a(5)).^2+a(3)*(data2-a(4)).*(data3-a(5)))>=0);
                    
                    % % 绘制等高线
                    % s0 = contour(data2, data3, y, [0.5, 1], 'LineWidth', 1, ...
                    %      'Color', 'r');
                    % 
                    % plot(par_all(i_para,4), par_all(i_para,5), 'o', 'MarkerSize', 8, ...
                    %     'MarkerFaceColor', 'r', 'Color', 'r');

                    a = par_all1(i_para,:);
                    y = (1./(1+a(6)*exp(sqrt(a(1)*(data2-a(4)).^2+a(2)*(data3-a(5)).^2+ ...
                        a(3)*(data2-a(4)).*(data3-a(5)))))).*((a(1)*(data2-a(4)).^2+ ...
                        a(2)*(data3-a(5)).^2+a(3)*(data2-a(4)).*(data3-a(5)))>=0);
                    
                    % 绘制等高线
                    s0 = contour(data2, data3, y, [0.5, 1], 'LineWidth', 1, ...
                         'Color', 'b');
                    % 绘制特殊点
                    plot(par_all1(i_para,4), par_all1(i_para,5), 'o', 'MarkerSize', 4, ...
                        'MarkerFaceColor', 'b', 'Color', 'b');


                    a = par_all2(i_para,:);
                    y = (1./(1+a(6)*exp(sqrt(a(1)*(data2-a(4)).^2+a(2)*(data3-a(5)).^2+ ...
                        a(3)*(data2-a(4)).*(data3-a(5)))))).*((a(1)*(data2-a(4)).^2+ ...
                        a(2)*(data3-a(5)).^2+a(3)*(data2-a(4)).*(data3-a(5)))>=0);
                    
                    % 绘制等高线
                    s0 = contour(data2, data3, y, [0.5, 1], 'LineWidth', 1, ...
                         'Color', 'g');
                    % 绘制特殊点
                    plot(par_all2(i_para,4), par_all2(i_para,5), 'o', 'MarkerSize', 4, ...
                        'MarkerFaceColor', 'g', 'Color', 'g');

                    output_folder = fullfile(save_folder,iOr, ...
                        obs_type,attribute_serial,lastPart);
                    if ~exist(output_folder, "dir")
                        mkdir(output_folder);
                    end
                    % xlim([-5,40])
                    % ylim([-5,40])
                    xlim([a(4)-20,a(4)+20])
                    ylim([a(5)-20,a(5)+20])
                    axis equal

                    saveas(1, fullfile(output_folder, ...
                        strcat(picnames_groups(i_para),".jpg")));
                    close(1);  % 关闭当前图形
                end
                concatenate_images1(output_folder,7);
            end
        end
    end

end





