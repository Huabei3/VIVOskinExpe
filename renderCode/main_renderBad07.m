close all;
clc;
clear;
%%
% files = dir('Z:\homes\Peggy\oppoSkinExperi\HasselCropped\downSampled1\*.jpg');  
% dir_pointsfiles=dir("Z:\homes\Peggy\oppoSkinExperi\HasselCropped\setPoints07_1\setPoints*.mat");
% dir_mask=dir("Z:\homes\Peggy\oppoSkinExperi\HasselCropped\downSampled1\mask\*.jpg");
% 
files = dir('Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\cropped\*.jpg');  
dir_pointsfiles=dir("Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\cropped\setPointsUseMask\setPointsUseMask07\setPoints*.mat");
dir_mask=dir("Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\cropped\mask\*.jpg");
badS=[4,6,18,20,24,29];
badA=[2,8,9,10,12,26];
for i = 1:numel(files)
    if ~ismember(i, badS)
        continue
    end
    close all
    white65=[95.04,100,108.89];
    load(strcat(dir_pointsfiles(i).folder,'\',dir_pointsfiles(i).name));
    spq=1;
    mode=3;         %1 caucasian,2 brown,3 chinese,4 sky ,5 grass, 6 black
    load zip/w.mat   %ddddd
    filename = fullfile(files(i).folder, files(i).name); 
    img0=imread(filename);
    img=im2double(img0);
   
% 
    if i==4
        startCenter=15;
        endCenter=49;

    else
        startCenter=1;
        endCenter=49;
    end
    for i_points=startCenter:endCenter
        dlab=centers(i_points,:);
        img_file=['Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\cropped\renderedLUTchoose\renderedBad07\' ...
            ,files(i).name(1:end-4),'_',sprintf('%02d', i_points),'[',num2str(dlab(1,1)),',' ,...
            num2str(dlab(1,2)),',',num2str(dlab(1,3)),'].jpg'];
%        img_file=['Z:\homes\Peggy\oppoSkinExperi\HasselCropped\rendered\renderedLUT07\' ...
%             ,files(i).name(1:end-4),'_',sprintf('%02d', i_points),'[',num2str(dlab(1,1)),',' ,...
%             num2str(dlab(1,2)),',',num2str(dlab(1,3)),'].jpg'];
        [img_file_path, ~, ~] = fileparts(img_file);
        img_file1=[img_file_path ,'\',...
            files(i).name(1:end-4),'_',sprintf('%02d', i_points),'[',num2str(dlab(1,1)),',' ,...
            num2str(dlab(1,2)),',',num2str(dlab(1,3)),']07.jpg'];
        if exist(img_file, 'file') == 2||exist(img_file1, 'file') == 2
            continue
        end

        [predict_white,rgbnew,ccT,duv,bull,bullx,ratio,lab,xyz,center0,center1]=AWBrendering(img,mode,spq,w,dlab,'srgb');
        bull=imread(strcat(dir_mask(i).folder,'\',dir_mask(i).name));
        disp([num2str(i_points),'/49of',num2str(i),'/',num2str(numel(files)),' ',files(i).name,' begin']);
        [out_rendering,outxyz,k,out_awb,outofgamut]=imgcat2_1_skipNoFace(img,bull,predict_white,white65,white65,w,'LUT',i,i_points);
%         [out_rendering,outxyz,k,out_awb,outofgamut]=imgcat2_1(img,bull,predict_white,white65,white65,w,'LUT',i,i_points);
        imshow(out_rendering);
    
        disp([num2str(i_points),'/49of',num2str(i),'/',num2str(numel(files)),' ',files(i).name,' was done']);

        if outofgamut<0.15
            imwrite(out_rendering,['Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\cropped\renderedLUTchoose\renderedBad07\' ...
                ,files(i).name(1:end-4),'_',sprintf('%02d', i_points),'[',num2str(dlab(1,1)),',' ,...
                num2str(dlab(1,2)),',',num2str(dlab(1,3)),']07.jpg'] );
%             imwrite(out_rendering,['Z:\homes\Peggy\oppoSkinExperi\HasselCropped\rendered\renderedLUT07\' ...
%                 ,files(i).name(1:end-4),'_',sprintf('%02d', i_points),'[',num2str(dlab(1,1)),',' ,...
%                 num2str(dlab(1,2)),',',num2str(dlab(1,3)),'].jpg'] );
            disp(['Out-of-gamut ratio:',num2str(outofgamut)]);
        else
            imwrite(out_rendering,['Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\cropped\renderedLUTchoose\renderedBad07\outofgamut\' ...
                ,files(i).name(1:end-4),'_',sprintf('%02d', i_points),'[',num2str(dlab(1,1)),',' ,...
                num2str(dlab(1,2)),',',num2str(dlab(1,3)),']07.jpg'] );
%             imwrite(out_rendering,['Z:\homes\Peggy\oppoSkinExperi\HasselCropped\rendered\renderedLUT07\' ...
%                 ,files(i).name(1:end-4),'_',sprintf('%02d', i_points),'[',num2str(dlab(1,1)),',' ,...
%                 num2str(dlab(1,2)),',',num2str(dlab(1,3)),'].jpg'] );
            disp(['Out-of-gamut ratio:',num2str(outofgamut)]);
        end


    currentTime = datetime('now');    
    formattedTime = datestr(currentTime, 'yyyy-mm-dd HH:MM:SS');
    disp([files(i).name(1:end-4),'_',num2str(i_points),'finished: ', formattedTime]);
    end
    currentTime = datetime('now');  
    formattedTime = datestr(currentTime, 'yyyy-mm-dd HH:MM:SS');
    disp([files(i).name(1:end-4),'finished: ',formattedTime]);
end



