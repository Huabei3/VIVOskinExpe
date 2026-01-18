close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量

%% 初始化参数
% Dtype = "OPPO_CAT16";
Dtype = "efit_p";
if strcmp(Dtype,"efit_p")
    sourceFolder='AnalyseResults_p\abs';
else
    sourceFolder='AnalyseResults';
end
load('documents\group_Lab_withrecenNgray.mat',"cellMatrix");
save_folder = fullfile(sourceFolder, Dtype, "self");
self_data = load(fullfile(save_folder, "fitRes_self.mat"));
load("OPPOskin\matchTable.mat","match_table");
mean_center_all = self_data.mean_center_all;
lastParts = ["inLab", "indoorAdd", "nightAdd", "outdoorAdd", "sunsetAdd"];
escape = ["indoor05", "sunset01", "sunset02", "sunset03", "sunset08"];

par_other = []; 
picname_cor_other = []; 
ave_mean_all = []; 
lab_group_others = [];
center_self = []; 

for i_lastPart = 1:length(lastParts)
    lastPart = lastParts(i_lastPart);
    source_folder = fullfile(sourceFolder, Dtype, lastPart, 'ellipPara_scaled');
    source_file = fullfile(source_folder, "fitRes_level.mat");
    selfCens = load(source_file);
    
    % 提取 ave
    n_render = 49;
    rows_used = 1:n_render:size(selfCens.lab_group_all, 1);
    lab_group_others = [lab_group_others; selfCens.lab_group_all];
    ave = selfCens.lab_group_all(rows_used, :);
    ave_mean = mean(ave(:, 1));
    picname_check = selfCens.picname_check(:, 1);
    par_ind = selfCens.par_ind;    
    
    wd65 = [94.811, 100.00, 107.304];
    lab_PMCC = [62.11, 18.96, 19.76];
    
    for i_para = 1:size(par_ind, 1)
        % 分类保存
        for i_match = 1:size(mean_center_all, 1)
            if strcmp(picname_check{i_para, 1}, mean_center_all{i_match, 1})
                par_other = [par_other; par_ind(i_para, :)];
                picname_cor_other = [picname_cor_other; string(picname_check{i_para, 1})];
                ave_mean_all = [ave_mean_all; ave_mean];
                center_self = [center_self; mean_center_all{i_match, 2}];
            end
        end

    end

end

% 创建输出文件夹
output_folder = fullfile(save_folder, 'ellipsoid_sections');
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end
%加载原图lab
for i_para = 1:size(par_other, 1)
    for i_match=1:size(cellMatrix,1)
        picname_curr=strrep(picname_cor_other(i_para),"zrecen","");
        if strcmp(picname_curr,cellMatrix{i_match,2})
            lab_ori(i_para,:)=cellMatrix{i_match,1}(end,:);
            break
        end
    end
    
end
% del_row=par_other(:,5)<36;
% par_other(del_row,:)=[];
% center_self(del_row,:)=[];
% picname_cor_other(del_row,:)=[];
% lab_ori(del_row,:)=[];
%% 创建三维图形
% figure;
% hold on;
% view(3); % 设置三维视角
% 
% % 循环绘制每个点和线段
% for i_para = 1:size(par_other, 1)
%     scatter3(par_other(i_para, 6), par_other(i_para, 7), par_other(i_para, 5),30, 'filled', ...
%         'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'b');    
%     scatter3(center_self(i_para, 2), center_self(i_para, 3),center_self(i_para, 1), 30, 'filled', ...
%     'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'r');  
%     scatter3(lab_ori(i_para, 2), lab_ori(i_para, 3), lab_ori(i_para, 1),30, 'filled', ...
%         'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k');
% 
%     % % 绘制线段（从 par_other 到 lab_ori）
%     % plot3([par_other(i_para, 6), center_self(i_para, 2)], ...
%     %       [par_other(i_para, 7), center_self(i_para, 3)], ...
%     %       [par_other(i_para, 5), center_self(i_para, 1)], ...
%     %       'Color', 'b', 'LineWidth', 1);
%     %     % 绘制线段（从 par_other 到 lab_ori）
%     % plot3([center_self(i_para, 2), lab_ori(i_para, 2)], ...
%     %       [center_self(i_para, 3), lab_ori(i_para, 3)], ...
%     %       [center_self(i_para, 1), lab_ori(i_para, 1)], ...
%     %       'Color', 'r', 'LineWidth', 1);
%     dE{i_para,1}=picname_cor_other(i_para);
%     dE{i_para,2}=deltaE2000(center_self(i_para, :),lab_ori(i_para, :));
%     dE{i_para,3}=deltaE2000(par_other(i_para, 5:7),lab_ori(i_para, :));
% end
% 
% % 添加标签和标题
% xlabel('\textit{a*}', 'Interpreter', 'latex','FontSize', 12*2);
% ylabel('\textit{b*}', 'Interpreter', 'latex','FontSize', 12*2);
% zlabel('\textit{L*}', 'Interpreter', 'latex','FontSize', 12*2);
% grid on;
% 
% % 保存图像
% exportgraphics(gcf, fullfile(output_folder, "self_other3d.jpg"), "Resolution", 150); 

%% 创建二维图形
figure;
hold on;
view(2); % 设置二维视角

% 循环绘制每个点和线段
for i_para = 1:size(par_other, 1)
    scatter(par_other(i_para, 6), par_other(i_para, 7), 30, 'filled', ...
        'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'b');
    scatter(center_self(i_para, 2), center_self(i_para, 3), 30, 'filled', ...
    'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'r');
    scatter(lab_ori(i_para, 2), lab_ori(i_para, 3), 30, 'filled', ...
        'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k');

    % text(par_other(i_para, 6)-0.1, par_other(i_para, 7), num2str(i_para), ...
    %     'Color', 'b', 'FontSize', 8); 
    % text(center_self(i_para, 2)-0.1, center_self(i_para, 3), num2str(i_para), ...
    %     'Color', 'r', 'FontSize', 8); 
    % text(par_other(i_para, 6)-0.1, par_other(i_para, 7), num2str(i_para), ...
    %     'Color', 'k', 'FontSize', 8); 
    % %           
    % plot([par_other(i_para, 6), center_self(i_para, 2)], ...
    %      [par_other(i_para, 7), center_self(i_para, 3)], ...
    %      'Color', 'b', 'LineWidth', 1);
    % plot([center_self(i_para, 2), lab_ori(i_para, 2)], ...
    %  [center_self(i_para, 3), lab_ori(i_para, 3)], ...
    %  'Color', 'r', 'LineWidth', 1);
end

min_lim=0;max_lim=40;
x = [min_lim, max_lim]; 
y = x;      
plot(x, y,  'LineWidth', 0.5); 
xlabel('\textit{$a^*$}', 'Interpreter', 'latex','FontSize', 12*2);
ylabel('\textit{$b^*$}', 'Interpreter', 'latex','FontSize', 12*2);

axis equal;
xticks([min_lim:5: max_lim]);
yticks([min_lim:5: max_lim]);
xlim([min_lim, max_lim]);
ylim([min_lim, max_lim]);
grid on;

% 保存图像
exportgraphics(gcf, fullfile(output_folder, "self_other2d.jpg"), "Resolution", 150); 


% concatenate_images2(output_folder,1);



