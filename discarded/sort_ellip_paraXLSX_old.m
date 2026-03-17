close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量
addpath '..'
%%
lastParts = {'female78i', 'female41i', 'femalevivoi', ...
    'male59i', 'male39i', 'malevivoi'};
Dtype = 'summer';
attribute_names = ["Preference", "Attractiveness", "Feminine", "Cooperative", ...
    "Youth", "Healthy", "Precise reproduction", "suit the environment or not",...
    "white-skinned", "ruddyadd"];
attribute_names_new = ["Preference", "Attractiveness", "Feminine", "Cooperative", ...
    "Youth", "Healthy", "Fidelity","Harmony", "Fair", "Ruddy"];

obs_types=["non_model","model_group","model","all"];

obs_type=obs_types(4);


% 定义保存的汇总 Excel 文件名
summary_filename = fullfile("AnalyseResults",Dtype,"sum_list",...
    strcat('ellip_para_',obs_type,'.xlsx'));

% 如果汇总文件已存在，删除它以确保新数据写入
if exist(summary_filename, 'file')
    delete(summary_filename);
end

% 遍历每个 lastPart
for lastPartIdx = 1:length(lastParts)
    lastPart = lastParts{lastPartIdx};
    
    % 定义保存的 Excel 文件名
    output_folder=fullfile("sum_list", Dtype,obs_type,lastPart);
    if ~exist(output_folder,"dir")
        mkdir(output_folder);
    end
    output_filename = fullfile(output_folder, 'ellip_para_all.xlsx');
    % 如果文件已存在，删除它们以确保新数据写入
    if exist(output_filename, 'file')
        delete(output_filename);
    end

    
    % 初始化汇总数据
    concatenated_table = table();
    
    % 遍历所有 attribute
    for attribute = [1, 2, 3, 4, 5, 6,7, 8, 9, 10]
        attribute_serial = strcat(sprintf("%02d", attribute), attribute_names(attribute));
        source_file = fullfile('AnalyseResults', Dtype, lastPart, obs_type, ...
            attribute_serial, 'ellipPara', 'fitRes_level.mat');
        par_all=[];
        if exist(source_file, 'file') % 新增 source_file4 的加载
            load(source_file);
        else
            par_all(1:21,1:6)=NaN;
            parNr_all(1:21,1:7)=NaN;
        end
        n_para=size(par_all,1);
        % 创建一个 cell 数组来存储 picname_group
        picname_group = cell(n_para, 1);
        ct=["H3K","H4K","H5K","H6K","H7K","H8K","HD65",...
        "L3K","L4K","L5K","L6K","L7K","L8K","LD65",...
        "M3K","M4K","M5K","M6K","M7K","M8K","MD65"];
        for i_para = 1:n_para
            picname_group{i_para} = strcat(gen_lastPart_new(lastPart),ct(i_para));
        end
        parNr_all(:,6)=-log(parNr_all(:,6));
        % 将 list 转换为 table
        list_table = array2table(parNr_all, 'VariableNames', ...
            {'k1', 'k2', 'k3', 'a', 'b', 'alpha', 'r'});
        
        % 将 picname_group 添加到 table 中
        list_table.picname_group = picname_group ;
        
        % 添加一列 attribute
        list_table.attribute = repmat(attribute_names_new(attribute), height(list_table), 1);
        idx=[1	2	3	4	7	5	6	15	16	17	18	21	19	20	8	9	10	11	14	12	13];
        for row = 1:height(list_table)
            list_table1(row,:)=list_table(idx(row),:);
        end
        list_table=list_table1;
        % 保留两位小数
        for col = 1:width(list_table)
            if isnumeric(list_table{:, col})
                list_table{:, col} = round(list_table{:, col}, 4);
            end
        end



        % 保存包含 theta 的文件
        writetable(list_table, output_filename, 'Sheet', gen_attribute_new(attribute_serial) );
        

        
        % 将当前 attribute 的 table 纵向拼接到汇总 table 中
        concatenated_table = [concatenated_table; list_table];
    end
    
    % 将汇总 table 写入汇总 Excel 文件
    writetable(concatenated_table, summary_filename, 'Sheet', gen_lastPart_new(lastPart) );
end
mean_list(summary_filename);
disp('所有 lastPart 的结果已写入汇总 Excel 文件。');

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





