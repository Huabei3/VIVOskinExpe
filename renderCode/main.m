    
folder = 'Z:\homes\Peggy\FirstYearMaster\MATLAB\SkinColorPreferenceScale\ori\';  % 文件夹路径
files = dir(fullfile(folder, '*.jpg'));  % 读取文件夹中的所有.jpg文件

outfolder=fullfile(folder,'rendered');
if exist(outfolder,'dir')==0
    mkdir(outfolder);
end


for i = 1:numel(files)  %改为1：numel(files),可以实现对文件夹中图片进行批量操作
    close all
    white65=[95.04,100,108.89];%d65_31

    spq=1;
    mode=3;         %1 caucasian,2 brown,3 chinese,4 sky ,5 grass，6 black
    load zip/w.mat   %相机修正参数
    
    filename = fullfile(folder, files(i).name);  % 获取文件名,包含路径
    img0=imread(filename);
    img=im2double(img0);
   
%     [face,rect1]=imcrop(img);
%     [m,n,~]=size(face);
%     imshow(face)
    
    dlab=[30,8,4];%渲染目标中心，可变化
    [predict_white,rgbnew,ccT,duv,bull,bullx,ratio,lab,xyz,center0,center1]=AWBrendering(img,mode,spq,w,dlab,'srgb');%渲染函数
    figure();
    imshow(bull);
    imwrite(bull,fullfile(folder,'mask',"ori1.jpg"))
    [out_rendering,outxyz,k,out_awb]=imgcat(img,predict_white,white65,white65,w,'srgb');%根据计算得到的白点，进行cat变化，得到渲染后的图像
    figure();
    imshow(out_rendering)

    disp([num2str(i),'/',num2str(numel(files)),' ',files(i).name,' was done']);
%     save(strcat(outfolder,'\rendered_',num2str(i),'.png'));
    imwrite(out_rendering, fullfile(outfolder,'ori1.jpg'));
    
end



