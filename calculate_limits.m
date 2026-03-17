function [lim_min, lim_max] = calculate_limits(source_file1, source_file2, source_file3,lim_min, lim_max)
    % 计算所有图的公共 lim_min 和 lim_max
    %
    % 输入参数：
    %   source_file1: 第一个数据文件的路径
    %   source_file2: 第二个数据文件的路径
    %   source_file3: 第三个数据文件的路径
    %
    % 输出参数：
    %   lim_min: 所有图中 data2 和 data3 的最小值
    %   lim_max: 所有图中 data2 和 data3 的最大值



    % 加载数据
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

    % 循环处理每个 i_para
    for i_para = 1:21
        if exist('par_all1', 'var')
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

        if exist('par_all2', 'var')
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

        if exist('par_all3', 'var') && (~all(par([1:3, 6]) == 0))
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
    end
end