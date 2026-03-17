close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量

%%
source_folder=fullfile('AlalyseResults\rpl\1k\indoorAdd\ellipPara_scaled');
source_file=fullfile(source_folder,"fitRes_level.mat");
sceneCens=load(source_file);
lab_group=sceneCens.par_all(:,5:7);

slashes = strfind(source_folder, '\');
lastPart = source_folder(slashes(1,end-1)+1:slashes(1,end)-1);

wd65=[94.811 100.00 107.304];
lab_PMCC=[62.11,18.96,19.76];

load("CATed\iNrs\CATedPre.mat","XYZw_pre_all","picname");
XYZw_pre_all=XYZw_pre_all./XYZw_pre_all(:,2).*wd65(2);

if strcmp(lastPart,"indoorAdd")
    XYZw_pre=XYZw_pre_all(15:24,:);
    picname_scene=picname(15:24,:);
elseif strcmp(lastPart,"nightAdd")
    XYZw_pre=XYZw_pre_all(25:34,:);
    picname_scene=picname(25:34,:);
elseif strcmp(lastPart,"outdoorAdd")
    XYZw_pre=XYZw_pre_all(35:44,:);
    picname_scene=picname(35:44,:);
elseif strcmp(lastPart,"sunsetAdd")
    XYZw_pre=XYZw_pre_all(44:52,:);
    picname_scene=picname(44:52,:);
end
%%
%CAT

lab_bf=lab_group;
XYZ_bf=lab2xyz2(lab_bf,'d65_64');

for i_scene=1:size(XYZ_bf,1)
    [CCT(i_scene,1),duv(i_scene,1),S_out{i_scene,1}] = xyz2CCT(XYZw_pre(i_scene,:),10);
    D3(i_scene,1)=0.00005*CCT(i_scene,1)+0.1977;
    XYZ_aft(i_scene,:) = CAT16_D(XYZ_bf(i_scene,:), XYZw_pre(i_scene,:), wd65, D3(i_scene,1));
end
lab_group=xyz2lab(XYZ_aft,'d65_64');
%%
if strcmp(lastPart,"indoorAdd")
    lab_group(5,:)=[];
elseif strcmp(lastPart,"sunsetAdd")
    lab_group([1,2,3,8],:)=[];
end
%%
% 拟合椭球并保存结果
% [ center_cherry, radii, evecs, v, chi2 ] = ellipsoid_fit( lab_group,'');
% [ r_ellipse,X0,Y0,a,b,phi ] = Fit95Ellipse( lab_group,0.95 );
% [r_ellipsoid, center_Alan, axis,  phi, theta, psi] = Fit95Ellipsoid1(lab_group,0.95);
[center,mu,chi2_val,List] =fit95ellip_my(lab_group, 0.05, 3);
%------保存参数------
save_folder='AlalyseResults\rpl\fit95';
output_folder=fullfile(save_folder,'ellipPara');
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end
save(fullfile(output_folder, strcat(lastPart,"fitRes_level.mat")), ...
    'center', 'mu','List');
%--------画椭球----
output_folder=fullfile(save_folder,'ellipsoid');
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end
f=plot95ellip(center,mu,lab_group,chi2_val,output_folder,lastPart); 
%--------画椭圆-----
output_folder=fullfile(save_folder,'ellipsoid_sections');
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end
contour95ellip(center,mu,lab_group,chi2_val,output_folder,lastPart); 



%%
save_folder='AlalyseResults\rpl\fit95';
output_folder=fullfile(save_folder,'ellipPara');
scene_name=["indoorAdd","nightAdd","outdoorAdd","sunsetAdd"];
center_all=[];mu_all=[];List_all=[];
for i_scene=1:length(scene_name)
    load(fullfile(output_folder, strcat(scene_name(i_scene),"fitRes_level.mat")), ...
        'center', 'mu','List');
    center_all=[center_all;center];
    mu_all=[mu_all;mu];
    List_all=[List_all;List];
end
muNcen_all=[mu_all,center_all];

