close all; % Ã©â€�?��??šÃ¥â?šâ„¢Ã¦Âµâ€¡Ã©Ââ?¹Ã¦â?žÂ°Ã¥Â´Â¢Ã¨Â¤â?Ã©ÂªÅ¾Ã¥Â©â?šÃ®ÂÅ??Ã§â‚¬Â¹Ã¦�??ºÂ¡Ã®Ââ?°Ã©Å Ë†Ã¯Â½�??°Ã¥Â´ËœÃ©Å Å Ã¯Â¸Â»Ã¦Â????
clc;       % Ã¥Â©ÂµÃ§Å Â³Ã®â€ �??“Ã©ÂÂ Ã¦Â¥�??žÃ¦â?˜Â«Ã©â?”ÂÃ¨Â§�??žÃ§â?œâ?¢Ã¥Â®â?¢Ã©Ââ?ºÃŽÂ£Ã©Å½Â°Ã§â?°Ë†Ã¦â�?�¢Â¬Ã©â€“Â¸Ã¦�??ºÂ¨Ã¥Ââ?¦Ã©ÂÅ½Ã¦Å Â½Ã¦â?šâ????Ã©â€�?�ÂÃ¥�??˜Å Ã¥Å â?˜Ã©Ââ?Ã¥ÂºÂ¨Ã®â?â„¢Ã©Å½Â´Ã¯Â¸Â½Ã¢â€™�??™Ã¥Â¨Â´Ã¯Â½�??¦Ã¦ÂÂ«Ã¦ÂµÂ Ã¦Â´ÂªÃ¦Å¸â?ºÃ¦ÂÂ´Ã£Ë†Â¢Ã¥Ââ�?�¬Ã¦Â¤Â¤Ã£Ë�?�Â¡Ã¥Â²Â¸Ã©ÂÂÃ¦â€™Â»Ã¦�??šÂ©Ã©ÂÂÃ¨Â¹Â­Ã§â?”ÂªÃ¦Â¿�????????
clear;     % Ã¥Â©ÂµÃ§Å Â³Ã®â€ �??“Ã©ÂÂ Ã¦Â¥�??žÃ¦â?˜Â«Ã©â?”ÂÃ¨Â§�??žÃ§â?œâ?¢Ã¥Â®â?¢Ã©Ââ?ºÃŽÂ£Ã©Å½Â°Ã§â?°Ë†Ã¦â�?�¢Â¬Ã©â€“Â¸Ã¦�??ºÂ¨Ã¥Ââ?¦Ã©ÂÅ½Ã¦Å Â½Ã¦â?šâ????Ã©â€�?�ÂÃ¥�??˜Å Ã¥Å â?˜Ã©Ââ?Ã¥ÂºÂ¨Ã®â?â„¢Ã©Å½Â´Ã¯Â¸Â½Ã¢â€™�??™Ã¥Â¨Â´Ã¯Â½�??¦Ã¦ÂÂ«Ã¦ÂµÂ Ã¦Â´ÂªÃ¦Å¸â?ºÃ¦ÂÂ´Ã£Ë†Â¢Ã¥Ââ�?�¬Ã¦Â¤Â¤Ã£Ë�?�Â¡Ã¥Â²Â¸Ã©ÂÂÃ¦â€™Â»Ã¦�??šÂ©Ã©ÂÂÃ¨Â¹Â­Ã§â?”ÂªÃ¦Â¿Â Ã§�??ÂµÃ¥Â§Â´Ã©â?â?¢Ã£Æ’Â¥Ã®Å¸�??¡Ã¥Â¨â? Ã¦â?™Â´�???Â¶Ã¦Â¿Â®Ã¦Â©â€ Ã¥�??°â?ºÃ©Ââ? Ã¯Â¹â?šÃ¦Å¸Â£Ã¥Â¦Â¯Ã¨â„¢Â¹Ã¤Â»â€ºÃ©ÂÅ½Ã¦Â°Â­Ã¥Â²Â¸Ã©ÂÅ’Ã¦�??ºÅ¸Ã¥Â¾â?žÃ©ÂÂ«Ã¦Â¿Ë†Ã¤Â»Â¾Ã©�??”ÂÃ¥�??œâ?žÃ¦â?¡ÂÃ§Â»Â®Ã¦Â¬ÂÃ®Â??????
%%
% files = dir('Z:\homes\Peggy\oppoSkinExperi\HasselCropped\downSampled1\*.jpg');  
% dir_pointsfiles=dir("Z:\homes\Peggy\oppoSkinExperi\HasselCropped\setPoints\setPoints*.mat");
% dir_mask=dir("Z:\homes\Peggy\oppoSkinExperi\HasselCropped\downSampled1\mask\*.jpg");

