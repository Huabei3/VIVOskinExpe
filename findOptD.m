close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量
%不同词条下21个光的图
%% 定义所有需要处理的 attribute
attributes = [1, 2, 3, 4, 5, 6,7, 8, 9,10];
attribute_names = ["Preference", "Attractiveness", "Feminine", "Cooperative", ...
    "Youth", "Healthy", "Precise reproduction","suit the environment or not", "white-skinned", "ruddy"];
attribute_names_new = ["Preference", "Attractiveness", "Feminine", "Cooperative", ...
    "Youth", "Healthy", "Fidelity","Harmony", "Fair", "Ruddy"];
picname_group=["h3k","h4k","h5k","h6k","hd65","h7k","h8k",...
    "m3k","m4k","m5k","m6k","md65","m7k","m8k",...
    "l3k","l4k","l5k","l6k","ld65","l7k","l8k"];
wd65_64 = [94.811, 100.00, 107.304];
CT = [3000, 4000, 5000, 6000, 6500, 7000, 8000]';
% obs_types=["non_model","model_group","model","all"];
% obs_types_new=["stranger","acquaintance","self","all"];

obs_types=["non_model"];
obs_types_new=["stranger"];
% 定义色环上的 7 种颜色
colors=hsv(3);

wd65=[94.811 100.00 107.304];
datai_file = '..\renderCode\calibResults\data_ipv18_3.mat';
XYZw=load(datai_file);
XYZw=XYZw.XYZw;
XYZw_scaled=XYZw./XYZw(2).*wd65(2);

