close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量
addpath("utils\")
%%
text_type="ch";
% nations=["AS","CA","SA","AF","all"];
Dtype="efit_p";
%%
lab_cherry=[65.50 	17.21 	17.72 ];
ab_summer=[0 17.9 18.7];
% ab_zeng=[0 19.9 23.0];
ab_zeng=[0 18 21];
ab_zengCIC=[0 21 24];
lab_OPPO=[65.1919   19.0833   23.0048];
PengCIC=[[65,0,0,25.3,46.5];[67,0,0,25.3,46.0];[58,0,0,25.1,46.5];[40,0,0,25.0,46.5]];
PengCIC(:,2)=PengCIC(:,4).*cosd(PengCIC(:,5));
PengCIC(:,3)=PengCIC(:,4).*sind(PengCIC(:,5));

Peng_VR2023 = [
    62.66, 18.31, 19.12, 26.47, 46.23;
    65.08, 18.83, 18.87, 26.66, 45.05;    
    57.04, 17.88, 18.61, 25.81, 46.14;
    40.27, 17.77, 18.69, 25.79, 46.44;
];
CaoCIC=[[0,0,0,25.4,44.5];[0,0,0,24.5,43.7];[0,0,0,25.7,48.3];[0,0,0,23.0,48.0]];
CaoCIC(:,2)=CaoCIC(:,4).*cosd(CaoCIC(:,5));
CaoCIC(:,3)=CaoCIC(:,4).*sind(CaoCIC(:,5));

Zeng=[[0,18,21];[0,17,16];[0,0,0];[0,21,29]];%这个是肤色统计中心
interpreter_type="tex";
%%
L_my=[[68.9490886950538	16.0083688942274	18.1852700776910];
[69.8478673702026	18.3728292750543	15.3556270255683];
[34.4157426010246	17.1019300269014	17.5477809245091];
[21.8605731733526	11.6133442675167	10.2940701491645]];
xyz_my=lab2xyz2(L_my,"d65_64");
%%
curr_row=1;
%% sangers
clear("lab_est");
uv_esti = [    
    [0.222, 0.494];  % Mongoloid (蒙古人种)
    [0.218, 0.486] ;  % Caucasoid (高加索人种)
    [0,0];
    [0.232, 0.502];  % Negroid (尼格罗人种)
];
for i_eth=1:length(uv_esti)
    if uv_esti(i_eth,1)==0
        lab_est(i_eth,:)=[0,0,0];
    else
        xy_est=uv2xy(uv_esti(i_eth,:));
        xyz_est(i_eth,:)=xyY2xyz([xy_est,xyz_my(i_eth,2)]);
        lab_est(i_eth,:)=xyz2lab(xyz_est(i_eth,:),"d65_64");
        lab_est(i_eth,1)=0;
    end
end

prev_cell{curr_row,1}=lab_est;
prev_cell{curr_row,2}="Sangers et al. (1994)";
prev_cell{curr_row,3}=["Mongoloid","Caucasoid","","Negroid"];
prev_cell{curr_row,4}=["蒙古人种","高加索人种","","尼格罗人种"];
curr_row=curr_row+1;
%-----------Yano
clear("lab_est");
uv_esti = [    
    [0.2425, 0.4895];  % Japanese (日本女性)
];
for i_eth=1:size(uv_esti,1)
    if uv_esti(i_eth,1)==0
        lab_est(i_eth,:)=[0,0,0];
    else
        xy_est=uv2xy(uv_esti(i_eth,:));
        xyz_est(i_eth,:)=xyY2xyz([xy_est,xyz_my(i_eth,2)]);
        lab_est(i_eth,:)=xyz2lab(xyz_est(i_eth,:),"d65_64");
        lab_est(i_eth,1)=0;
    end
end

prev_cell{curr_row,1}=lab_est;
prev_cell{curr_row,2}="Yano et al. (1998)";
prev_cell{curr_row,3}=["Japanese woman"];
prev_cell{curr_row,4}=["日本女性"];
curr_row=curr_row+1;
%-----------Yamamoto2002
clear("lab_est");
lab_est=[[0,0,0];[0,0,0];[0,0,0];[0,0,0];
    [76.98	17.43	18.29];
[74.88	17.18	19.24];
[78.12	16.4	13.74]];

lab_est(1,:)=mean(lab_est(5:7,:),1);
prev_cell{curr_row,1}=lab_est;
prev_cell{curr_row,2}="Yamamoto et al. (2002)";
prev_cell{curr_row,3}=["","","","","Japanese observer","Korean observer","Chinese observer"];
prev_cell{curr_row,4}=["","","","","日本人观察者","韩国人观察者","中国人观察者"];
curr_row=curr_row+1;
%-----------Kuang
clear("lab_est");
lab_est = [    
    [0,11.6443, 22.2768]; 
    [0,26.3087, 39.6875] ;  
    [0,22.5503,31.0268];
    [0,18.6577, 29.4196];  
];


prev_cell{curr_row,1}=lab_est;
prev_cell{curr_row,2}="Kuang et al. (2005)";
prev_cell{curr_row,3}=["Asian","Caucasian","Indian","African-American"];
prev_cell{curr_row,4}=["亚洲人","白人","印度人","非裔美国人"];
curr_row=curr_row+1;
%----------------
clear("lab_est");
YCbCr =[[121.9	104.62	157.28];
[157.2	104.33	153.11];
[0	0	0];
[95.7	111.56	150.21];
[136.3 105.59 153.93]];
for i_eth=1:size(YCbCr,1)
    if YCbCr(i_eth,1)==0
        lab_est(i_eth,:)=[0,0,0];
    else
        lab_est(i_eth,:) = ycbcr2lab(YCbCr(i_eth,:), true);
    end
end
prev_cell{curr_row,1}=lab_est;
prev_cell{curr_row,2}="Park et al. (2006)";
prev_cell{curr_row,3}=["Asian","Caucasian","Indian","African-American","Mixed"];
prev_cell{curr_row,4}=["亚洲人","白人","印度人","非裔美国人","混合人种"];
curr_row=curr_row+1;
%-----------Zeng2009
% clear("lab_est");
% lab_est = [    
%     [59,19, 20];  
%     [59,19, 20] ;  
%     [0,0,0];
%     [0,18.5,19.5];  
% ];
% 
% 
% prev_cell{curr_row,1}=lab_est;
% prev_cell{curr_row,2}="Zeng et al. (2009)";
% prev_cell{curr_row,3}=["Oriental","Caucasian","","Dark skin"];
% prev_cell{curr_row,4}=["东方人","白种人","","深色皮肤"];
% curr_row=curr_row+1;

%-----------Zeng2010
% clear("lab_est");
% lab_est = [[0,0, 0];
%     [0,0, 0];
%     [0,0, 0];
%     [0,0, 0];
%     [0,21, 24]];
% 
% 
% prev_cell{curr_row,1}=lab_est;
% prev_cell{curr_row,2}="Zeng et al. (2010)";
% prev_cell{curr_row,3}=["","","","","Mixed"];
% prev_cell{curr_row,4}=["","","","","混合人种"];
% curr_row=curr_row+1;
%-----------Zeng2011
clear("lab_est");
% lab_est = [[0,18,21];[0,17,16];[0,0,0];[0,21,29]];%这个是统计喜好中心
lab_est = [[0,19.9, 22.8];
    [0,21.4, 24.1];
    [0,0, 0];
    [0,21.2, 24.8]];
xyz_est=lab2xyz2(lab_est,"d65_64");
wd65=CCT2xyz(6500,0,10);
wd50=CCT2xyz(5000,0,10);
F=0.8;
omega=2*pi*(1-cos(pi/36));
S=0.0124; %164.07*75.57*(10^(-6))
E=120;
LA=E./S.*omega;
D = F*(1-(1/3.6)*exp((-LA-42)/92));
XYZ_aft = CAT16_D(xyz_est,  wd65,wd50, D);
lab_est = xyz2lab(XYZ_aft, 'd65_64');

prev_cell{curr_row,1}=lab_est;
prev_cell{curr_row,2}="Zeng et al. (2011)";
prev_cell{curr_row,3}=["Oriental","Caucasian","","African"];
prev_cell{curr_row,4}=["东方人","白种人","","非洲人"];
curr_row=curr_row+1;

%-----------Deng 2013
clear("lab_est");
lab_est=[[0,0, 0];
    [0,0, 0];
    [0,0, 0];
    [0,0, 0];
    [64.4	16.1	16.3];
[64.7	15.6	16.3];
[65.3	14.8	15.4];
[65.2	15.3	15.6]];
prev_cell{curr_row,1}=lab_est;
prev_cell{curr_row,2}="Deng et al. (2013)";
prev_cell{curr_row,3}=["","","","",...
    "Japanese male observer","Japanese female observer",...
    "Chinese male observer","Chinese female observer"];
prev_cell{curr_row,4}=["","","","",...
    "日本男性观察者","日本女性观察者","中国男性观察者","中国女性观察者"];
curr_row=curr_row+1;
%-----------Peng2020
clear("lab_est");
lab_est = PengCIC(:,1:3);

prev_cell{curr_row,1}=lab_est;
prev_cell{curr_row,2}="Peng et al. (2020)";
prev_cell{curr_row,3}=["Oriental","Caucasian","South Asian","African"];
prev_cell{curr_row,4}=["东方人","白种人","南亚人","非洲人"];
curr_row=curr_row+1;

%----------Peng_VR2023
clear("lab_est");
lab_est = Peng_VR2023(:,1:3);

prev_cell{curr_row,1}=lab_est;
prev_cell{curr_row,2}="Peng et al. (2023)";
prev_cell{curr_row,3}=["Oriental","Caucasian","South Asian","African"];
prev_cell{curr_row,4}=["东方人","白种人","南亚人","非洲人"];
curr_row=curr_row+1;

%-----------Cao2020
clear("lab_est");
lab_est = CaoCIC(:,1:3);

prev_cell{curr_row,1}=lab_est;
prev_cell{curr_row,2}="Cao et al. (2020)";
prev_cell{curr_row,3}=["Oriental Asian","Caucasian","South Asian","African"];
prev_cell{curr_row,4}=["东亚人","白种人","南亚人","非洲人"];
curr_row=curr_row+1;
prev_cell([1,4],:)=[];
%%
length_color=4;

hue_values = linspace(0, 1, length_color + 1);hue_values = hue_values(1:end-1);
hsv_matrix = [hue_values', 0.8 * ones(length_color, 1), 0.8 * ones(length_color, 1)];
colors_temp = hsv2rgb(hsv_matrix);
colors=[[0.7 0 0];[0 0.5 0];[0 0 0];[1 0.5 0];[0.2 0.2 1];
    [1 0 1];[0.5 0.5 0.5];
    [1, 0.75, 0.8];[0.6, 0.2, 0.8];[0.6, 0.4, 0.2]];
colors(1:2,:)=colors_temp(1:2,:);
%%
labCh_PMCC=[[62.11	18.96	19.76	27.39	46.18];...
            [64.15	19.56	19.63	27.71	45.10];...
            [56.01	18.25	18.72	26.14	45.72];...
            [41.06	17.37	17.94	24.97	45.93]];
if strcmp(Dtype,"efit_p_free")
    ellip_pic_folder="ellip_pic_p_free";
elseif strcmp(Dtype,"efit_p")
    ellip_pic_folder="ellip_pic_p";
end

% label_type="ACSA";
label_type="only_my";
% label_type="include_this";
% label_type="exclude_this";
output_folder=fullfile(ellip_pic_folder,Dtype,"compare_thesis_pre",label_type);

if ~exist(output_folder,"dir")
    mkdir(output_folder);
end

ethnic_names=["Asian","Caucasian","South Asian","African"];
ethnic_names_Ch=["亚洲人","高加索人","南亚人","非洲人"];
ethnic_groups=["1AS","2CA","3SA","4AF"];
figure(1);
lab_pre_all=[];author_all={};
res_matrix=[];curr=1;
% for i_eth=1
for i_eth=1:size(ethnic_groups,2)
    if strcmp(label_type,"only_my")&&i_eth>1
        continue
    end
    
    % grid on;
    box on;
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

    % 计算等高线数据
    a = par;
    y = (1./(1+a(6)*exp(sqrt(a(1)*(data2-a(4)).^2+a(2)*(data3-a(5)).^2+ ...
        a(3)*(data2-a(4)).*(data3-a(5)))))).*((a(1)*(data2-a(4)).^2+ ...
        a(2)*(data3-a(5)).^2+a(3)*(data2-a(4)).*(data3-a(5)))>=0);
    
    % 绘制等高线
    if strcmp(label_type,"only_my")
    % if strcmp(label_type,"only_my")||strcmp(label_type,"include_this")
        color=[0 0 0];
    else
        color=colors(i_eth,:);
    end
    if strcmp(label_type,"include_this")||strcmp(label_type,"only_my")
        s0 = contour(data2, data3, y, [0.5, 1], 'LineWidth', 1.5, ...
             'Color', color);

        hold on;
        % 绘制特殊点
        plot(par(4), par(5), 'o', 'MarkerSize', 4, ...
            'MarkerFaceColor', color, 'Color', 'k');
            res_matrix=[res_matrix;center(i_eth,:)];
            res_cell{curr,1}=center(i_eth,:);
            res_cell{curr,2}=ethnic_groups(i_eth);
            curr=curr+1;
        
    end
    
    
    
    axis equal
    if strcmp(text_type,"eng")&&strcmp(label_type,"exclude_this")
        min_lim=12;
        max_lim=26;

    else
        min_lim=0;
        max_lim=40;
    end

    xlim([min_lim,max_lim])
    ylim([min_lim,max_lim])
    interval = 5;
    xticks(0:interval:max_lim);
    yticks(0:interval:max_lim);
    x = linspace(min_lim, max_lim, 1000);
    y = x;
    plot(x, y,'Color','k','LineStyle','--','LineWidth',1);
    if i_eth==1
        if ~strcmp(label_type,"only_my")
            for i_prev=1:size(prev_cell,1)
                for i_eth1=1:size(prev_cell{i_prev,1},1)
                    lab_pre=prev_cell{i_prev,1}(i_eth1,:);
                    
                    lab_pre(:,4)=sqrt(lab_pre(:,2).^2+lab_pre(:,3).^2);
                    lab_pre(:,5)=atan2d(lab_pre(:,3),lab_pre(:,2));
                    lab_pre_all=[lab_pre_all;lab_pre];
                    author_str=char(prev_cell{i_prev,2});
    
                    if lab_pre(1,2)~=0
                    if strcmp(author_str,"Park et al. (2006)")
                        author_str_used="Pa";
                    elseif strcmp(author_str,"Peng et al. (2020)")
                        author_str_used="P3";
                    elseif strcmp(author_str,"Peng et al. (2023)")
                        author_str_used="P";
                    elseif strcmp(author_str,"Zeng et al. (2010)")
                        author_str_used="Z1";
                    elseif strcmp(author_str,"Zeng et al. (2011)")
                        author_str_used="Z";
                    elseif strcmp(author_str,"Yano et al. (1998)")
                        author_str_used="Yn";
                    elseif strcmp(author_str,"Yamamoto et al. (2002)")
                        author_str_used="Ym";
                    else
                        author_str_used=author_str(1);
                    end
    
                    author_all{end+1,1}=strcat(author_str," ",prev_cell{i_prev,3}(i_eth1));
                    author_all{end,2}=strcat(strrep(author_str," et al.","等人")," ",prev_cell{i_prev,4}(i_eth1));
                    author_all{end,3}=colors(i_eth1,:);
                    author_all{end,4}=author_str_used;
                    target_text_size=8;
                    if ~(strcmp(label_type,"ACSA")&&i_eth1>4)
                        text(lab_pre(1, 2), lab_pre(1, 3), ...
                             author_str_used, 'FontSize', target_text_size, ...
                             'VerticalAlignment', 'top', 'Color', colors(i_eth1,:), ...
                             'FontWeight', 'bold');  % 新增字体加粗参数
                    end
                    end
                    % scatter(lab_pre(1,2), lab_pre(1,3), 20, '^', 'LineWidth', 1, ...
                    % 'MarkerEdgeColor',colors(i_eth,:));
                end
            end
        end
        disp("d")
    end
    if ~strcmp(label_type,"only_my")
        scatter(labCh_PMCC(i_eth,2), labCh_PMCC(i_eth,3), 40, 's', 'LineWidth', 1, ...
        'MarkerEdgeColor',colors(i_eth,:),'MarkerFaceColor','none');
    end

    if strcmp(interpreter_type,"tex")
        xlabel('a^{*}','Interpreter','tex','FontName','Arial','FontAngle','italic', ...
            'FontSize',12*1.2);
        ylabel('b^{*}','Interpreter','tex','FontName','Arial','FontAngle','italic', ...
            'FontSize',12*1.2);
    elseif strcmp(interpreter_type,"latex")
        xlabel('$a^{*}$','Interpreter','latex', 'FontSize',12*1.2);
        ylabel('$b^{*}$','Interpreter','latex', 'FontSize',12*1.2);
    end
    if strcmp(label_type,"include_this")
        author_all{end+1,1}=strcat("This experiment",ethnic_names(i_eth));
        author_all{end,2}=strcat("本实验",ethnic_names_Ch(i_eth));
        author_all{end,3}=colors(i_eth,:);
        author_all{end,4}=".";
    end
end
%%
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

res_matrix=[res_matrix;par(5:7)];
res_cell{curr,1}=par(5:7);
res_cell{curr,2}="OPPO";
curr=curr+1;
% 绘制等高线
if strcmp(label_type,"only_my")||strcmp(label_type,"include_this")
    color=[0 0 0];
else
    color=colors(1,:);
end
if strcmp(label_type,"include_this")||strcmp(label_type,"only_my")
    if strcmp(text_type,"ch")
        s0 = contour(data2, data3, y, [0.5, 1], 'LineWidth', 1, 'LineStyle','--',...
             'Color', color);
    end
    hold on;
    if strcmp(text_type,"ch")
        % 绘制特殊点
        plot(par(6), par(7), 'p', 'MarkerSize', 10, ...
            'MarkerFaceColor', color, 'Color', color);
    end
end


%%

Dtype="efit_p";
L_exp_folder="D:\work\FirstYearMaster\SkinColorPreferenceScale\AnalyseResults_p\efit_p\scaled\fitRes";
data_L_exp=load(fullfile(L_exp_folder,"fitRes_level_p.mat"));

n_para=size(data_L_exp.par_all,1);
for i_level=1:n_para
    par=data_L_exp.par_all(i_level,:);
    if strcmp(label_type,"include_this")
        color=[0,0,0];
    else
        color=colors(i_level,:);
    end
    % 计算等高线数据
    a = par;
    y = (1./(1+a(6)*exp(sqrt(a(1)*(data2-a(4)).^2+a(2)*(data3-a(5)).^2+ ...
        a(3)*(data2-a(4)).*(data3-a(5)))))).*((a(1)*(data2-a(4)).^2+ ...
        a(2)*(data3-a(5)).^2+a(3)*(data2-a(4)).*(data3-a(5)))>=0);
    
    % 绘制等高线
    if strcmp(label_type,"include_this")||strcmp(label_type,"only_my")
        if strcmp(text_type,"ch")
            s0 = contour(data2, data3, y, [0.5, 1], 'LineWidth', 1,'LineStyle',':', ...
                 'Color', color);
        end
        hold on;
        if strcmp(text_type,"ch")
            % 绘制特殊点
            plot(par(4), par(5), 'x', 'MarkerSize', 8, ...
                'MarkerFaceColor', color, 'Color', color,"LineWidth",1.5);
                res_matrix=[res_matrix;center(i_eth,:)];
                res_cell{curr,1}=center(i_eth,:);
                res_cell{curr,2}=ethnic_groups(i_eth);
                curr=curr+1;
        end
    end
    % plot(par(4), par(5), 'x', 'MarkerSize', 8, ...
    %     'MarkerFaceColor', color, 'Color', color);
end
%%

ax = gca;
targetFontSize=12;
set(ax, 'FontSize', targetFontSize);
if strcmp(interpreter_type,"tex")
    xlabel('a^{*}','Interpreter','tex','FontName','Arial','FontAngle','italic', ...
        'FontSize',1.2*targetFontSize);
    ylabel('b^{*}','Interpreter','tex','FontName','Arial','FontAngle','italic', ...
        'FontSize',1.2*targetFontSize);
elseif strcmp(interpreter_type,"latex")
    xlabel('$a^{*}$','Interpreter','latex', 'FontSize',1.2*targetFontSize);
    ylabel('$b^{*}$','Interpreter','latex', 'FontSize',1.2*targetFontSize);
end
% set(findobj(gcf, 'Type', 'Text'), 'FontSize', targetFontSize); % 针对 LaTeX 标签

% view_settings = {
%     [12, 26, 12, 26], '';           % 原始范围
%     [16, 20, 16, 20], '_zoomed'     % 新增范围 [18, 21]
% };
view_settings = {
    [0, 40, 0, 40], '';           % 原始范围
    [16, 20, 16, 20], '_zoomed'     % 新增范围 [18, 21]
};
% zoom_rect = [16, 16, 4, 4];
for s_idx = 1:1
% for s_idx = 1:size(view_settings, 1)
    % fig_handles(s_idx) = figure(s_idx);
    current_lims = view_settings{s_idx, 1};
    suffix = view_settings{s_idx, 2};
    
    % 更新坐标轴
    if strcmp(label_type,"exclude_this")
        current_lims=[12,26,12,26];
    end
    xlim([current_lims(1), current_lims(2)]);
    ylim([current_lims(3), current_lims(4)]);
    
    % 更新刻度（如果是 18-21，建议刻度加密，例如 0.5 间隔
    interval=round((view_settings{s_idx,1}(2)-view_settings{s_idx,1}(1))/4);
    xticks(view_settings{s_idx,1}(1):interval:view_settings{s_idx,1}(2));
    yticks(view_settings{s_idx,1}(3):interval:view_settings{s_idx,1}(4));
    % --- 3. 针对不同图片的特殊处理 ---
    % if s_idx == 1
    %     % 第一张图：让标签离轴远一点
    %     % 方法：调整 Label 的 Position (也可以用 XLabel.VerticalAlignment)
    %     xl = xlabel('$a^*$', 'Interpreter', 'latex');
    %     yl = ylabel('$b^*$', 'Interpreter', 'latex');
    % 
    %     % 获取当前位置并向下/向左偏移 (具体数值可根据 600dpi 的观感微调)
    %     xl.Units = 'normalized';
    %     xl.Position(2) = xl.Position(2) - 0.05; % Y轴方向向下移
    %     yl.Units = 'normalized';
    %     yl.Position(1) = yl.Position(1) - 0.05; % X轴方向向左移
    % 
    %     % 在第一张图上画虚线矩形框
    %     % hZoomBox = rectangle('Position', zoom_rect, 'EdgeColor', 'k', ...
    %     %           'LineWidth', 1.5, 'LineStyle', '--');
    % 
    % elseif s_idx == 2
    %     % 第二张图：去掉标签
    %     xlabel('');
    %     ylabel('');
    %     delete(findall(gca, 'Type', 'rectangle', 'LineStyle', '--'));
    % end
    child_objs = get(gca, 'Children');
    set(child_objs, 'Clipping', 'on');
    drawnow;
    
    % 构造文件名
    base_name = strcat(label_type, 'compare_thesis_pre', suffix);
    img_name = fullfile(output_folder, strcat(base_name, '.jpg'));
    fig_name = fullfile(output_folder, strcat(base_name, '.fig'));
    
    % 保存
    savefig(gcf, fig_name);
    exportgraphics(gcf, img_name, 'Resolution', 600);
    
    fprintf('已保存: %s\n', img_name);
end




% 保持后续的数据保存逻辑
save(fullfile(output_folder,"author_colors.mat"),"author_all","prev_cell");


fullfile(pwd,output_folder)

% concatenate_images1(output_folder,4);
%%



if strcmp(label_type,"only_my")
    if strcmp(interpreter_type,"latex")
    s.labels_row1 = {"$L^*$=10","$L^*$=20","$L^*$=30","$L^*$=40",...
        "$L^*$=50","$L^*$=60","$L^*$=70","$L^*$=80","实验二","实验三"};
    elseif strcmp(interpreter_type,"tex")
            s.labels_row1 = {"\itL^*\rm=10","\itL^*\rm=20","\itL^*\rm=30","\itL^*\rm=40",...
        "\itL^*\rm=50","\itL^*\rm=60","\itL^*\rm=70","\itL^*\rm=80","实验二","实验三"};
    end
    s.labels_row2 = {};
    s.markers_row2 = {};
    % s.markers_colors = [];
    s.markers_colors = colors;
    s.markers_face_colors = [];
    s.n_col1=3; 
    s.n_col2=3;
    s.if_label=false;
    s.markers_row1_last2={"p","o"};
    s.leg_x_shift=-0.09;
    s.marginL=0.3;

    num_attributes = numel(s.labels_row1);
    hue_values = linspace(0, 1, num_attributes + 1);
    hue_values = hue_values(1:end-1);
    hsv_matrix = [hue_values', 0.8 * ones(num_attributes, 1), 0.8 * ones(num_attributes, 1)];
    s.colors_row1 = hsv2rgb(hsv_matrix);


    s.label_type="only_my";
    dir_figs=dir(fullfile(output_folder,"only_mycompare_thesis_pre.fig"));
    clear("figFiles")
    for i_fig=1:length(dir_figs)
        figFiles{i_fig}=dir_figs(i_fig).name;
    end
    s.interpreter_type=interpreter_type;
    concatenate_figs_legend1(output_folder, figFiles, 1,"none","draw",s,0.09,1.2);
elseif strcmp(label_type,"compare_thesis_pre")
    opts.targetFontSize=12;
    opts.margin=0.2;    
    opts.label_type="compare_thesis_pre";
    opts.if_rotate=false;
    % opts.bar_interval=0.4;
    adjust_fig(save_folder, opts);
    s.labels_row1 = {"$L^*$=10","$L^*$=20","$L^*$=30","$L^*$=40",...
        "$L^*$=50","$L^*$=60","$L^*$=70","$L^*$=80","实验二","实验三"};
    s.labels_row2 = {};
    s.markers_row2 = {};
    s.markers_colors = [];
    s.markers_face_colors = [];
    s.n_col1=3; 
    s.n_col2=3;
    s.if_label=false;
    s.markers_row1_last2={"p","o"};
    s.leg_x_shift=-0.09;
    s.marginL=0.3;

    num_attributes = numel(s.labels_row1);
    hue_values = linspace(0, 1, num_attributes + 1);
    hue_values = hue_values(1:end-1);
    hsv_matrix = [hue_values', 0.8 * ones(num_attributes, 1), 0.8 * ones(num_attributes, 1)];
    s.colors_row1 = hsv2rgb(hsv_matrix);


    s.label_type="only_my";
    dir_figs=dir(fullfile(output_folder,"only_mycompare_thesis_pre.fig"));
    clear("figFiles")
    for i_fig=1:length(dir_figs)
        figFiles{i_fig}=dir_figs(i_fig).name;
    end

    concatenate_figs_legend1(output_folder, figFiles, 1,"none","draw",s,0.09,1.2);

    % elseif strcmp(label_type,"exclude_this")
    % 
    % 
    % s.labels_row1 = {};
    % s.labels_row2 = {};
    % s.markers_row2 = {};
    % s.markers_colors = [];
    % s.markers_face_colors = [];
    % s.n_col1=2; 
    % s.n_col2=2;
    % s.if_label=false;
    % s.markers_row1_last2={};
    % s.leg_x_shift=-0.09;
    % s.marginL=0.3;
    % 
    % 
    % s.label_type="exclude_this";
    % figFiles={"exclude_thiscompare_thesis_pre.fig",...
    %     "exclude_thiscompare_thesis_pre_zoomed.fig"};
    % 
    % concatenate_figs_legend1(output_folder, figFiles, 2,"none","draw",s,0.04,1.2);

end