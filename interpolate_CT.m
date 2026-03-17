close all; % 关闭所有图窗 
clc;       % 清空命令窗口 
clear;     % 清除工作区所有变量 
addpath('utils\') 
%% 定义所有需要处理的 attribute 
attributes = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]; 
 
attribute_names = ["Preference", "Attractiveness", "Feminine", "Cooperative", ... 
    "Youth", "Healthy", "Fidelity", "Harmony", "Fair", "Ruddy"]; 
nations = ["AS", "CA", "SA", "AF"]; 
nation_serials=["Asian","Caucasian","South Asian","African","all"]; 
% nations = ["AS"]; 
% lastParts = {'f04i', 'f05i', 'f06i', 'm04i', 'm05i', 'm06i'};n_para = 21;iOr='i'; 
lastParts = {'f04i', 'f05i', 'f06i', 'm04i', 'm05i', 'm06i',... 
'f01i', 'f02i', 'f03i', 'm01i', 'm02i', 'm03i',... 
'f07i', 'f08i','m07i', 'm08i',... 
'f09i', 'f10i','m09i', 'm10i'};n_para = 21;iOr='i'; 
%------------------------------------ 
% lastParts = {'f04r', 'f05r', 'f06r', 'm04r', 'm05r', 'm06r',... 
% 'f01r', 'f02r', 'f03r', 'm01r', 'm02r', 'm03r',... 
% 'f07r', 'f08r','m07r', 'm08r',... 
% 'f09r', 'f10r','m09r', 'm10r'};n_para = 14;iOr='r'; 
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
% obs_types = ["non_model"]; 
obs_types = ["non_model","model_group"]; 
% obs_types = ["non_model", "model_group", "model"]; 
scale_type="unscaled"; 
load(fullfile("documents",iOr,"render_data2.mat"),"render_map"); 
Keys = keys(render_map); 
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
if iOr =='i'
    picnames_groups = ["h3k","h4k","h5k","h6k","hd65","h7k","h8k",...
                    "m3k","m4k","m5k","m6k","md65","m7k","m8k",...
                     "l3k","l4k","l5k","l6k","ld65","l7k","l8k"];
    load('optimizedD\neutral_gray\combi_XYZw_i.mat', 'XYZ_combi',"CCT_combi");
    target_indices{1}=5;
    target_indices{2}=12;
    target_indices{3}=19;

    XYZwpre=XYZ_combi;
elseif iOr=='r'
    picnames_groups = ["rs01","rs02","rs03","rs04","rs05","rs06","rs07", ...
             "rs08","rs09","rs10","rs11","rs12","rs13","rs14"];
    picnames_groups1=["1负一楼商场" ,"2负一楼vivo" ,"3下沉广场", "4学校饭堂" ,"5学校小卖部",...
    "6学校星巴克", "7草地顺光" ,"8草地侧光", "9草地逆光", "10阴天场景" ,...
    "11夕阳草地逆光", "12夕阳草地侧光", "13夜景小卖部门口", "14 极夜小卖部对面"];
    target_indices{1}=1:14;
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
Dtype = 'noCAT'; 

%% 绘图部分 - 按色温映射颜色 
output_folder1=fullfile("ellip_pic", "noCAT"); 
if ~exist(output_folder1,"dir") 
    mkdir(output_folder1); 
end 
data_noCAT=load(fullfile(output_folder1,strcat("data_reshaped_",iOr,".mat")), ... 
    "par_mean","average_mean", ... 
    "lab_fit_reshaped","file_missing","par_reshaped","average_reshaped"); 
nan_record={}; 
% 创建从冷色(蓝色)到暖色(红色)的颜色映射 
cmap = colormap('jet'); 
cmap = flipud(cmap);  % 翻转颜色映射，使蓝色对应高色温，红色对应低色温 
load(fullfile("optimizedD\backGroundGray\XYZ_gray.mat"),"xyz_gray"); 
E=xyz_gray(:,2); 

