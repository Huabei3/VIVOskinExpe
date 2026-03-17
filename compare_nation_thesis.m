close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量

%%



Dtype="efit_p";

prev_folder=fullfile("ellip_pic_p",Dtype,"compare_thesis_pre");
load(fullfile(prev_folder,"author_colors.mat"),"author_all","prev_cell");

length_color=size(prev_cell,1);
hue_values = linspace(0, 1, length_color + 1);hue_values = hue_values(1:end-1);
hsv_matrix = [hue_values', 0.8 * ones(length_color, 1), 0.8 * ones(length_color, 1)];
colors = hsv2rgb(hsv_matrix);

lab_cherry=[65.50 	17.21 	17.72 ];
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

labCh_PMCC=[[62.11	18.96	19.76	27.39	46.18];...
            [64.15	19.56	19.63	27.71	45.10];...
            [56.01	18.25	18.72	26.14	45.72];...
            [41.06	17.37	17.94	24.97	45.93]];
if strcmp(Dtype,"efit_p_free")
    ellip_pic_folder="ellip_pic_p_free";
elseif strcmp(Dtype,"efit_p")
    ellip_pic_folder="ellip_pic_p";
end
output_folder=fullfile(ellip_pic_folder,Dtype,"compare_nation_thesis");

if ~exist(output_folder,"dir")
    mkdir(output_folder);
end

ethnic_names=["Asian","Caucasian","South Asian","African"];
ethnic_groups=["1AS","2CA","3SA","4AF"];
for i_eth=1:size(ethnic_groups,2)
    figure(i_eth);
    grid on;box on;
    hold on;
    if strcmp(Dtype,"efit_p_free")
        AnalyseResults_folder="AnalyseResults_p_free";
    elseif strcmp(Dtype,"efit_p")
        AnalyseResults_folder="AnalyseResults_p";
    end
    fitRes_file=fullfile(AnalyseResults_folder,Dtype,"50\unscaled\nation1\scaled\" + ...
        "non_model\i\01Preference",ethnic_groups(i_eth),"1.mat");
    fitRes_data=load(fitRes_file);
    par=fitRes_data.par;
    center(i_eth,:)=[fitRes_data.average_indices_curr(1,1),fitRes_data.par(1,4:5)];
    
    check_data2 = par(4) + (-30:0.2:30);
    check_data3 = par(5) + (-30:0.2:30);
    [data2, data3] = meshgrid(check_data2, check_data3);
    [row, col] = size(data2);
    color=[0 0 0];
    % 计算等高线数据
    a = par;
    y = (1./(1+a(6)*exp(sqrt(a(1)*(data2-a(4)).^2+a(2)*(data3-a(5)).^2+ ...
        a(3)*(data2-a(4)).*(data3-a(5)))))).*((a(1)*(data2-a(4)).^2+ ...
        a(2)*(data3-a(5)).^2+a(3)*(data2-a(4)).*(data3-a(5)))>=0);
    
    % 绘制等高线
    s0 = contour(data2, data3, y, [0.5, 1], 'LineWidth', 1, ...
         'Color', color);
    hold on;
    % 绘制特殊点
    plot(par(4), par(5), 'o', 'MarkerSize', 4, ...
        'MarkerFaceColor', color, 'Color', color);
    if i_eth==1
    cens(3,:)=par(1,4:5);
    end
    
    
    axis equal
    min_lim=0;
    max_lim=45;
    xlim([min_lim,max_lim])
    ylim([min_lim,max_lim])
    x = linspace(min_lim, max_lim, 1000);
    y = x;
    plot(x, y);
    for i_prev=1:size(prev_cell,1)
        if size(prev_cell{i_prev,1},1)<i_eth
            continue
        end
        lab_pre=prev_cell{i_prev,1}(i_eth,:);

        if lab_pre(1,2)~=0
            author_str=char(prev_cell{i_prev,2});  
            author_str_used=author_str(1);            

            text(lab_pre(1, 2), lab_pre(1, 3), ...
             author_str_used, 'FontSize', 8, ...
             'VerticalAlignment', 'top', 'Color', colors(i_prev,:), ...
             'FontWeight', 'bold');  % 新增字体加粗参数
        end
    end

    scatter(labCh_PMCC(i_eth,2), labCh_PMCC(i_eth,3), 20, 's', 'LineWidth', 1, ...
    'MarkerEdgeColor','m','MarkerFaceColor','m');

    if i_eth==1
        OPPO_inLab50_folder="D:\work\project_code_backup\OPPOskinExpe\analyzeResult_scaled\" + ...
            "AnalyseResults_p\display\rela\efit_p\scene\inLab\ellipPara_scaled";
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
        
        cens(2,:)=par(1,6:7);
        % 绘制等高线
        color=[0 0 0];
        s0 = contour(data2, data3, y, [0.5, 1], 'LineWidth', 1, 'LineStyle','--',...
             'Color', color);
        hold on;
        % 绘制特殊点
        plot(par(6), par(7), 'p', 'MarkerSize', 10, ...
            'MarkerFaceColor', color, 'Color', color);

        %-----------------------------------------------
        Dtype="efit_p";
        L_exp_folder="D:\work\FirstYearMaster\SkinColorPreferenceScale\AnalyseResults_p\efit_p\scaled\fitRes";
        
        data_L_exp=load(fullfile(L_exp_folder,"fitRes_level_p.mat"));
        n_para=size(data_L_exp.par_all,1);
        for i_level=6
        % for i_level=1:n_para
            par=data_L_exp.par_all(i_level,:);
            cens(1,:)=mean(data_L_exp.par_all(:,4:5),1);
        
            % 计算等高线数据
            a = par;
            y = (1./(1+a(6)*exp(sqrt(a(1)*(data2-a(4)).^2+a(2)*(data3-a(5)).^2+ ...
                a(3)*(data2-a(4)).*(data3-a(5)))))).*((a(1)*(data2-a(4)).^2+ ...
                a(2)*(data3-a(5)).^2+a(3)*(data2-a(4)).*(data3-a(5)))>=0);
            
            % 绘制等高线
            s0 = contour(data2, data3, y, [0.5, 1], 'LineWidth', 1,'LineStyle',':', ...
                 'Color', color);
            hold on;
            % 绘制特殊点
            plot(par(4), par(5), 'x', 'MarkerSize', 4, ...
                'MarkerFaceColor', color, 'Color', color);


        end
    end
    xlabel('\it a* \rm\fontsize{16}（无量纲）', 'Interpreter', 'tex', 'FontSize', 20);
    ylabel('\it b* \rm\fontsize{16}（无量纲）', 'Interpreter', 'tex', 'FontSize', 20);
    exportgraphics(gcf, fullfile(output_folder, ...
        strcat(ethnic_groups(i_eth),'.jpg')),'resolution',300);

end

concatenate_images1(output_folder,4);

