function process_data_CAT2(dir_res, output_folder, lastPart,Dtype)
%和process_data_CAT1的区别是
    % 处理数据并保存
    resfile = fullfile(dir_res(1).folder, dir_res(1).name);
    result = readtable(resfile);
    result_cell = table2cell(result);
    indices = result_cell(:, 1);
    indices = cell2mat(indices);
    n_lab = max(indices) + 1;
    n_file = length(dir_res);

    score_all = zeros(n_lab, n_file);
    num_lab_all = zeros(n_lab, n_file);
    STRESS_intra = [];
    repeat_score_all = [];

    for i_file = 1:length(dir_res)
        resfile = fullfile(dir_res(i_file).folder, dir_res(i_file).name);
        result = readtable(resfile);
        result_cell = table2cell(result);
        rowsWithNaN = any(isnan(cell2mat(result_cell(:,1))), 2);
        result_cell(rowsWithNaN, :) = [];
        scores = cell2mat(result_cell(:, 3));
        scores = mapMatrixValues01(scores);
        for k = 1:length(scores)
            result_cell{k, 3} = scores(k);
        end
        result_cell = sortrows(result_cell, 1);
        repeat_score = [];
        picname_lab = [];
        score_lab = zeros(max(cell2mat(result_cell(:, 1))) + 1, 1);
        num_lab = zeros(max(cell2mat(result_cell(:, 1))) + 1, 1);
        for i_lab = 0:max(cell2mat(result_cell(:, 1)))
            num_scores = find(cell2mat(result_cell(:, 1)) == i_lab);
            score_lab(i_lab + 1) = mean(cell2mat(result_cell(num_scores, 3)));
            if isempty(num_scores)
                disp("1");
            end
            picname_lab = [picname_lab; result_cell(num_scores(1), 2)];
            num_lab(i_lab + 1) = length(num_scores);
            if num_lab(i_lab + 1) > 1
                repeat_score_temp = [i_lab, cell2mat(result_cell(num_scores(1), 3)), cell2mat(result_cell(num_scores(2), 3))];
                repeat_score = [repeat_score; repeat_score_temp];
            end
        end
        repeat_score_mean = (repeat_score(:, 2) + repeat_score(:, 3)) ./ 2;
        repeat_score_all = [repeat_score_all; {repeat_score}];
        STRESS_intra = [STRESS_intra; {dir_res(i_file).name, STRESS(repeat_score(:, 2), repeat_score_mean)}];
        score_all(:, i_file) = score_lab;
        num_lab_all(:, i_file) = num_lab;
    end


    STRESS_intra_mean = mean(cell2mat(STRESS_intra(:, 2)));
    n_group=size(score_all,1)./33;
    n_obs=size(score_all,2);

    score_all_mean = mean(score_all, 2);
    STRESS_inter = [];
    for i_file = 1:n_file
        STRESS_inter = [STRESS_inter; {dir_res(i_file).name, STRESS(score_all(:, i_file), score_all_mean)}];
    end

    save(fullfile(output_folder, 'STRESS.mat'), 'STRESS_inter', 'STRESS_intra');

    % 计算 z_score
    score_all = round(score_all);
    for i_pic = 1:size(score_all, 1)
        for i_grade = 1:6
            count(i_pic, i_grade) = sum(score_all(i_pic, :) == i_grade);
        end
    end
    for i_grade = 1:6
        cumu(:, i_grade) = sum(count(:, 1:i_grade), 2);
    end
    LG = log((cumu + 0.5) ./ (size(score_all, 2) - cumu + 0.5));
    z_score = LG * 0.6422 + 0.0003;
    for i_grade = 1:5
        diff(:, i_grade) = z_score(:, i_grade + 1) - z_score(:, i_grade);
    end
    mean_diff = mean(diff, 1);
    boundary(1, 1) = 0;
    for i_grade = 2:6
        boundary(1, i_grade) = boundary(1, i_grade - 1) + mean_diff(1, i_grade - 1);
    end
    scaledValue = repmat(boundary, size(z_score, 1), 1) - z_score;
    meanScaledValue = mean(scaledValue(:, 1:5), 2);
    MSV_scaled = (meanScaledValue - min(meanScaledValue)) ./ (max(meanScaledValue) - min(meanScaledValue));

    % 处理并保存每个 group 的 z-score 和 lab
    load(fullfile('dlabsNpicname', strcat(lastPart, ".mat")));


    picname_check = [];
    for i_group = 1:33:length(score_all)
        picname_group = picname_lab{i_group}(1:end - 3);
        picname_check{floor((i_group - 1) / 33) + 1, 1} = picname_lab{i_group}(1:end - 3);
        lab_group = [];
        for i_pic = 1:length(dlabsNpicname)
            if strcmp(dlabsNpicname{i_pic, 2}(1:end - 3),gen_lastPart_new(picname_group))
                lab_group = [lab_group; dlabsNpicname{i_pic, 1}];
            end
        end
        MSV_group = MSV_scaled(i_group:i_group + 32, :);

        %---------CAT----------------
        wd65_64 = [94.811, 100.00, 107.304];
        for i_points=1:size(lab_group,1)
            lab_bfCAT(i_points, :) = lab_group(i_points,:);

            CCT = find_CCT(picname_group);

            XYZw_pre(i_points, :) = CCT2xyz(CCT);
            XYZ_bf(i_points, :) = lab2xyz2(lab_bfCAT(i_points, :), 'd65_64');
            [CCT, duv, S_out] = xyz2CCT(XYZw_pre(i_points, :), 10);
            
            if strcmp(Dtype,'full')
                D = 1;
            elseif strcmp(Dtype,'zhai')
                D = 0.723 * (1 - 1116 / CCT + 8.64 * duv - 49266 * duv / CCT); % zhai
            elseif strcmp(Dtype,'summer')
                D = 0.239 * 0.723 * (1 - 1116 / CCT); % summer
            elseif strcmp(Dtype,'OPPO')
                D = 0.00005 * CCT + 0.1977; % OPPO
            end
            if ~strcmp(Dtype,'noCAT')
                XYZ_aft(i_points, :) = CAT16_D(XYZ_bf(i_points, :),  XYZw_pre(i_points, :),wd65_64, 1);
                lab_group(i_points, :) = xyz2lab(XYZ_aft(i_points, :), 'd65_64');
            end

        end

        %-------------------
        outputFolder = fullfile(output_folder, 'labNscore');
        if ~exist(outputFolder, 'dir')
            mkdir(outputFolder);
        end
        picname_group_old=lower(gen_lastPart_old(picname_group));
        % if if_mix
            save(fullfile(outputFolder, strcat("labNscore_group",gen_lastPart_new(picname_group) , ".mat")), ...
                'lab_group','lab_bfCAT', 'MSV_group', 'picname_group','picname_check');
        % else
        %     save(fullfile(outputFolder, strcat("labNscore_group", picname_group_old, ".mat")), ...
        %         'lab_group','lab_bfCAT', 'MSV_group', 'picname_group','picname_check');
        % end
    end
end








