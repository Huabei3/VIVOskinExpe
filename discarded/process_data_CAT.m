function process_data_CAT(dir_res, output_folder, lastPart,Dtype,data_type)
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
        scores = mapMatrixValues(scores);
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
        repeat_score(:, 2:3) = (repeat_score(:, 2:3) - 1) / 5;
        repeat_score_mean = (repeat_score(:, 2) + repeat_score(:, 3)) ./ 2;
        repeat_score_all = [repeat_score_all; {repeat_score}];
        STRESS_intra = [STRESS_intra; {dir_res(i_file).name, STRESS(repeat_score(:, 2), repeat_score_mean)}];
        score_all(:, i_file) = score_lab;
        num_lab_all(:, i_file) = num_lab;
    end


    STRESS_intra_mean = mean(cell2mat(STRESS_intra(:, 2)));
    score_all_scaled = (score_all - 1) / 5;
    score_all_mean = mean(score_all_scaled, 2);
    STRESS_inter = [];
    for i_file = 1:n_file
        STRESS_inter = [STRESS_inter; {dir_res(i_file).name, STRESS(score_all_scaled(:, i_file), score_all_mean)}];
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
    if strcmp(data_type,"Asian")
        load(fullfile('dlabsNpicname', strcat(lastPart, ".mat")));
    elseif strcmp(data_type,"Asian_ruddy")
        lastPart_new=gen_lastPart_new(lastPart);
        load(fullfile('dlabsNpicname', 'ruddy',strcat(lastPart_new, ".mat")));
    elseif strcmp(data_type,"not_Asian")
        lastPart_new=gen_lastPart_new(lastPart);
        load(fullfile('dlabsNpicname', strcat(lastPart_new, ".mat")));
    end
    picname_check = [];
    for i_group = 1:33:length(score_all)
        picname_group = picname_lab{i_group}(1:end - 3);
        picname_check{floor((i_group - 1) / 33) + 1, 1} = picname_lab{i_group}(1:end - 3);
        lab_group = [];
        for i_pic = 1:length(dlabsNpicname)
            if strcmp(dlabsNpicname{i_pic, 2}(1:end - 3), picname_group)
                lab_group = [lab_group; dlabsNpicname{i_pic, 1}];
            end
        end
        MSV_group = MSV_scaled(i_group:i_group + 32, :);

        %---------CAT----------------
        wd65_64 = [94.811, 100.00, 107.304];
        for i_points=1:size(lab_group,1)
            lab_bfCAT(i_points, :) = lab_group(i_points,:);
            CCT = find_CCT_i( picname_group);
            XYZw_pre(i_points, :) = CCT2xyz(CCT);
            XYZ_bf(i_points, :) = lab2xyz2(lab_bfCAT(i_points, :), 'd65_64');
            [CCT, duv, S_out] = xyz2CCT(XYZw_pre(i_points, :), 10);
            D1 = 0.723 * (1 - 1116 / CCT + 8.64 * duv - 49266 * duv / CCT); % zhai
            D2 = 0.239 * 0.723 * (1 - 1116 / CCT); % summer
            D3 = 0.00005 * CCT + 0.1977; % OPPO
            XYZ_aft(i_points, :) = CAT16_D(XYZ_bf(i_points, :),  XYZw_pre(i_points, :),wd65_64, 1);
            XYZ_aft1(i_points, :) = CAT16_D(XYZ_bf(i_points, :), XYZw_pre(i_points, :), wd65_64, D1);
            XYZ_aft2(i_points, :) = CAT16_D(XYZ_bf(i_points, :), XYZw_pre(i_points, :), wd65_64, D2);
            XYZ_aft3(i_points, :) = CAT16_D(XYZ_bf(i_points, :),  XYZw_pre(i_points, :),wd65_64, D3);
            lab_aft(i_points, :) = xyz2lab(XYZ_aft(i_points, :), 'd65_64');
            lab_aft1(i_points, :) = xyz2lab(XYZ_aft1(i_points, :), 'd65_64');
            lab_aft2(i_points, :) = xyz2lab(XYZ_aft2(i_points, :), 'd65_64');
            lab_aft3(i_points, :) = xyz2lab(XYZ_aft3(i_points, :), 'd65_64');

        end
        if strcmp(Dtype,'full')
            lab_group=lab_aft;
        elseif strcmp(Dtype,'zhai')
            lab_group=lab_aft1;
        elseif strcmp(Dtype,'summer')
            lab_group=lab_aft2;
        elseif strcmp(Dtype,'OPPO')
            lab_group=lab_aft3;
        end
        %-------------------
        outputFolder = fullfile(output_folder, 'labNscore');
        if ~exist(outputFolder, 'dir')
            mkdir(outputFolder);
        end
        picname_group_old=lower(gen_lastPart_old(picname_group));

        save(fullfile(outputFolder, strcat("labNscore_group", picname_group_old, ".mat")), ...
            'lab_group','lab_bfCAT', 'MSV_group', 'picname_group','picname_check');
    end
end



function CCT = find_CCT_i( picname_group)
    picnames_groups = ["h3k","h4k","h5k","h6k","h7k","h8k","hd65", ...
                     "l3k","l4k","l5k","l6k","l7k","l8k","ld65", ...
                     "m3k","m4k","m5k","m6k","m7k","m8k","md65"];
    CT = [3000, 4000, 5000, 6000, 7000, 8000, 6500, ...
          3000, 4000, 5000, 6000, 7000, 8000, 6500, ...
          3000, 4000, 5000, 6000, 7000, 8000, 6500]';
    CCT = [];

    % 遍历 picname_group
    for idx = 1:length(picnames_groups)
        % 检查 input_string 是否包含当前 picname
        if contains(picname_group, picnames_groups(idx))
            % 如果包含，返回对应的 CT 值
            CCT = CT(idx);
            return; % 找到匹配项后立即返回
        end
    end

    % 如果未找到匹配项，输出警告
    warning('未找到匹配的 picname: %s', input_string);
end


function mappedMatrix = mapMatrixValues(matrix)
    mappedMatrix = matrix;
    [rows, cols] = size(matrix);
    for i = 1:rows
        for j = 1:cols
            if matrix(i, j) == -3
                mappedMatrix(i, j) = 1;
            elseif matrix(i, j) == -2
                mappedMatrix(i, j) = 2;
            elseif matrix(i, j) == -1
                mappedMatrix(i, j) = 3;
            elseif matrix(i, j) == 1
                mappedMatrix(i, j) = 4;
            elseif matrix(i, j) == 2
                mappedMatrix(i, j) = 5;
            elseif matrix(i, j) == 3
                mappedMatrix(i, j) = 6;
            end
        end
    end
end

% function newname=raplacename(oldname)
%     newname = strrep(oldname, "femaleVIVO", "");
% end