close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量

%%
lastParts = {'female78i', 'female41i', 'femalevivoi', ...
    'male59i', 'male39i', 'malevivoi'};
Dtype = 'summer';
attribute_names = ["Preference", "Attractiveness", "Feminine", "Cooperative", ...
    "Youth", "Healthy", "Precise reproduction", "suit the environment or not", "white-skinned", "ruddy"];

% 定义保存的汇总 Excel 文件名
summary_filename = fullfile("AlalyseResults", Dtype, ...
    'List_allMod1.xlsx');

% 如果汇总文件已存在，删除它以确保新数据写入
if exist(summary_filename, 'file')
    delete(summary_filename);
end

% 遍历每个 lastPart
for lastPartIdx = 1:length(lastParts)
    lastPart = lastParts{lastPartIdx};
    
    % 定义保存的 Excel 文件名
    output_filename = fullfile("AlalyseResults", Dtype, lastPart, 'ellip_list_all.xlsx');
    output_filename_no_theta = fullfile("AlalyseResults", Dtype, lastPart, 'ellip_list_all_no_theta.xlsx'); % 不包含 theta 的文件
    
    % 如果文件已存在，删除它们以确保新数据写入
    if exist(output_filename, 'file')
        delete(output_filename);
    end
    if exist(output_filename_no_theta, 'file')
        delete(output_filename_no_theta);
    end
    
    % 初始化汇总数据
    concatenated_table = table();
    
    % 遍历所有 attribute
    for attribute = [1, 2, 3, 4, 5, 6,7, 8, 9, 10]
        attribute_serial = strcat(sprintf("%02d", attribute), attribute_names(attribute));
        source_file = fullfile('AlalyseResults', Dtype, lastPart, "all", ...
            attribute_serial, 'ellipPara', 'fitRes_level.mat');
        par_all=[];
        if exist(source_file, 'file') % 新增 source_file4 的加载
            load(source_file);
        else
            par_all(1:21,1:6)=NaN;
            parNr_all(1:21,1:7)=NaN;
        end

        slashes = strfind(source_file, '\');
        
        save_folder = fullfile("AlalyseResults", Dtype, lastPart,"all", attribute_serial, "list");
        if ~exist(save_folder, "dir")
            mkdir(save_folder);
        end
        
        model = lastPart(1:end-1);
        
        [lastPart1, model1] = gen_lastPart1(lastPart);
        lastPart_new = gen_lastPart_new(lastPart1);
        
        average_file = strcat("..\renderCode\aveSkinByHand2\", lastPart_new, "\autoNhand_scaleoverLUT.mat");
        average = load(average_file);
        average = average.average_lab_all(:, 1:3);
        
        n_para = size(par_all, 1);
        list = zeros(n_para, 9); % 分别是 L、a、b、C、h、A、A/B、theta、coefficients
        L = average(:, 1);

        list(:, 1) = L;
        list(:, 2:3) = par_all(:, 4:5);
        list(:, 4) = sqrt(par_all(:, 4).^2 + par_all(:, 5).^2);
        list(:, 5) = atan2d_360(par_all(:, 5), par_all(:, 4));

        y_target=0.5;
        denominator=(log((1/y_target-1)./par_all(:,6)).^2);
        lambda00 = par_all(:, 1)./denominator;
        lambda01 = par_all(:, 3)./denominator / 2;
        lambda10 = par_all(:, 3) ./denominator/ 2;
        lambda11 = par_all(:, 2)./denominator;
        theta = 0.5 * atan2d_360(2 * lambda01, (lambda00 - lambda11));

        
        A = lambda00 .* cosd(theta).^2 - lambda01 .* sind(2 * theta) + lambda11 .* sind(theta).^2;
        B = lambda00 .* sind(theta).^2 + lambda01 .* sind(2 * theta) + lambda11 .* cosd(theta).^2;
        aabb(:, 1) = sqrt(1 ./ A);
        aabb(:, 2) = sqrt(1 ./ B);

        for i_para=1:size(aabb,1)
            if aabb(i_para, 1) < aabb(i_para, 2)
                temp = aabb(i_para, 1);
                aabb(i_para, 1) = aabb(i_para, 2);
                aabb(i_para, 2) = temp;
                % 调整 theta
                theta(i_para,:) = theta(i_para,:) + 90;
                theta(i_para,:)=convertAngleTo90Interval(theta(i_para,:));
            end
        end
        
        
        list(:, 6) = aabb(:, 1);
        list(:, 7) = aabb(:, 1) ./ aabb(:, 2);
        list(:, 8) = theta;        
        list(:, 9) = parNr_all(:, end);
        
        % 创建一个 cell 数组来存储 picname_group
        picname_group = cell(n_para, 1);
        for i_para = 1:n_para
            picname_group{i_para} = picname_check{i_para, 1};
        end
        
        % 将 list 转换为 table
        list_table = array2table(list, 'VariableNames', ...
            {'L', 'a', 'b', 'C', 'h', 'A', 'A_over_B', 'theta', 'coefficients'});
        
        % 将 picname_group 添加到 table 中
        list_table.picname_group = picname_group;
        
        % 添加一列 attribute
        list_table.attribute = repmat(attribute_names(attribute), height(list_table), 1);
        
        % 保留两位小数
        for col = 1:width(list_table)
            if isnumeric(list_table{:, col})
                list_table{:, col} = round(list_table{:, col}, 2);
            end
        end
        
        % 保存包含 theta 的文件
        writetable(list_table, output_filename, 'Sheet', attribute_serial);
        
        % 创建不包含 theta 的 table
        list_table_no_theta = list_table;
        list_table_no_theta(:, 'theta') = []; % 删除 theta 列
        
        % 保存不包含 theta 的文件
        writetable(list_table_no_theta, output_filename_no_theta, 'Sheet', attribute_serial);
        
        % 将当前 attribute 的 table 纵向拼接到汇总 table 中
        concatenated_table = [concatenated_table; list_table];
    end
    
    % 将汇总 table 写入汇总 Excel 文件
    writetable(concatenated_table, summary_filename, 'Sheet', lastPart);
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