Dtype='noCAT';
h1=figure(1);
ax1 = axes('Parent', h1);
hold on;
set(gcf, 'Color', 'white');
h2=figure(2);
ax2 = axes('Parent', h2);
hold on;
for i_obstype=1:length(obs_types)

    save_folder=fullfile('AnalyseResults1', 'optimizedD',obs_types(i_obstype)); 
    if ~exist(save_folder,"dir")
        mkdir(save_folder);
    end
    check_folder=fullfile(save_folder,"check_pic");
    if ~exist(check_folder,"dir")
        mkdir(check_folder);
    end

    lab_PMCC = [62.11, 18.96, 19.76];
    labC_PMCC = [lab_PMCC, sqrt(lab_PMCC(1, 2)^2 + lab_PMCC(1, 3)^2)];
    
    % lastParts = {'female78i', 'female41i', 'femalevivoi', ...
    %     'male59i', 'male39i', 'malevivoi'};
    lastParts = {'f04iadd', 'f05iadd', 'f06iadd', ...
    'm04iadd', 'm05iadd', 'm06iadd'};
    
    for lastPart_idx = 1:length(lastParts)
        lastPart = lastParts{lastPart_idx};
    
        model = lastPart(1:end-1);
        [lastPart1, model1] = gen_lastPart1(lastPart);
        lastPart_new=gen_lastPart_new(lastPart1);
        disp([lastPart,lastPart_new])
        average_file = strcat("aveSkin\", strrep(lastPart_new,"add",""), "\autoNhand_scaleoverLUT.mat");
        average_data = load(average_file);
        average_inds(:,:,lastPart_idx) = average_data.average_lab_all(:, 1:3);
        for attribute = attributes
            fprintf('Processing attribute: %d\n', attribute);        
            % 生成 attribute_serial
            attribute_serial = strcat(sprintf("%02d", attribute), attribute_names_new(attribute));

            source_file_used = fullfile('AnalyseResults1', Dtype, lastPart, ...
                obs_types(i_obstype), attribute_serial, 'ellipPara', 'fitRes_level.mat'); 
            
            par_all4=[];
            if exist(source_file_used, 'file') % 新增 source_file_used 的加载
                load(source_file_used);
                par_all4 = par_all;
            else
                par_all4(1:21,1:6)=NaN;
            end
            par_inds(:,:,lastPart_idx,attribute)=par_all4;
        end
    end
    
    average=nanmean(average_inds,3);
    par_all_used=nanmean(par_inds(:,:,:,1),3);
    %a-b
    lim_min_x=min(min(min(par_all_used(:,4,:,:))))-1;
    lim_max_x=max(max(max(par_all_used(:,4,:,:))))+1;
    lim_min_y=min(min(min(par_all_used(:,5,:,:))))-1;
    lim_max_y=max(max(max(par_all_used(:,5,:,:))))+1;
    
    %% 循环处理每个 attribute
    for attribute = [1]
    % for attribute = attributes
        % par_all_used=par_all_used(:,:,1,attribute);
        attribute_serial = strcat(sprintf("%02d", attribute), attribute_names(attribute));


        for i_para = 1:size(par_all_used,1)
            % 计算 labC_PMCCpre
            if average(i_para, 1) <= 60
                C_pre = 6.7421 * log(average(i_para, 1)) - 9.9816; % 亮度实验
            else
                C_pre = 6.7421 * log(60) - 9.9816; % 亮度实验
            end

        end
    
        idx_ranges=[1:7;8:14;15:21];

        for i_level = 1:3
            % 绘制 source_file_used 的 contour 或散点图 (新增部分)
            if exist('par_all_used', 'var')&&~isempty(par_all_used)
                par = par_all_used(idx_ranges(i_level,:), :);
                ave_level=average(idx_ranges(i_level,:), :);
                lab_fit=[ave_level(:,1),par(:,4),par(:,5)];
                lab_D65=lab_fit(5,:);
                XYZ_bf=lab2xyz2(lab_fit,'user',XYZw_scaled);
                
                for i_row=1:length(lab_fit)    
                    XYZw=CCT2xyz(CT(i_row),0,10);

                    D=linspace(0,1,1000);
                    for i_D=1:length(D)
                        XYZt(i_D,:) = CAT16_D(XYZ_bf(i_row,:), XYZw, wd65, D(i_D));                    
                        [Labt(i_D,:)] = xyz2lab(XYZt(i_D,:), 'user', wd65);
                        dE(i_D,:)=deltaE2000(Labt(i_D,:),lab_D65);
                    end
                    [~,min_idx]=min(dE);
                    D_min_dE(i_row,1)=D(min_idx);
                    plot(D,dE,'Parent',ax1);
                    
                    % title(num2str(CT(i_row)));

                    D_optimal(i_row,:) = optimize_D(XYZ_bf(i_row,:), ...
                        XYZw, wd65, lab_D65);                    
                end
                scatter(1116./CT,D_min_dE,'Parent',ax2);
                scatter(1116./CT,D_optimal, 30, 'filled','Parent',ax2);
                D_optimal_all{i_level,1}=D_optimal;
                D_optimal_all{i_level,2}=CT;

            end
        % disp("d")
        end   
        
    end

    save(fullfile(save_folder,"optimizedD.mat"),"D_optimal_all");
end


%% 
figure(2)
hold on
axis equal;
D_CCT=[];
for i_level = 1:3
    D=D_optimal_all{i_level,1};
    CCT=D_optimal_all{i_level,2};
    D_CCT=[D_CCT;[D,CCT]];
end
%拟合曲线
idx_del=D_CCT(:,1)>0.99;
D_CCT(idx_del,:)=[];
save(fullfile(save_folder,"D_CCT.mat"),"D_CCT");
%%
load(fullfile(save_folder,"D_CCT.mat"),"D_CCT");

%% 拟合曲线，取倒数

% figure(3)
% hold on
% axis equal;
% 
% scatter(1116./D_CCT(:,2),D_CCT(:,1),30, 'filled');
% xdata = 1116./D_CCT(:,2);
% ydata = D_CCT(:,1);
% 
% f = @(a,xdata)(a(1).*xdata+a(2));
% 
% rmax = 0;
% 
% for t = 1:500
%     a0 = [rand,rand];
%     options = optimset('MaxFunEvals',200000);
%     a = lsqcurvefit(f,a0,xdata,ydata,[-inf,-inf],[inf,inf],options);
%     y = a(1).*xdata+a(2);
% 
%     r = corr(y,ydata);
%     if r >= rmax
%         rmax = r;
%         afinal = a;
%     end
% end
% r_D1=rmax;
% a_D1 = afinal;
% 
% x_max_lim=max(1116./D_CCT(:,2))+0.2;
% y_max_lim=max(D_CCT(:,1))+0.2;
% %画拟合直线
% x = 0:0.1:x_max_lim;
% y= a_D1(1)*x+a_D1(2);
% 
% y1 = 0.00005 * 1./x + 0.1977; % OPPO
% y2 = 0.239 * 0.723 * (1 - x);%summer
% plot(x,y,"Color","r");
% plot(x,y1,"Color","g");
% plot(x,y2,"Color","b");
% ax = gca; ax.XLim = [0 x_max_lim];
% ay = gca; ay.YLim = [0 y_max_lim];
% xlabel('1116/CCT','FontAngle','italic');
% ylabel('D','FontAngle', 'italic');% 
% 
% save(fullfile(save_folder,"D_reversedCCT.mat"),"a_D1");
% exportgraphics(gcf,fullfile(save_folder,strcat('D_reversedCCT.jpg')), ...
%     "Resolution",150);


%%


function D_optimal = optimize_D(XYZ, XYZw, XYZwt, Labtarget)
    % 定义目标函数，计算 deltaE2000
    % objectiveFunction = @(D) cal_deltaE2000(XYZ, XYZw, XYZwt, D, Labtarget);
    objectiveFunction = @(D) cal_delta_h(XYZ, XYZw, XYZwt, D, Labtarget);
    
    % 使用 fminbnd 或 fminsearch 搜索最优的 D 值
    % 假设 D 的合理范围是 [0, 1]
    D_optimal = fminbnd(objectiveFunction, 0, 1);
    
    % 输出最优 D 值
    fprintf('Optimal D value: %.6f\n', D_optimal);
end

function delta_h = cal_delta_h(XYZ, XYZw, XYZwt, D, Labtarget)
    % 调用 CAT16_D 函数计算 XYZt
    XYZt = CAT16_D(XYZ, XYZw, XYZwt, D);
    
    % 将 XYZt 和 XYZtarget 转换为 Lab
    wd65=[94.811 100.00 107.304];
    datai_file = 'LUT3d\results\datai_sorted40_3.mat';
    XYZw=load(datai_file);
    XYZw=XYZw.XYZw;
    XYZw_scaled=XYZw./XYZw(2).*wd65(2);
    %这里XYZt用XYZw_scaled转入就用XYZw_scaled转回Labt，
    % 等效于Labtarget也用XYZw_scaled转为XYZtarget和XYZt比
    [Labt] = xyz2lab(XYZt, 'user', XYZw_scaled);
    h_t=atan2d(Labt(3),Labt(2));
    h_target=atan2d(Labtarget(3),Labtarget(2));
    
    % 计算 deltaE2000
    delta_h = abs(h_t - h_target);
end

%%
% function D_optimal = optimize_D(XYZ, XYZw, XYZwt, Labtarget)
%     % 定义目标函数，计算 deltaE2000
%     objectiveFunction = @(D) cal_deltaE2000(XYZ, XYZw, XYZwt, D, Labtarget);
% 
%     % 使用 fminbnd 或 fminsearch 搜索最优的 D 值
%     % 假设 D 的合理范围是 [0, 1]
%     D_optimal = fminbnd(objectiveFunction, 0, 1);
% 
%     % 输出最优 D 值
%     fprintf('Optimal D value: %.6f\n', D_optimal);
% end
% 
% function deltaE = cal_deltaE2000(XYZ, XYZw, XYZwt, D, Labtarget)
%     % 调用 CAT16_D 函数计算 XYZt
%     XYZt = CAT16_D(XYZ, XYZw, XYZwt, D);
% 
%     % 将 XYZt 和 XYZtarget 转换为 Lab
%     [Labt] = xyz2lab(XYZt, 'user', XYZwt./XYZwt(2).*100);
% 
%     % 计算 deltaE2000
%     deltaE = deltaE2000(Labt, Labtarget);
% end

