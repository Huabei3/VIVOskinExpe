close all; 
clc;       
clear;     
%%
files = dir('Z:\homes\Peggy\oppoSkinExperi\picked40\Hassel\downSampled1\cropped\*.jpg');  
dir_mask=dir("Z:\homes\Peggy\oppoSkinExperi\picked40\Hassel\downSampled1\cropped\mask\*.jpg");
average_file='Z:\homes\Peggy\oppoSkinExperi\picked40\Hassel\downSampled1\cropped\aveSkinByHand\autoNhand.mat';
% files = dir('Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\cropped\*.jpg');  
% dir_mask=dir("Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\cropped\mask\*.jpg");
% average_file='Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\cropped\aveSkinByHand\autoNhand.mat';
average=load(average_file);
average=average.average_lab_all(:,5:7);

num_points = readmatrix('Z:\homes\Peggy\oppoSkinExperi\points48.xlsx'); 
num_center = num_points(53,:); 
num_points(50:53,:)=[];


for i = 1:numel(files)

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
    %     startCenter=29;
    %     endCenter=49;
    % else
        startCenter=1;
        endCenter=49;
    % end

    for i_points=startCenter:endCenter
        
        delta_Lab=num_points(i_points,:)-num_center;
        delta_Lab1=1.3*delta_Lab;
        if delta_Lab1(1,1)<=0
            continue
        end
        dlab=average(i,:)+delta_Lab1;

        img_file=['Z:\homes\Peggy\oppoSkinExperi\picked40\Hassel\downSampled1\cropped\renderedAdd\renderedAdd13up\' ...
            ,files(i).name(1:end-4),'_',sprintf('%02d', i_points),'[',num2str(dlab(1,1)),',' ,...
            num2str(dlab(1,2)),',',num2str(dlab(1,3)),'].jpg'];
        if exist(img_file, 'file') == 2
            continue
        end
        
        disp([num2str(i_points),'/49of',num2str(i),'/',num2str(numel(files)),' ',files(i).name,' begin']);

        [out_rendering,outofgamut]=img_AddRender(img,bull,'LUT',delta_Lab1);
        imshow(out_rendering);
    
        disp([num2str(i_points),'/49of',num2str(i),'/',num2str(numel(files)),' ',files(i).name,' was done']);
        imwrite(out_rendering,['Z:\homes\Peggy\oppoSkinExperi\picked40\Hassel\downSampled1\cropped\renderedAdd\renderedAdd13up\' ...
            ,files(i).name(1:end-4),'_',sprintf('%02d', i_points),'[',num2str(dlab(1,1)),',' ,...
            num2str(dlab(1,2)),',',num2str(dlab(1,3)),'].jpg'] );
        disp(['Out-of-gamut ratio:',num2str(outofgamut)]);
        currentTime = datetime('now');    
        formattedTime = datestr(currentTime, 'yyyy-mm-dd HH:MM:SS');
        disp([files(i).name(1:end-4),'_',num2str(i_points),'finished: ', formattedTime]);
    end
    currentTime = datetime('now');  
    formattedTime = datestr(currentTime, 'yyyy-mm-dd HH:MM:SS');
    disp([files(i).name(1:end-4),'finished: ',formattedTime]);
end



