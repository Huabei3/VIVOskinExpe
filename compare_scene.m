close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量

%%
length_color=4;
hue_values = linspace(0, 1, length_color + 1);hue_values = hue_values(1:end-1);
hsv_matrix = [hue_values', 0.8 * ones(length_color, 1), 0.8 * ones(length_color, 1)];
colors = hsv2rgb(hsv_matrix);
scale_type_origin="unscaled";
scale_type="scaled";
Dtype="efit_p";
interpreter_type="tex";
lab_cherry=[65.50 	17.21 	17.72];
ab_summer=[0 17.9 18.7];
% ab_zeng=[0 19.9 23.0];
ab_zeng=[0 18 21];
ab_zengCIC=[0 21 24];
lab_OPPO=[65.1919   19.0833   23.0048];
PengCIC=[[67,0,0,25.3,46.0];[65,0,0,25.3,46.5];[58,0,0,25.1,46.5];[40,0,0,25.0,46.5]];
PengCIC(:,2)=PengCIC(:,4).*cosd(PengCIC(:,5));
PengCIC(:,3)=PengCIC(:,4).*sind(PengCIC(:,5));

CaoCIC=[[0,0,0,24.5,43.7];[0,0,0,25.4,44.5];[0,0,0,25.7,48.3];[0,0,0,23.0,48.0]];
CaoCIC(:,2)=CaoCIC(:,4).*cosd(CaoCIC(:,5));
CaoCIC(:,3)=CaoCIC(:,4).*sind(CaoCIC(:,5));

Zeng=[[0,18,21];[0,17,16];[0,0,0];[0,21,29]];

% scenes_OPPO=[[59.22 0 0	26.81 	46.85] ;%室内
% [57.49 0 0	23.66 	46.81] ;%室外
% [62.87 0 0	22.02 	42.75];%黄昏
% [61.78 0 0	25.84 	49.74]];%夜景
% scenes_OPPO(:,2)=scenes_OPPO(:,4).*cosd(scenes_OPPO(:,5));
% scenes_OPPO(:,3)=scenes_OPPO(:,4).*sind(scenes_OPPO(:,5));
% [63.02 	20.02 	26.32 	33.07 	59.95 ];%实验室内
scenes_OPPO=[
[56.48 	18.59 	22.44 	29.14 	55.54 ];%室内
[55.58 	15.97 	18.35 	24.32 	52.87 ];%室外
[62.09 	16.30 	16.15 	22.95 	44.47 ];%黄昏
[60.70 	16.25 	20.42 	26.10 	57.65 ]%夜景
];


labCh_PMCC=[[62.11	18.96	19.76	27.39	46.18];...
            [64.15	19.56	19.63	27.71	45.10];...
            [56.01	18.25	18.72	26.14	45.72];...
            [41.06	17.37	17.94	24.97	45.93]];

output_folder=fullfile("ellip_pic_p",Dtype,"compare_scene");

if ~exist(output_folder,"dir")
    mkdir(output_folder);
end
lastParts_OPPO=["indoorAdd","outdoorAdd","sunsetAdd","nightAdd"];
ethnic_names=["Asian","Caucasian","South Asian","African"];
ethnic_groups=["1AS","2CA","3SA","4AF"];
res_matrix=[];curr=1;
for i_eth=[1]
    figure(i_eth);
    % grid on;
    box on;
    hold on;
    if strcmp(Dtype,"efit_p_free")
        AnalyseResults_folder="AnalyseResults_p_free";
    elseif strcmp(Dtype,"efit_p")
        AnalyseResults_folder="AnalyseResults_p";
    end
    source_folder=fullfile("D:\work\VIVOskinExpe\analyze",AnalyseResults_folder, ...
        Dtype,"50",scale_type_origin,"nation1",scale_type, ...
            "non_model\r\01Preference",ethnic_groups(i_eth));
    for i_indices=1:4
        full_path=fullfile(source_folder,strcat(num2str(i_indices),".mat"));
        if ~exist(full_path,"file")
            continue
        end
        fitRes_data = load(full_path); 
        par=fitRes_data.par;
        center(i_eth,:)=[fitRes_data.average_indices_curr(1,1),par(1,4:5)];
        
        check_data2 = par(4) + (-30:0.2:30);
        check_data3 = par(5) + (-30:0.2:30);
        [data2, data3] = meshgrid(check_data2, check_data3);
        [row, col] = size(data2);
        
        % 计算等高线数据
        a = par;
        y = (1./(1+a(6)*exp(sqrt(a(1)*(data2-a(4)).^2+a(2)*(data3-a(5)).^2+ ...
            a(3)*(data2-a(4)).*(data3-a(5)))))).*((a(1)*(data2-a(4)).^2+ ...
            a(2)*(data3-a(5)).^2+a(3)*(data2-a(4)).*(data3-a(5)))>=0);
        
        % 绘制等高线
        s0 = contour(data2, data3, y, [0.5, 1], 'LineWidth', 1, ...
             'Color', colors(i_indices,:));
        hold on;
        % 绘制特殊点
        plot(par(4), par(5), 'o', 'MarkerSize', 4, ...
            'MarkerFaceColor', colors(i_indices,:), 'Color', colors(i_indices,:));
        
        res_matrix=[res_matrix;center(i_eth,:)];
        res_cell{curr,1}=center(i_eth,:);
        res_cell{curr,2}=num2str(i_indices);
        curr=curr+1;
        axis equal
        min_lim=0;
        max_lim=40;
        xlim([min_lim,max_lim])
        ylim([min_lim,max_lim])
        xticks(min_lim:10:max_lim)
        yticks(min_lim:10:max_lim)
        x = linspace(min_lim, max_lim, 1000);
        y = x;
        plot(x, y,'LineStyle','--','LineWidth',1,'Color','k');
        %-------------------------
        lastPart_OPPO=lastParts_OPPO(i_indices);
        OPPO_inLab50_folder=fullfile("D:\work\project_code_backup\OPPOskinExpe\analyzeResult_scaled\" + ...
            "AnalyseResults_p\display\rela\efit_p\scene",lastPart_OPPO,"ellipPara_scaled");
        OPPO_inLab50_data=load(fullfile(OPPO_inLab50_folder,"fitRes_level.mat"));
        
        par=OPPO_inLab50_data.par;
        center(i_eth,:)=OPPO_inLab50_data.par(1,5:7);
        
        check_data2 = par(6) + (-30:0.2:30);
        check_data3 = par(7) + (-30:0.2:30);
        [data2, data3] = meshgrid(check_data2, check_data3);
        [row, col] = size(data2);
        
        % 计算等高线数据
        a = par;
        y = (1./(1+a(8)*exp(sqrt(a(2)*(data2-a(6)).^2+a(3)*(data3-a(7)).^2+ ...
            a(4)*(data2-a(6)).*(data3-a(7)))))).*((a(2)*(data2-a(6)).^2+ ...
            a(3)*(data3-a(7)).^2+a(4)*(data2-a(6)).*(data3-a(7)))>=0);

        res_matrix=[res_matrix;par(5:7)];
        res_cell{curr,1}=par(5:7);
        res_cell{curr,2}=lastPart_OPPO;
        curr=curr+1;
        % 绘制等高线
        % if strcmp(label_type,"include_this")||strcmp(label_type,"only_my")
            s0 = contour(data2, data3, y, [0.5, 1], 'LineWidth', 1, 'LineStyle','--',...
                 'Color', colors(i_indices,:));
            hold on;
            % lastPart_OPPO
            % 绘制特殊点
            plot(par(6), par(7), 'p', 'MarkerSize', 8, ...
                'MarkerFaceColor', colors(i_indices,:), 'Color', colors(i_indices,:));
        % end


        %-----------------------
        % scatter(scenes_OPPO(i_indices,2), scenes_OPPO(i_indices,3), 20, '^', 'LineWidth', 1, ...
        % 'MarkerEdgeColor',colors(i_indices,:));
    end
    scatter(labCh_PMCC(1,2), labCh_PMCC(1,3), 20, 's', 'LineWidth', 1, ...
    'MarkerEdgeColor','m','MarkerFaceColor','m');
    % title(ethnic_names(i_eth))
    % xlabel('\it a* \rm\fontsize{16}（无量纲）', 'Interpreter', 'tex', 'FontSize', 20);
    % ylabel('\it b* \rm\fontsize{16}（无量纲）', 'Interpreter', 'tex', 'FontSize', 20);

    ax = gca;
    targetFontSize=12;
    set(ax, 'FontSize', targetFontSize);
    if strcmp(interpreter_type,"tex")
        xlabel('a^*', 'Interpreter','tex','FontName','Arial', ...
            'FontAngle','italic', 'FontSize', 1.5*targetFontSize);
        ylabel('b^*', 'Interpreter','tex','FontName','Arial', ...
            'FontAngle','italic', 'FontSize', 1.5*targetFontSize);
    elseif strcmp(interpreter_type,"latex")
        xlabel('$a^*$', 'Interpreter','latex', 'FontSize', 1.5*targetFontSize);
        ylabel('$b^*$', 'Interpreter','latex','FontSize', 1.5*targetFontSize);
    end
    set(findobj(gcf, 'Type', 'Text'), 'FontSize', targetFontSize);
    img_name=fullfile(output_folder, ...
        strcat(ethnic_groups(i_eth),'.jpg'));    
    savefig(gcf, strrep(img_name,'jpg','fig'));

    exportgraphics(gcf,img_name ,'resolution',300);

end

concatenate_images1noSerial(output_folder,4);

%%


text_type="ch";
if strcmp(text_type,"eng")
    s.labels_row1 = {'indoor', 'night', 'outdoor', 'sunset'};
    s.labels_row2 = { 'this experiment','PMCC'};
    s.markers_row2 = { 'o','s'};
    s.markers_colors = [ 0 0 0; 1 0 1];
    s.markers_face_colors=[ 0 0 0; 1 0 1];
elseif strcmp(text_type,"ch")
    s.labels_row1 = {"室内", "夜景", "室外", "黄昏"};
    s.labels_row2 = {'实验二', '实验三','PMCC'};
    s.markers_row2 = {'p', 'o','s'};
    s.markers_colors = [0 0 0; 0 0 0; 1 0 1];
    s.markers_face_colors=[0 0 0; 0 0 0; 1 0 1];


end


s.sidePad=0.2;
s.if_label=0;
s.colors_row1 = colors;
s.marginL=0.25;
s.leg_x_shift=-0.1;
%----------------------
dir_figs=dir(fullfile(output_folder,"*.fig"));   
clear("figFiles");i_fig1=1;
for i_fig=1:length(dir_figs)
    figFiles{i_fig1}=dir_figs(i_fig).name;
    i_fig1=i_fig1+1;
end

legend_file="";
s.iconTextGap=0.04;
s.fontSizeScale=1.2;
s.tickFontScale=0.9;
concatenate_figs_legend1(output_folder, figFiles, 1,legend_file,"draw",s,0,0.9);


fullfile(pwd,output_folder)