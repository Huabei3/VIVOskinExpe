close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量

%% 定义所有需要处理的 attribute
attributes = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
attribute_names = ["Preference", "Attractiveness", "Feminine", "Cooperative", ...
    "Youth", "Healthy", "Precise reproduction", ...
    "suit the environment or not", "white-skinned", "ruddyadd"];
picname_group = ["h3k", "h4k", "h5k", "h6k", "h7k", "h8k", "hd65", ...
    "l3k", "l4k", "l5k", "l6k", "l7k", "l8k", "ld65", ...
    "m3k", "m4k", "m5k", "m6k", "m7k", "m8k", "md65"];

lastParts = {'female78i', 'female41i', 'femalevivoi', 'male59i', 'male39i', 'malevivoi'};
Dtype = 'summer';obs_type="non_model";
save_folder = fullfile("AnalyseResults", Dtype,"corr",obs_type );

% 创建保存文件夹
if ~exist(save_folder, "dir")
    mkdir(save_folder);
end

lab_PMCC = [62.11, 18.96, 19.76];
labC_PMCC = [lab_PMCC, sqrt(lab_PMCC(1, 2)^2 + lab_PMCC(1, 3)^2)];

% 初始化 corr_attr_all 用于存储所有 i_para 的 corr_attr
corr_attr_all = cell(length(picname_group), 2);

% 初始化用于存储所有 lastPart 的 corr_attr_all
all_corr_attr = cell(length(lastParts), length(picname_group));

