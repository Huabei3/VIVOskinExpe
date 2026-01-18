close all; 
clc;       
clear;     
%%
files = dir('D:\work\FirstYearMaster\oppoSkinExperi\picked40\iphone\cropped\*.jpg');  
dir_maskUp=dir("D:\work\FirstYearMaster\oppoSkinExperi\picked40\iphone\cropped\maskUp\*.jpg");
dir_maskDown=dir("D:\work\FirstYearMaster\oppoSkinExperi\picked40\iphone\cropped\maskDown\*.jpg");
% files = dir('Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\cropped\*.jpg');  
% dir_maskUp=dir("Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\cropped\maskUp\*.jpg");
% dir_maskDown=dir("Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\cropped\maskDown\*.jpg");
% % dir_mask=dir("Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\cropped\mask\*.jpg");

num_points = readmatrix('D:\work\FirstYearMaster\oppoSkinExperi\points48.xlsx'); 
% num_points = readmatrix('Z:\homes\Peggy\oppoSkinExperi\points48.xlsx'); 
num_center = num_points(53,:); 
num_points(50:53,:)=[];

save_folder=['D:\work\FirstYearMaster\oppoSkinExperi\picked40\iphone\' ...
    'cropped\renderedLUTchoose\renderedReCen07'];
if ~exist(save_folder,'dir')
    mkdir(save_folder);
end


BigDeCenter=[6,8,9,11,15,16,21,24,27,31,33,34];
harLine=[25,29];

% for i = 33:33
for i = 1:numel(files)
    % if ~ismember(i, BigDeCenter)
    %     continue
    % end    
    num_of_g=floor(i/10);
    num_inside_g=mod(i,10);
    if num_inside_g==0
        num_inside_g=10;
        num_of_g=num_of_g-1;
    end
    if num_of_g==0
        group_string='indoorAdd';
    elseif num_of_g==1
        group_string='nightAdd';
    elseif num_of_g==2
        group_string='outdoorAdd';
    elseif num_of_g==3
        group_string='sunsetAdd';
    end
    DeCen_folder=fullfile(['D:\work\FirstYearMaster\oppoSkinExperi\' ...
        'ExperimentResult\all_delete'],group_string);
    DeCen_file=fullfile(DeCen_folder, 'sorted_results\matrix_sorted.mat');
    ReCen=load(DeCen_file);
    ReCen=ReCen.matrix_decenter;
    ReCen=cell2mat(ReCen(num_inside_g,2:4));

    white65=[95.04,100,108.89];
    
    filename = fullfile(files(i).folder, files(i).name);      
    img0=imread(filename);
    img=im2double(img0);
    [m, n, p] = size(img);
    out = reshape(img, [m * n, p]);     
    out=out*255;

    if i==6
        startCenter=15;
        endCenter=49;
    else
        startCenter=1;
        endCenter=49;
    end

    for i_points=startCenter:endCenter
        % if ~ismember(harLine,i_points)
        %     continue
        % end
        delta_Lab=num_points(i_points,:)-num_center;
        delta_Lab1=0.7*delta_Lab;
        dlab=ReCen+delta_Lab1;
        % bull=imread(strcat(dir_mask(i).folder,'\',dir_mask(i).name));
        % dlab=average(i,:)+delta_Lab1;
        if delta_Lab1(1)>0
            bull=imread(strcat(dir_maskUp(i).folder,'\',dir_maskUp(i).name));
        else
            bull=imread(strcat(dir_maskDown(i).folder,'\',dir_maskDown(i).name));
        end
        bull_reshaped=reshape(bull, [m * n, p])./255;
        bull_reshaped = double(bull_reshaped);
        img_file=fullfile(save_folder ,...
            strcat(files(i).name(1:end-4),'_',sprintf('%02d', i_points),'[',num2str(dlab(1,1)),',' ,...
            num2str(dlab(1,2)),',',num2str(dlab(1,3)),'].jpg'));
        if exist(img_file, 'file') == 2
            continue
        end
        
        disp([num2str(i_points),'/49of',num2str(i),'/',num2str(numel(files)),' ',files(i).name,' begin']);

        [out_rendering,outofgamut]=img_AddRender(img,bull,'LUT',delta_Lab1);
        imshow(out_rendering);
    
        disp([num2str(i_points),'/49of',num2str(i),'/',num2str(numel(files)),' ',files(i).name,' was done']);
        imwrite(out_rendering,fullfile(save_folder ...
            ,strcat(files(i).name(1:end-4),'_',sprintf('%02d', i_points),'[',num2str(dlab(1,1)),',' ,...
            num2str(dlab(1,2)),',',num2str(dlab(1,3)),'].jpg') ));
        disp(['Out-of-gamut ratio:',num2str(outofgamut)]);
        currentTime = datetime('now');    
        formattedTime = datestr(currentTime, 'yyyy-mm-dd HH:MM:SS');
        disp([files(i).name(1:end-4),'_',num2str(i_points),'finished: ', formattedTime]);
    end
    currentTime = datetime('now');  
    formattedTime = datestr(currentTime, 'yyyy-mm-dd HH:MM:SS');
    disp([files(i).name(1:end-4),'finished: ',formattedTime]);
end



