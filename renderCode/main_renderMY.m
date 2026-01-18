close all; 
clc;       
clear;     
%%
files = dir('Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\cropped\*.jpg');  
dir_mask=dir("Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\cropped\mask\*.jpg");
average_file='Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\cropped\aveSkinByHand\autoNhand.mat';
average=load(average_file);
average=average.average_lab_all(:,5:7);

num_points = readmatrix('Z:\homes\Peggy\oppoSkinExperi\points48.xlsx'); 
num_center = num_points(53,:); 
num_points(50:53,:)=[];

badS=[4,6,18,20,24,29];
badA=[2,8,9,10,12,26];

for i = 16:numel(files)
%     if ~ismember(i, badS)
%         continue
%     end
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


    if i==16
        startCenter=25;
        endCenter=49;
    else
        startCenter=1;
        endCenter=49;
    end

    for i_points=startCenter:endCenter
        
        delta_Lab=num_points(i_points,:)-num_center;
        dlab=average(i,:)+delta_Lab;

        img_file=['Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\cropped\renderedLUTchoose\renderedAdd\' ...
            ,files(i).name(1:end-4),'_',sprintf('%02d', i_points),'[',num2str(dlab(1,1)),',' ,...
            num2str(dlab(1,2)),',',num2str(dlab(1,3)),'].jpg'];
        if exist(img_file, 'file') == 2
            continue
        end

        
        disp([num2str(i_points),'/49of',num2str(i),'/',num2str(numel(files)),' ',files(i).name,' begin']);
        




        [out_rendering,outofgamut]=img_AddRender(img,bull,'LUT',delta_Lab);
        imshow(out_rendering);
    
        disp([num2str(i_points),'/49of',num2str(i),'/',num2str(numel(files)),' ',files(i).name,' was done']);
        imwrite(out_rendering,['Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\cropped\renderedLUTchoose\renderedAdd\' ...
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



