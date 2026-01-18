close all; % éæŠ½æ£´éŽµ?éˆå¤Šæµ˜ç»?
clc;       % å¨“å‘¯â”–é›æˆ’æŠ¤ç»æ¥€å½?
clear;     % å¨“å‘´æ«Žå®¸ãƒ¤ç¶”é–çƒ˜å¢éˆå¤Šå½‰é–??
%%

files = dir('Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\cropped\*.jpg');  % ç’‡è¯²å½‡é‚å›¦æ¬¢æ¾¶é?›è…‘é¨å‹¬å¢éˆ?.jpgé‚å›¦æ¬?
dir_pointsfiles=dir("Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\cropped\setPoints\setPoints*.mat");
dir_mask=dir("Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\cropped\mask\*.jpg");
% for i = 6:6
for i = 6:numel(files)  %é?é€›è´Ÿ1é”›æ­¯umel(files),é™îˆ™äº0ç?¹ç‚µå¹‡ç?µè§„æžƒæµ è·ºã™æ¶“î…žæµ˜é—å›ªç¹˜ç›å±¾å£’é–²å¿”æ·æµ??
%     close all
    white65=[95.04,100,108.89];
    load(strcat(dir_pointsfiles(i).folder,'\',dir_pointsfiles(i).name));%é”çŠºæµ‡setPoints
    spq=1;
    mode=3;         %1 caucasian,2 brown,3 chinese,4 sky ,5 grassé”??6 black
    load zip/w.mat   %ddddd
    
    filename = fullfile(files(i).folder, files(i).name);  % é‘¾å³°å½‡é‚å›¦æ¬¢é??,é–å‘­æƒˆç’ºîˆšç·ž
    img0=imread(filename);
    img=im2double(img0);
   

    if i==6
        startCenter=43;
        endCenter=49;
    elseif i==8 
        startCenter=42;
        endCenter=49;
    elseif i==10
        startCenter=15;
        endCenter=24;
    else
        continue
    end
    for i_points=startCenter:endCenter
        dlab=centers(i_points,:);
        [predict_white,rgbnew,ccT,duv,bull,bullx,ratio,lab,xyz,center0,center1]=AWBrendering(img,mode,spq,w,dlab,'srgb');%å¨“å‰ç…‹é‘èŠ¥æšŸ
        bull=imread(strcat(dir_mask(i).folder,'\',dir_mask(i).name));

        [out_rendering,outxyz,k,out_awb,outofgamut]=imgcat2_1(img,bull,predict_white,white65,white65,w,'LUT',i,i_points);%éè§„åµç’ï¼„ç•»å¯°æ¥€åŸŒé¨å‹­æ«§éç™¸ç´æ©æ¶œî”‘caté™æ¨ºå¯²é”›å±½ç·±é’ç‰ˆè¦†éŒæ’³æ‚—é¨å‹«æµ˜é?
        imshow(out_rendering);
    
        disp([num2str(i_points),'/49of',num2str(i),'/',num2str(numel(files)),' ',files(i).name,' was done']);
        if outofgamut<0.15
        imwrite(out_rendering,['Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\cropped\' ...
            'renderedLUT\' ...
            ,files(i).name(1:end-4),'_',sprintf('%02d', i_points),'[',num2str(dlab(1,1)),',' ,...
            num2str(dlab(1,2)),',',num2str(dlab(1,3)),'].jpg'] );
        disp(['Out-of-gamut ratio:',num2str(outofgamut)]);
        else
        imwrite(out_rendering,['Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\cropped\' ...
            'renderedLUT\outofgamut\' ...
            ,files(i).name(1:end-4),'_',sprintf('%02d', i_points),'[',num2str(dlab(1,1)),',' ,...
            num2str(dlab(1,2)),',',num2str(dlab(1,3)),'].jpg'] );
        disp(['Out-of-gamut ratio:',num2str(outofgamut)]);
        end

%         save(strcat("D:\oppoSkinExperi\picked40\iphone" + ...
%             "\aveSkinColor",files(i).name(9:end-4),".mat"),'center0');
    % é‘¾å³°å½‡è¤°æ’³å¢ éƒãƒ¦æ¹¡éœå±¾æ¤‚é—??
    currentTime = datetime('now');    
    formattedTime = datestr(currentTime, 'yyyy-mm-dd HH:MM:SS');
    % éŽµæ’³åµƒè¤°æ’³å¢ éƒãƒ¦æ¹¡éœå±¾æ¤‚é—??
    disp([files(i).name(1:end-4),'_',num2str(i_points),'ç¼æ’´æ½«é”›å±½ç¶‹é“å¶†æ¤‚é—‚å­˜æ§¸: ', formattedTime]);
    end
        % é‘¾å³°å½‡è¤°æ’³å¢ éƒãƒ¦æ¹¡éœå±¾æ¤‚é—??
    currentTime = datetime('now');  
    formattedTime = datestr(currentTime, 'yyyy-mm-dd HH:MM:SS');
    % éŽµæ’³åµƒè¤°æ’³å¢ éƒãƒ¦æ¹¡éœå±¾æ¤‚é—??
    disp([files(i).name(1:end-4),'ç¼æ’´æ½«é”›å±½ç¶‹é“å¶†æ¤‚é—‚å­˜æ§¸: ',formattedTime]);
end



