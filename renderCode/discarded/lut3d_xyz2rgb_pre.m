function [RGB] = lut3d_xyz2rgb_pre(XYZ, datafile,  GOGModel)

    % 载入必要的数据
    LUTdata = load(datafile);
    P_labs = LUTdata.P_labs;
    XYZw1 = LUTdata.XYZw;
    cubeL = 40;
    [r, g, b] = meshgrid(linspace(0, 255, cubeL));
    rgb_grid = [r(:), g(:), b(:)];

    % 将XYZ转换为Lab空间
    Lab = xyz2lab(XYZ, 'user', XYZw1);

    % 初始化RGB
    RGB = zeros(size(XYZ, 1), 3);

    % 处理所有未缓存的部分
    % 创建一个临时变量来存储parfor循环中的结果
    tempRGB = zeros(size(Lab, 1), 3);

    % 确保并行池已经启动
    CoreNum = feature('numcores');
    if isempty(gcp('nocreate'))
        parpool(CoreNum);
    end

    parfor k = 1:size(Lab, 1)
        lab_value = Lab(k, :);

        % 使用GOG模型预测大致范围
        
        predictedRGB = predictGOG(lab_value, GOGModel);

        % 在预测范围内查找最小色差点
        [bestRGB, minDe] = searchWithinRange(lab_value, P_labs, rgb_grid, predictedRGB, 4);

        % 如果最小色差点在范围边界，则扩大范围继续查找
        range = 4;
        while isBoundaryPoint(bestRGB, predictedRGB, range)
            range = range * 2;
            [bestRGB, minDe] = searchWithinRange(lab_value, P_labs, rgb_grid, predictedRGB, range);
        end

        tempRGB(k, :) = bestRGB;

        % 显示进度
        if mod(k, 10000) == 0
            disp([num2str(k) '/' num2str(size(Lab, 1))]);
            disp(['Current time: ' datestr(now, 'yyyy-mm-dd HH:MM:SS')]);
        end
    end

    % 合并parfor循环的结果到RGB
    RGB = tempRGB;

    % 使用周围的值插值处理 NaN 和 Inf
    RGB = handleNaNAndInf(RGB);

    % 限制RGB值的范围到 [0, 255]
    RGB = min(max(RGB, 0), 255);
end

function hash = simpleHash(arr)
    % 使用一个简单的哈希算法，将数组转换为唯一的字符串表示
    hash = sum(arr .* (1:length(arr))); % 简单的加权和作为哈希
    hash = num2str(hash, '%.5f'); % 转换为字符串
end

function RGB = handleNaNAndInf(RGB)
    % 使用邻近的有效值替代 NaN 和 Inf
    for c = 1:size(RGB, 2)
        % 检查每一列
        invalid_mask = isnan(RGB(:, c)) | isinf(RGB(:, c));
        if any(invalid_mask)
            % 用最近的有效值进行插值
            RGB(:, c) = fillmissing(RGB(:, c), 'nearest');
        end
    end
end

function [bestRGB, minDe] = searchWithinRange(lab_value, P_labs, rgb_grid, predictedRGB, range)
    % 根据预测的RGB值和范围，在该范围内查找最小色差点
    minDe = inf;
    bestRGB = [0, 0, 0];
    
    for i = 1:size(rgb_grid, 1)
        if all(abs(rgb_grid(i, :) - predictedRGB) <= range)
            de = cielabde(lab_value, P_labs(i, :));
            if de < minDe
                minDe = de;
                bestRGB = rgb_grid(i, :);
            end
        end
    end
end

function isBoundary = isBoundaryPoint(point, predictedRGB, range)
    % 判断点是否在预测范围的边界上
    isBoundary = any(abs(point - predictedRGB) == range);
end

function predictedRGB = predictGOG(lab_value, GOGModel)
    % 使用GOG模型预测大致的RGB范围
    % 这里假设GOGModel是一个已经训练好的模型
    predictedRGB = predict(GOGModel, lab_value);
end
