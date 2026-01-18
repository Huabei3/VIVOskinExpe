close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量

%%

fmArray=["female1makeup"	"female2makeup"	"female3makeup"	"female4makeup"	"female5makeup"	"indoor01"	"indoor02"	"indoor03"	"indoor06"	"indoor07"	"indoor08"	"night01"	"night02"	"night03"	"night04"	"night05"	"night07"	"outdoor01"	"outdoor02"	"outdoor03"	"outdoor04"	"outdoor06"	"outdoor08"	"sunset01"	"sunset04"	"sunset07"	"sunset08"];
fnArray=["female1nomakeup"	"female2nomakeup"	"female3nomakeup"	"female4nomakeup"	"female5nomakeup"];
mArray=["male2"	"male3"	"male4"	"indoor04"	"indoor05"	"indoor09"	"indoor10"	"night06"	"night08"	"night09"	"night10"	"outdoor05"	"outdoor07"	"outdoor09"	"outdoor10"	"sunset02"	"sunset03"	"sunset05"	"sunset06"];
lastParts=["inLab","indoorAdd","nightAdd","outdoorAdd","sunsetAdd"];
escape=["indoor05","sunset01","sunset02","sunset03","sunset08"];
% Dtype="OPPO_CAT16";
Dtype = "efit_p";
if strcmp(Dtype,"efit_p")
    sourceFolder='AnalyseResults_p\abs';
else
    sourceFolder='AnalyseResults';
end

makeups=["fm","fn"];
ori_labs_makeup= cell(3, 1);
lab_fm=[];picname_cor_fm=[];lab_fn=[];picname_cor_fn=[];
lab_m=[];picname_cor_m=[];
for i_lastPart=1:1
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
        if ismember(picname_check{i_para,1},fmArray)&&~ismember(picname_check{i_para,1},escape)
            lab_fm=[lab_fm;lab_group(i_para,:)];
            picname_cor_fm=[picname_cor_fm;string(picname_check{i_para,1})];
            ori_labs_makeup{1}=[ori_labs_makeup{1};ori_labs(i_para,:)];
        elseif ismember(picname_check{i_para,1},fnArray)&&~ismember(picname_check{i_para,1},escape)
            lab_fn=[lab_fn;lab_group(i_para,:)];
            picname_cor_fn=[picname_cor_fn;string(picname_check{i_para,1})];
            ori_labs_makeup{2}=[ori_labs_makeup{2};ori_labs(i_para,:)];
        elseif ismember(picname_check{i_para,1},mArray)&&~ismember(picname_check{i_para,1},escape)
            lab_m=[lab_m;lab_group(i_para,:)];
            picname_cor_m=[picname_cor_m;string(picname_check{i_para,1})];
            ori_labs_makeup{3}=[ori_labs_makeup{3};ori_labs(i_para,:)];
        end
    end

end


colors=hsv(2);
for i_makeup=1:2
    if i_makeup==1
        lab_used=lab_fm;
    elseif i_makeup==2
        lab_used=lab_fn;
    else
        lab_used=lab_m;
    end
    [center,mu,chi2_val,List,cov_mat,cov_mat_r] =fit95ellip_my(lab_used, 0.05, 3);
    %------保存参数------
    save_folder=fullfile(sourceFolder,Dtype,'makeup','95');
    output_folder=fullfile(save_folder,'ellipPara');
    if ~exist(output_folder, 'dir')
        mkdir(output_folder);
    end
    save(fullfile(output_folder, strcat(makeups(i_makeup),"fitRes_level.mat")), ...
        'center', 'mu','List');
    
    %--------画椭圆-----
    output_folder=fullfile(save_folder,'ellipsoid_sections');
    if ~exist(output_folder, 'dir')
        mkdir(output_folder);
    end
    contour95ellip(center,mu,lab_used,chi2_val, ...
        output_folder,makeups(i_makeup),colors(i_makeup,:), ...
        "makeup",mean(ori_labs_makeup{i_makeup},1)); 
    % contour95ellip(center,mu,lab_used,chi2_val, ...
    % output_folder,makeups(i_makeup),colors(i_makeup,:), ...
    % "makeup",[NaN,NaN,NaN]); 
    %------计算色差-----------
    for i_para=1:size(lab_used,1)
        for j_para=1:size(lab_used,1)
            dE_mat(i_para,j_para)=...
                deltaE2000(lab_used(i_para,:),lab_used(j_para,:));
        end
    end
    dE_intra{i_makeup,1}=dE_mat;
    dE_mat(dE_mat == 0) = NaN;
    dE_intra_mean(i_makeup,1)=nanmean(nanmean(dE_mat));

    center_labels(i_makeup,:)=center;
end
concatenate_images1(output_folder,2);
%计算变量间色差
% makeup_data=load(fullfile(sourceFolder,Dtype, ...
%     "makeup\ellipPara_scaled\fitRes_level.mat"),"par_all");
% lab_50cen=makeup_data.par_all(:,5:7);
for i_label=1:length(makeups)
    for j_label=1:length(makeups)
        dE_inter95(i_label,j_label)=...
            deltaE2000(center_labels(i_label,:), ...
            center_labels(j_label,:));
    end
end
dE_inter95(dE_inter95 == 0) = NaN;
dE_inter95_mean=nanmean(nanmean(dE_inter95));
% for i_label=1:length(makeups)
%     for j_label=1:length(makeups)
%         dE_inter50(i_label,j_label)=...
%             deltaE2000(lab_50cen(i_label,:),lab_50cen(j_label,:));
%     end
% end
% dE_inter50(dE_inter50 == 0) = NaN;
% dE_inter50_mean=nanmean(nanmean(dE_inter50));

