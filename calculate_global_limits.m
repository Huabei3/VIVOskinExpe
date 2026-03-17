function [lim_min, lim_max] = calculate_global_limits(lastParts, attributes, attribute_names)
    % 初始化 lim_min 和 lim_max
    lim_min = inf;
    lim_max = -inf;

    % 遍历每个 lastPart
    for lastPart = lastParts
        lastPart = lastPart{1};
        % 遍历每个 attribute
        for attribute = attributes
            fprintf('Processing lastPart: %s, attribute: %d\n', lastPart, attribute);
            
            % 生成 attribute_serial
            attribute_serial = strcat(sprintf("%02d", attribute), attribute_names(attribute));
            
            % 定义路径
            source_file1 = fullfile('AlalyseResults', lastPart, attribute_serial, 'ellipPara', 'fitRes_level.mat');
            source_file2 = fullfile('AlalyseResults', lastPart, 'model_group', attribute_serial, 'ellipPara', 'fitRes_level.mat');
            source_file3 = fullfile('AlalyseResults', lastPart, 'model', attribute_serial, 'ellipPara', 'fitRes_level.mat');
            source_file4 = fullfile('AlalyseResults', lastPart, 'all', attribute_serial, 'ellipPara', 'fitRes_level.mat'); % 新增 source_file4
            
            % 加载数据
            par_all1 = []; par_all2 = []; par_all3 = []; par_all4 = [];
            if exist(source_file1, 'file')
                load(source_file1);
                par_all1 = par_all;
            end
            if exist(source_file2, 'file')
                load(source_file2);
                par_all2 = par_all;
            end
            if exist(source_file3, 'file')
                load(source_file3);
                par_all3 = par_all;
            end
            if exist(source_file4, 'file') % 新增 source_file4 的加载
                load(source_file4);
                par_all4 = par_all;
            end
            
            % 调用 calculate_limits 函数计算当前 lastPart 和 attribute 的 lim_min 和 lim_max
            [current_lim_min, current_lim_max] = calculate_limits(par_all1, par_all2, par_all3, par_all4);
            
            % 更新全局的 lim_min 和 lim_max
            lim_min = min(lim_min, current_lim_min);
            lim_max = max(lim_max, current_lim_max);
        end
    end
end

function [lim_min, lim_max] = calculate_limits(par_all1, par_all2, par_all3, par_all4)
    % 初始化 lim_min 和 lim_max
    lim_min = inf;
    lim_max = -inf;

    % 循环处理每个 i_para
    for i_para = 1:21
        % 处理 par_all1
        if ~isempty(par_all1)
            par = par_all1(i_para, :);
            check_data2 = par(4) + (-30:0.2:30);
            check_data3 = par(5) + (-30:0.2:30);
            [data2, data3] = meshgrid(check_data2, check_data3);
            y = (1 ./ (1 + par(6) * exp(sqrt(par(1) * (data2 - par(4)).^2 + par(2) * (data3 - par(5)).^2 + ...
                par(3) * (data2 - par(4)) .* (data3 - par(5)))))) .* ((par(1) * (data2 - par(4)).^2 + ...
                par(2) * (data3 - par(5)).^2 + par(3) * (data2 - par(4)) .* (data3 - par(5))) >= 0);
            lim_min = min(lim_min, min(data2(y >= 0.5)));
            lim_max = max(lim_max, max(data2(y >= 0.5)));
            lim_min = min(lim_min, min(data3(y >= 0.5)));
            lim_max = max(lim_max, max(data3(y >= 0.5)));
        end

        % 处理 par_all2
        if ~isempty(par_all2)
            par = par_all2(i_para, :);
            check_data2 = par(4) + (-30:0.2:30);
            check_data3 = par(5) + (-30:0.2:30);
            [data2, data3] = meshgrid(check_data2, check_data3);
            y = (1 ./ (1 + par(6) * exp(sqrt(par(1) * (data2 - par(4)).^2 + par(2) * (data3 - par(5)).^2 + ...
                par(3) * (data2 - par(4)) .* (data3 - par(5)))))) .* ((par(1) * (data2 - par(4)).^2 + ...
                par(2) * (data3 - par(5)).^2 + par(3) * (data2 - par(4)) .* (data3 - par(5))) >= 0);
            lim_min = min(lim_min, min(data2(y >= 0.5)));
            lim_max = max(lim_max, max(data2(y >= 0.5)));
            lim_min = min(lim_min, min(data3(y >= 0.5)));
            lim_max = max(lim_max, max(data3(y >= 0.5)));
        end

        % 处理 par_all3
        if ~isempty(par_all3)
            par = par_all3(i_para, :);
            check_data2 = par(4) + (-30:0.2:30);
            check_data3 = par(5) + (-30:0.2:30);
            [data2, data3] = meshgrid(check_data2, check_data3);
            y = (1 ./ (1 + par(6) * exp(sqrt(par(1) * (data2 - par(4)).^2 + par(2) * (data3 - par(5)).^2 + ...
                par(3) * (data2 - par(4)) .* (data3 - par(5)))))) .* ((par(1) * (data2 - par(4)).^2 + ...
                par(2) * (data3 - par(5)).^2 + par(3) * (data2 - par(4)) .* (data3 - par(5))) >= 0);
            lim_min = min(lim_min, min(data2(y >= 0.5)));
            lim_max = max(lim_max, max(data2(y >= 0.5)));
            lim_min = min(lim_min, min(data3(y >= 0.5)));
            lim_max = max(lim_max, max(data3(y >= 0.5)));
        end

        % 处理 par_all4
        if ~isempty(par_all4)
            par = par_all4(i_para, :);
            check_data2 = par(4) + (-30:0.2:30);
            check_data3 = par(5) + (-30:0.2:30);
            [data2, data3] = meshgrid(check_data2, check_data3);
            y = (1 ./ (1 + par(6) * exp(sqrt(par(1) * (data2 - par(4)).^2 + par(2) * (data3 - par(5)).^2 + ...
                par(3) * (data2 - par(4)) .* (data3 - par(5)))))) .* ((par(1) * (data2 - par(4)).^2 + ...
                par(2) * (data3 - par(5)).^2 + par(3) * (data2 - par(4)) .* (data3 - par(5))) >= 0);
            lim_min = min(lim_min, min(data2(y >= 0.5)));
            lim_max = max(lim_max, max(data2(y >= 0.5)));
            lim_min = min(lim_min, min(data3(y >= 0.5)));
            lim_max = max(lim_max, max(data3(y >= 0.5)));
        end
    end
end