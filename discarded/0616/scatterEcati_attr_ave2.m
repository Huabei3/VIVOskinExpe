close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量

%% 定义所有需要处理的 attribute
attributes = [1, 2, 3, 4, 5, 6,7, 8, 9,10];
attribute_names_new = ["Preference", "Attractiveness", "Feminine", "Cooperative", ...
    "Youth", "Healthy", "Fidelity","Harmony", "Fair", "Ruddy"];
picname_group=["h3k","h4k","h5k","h6k","h7k","h8k","hd65",...
    "m3k","m4k","m5k","m6k","m7k","m8k","md65",...
    "l3k","l4k","l5k","l6k","l7k","l8k","ld65"];
    wd65_64 = [94.811, 100.00, 107.304];
CT = [3000, 4000, 5000, 6000, 7000, 8000, 6500, ...
      3000, 4000, 5000, 6000, 7000, 8000, 6500, ...
      3000, 4000, 5000, 6000, 7000, 8000, 6500]';
line_style={'-',':','-.'};
plot_style={'^','<','v'};
% 定义色环上的 7 种颜色
colors = hsv(10); % 使用 hsv 色图生成 7 种颜色
nations=["AS","CA","SA","AF"];
% lastParts = {'f04r', 'f05r', 'f06r', ...
% 'm04r', 'm05r', 'm06r'};
lastParts = {'f04i', 'f05i', 'f06i', ...
'm04i', 'm05i', 'm06i'};
% lastParts = {'f04iadd', 'f05iadd', 'f06iadd', ...
% 'm04iadd', 'm05iadd', 'm06iadd'};

nation=nations(1);
if contains(lastParts{1},'i')
    iOr='i';n_para=21;i_target=5;
elseif contains(lastParts{1},'r')
    iOr='r';n_para=14;i_target=15;
end
obs_type="non_model";
% lastParts = {'female78i', 'female41i', 'femalevivoi', 'male59i', 'male39i', 'malevivoi'};
gender=['f','m'];
Dtype='VIVO_CAT16';

%%

cm700d = readcell('combined_data1.xlsx'); % 使用 readcell 读取数据，不自动解析表头
cm700d_res = {}; % 初始化结果 cell 数组
% 初始化变量
current_model = '';
mean_row = [];
% 遍历数据
for i = 1:size(cm700d, 1)
    row = cm700d(i, :); % 当前行数据
    cell_data = row{1}; % 当前行的第一个单元格内容
    if ischar(cell_data) && (startsWith(cell_data, 'f0') || startsWith(cell_data, 'm0')) && ~strcmp(cell_data, 'mean')
        current_model = cell_data;
    elseif strcmp(cell_data, 'mean') && ~isempty(current_model)
        cm700d_res{end+1, 1} = current_model; % model 名称
        cm700d_res{end, 2} = str2double(row{2});
        cm700d_res{end, 3} = str2double(row{3});
        cm700d_res{end, 4} = str2double(row{4}); % 对应的 mean 值
    end
end