dE{1,1}="dE_inter95";dE{1,2}="dE_intra";
dE{2,1}=dE_inter95_mean;dE{2,2}=mean(dE_intra_mean);
save(fullfile(output_folder, strcat("dE.mat")), ...
    'dE_intra', 'dE_intra_mean',"dE_inter95", ...
    "center_labels","dE_inter95_mean","dE");
% dE{1,1}="dE_inter50";dE{1,2}="dE_inter95";dE{1,3}="dE_intra";
% dE{2,1}=dE_inter50_mean;dE{2,2}=dE_inter95_mean;dE{2,3}=mean(dE_intra_mean);
% save(fullfile(output_folder, strcat("dE.mat")), ...
%     'dE_intra', 'dE_intra_mean',"dE_inter50","dE_inter95", ...
%     'lab_50cen',"center_labels","dE_inter50_mean","dE_inter95_mean","dE");

%%
% 提取fm和fn两组数据的labCh五个维度
labCh_fm = [lab_fm, sqrt(sum(lab_fm(:,2:3).^2, 2)), atan2d(lab_fm(:,3), lab_fm(:,2))];
labCh_fn = [lab_fn, sqrt(sum(lab_fn(:,2:3).^2, 2)), atan2d(lab_fn(:,3), lab_fn(:,2))];

% 创建分组变量
groups_fm = repmat({'fm'}, size(labCh_fm, 1), 1);
groups_fn = repmat({'fn'}, size(labCh_fn, 1), 1);
groups = [groups_fm; groups_fn];

% 合并两组数据
labCh_all = [labCh_fm; labCh_fn];

% 定义维度名称
dimension_names = {'L*', 'a*', 'b*', 'C', 'h'};

% 创建输出文件夹
output_folder = fullfile(sourceFolder, Dtype, 'makeup', 'Normality_Test');
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end

% 对每个维度进行正态性检验
for i_dim = 1:5
    % 提取当前维度的数据
    data_fm = labCh_fm(:, i_dim);
    data_fn = labCh_fn(:, i_dim);
    
    % 绘制Q-Q图
    figure;
    subplot(1, 2, 1);
    qqplot(data_fm);
    title(['Q-Q Plot for fm - ', dimension_names{i_dim}]);
    
    subplot(1, 2, 2);
    qqplot(data_fn);
    title(['Q-Q Plot for fn - ', dimension_names{i_dim}]);
    
    % 保存Q-Q图
    saveas(gcf, fullfile(output_folder, ['QQPlot_dim', num2str(i_dim), '.png']));
    
    % 进行Lilliefors检验
    [h_fm, p_fm, ksstat_fm, cv_fm] = lillietest(data_fm);
    [h_fn, p_fn, ksstat_fn, cv_fn] = lillietest(data_fn);
    check{i_dim,1}=dimension_names{i_dim};
    check{i_dim,2}=p_fm;
    check{i_dim,3}=ksstat_fm;
    check{i_dim,4}=cv_fm;

    check{i_dim,5}=p_fn;
    check{i_dim,6}=ksstat_fn;
    check{i_dim,7}=cv_fn;
    % 输出Lilliefors检验结果
    fprintf('Lilliefors Test for dimension %s:\n', dimension_names{i_dim});
    fprintf('  fm: p-value = %.4f, h = %d, KS Statistic = %.4f, Critical Value = %.4f\n', p_fm, h_fm, ksstat_fm, cv_fm);
    fprintf('  fn: p-value = %.4f, h = %d, KS Statistic = %.4f, Critical Value = %.4f\n', p_fn, h_fn, ksstat_fn, cv_fn);
    [p_levene, tbl_levene, stats_levene] = vartest2(data_fm, data_fn);
    % check{i_dim, 8} = p_levene; % Levene检验的p值
    check{i_dim, 8} =std(data_fm)./std(data_fn);
end



% 对每个维度进行ANOVA分析
p_values = zeros(1, 5); % 存储每个维度的p值
for i_dim = 1:5
    [p, tbl, stats] = anova1(labCh_all(:, i_dim), groups, 'off'); % 进行ANOVA分析
    p_values(i_dim) = p; % 保存p值
    check{i_dim,9}=p;
end

% 输出每个维度的p值
disp('ANOVA p-values for each dimension:');
disp(p_values);

% 保存结果
output_folder = fullfile(sourceFolder, Dtype, 'makeup', 'ANOVA');
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end
save(fullfile(output_folder, 'ANOVA_results.mat'), 'p_values', 'labCh_all', 'groups');

%%
% 初始化存储Mann-Whitney U检验结果的变量
p_values_mannwhitney = zeros(1, 5); % 存储每个维度的p值

% 对每个维度进行Mann-Whitney U检验
for i_dim = 1:5
    % 提取当前维度的数据
    data_fm = labCh_fm(:, i_dim);
    data_fn = labCh_fn(:, i_dim);
    
    % 进行Mann-Whitney U检验
    [p_mannwhitney, ~] = ranksum(data_fm, data_fn);
    p_values_mannwhitney(i_dim) = p_mannwhitney; % 保存p值
    check{i_dim, 10} = p_mannwhitney; % 将Mann-Whitney U检验的p值保存到check变量中

end

% 输出每个维度的Mann-Whitney U检验p值
disp('Mann-Whitney U Test p-values for each dimension:');
disp(p_values_mannwhitney);

% 保存结果
output_folder = fullfile(sourceFolder, Dtype, 'makeup', 'Nonparametric_Test');
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end
save(fullfile(output_folder, 'MannWhitneyU_results.mat'), 'p_values_mannwhitney', 'check');