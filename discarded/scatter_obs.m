close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量
%% 定义所有需要处理的 attribute
attributes = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

attribute_names = ["Preference", "Attractiveness", "Feminine", "Cooperative", ...
    "Youth", "Healthy", "Fidelity", "Harmony", "Fair", "Ruddy"];
nations = ["AS", "CA", "SA", "AF"];
nation_names = ["Asian", "Caucasian", "South Asian", "African"];

lastParts = {'f04i', 'f05i', 'f06i', 'm04i', 'm05i', 'm06i',...
'f01i', 'f02i', 'f03i', 'm01i', 'm02i', 'm03i',...
'f07i', 'f08i','m07i', 'm08i',...
'f09i', 'f10i','m09i', 'm10i'};n_para = 21;iOr='i';

% lastParts = {'f04r', 'f05r', 'f06r', 'm04r', 'm05r', 'm06r',...
% 'f01r', 'f02r', 'f03r', 'm01r', 'm02r', 'm03r',...
% 'f07r', 'f08r','m07r', 'm08r',...
% 'f09r', 'f10r','m09r', 'm10r'};n_para = 14;iOr='r';

if iOr =='i'
    picnames_groups = ["h3k","h4k","h5k","h6k","hd65","h7k","h8k",...
                    "m3k","m4k","m5k","m6k","md65","m7k","m8k",...
                     "l3k","l4k","l5k","l6k","ld65","l7k","l8k"];
elseif iOr=='r'
    picnames_groups = ["rs01","rs02","rs03","rs04","rs05","rs06","rs07", ...
             "rs08","rs09","rs10","rs11","rs12","rs13","rs14"];
end
lightness_type="abs";

load("documents\valid_attr.mat","map");


wd65 = [94.811, 100.00, 107.304];
datai_file = 'D:\work\VIVOskinExpe\renderCode\calibResults\datai_ipv18_3.mat';
LUT=load(datai_file);
XYZw_LUT=LUT.XYZw;
line_style = {'-',':','-.'};
plot_style = {'v','^'};

