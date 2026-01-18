close all; % 閼煎懘鍨鹃弬??
clc;       % 濮樻挻绱＄喊宀冨箺闁炽儲顕￠悿婊???
clear;     % 濮樻挻绱＄喊宀冨箺闁炽儲顕￠悿婊村灚宕犵拠銉㈡晽闁???
%%
% files = dir('Z:\homes\Peggy\oppoSkinExperi\HasselCropped\downSampled1\*.jpg');  
% dir_pointsfiles=dir("Z:\homes\Peggy\oppoSkinExperi\HasselCropped\setPoints\setPoints*.mat");
% dir_mask=dir("Z:\homes\Peggy\oppoSkinExperi\HasselCropped\downSampled1\mask\*.jpg");

files = dir('Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\cropped\*.jpg');  
dir_pointsfiles=dir("Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\cropped\setPoints_sRGBchoose\setPoints06\setPoints0.6.mat");
% dir_pointsfiles=dir("Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\cropped\setPoints\setPoints0.6*.mat");
dir_mask=dir("Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\cropped\mask\*.jpg");

valid_ranges = [33, 21];
for i = 1:numel(files)
    close all
    white65=[95.04,100,108.89];
    load(strcat(dir_pointsfiles(i).folder,'\',dir_pointsfiles(i).name));%閼煎懘鍨鹃弬鍛?ラ妷??濡垹濡村熬閳锋瑥澶熷熬閺岊垼鍟斿懗閹规牬鐏愰崗鐔奉潠閳圭偛绂嬮敍锝忚吂?灏剧粻鍍峯ints
    spq=1;
    mode=3;         %1 caucasian,2 brown,3 chinese,4 sky ,5 grass, 6 black
    load zip/w.mat   %ddddd
    
    filename = fullfile(files(i).folder, files(i).name);  % 閼煎懘鍨鹃弬鍛?ラ妷??灏惧ù??
    img0=imread(filename);
    img=im2double(img0);
   

%     if i==10
%         startCenter=33;
%         endCenter=49;
%     else
        startCenter=1;
        endCenter=49;
%     end

    for i_points=startCenter:endCenter
        if ~ismember(i_points, valid_ranges)
            continue
        end
        dlab=centers(i_points,:);
        [predict_white,rgbnew,ccT,duv,bull,bullx,ratio,lab,xyz,center0,center1]=AWBrendering(img,mode,spq,w,dlab,'srgb');
        bull=imread(strcat(dir_mask(i).folder,'\',dir_mask(i).name));
        [out_rendering,outxyz,k,out_awb,outofgamut]=imgcat2_1_skipNoFace(img,bull,predict_white,white65,white65,w,'LUT',i,i_points);
%         [out_rendering,outxyz,k,out_awb,outofgamut]=imgcat2_1(img,bull,predict_white,white65,white65,w,'LUT',i,i_points);
        imshow(out_rendering);
    
        disp([num2str(i_points),'/49of',num2str(i),'/',num2str(numel(files)),' ',files(i).name,' was done']);
        if outofgamut<0.15
        imwrite(out_rendering,['Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\cropped\renderedLUTchoose\inner06' ...
            ,files(i).name(1:end-4),'_',sprintf('%02d', i_points),'[',num2str(dlab(1,1)),',' ,...
            num2str(dlab(1,2)),',',num2str(dlab(1,3)),'].jpg'] );
%         imwrite(out_rendering,['Z:\homes\Peggy\oppoSkinExperi\HasselCropped\rendered\' ...
%             ,files(i).name(1:end-4),'_',sprintf('%02d', i_points),'[',num2str(dlab(1,1)),',' ,...
%             num2str(dlab(1,2)),',',num2str(dlab(1,3)),'].jpg'] );
        disp(['Out-of-gamut ratio:',num2str(outofgamut)]);
        else
        imwrite(out_rendering,['Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\cropped\renderedLUTchoose\inner06\' ...
            ,files(i).name(1:end-4),'_',sprintf('%02d', i_points),'[',num2str(dlab(1,1)),',' ,...
            num2str(dlab(1,2)),',',num2str(dlab(1,3)),'].jpg'] );
%         imwrite(out_rendering,['Z:\homes\Peggy\oppoSkinExperi\HasselCropped\rendered\outofgamut\' ...
%             ,files(i).name(1:end-4),'_',sprintf('%02d', i_points),'[',num2str(dlab(1,1)),',' ,...
%             num2str(dlab(1,2)),',',num2str(dlab(1,3)),'].jpg'] );
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



