close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量

%%

femaleArray = ["female1makeup", "female1nomakeup", "female2makeup", "female2nomakeup", "female3makeup", "female3nomakeup", "female4makeup", "female4nomakeup", "female5makeup", "female5nomakeup", "indoor01", "indoor02", "indoor03", "indoor06", "indoor07", "indoor08", "night01", "night02", "night03", "night04", "night05", "night07", "outdoor01", "outdoor02", "outdoor03", "outdoor04", "outdoor06", "outdoor08", "sunset01", "sunset04", "sunset07", "sunset08"];
maleArray = ["male1", "male2", "male3", "male4", "indoor04", "indoor05", "indoor09", "indoor10", "night06", "night08", "night09", "night10", "outdoor05", "outdoor07", "outdoor09", "outdoor10", "sunset02", "sunset03", "sunset05", "sunset06"];

lastParts=["inLab","indoorAdd","nightAdd","outdoorAdd","sunsetAdd"];
escape=["indoor05","sunset01","sunset02","sunset03","sunset08"];
% Dtype="OPPO_CAT16";
Dtype = "efit_p";
lightness_type="rela";
rgb2xyz_type="display";
if strcmp(Dtype,"efit_p")
    sourceFolder=fullfile('AnalyseResults_p',rgb2xyz_type,lightness_type);
else
    sourceFolder='AnalyseResults';
end

