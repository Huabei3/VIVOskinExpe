close all; 
clc;       
clear;     
%%

files = dir('Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\*.jpg');  % 闁荤姴娲╅褑銇愰崶�??妫橀柛銉檮椤愯棄顭块崼??濞戞粌骞?闂佹眹鍔�??氼厽鏅跺澶婂珘?.jpg闂佸搫鍊稿ú锝呪枎?
dir_cropRect=dir("Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\cropped\crop_para\*.mat");

for i = 10:numel(files)  
    close all
    white65=[95.04,100,108.89];

    load zip/w.mat   %ddddd
    
    filename = fullfile(files(i).folder, files(i).name);  % 闂佸吋鍎抽崲鑼躲亹閸ヮ剙妫橀柛銉檮椤愪粙鏌???,闂佸憡鐗曢幊搴ㄥ箚閸垺宕夋い鏍ㄦ皑�???
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