%% 循环处理每个 lastPart
for lastPart_idx = 1:length(lastParts)
    lastPart = lastParts{lastPart_idx};
    dir_labNgroup=dir(fullfile("AnalyseResults",Dtype,lastPart,obs_type, ...
        "01Preference\labNscore\","labNscore*.mat"));

    % 循环处理每个 i_para（即每个 light）
    for i_para = 1:length(picname_group)
        fprintf('Processing light: %d\n', i_para);
        data2=[];data3=[];
        if contains(dir_labNgroup(i_para).name,picname_group(i_para))
            MSVNlab = load(fullfile(dir_labNgroup(i_para).folder, dir_labNgroup(i_para).name));
            data2=MSVNlab.lab_group(:,2);
            data3=MSVNlab.lab_group(:,3);
            picname_check_temp{i_para,1}=picname_group(i_para);
            picname_check_temp{i_para,2}=dir_labNgroup(i_para).name;
            picname_check{lastPart_idx}=picname_check_temp;
        end
        % 初始化 y 用于存储每个 attribute 的 y 值
        y = cell(length(attributes), 1);

        % 循环处理每个 attribute
        for attribute = attributes
            % 生成 attribute_serial
            attribute_serial = strcat(sprintf("%02d", attribute), attribute_names(attribute));
            if attribute==7
                obs_type_used="model_group";
            else
                obs_type_used=obs_type;
            end
            source_file4 = fullfile('AnalyseResults', Dtype, lastPart, ...
                obs_type_used, attribute_serial, 'ellipPara', 'fitRes_level.mat');

            % 加载 source_file4
            if exist(source_file4, 'file')
                load(source_file4);
                par = par_all(i_para, :);
                % 计算 y 值
                y{attribute} = (1 ./ (1 + par(6) * exp(sqrt(par(1) * (data2 - par(4)).^2 + par(2) * (data3 - par(5)).^2 + ...
                    par(3) * (data2 - par(4)) .* (data3 - par(5)))))) .* ((par(1) * (data2 - par(4)).^2 + ...
                    par(2) * (data3 - par(5)).^2 + par(3) * (data2 - par(4)) .* (data3 - par(5))) >= 0);
            end
        end

        % 计算 corr_attr
        corr_attr = zeros(length(attributes), length(attributes));
        for i_attr = attributes
            for j_attr = attributes
                if isempty(y{i_attr}) || isempty(y{j_attr})
                    corr_attr(i_attr, j_attr) = NaN;
                elseif std(y{i_attr}(:)) == 0 || std(y{j_attr}(:)) == 0
                    corr_attr(i_attr, j_attr) = NaN;
                else
                    corr_attr(i_attr, j_attr) = corr(y{i_attr}(:), y{j_attr}(:));
                end
            end
        end

        % 存储 corr_attr
        corr_attr_all{i_para, 1} = corr_attr;
        corr_attr_all{i_para, 2} = picname_group(i_para);

        % 将当前 lastPart 的 corr_attr 存储到 all_corr_attr
        all_corr_attr{lastPart_idx, i_para} = corr_attr;
    end

    % 将 corr_attr_all 写入 Excel 文件
    if ~exist(fullfile(save_folder, lastPart), "dir")
        mkdir(fullfile(save_folder, lastPart));
    end
    excel_file = fullfile(save_folder, lastPart, 'corr_attr_summary.xlsx');
    for i_para = 1:length(picname_group)
        sheet_name = picname_group{i_para};
        writematrix(corr_attr_all{i_para, 1}, excel_file, 'Sheet', sheet_name);
    end
end

%% 计算不同 lastPart 的 corr_attr_all 的平均值
% 初始化用于存储所有 corr_attr 的三维数组
corr_attr_3d = zeros(length(attributes), length(attributes), length(lastParts), length(picname_group));

% 将每个 lastPart 的 corr_attr 存储到三维数组中
for lastPart_idx = 1:length(lastParts)
    for i_para = 1:length(picname_group)
        corr_attr_3d(:, :, lastPart_idx, i_para) = all_corr_attr{lastPart_idx, i_para};
    end
end

% 对后两个维度取平均，得到 2 维表格
avg_corr_attr = nanmean(nanmean(corr_attr_3d, 4), 3);

% 将平均值写入新的 Excel 文件，并在行首和列首添加 attribute_serial
avg_excel_file = fullfile(save_folder, 'avg_corr_attr_summary.xlsx');
% 将 attribute_names 转换为 cell 类型
attribute_names_cell = cellstr(attribute_names);
% 构建带表头的矩阵
avg_corr_attr_with_header = [["", attribute_names_cell]; [attribute_names_cell', num2cell(avg_corr_attr)]];
% 写入 Excel 文件
writematrix(avg_corr_attr_with_header, avg_excel_file, 'Sheet', 'Average_Corr_Attr');

%% 将每个 lastPart_idx 和 i_para 对应的 corr_attr_3d 写入 Excel 文件
% 创建一个新的 Excel 文件
combined_excel_file = fullfile(save_folder, 'combined_corr_attr_summary.xlsx');

% 初始化一个空的单元格数组用于存储所有数据
combined_data = {};

% 遍历每个 lastPart_idx 和 i_para
for lastPart_idx = 1:length(lastParts)
    for i_para = 1:length(picname_group)
        % 获取当前 lastPart 和 i_para 的 corr_attr
        corr_attr = corr_attr_3d(:, :, lastPart_idx, i_para);

        % 在行首和列首添加 attribute_serial
        corr_attr_with_header = [["", attribute_names]; [attribute_names', num2cell(corr_attr)]];

        % 在前面添加一列 picname_group(i_para)
        corr_attr_with_header = [[lastParts{lastPart_idx}, repmat({''}, 1, length(attribute_names))]; ...
            [picname_group(i_para), repmat({''}, 1, length(attribute_names))]; ...
            corr_attr_with_header];

        % 将当前数据添加到 combined_data
        combined_data = [combined_data; corr_attr_with_header; repmat({''}, 1, size(corr_attr_with_header, 2))];
    end
end

% 将 combined_data 写入 Excel 文件
writematrix(combined_data, combined_excel_file, 'Sheet', 'Combined_Corr_Attr');

disp("Processing complete.");

%%
% 读取 Excel 文件

data = readmatrix(avg_excel_file); % 读取数据部分（10x10 矩阵）

% 找到 <1 的值
less_than_one = data(data < 1);

% 找到最大的前 20% 的值
num_values = numel(less_than_one); % <1 的总数量
top_20_percent = floor(0.2 * num_values); % 前 20% 的数量
[~, sorted_indices] = sort(less_than_one, 'descend'); % 降序排序
top_indices = sorted_indices(1:top_20_percent); % 前 20% 的索引

% 在对应数据后面加上 "high"
modified_data = num2cell(data); % 将矩阵转换为 cell 数组
[row, col] = find(data < 1); % 找到 <1 的值的位置
for i = 1:length(row)
    if ismember(data(row(i), col(i)), less_than_one(top_indices)) % 如果是前 20%
        modified_data{row(i), col(i)} = [num2str(data(row(i), col(i))), ' high']; % 加上 "high"
    else
        modified_data{row(i), col(i)} = num2str(data(row(i), col(i))); % 其他 <1 的值转换为字符串
    end
end

% 将修改后的表格写入新的 Excel 文件
output_filename = fullfile(save_folder,'output.xlsx'); % 输出文件名
writecell(modified_data, output_filename); % 写入 Excel 文件

disp("处理完成，结果已保存到 output.xlsx。");