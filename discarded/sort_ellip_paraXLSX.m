close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量
addpath '..'
%%
lastParts = {'f04i', 'f05i', 'f06i', 'm04i', 'm05i', 'm06i',...
'f01i', 'f02i', 'f03i', 'm01i', 'm02i', 'm03i',...
'f07i', 'f08i','m07i', 'm08i',...
'f09i', 'f10i','m09i', 'm10i'};n_para = 21;iOr='i';


% lastParts = {'f04r', 'f05r', 'f06r', 'm04r', 'm05r', 'm06r',...
% 'f01r', 'f02r', 'f03r', 'm01r', 'm02r', 'm03r',...
% 'f07r', 'f08r','m07r', 'm08r',...
% 'f09r', 'f10r','m09r', 'm10r'};n_para = 14;iOr='r';

Dtype = 'efit_p';
scale_type_origin="unscaled";
load(fullfile("documents",iOr,"render_data2.mat"),"render_map");
Keys = keys(render_map);
attribute_names = ["Preference", "Attractiveness", "Feminine", "Cooperative", ...
    "Youth", "Healthy", "Precise reproduction", "suit the environment or not",...
    "white-skinned", "ruddyadd"];
attribute_names_new = ["Preference", "Attractiveness", "Feminine", "Cooperative", ...
    "Youth", "Healthy", "Fidelity","Harmony", "Fair", "Ruddy"];
% obs_types=["model"];
obs_types=["non_model","model_group"];
% obs_types=["non_model","model_group","model"];
for i_obs=1:length(obs_types)
    obs_type=obs_types(i_obs);
    
    outputFolder=fullfile( "AnalyseResults_p",Dtype,scale_type_origin,"sum_list");
    if ~exist(outputFolder,"dir")
        mkdir(outputFolder);
    end
    % 定义保存的汇总 Excel 文件名
    summary_filename = fullfile(outputFolder,...
        strcat('ellip_para_',obs_type,'_',iOr,'.xlsx'));
    
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
            attribute_serial = strcat(sprintf("%02d", attribute), attribute_names_new(attribute));
            source_file = fullfile('AnalyseResults_p', Dtype,scale_type_origin, lastPart, obs_type, ...
                attribute_serial, 'ellipPara', 'fitRes.mat');
            par_all=[];
            if exist(source_file, 'file') % 新增 source_file4 的加载
                load(source_file);
            else
                par_all(1:n_para,1:6)=NaN;
                parNr_all(1:n_para,1:7)=NaN;
            end
            n_para=size(par_all,1);
            % 创建一个 cell 数组来存储 picname_group
            picname_group = cell(n_para, 1);
            if iOr=='i'
                picnames_groups=["H3K","H4K","H5K","H6K","HD65","H7K","H8K",...
                    "M3K","M4K","M5K","M6K","MD65","M7K","M8K",...
                "L3K","L4K","L5K","L6K","LD65","L7K","L8K"];
            elseif iOr=='r'
                picnames_groups = ["rs01","rs02","rs03","rs04","rs05","rs06","rs07", ...
                             "rs08","rs09","rs10","rs11","rs12","rs13","rs14"];
            end
            for i_para = 1:n_para
                picname_group{i_para} = strcat(gen_lastPart_new(lastPart),picnames_groups(i_para));
            end
            parNr_all(:,6)=-log(parNr_all(:,6));
            % 将 list 转换为 table
            list_table = array2table(parNr_all, 'VariableNames', ...
                {'k1', 'k2', 'k3', 'a', 'b', 'alpha', 'r'});
            
            % 将 picname_group 添加到 table 中
            curr_struct=render_map(strcat(lower(picname_group{i_para})));
            % curr_struct.
            list_table.picname_group = picname_group ;
            
            % 添加一列 attribute
            list_table.attribute = repmat(attribute_names_new(attribute), height(list_table), 1);
    
            % 保存包含 theta 的文件
            writetable(list_table, output_filename, 'Sheet', gen_attribute_new(attribute_serial) );
       
            % 将当前 attribute 的 table 纵向拼接到汇总 table 中
            concatenated_table = [concatenated_table; list_table];
        end
        
        % 将汇总 table 写入汇总 Excel 文件
        writetable(concatenated_table, summary_filename, 'Sheet', gen_lastPart_new(lastPart) );
    end
    mean_list(summary_filename,n_para);
    disp('所有 lastPart 的结果已写入汇总 Excel 文件。');
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





