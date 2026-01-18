close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量
addpath '..'
%%

Dtype="OPPO_CAT16";
lastParts=["inLab","indoorAdd","nightAdd","outdoorAdd","sunsetAdd","recen"];
outputFolder=fullfile( "AnalyseResults",Dtype,"sum_list");
if ~exist(outputFolder,"dir")
    mkdir(outputFolder);
end
% 定义保存的汇总 Excel 文件名
summary_filename = fullfile(outputFolder,...
    strcat('ellip_para_.xlsx'));

% 如果汇总文件已存在，删除它以确保新数据写入
if exist(summary_filename, 'file')
    delete(summary_filename);
end
% 初始化汇总数据
concatenated_table = table();

for i_lastPart=1:length(lastParts)
    lastPart=lastParts(i_lastPart);
    source_file = fullfile('AnalyseResults',Dtype,lastPart,'ellipPara_scaled', 'fitRes_level.mat');
    par_ind=[];
    if exist(source_file, 'file') % 新增 source_file4 的加载
        load(source_file);
    else
        par_ind(1:21,1:6)=NaN;
        parNr_all(1:21,1:7)=NaN;
    end
    n_para=size(par_ind,1);
    parNr_all=[par_ind,r_ind];
    parNr_all(:,8)=-log(parNr_all(:,8));
    parNr_all(end+1,:)=mean(parNr_all,1);
    picname_check{end+1,1}="mean";
    picname_check=cell2table(picname_check(:,1));
    % 将 list 转换为 table
    list_table = array2table(parNr_all, 'VariableNames', ...
        {'k1', 'k2', 'k3','k4', 'L','a', 'b', 'alpha', 'r'});
    list_table=[picname_check,list_table];
    % 保存包含 theta 的文件
    writetable(list_table, summary_filename, 'Sheet', lastPart );    

    % 将当前 attribute 的 table 纵向拼接到汇总 table 中
    concatenated_table = [concatenated_table; list_table];
end
    


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





