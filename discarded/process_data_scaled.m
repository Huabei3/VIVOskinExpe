function process_data_scaled(dir_res, output_folder, lastPart,Dtype)
    % 处理数据并保存
    addpath("utils\")
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
    n_group=size(score_all,1)./33;
    n_obs=size(score_all,2);
    for i_obs = 1:n_obs
        for i_group = 1:n_group        
            score_all_temp=score_all((i_group-1)*33+1:i_group*33,i_obs);
            % picname_lab_temp=picname_lab((i_group-1)*33+1:i_group*33,1);
            score_all_temp = (score_all_temp - min(score_all_temp)) /(max(score_all_temp)-min(score_all_temp));
            score_all_scaled((i_group-1)*33+1:i_group*33,i_obs)=score_all_temp;
        end
    end
    % score_all_scaled = (score_all - 1) /5;
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
    load(fullfile('dlabsNpicname', strcat(lastPart, ".mat")));


    picname_check = [];
    for i_group = 1:33:length(score_all)
        i_nog=floor((i_group - 1) / 33) + 1;
        picname_group = picname_lab{i_group}(1:end - 3);
        picname_check{floor((i_group - 1) / 33) + 1, 1} = picname_lab{i_group}(1:end - 3);
        lab_group = [];matching_indices=[];
        for i_pic = 1:length(dlabsNpicname)
            picname_sing=char(gen_lastPart_new(dlabsNpicname{i_pic, 2}));
            if strcmp(picname_sing(1:end - 3),gen_lastPart_new(picname_group))
                lab_group = [lab_group; dlabsNpicname{i_pic, 1}];
            end
        end
        
        MSV_group = MSV_scaled(i_group:i_group + 32, :);

        %---------CAT----------------
        load("optmizedD\light_i.mat","CCT_light","XYZ_light");
        wd65_64 = [94.811, 100.00, 107.304];
        datai_file = '..\renderCode\calibResults\datai_ipv18_3.mat';
        LUT=load(datai_file);
        XYZw_LUT=LUT.XYZw;
        CCT = find_CCT(picname_group);
        [XYZw_wsq] = find_whitesquare(picname_group);
        wd65_wsq=wd65_64./wd65_64(2).*XYZw_wsq(2);
        
        for i_points=1:size(lab_group,1)
            lab_bfCAT(i_points, :) = lab_group(i_points,:);

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
            elseif strcmp(Dtype,'VIVO_3sec')   
                a=[5000,6500,0.877457958129589,8.806393623712550e-05,-5.419897901302469e-04,2.566090248335773e-04];
                D = (CCT <= a(1)) .* (a(3) + a(4)*(CCT - a(1))) + ...
                    (CCT > a(1) & CCT <= a(2)) .* (a(3) + a(5)*(CCT - a(1))) + ...
                    (CCT > a(2)) .* ((a(3) + a(5)*(a(2) - a(1))) + a(6)*(CCT - a(2)));
            elseif strcmp(Dtype,'VIVO_3sec_theo')
                a=[5000,6500,1.020458486365946,1.271174498057603e-04,-7.688089445339436e-04,2.887348158238644e-04];
                D = (CCT <= a(1)) .* (a(3) + a(4)*(CCT - a(1))) + ...
                    (CCT > a(1) & CCT <= a(2)) .* (a(3) + a(5)*(CCT - a(1))) + ...
                    (CCT > a(2)) .* ((a(3) + a(5)*(a(2) - a(1))) + a(6)*(CCT - a(2)));
            end
            if strcmp(Dtype,'noCAT')
                XYZ_bf(i_points, :)=XYZ_bf(i_points, :)./wd65_64(2).*XYZw_LUT(2);
                lab_group(i_points, :) = xyz2lab(XYZ_bf(i_points, :), 'user',wd65_wsq);
            else
                XYZ_aft(i_points, :) = CAT16_D(XYZ_bf(i_points, :), ...
                    XYZw_pre(i_points, :),wd65_64, D);
                XYZ_aft(i_points, :)=XYZ_aft(i_points, :)./wd65_64(2).*XYZw_LUT(2);
                lab_group(i_points, :) = xyz2lab(XYZ_aft(i_points, :), 'user',wd65_wsq);
            end

        end

        %-------------------
        outputFolder = fullfile(output_folder, 'labNscore');
        if ~exist(outputFolder, 'dir')
            mkdir(outputFolder);
        end
        picname_group_old=lower(gen_lastPart_old(picname_group));
        save(fullfile(outputFolder, strcat("labNscore_group",gen_lastPart_new(picname_group) , ".mat")), ...
            'lab_group','lab_bfCAT', 'MSV_group', 'picname_group','picname_check');

    end
    save(fullfile(outputFolder, strcat(lastPart,"picname_check.mat")), ...
    'picname_check');

end