lab_cm700d1=cm700d_res([4:6,14:16],:);
lab_cm700d_f=cell2mat(lab_cm700d1(1:3,2:4));
lab_cm700d_m=cell2mat(lab_cm700d1(4:5,2:4));
lab_cm700d=[mean(lab_cm700d_f,1);mean(lab_cm700d_m,1)];
%%
for lastPart_idx = 1:length(lastParts)
    lastPart = lastParts{lastPart_idx};
    
    save_folder = fullfile("ellip_pic\ellipse1",  Dtype,strcat(nation,iOr,obs_type), ...
        "attr_fNm");
    
    % 创建保存文件夹
    if ~exist(save_folder, "dir")
        mkdir(save_folder);
    end
    
    lab_PMCC = [62.11, 18.96, 19.76];
    labC_PMCC = [lab_PMCC, sqrt(lab_PMCC(1, 2)^2 + lab_PMCC(1, 3)^2)];
    
    model = lastPart(1:end-1);
    [lastPart1, model1] = gen_lastPart1(lastPart);
    lastPart_new=gen_lastPart_new(lastPart1);
    disp([lastPart,lastPart_new])
    average_file = strcat("aveSkin\", strrep(lastPart_new,"add",""), "\autoNhand_scaleoverLUT.mat");
    average_data = load(average_file);
    average_inds(:,:,lastPart_idx) = average_data.average_lab_all(:, 1:3);


    %% 循环处理每个 attribute
    % for attribute = [10]
    for attribute = attributes
        fprintf('Processing attribute: %d\n', attribute);
        attribute_serial = strcat(sprintf("%02d", attribute), attribute_names_new(attribute));
        
        % 定义路径
        source_file1 = fullfile('AnalyseResults1', Dtype,lastPart,obs_type ,attribute_serial, 'ellipPara', 'fitRes.mat');

        
        % 加载数据
        par_all=[];
        if exist(source_file1, 'file') % 新增 source_file1 的加载
            parData=load(source_file1);
            par_all = parData.par_all;
        else
            par_all(1:n_para,1:6)=NaN;
        end
        par_inds(:,:,lastPart_idx,attribute)=par_all;
    end
end
range{1}=1:3;
range{2}=4:6;
for i_gender=1:2
    average{i_gender}=nanmean(average_inds(:,:,range{i_gender}),3);    
    par_all4{i_gender}=nanmean(par_inds(:,:,range{i_gender},:),3);    
end
for i_gender=1:2
    average{i_gender}=[average{i_gender};mean(average{i_gender},1)];
    par_all4{i_gender}=[par_all4{i_gender};mean(par_all4{i_gender},1)];
end

lim_min_x=inf;lim_min_y=inf;lim_max_x=-inf;lim_max_y=-inf;
for i_gender=1:2
    lim_min_x=min(lim_min_x,min(min(min(par_all4{i_gender}(5,4,:,:)))));
    lim_max_x=max(lim_max_x,max(max(max(par_all4{i_gender}(5,4,:,:)))));
    lim_min_y=min(lim_min_y,min(min(min(par_all4{i_gender}(5,5,:,:)))))-1;
    lim_max_y=max(lim_max_y,max(max(max(par_all4{i_gender}(5,5,:,:)))))-1;
end
lim_min_x=min(lim_min_x,min(lab_cm700d(:,2)))-1;
lim_max_x=max(lim_max_x,max(lab_cm700d(:,2)))+1;
lim_min_y=min(lim_min_y,min(lab_cm700d(:,3)))-1;
lim_max_y=max(lim_max_y,max(lab_cm700d(:,3)))+1;
for i_gender=1:2
    figure;
    hold on;
    set(gcf, 'Color', 'white');
    for attribute = attributes
        fprintf('Processing attribute: %d\n', attribute);
        attribute_serial = strcat(sprintf("%02d", attribute), attribute_names_new(attribute));
            % 循环处理当前 light_level 的 i_para
            for i_para = [i_target]
    
                % 计算 labC_PMCCpre
                if average{i_gender}(i_para, 1) <= 60
                    C_pre(i_para, 1) = 6.7421 * log(average{i_gender}(i_para, 1)) - 9.9816; % 亮度实验
                else
                    C_pre(i_para, 1) = 6.7421 * log(60) - 9.9816; % 亮度实验
                end
                labC_PMCCpre(i_para, 1) = average{i_gender}(i_para, 1);
                labC_PMCCpre(i_para, 2:3) = lab_PMCC(1, 2:3) ./ labC_PMCC(1, 4) .* C_pre(i_para, 1);
                labC_PMCCpre(i_para, 4) = C_pre(i_para, 1);
                % 绘制 source_file1 的 contour 或散点图 (新增部分)
                hold on;
                if exist('par_all4', 'var')&&~isempty(par_all4{i_gender})
                    par = par_all4{i_gender}(i_para, :,attribute);                
                    scatter(par(4), par(5), 30, 'o','filled', ...
                        'MarkerFaceColor', colors(attribute, :));
                    attribute_char=char(attribute_serial);
                    text(par(4), par(5), ...
                        attribute_char(1:2), 'FontSize', 7, ...
                        'VerticalAlignment', 'middle');
                end
                plot(labC_PMCCpre(i_para, 2), labC_PMCCpre(i_para, 3), 's', 'MarkerSize', 10, ...
                    'MarkerFaceColor', 'm', 'MarkerEdgeColor', 'm');

            end        


    end
    plot(lab_cm700d(i_gender, 2), lab_cm700d(i_gender, 3), 'p', 'MarkerSize', 10, ...
    'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'b');
    % 添加图例、标签和标题
    xlabel('{\ita*}');
    ylabel('{\itb*}');
    
    lastPart_new=gen_lastPart_new(lastPart);
    title(strcat(gender(i_gender),"a-b"));
    
    % 设置坐标轴范围
    x = linspace(0, 25, 100); % 从 -10 到 10，生成 100 个点
    plot(x, x); % 'r-' 表示红色实线
    axis equal;
    xlim([lim_min_x, lim_max_x]);
    ylim([lim_min_y, lim_max_y]);
    
    
    
    % 保存图像
    if ~exist(fullfile(save_folder), "dir")
        mkdir(fullfile(save_folder));
    end
    
    exportgraphics(gcf, fullfile(save_folder, strcat(gender(i_gender), 'scatterEcat_attr_a_b.jpg')), 'Resolution', 300);
    % close(gcf);
end
concatenate_images1(save_folder ,2);
