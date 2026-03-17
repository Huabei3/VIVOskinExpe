function mean_sheetNames(filename, sheetNames, sheet_name, picname_groups)
    outputFilename = filename;
    allData = [];
    textColumns = [];
    validSheetCount = 0;
    numericColumnIndices = [];
    maxRows = 0; % Variable to store the maximum row count

    % --- First Pass: Find max rows and numeric columns ---
    for i = 1:length(sheetNames)
        currentSheet = sheetNames{i};
        try
            dataTable = readtable(filename, 'Sheet', currentSheet, 'ReadRowNames', false);
            % Update maxRows if the current sheet has more rows
            if height(dataTable) > maxRows
                maxRows = height(dataTable);
            end
            
            % Identify numeric columns on the first pass
            if isempty(numericColumnIndices)
                for colIdx = 1:width(dataTable)
                    if isnumeric(dataTable{:, colIdx})
                        if ~all(isnan(dataTable{:, colIdx}))
                            numericColumnIndices = [numericColumnIndices, colIdx];
                        end
                    end
                end
                
                % Store text columns (from the first sheet)
                textColumnIndices = setdiff(1:width(dataTable), numericColumnIndices);
                if ~isempty(textColumnIndices)
                    textColumns = dataTable(:, textColumnIndices);
                end
            end
        catch
            disp(['Warning: Could not read sheet ''', currentSheet, '''. Skipping.']);
        end
    end

    % Check if any valid numeric columns were found
    if isempty(numericColumnIndices)
        disp('No valid numeric data columns found.');
        return; % Exit the function
    end
    
    % --- Second Pass: Read data and populate allData array ---
    allData = NaN(maxRows, length(numericColumnIndices), length(sheetNames));
    
    for i = 1:length(sheetNames)
        currentSheet = sheetNames{i};
        try
            dataTable = readtable(filename, 'Sheet', currentSheet, 'ReadRowNames', false);
            numericData = table2array(dataTable(:, numericColumnIndices));
            
            % Check if data is not empty and has a size
            if ~isempty(numericData) && ~all(isnan(numericData(:)))
                % Pad with NaNs if the current sheet has fewer rows than the max
                paddedData = NaN(maxRows, size(numericData, 2));
                paddedData(1:size(numericData, 1), :) = numericData;
                
                allData(:, :, i) = paddedData;
                validSheetCount = validSheetCount + 1;
            end
        catch
            disp(['Warning: Could not process sheet ''', currentSheet, '''. Skipping.']);
        end
    end
    
    % --- Calculation and Output ---
    if validSheetCount > 0
        meanValues = squeeze(nanmean(allData, 3));
        
        % Ensure meanValues is a 2D array if there's only one column
        if isvector(meanValues)
            meanValues = meanValues(:); % Reshape to a column vector
        end

        meanTableNumeric = array2table(meanValues, 'VariableNames', dataTable.Properties.VariableNames(numericColumnIndices));
        
        % If textColumns has fewer rows than maxRows, pad it
        if height(textColumns) < maxRows
            nanTable = cell2table(cell(maxRows - height(textColumns), width(textColumns)), 'VariableNames', textColumns.Properties.VariableNames);
            textColumns = [textColumns; nanTable];
        end
        
        if ~isempty(textColumns)
            % Ensure textColumns is aligned with meanTableNumeric
            meanTable = [meanTableNumeric, textColumns];
        else
            meanTable = meanTableNumeric;
        end
        
        % Modify picname_group column
        if ismember('picname_group', meanTable.Properties.VariableNames)
            meanTable.picname_group = repmat(picname_groups', maxRows / length(picname_groups), 1);
        end
        
        % Write to new sheet
        writetable(meanTable, outputFilename, 'Sheet', sheet_name);
        disp(['处理完成，基于 ', num2str(validSheetCount), ' 个有效工作表计算了 ', num2str(length(numericColumnIndices)), ' 个数字列的平均值。']);
    else
        disp('没有找到有效的数字列数据。');
    end
end