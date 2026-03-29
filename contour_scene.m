close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量
addpath("utils\")
%%
% VIVO
VIVO_table_folder="D:\work\VIVOskinExpe\analyze\AnalyseResults_p\efit_p\scaled\resTable";
VIVO_table_file=fullfile(VIVO_table_folder,"Peggy_VIVO_table.mat");
VIVO_table_data=load(VIVO_table_file);
VIVO_table=VIVO_table_data.fit_table;

nations = ["Asian", "Caucasian", "South Asian", "African"];

attributes = ["Preference", "Attractiveness", "Feminine", "Cooperative", ...
"Youth", "Healthy", "Fidelity", "Harmony", "Fair", "Ruddy"];

nation_indices = cell(5, 1); % 5个人种（包括"all"）
% AS (Asian): f04i, f05i, f06i, m04i, m05i, m06i (索引1-6)
nation_indices{1} = 1:6;
% CA (Caucasian): f01i, f02i, f03i, m01i, m02i, m03i (索引7-12)  
nation_indices{2} = 7:12;
% SA (South Asian): f07i, f08i, m07i, m08i (索引13-16)
nation_indices{3} = 13:16;
% AF (African): f09i, f10i, m09i, m10i (索引17-20)
nation_indices{4} = 17:20;
% all: 所有索引 (索引1-20)
nation_indices{5} = 1:20;
n_scenetype=3;
hue_values = linspace(0, 1, n_scenetype + 1);hue_values = hue_values(1:end-1);
hsv_matrix = [hue_values', 0.8*ones(n_scenetype, 1),  0.8*ones(n_scenetype, 1)];
colors_scene = hsv2rgb(hsv_matrix);

colors=zeros(14,3);
for i_scene = 1:size(colors, 1)
    if ismember(i_scene, [1, 2, 4, 5, 6])
        colors(i_scene,:) = colors_scene(1, :);
    elseif ismember(i_scene, [3, 7, 8, 9, 10, 11, 12])
        colors(i_scene,:) = colors_scene(2, :);
    elseif ismember(i_scene, [13, 14])
        colors(i_scene,:) = colors_scene(3, :);
    end
end

lastParts = {'f04r', 'f05r', 'f06r', 'm04r', 'm05r', 'm06r',...
'f01r', 'f02r', 'f03r', 'm01r', 'm02r', 'm03r',...
'f07r', 'f08r','m07r', 'm08r',...
'f09r', 'f10r','m09r', 'm10r'};n_para = 14;iOr='r';
for i_lastPart=1:length(lastParts)
    models{i_lastPart}=strrep(lastParts{i_lastPart},"i","");
end
wd65 = [94.811, 100.00, 107.304];
datai_file = 'D:\work\VIVOskinExpe\renderCode\calibResults\datai_ipv18_3.mat';
LUT=load(datai_file);
XYZw_LUT=LUT.XYZw;
labCh_PMCC=[[62.11	18.96	19.76	27.39	46.18];...
        [64.15	19.56	19.63	27.71	45.10];...
        [56.01	18.25	18.72	26.14	45.72];...
        [41.06	17.37	17.94	24.97	45.93]];
if iOr =='i'
    picnames_groups = ["h3k","h4k","h5k","h6k","hd65","h7k","h8k",...
                    "m3k","m4k","m5k","m6k","md65","m7k","m8k",...
                     "l3k","l4k","l5k","l6k","ld65","l7k","l8k"];
elseif iOr=='r'
    picnames_groups = ["rs01","rs02","rs03","rs04","rs05","rs06","rs07", ...
             "rs08","rs09","rs10","rs11","rs12","rs13","rs14"];
end
obs_type_used="non_model";
scale_type="scaled";
Dtype = 'efit_p';


for i_nation=1:length(nations)
        clear("lab_group","p_group","par_mean");
        nation=nations(i_nation);
        nation_serial=sprintf("%02d%s",i_nation,nation);
        curr_nation_indices = nation_indices{i_nation};
        clear("parNr")
        save_folder = fullfile('AnalyseResults_p', Dtype, ...
            scale_type ,"contour_scene",obs_type_used);
        if ~exist(save_folder,"dir")
            mkdir(save_folder)
        end

        all_scenes = string(VIVO_table.scene);
        all_ethnicities = string(VIVO_table.model_ethnicity);
        all_attributes = string(VIVO_table.attribute);
        all_observer_types = string(VIVO_table.observer_type);
        for i_attr = 1:1
            
            attribute = attributes(i_attr);
            attribute_serial = strcat(sprintf("%02d", i_attr), attributes(i_attr));
            attribute_serial=ch2eng(attribute_serial);
            for i_scene=1:length(picnames_groups)


                logic_idx = (endsWith(all_scenes,picnames_groups(i_scene))) & ...
                        (all_ethnicities == string(nation)) & ...
                        (all_attributes == attribute)&(all_observer_types == "non_model");
                    
                filtered_rows = VIVO_table(logic_idx, :);
                if size(filtered_rows,1)>0
    
                    for i_row=1:size(filtered_rows,1)
                        XYZw_white=filtered_rows.other_info{i_row,1}.XYZw_white_val;
                        xyz_values=lab2xyz2(filtered_rows.lab_values{i_row},"user",wd65./wd65(2).*XYZw_LUT(2));
                        filtered_rows.lab_values_scaled{i_row}=xyz2lab(xyz_values,"user",wd65./wd65(2).*XYZw_white(2));
                        
                        % lab_cen=[filtered_rows.average_lab{i_row}(1,1),filtered_rows.par{i_row}(1,4:5)];
                        % xyz_cen=lab2xyz2(lab_cen,"user",wd65./wd65(2).*XYZw_LUT(2));
                        % filtered_rows.lab_cen_scaled{i_row}=xyz2lab(xyz_cen,"user",wd65./wd65(2).*XYZw_white(2));
                    end
                    if strcmp(scale_type,"scaled")
                        lab_group = vertcat(filtered_rows.lab_values_scaled{:});
                    else
                        lab_group = vertcat(filtered_rows.lab_values{:});
                    end
                    p_group = vertcat(filtered_rows.opinion_scores{:});
                    par_group = vertcat(filtered_rows.par{:});
                    par_ave(i_scene,:)=mean(par_group,1,'omitnan');
        
                    [par_mean, r_mean] = ...
                        calculate_weighted_or_simple_mean(p_group, lab_group);
                    mean_cen(1) = mean(lab_group(:,1),'omitnan');
                    mean_cen(2:3) = par_mean(1,4:5);
            
                    % [par, r, y] = my_ellipsoidfit3_free(lab_group, MSV_group, mean_cen);
                    [par, r, y] = my_ellipsoidfit3_dy(lab_group, p_group,mean_cen);
        
                    parNr(i_scene,:) = [par, r];  
                end
            end

        end
        save_file=fullfile(save_folder,strcat(nation_serial,"_contour_scene.mat"));
        save(save_file,"parNr","lab_group","p_group","par_ave");
end




%% 画图部分：为每个 nation 生成一张包含所有 attribute 椭圆的图
nation_limits = struct();
% 为每个nation分别计算坐标轴范围
for i_nation = 1:length(nations)
    if i_nation~=4
        nation_limits(i_nation).lim_min_x = 0;
        nation_limits(i_nation).lim_max_x = 35;
        nation_limits(i_nation).lim_min_y = 0;
        nation_limits(i_nation).lim_max_y = 35;
    else
        nation_limits(i_nation).lim_min_x = 0;
        nation_limits(i_nation).lim_max_x = 35;
        nation_limits(i_nation).lim_min_y = 0;
        nation_limits(i_nation).lim_max_y = 35;
    end
end
nation_ticks=[10 10 10 5];
% 绘图循环
par_type="merge_fit";
% par_type="ave";
targetFontSize=12;
radi_scale=2;
for i_nation = 1:length(nations)
    nation = nations(i_nation);
    nation_serial = strcat(sprintf("%02d", i_nation), nation);

    save_file=fullfile(save_folder,strcat(nation_serial,"_contour_scene.mat"));
    data_nation=load(save_file);
    % 创建画布
    h_fig = figure(i_nation); % 避免与之前的图号冲突
    hold on;
    set(gcf, 'Color', 'white');
    
    % 绘制 y=x 参考线
    x_ref = linspace(-10, 50, 100);
    plot(x_ref, x_ref, '--', 'Color', 'k', 'LineWidth',1);

    % 遍历每个属性绘制椭圆
    for i_attr = 1:1
        attribute = attributes(i_attr);
        for i_scene=1:length(picnames_groups)
            if strcmp(par_type,"merge_fit")
                a = data_nation.parNr(i_scene, 1:end-1);
            elseif strcmp(par_type,"ave")
                a = data_nation.par_ave(i_scene, :);
            end
            a(1,1:3)=a(1,1:3).*(radi_scale.^2);
            par=a;
            if ~isempty(a)&&sum(a(2:3))~=0
                %---------------
                check_data2 = par(4) + (-30:0.2:30);
                check_data3 = par(5) + (-30:0.2:30);
                [data2, data3] = meshgrid(check_data2, check_data3);
                y = (1./(1+a(6)*exp(sqrt(a(1)*(data2-a(4)).^2+a(2)*(data3-a(5)).^2+ ...
                    a(3)*(data2-a(4)).*(data3-a(5)))))).*((a(1)*(data2-a(4)).^2+ ...
                    a(2)*(data3-a(5)).^2+a(3)*(data2-a(4)).*(data3-a(5)))>=0);        
                % 绘制等高线
                color=colors(i_scene,:);
                s0 = contour(data2, data3, y, [0.5, 1], 'LineWidth', 1, ...
                    'LineStyle', '-', 'Color', color);
                hold on;
                % 绘制特殊点
                plot(par(4), par(5), 'o', 'MarkerSize', 3, ...
                    'MarkerFaceColor', color, 'Color', 'k');
            end
        %-------------------------
        end
    end

    plot(labCh_PMCC(i_nation,2), labCh_PMCC(i_nation,3), 's', 'MarkerSize', 6, ...
        'MarkerFaceColor', [1 0 1], 'MarkerEdgeColor',[1 0 1],'LineWidth',0.5);
    %设置margin
    ax=gca;
    margin=0.18;
    set(ax.XLabel, 'Units', 'normalized');
    set(ax.YLabel, 'Units', 'normalized');
    ax.XLabel.Position(1) = 0.5; 
    ax.XLabel.Position(2) = -margin; 
    ax.YLabel.Position(1) = -margin; 
    ax.YLabel.Position(2) = 0.5;
    % 图形美化
    fontSizeScale=1.5;
    xlabel('a^{*}','Interpreter','tex','FontName','Arial','FontAngle','italic','FontSize',fontSizeScale*targetFontSize);
    ylabel('b^{*}','Interpreter','tex','FontName','Arial','FontAngle','italic','FontSize',fontSizeScale*targetFontSize);
    title(nation, 'FontSize', targetFontSize,'FontWeight','bold');
    axis equal;
    
    box on;
    
    % 设置坐标轴范围（参考您之前的 nation_limits）
    if exist('nation_limits', 'var')
        xlim([nation_limits(i_nation).lim_min_x, nation_limits(i_nation).lim_max_x]);
        ylim([nation_limits(i_nation).lim_min_y, nation_limits(i_nation).lim_max_y]);
    end
    set(gca, 'XTick', ceil(nation_limits(i_nation).lim_min_x):nation_ticks(i_nation):floor(nation_limits(i_nation).lim_max_x));
    set(gca, 'YTick', ceil(nation_limits(i_nation).lim_min_y):nation_ticks(i_nation):floor(nation_limits(i_nation).lim_max_y));
    % 保存图片（去除白边关键步骤）
    save_folder_plot = fullfile(save_folder, 'plots',par_type);
    if ~exist(save_folder_plot, 'dir'), mkdir(save_folder_plot); end    
    img_name = fullfile(save_folder_plot, strcat(nation_serial, '_contour_map.png'));

    exportgraphics(h_fig, img_name, 'Resolution', 600);
    savefig(h_fig, strrep(img_name, '.png', '.fig'))    
    fprintf('Saved contour plot for %s\n', nation);
    % close(h_fig); % 如果不需要连续查看，取消注释此行
    
end
close all


%%
s.labels_row1 = {"indoor","outdoor","night"};
s.labels_row2 = {"preference center","PMCC"};
s.markers_row2 = {'o','s'};
s.markers_colors = [0 0 0; 1 0 1];
s.markers_face_colors = [0 0 0; 1 0 1];
s.n_col1=3; 
s.n_col2=2;
s.if_label=true;
s.leg_x_shift=0.04;


s.colors_row1 = colors_scene;

s.label_type="contour_attr";
dir_figs=dir(fullfile(save_folder_plot,"*.fig"));
clear("figFiles")
for i_fig=1:length(dir_figs)
    figFiles{i_fig}=dir_figs(i_fig).name;
end
concatenate_figs_legend1(save_folder_plot, figFiles, 4,"none","draw",s,0.09,2);
%--------------------------------
fullfile(pwd,save_folder_plot)