genders = ["f", "m"]; % 定义性别数组
% 生成色相值（H），范围从0到1
hue_values = linspace(0, 1, length(nations) + 1);hue_values = hue_values(1:end-1); 
hsv_matrix = [hue_values', 0.8 * ones(length(nations), 1), 0.8 * ones(length(nations), 1)];
colors = hsv2rgb(hsv_matrix);


obs_types = ["non_model", "model_group","model"];
% 定义人种对应的lastParts索引
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



if iOr == 'i'
    indices_target = [1:21];
    picnames_groups = ["h3k","h4k","h5k","h6k","hd65","h7k","h8k",...
                    "m3k","m4k","m5k","m6k","md65","m7k","m8k",...
                     "l3k","l4k","l5k","l6k","ld65","l7k","l8k"];
    load('optimizedD\neutral_gray\combi_XYZw_i.mat', 'XYZ_combi',"CCT_combi");
    CT = CCT_combi;
    XYZwpre=XYZ_combi;
else
    indices_target = 1:14;   
    picnames_groups = ["rs01","rs02","rs03","rs04","rs05","rs06","rs07", ...
                     "rs08","rs09","rs10","rs11","rs12","rs13","rs14"];        
    load(fullfile("..\renderCode\light_r\model_light_mean",strcat(model,".mat")), ...
        "model_tcp_mean","XYZwpre_mea");
    CT = model_tcp_mean;
    XYZwpre=XYZwpre_mea;
end
% 初始化重塑后的数据结构
average_reshaped = cell(5, 1); % 5个人种
par_reshaped = cell(3, 5, 1);  % 3种观察者类型 × 5个人种
lab_fit_reshaped = cell(3, 5, 1); % 3种观察者类型 × 5个人种
labCh_PMCC=[[62.11	18.96	19.76	27.39	46.18];...
            [64.15	19.56	19.63	27.71	45.10];...
            [56.01	18.25	18.72	26.14	45.72];...
            [41.06	17.37	17.94	24.97	45.93]];
labCh_PMCC(end+1,:)=mean(labCh_PMCC,1);
file_missing={};
Dtype = 'efit2';

% 定义一个函数来分离性别索引
function gender_indices = separate_genders(n_subjects, curr_nation_indices, lastParts)
    gender_indices = cell(2, 1); % f和m的索引
    for i_subject = 1:n_subjects
        subject_idx = curr_nation_indices(i_subject);
        lastPart = lastParts{subject_idx};
        if lastPart(1) == 'f'
            gender_indices{1} = [gender_indices{1}, i_subject];
        elseif lastPart(1) == 'm'
            gender_indices{2} = [gender_indices{2}, i_subject];
        end
    end
end

%% 直接按重塑后的结构加载和存储数据
for i_obs = 1:length(obs_types)
    obs_type = obs_types(i_obs);
    
    for i_nation = 1:length(nations)
        % 获取当前人种的所有索引
        nation=nations(i_nation);
        curr_nation_indices = nation_indices{i_nation};
        
        % 为当前人种组合初始化数据数组
        n_subjects = length(curr_nation_indices);
        par_current = zeros(n_para, 6, n_subjects, length(attributes));
        lab_fit_current = zeros(n_para, 3, n_subjects, length(attributes));
        average_current = zeros(n_para, 3, n_subjects);
        
        % 为每个subject加载数据
        for i_subject = 1:n_subjects
            subject_idx = curr_nation_indices(i_subject);
            lastPart = lastParts{subject_idx};
            iOr = lastPart(end);
            white_file = fullfile("optimizedD\whiteSquare\XYZw_white", ...
                strcat(lastPart, ".mat"));
            load(white_file,"XYZw_white");
            % 加载平均肤色数据
            average_file = fullfile("aveSkin", lastPart, "autoNhand_scaleoverLUT.mat");
            if exist(average_file, 'file')
                average_data = load(average_file);
                average_bf=average_data.average_lab_all(:, 1:3);
                %late CAT
                XYZ_bf=lab2xyz2(average_bf,'d65_64');
                for i_para=1:size(average_bf,1)
                    D_pre(i_para,1)= calculateD(CT(i_para,1), 0, "efit2");
                    XYZt(i_para,:) = CAT16_D(XYZ_bf(i_para,:), ...
                        XYZwpre(i_para,:), wd65, D_pre(i_para,1));                
                end
                average_aft = xyz2lab(XYZt, 'd65_64');
                if strcmp(lightness_type,"rela")
                    xyz_ave=[];ave_scaled=[];
                    for i_para=1:size(average_aft,1)                                
                        xyz_ave(i_para,:)=lab2xyz2(average_aft(i_para,:),"user",wd65./wd65(2).*XYZw_LUT(2));
                        ave_scaled(i_para,:)=xyz2lab(xyz_ave(i_para,:),"user",wd65./wd65(2).*XYZw_white(i_para,2));
                    end
                    average_current(:, :, i_subject) = ave_scaled;
                else
                    average_current(:, :, i_subject) = average_aft;
                end
            else
                average_current(:, :, i_subject) = NaN(n_para, 3);
            end
            
            % 循环处理每个 attribute
            for i_attr = 1:length(attributes)
                attribute = attributes(i_attr);
                attribute_serial = strcat(sprintf("%02d", attribute), attribute_names(attribute));
                
                % 定义路径
                source_file = fullfile('AnalyseResults1', Dtype, lastPart, obs_type, attribute_serial, 'ellipPara', 'fitRes.mat');
                
                % 加载数据
                if exist(source_file, 'file')
                    par_all_data = load(source_file);
                    par_all = par_all_data.par_all;
                    par_all=[par_all;...
                        nan(size(par_current,1)-size(par_all,1),size(par_all,2))];
                    par_current(:, :, i_subject, i_attr) = par_all;

                    lab_bf=[average_current(:, 1, i_subject), par_all(:,4:5)];
                    if strcmp(lightness_type,"rela")
                        xyz_fit=[];lab_scaled=[];
                        for i_para=1:size(par_all,1)                                
                            xyz_fit(i_para,:)=lab2xyz2(lab_bf(i_para,:),"user",wd65./wd65(2).*XYZw_LUT(2));
                            lab_scaled(i_para,:)=xyz2lab(xyz_fit(i_para,:),"user",wd65./wd65(2).*XYZw_white(i_para,2));
                        end
                        lab_fit_current(:, :, i_subject, i_attr) = lab_scaled;
                    else
                        lab_fit_current(:, :, i_subject, i_attr) = lab_bf;
                    end
                    
                else
                    par_current(:, :, i_subject, i_attr) = NaN(n_para, 6);
                    lab_fit_current(:, :, i_subject, i_attr) = NaN(n_para, 3);
                    file_missing{end+1,1}=lastPart;
                    file_missing{end,2}=obs_type;
                    file_missing{end,3}=attribute_serial;
                end
            end
        end
        
        % 存储到重塑后的数据结构中
        par_reshaped{i_obs, i_nation} = par_current;
        lab_fit_reshaped{i_obs, i_nation} = lab_fit_current;
        
        % average_reshaped只需要存储一次（不依赖于观察者类型）
        if i_obs == 1
            average_reshaped{i_nation} = average_current;
        end
        
        average_mean{i_nation}=nanmean(average_reshaped{i_nation} ,3);       
        par_mean{i_obs,i_nation}=nanmean(par_reshaped{i_obs,i_nation},3);
        average_nation_temp(i_nation,:)=mean(average_mean{i_nation}(indices_target,:));
        
    end
    average_nations{i_obs}=average_nation_temp;
end
%% 保存
output_folder=fullfile("ellip_pic", Dtype,lightness_type);
if ~exist(output_folder,"dir")
    mkdir(output_folder);
end

save(fullfile(output_folder,strcat("data_reshaped_",iOr,".mat")),"par_mean","average_mean", ...
"lab_fit_reshaped","file_missing","par_reshaped","average_reshaped");
%%
output_folder=fullfile("AnalyseResults1",Dtype,"sum_list",lightness_type);
if ~exist(output_folder,"dir")
    mkdir(output_folder);
end
save(fullfile(output_folder,strcat("data_reshaped_",iOr,".mat")), ...
    "par_mean","average_mean", ...
"lab_fit_reshaped","file_missing","par_reshaped","average_reshaped");
%%
save_path=fullfile("ellip_pic", Dtype, "obs","sum_list",lightness_type, iOr);
% sort_lab_fit_XSLX_obs(lab_fit_reshaped, average_mean, save_path, ...
%     indices_target, lightness_type, iOr);
%% 计算全局坐标轴范围
% 初始化极值变量
lim_min_x = inf;  % a*轴最小边界初始化为正无穷
lim_min_y = inf;  % b*轴最小边界初始化为正无穷
lim_max_x = -inf; % a*轴最大边界初始化为负无穷
lim_max_y = -inf; % b*轴最大边界初始化为负无穷

% 遍历所有可能的数据组合计算全局极值
for i_nation = 1:length(nations)
    for i_obs = 1:length(obs_types)
        obs_type=obs_types(i_obs);
        % 获取当前人种的subject数量
        n_subjects = size(lab_fit_reshaped{i_obs, i_nation}, 3);
        if n_subjects == 0
            continue;
        end

        % 获取当前人种对应的lastPart索引
        curr_nation_indices = nation_indices{i_nation};


        for attribute = attributes
            lab = lab_fit_reshaped{i_obs,i_nation}(indices_target, :, :, attribute);
            lab_mean = nanmean(lab, 3);
            lab_mean = nanmean(lab_mean, 1);
            if ~all(isnan(lab_mean(:)))                
                lim_min_x = min(lim_min_x, lab_mean(2));
                lim_max_x = max(lim_max_x, lab_mean(2));
                lim_min_y = min(lim_min_y, lab_mean(3));
                lim_max_y = max(lim_max_y, lab_mean(3));
            end
        end

    end
end

% 添加边距
lim_min_x = lim_min_x - 1;
lim_max_x = lim_max_x + 1;
lim_min_y = lim_min_y - 1;
lim_max_y = lim_max_y + 1;

% 确保x和y轴范围相同，以保持等比例显示
range_x = lim_max_x - lim_min_x;
range_y = lim_max_y - lim_min_y;
max_range = max(range_x, range_y);

% 调整范围使x和y轴的刻度间隔相同
lim_min_x = (lim_min_x + lim_max_x - max_range) / 2;
lim_max_x = (lim_min_x + lim_max_x + max_range) / 2;
lim_min_y = (lim_min_y + lim_max_y - max_range) / 2;
lim_max_y = (lim_min_y + lim_max_y + max_range) / 2;



%% 绘图部分
nan_record={};
% 创建从冷色(蓝色)到暖色(红色)的颜色映射
cmap = colormap('jet');
for i_nation = 1:length(nations)
    nation=nations(i_nation);
    nation_serial=strcat(sprintf("%02d",i_nation),nation);
    figure(i_nation);
    hold on;
    set(gcf, 'Color', 'white');
    for attribute = attributes
        attribute_serial = strcat(sprintf("%02d", attribute), attribute_names(attribute));
        clear("lab_g_obs");
        for i_obs=1:length(obs_types)
            obs_type=obs_types(i_obs);
            if iOr=='r'
                CT=CT_nations{i_nation};
            end
            % 获取当前人种的subject数量
            n_subjects = size(lab_fit_reshaped{i_obs, i_nation}, 3);
            if n_subjects == 0
                continue;
            end

            % 获取当前人种对应的lastPart索引
            curr_nation_indices = nation_indices{i_nation};        
            % 分离性别索引
            gender_indices = separate_genders(n_subjects, curr_nation_indices, lastParts);
            % 直接从lab_fit_reshaped获取数据
            lab_data = lab_fit_reshaped{i_obs,i_nation}(indices_target, :, :, attribute);

            % 计算平均值并准备数据
            lab_g = nanmean(lab_data, 3); % 按受试者维度求平均
            lab_g = nanmean(lab_g, 1); % 按光源维度求平均


            % 根据归一化数据值获取颜色
            scatter(lab_g( 2), lab_g( 3), 20, 'o', 'filled', ...
                'MarkerFaceColor', colors(i_obs,:), 'MarkerEdgeColor', colors(i_obs,:), 'LineWidth', 0.5);

            % 标记数据值
            text(lab_g(2), lab_g(3), ...
                 num2str(attribute), 'FontSize', 6, ...
                'VerticalAlignment', 'top', 'Color', 'k');
            lab_g_obs(i_obs,:)=lab_g;
        end
        ave=mean(average_mean{ i_nation}(indices_target,:),1);
        scatter(ave( 2), ave( 3), 20, 'o', 'filled', ...
        'MarkerFaceColor', colors(4,:), 'MarkerEdgeColor', colors(4,:), 'LineWidth', 0.5);
        lab_g_obs(4,:)=ave;
        lab_g_obs(:, 4) = sqrt(lab_g_obs(:, 2).^2 + lab_g_obs(:, 3).^2);
        lab_g_obs(:, 5) = atan2d(lab_g_obs(:, 3), lab_g_obs(:, 2));

        % 将带有标题的 lab_g_obs 拼接到 lab_g_all 中
        lab_g_all(attribute,:) =[lab_g_obs(1,:), lab_g_obs(2,:), lab_g_obs(3,:),...
            lab_g_obs(4,:)];        
        if size(lab_g_obs, 1) >= 2 && ~any(isnan(lab_g_obs(1,2:3))) && ~any(isnan(lab_g_obs(2,2:3)))
            x = [lab_g_obs(1,2), lab_g_obs(2,2)];
            y = [lab_g_obs(1,3), lab_g_obs(2,3)];

        % 绘制线段
        line(x, y, 'Color', 'k', 'LineWidth', 0.5, 'LineStyle', '-');            

        end
        % 添加PMCC点
        lab = lab_fit_reshaped{i_obs,i_nation}(indices_target, :, :, 1);
        lab = nanmean(lab, 3); % 按受试者维度求平均
        lab = nanmean(lab, 1); % 按光源/环境维度求平均

        % 绘制原始PMCC点
        xyz_mean=lab2xyz2(lab,"d65_64");
        xyz_PMCC=lab2xyz2(labCh_PMCC(i_nation,1:3),"d65_64");
        xyz_PMCC=xyz_PMCC./xyz_PMCC(2).*xyz_mean(2);
        labCh_PMCC_pre(i_nation,:)=xyz2lab(xyz_PMCC,"d65_64");
        plot(labCh_PMCC(i_nation, 2), labCh_PMCC(i_nation, 3), 's', 'MarkerSize', 8, ...
            'MarkerFaceColor',colors(i_nation,:), 'MarkerEdgeColor', colors(i_nation,:));
        plot(labCh_PMCC_pre(i_nation, 2), labCh_PMCC_pre(i_nation, 3), 's', 'MarkerSize', 8, ...
            'MarkerFaceColor', 'none', 'MarkerEdgeColor', colors(i_nation,:));
    end
    
    % 添加图例、标签和标题
    xlabel('{\ita*}', 'FontSize', 10);
    ylabel('{\itb*}', 'FontSize', 10);
    title([nation_names(i_nation)], 'FontSize', 12);


    % 设置坐标轴范围
    axis equal;
    interval = 2;  
    xticks(round(lim_min_x):interval:round(lim_max_x));
    yticks(round(lim_min_y):interval:round(lim_max_y));
    xlim([lim_min_x, lim_max_x]);
    ylim([lim_min_y, lim_max_y]);

    % 绘制y=x参考线
    x = linspace(lim_min_x, lim_max_x, 100);
    plot(x, x, 'k--', 'LineWidth', 0.8);

    % 保存图片
    save_folder = fullfile("ellip_pic", Dtype, "obs",lightness_type, iOr);
    if ~exist(save_folder, "dir")
        mkdir(save_folder, 'recursive');
    end
    exportgraphics(gcf, fullfile(save_folder, strcat(nation_serial, '_L.jpg')), 'Resolution', 300);
    close(gcf);
    header1 = ["non_model","","","","", "model_group", "","","","","model","","","","","average","","","",""];  
    header2 = ["L", "a", "b", "C", "h","L", "a", "b", "C", "h","L", "a", "b", "C", "h","L", "a", "b", "C", "h"];  
    clear("lab_g_cell")
    lab_g_cell=lab_g_all;
    lab_g_cell(end+1,:)=mean(lab_g_cell,1,"omitnan");    
    lab_g_cell=[header1;header2;lab_g_cell];
    lab_g_cell=[["";"";attribute_names';"mean"],lab_g_cell];  
    xlswrite(fullfile(save_folder,"lab_data_obs.xlsx"), lab_g_cell, nation);

    % 合并所有图片
    save_folder = fullfile("ellip_pic", Dtype, "obs", lightness_type, iOr);
    concatenate_images1(save_folder, 4);   
end