%% 更改后的插值逻辑 
% 预加载一次数据，避免在循环中重复加载 
output_folder1=fullfile("ellip_pic", "noCAT"); 
data_noCAT = load(fullfile(output_folder1,strcat("data_reshaped_",iOr,".mat"))); 
 
% 创建存储插值句柄的 cell 数组 
interpolated_handles = cell(length(obs_types), length(nations), length(attributes)); 
 
for i_obs = 1:length(obs_types) 
    obs_type = obs_types(i_obs); 
    for i_nation = 1:length(nations) 
        nation = nations(i_nation); 

        % 计算 E 和 CCT 的平均值
        clear("E_vals");
        clear("CCT_vals");
        
        curr_nation_indices = nation_indices{i_nation};
        n_subjects = length(curr_nation_indices);
        
        for i_subject = 1:n_subjects
            subject_idx = curr_nation_indices(i_subject);
            lastPart = lastParts{subject_idx};
            for i_para=1:length(picnames_groups)
                 picname = strcat(lastPart,picnames_groups(i_para));
                 
                 if isKey(render_map, picname)
                    curr_struct = render_map(picname);
                    E_vals(i_para,i_subject) = curr_struct.E_val;
                    CCT_vals(i_para,i_subject)  =  curr_struct.CCT_val;
                 else
                    file_missing{end+1} = picname;
                 end
            end
        end
        E_nation=nanmean(E_vals,2);
        CCT_nation=nanmean(CCT_vals,2);

        



        for i_attr = 1:length(attributes) 
            attribute = attributes(i_attr); 
            
            % 从加载的数据中获取 lab1 
            % 注意: 这里直接使用 data_noCAT.lab_fit_reshaped 
            % data_noCAT 结构体中的 lab_fit_reshaped 是 3x5x1 的 cell，i_obs, i_nation, i_attr 索引需要调整 
            % lab_data1 = nanmean(data_noCAT.lab_fit_reshaped{i_obs, i_nation}, 3); 
            lab_data_for_attr = data_noCAT.lab_fit_reshaped{i_obs,i_nation}; 
            lab_data1 = nanmean(lab_data_for_attr(:,:,:,i_attr), 3); 
            

            % 定义插值坐标和值 
            % x: L* % y: 1/CCT 
            % v1: a* % v2: b* 
            x = lab_data1(:, 1); 
            y = 1./CCT_nation; 
            v_a = lab_data1(:, 2); 
            v_b = lab_data1(:, 3); 
            
            % 执行二维插值 
            nation,attribute
            try 
                F_a = scatteredInterpolant(x, y, v_a, 'linear', 'none'); 
                F_b = scatteredInterpolant(x, y, v_b, 'linear', 'none'); 
            
                % 将插值句柄保存到 cell 数组中 
                interpolated_handles{i_obs, i_nation, i_attr} = {F_a, F_b}; 
            catch ME 
                fprintf('Interpolation failed for: obs_type=%s, nation=%s, attribute=%s. Error: %s\n', obs_type, nation, attribute_names(attribute), ME.message); 
                continue; 
            end 
        end 
    end 
end 
 
%% 保存插值结果 

 
for i_obs = 1:length(obs_types) 
    obs_type = obs_types(i_obs); 
    for i_nation = 1:length(nations) 
        nation_serial = strcat(num2str(i_nation),nation_serials(i_nation)); 
        for i_attr = 1:length(attributes) 
            attribute_serial = attribute_names(attributes(i_attr)); 

            save_folder = fullfile("ellip_pic", "interpolated_data", obs_type, iOr,attribute_serial,nation_serial); 
            if ~exist(save_folder, "dir") 
                mkdir(save_folder); 
            end 

            filename = fullfile(save_folder, sprintf('interp_handles.mat')); 
            
            F_handles = interpolated_handles{i_obs, i_nation, i_attr}; 
            if ~isempty(F_handles) 
                F_a = F_handles{1}; 
                F_b = F_handles{2}; 
                save(filename, 'F_a', 'F_b'); 
            end 
        end 
    end 
end 
disp('Interpolation handles saved successfully.');