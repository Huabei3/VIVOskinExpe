close all; 
clc;       
clear;     
%%
files = dir('..\dataset_image\iphone\cropped\*.jpg');  
dir_mask=dir("..\dataset_image\iphone\cropped\mask\*.jpg");
average_file='..\dataset_image\iphone\cropped\aveSkinByHand\autoNhand.mat';
average=load(average_file);
average=average.average_lab_all(:,5:7);

num_points = readmatrix('points48.xlsx'); 
num_center = num_points(53,:); 
num_points(50:53,:)=[];

hairline=[25,29];
% hairline=[16,18,19,20,25,27,29,30,32,33,35,36];

for i = 2:2
% for i = 33:numel(files)

    close all
    white65=[95.04,100,108.89];
    
    filename = fullfile(files(i).folder, files(i).name);      
    img0=imread(filename);
    img=im2double(img0);
    [m, n, p] = size(img);
    out = reshape(img, [m * n, p]);     
    out=out*255;

    bull=imread(strcat(dir_mask(i).folder,'\',dir_mask(i).name));
    bull_reshaped=reshape(bull, [m * n, p])./255;
    bull_reshaped = double(bull_reshaped);
    logicalIndex = all(bull_reshaped == 0, 2);


    % if i==2
        startCenter=49;
        endCenter=49;
    % else
    %     startCenter=1;
    %     endCenter=49;
    % end

    for i_points=startCenter:endCenter

        
        % delta_Lab=num_points(i_points,:)-num_center;
        % delta_Lab1=0.7*delta_Lab;
        % dlab=average(i,:)+delta_Lab1;
        fitRes_folder=fullfile("..\analyzeResult\AlalyseResults\rpl\1k\indoorAdd\ellipPara_scaled","fitRes_level.mat");
        fitRes_data=load(fitRes_folder);
        dlab=fitRes_data.parNr_all(i,5:7);
        delta_Lab1=dlab-average(i,:);

        img_file=['..\rendered\renderedAdd07\' ...
            ,files(i).name(1:end-4),'_',sprintf('%02d', i_points),'[',num2str(dlab(1,1)),',' ,...
            num2str(dlab(1,2)),',',num2str(dlab(1,3)),'].jpg'];
        if exist(img_file, 'file') == 2
            continue
        end
        
        disp([num2str(i_points),'/49of',num2str(i),'/',num2str(numel(files)),' ',files(i).name,' begin']);

        % [out_rendering,outofgamut]=img_AddRender(img,bull,'LUT',delta_Lab1);
        [out_rendering,outofgamut]=img_AddRender(img,bull,'srgb',delta_Lab1);
        imshow(out_rendering);
    
        disp([num2str(i_points),'/49of',num2str(i),'/',num2str(numel(files)),' ',files(i).name,' was done']);
        imwrite(out_rendering,['..\rendered\renderedAdd07\' ...
            ,files(i).name(1:end-4),'_',sprintf('%02d', i_points),'[',num2str(dlab(1,1)),',' ,...
            num2str(dlab(1,2)),',',num2str(dlab(1,3)),']_preCen.jpg'] );
        disp(['Out-of-gamut ratio:',num2str(outofgamut)]);
        currentTime = datetime('now');    
        formattedTime = datestr(currentTime, 'yyyy-mm-dd HH:MM:SS');
        disp([files(i).name(1:end-4),'_',num2str(i_points),'finished: ', formattedTime]);
    end
    currentTime = datetime('now');  
    formattedTime = datestr(currentTime, 'yyyy-mm-dd HH:MM:SS');
    disp([files(i).name(1:end-4),'finished: ',formattedTime]);
end



