clc
clear
close all
folder = 'pictures\Samsung';  % 文件夹路径
files = dir(fullfile(folder, '*.jpg'));  % 读取文件夹中的所有.jpg文件

outfolder='pictures\Samsung\result\2';
if exist(outfolder,'dir')==0
    mkdir(outfolder);
end

for i = 27
    close all
    
    white65=[95.04,100,108.89];
    spq=1;
    mode=1;         %1 caucasian,2 brown,3 chinese,4 sky ,5 grass,6 black
    load zip/w.mat   %相机修正参数
    
    filename = fullfile(folder, files(i).name);  % 获取文件名,包含路径
    img0=imread(filename);
    img=im2double(img0);
    
    
%     rect=[2.062510000000000e+03,9.645100000000000e+02,7.159799999999996e+02,9.559800000000000e+02];
%     face=imcrop(img,rect);
%     figure;imshow(face)
    [face,rect]=imcrop(img);
    figure;imshow(face)

    downsize=30;
    sigma=2;
%     for downsize=10:10:40
%         for sigma=[0.5,1,2,4,6,10]
            [out_origin,out_gauss,out_bull,average_reference_white,cct_gauss,cct_origin]=mix_AWB(face,downsize,sigma,mode,spq,w,'srgb');
            [predict_white1,rgbnew,ccT,duv,bull,bullx,ratio,lab,outxyz,center0,center1]=memoryAWB(out_gauss,mode,spq,w,'srgb');
%             imwrite(out_gauss,[outfolder,'\downsize,sigma = [',' ',num2str(downsize),',',num2str(sigma),'].jpg'])
%         end
%     end
    figure;imshow([face out_gauss])
%%   method 2
%     white80=[91.1,100,111.8];
%     white65=[95.04,100,108.89];
%     white50=[98.3,100,76.5];
%     white40=[104.0,100,68.0];
%     white30=[110.2,100,45.6];
%     face_D80=imgcat(face,white80,white65,white65);
%     face_D65=imgcat(face,white65,white65,white65);
%     face_D50=imgcat(face,white50,white65,white65);
%     face_D40=imgcat(face,white40,white65,white65);
%     face_D30=imgcat(face,white30,white65,white65);
%     figure;imshow([face_D80,face_D65,face_D50,face_D40,face_D30])
%     
%     facex=face_D40;
%     [predict_white,rgbnew,ccT,duv,bull,bullx,dratio,lab,center0,result_center]=memoryAWB(facex,mode,spq,w);
%     
%     startcenter=[64.8,19.5,19.5,0.020667578,0.127532583,0.047573365,-0.055680769,2.396801573];
%     k1=startcenter(4);
%     k2=startcenter(5);
%     k3=startcenter(6);
%     k4=startcenter(7);
%     dlab=center0-result_center;
%     de=(k1*dlab(1)^2+k2*dlab(2)^2+k3*dlab(3)^2+k4*dlab(2)*dlab(3))^0.5;
%     figure;imshow(bull.*facex)
%     
% %     imwrite(bull,[outfolder,'\mask_',files(i).name]);
    disp([num2str(i),'/',num2str(numel(files)),' ',files(i).name,' was done']);
end



