function cal_nation_D(par_all, average, save_folder,XYZ_light,picname_group,CT)
    addpath("utils\")
    % 确保保存文件夹存在
    if ~exist(save_folder, 'dir')
        mkdir(save_folder);
    end
 
    % 主处理循环
    for attribute = [1]
        par = par_all(:, :,1,attribute);
        lab_fit=[average(:,1),par(:,4),par(:,5)];
        lab_D65=lab_fit(5,:);
        XYZ_bf=lab2xyz2(lab_fit,'d65_64');

        % 初始化结果数组
        D_optimal = zeros(size(par,1), 1);
        Labt = zeros(size(par,1), 3);
        
        
        for i_para=1:size(par,1)
            if i_para<=7
                i_target=5;
            elseif i_para<=14
                i_target=12;
            else
                i_target=19;
            end
            Labtarget=lab_fit(i_target,:);
            XYZw_target=XYZ_light(i_target,:)./XYZ_light(i_target,2).*100;

            XYZw(i_para,:)=XYZ_light(i_para,:)./XYZ_light(i_para,2).*100;
            D_optimal(i_para,1) = optimize_D(XYZ_bf(i_para,:), ...
                XYZw(i_para,:), XYZw_target, Labtarget);
            XYZt = CAT16_D(XYZ_bf(i_para,:), XYZw(i_para,:), XYZw_target, D_optimal(i_para,1));
            Labt(i_para,:) = xyz2lab(XYZt, 'd65_64');

            figure()
            hold on;
            scatter(par(i_para,4), par(i_para,5),  50, 'o', 'filled');
            scatter(Labt(i_para,2), Labt(i_para,3),  50, '^', 'filled');
            scatter(Labtarget(2), Labtarget(3), 80, 'p', 'filled');
            axis equal;      

            D = linspace(0,1,1000);
            XYZ_aft = zeros(length(D), 3);
            for i_D=1:length(D)
                XYZ_aft(i_D,:) = CAT16_D(XYZ_bf(i_para,:), XYZw(i_para,:), XYZw_target, D(i_D));
            end
            lab_aft=xyz2lab(XYZ_aft,'d65_64');
            plot(lab_aft(:,2),lab_aft(:,3));
            scatter(lab_aft(1,2),lab_aft(1,3));

            title(picname_group(i_para));
            exportgraphics(gcf, fullfile(save_folder, ...
                strcat(picname_group(i_para),  '.jpg')), 'Resolution', 150);
            close(gcf);
        end
        
        D_CCT=[D_optimal,CT];
        % 添加图例、标签和标题
        xlabel('{\ita*}');
        ylabel('{\itb*}');
        title(strcat('a-b'));

        % 设置坐标轴范围
        x = linspace(0, 25, 100);
        plot(x, x);
        axis equal;      

        attribute_serial = strcat(sprintf("%02d", attribute));
        if ~exist(fullfile(save_folder, 'a_b'),"dir")
            mkdir(fullfile(save_folder, 'a_b'));
        end
        exportgraphics(gcf, fullfile(save_folder, 'a_b',strcat(attribute_serial,  'a-b.jpg')), 'Resolution', 300);
        close(gcf);           
    end
    
    concatenate_images1(fullfile(save_folder, 'a_b') ,5);

    % 后续分析部分
    lab_used=Labt;
    lim_min_x=min(lab_used(:,2));
    lim_max_x=max(lab_used(:,2));
    lim_min_y=min(lab_used(:,3));
    lim_max_y=max(lab_used(:,3));
    
    figure();
    hold on;
    colors_light=hsv(7);
    for i_para=1:size(lab_fit,1)
        text(Labt(i_para,2),Labt(i_para,3), picname_group(i_para), ...
        'FontSize', 8, 'VerticalAlignment', 'middle', ...
        'Color',colors_light(mod((i_para-1),7)+1,:));
    end
    
    x = linspace(0, 25, 100);
    plot(x, x);
    axis equal;      
    xlim([lim_min_x, lim_max_x]);
    ylim([lim_min_y, lim_max_y]);
    exportgraphics(gcf, fullfile(save_folder, strcat('CT.jpg')), 'Resolution', 300);
    close(gcf)
    
    %%
    % D和倒数色温关系分析
    D_CCT=[D_optimal,CT];
    figure()
    hold on

    D_CCT_del=D_CCT;
    D_CCT_del(D_CCT_del(:,1)<0.001|D_CCT_del(:,1)>0.99,:)=[];
    [par_l, r_l, y_l] = linearSplineModel(D_CCT_del);
    
    % 计算不同模型的D值
    [~,duv,~]=xyz2CCT(XYZw,10);
    duv=duv';
    load(fullfile("optmizedD\backGroundGray\XYZ_gray.mat"),"xyz_gray");
    E=mean(xyz_gray(1:7,2));

    x=2000:10:8000;x=x';
    D_3spl = zeros(length(x), 1);
    D_cherry = zeros(length(x), 1);
    D_zhai = zeros(length(x), 1);
    D_summer = zeros(length(x), 1);
    
    for i_row=1:length(x)
        D_3spl(i_row,:) = calculateD_par(x(i_row,:), 0, "VIVO_spl",E,par_l);
        D_cherry(i_row,:) = calculateD(x(i_row,:), 0, "cherry",E);
        D_zhai(i_row,:) = calculateD(x(i_row,:), 0, "zhai",E);
        D_summer(i_row,:) = calculateD(x(i_row,:), 0, "summer",E);
    end
    
    colors=hsv(7);
    plot(x,D_3spl,'Color',colors(1,:));
    plot(x,D_cherry,'Color',colors(2,:));
    plot(x,D_zhai,'Color',colors(3,:));
    plot(x,D_summer,'Color',colors(4,:));
    shapes={'p','s','^'};
    hold on;
    for i_para=1:length(D_CCT)
        i_shape=floor((i_para-1)/7)+1;
        color_idx=mod(i_para,7)+1;
        plot(D_CCT(i_para,2),D_CCT(i_para,1),shapes{i_shape}, ...
            'MarkerFaceColor', colors(color_idx, :), ...
                'MarkerEdgeColor', colors(color_idx, :));
    end

    % 保存结果
    save(fullfile(save_folder,strcat("D_3spl.mat")),"par_l","y_l","r_l");
    exportgraphics(gcf,fullfile(save_folder,strcat(strcat('D_3spl.jpg'))), ...
        "Resolution",150);
    close(gcf)
end