close all; clc; clear;
addpath("utils\")

%% 配置路径与参数
VIVO_table_folder = "D:\work\VIVOskinExpe\analyze\AnalyseResults_p\efit_p\scaled\resTable";
VIVO_table_file = fullfile(VIVO_table_folder, "Peggy_VIVO_table.mat");
data = load(VIVO_table_file);
VIVO_table = data.fit_table;

% 基础定义
nations = ["Asian", "Caucasian", "South Asian", "African"];
attributes = ["Preference", "Attractiveness", "Feminine", "Cooperative", ...
              "Youth", "Healthy", "Fidelity", "Harmony", "Fair", "Ruddy"];
          
% 对应原代码中的模型 ID 顺序
% lastParts = {'f04i', 'f05i', 'f06i', 'm04i', 'm05i', 'm06i',...
%              'f01i', 'f02i', 'f03i', 'm01i', 'm02i', 'm03i',...
%              'f07i', 'f08i','m07i', 'm08i',...
%              'f09i', 'f10i','m09i', 'm10i'};n_para = 21;iOr='i';
lastParts = {'f04r', 'f05r', 'f06r', 'm04r', 'm05r', 'm06r',...
'f01r', 'f02r', 'f03r', 'm01r', 'm02r', 'm03r',...
'f07r', 'f08r','m07r', 'm08r',...
'f09r', 'f10r','m09r', 'm10r'};n_para = 14;iOr='r';

if iOr=='i'
    picnames_groups = ["h3k","h4k","h5k","h6k","hd65","h7k","h8k",...
            "m3k","m4k","m5k","m6k","md65","m7k","m8k",...
             "l3k","l4k","l5k","l6k","ld65","l7k","l8k"];
elseif iOr=='r'
    picnames_groups = ["rs01","rs02","rs03","rs04","rs05","rs06","rs07", ...
             "rs08","rs09","rs10","rs11","rs12","rs13","rs14"];
end

% 场景列表 (根据你的描述应该是 33 个)
scenes = picnames_groups; 

output_folder = fullfile('AnalyseResults_p', 'efit_p', 'scaled', 'sum_list');
if ~exist(output_folder, 'dir'), mkdir(output_folder); end

%% 遍历 Attribute 生成对应的 Excel

% --- 预处理：将场景后缀提取并直接存回 table，方便后续统一操作 ---
all_raw_scenes = string(VIVO_table.scene);
VIVO_table.scene_suffix = arrayfun(@(s) last_part_after_dash(s), all_raw_scenes);
VIVO_table.attribute = string(VIVO_table.attribute);
VIVO_table.model_id = string(VIVO_table.model_id);
VIVO_table.observer_type = string(VIVO_table.observer_type);

for i_attr = 1:length(attributes)
    attr_name = attributes(i_attr);
    summary_filename = fullfile(output_folder, sprintf("lab_and_p_%s_%s.xlsx", attr_name,iOr));
    if exist(summary_filename, 'file'), delete(summary_filename); end
    
    nation_tables = cell(1, length(nations)); % 存储各人种的 table 用于后续平均

    attr_sub_table = VIVO_table(VIVO_table.attribute == attr_name & ...
                                VIVO_table.observer_type == "non_model", :);
    % 1. 处理每个 Model (lastPart) 并写入独立 Sheet
    for i_model = 1:length(lastParts)
        model_id = strrep(lastParts{i_model}, iOr, "");
        model_full_id = lastParts{i_model};
        
        model_sub_table = attr_sub_table(attr_sub_table.model_id == model_id, :);
        
        model_table = table();
        
        for i_scene = 1:length(scenes)
            scene_name = scenes(i_scene);
            
            row = model_sub_table(model_sub_table.scene_suffix == scene_name, :);
            
            if ~isempty(row)
                % 提取 L, a, b (假设在 table 的 lab 字段或拆分的列中，这里根据 VIVO_table 结构调整)
                % 如果你的 table 结构不同，请修改列名
                L = row.lab_values{1}(:,1); 
                a = row.lab_values{1}(:,2); 
                b = row.lab_values{1}(:,3); 
                p = row.opinion_scores{1};
            else
                L = NaN; a = NaN; b = NaN; p = NaN;
            end
            
            % 构造 4 列数据
            temp_tab = table(L, a, b, p);
            temp_tab.Properties.VariableNames = [scene_name+"_L", scene_name+"_a", scene_name+"_b", scene_name+"_p"];
            
            model_table = [model_table, temp_tab];
        end
        
        % 写入 Sheet
        writetable(model_table, summary_filename, 'Sheet', model_full_id);
        fprintf('所已汇总%s\n',model_full_id);
    end
    
    % mean_list(summary_filename,n_para);
end

disp('所有数据已汇总至 Excel。');

%% 辅助函数 (保持你原有的即可)
function name = gen_lastPart_new(lp)
    name = strrep(lp, 'i', '');
end
function out = last_part_after_dash(str)
    parts = split(str, " ");
    out = parts(end); % 取最后一部分
end