files = dir('Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\cropped\*.jpg');  
dir_pointsfiles=dir("Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\cropped\setPoints_sRGBchoose\setPoints07\setPoints*.mat");
% dir_pointsfiles=dir("Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\cropped\setPoints\setPoints0.7*.mat");
dir_mask=dir("Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\cropped\mask\*.jpg");
for i = 16:numel(files)
    close all
    white65=[95.04,100,108.89];
    load(strcat(dir_pointsfiles(i).folder,'\',dir_pointsfiles(i).name));%Ã©â€�?��??šÃ¥â?šâ„¢Ã¦Âµâ€¡Ã©Ââ?¹Ã¦â?žÂ°Ã¥Â´Â¢Ã¨Â¤â?Ã©ÂªÅ¾Ã¥Â©â?šÃ®ÂÅ??Ã§â‚¬Â¹Ã¦�??ºÂ¡Ã®Ââ?°Ã©Å Ë†Ã¯Â½�??°Ã¥Â´ËœÃ©Å Å Ã¯Â¸Â»Ã¦Â£Å¸Ã©â?”�??šÃ¤Â½Â¸Ã¦â? Â¡Ã¦Â¸Å¡Ã¦Â¥â?¦Ã¥Â????Ã©â€�?�ÂÃ©Â�??ºÃ®ËœÂ«Ã©Ââ?¦Ã¦Â¶ËœÃ¦â?¢Â???Ã¥Â©ÂµÃ§Å ÂµÃ®â€¢Â½Ã¥Â¦Â²Ã¥�??˜Â´Ã¥Â´Â¹Ã©â?“Â¬Ã¥Â¶�??¦Ã¥Å¾â?šÃ©ÂÅ¸Ã¦Â¬ÂÃ¥Â«ÂªÃ§Â»Â»Ã¥â?”�??ºÃ¦Å¸Â¡Ã¦Â¾Â¶Ã¥Â¬ÂªÃ§ÂÂ©Ã©â?“Â¸Ã§�?? Â¸Ã§â?¦Â¡Ã¥Â§Å Ã¦Â´ÂªÃ¥Â¹Å½Ã©â?˜ÂºÃ£Æ’Â¦Ã¦Å¡Â Ã©�??”ÂÃ¨ÂÂ¤Ã¥�??“�?? Ã©ÂÅ½Ã¦Ââ?™Ã®�??¡Â¥Ã©Ââ?¢Ã®Ë†�??ºÃ¥Ââ?žÃ¥Â¦Å¾Ã¥Â¬ÂªÃ©ÂªÂ¸Ã©Ââ? Ã¯Â¿Â Ã¦Â¢Â»Ã¦ÂµÂ£Ã¥â?˜Å Ã¦Æ’Ë�?�Ã©�??“Â»Ã®�??¦Å¾Ã§â?°â?œÃ¥Â®â?¢Ã¨Â§â?žÃ§Â¸Â½Ã§Â»â?¹Ã¨Â·Â¨Ã¦Å¸Ë†Ã©�??”ÂÃ¥�??œâ?žÃ¥â‚¬Â¹Ã�??ÂµÃ‘â€¡Ã¥Â´ÂµÃ©Ââ?¢Ã®Ë†�??ºÃ¢â?™�??˜Ã§Â»Â¾Ã®â?¦Å¾Ã¦â?¹â?¹Ã¥Â¨Â¼Ã¦â?žÂ°Ã¦Å¸Â£Ã¥Â¦Â¤Ã¥Â©â?šÃ¥Â¢Â´Ã©â?“Â¹Ã®�?? Â½Ã¯Â¹Â¢Ã©ÂªÅ¾Ã¥â?ºÂ¬Ã¥Â¼Â¶Ã§â?™ÂºÃ®Å¸�??˜Ã¦Â§Â¯Ã©â?”�??šÃ¤Â½ÂºÃ§Â²Â¯Ã©ÂÅ’Ã£�??žÂ©Ã£â‚¬Æ�?�Ã¦ÂÂ´Ã¢Ëœâ€ Ã§â?žÂ½Ã©â?“Â»Ã¦Â¨Â¼Ã§Â²Â¯Ã©Â�??œÃ¥â? Â®Ã¦Å¸â?ºÃ©â?â?Ã¨Â¯Â²Ã¥Â¹â?“Ã¥Â¨Â´Ã§Å Â³Ã§Â²Å½Ã§Â»Â±Ã¦Å½�??”Ã¥Â´�??™Ã¥Â§ËœÃ§�??¦Å½Ã¥â?°Â¶Ã©â?”ÂÃ¨Â½Â°Ã§Â¤ÂÃ§Â»�??°Ã¥Â½â?™Ã¥Â¼Â«Ã©Å½Â°Ã®Ë�?�Å�?�Ã§�????Ã¦Â¿Â®Ã¦Â©â€ Ã¥�??°Å¡Ã©ÂÅ???Ã©â€�?�ÂÃ¨Â¯Â²Ã§Â¹ÂÃ§Â»Â»Ã¦�??žÂ­Ã¦â„¢Â¶Ã©ÂÂ£Ã¥Â±Â½Ã¥Å¾ÂÃ¥Â©ÂµÃ§Å Â³Ã¨â€°Â¾Ã§ÂºÂ¾Ã§â?¢Å??Ã§â€˜Â°Ã¥Â«Â®Ã¥Â¦Â«Ã®Ëœ�??ts
    spq=1;
    mode=3;         %1 caucasian,2 brown,3 chinese,4 sky ,5 grass, 6 black
    load zip/w.mat   %ddddd
    
    filename = fullfile(files(i).folder, files(i).name);  % Ã©â€�?��??šÃ¥â?šâ„¢Ã¦Âµâ€¡Ã©Ââ?¹Ã¦â?žÂ°Ã¥Â´Â¢Ã¨Â¤â?Ã©ÂªÅ¾Ã¥Â©â?šÃ®ÂÅ??Ã§â‚¬Â¹Ã¦�??ºÂ¡Ã®Ââ?°Ã©Å Ë†Ã¯Â½�??°Ã¥Â´ËœÃ©Å Å Ã¯Â¸Â»Ã¦Â£Å¸Ã©â?”�??šÃ¤Â½Â¸Ã¦â? Â¡Ã¦Â¸Å¡Ã¦Â¥â?¦Ã¥Â????Ã©â€�?�ÂÃ©Â�??ºÃ®ËœÂ«Ã©Ââ?¦Ã¦Â¶ËœÃ¦â?¢Â???Ã©â€�?�ÂÃ¨Â¯Â²Ã§Â¹ÂÃ§Â»Â»Ã¦Ë�?�Â¦Ã¥Â´�??¢Ã©Å½Â¶Ã¨Å Â¥Ã§Â????
    img0=imread(filename);
    img=im2double(img0);
   

%     if i==1
%         startCenter=40;
%         endCenter=49;
% 
%     else
        startCenter=1;
        endCenter=49;
%     end
    for i_points=startCenter:endCenter
        dlab=centers(i_points,:);
        %Ã¨Â·Â³Ã¨Â¿â€¡Ã¥Â·Â²Ã§Â»ÂÃ¦Â¸Â²Ã¦Å¸�??œÃ§Å??
        img_file=['Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\cropped\renderedLUTchoose\renderedLUT07\' ...
            ,files(i).name(1:end-4),'_',sprintf('%02d', i_points),'[',num2str(dlab(1,1)),',' ,...
            num2str(dlab(1,2)),',',num2str(dlab(1,3)),'].jpg'];
        [img_file_path, ~, ~] = fileparts(img_file);
        img_file1=[img_file_path ,'\',...
            files(i).name(1:end-4),'_',sprintf('%02d', i_points),'[',num2str(dlab(1,1)),',' ,...
            num2str(dlab(1,2)),',',num2str(dlab(1,3)),']07.jpg'];
        if exist(img_file, 'file') == 2||exist(img_file1, 'file') == 2
            continue
        end
        %Ã¦Â¸Â²Ã¦Å¸â€œÃ¥�??ºÂ¾Ã§â?°â??
        [predict_white,rgbnew,ccT,duv,bull,bullx,ratio,lab,xyz,center0,center1]=AWBrendering(img,mode,spq,w,dlab,'srgb');
        bull=imread(strcat(dir_mask(i).folder,'\',dir_mask(i).name));
        disp([num2str(i_points),'/49of',num2str(i),'/',num2str(numel(files)),' ',files(i).name,' begin']);
        [out_rendering,outxyz,k,out_awb,outofgamut]=imgcat2_1_skipNoFace(img,bull,predict_white,white65,white65,w,'LUT',i,i_points);
%         [out_rendering,outxyz,k,out_awb,outofgamut]=imgcat2_1(img,bull,predict_white,white65,white65,w,'LUT',i,i_points);
        imshow(out_rendering);
    
        disp([num2str(i_points),'/49of',num2str(i),'/',num2str(numel(files)),' ',files(i).name,' was done']);
        %Ã¤Â¿ÂÃ¥Â­ËœÃ¥â€ºÂ¾Ã§�??°â??
        if outofgamut<0.15
            imwrite(out_rendering,['Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\cropped\renderedLUTchoose\renderedLUT07\' ...
                ,files(i).name(1:end-4),'_',sprintf('%02d', i_points),'[',num2str(dlab(1,1)),',' ,...
                num2str(dlab(1,2)),',',num2str(dlab(1,3)),']07.jpg'] );
    %         imwrite(out_rendering,['Z:\homes\Peggy\oppoSkinExperi\HasselCropped\rendered\' ...
    %             ,files(i).name(1:end-4),'_',sprintf('%02d', i_points),'[',num2str(dlab(1,1)),',' ,...
    %             num2str(dlab(1,2)),',',num2str(dlab(1,3)),'].jpg'] );
            disp(['Out-of-gamut ratio:',num2str(outofgamut)]);
        else
            imwrite(out_rendering,['Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\cropped\renderedLUTchoose\renderedLUT07\outofgamut\' ...
                ,files(i).name(1:end-4),'_',sprintf('%02d', i_points),'[',num2str(dlab(1,1)),',' ,...
                num2str(dlab(1,2)),',',num2str(dlab(1,3)),']07.jpg'] );
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



