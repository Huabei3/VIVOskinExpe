close all; % é—ç¨¿ç¹‘æ¿žå©‚Î›éŽ¾î†¼ç®¥?é—å“„ç‰†é¡¦îˆšÃ¹å¦¯è‚©çŽ»?
clc;       % å©µç‚´æŒ¸éŽ³æ„°åŸžéî…žå·é–¹å­˜å¸—æ¿®ãˆ¢ç´’éŽ°î…§æ®”ç‘???
clear;     % å©µç‚´æŒ¸éŽ³æ¨ºâ–æ´â˜†å•…é–µå¤ˆå?—ç»‹å©‡æŸ›éî‚¢åŠ‹å©¢Ñƒç§¹å¯®åž«å¾„æ¿ å‚œç§®é—‚???
%%

files = dir('Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\cropped\*.jpg');  % é–»çŠ²æ´©é¡•Ñ†ãé¥î„?æ£˜é–¸ãƒ¯é™„é¡è—‰îŸ¿é«??å¨‘æ»ƒå¹?é—æ±‡åŠŒç?šî…Ÿæ™¶å®¥å¤Šå«‰?.jpgé—å“„å€¸å¨²ï½…â–Ž?
dir_pointsfiles=dir("Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\cropped\setPoints\setPoints*.mat");
dir_mask=dir("Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\cropped\mask\*.jpg");
% for i = 6:6
for i = 12:numel(files)  %é—???é—î‚£ç¨–ç»€?1é—æŒŽç¨1é¡1â•±mel(files),é—å1Šç2¯é¨îˆ›ç¦éŽ???é¦î…žä»§æ¥ ç‚²æ´¨?æµ£å†¾æ½é–ºå¬ªå•¯ç»‚æŽ”æ„éŽ­æŽç²´æ¿žæˆžæ©é˜ç…ŽÃ¹å§—?éŽ®Ñ‡å´¶é¡å—™î†’é–»ç‚´ç¨‘éˆî„ç«ŸéŽºæ¥ç…‚éŸ«å›¨æ¢¹éŽ¯æ¬Ã???
    close all
    white65=[95.04,100,108.89];
    load(strcat(dir_pointsfiles(i).folder,'\',dir_pointsfiles(i).name));%é—å‘Šæ¢»æ¿®æƒ§Ã¹é£æ…¹tPoints
    spq=1;
    mode=3;         %1 caucasian,2 brown,3 chinese,4 sky ,5 grassé—????6 black
    load zip/w.mat   %ddddd
    
    filename = fullfile(files(i).folder, files(i).name);  % é—å…¼å„³é¢èŒ¶ãé¥î„€æ£˜é–¸ãƒ¯é™„é¡ä»‹æŸ???,é—å‘Šç‰•éŽ³åº¨å¹†é«ãˆ¡å´‰æ¤¤æ ¨æ°¨ç»??
    img0=imread(filename);
    img=im2double(img0);
   

%     if i==11
%         startCenter=21;
%         endCenter=49;
%    
%     else
        startCenter=1;
        endCenter=49;
%     end
    for i_points=startCenter:endCenter
        dlab=centers(i_points,:);
        [predict_white,rgbnew,ccT,duv,bull,bullx,ratio,lab,xyz,center0,center1]=AWBrendering(img,mode,spq,w,dlab,'srgb');%å©µç‚´æŒ¸å¯®å •æ‚¡ç€£î†¼ç¤„é–¼æ’å„²å¨??
        bull=imread(strcat(dir_mask(i).folder,'\',dir_mask(i).name));

        [out_rendering,outxyz,k,out_awb,outofgamut]=imgcat2_1(img,bull,predict_white,white65,white65,w,'LUT',i,i_points);%é—å“„ç§·é¡«å¤Šç•µæµ£çƒ˜åª¼é–¿æ¶˜å«®é†î„‚?ç”µå¢—é¡¨å‘´å´ºå®€å‹¬å„é–¸æ›¨åŽ½é¡ã‚‰æŸ£éŽ°î†½îŸç¼è¾¨ç¹ƒå¨¼è¯²â˜‰å©Šåº¢æ–€caté—å‘Šç‘¦é”šéŽåž«ç…¡éå¶‡ä»¦é£å²€ç®’é—å‘Šå¸žæ¾§æ¥ƒæ†°é¡æ¶˜è“Ÿé–¹ææ«•éŠç”¸æŸ£éŠŠãƒ¥î©æ¿žå­˜ï¹¢å®???
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
    % é—å…¼å„³é¢èŒ¶ãé¥î‚äº¹é–¹æƒ§å•¿é¡¤å‘´æŸ¡éï¹?åŠœæ¿ ?é”ŸçŠ²æ¤½éç‚µå“é¡¦Ñ‡æ¢»??
    currentTime = datetime('now');    
    formattedTime = datestr(currentTime, 'yyyy-mm-dd HH:MM:SS');
    % é—ç‘°çšéŽ¸ç¨¿ç•µéî…œäº¹é–¹æƒ§å•¿é¡¤å‘´æŸ¡éï¹?åŠœæ¿ ?é”ŸçŠ²æ¤½éç‚µå“é¡¦Ñ‡æ¢»??
    disp([files(i).name(1:end-4),'_',num2str(i_points),'ç¼‚å‚™ç„¦éŽ¸è¯²îŸ‡é¡ï¸½æ™¬éç‚µæ™«ç»‰å¥¸æŸ›éŽ¾å´‡Ð£æ¿¡ç‚²å?¿å§Šè??æ¶™É‘ç¬‘: ', formattedTime]);
    end
        % é—å…¼å„³é¢èŒ¶ãé¥î‚äº¹é–¹æƒ§å•¿é¡¤å‘´æŸ¡éï¹?åŠœæ¿ ?é”ŸçŠ²æ¤½éç‚µå“é¡¦Ñ‡æ¢»??
    currentTime = datetime('now');  
    formattedTime = datestr(currentTime, 'yyyy-mm-dd HH:MM:SS');
    % é—ç‘°çšéŽ¸ç¨¿ç•µéî…œäº¹é–¹æƒ§å•¿é¡¤å‘´æŸ¡éï¹?åŠœæ¿ ?é”ŸçŠ²æ¤½éç‚µå“é¡¦Ñ‡æ¢»??
    disp([files(i).name(1:end-4),'ç¼‚å‚™ç„¦éŽ¸è¯²îŸ‡é¡ï¸½æ™¬éç‚µæ™«ç»‰å¥¸æŸ›éŽ¾å´‡Ð£æ¿¡ç‚²å?¿å§Šè??æ¶™É‘ç¬‘: ',formattedTime]);
end



