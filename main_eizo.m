clear;clc;close all

addpath(genpath('E:\Johnny\WORK\Toolbox'))
addpath(genpath('utils'))

load RGB96.mat;
rgb96=RGB;
RGB = RGB/255;

i_device=1;
dir_96data=dir("eizo\*.mat");

SPDname = 380:1:780;SPDname = SPDname';
load(fullfile(dir_96data(i_device).folder,dir_96data(i_device).name));


% load("Z:\homes\Peggy\VIVOskinExpe\calibResults\96\" + ...
%     "VIVO_CS2000_96_3.mat");
% DATAs(1,:) = [];
% SPD = reshape(cell2mat(DATAs(:,4)),401,96);
XYZ10 = spd2xyz([SPDname SPD],10);

% XYZ_table=readtable("Z:\homes\Peggy\oppoSkinExperi\LUT3d\results\" + ...
%     "test-color-patch-3-96.csv");
% XYZ_spd=table2array(XYZ_table(:,1:end));
% SPDname = 380:1:780;
% SPDname = SPDname';
% XYZ10 = spd2xyz([SPDname XYZ_spd'],10);

disp('CIE1964 10 degree');
XYZ=XYZ10;
% display characterization model
R=1;G=R;B=R; %input data for the forward model
% load r; load g; load b; load grey; %load the corresponding XYZ values
r=XYZ(1:18,:);g=XYZ(19:36,:);b=XYZ(37:54,:);grey=XYZ(55:72,:);
%------------三通道归一化-----------
black=mean([r(1,:);g(1,:);b(1,:)]);%to find the ideal XYZ value for individual r,g,b channels
r=bsxfun(@minus, r, r(1,:));%r=r-r(1,:)
g=bsxfun(@minus, g, g(1,:));
b=bsxfun(@minus, b, b(1,:));
% grey=bsxfun(@minus, grey, grey(1,:));
max_RGB=[r(end,:);g(end,:);b(end,:)]';
LR=r(:,1)/r(end,1);
LG=g(:,2)/g(end,2);
LB=b(:,3)/b(end,3);
%------------三通道归一化------------
xdata=[0:15:255]/255;
% figure
% plot(xdata,LR,'.');
%------------拟合得到每个颜色通道的系数------------
coef_r=lsqcurvefit(@gog,[1 1 1],xdata',LR,[0,-Inf,-Inf],[Inf,Inf,Inf]);% coef_r=real(coef_r); %coef:kg,ko,gamma
coef_g=lsqcurvefit(@gog,[1 1 1],xdata',LG,[0,-Inf,-Inf],[Inf,Inf,Inf]);% coef_g=real(coef_g);%coef:kg,ko,gamma
coef_b=lsqcurvefit(@gog,[1 1 1],xdata',LB,[0,-Inf,-Inf],[Inf,Inf,Inf]);% coef_b=real(coef_b);%coef:kg,ko,gamma

% coef_r=real(lsqcurvefit(@gog,[1 1 1],xdata',LR,-Inf,Inf));% coef_r=real(coef_r); %coef:kg,ko,gamma
% coef_g=real(lsqcurvefit(@gog,[1 1 1],xdata',LG,-Inf,Inf));% coef_g=real(coef_g);%coef:kg,ko,gamma
% coef_b=real(lsqcurvefit(@gog,[1 1 1],xdata',LB,-Inf,Inf));% coef_b=real(coef_b);%coef:kg,ko,gamma
%----------算拟合曲线预测亮度，小于0的截断----------
Lr=real(gog(coef_r,xdata));Lr(Lr<0)=0;
Lg=real(gog(coef_g,xdata));Lg(Lg<0)=0;
Lb=real(gog(coef_b,xdata));Lb(Lb<0)=0;

%----将归一化后的光亮度值转换为实际的 XYZ 颜色空间值，并加上黑色基准值-----
XYZ_rgb_plus=bsxfun(@plus,max_RGB*[Lr;Lg;Lb],black');%XYZ_rgb_plus=max_RGB*[Lr;Lg;Lb]+black'
XYZ_rgb_plus=XYZ_rgb_plus';

%-----------计算正向灰阶色差----------
lab1=xyz2lab(grey,'user',grey(end,:));
lab2=xyz2lab(XYZ_rgb_plus,'user',grey(end,:));
result1=cielabde(lab1,lab2);
result1_00=deltaE2000(lab1,lab2);
disp('Color difference for 18 grey channels:')
mean_result1=mean(result1);
max_result1=max(result1);
std_result1=std(result1);

mean_result1_00=mean(result1_00);
disp(strcat("mean dEab: ",num2str(mean_result1)));
disp(strcat("max dEab: ",num2str(max_result1)));
disp(strcat("std dEab: ",num2str(std_result1)));
% disp(num2str(mean(result1_00)));
savefile=['Z:\homes\Peggy\FirstYearMaster\MATLAB\SkinColorPreferenceScale\gog\' ...
    'GOGpara.mat'];
save(savefile,'black','coef_r','coef_g','coef_b','max_RGB','result1');

%---------计算逆向灰阶色差-----------
%测到的灰阶XYZ->RGB
%XYZ2RGB:
load(savefile);
XYZ_R=bsxfun(@minus,grey',black');
L_RGB=inv(max_RGB)*XYZ_R;%scaled lightness for each channel
rdata=gog_r(coef_r,L_RGB(1,:));%Scaled R data
gdata=gog_r(coef_g,L_RGB(2,:));
bdata=gog_r(coef_b,L_RGB(3,:));

%RGB2XYZ:
load(savefile);
Lr=gog(coef_r,rdata);Lr(Lr<0)=0;
Lg=gog(coef_g,gdata);Lg(Lg<0)=0;
Lb=gog(coef_b,bdata);Lb(Lb<0)=0;
XYZ_rgb_plus=bsxfun(@plus,max_RGB*[Lr;Lg;Lb],black');

XYZ_rgb_plus=XYZ_rgb_plus';
lab1=xyz2lab(grey,'user',grey(end,:));
lab2=xyz2lab(XYZ_rgb_plus,'user',grey(end,:));
result2=cielabde(lab1,lab2);
result2_00=deltaE2000(lab1,lab2);
disp('Color difference of quantum error:')

mean_result2_00=mean(result2_00);

mean_result2=mean(result2);
max_result2=max(result2);
std_result2=std(result2);

disp(strcat("mean dEab: ",num2str(mean_result2)));
disp(strcat("max dEab: ",num2str(max_result2)));
disp(strcat("std dEab: ",num2str(std_result2)));

load(savefile);
RGB_24=RGB(73:96,:);
XYZ_24=display_f(RGB_24,savefile);
XYZ_24_M=XYZ(73:96,:);
lab1=xyz2lab(XYZ_24,'user',XYZ(72,:));
lab2=xyz2lab(XYZ_24_M,'user',XYZ(72,:));
result3=cielabde(lab1,lab2);
result3_00=deltaE2000(lab1,lab2);
disp('Color difference for 24 color patches:')
mean_result3_00=mean(result3_00);
mean_result3=mean(result3);
max_result3=max(result3);
std_result3=std(result3);
mean_result_skin=mean(result3(1:2,1));
max_result_skin=max(result3(1:2,1));
std_result_skin=std(result3(1:2,1));
disp(strcat("mean dEab: ",num2str(mean_result3)));
disp(strcat("max dEab: ",num2str(max_result3)));
disp(strcat("std dEab: ",num2str(std_result3)));
disp('Color difference for 2 skin color patches:')
disp(strcat("mean dEab: ",num2str(mean_result_skin)));
disp(strcat("max dEab: ",num2str(max_result_skin)));
disp(strcat("std dEab: ",num2str(std_result_skin)));
% disp(num2str(mean(result3_00)));

save(savefile,'black','coef_r','coef_g','coef_b','max_RGB', ...
    'result1','result2','result3','mean_result3','mean_result2','mean_result1');


