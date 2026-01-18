function [outnew,outxyz,kL,outnew2,outofgamut]=imgcat2_1(img,bull,actualwhite,targetwhite,white0,w,string,i,i_points)
% outnew 是(targetwhite)标准D65，Y=100作为参考白时的结果，图像亮度Y归一化到0-100，所有像素的xyz均乘以亮度系数kL，可以作为渲染结果使用，因为参考光源恒定为D65，Y=100
% outxyz同理，使用Y=100标准D65转换到lab
matrix=1
% outnew2 是(targetwhite)D65，亮度保持原图亮度的结果，xyz没有乘系数，而是参考白D65的亮度Y=100*kL,可以用作白平衡，因为每个参考白都根据图片亮度做了适应
switch string
    case 'srgb'
        matrix=1;
    case 'polynomial'
        matrix=2;
    case 'LUT'
        matrix=3;
end

[m,n,p]=size(img);
out=reshape(img,[m*n,p]);%展开
xyz2=zeros(size(out));
% xyz1=zeros(size(out));
% rgbnew=zeros(size(out));
% rgbnew2=zeros(size(out));

% dataLUT=load("data_sorted53_3.mat");%不管前面的actualwhite直接用手机测到的白
% actualwhite=dataLUT.XYZw;
kL=100/actualwhite(2);
whitemodify=actualwhite*kL;
datai_file='datai_sorted53_3.mat';

if matrix==1
    xyz=srgb2xyz(out);
end
if matrix==2
    xyz=rgb2xyz(out,w);
end
if matrix==3
    out=out*255;
    xyz = lut3d_rgb2xyz1(out,datai_file);
    disp("lut3d_rgb2xyz1 over");
end

xyz1=xyz*kL;


xyz2 = SimpleTwostepCAT (xyz1,whitemodify,targetwhite,white0,'CAT16',1,1);
xyz2_1=xyz2;
xyz2(bull==0)=xyz(bull==0);
xyz3 = xyz2/kL;

% [rgbnew,flag,outofgamut]=xyz2srgb_1(xyz2);%xyz变回srgb，如需变为RGB，需要额外函数
datafile='D:\oppoSkinExperi\memoryAWB-simplify\data_ipv40_3.mat';
rgbnew=lut3d_xyz2rgbipv(xyz2,datafile,i,i_points);
% rgbnew2=lut3d_xyz2rgb1(xyz3,datafile);%xyz变回srgb，如需变为RGB，需要额外函数
rgbnew2=xyz2srgb(xyz3);%xyz变回srgb，如需变为RGB，需要额外函数

outxyz=reshape(xyz2,[m,n,p]);
outnew=reshape(rgbnew,[m,n,p]);
outnew2=reshape(rgbnew2,[m,n,p]);
