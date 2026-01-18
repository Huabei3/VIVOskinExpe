close all; 
clc;       
clear;     
%%

files = dir('Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\*.jpg');  % é—è¤å§´å¨²â•…î”šè¤‘éŠ‡æ„°å´¶é¡??å¦«æ©€æŸ›éŠ‰îˆžæª®æ¤¤æ„¯æ£„é¡­å—å´¼??æ¿žæˆžç²Œéªž?é—‚ä½¹çœ¹é”å²??æ°¼åŽ½é…è·ºî…¼æ¾¶å©‚ç˜?.jpgé—‚ä½¸æ«éŠç¨¿Ãºé”å‘ªæžŽ?
dir_cropRect=dir("Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\cropped\crop_para\*.mat");

for i = 7:numel(files)  
    close all
    white65=[95.04,100,108.89];

    load zip/w.mat   %ddddd
    
    filename = fullfile(files(i).folder, files(i).name);  % é—‚ä½¸å‹éŽæŠ½å´²é‘¼èº²äº¹é–¸ãƒ®å‰™å¦«æ©€æŸ›éŠ‰îˆžæª®æ¤¤æ„ªç²™éŒ???,é—‚ä½¸æ†¡é—æ›¢å¹Šæ´ã„¥ç®šé–¸î‚ åžºå®•å¤‹ã„éã„¦çš‘ç¼???
    img0=imread(filename);
    img=im2double(img0);
    load(strcat(dir_cropRect(i).folder,'\',dir_cropRect(i).name));
    out_img = process_outside_crop_rect(img, cropRect,i);

    source_folder='Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\cropped\renderedLUT';
    all_files = dir(fullfile(source_folder, '*.jpg'));
    selected_files = [];    
    search_string = files(i).name;     
    for i_makeDir = 1:numel(all_files)
        if contains(all_files(i_makeDir).name, search_string)
            selected_files = [selected_files; all_files(i_makeDir)];
        end
    end


    for i_points=1:numel(selected_files)
        rendered_img=imread([selected_files(i).folder,'\',selected_files(i).name]);
        out_img(cropRect(2):(cropRect(2)+cropRect(4)), cropRect(1):(cropRect(1)+cropRect(3)), :) = rendered_img;
        outfolder='Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\cropped\renderedLUT\renderLUT_big';
        imwrite(out_img,[outfolder,'\Big',selected_files(i_points).name(9:end)] );

    end
    currentTime = datetime('now');  
    formattedTime = datestr(currentTime, 'yyyy-mm-dd HH:MM:SS');
    disp([files(i).name(1:end-4),'finished: ',formattedTime]);
end



