function mean_sheetNames(filename,sheetNames,sheet_name,picname_groups)
    outputFilename = filename;
    % 初始化存储所有数据的四维数组和非数字列信息
    allData = [];
    textColumns = [];
    validSheetCount = 0;
    numericColumnIndices = [];
    for i = 1:length(sheetNames)
        
        % 读取当前工作表
        currentSheet = sheetNames{i};
        dataTable = readtable(filename, 'Sheet', currentSheet);

        % 动态检测数字列
        if validSheetCount == 0
            % 首次检测数字列位置
            numericColumnIndices = [];
            for colIdx = 1:width(dataTable)
                % 检查列是否包含数值类型且不全为NaN
                if isfloat(dataTable{1, colIdx}) || isnumeric(dataTable{1, colIdx})
                    if ~all(isnan(dataTable{:, colIdx}))
                        numericColumnIndices = [numericColumnIndices, colIdx];
                    end
                end
            end

            % 保存非数字列（仅从第一个有效工作表）
            textColumnIndices = setdiff(1:width(dataTable), numericColumnIndices);
            if ~isempty(textColumnIndices)
                textColumns = dataTable(:, textColumnIndices);
            end
        end

        % 提取数字列数据
        if ~isempty(numericColumnIndices)
            numericData = table2array(dataTable(:, numericColumnIndices));

            % 检查数据是否为空或全为NaN
            if ~isempty(numericData) && ~all(isnan(numericData(:)))
                % 初始化四维数组
                if isempty(allData)
                    allData = NaN(height(dataTable), length(numericColumnIndices), length(sheetNames));
                end

                % 将数据存入四维数组
                numericData=[numericData;...
                        nan(size(allData,1)-size(numericData,1),size(numericData,2))];
                % nanPadding = NaN(size(numericData,1)-size(allData,1), size(allData, 2), size(allData, 3));
                % allData = cat(1, allData, nanPadding);
                allData(:, :, i) = numericData;
                

                % 增加有效工作表计数器
                validSheetCount = validSheetCount + 1;
            end
        end
    end

    % 计算平均值（忽略NaN）
    if validSheetCount > 0 && ~isempty(numericColumnIndices)
        % 对第三维度计算nanmean
        meanValues = squeeze(nanmean(allData, 3));

        % 创建结果表格的数字部分
        meanTableNumeric = array2table(meanValues, 'VariableNames', dataTable.Properties.VariableNames(numericColumnIndices));

        % 合并数字列和非数字列
        if ~isempty(textColumns)
            meanTable = [meanTableNumeric, textColumns];
        else
            meanTable = meanTableNumeric;
        end

        % 修改 picname_group 列为指定的值（如果存在）
        if isfield(table2struct(meanTable), 'picname_group')
            meanTable.picname_group = repmat(picname_groups', height(meanTable) / length(picname_groups), 1);
        end

        % 写入新的工作表
        writetable(meanTable, outputFilename, 'Sheet', sheet_name);

        disp(['处理完成，基于 ', num2str(validSheetCount), ' 个有效工作表计算了 ', num2str(length(numericColumnIndices)), ' 个数字列的平均值。']);
    else
        disp('没有找到有效的数字列数据。');
    end
end