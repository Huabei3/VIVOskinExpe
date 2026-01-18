close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量
addpath("utils\")
%%
load("neutral24\white.mat","CCT","XYZ_gray");
load("OPPOskin\matchTable_map.mat");
load("neutral24\global_ratio.mat");

wd65=[94.811 100.00 107.304];   
XYZw_pre_all=XYZ_gray./XYZ_gray(:,2).*100;

XYZ_gray_scene{1}=XYZ_gray(1:14,:);
XYZ_gray_scene{2}=XYZ_gray(15:24,:);
XYZ_gray_scene{3}=XYZ_gray(25:34,:);
XYZ_gray_scene{4}=XYZ_gray(35:44,:);
XYZ_gray_scene{5}=XYZ_gray(44:52,:);
XYZ_gray_scene{2}(5,:)=[];
XYZ_gray_scene{5}([1,2,3,8],:)=[];
for i_lastPart=1:5
    CCTpre{i_lastPart,1}=xyz2CCT(XYZ_gray_scene{i_lastPart},10);
    CCTpre{i_lastPart,1}=CCTpre{i_lastPart,1}';
    CCT_mean(i_lastPart,1)=mean(CCTpre{i_lastPart,1},1);
end

%%
lastParts=["inLab","indoorAdd","nightAdd","outdoorAdd","sunsetAdd"];
Dtype="efit_p";
lightness_type="abs";
rgb2xyz_type="srgb";
% rgb2xyz_type="display";
%%
H = linspace(0, 1, length(lastParts) + 1); % 加1是为了避免最后一个值为1（和0重复）
H = H(1:end-1); % 去掉最后一个值
S = 0.9 * ones(1, length(lastParts));
V = 0.7 * ones(1, length(lastParts));
colors = hsv2rgb([H; S; V]');
%%
lab_all_scene=[];
% for i_lastPart=1:1
for i_lastPart=1:length(lastParts)
    lastPart=lastParts(i_lastPart);
    if strcmp(rgb2xyz_type,"srgb")
        folder=fullfile('AnalyseResults_p',rgb2xyz_type,lightness_type, ...
            Dtype,lastPart);
    elseif strcmp(rgb2xyz_type,"display")
        folder=fullfile('AnalyseResults_p',lightness_type, ...
            Dtype,lastPart);
    end
    pic_folder=fullfile(folder,"checkVIVOmodel_pic",rgb2xyz_type);
    if ~exist(pic_folder,"dir")
        mkdir(pic_folder);
    end
    source_folder=fullfile(folder,'ellipPara_scaled');
    source_file=fullfile(source_folder,"fitRes_level.mat");
    fit_data=load(source_file);
    labNscore_folder=fullfile(folder,"labNscore");

    for i_par=1:size(fit_data.picname_check,1)
        dir_labNscore=dir(fullfile(labNscore_folder, ...
        strcat("labNscore_groupAdd",fit_data.picname_check{i_par,1},".mat")));
        file_labNscore=fullfile(dir_labNscore(1).folder,dir_labNscore(1).name);
        data_labNscore=load(file_labNscore);
        par=fit_data.par_ind(i_par,:);
        lab_group=data_labNscore.lab_group(1:18,:);
        p_group=data_labNscore.p_group(1:18,:);
        L=mean(lab_group(:,1),1,"omitnan");
        [hue_angle, chroma,long_axis,short_axis,theta,alpha] =...
            get_analytical_para(1,L);
        [par_ellipse] = calculate_par_from_ellipse(hue_angle, chroma, ...
                long_axis, short_axis, theta, alpha);
        y = calculate_y(lab_group(:,2), lab_group(:,3), par_ellipse);
        r(i_lastPart,i_par) = corr(y, p_group, 'Type', 'Pearson');
        dE(i_lastPart,i_par) =deltaE2000([L,par_ellipse(4:5)],par(5:7));
        dE1(i_lastPart,i_par) =deltaE2000([L,par_ellipse(4:5)],[L,par(6:7)]);
        centers_scene(i_par,:)=[[L,par_ellipse(4:5)],[L,par(6:7)]];
        picname_check{i_lastPart,i_par}=fit_data.picname_check{i_par,1};
        disp("d")
        %-----------------画图---------------------------
        figure();hold on;
        scatter(par(6), par(7), 30, 'filled','MarkerEdgeColor', 'r', ...
            'MarkerFaceColor', 'r');
        scatter(par_ellipse(4), par_ellipse(5), 30, 'filled','MarkerEdgeColor', 'b', ...
            'MarkerFaceColor', 'b');
        hold on;
        lim_max = max(max(lab_group(:, 2)), max(lab_group(:, 3))) + 10;
        lim_min = min(min(lab_group(:, 2)), min(lab_group(:, 3))) - 10;
        line([0, 0], [lim_min, lim_max], 'Color', 'k', 'LineStyle', '--'); % x=0
        line([lim_min, lim_max], [0, 0], 'Color', 'k', 'LineStyle', '--'); % y=0
        refline(1, 0); % 45 度线
    
        % 设置图形属性
        axis equal;
        xlim([lim_min, lim_max]);
        ylim([lim_min, lim_max]);
        xlabel('{\ita*}');
        ylabel('{\itb*}');
        title(sprintf("%s:L=%02d",fit_data.picname_check{i_par,1},round(L)));
        exportgraphics(gcf, fullfile(pic_folder, ...
            strcat(fit_data.picname_check{i_par,1},'.jpg')),'Resolution',150);
        close(gcf)

        % 
        % for i_match=1:length(match_table)
        %     if strcmp(strrep(data_labNscore.picname_lab{i_par}(1:end-3), ...
        %             "zrecen",""), match_table{i_match,1})
        %         break
        %     end
        % end
        % XYZw_pre(i_par,:)=XYZw_pre_all(i_match,:);
        % 
        % xyz_ave=lab2xyz2(average_scaled,"d65_64");
        % [CCT(i_par,1),duv(i_par,1),S_out{i_par,1}] = xyz2CCT(XYZw_pre(i_par,:),10);
        % D3(i_par,1) = calculateD(CCT(i_par,1),duv(i_par,1), Dtype);
        % XYZ_aft(i_ecat,:) = CAT16_D(xyz_ave(i_ecat,:), ...
        %     XYZw_pre(i_par,:), ...
        %     wd65, D3(i_par,1));

    end
    centers{i_lastPart,1}=centers_scene;
    %提取ori_labs %这里要小心顺序，没有check机制改一改就可能出错

end