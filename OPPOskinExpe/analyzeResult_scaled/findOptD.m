clear;
addpath("utils\")
%%
scene_name=["inLab","indoorAdd","nightAdd","outdoorAdd","sunsetAdd"];



ave_All=[];
for i_scene=1:length(scene_name)
    [picname_groups] = gen_picname_groups(scene_name(i_scene));
    save_folder = fullfile('AnalyseResults\noCAT', ...
        scene_name(i_scene),"labNscore");
    for i_pic = 1:length(picname_groups)
        load(fullfile(save_folder ,strcat("labNscore_groupAdd", ...
            picname_groups(i_pic),".mat")),"lab_group");
        ave_All=[ave_All;[lab_group(end,:),{picname_groups(i_pic)}]];
    end
    
end

save("documents\Averages","ave_All");
%%
load("OPPOskin\matchTable.mat","match_table");
load("documents\CATedPre.mat","XYZw_pre_all","picname");
XYZw_inLab=mean(XYZw_pre_all(1:14,:));
scene_name=["inLab","indoorAdd","nightAdd","outdoorAdd","sunsetAdd"];
par_All=[];picname_check_All=[];
for i_scene=1:length(scene_name)
    save_folder = fullfile('AnalyseResults\noCAT', ...
        scene_name(i_scene),"ellipPara_scaled");
    load(fullfile(save_folder ,"fitRes_level.mat"),"picname_check","par_ind");
    par_All=[par_All;par_ind];
    picname_check_All=[picname_check_All;picname_check(:,1)];
    
end

XYZw_pre_cell=num2cell(XYZw_pre_all);
XYZw_pre_cell = horzcat(XYZw_pre_cell, picname_check_All);


wd65=[94.811 100.00 107.304];
datai_file = '..\display_calibration\datai_sorted40_3.mat';
XYZw=load(datai_file);
XYZw=XYZw.XYZw;
XYZw_scaled=XYZw./XYZw(2).*wd65(2);
save_folder="Optimize_D";
if ~exist(save_folder,"dir")
    mkdir(save_folder);
end
check_folder=fullfile(save_folder,"check_pic");
if ~exist(check_folder,"dir")
    mkdir(check_folder);
end
% figure("Visible","off");
figure();
hold on;

for i_row=1:size(par_All,1)
    lab_row(i_row,:)=[ave_All{i_row,1}(1,1),par_All(i_row,4:5)];   
    XYZ_row(i_row,:)=lab2xyz2(lab_row(i_row,:),'user',XYZw_scaled);
    XYZw=XYZw_pre_all(i_row,:);
    [CCT(i_row,1),duv(i_row,1),S_out{i_row,1}] = ...
        xyz2CCT(XYZw./XYZw(2).*100,10);
    
    idx_inLab = find(strcmp(XYZw_pre_cell(:,4), match_table{i_row,3}));
    a_CL=[6.7421,-9.9816];
    C_pre=a_CL(1)*log(lab_row(idx_inLab,1))+a_CL(2);%亮度实验
    C_bf=sqrt(lab_row(i_row,2).^2+lab_row(i_row,3).^2);
    % lab_bf(i_row,:)=[lab_row(idx_inLab,1),lab_row(i_row,2:3)./C_bf.*C_pre];
    %通过亮度实验放缩
    % lab_bf(i_row,:)=lab_row(i_row,:)./lab_row(i_row,1).*lab_row(idx_inLab,1);
    %直接放缩
    % XYZ_bf(i_row,:)=lab2xyz2(lab_bf(i_row,:),'user',XYZw_scaled);
    XYZ_bf(i_row,:)=XYZ_row(i_row,:);
    % XYZ_bf(i_row,:)=XYZ_row(i_row,:)./XYZw_pre_all(i_row,2).*XYZw_pre_all(idx_inLab,2);
    XYZ_target(i_row,:)=XYZ_row(idx_inLab,:);
    
    XYZwt=XYZw_pre_all(idx_inLab,:);
    Labtarget(i_row,:)=[ave_All{idx_inLab,1}(1,1),par_All(idx_inLab,4:5)];
    % D_optimal(i_row,:) = optimize_D(XYZ_bf(i_row,:),XYZw, XYZwt, Labtarget(i_row,:));
    D_optimal(i_row,:) = optimize_D(XYZ_bf(i_row,:),XYZw, XYZwt);


    D=linspace(0,1,1000);
    for i_D=1:length(D)
        XYZt(i_D,:) = CAT16_D(XYZ_bf(i_row,:), XYZw, XYZwt, D(i_D));                    
        [Labt(i_D,:)] = xyz2lab(XYZt(i_D,:), 'user', XYZw_scaled);
        d_h(i_D,:)=atan2d(Labt(i_D,3),Labt(i_D,2))-...
        atan2d(Labtarget(i_row,3),Labtarget(i_row,2));
    end
    plot(D,d_h);
    title(num2str(CCT(i_row,1)));
    saveas(gcf,fullfile(check_folder,strcat(ave_All{i_row,2},".jpg")));
end

figure;
scatter(CCT, D_optimal, 30, 'filled');
D_CCT=[D_optimal,CCT];
D_CCT_duv=[D_optimal,CCT,duv];
idx_del=(D_CCT(:,1)>0.99|D_CCT(:,1)<0.01);
D_CCT(idx_del,:)=[];
D_CCT_duv(idx_del,:)=[];
lab_bf_target=[lab_row,Labtarget,CCT];

%% 拟合曲线，取倒数

figure(3)
hold on
axis equal;

scatter(1116./D_CCT(:,2),D_CCT(:,1),30, 'filled');
xdata = 1116./D_CCT(:,2);
ydata = D_CCT(:,1);

f = @(a,xdata)(a(1).*xdata+a(2));

rmax = 0;

for t = 1:500
    a0 = [rand,rand];
    options = optimset('MaxFunEvals',200000);
    a = lsqcurvefit(f,a0,xdata,ydata,[-inf,-inf],[inf,inf],options);
    y = a(1).*xdata+a(2);

    r = corr(y,ydata);
    if r >= rmax
        rmax = r;
        afinal = a;
    end
end
r_D1=rmax;
a_D1 = afinal;

x_max_lim=max(1116./D_CCT(:,2))+0.2;
y_max_lim=max(D_CCT(:,1))+0.2;
%画拟合直线
x = 0:0.1:x_max_lim;
y= a_D1(1)*x+a_D1(2);

y1 = 0.00005 * 1./x + 0.1977; % OPPO
y2 = 0.239 * 0.723 * (1 - x);%summer
plot(x,y,"Color","r");
plot(x,y1,"Color","g");
plot(x,y2,"Color","b");
ax = gca; ax.XLim = [0 x_max_lim];
ay = gca; ay.YLim = [0 y_max_lim];
xlabel('1116/CCT','FontAngle','italic');
ylabel('D','FontAngle', 'italic');



save(fullfile(save_folder,"D_reversedCCT.mat"),"a_D1");
exportgraphics(gcf,fullfile(save_folder,strcat('D_reversedCCT.jpg')), ...
    "Resolution",150);


%% 不取倒数


figure(4)
hold on
axis equal;

scatter(D_CCT(:,2)./10000,D_CCT(:,1),30, 'filled');
xdata = D_CCT(:,2)./10000;
ydata = D_CCT(:,1);

f = @(a,xdata)(a(1).*xdata+a(2));

rmax = 0;

for t = 1:500
    a0 = [rand,rand];
    options = optimset('MaxFunEvals',200000);
    a = lsqcurvefit(f,a0,xdata,ydata,[-inf,-inf],[inf,inf],options);
    y = a(1).*xdata+a(2);

    r = corr(y,ydata);
    if r >= rmax
        rmax = r;
        afinal = a;
    end
end
r_D2=rmax;
a_D2 = afinal;

x_max_lim=max(D_CCT(:,2)./10000)+0.2;
y_max_lim=max(D_CCT(:,1))+0.2;


%画拟合直线
x = 0:0.1:x_max_lim;
y= a_D2(1)*x+a_D2(2);

y1 = 0.00005 * (x*10000) + 0.1977; % OPPO
y2 = 0.239 * 0.723 * (1 - 1116./(x*10000));%summer
plot(x,y,"Color","r");
plot(x,y1,"Color","g");
plot(x,y2,"Color","b");
ax = gca; ax.XLim = [0 x_max_lim];
ay = gca; ay.YLim = [0 y_max_lim];
xlabel('CCT','FontAngle','italic');
ylabel('D','FontAngle', 'italic');

save(fullfile(save_folder,"D_CCT.mat"),"a_D2");
exportgraphics(gcf,fullfile(save_folder,strcat('D_CCT.jpg')), ...
    "Resolution",150);




%% zhai的公式结构


% 假设 D_CCT 是一个矩阵，其中：
% D_CCT_duv(:,1) 是因变量 y
% D_CCT_duv(:,2) 是自变量 x1
% D_CCT_duv(:,3) 是自变量 x2
figure(5)
hold on
axis equal;

% 绘制散点图
scatter(D_CCT_duv(:,2), D_CCT_duv(:,1), 30, 'filled');
x1data = 1116./D_CCT_duv(:,2); % x1
x2data = D_CCT_duv(:,3); % x2
ydata = D_CCT_duv(:,1);

% 定义拟合函数
f = @(a, xdata) a(1).*xdata(:,1) + a(2).*xdata(:,2) + a(3).*xdata(:,1).*xdata(:,2) + a(4);

rmax = 0;

for t = 1:500
    a0 = [rand, rand, rand, rand]; % 初始参数
    options = optimset('MaxFunEvals', 200000);
    a = lsqcurvefit(f, a0, [x1data, x2data], ydata, [-inf, -inf, -inf, -inf], [inf, inf, inf, inf], options);
    y = a(1).*x1data + a(2).*x2data + a(3).*x1data.*x2data + a(4);

    r = corr(y, ydata);
    if r >= rmax
        rmax = r;
        afinal = a;
    end
end
r_D3 = rmax;
a_D3 = afinal;

% 计算绘图范围
x1_max_lim = max(D_CCT_duv(:,2)./10000) + 0.2;
x2_max_lim = max(D_CCT_duv(:,3)) + 0.2;
y_max_lim = max(D_CCT_duv(:,1)) + 0.2;

% 绘制拟合曲线
% 由于有两个自变量，需要选择一个固定值来绘制曲线
% 假设固定 x2 = mean(x2data)
x2_fixed = 0;
x1 = 0:0.1:x1_max_lim;
y = a_D3(1)*(1116./x1) + a_D3(2)*x2_fixed + a_D3(3)*(1116./x1).*x2_fixed + a_D3(4);
y1 = 0.00005 * x1 + 0.1977; % OPPO
y2 = 0.239 * 0.723 * (1 - 1116./x1);%summer
y3 = 0.723 * (1 - 1116 ./ x1 + 8.64 * x2_fixed - 49266 * x2_fixed ./ x1); % zhai
plot(x1, y, "Color", "r");
plot(x1,y1,"Color","g");
plot(x1,y2,"Color","b");
plot(x1,y3,"Color","c");
xlabel('CCT', 'FontAngle', 'italic');
ylabel('D', 'FontAngle', 'italic');

% 设置坐标轴范围
ax = gca;
ax.XLim = [0 x1_max_lim];
ay = gca;
ay.YLim = [0 y_max_lim];

% 保存结果
save(fullfile(save_folder, "D_CCT_duv.mat"), "a_D3");
exportgraphics(gcf, fullfile(save_folder, strcat('D_CCT_duv.jpg')), ...
    "Resolution", 150);

%%
function D_optimal = optimize_D(XYZ, XYZw, XYZwt)
    % 定义目标函数，计算 deltaE2000
    % objectiveFunction = @(D) cal_deltaE2000(XYZ, XYZw, XYZwt, D, Labtarget);
    objectiveFunction = @(D) cal_delta_h(XYZ, XYZw, XYZwt, D);
    
    % 使用 fminbnd 或 fminsearch 搜索最优的 D 值
    % 假设 D 的合理范围是 [0, 1]
    D_optimal = fminbnd(objectiveFunction, 0, 1);
    
    % 输出最优 D 值
    fprintf('Optimal D value: %.6f\n', D_optimal);
end

function delta_h = cal_delta_h(XYZ, XYZw, XYZwt, D)
    % 调用 CAT16_D 函数计算 XYZt
    XYZt = CAT16_D(XYZ, XYZw, XYZwt, D);
    
    % 将 XYZt 和 XYZtarget 转换为 Lab
    wd65=[94.811 100.00 107.304];
    datai_file = '..\display_calibration\datai_sorted40_3.mat';
    XYZw=load(datai_file);
    XYZw=XYZw.XYZw;
    XYZw_scaled=XYZw./XYZw(2).*wd65(2);
    %这里XYZt用XYZw_scaled转入就用XYZw_scaled转回Labt，
    % 等效于Labtarget也用XYZw_scaled转为XYZtarget和XYZt比
    [Labt] = xyz2lab(XYZt, 'user', XYZw_scaled);
    h_t=atan2d(Labt(3),Labt(2));
    h_target=45;
    
    % 计算 deltaE2000
    delta_h = abs(h_t - h_target);
end


%%
% function D_optimal = optimize_D(XYZ, XYZw, XYZwt, Labtarget)
%     % 定义目标函数，计算 deltaE2000
%     % objectiveFunction = @(D) cal_deltaE2000(XYZ, XYZw, XYZwt, D, Labtarget);
%     objectiveFunction = @(D) cal_delta_h(XYZ, XYZw, XYZwt, D, Labtarget);
% 
%     % 使用 fminbnd 或 fminsearch 搜索最优的 D 值
%     % 假设 D 的合理范围是 [0, 1]
%     D_optimal = fminbnd(objectiveFunction, 0, 1);
% 
%     % 输出最优 D 值
%     fprintf('Optimal D value: %.6f\n', D_optimal);
% end
% 
% function delta_h = cal_delta_h(XYZ, XYZw, XYZwt, D, Labtarget)
%     % 调用 CAT16_D 函数计算 XYZt
%     XYZt = CAT16_D(XYZ, XYZw, XYZwt, D);
% 
%     % 将 XYZt 和 XYZtarget 转换为 Lab
%     wd65=[94.811 100.00 107.304];
%     datai_file = 'LUT3d\results\datai_sorted40_3.mat';
%     XYZw=load(datai_file);
%     XYZw=XYZw.XYZw;
%     XYZw_scaled=XYZw./XYZw(2).*wd65(2);
%     %这里XYZt用XYZw_scaled转入就用XYZw_scaled转回Labt，
%     % 等效于Labtarget也用XYZw_scaled转为XYZtarget和XYZt比
%     [Labt] = xyz2lab(XYZt, 'user', XYZw_scaled);
%     h_t=atan2d(Labt(3),Labt(2));
%     h_target=atan2d(Labtarget(3),Labtarget(2));
% 
%     % 计算 deltaE2000
%     delta_h = abs(h_t - h_target);
% end
% 