genders=["f","m"];
ori_labs_gender= cell(length(genders), 1);
lab_f=[];picname_cor_f=[];
lab_m=[];picname_cor_m=[];
for i_lastPart=1:length(lastParts)
    lastPart=lastParts(i_lastPart);
    source_folder=fullfile(sourceFolder,Dtype,lastPart,'ellipPara_scaled');
    source_file=fullfile(source_folder,"fitRes_level.mat");
    fit_data=load(source_file);
    %提取ave %这里要小心顺序，没有check机制改一改就可能出错
    n_render=49;
    rows_used=49:n_render:size(fit_data.lab_group_all,1);
    ori_labs=fit_data.lab_group_all(rows_used,:);
    picname_check=fit_data.picname_check(:,1);
    par_ind=fit_data.par_ind;
    
    lab_group=fit_data.par_ind(:,5:7);
    
    slashes = strfind(source_folder, '\');
    
    wd65=[94.811 100.00 107.304];
    lab_PMCC=[62.11,18.96,19.76];
    
    for i_para=1:size(par_ind,1)
        %分类保存
        if ismember(picname_check{i_para,1},femaleArray)&&~ismember(picname_check{i_para,1},escape)
            lab_f=[lab_f;lab_group(i_para,:)];
            ori_labs_gender{1}=[ori_labs_gender{1};ori_labs(i_para,:)];
            picname_cor_f=[picname_cor_f;string(picname_check{i_para,1})];
        elseif ismember(picname_check{i_para,1},maleArray)&&~ismember(picname_check{i_para,1},escape)
            lab_m=[lab_m;lab_group(i_para,:)];
            ori_labs_gender{2}=[ori_labs_gender{2};ori_labs(i_para,:)];
            picname_cor_m=[picname_cor_m;string(picname_check{i_para,1})];
        end
    end

end

colors=hsv(length(genders));
for i_gender=1:2
    if i_gender==1
        lab_used=lab_f;
    else
        lab_used=lab_m;
    end
    [center,mu,chi2_val,List,cov_mat,cov_mat_r] =fit95ellip_my(lab_used, 0.05, 3);
    %------保存参数------
    save_folder=fullfile(sourceFolder,Dtype,'gender','95');
    output_folder=fullfile(save_folder,'ellipPara');
    if ~exist(output_folder, 'dir')
        mkdir(output_folder);
    end
    save(fullfile(output_folder, strcat(genders(i_gender),"fitRes_level.mat")), ...
        'center', 'mu','List');
    
    %--------画椭圆-----
    output_folder=fullfile(save_folder,'ellipsoid_sections');
    if ~exist(output_folder, 'dir')
        mkdir(output_folder);
    end
    
    contour95ellip(center,mu,lab_used,chi2_val, ...
        output_folder,genders(i_gender),colors(i_gender,:), ...
        "gender",mean(ori_labs_gender{i_gender},1)); 
    %------计算色差-----------
    for i_para=1:size(lab_used,1)
        for j_para=1:size(lab_used,1)
            dE_mat(i_para,j_para)=...
                deltaE2000(lab_used(i_para,:),lab_used(j_para,:));
        end
    end
    dE_intra{i_gender,1}=dE_mat;
    dE_mat(dE_mat == 0) = NaN;
    dE_intra_mean(i_gender,1)=nanmean(nanmean(dE_mat));

    center_labels(i_gender,:)=center;
end

%计算变量间色差
concatenate_images1(output_folder,2);
% gender_data=load(fullfile(sourceFolder,Dtype, ...
%     "gender\ellipPara_scaled\fitRes_level.mat"),"par_all");
% lab_50cen=gender_data.par_all(:,5:7);
for i_label=1:length(genders)
    for j_label=1:length(genders)
        dE_inter95(i_label,j_label)=...
            deltaE2000([center_labels(i_label,:)], ...
            [center_labels(j_label,:)]);
    end
end
dE_inter95(dE_inter95 == 0) = NaN;
dE_inter95_mean=nanmean(nanmean(dE_inter95));
% for i_label=1:length(genders)
%     for j_label=1:length(genders)
%         dE_inter50(i_label,j_label)=...
%             deltaE2000(lab_50cen(i_label,:), lab_50cen(j_label,:));
%     end
% end
% dE_inter50(dE_inter50 == 0) = NaN;
% dE_inter50_mean=nanmean(nanmean(dE_inter50));
dE{1,1}="dE_inter95";dE{1,2}="dE_intra";
dE{2,1}=dE_inter95_mean;dE{2,2}=mean(dE_intra_mean);
save(fullfile(output_folder, strcat("dE.mat")), ...
    'dE_intra', 'dE_intra_mean',"dE_inter95", ...
    "center_labels","dE_inter95_mean");
% dE{1,1}="dE_inter50";dE{1,2}="dE_inter95";dE{1,3}="dE_intra";
% dE{2,1}=dE_inter50_mean;dE{2,2}=dE_inter95_mean;dE{2,3}=mean(dE_intra_mean);
% save(fullfile(output_folder, strcat("dE.mat")), ...
%     'dE_intra', 'dE_intra_mean',"dE_inter50","dE_inter95", ...
%     'lab_50cen',"center_labels","dE_inter50_mean","dE_inter95_mean");

%%
% 提取lab_f和lab_m两组数据的labCh五个维度
labCh_f = [lab_f, sqrt(sum(lab_f(:,2:3).^2, 2)), atan2d(lab_f(:,3), lab_f(:,2))];
labCh_m = [lab_m, sqrt(sum(lab_m(:,2:3).^2, 2)), atan2d(lab_m(:,3), lab_m(:,2))];

% 创建分组变量
groups_f = repmat({'f'}, size(labCh_f, 1), 1);
groups_m = repmat({'m'}, size(labCh_m, 1), 1);
groups = [groups_f; groups_m];

% 合并两组数据
labCh_all = [labCh_f; labCh_m];

% 定义维度名称
dimension_names = {'L*', 'a*', 'b*', 'C', 'h'};

% 创建输出文件夹
output_folder = fullfile(sourceFolder, Dtype, 'gender', 'Normality_Test');
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end

% 初始化check变量
check = cell(5, 9); % 每行对应一个维度，每列对应不同的统计结果

% 对每个维度进行正态性检验
for i_dim = 1:5
    % 提取当前维度的数据
    data_f = labCh_f(:, i_dim);
    data_m = labCh_m(:, i_dim);
    
    % 绘制Q-Q图
    figure;
    subplot(1, 2, 1);
    qqplot(data_f);
    title(['Q-Q Plot for f - ', dimension_names{i_dim}]);
    
    subplot(1, 2, 2);
    qqplot(data_m);
    title(['Q-Q Plot for m - ', dimension_names{i_dim}]);
    
    % 保存Q-Q图
    saveas(gcf, fullfile(output_folder, ['QQPlot_dim', num2str(i_dim), '.png']));
    
    % 进行Lilliefors检验
    [h_f, p_f, ksstat_f, cv_f] = lillietest(data_f);
    [h_m, p_m, ksstat_m, cv_m] = lillietest(data_m);
    
    % 保存Lilliefors检验结果
    check{i_dim, 1} = dimension_names{i_dim}; % 维度名称
    check{i_dim, 2} = p_f; % f组的p值
    check{i_dim, 3} = ksstat_f; % f组的KS统计量
    check{i_dim, 4} = cv_f; % f组的临界值
    check{i_dim, 5} = p_m; % m组的p值
    check{i_dim, 6} = ksstat_m; % m组的KS统计量
    check{i_dim, 7} = cv_m; % m组的临界值
    
    % 输出Lilliefors检验结果
    fprintf('Lilliefors Test for dimension %s:\n', dimension_names{i_dim});
    fprintf('  f: p-value = %.4f, h = %d, KS Statistic = %.4f, Critical Value = %.4f\n', p_f, h_f, ksstat_f, cv_f);
    fprintf('  m: p-value = %.4f, h = %d, KS Statistic = %.4f, Critical Value = %.4f\n', p_m, h_m, ksstat_m, cv_m);
    % [p_levene, tbl_levene, stats_levene] = vartest2(data_f, data_m);
    % check{i_dim, 8} = p_levene; % Levene检验的p值
     check{i_dim, 8} =std(data_f)./std(data_m);
end

% 对每个维度进行ANOVA分析
p_values = zeros(1, 5); % 存储每个维度的p值
for i_dim = 1:5
    [p, tbl, stats] = anova1(labCh_all(:, i_dim), groups, 'off'); % 进行ANOVA分析
    p_values(i_dim) = p; % 保存p值
    check{i_dim, 9} = p; % 保存ANOVA的p值
end

% 输出每个维度的p值
disp('ANOVA p-values for each dimension:');
disp(p_values);

% 保存结果
output_folder = fullfile(sourceFolder, Dtype, 'gender', 'ANOVA');
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end
save(fullfile(output_folder, 'ANOVA_results_gender.mat'), 'p_values', 'labCh_all', 'groups');

% 可视化ANOVA结果
figure;
bar(1:5, p_values);
set(gca, 'XTickLabel', {'L*', 'a*', 'b*', 'C', 'h'});
ylabel('p-value');
title('ANOVA p-values for each dimension');
grid on;
saveas(gcf, fullfile(output_folder, 'ANOVA_p_values.png'));

% 保存check结果
save(fullfile(output_folder, 'check_results_gender.mat'), 'check');