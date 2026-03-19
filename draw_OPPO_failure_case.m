clear; close all;

targetFontSize = 12;
save_folder = fullfile("ellip_pic_p", "ellipse", "OPPO_failure_case");
if ~exist(save_folder, "dir")
    mkdir(save_folder);
end

Peggy_OPPO_folder="D:\work\project_code_backup\OPPOskinExpe\analyzeResult_scaled\AnalyseResults_p\display\abs\efit_p\resTable";
Peggy_OPPO_file=fullfile(Peggy_OPPO_folder,"Peggy_OPPO_table.mat");
Peggy_OPPO_data=load(Peggy_OPPO_file);
Peggy_OPPO_table=Peggy_OPPO_data.fit_table(1:52,:);

scenes=["inLab","indoorAdd","nightAdd","outdoorAdd","sunsetAdd"];

num_colors=length(scenes);
hue_values = linspace(0, 1, num_colors + 1);
hue_values = hue_values(1:end-1); 
hsv_matrix = [hue_values', 0.8 * ones(num_colors, 1), 0.8 * ones(num_colors, 1)];
colors = hsv2rgb(hsv_matrix);

for i_scene=1:length(scenes)
    lab_center{i_scene,1}=[];
    lab_center{i_scene,2}=scenes(i_scene);
end
for i_img=1:size(Peggy_OPPO_table,1)
    picname=Peggy_OPPO_table.scene{i_img};
    picname=char(picname);
    blank=find(picname==' ');
    prefix=picname(1:blank-1);

    for i_scene=1:length(scenes)
        if strcmp(prefix,scenes(i_scene))
            lab_center{i_scene,1}=[lab_center{i_scene,1};Peggy_OPPO_table.lab_center{i_img}];
            
        end
    end

end

for i_scene=1:length(scenes)
    cens_scene=lab_center{i_scene,1};
    cens_scene(:,4)=sqrt(cens_scene(:,2).^2+cens_scene(:,3).^2);
    cens_scene(:,5)=atan2d(cens_scene(:,3),cens_scene(:,2));
    lab_center{i_scene,1}=cens_scene;
end
targetFontSize=12;
limits{1}=[0,35,0,35];
limits{2}=[5,40,20,70];

%a-b
figure(1);
hold on;
for i_scene=1:length(scenes)

    cens_scene=lab_center{i_scene,1};
    for i_row = 1:length(cens_scene)
        lastPart=scenes{i_scene};
        if (i_scene==2&&ismember(i_row,5))||(i_scene==5&&ismember(i_row,[1,2,3]))
            plot_style="s";
        else
            plot_style="o";
        end
        color=colors(i_scene,:);
        plot(cens_scene(i_row, 2), cens_scene(i_row, 3), plot_style, ...
            'MarkerFaceColor', 'none', 'MarkerEdgeColor', color, ...
            'MarkerSize', 5, 'LineWidth', 1.5);        
    end


end
% 添加45°线
x = linspace(limits{1}(1),limits{1}(2), 1000);
y = x; 
plot(x, y, 'k--', 'LineWidth', 1);    
% title('$a^*-b^*$', 'Interpreter', 'latex', 'FontSize', targetFontSize);
xlabel('$a^*$', 'Interpreter', 'latex', 'FontSize', targetFontSize);
ylabel('$b^*$', 'Interpreter', 'latex', 'FontSize', targetFontSize);
ax = gca;
set(ax, 'FontSize', targetFontSize);
axis equal;
xlim([limits{1}(1),limits{1}(2)]);
ylim([limits{1}(3),limits{1}(4)]);
ax = gca;
set(ax, 'FontSize', targetFontSize);
set(findobj(gcf, 'Type', 'Text'), 'FontSize', targetFontSize); % 针对 LaTeX 标签
set(findobj(gcf, 'Type', 'Text'), 'FontSize', targetFontSize); % 针对 LaTeX 标签
img_name=fullfile(save_folder, strcat('a_b.jpg'));    
savefig(gcf, strrep(img_name,'jpg','fig'));
exportgraphics(gcf,img_name , 'Resolution', 150);






%L-C
figure(2);
hold on;
for i_scene=1:length(scenes)

    cens_scene=lab_center{i_scene,1};
    for i_row = 1:length(cens_scene)
        lastPart=scenes{i_scene};
        if (i_scene==2&&ismember(i_row,5))||(i_scene==5&&ismember(i_row,[1,2,3]))
            plot_style="s";
        else
            plot_style="o";
        end
        color=colors(i_scene,:);
        plot(cens_scene(i_row, 4), cens_scene(i_row, 1), plot_style, ...
            'MarkerFaceColor', 'none', 'MarkerEdgeColor', color, ...
            'MarkerSize', 5, 'LineWidth', 1.5);        
    end


end
% 添加45°线

% title('$a^*-b^*$', 'Interpreter', 'latex', 'FontSize', targetFontSize);
xlabel('$C^*_{ab}$', 'Interpreter', 'latex', 'FontSize', targetFontSize);
ylabel('$L^*$', 'Interpreter', 'latex', 'FontSize', targetFontSize);
ax = gca;
set(ax, 'FontSize',targetFontSize);
axis equal;
xlim([limits{2}(1),limits{2}(2)]);
ylim([limits{2}(3),limits{2}(4)]);
ax = gca;
set(ax, 'FontSize', targetFontSize);
set(findobj(gcf, 'Type', 'Text'), 'FontSize', targetFontSize); % 针对 LaTeX 标签
set(findobj(gcf, 'Type', 'Text'), 'FontSize', targetFontSize); % 针对 LaTeX 标签
img_name=fullfile(save_folder, strcat('L_C.jpg'));    
savefig(gcf, strrep(img_name,'jpg','fig'));
exportgraphics(gcf,img_name , 'Resolution', 150);

