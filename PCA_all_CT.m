close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量
%% Define all attributes to be processed
attributes = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
attribute_names_new = ["Preference", "Attractiveness", "Feminine", "Cooperative", ...
    "Youth", "Healthy", "Fidelity","Harmony", "Fair", "Ruddy"];
% Define lastParts and picname_group for 'i'
lastParts_i = {'f04i', 'f05i', 'f06i', 'm04i', 'm05i', 'm06i',...
'f01i', 'f02i', 'f03i', 'm01i', 'm02i', 'm03i',...
'f07i', 'f08i','m07i', 'm08i',...
'f09i', 'f10i','m09i', 'm10i'};
picname_group_i = ["h3k", "h4k", "h5k", "h6k", "hd65", "h7k", "h8k",...
"m3k", "m4k", "m5k", "m6k", "md65", "m7k", "m8k",...
 "l3k", "l4k", "l5k", "l6k", "ld65", "l7k", "l8k"];
CT=["3000k","4000k","5000k","6000k","6500k","7000k","8000k"];
% Add "all" nation
nations = ["AS","CA","SA","AF", "all"];
nations_new=["Asian","Caucasian","South Asian","African", "All Nations"];
% Define nation indices for 'i'
nation_indices_i = cell(5, 1);
nation_indices_i{1} = 1:6;   % AS
nation_indices_i{2} = 7:12;  % CA
nation_indices_i{3} = 13:16; % SA
nation_indices_i{4} = 17:20; % AF
nation_indices_i{5} = 1:20;  % all
Dtype = 'efit2';
obs_types = ["non_model", "model_group", "model"];
for i_obs = 1:length(obs_types)
    obs_type = obs_types(i_obs);
    
    % Loop for i_CT from 1 to 7
    for i_CT = 1:7
        % Define i_para based on i_CT
        current_i_para_indices = [i_CT, i_CT+7, i_CT+14];
        
        save_folder = fullfile("AnalyseResults1", Dtype, "sum_list");
        
        % Create save folder
        if ~exist(save_folder, "dir")
            mkdir(save_folder);
        end
        
        %% Initialize variables for storing PCA results
        pca_results = cell(length(nations), 1);
        pcn_nations = cell(length(nations), 1); % To store max_attribute for each PC
        
        %% Loop through each nation
        % ONLY PROCESS i_nation = 5 (All Nations)
        % Original line: for i_nation = 1:length(nations)
        for i_nation = 5:5 % Modified to process only i_nation = 5
            % Get current nation indices for 'i'
            current_nation_indices_i = nation_indices_i{i_nation};
            
            % Initialize y for storing 'i' data
            y = cell(length(attributes), 1);
            
            for attribute = attributes
                attribute_serial = strcat(sprintf("%02d", attribute), attribute_names_new(attribute));
                if attribute == 7
                    obs_type_used = "model_group";
                else
                    obs_type_used = obs_type;
                end
                
                y_i = []; % Data for 'i' images
                
                % Load data for 'i' images
                for i_lastPart_i = current_nation_indices_i
                    lastPart = lastParts_i{i_lastPart_i};
                    lastPart = strrep(lastPart, "add", "");              
                    
                    % Loop through the defined i_para indices
                    for p_idx = 1:length(current_i_para_indices)
                        current_pic_index = current_i_para_indices(p_idx);
                        % Ensure the index is valid for picname_group_i
                        if current_pic_index > 0 && current_pic_index <= length(picname_group_i)
                            labNgroup_file = fullfile("AnalyseResults1", Dtype, lastPart, obs_type_used, ...
                                attribute_serial, "labNscore", ...
                                strcat("labNscore_group", lastPart, picname_group_i(current_pic_index), ".mat"));
                            if exist(labNgroup_file, 'file')
                                MSVNlab = load(labNgroup_file);
                                y_temp = MSVNlab.MSV_group;  
                            else
                                y_temp = NaN([33,1]);
                            end
                            y_i = [y_i; y_temp];
                        else
                            % Handle invalid index, e.g., add NaNs for consistency
                            y_i = [y_i; NaN([33,1])];
                        end
                    end
                end
                
                % Assign 'i' results for the current attribute
                y{attribute} = y_i;
            end
            
            % PCA Analysis: using the ten y{attribute} as ten dimensions
            % Construct the 10-dimensional data matrix
            data_matrix = []; pcn = [];
            for attribute = 1:length(attributes)
                if ~isempty(y{attribute})
                    data_matrix = [data_matrix, y{attribute}];
                else
                    % If data for an attribute is empty, fill with NaNs
                    % Ensure size consistency - use the size of the first non-empty attribute
                    if ~isempty(y{find(~cellfun('isempty', y), 1)})
                        data_matrix = [data_matrix, NaN(size(y{find(~cellfun('isempty', y), 1)}))];
                    else
                        data_matrix = [data_matrix, NaN(size(y{1}))]; % Fallback if all are empty initially
                    end
                end
                attribute_serial = strcat(sprintf("%02d", attribute), attribute_names_new(attribute));
                pcn = [pcn; attribute_serial];
            end
            
            % Check data validity
            if ~isempty(data_matrix) && size(data_matrix, 2) == length(attributes)
                
                % Calculate ratio of NaN values per column, remove columns with >1/5 NaNs
                col_nan_ratio = mean(isnan(data_matrix), 1);
                valid_cols = col_nan_ratio <= 1/5;
                valid_data = data_matrix(:, valid_cols);
                
                % Calculate ratio of NaN values per row, remove rows with >1/5 NaNs
                row_nan_ratio = mean(isnan(valid_data), 2);
                valid_rows = row_nan_ratio <= 1/5;
                valid_data = valid_data(valid_rows, :);
                
                % Count and display number of rows and columns still containing NaNs after removal
                nan_rows = sum(any(isnan(valid_data), 2));
                nan_cols = sum(any(isnan(valid_data), 1));
                disp(['Number of rows still containing missing values after removal: ', num2str(nan_rows)]);
                disp(['Number of columns still containing missing values after removal: ', num2str(nan_cols)]);
                
                % Interpolate remaining missing values
                valid_data = fillmissing(valid_data, 'nearest');
                pcn_valid = pcn(valid_cols, :); % Store valid PC names
                
                % Only perform PCA if there's enough valid data
                if size(valid_data, 1) > size(valid_data, 2) && size(valid_data, 2) > 1 % Need more observations than variables, and more than 1 variable
                    % Perform PCA
                    [coeff, score, latent, ~, explained] = pca(valid_data);
                    % Store PCA results
                    pca_results{i_nation} = struct(...
                        'coeff', coeff, ...
                        'score', score, ...
                        'latent', latent, ...
                        'explained', explained, ...
                        'data', valid_data, ...
                        'pcn_valid', pcn_valid); 
                    
                    % New field: record attribute_serial with the largest proportion of principal components
                    [~, maxPC_idx] = max(abs(coeff), [], 1); 
                    max_attribute = pcn_valid(maxPC_idx); 
                    pcn_nations{i_nation}=pcn_valid(maxPC_idx); 
                    
                    % Add a new column to pca_results to save the attribute_serial of the largest principal component
                    pca_results{i_nation}.max_attribute = max_attribute;
                    
                    % PCA result visualization
                    figure('Position', [100, 100, 1200, 500]);
                    % Scatter plot of the first and second principal components
                    subplot(1, 2, 1);
                    scatter(score(:,1), score(:,2), 30, 'filled');
                    title(sprintf('PCA Results: %s (i data for i_CT=%d)', nations_new(i_nation), i_CT));
                    xlabel(['Principal Component 1 (', num2str(explained(1), '%.1f'), '%)']);
                    ylabel(['Principal Component 2 (', num2str(explained(2), '%.1f'), '%)']);
                    grid on;
                    
                    % Explained variance ratio plot
                    subplot(1, 2, 2);
                    bar(1:length(explained), explained);
                    title('Explained Variance Ratio of Each Principal Component');
                    xlabel('Principal Component');
                    ylabel('Explained Variance Ratio (%)');
                    xticks(1:length(explained));
                    grid on;
                    
                    % Save PCA result image
                    pca_img_folder = fullfile(save_folder, 'PCA_images', obs_type);
                    if ~exist(pca_img_folder, 'dir')
                        mkdir(pca_img_folder);
                    end
                    saveas(gcf, fullfile(pca_img_folder, sprintf('PCA_%s_i_CT_%d.jpg', nations(i_nation), i_CT)));
                    close(gcf);
                else
                    fprintf('Skipping PCA for %s (i data for i_CT=%d) due to insufficient valid data.\n', nations_new(i_nation), i_CT);
                end
            else
                fprintf('Skipping PCA for %s (i data for i_CT=%d) due to empty or incomplete data matrix.\n', nations_new(i_nation), i_CT);
            end
        end
        
        %% Save PCA results
        pca_save_folder = fullfile(save_folder, 'PCA_results', obs_type);
        if ~exist(pca_save_folder, 'dir')
            mkdir(pca_save_folder);
        end
        
        % Save all PCA results to a mat file for this i_CT
        save(fullfile(pca_save_folder, sprintf('all_pca_results_i_CT_%d.mat', i_CT)), 'pca_results');
        
        % Create PCA results summary table
        max_pcs = 0;
        % Only loop for i_nation = 5
        for i_nation_sum = 5:5 % Modified to process only i_nation = 5
            if ~isempty(pca_results{i_nation_sum})
                max_pcs = max(max_pcs, length(pca_results{i_nation_sum}.explained));
            end
        end
        if max_pcs > 0 % Only proceed if there was valid PCA data for nation 5
            % Initialize pca_summary table
            % The size of the cell array might need to be adjusted if you're only
            % ever storing one row (for nation 5) in the summary.
            % Change from length(nations) + 1 to 2 to accommodate header + 1 data row
            pca_summary_cell = cell(2, 2 * max_pcs + 1); 
            
            % Set table header
            header = {'Nation'};
            for i_pc = 1:max_pcs
                header = [header, {sprintf('PC%d_Explained', i_pc), sprintf('PC%d_Max_Attribute', i_pc)}];
            end
            pca_summary_cell(1, :) = header;
            
            idx = 2;
            % Only loop for i_nation = 5
            for i_nation_sum = 5:5 % Modified to process only i_nation = 5
                if ~isempty(pca_results{i_nation_sum})
                    pca_data = pca_results{i_nation_sum};
                    row = {nations_new(i_nation_sum)};
                    
                    num_pcs_current = length(pca_data.explained);
                    
                    for i_pc = 1:max_pcs
                        if i_pc <= num_pcs_current
                            row = [row, pca_data.explained(i_pc), pca_data.max_attribute{i_pc}];
                        else
                            row = [row, NaN, 'NaN'];
                        end
                    end
                    pca_summary_cell(idx, :) = row;
                    idx = idx + 1;
                end
            end
            
            % Save PCA result summary table to CSV
            writecell(pca_summary_cell, fullfile(pca_save_folder, strcat('i_only_i_CT_', num2str(i_CT), '_', obs_type, '_pca_summary.csv')));
            disp(['Processing complete for i_CT = ', num2str(i_CT)]);
        else
             fprintf('Skipping PCA summary creation for i_CT = %d as no valid PCA data was generated for All Nations.\n', i_CT);
        end
        %% Save max_attribute, explained data, and coeff for each nation to different worksheets
        % Define Excel file names outside the nation loop to append sheets
        pca_summary_xlsx_file = fullfile(pca_save_folder, strcat('i_only_', obs_type, '_pca_summary_by_i_CT.xlsx'));
        coeff_xlsx_file = fullfile(pca_save_folder, strcat('i_only_', obs_type, '_pca_coeff_by_i_CT.xlsx')); 
        
        % Only loop for i_nation = 5
        for i_nation_sheet = 5:5 % Modified to process only i_nation = 5
            if ~isempty(pca_results{i_nation_sheet})
                pca_data = pca_results{i_nation_sheet};
                pcn_valid = pca_data.pcn_valid; 
                explained = pca_data.explained;
                coeff = pca_data.coeff; 
                
                % Create sheet name for the current nation and i_CT
                sheet_name_current = strcat( CT(i_CT));
                
                % Create table containing explained and max_attribute
                pc_names = arrayfun(@(x) sprintf('PC%d', x), 1:length(explained), 'UniformOutput', false);
                max_attribute_table = table(pc_names(:), explained(:), pca_data.max_attribute(:), ...
                                            'VariableNames', {'PrincipalComponent', 'ExplainedVariance', 'MaxLoadingAttribute'});
        
                % Write to the corresponding worksheet
                writetable(max_attribute_table, pca_summary_xlsx_file, 'Sheet', sheet_name_current);
                
                % Save coeff matrix to a separate Excel file, and add max loading attributes and explained variance
                if ~isempty(coeff)
                    % Create column headers for coeff table (PC1, PC2...)
                    pc_headers = arrayfun(@(x) sprintf('PC%d', x), 1:size(coeff, 2), 'UniformOutput', false);
                    
                    % Get indices of attributes with largest absolute loading for each PC
                    [~, max_coeff_row_idx] = max(abs(coeff), [], 1); 
                    
                    % Get corresponding pcn
                    max_loading_pcn = pcn_valid(max_coeff_row_idx);
                    
                    % Convert pcn_valid to cell array for concatenation with coeff
                    coeff_table_data = [cellstr(pcn_valid), num2cell(coeff)];
                    
                    % Create table header: first empty, then PC names
                    coeff_table_headers = [{' '}, pc_headers];
                    
                    % Create a new row for the explained variance - MOVED THIS LINE
                    explained_variance_row = [{'Explained Variance (%)'}, num2cell(explained(:))']; % Transpose explained to a row
                    
                    % Create a new row for the max loading pcn
                    max_pcn_row = [{'Max Loading Attribute'}, cellstr(max_loading_pcn)']; % Transpose to make it a row
                    
                    % Combine header, explained variance row, data, and the max loading row
                    coeff_output_data = [coeff_table_headers; explained_variance_row; coeff_table_data; max_pcn_row];
                    
                    % Write to the corresponding worksheet of the coeff file
                    writecell(coeff_output_data, coeff_xlsx_file, 'Sheet', sheet_name_current);
                end
            end
        end
    end % End of i_CT loop
end % End of obs_types loop