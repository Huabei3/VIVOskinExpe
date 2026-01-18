close all; % 关闭所有图窗
clc;       % 清空命令窗口par_ind
clear;     % 清除工作区所有变量
%%
% 假设已知椭球的参数
Dtype="OPPO_CAT16";
lastParts=["inLab","indoorAdd","nightAdd","outdoorAdd","sunsetAdd","recen"];
outputFolder=fullfile( "AnalyseResults",Dtype,"sum_list");
if ~exist(outputFolder,"dir")
    mkdir(outputFolder);
end
% 定义保存的汇总 Excel 文件名
summary_filename = fullfile(outputFolder,...
    strcat('STRESS_.xlsx'));

% 如果汇总文件已存在，删除它以确保新数据写入
if exist(summary_filename, 'file')
    delete(summary_filename);
end

for i_lastPart=1:length(lastParts)
    lastPart=lastParts(i_lastPart);
    fitRes_folder = fullfile('AnalyseResults',Dtype,lastPart);
    load(fullfile(fitRes_folder, "STRESS", "STRESS.mat"));
    STRESS_list=[STRESS_intra(:,2),STRESS_inter(:,2)];
    left_list=STRESS_intra(:,1);
    STRESS_list=cell2mat(STRESS_list);
    summary_intra{i_lastPart,1}=mean(STRESS_list(:,1));
    summary_intra{i_lastPart,2}=max(STRESS_list(:,1));
    summary_intra{i_lastPart,3}=min(STRESS_list(:,1));
    summary_intra{i_lastPart,4}=std(STRESS_list(:,1));
    summary_inter{i_lastPart,1}=mean(STRESS_list(:,2));
    summary_inter{i_lastPart,2}=max(STRESS_list(:,2));
    summary_inter{i_lastPart,3}=min(STRESS_list(:,2));
    summary_inter{i_lastPart,4}=std(STRESS_list(:,2));
    STRESS_list(end+1,:)=mean(STRESS_list,1);
    STRESS_list=num2cell(STRESS_list);
    left_list{end+1,1}="mean";
    
    STRESS_list=[left_list,STRESS_list];
    list_table = array2table(STRESS_list, 'VariableNames', ...
        {'obs','STRESS_intra', 'STRESS_inter'});
    
    % 保存包含 theta 的文件
    writetable(list_table, summary_filename, 'Sheet', lastPart );    
end
disp("done");
intra_table = cell2table(summary_intra, 'VariableNames', {'mean', 'max', 'min','std'});
writetable(intra_table, summary_filename, 'Sheet', "intra" );
inter_table = cell2table(summary_inter, 'VariableNames', {'mean', 'max', 'min','std'});
writetable(inter_table, summary_filename, 'Sheet', "inter" );

% 将角度转换到 360 度范围内的函数
function degree = atan2d_360(y, x)
    degree = atan2d(y, x);
    if degree < 0
        degree = degree + 360;
    end
end



