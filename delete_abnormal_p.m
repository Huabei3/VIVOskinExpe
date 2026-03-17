clear;clc;close all;
%%
lastParts = {'f04i', 'f05i', 'f06i', 'm04i', 'm05i', 'm06i',...
'f01i', 'f02i', 'f03i', 'm01i', 'm02i', 'm03i',...
'f07i', 'f08i','m07i', 'm08i',...
'f09i', 'f10i','m09i', 'm10i'};n_para=21;iOr="i";

% lastParts = {'f04r', 'f05r', 'f06r', 'm04r', 'm05r', 'm06r',...
% 'f01r', 'f02r', 'f03r', 'm01r', 'm02r', 'm03r',...
% 'f07r', 'f08r','m07r', 'm08r',...
% 'f09r', 'f10r','m09r', 'm10r'};n_para=14;iOr="r";


if strcmp(iOr ,'i')
    picnames_groups = ["h3k","h4k","h5k","h6k","hd65","h7k","h8k", ...
                    "m3k","m4k","m5k","m6k","md65","m7k","m8k",...
                     "l3k","l4k","l5k","l6k","ld65","l7k","l8k"];
elseif strcmp(iOr,'r')
    picnames_groups = ["rs01","rs02","rs03","rs04","rs05","rs06","rs07", ...
                 "rs08","rs09","rs10","rs11","rs12","rs13","rs14"];
end

% Dtype='noCAT';
Dtype='efit_p';
scale_type_origin="unscaled";
attributes = [1, 2, 3, 4, 5, 6, 7,8, 9,10];
attribute_names_new = ["Preference", "Attractiveness", "Feminine", "Cooperative", ...
    "Youth", "Healthy", "Fidelity","Harmony", "Fair", "Ruddy"];
for i_lastPart = 17:20
% for i_lastPart = 1:length(lastParts)
    lastPart = lastParts{i_lastPart};
    for attribute = attributes
        attribute_serial = strcat(sprintf("%02d", attribute), attribute_names_new(attribute));
        labNscore_folder=fullfile("AnalyseResults_p\efit_p\unscaled",lastPart, ...
            "non_model",attribute_serial,"labNscore");    
        fitRes_folder=fullfile("AnalyseResults_p\efit_p\unscaled",lastPart, ...
                "non_model",attribute_serial,"ellipPara");
        fitRes_file=fullfile(fitRes_folder,"fitRes.mat");
        clear("par_all","parNr_all","picname_check","r_all");
        if ~exist(fitRes_file,"file")
            disp(strcat(fitRes_file," not exist"))
            continue
        end
        load(fitRes_file);
        abnormal=0;
        for i_para=1:n_para
            labNscore_file=fullfile(labNscore_folder, ...
                strcat("labNscore_group",lastPart,picnames_groups(i_para),".mat"));
            clear("p_group","lab_group")
            load(labNscore_file);
    

            p_ratio=sum(p_group>0.5)./length(p_group);
            if (p_ratio<0.1||p_ratio>0.9)
                abnormal=abnormal+1;
            end
            
            % if (p_ratio<0.1||p_ratio>0.9)
            %     par_all(i_para,:)=nan;
            %     parNr_all(i_para,:)=nan;
            %     r_all(i_para,:)=nan;
            % end

            figure("Visible","off");hold on;
            par = par_all(i_para, :);
            % 修改后的scatter代码 - 按照p_group确定颜色
            scatter(lab_group(p_group<0.5, 2), lab_group(p_group<0.5, 3), 10, p_group(p_group<0.5), "o", 'filled');
            scatter(lab_group(p_group>0.5, 2), lab_group(p_group>0.5, 3), 10, p_group(p_group>0.5), "+");
            % if all(par([1:3, 6]) == 0)
            %     % 如果 par_all3(i_para, [1:3, 6]) 都等于 0，只绘制菱形散点图
            %     scatter(par(4), par(5), 30, markers{source_idx}, 'filled', ...
            %         'MarkerFaceColor', colors(idx, :), 'MarkerEdgeColor', colors(idx, :));
            % else
                % 绘制 contour
                check_data2 = par(4) + (-30:0.2:30);
                check_data3 = par(5) + (-30:0.2:30);
                [data2, data3] = meshgrid(check_data2, check_data3);
                
                a = par;
                y = (1 ./ (1 + a(6) * exp(sqrt(a(1) * (data2 - a(4)).^2 + a(2) * (data3 - a(5)).^2 + ...
                    a(3) * (data2 - a(4)) .* (data3 - a(5)))))) .* ((a(1) * (data2 - a(4)).^2 + ...
                    a(2) * (data3 - a(5)).^2 + a(3) * (data2 - a(4)) .* (data3 - a(5))) >= 0);
                
                contour(data2, data3, y, [0.5, 1], 'Linewidth', 1, ...
                    'Color', 'r', 'LineStyle', '-'); 
                
                
                % 绘制 scatter 和 plot
                scatter(par(4), par(5), 30, 'v', 'filled', ...
                    'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'r');


            xlim([-10, 30]);
            ylim([-10, 30]);
        
            % 添加标签和标题
            xlabel('{\ita*}');
            ylabel('{\itb*}');
            title(strcat(picname_group));
        
            
            % 保存图像
            plot_folder=strrep(fitRes_folder,"ellipPara","plot_abnormal");
            if ~exist(plot_folder,"dir")
                mkdir(plot_folder)
            end
            exportgraphics(gcf, fullfile(plot_folder, strcat(picname_group, ".jpg")), 'Resolution', 300);
            close(gcf); % 关闭当前图窗

        end
        concatenate_images1(plot_folder,7);
        ratio_abnormal{i_lastPart,1}=lastPart;
        ratio_abnormal{i_lastPart,attribute+1}=abnormal/n_para;

        num_abnormal{i_lastPart,1}=lastPart;
        num_abnormal{i_lastPart,attribute+1}=abnormal;
        % save(fitRes_file,"par_all","parNr_all","picname_check","r_all");
    end
end


%%
for i_lastPart = 17:20
% for i_lastPart = 1:length(lastParts)
    lastPart = lastParts{i_lastPart};
    for attribute = attributes
        attribute_serial = strcat(sprintf("%02d", attribute), attribute_names_new(attribute));
        
        plot_abnormal_folder=fullfile("AnalyseResults_p\efit_p\unscaled",lastPart, ...
            "non_model",attribute_serial,"plot_abnormal","concatenated");
        old_file=fullfile(plot_abnormal_folder,"bigImg.jpg");
        disp("big")
        if exist(old_file,"file")
            disp("d")
            new_folder="AnalyseResults_p\efit_p\unscaled\plot_abnormal";
            if ~exist(new_folder,"dir")
                mkdir(new_folder)
            end
            new_file=fullfile(new_folder,strcat(lastPart,attribute_serial,".jpg"));
            copyfile(old_file,new_file);
        end
    end
end


