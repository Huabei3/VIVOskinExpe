close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量

%%
lastParts=["inLab","indoorAdd","nightAdd","outdoorAdd","sunsetAdd"];
% Dtype="OPPO_CAT16";
Dtype = "efit_p";
lightness_type="rela";
rgb2xyz_type="display";
if strcmp(Dtype,"efit_p")
    sourceFolder=fullfile('AnalyseResults_p',rgb2xyz_type,lightness_type);
else
    sourceFolder='AnalyseResults';
end
lab_cherry=[65.50 	17.21 	17.72 ];
ab_summer=[0 17.9 18.7];
% ab_zeng=[0 19.9 23.0];
ab_zeng=[0 18 21];

PengCIC=[[65,0,0,25.3,46.5];[67,0,0,25.3,46.0];[58,0,0,25.1,46.5];[40,0,0,25.0,46.5]];
PengCIC(:,2)=PengCIC(:,4).*cosd(PengCIC(:,5));
PengCIC(:,3)=PengCIC(:,4).*sind(PengCIC(:,5));

CaoCIC=[[0,0,0,25.4,44.5];[0,0,0,24.5,43.7];[0,0,0,25.7,48.3];[0,0,0,23.0,48.0]];
CaoCIC(:,2)=CaoCIC(:,4).*cosd(CaoCIC(:,5));
CaoCIC(:,3)=CaoCIC(:,4).*sind(CaoCIC(:,5));

Zeng=[[0,18,21];[0,17,16];[0,0,0];[0,21,29]];

lab_OPPO=[65.1919   19.0833   23.0048];
colors=hsv(length(lastParts));

for i_lastPart=1:1
    lastPart=lastParts(i_lastPart);
    source_folder=fullfile(sourceFolder,Dtype,lastPart,'ellipPara_scaled');
    source_file=fullfile(source_folder,"fitRes_level.mat");
    fit_data=load(source_file);

    %-------------50%椭圆------------
    check_data2 = fit_data.par(6) + (-30:0.2:30);
    check_data3 = fit_data.par(7) + (-30:0.2:30);
    [data2, data3] = meshgrid(check_data2, check_data3);
    a = fit_data.par;
    % 计算 y 的值
    y = (1./(1 + a(8) * exp(sqrt(a(2) * (data2 - a(6)).^2 + a(3) * (data3 - a(7)).^2 + ...
        a(4) * (data2 - a(6)) .* (data3 - a(7)))))).*((a(2) * (data2 - a(6)).^2 + ...
        a(3) * (data3 - a(7)).^2 + a(4) * (data2 - a(6)) .* (data3 - a(7))) >= 0);
    figure(1);hold on;
    contour(data2, data3, y, [0.5, 1], 'Linewidth', 1);
    scatter(fit_data.par(6), fit_data.par(7), 30, 'd','filled');
    %-------------------------
    %提取ave %这里要小心顺序，没有check机制改一改就可能出错
    n_render=49;
    rows_used=49:n_render:size(fit_data.lab_group_all,1);
    ori_labs=fit_data.lab_group_all(rows_used,:);%这里的ori_labs已经经历过CAT了
    
    lab_group=fit_data.par_ind(:,5:7);    
    
    slashes = strfind(source_folder, '\');
    
    wd65=[94.811 100.00 107.304];
    lab_PMCC=[62.11,18.96,19.76];
    
    
    %%
    if strcmp(lastPart,"indoorAdd")
        lab_group(5,:)=[];
        ori_labs(5,:)=[];
    elseif strcmp(lastPart,"sunsetAdd")
        lab_group([1,2,3,8],:)=[];
        ori_labs([1,2,3,8],:)=[];
    end
    lab_50cen(i_lastPart,:)=fit_data.par(:,5:7);
    %%
    % 拟合椭球并保存结果
    
    [center,mu,chi2_val,List,cov_mat,cov_mat_r] =fit95ellip_my(lab_group, 0.05, 3);
    %------保存参数------
    save_folder=fullfile(sourceFolder,Dtype,'compare','95');
    output_folder=fullfile(save_folder,'ellipPara');
    if ~exist(output_folder, 'dir')
        mkdir(output_folder);
    end
    save(fullfile(output_folder, strcat(lastPart,"fitRes_level.mat")), ...
        'center', 'mu','List');
    
    %--------画椭圆------------
    output_folder=fullfile(save_folder,'ellipsoid_sections');
    if ~exist(output_folder, 'dir')
        mkdir(output_folder);
    end
    contour95ellip(center,mu,lab_group,chi2_val, ...
        output_folder,lastPart,colors(i_lastPart,:),"scene",mean(ori_labs,1)); 

    %------计算色差-----------
    for i_para=1:size(lab_group,1)
        for j_para=1:size(lab_group,1)
            dE_mat(i_para,j_para)=...
                deltaE2000(lab_group(i_para,:),lab_group(j_para,:));
        end
    end
    dE_intra{i_lastPart,1}=dE_mat;
    dE_mat(dE_mat == 0) = NaN;
    dE_intra_mean(i_lastPart,1)=nanmean(nanmean(dE_mat));

    center_labels(i_lastPart,:)=center;
end

h1 = figure(1);

hold on;
hsvColors = hsv(3); % 设置饱和度为 0.5
hsvColors(:, 2) = 0.5; 
axis equal
% scatter(lab_cherry(2), lab_cherry(3), 20, '^', 'LineWidth', 1, ...
% 'MarkerEdgeColor',hsvColors(1,:));
% scatter(ab_summer(2), ab_summer(3), 20, '^', 'LineWidth', 1, ...
% 'MarkerEdgeColor',hsvColors(2,:));


scatter(PengCIC(1,2), PengCIC(1,3), 20, '^', 'LineWidth', 1, ...
'MarkerEdgeColor',hsvColors(1,:));
scatter(CaoCIC(1,2), CaoCIC(1,3), 20, '^', 'LineWidth', 1, ...
'MarkerEdgeColor',hsvColors(2,:));

scatter(ab_zeng(2), ab_zeng(3), 20, '^', 'LineWidth', 1, ...
'MarkerEdgeColor',hsvColors(3,:));
axis equal
xlim([0,40])
ylim([0,40])
grid on;box on;
exportgraphics(gcf, fullfile(output_folder, strcat('a_b.jpg')), ...
    'Resolution', 300);



concatenate_images1(output_folder,3);
LabCh(1,:)=[65.50 	17.21 	17.72 ];
LabCh(2,:)=[0 17.9 18.7];
LabCh(3,:)=[0 18 21];
LabCh(4,:)=center;
LabCh(:,4)=sqrt(LabCh(:,2).^2+LabCh(:,3).^2);
LabCh(:,5)=atan2d(LabCh(:,3),LabCh(:,2));