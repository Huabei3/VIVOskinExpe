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
    target_names=["high","middle","low"];
elseif iOr=='r'
    picnames_groups = ["rs01","rs02","rs03","rs04","rs05","rs06","rs07", ...
             "rs08","rs09","rs10","rs11","rs12","rs13","rs14"];
    picnames_groups1=["1负一楼商场" ,"2负一楼vivo" ,"3下沉广场", "4学校饭堂" ,"5学校小卖部",...
    "6学校星巴克", "7草地顺光" ,"8草地侧光", "9草地逆光", "10阴天场景" ,...
    "11夕阳草地逆光", "12夕阳草地侧光", "13夜景小卖部门口", "14 极夜小卖部对面"];
    target_indices{1}=[1,2,4,5];
    target_indices{2}=[7,8,9,10];
    target_indices{3}=[11,12];
    target_indices{4}=[13,14];
    target_indices{5}=[6];
    target_names=["indoor","outdoor","sunset","night","starbuck"];
end
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
nations = ["AS", "CA", "SA", "AF", "all"]; % Add "all" for the combined data
% 初始化重塑后的数据结构
average_reshaped = cell(5, 1); % 5个人种
labCh_PMCC=[[62.11	18.96	19.76	27.39	46.18];...
            [64.15	19.56	19.63	27.71	45.10];...
            [56.01	18.25	18.72	26.14	45.72];...
            [41.06	17.37	17.94	24.97	45.93]];
labCh_PMCC(end+1,:)=mean(labCh_PMCC,1);
file_missing={};
Dtype = 'efit2';
scale_type="scaled";
load(fullfile("documents",iOr,"render_data2.mat"),"render_map");
Keys = keys(render_map);
picname_check = picnames_groups.';
output_folder=fullfile("AnalyseResults1",Dtype,"50\nation1\XLSX");
if ~exist(output_folder,"dir")
    mkdir(output_folder);
end
%% 循环处理每个 attribute 并生成 Excel 表格
for i_obs = 1:length(obs_types)
    obs_type = obs_types(i_obs);
    
    % 创建 Excel 文件名
    excel_filename = fullfile(output_folder, strcat('nation1', obs_type, '_', iOr, '.xlsx'));
    
    for attribute = 1:length(attributes)
        attribute_name = attribute_names_new(attribute);
        attribute_serial = strcat(sprintf("%02d", attribute), attribute_name);

        % 初始化一个 cell 数组来存储当前 attribute 的所有数据
        all_data = {};
        row_idx = 1;

        for i_indice = 1:length(target_indices)
            % 获取当前 lighting condition 的名字
            indice_name = target_names(i_indice);
            
            % 为每个 nation 处理数据
            for i_nation = 1:length(nations)
                nation = nations(i_nation);
                nation_serial = strcat(num2str(i_nation), nation);

                % 定义源文件路径
                if attribute==7
                    obs_type_used="model_group";
                else
                    obs_type_used=obs_type;
                end
                fitRes_file = fullfile("AnalyseResults1",Dtype,"50\nation1", ...
                    scale_type,obs_type_used,iOr,attribute_serial, ...
                    nation_serial,strcat(num2str(i_indice),".mat"));

                % 检查文件是否存在
                if exist(fitRes_file, 'file')
                    load(fitRes_file, "average_indices_curr", "par");
                    
                    % 提取 labCh 数据
                    lab = [average_indices_curr, par(1,4:5)];
                    L = lab(:,1);
                    a = lab(:,2);
                    b = lab(:,3);
                    
                    labCh = [L, a, b, sqrt(a.^2 + b.^2), atan2d(b, a)];
                    
                    % 计算 E 和 CCT 的平均值
                    E_vals = [];
                    CCT_vals = [];
                    
                    curr_nation_indices = nation_indices{i_nation};
                    n_subjects = length(curr_nation_indices);
                    
                    for i_subject = 1:n_subjects
                        subject_idx = curr_nation_indices(i_subject);
                        lastPart = lastParts{subject_idx};
                        for i_para=target_indices{i_indice}
                             picname = strcat(lastPart,picname_check{i_para, 1});
                             
                             if isKey(render_map, picname)
                                curr_struct = render_map(picname);
                                E_vals = [E_vals; curr_struct.E_val];
                                CCT_vals = [CCT_vals; curr_struct.CCT_val];
                             else
                                file_missing{end+1} = picname;
                             end
                        end
                    end
                    
                    avg_E = nanmean(E_vals);
                    avg_CCT = nanmean(CCT_vals);
                    
                    % 整理数据并添加到 cell 数组中
                    for i_lab = 1:size(labCh,1)
                        all_data{row_idx, 1} = indice_name;
                        all_data{row_idx, 2} = nation;
                        all_data{row_idx, 3} = labCh(i_lab, 1); % L
                        all_data{row_idx, 4} = labCh(i_lab, 2); % a
                        all_data{row_idx, 5} = labCh(i_lab, 3); % b
                        all_data{row_idx, 6} = labCh(i_lab, 4); % C
                        all_data{row_idx, 7} = labCh(i_lab, 5); % h
                        all_data{row_idx, 8} = avg_E;
                        all_data{row_idx, 9} = avg_CCT;
                        row_idx = row_idx + 1;
                    end
                else
                    fprintf('文件不存在: %s\n', fitRes_file);
                    % 如果文件不存在，仍然记录一行数据，但值为 NaN
                    all_data{row_idx, 1} = indice_name;
                    all_data{row_idx, 2} = nation;
                    all_data{row_idx, 3} = NaN; % L
                    all_data{row_idx, 4} = NaN; % a
                    all_data{row_idx, 5} = NaN; % b
                    all_data{row_idx, 6} = NaN; % C
                    all_data{row_idx, 7} = NaN; % h
                    all_data{row_idx, 8} = NaN; % E
                    all_data{row_idx, 9} = NaN; % CCT
                    row_idx = row_idx + 1;
                end
            end
        end

        % 将 cell 数组转换为 table
        T = cell2table(all_data, 'VariableNames', {'Indice', 'Nation', 'L', 'a', 'b', 'C', 'h', 'Avg_E', 'Avg_CCT'});
        
        % 将 table 写入 Excel 文件的一个新 sheet
        % sheet name should be short and descriptive, using attribute_name
        sheet_name = attribute_name;
        writetable(T, excel_filename, 'Sheet', sheet_name);
        
        fprintf('Attribute "%s" 的数据已写入文件 %s 的 sheet "%s" 中。\n', attribute_name, excel_filename, sheet_name);
    end
end