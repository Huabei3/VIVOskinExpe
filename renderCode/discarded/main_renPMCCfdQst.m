close all; 
clc;       
clear;     
%%
files = dir('Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\cropped\renderedLUTchoose\PreferNPMCC\findQst\cropped\*.jpg');  
dir_maskUp=dir("Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\cropped\renderedLUTchoose\PreferNPMCC\findQst\maskUp\*.jpg");
dir_maskDown=dir("Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\cropped\renderedLUTchoose\PreferNPMCC\findQst\maskDown\*.jpg");
% dir_mask=dir("Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\cropped\mask\*.jpg");
% average_file='Z:\homes\Peggy\oppoSkinExperi\picked40\Hassel\downSampled1\cropped\aveSkinByHand\autoNhand.mat';
% files = dir('Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\cropped\*.jpg');  
% dir_mask=dir("Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\cropped\mask\*.jpg");
average_file='Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\cropped\aveSkinByHand\autoNhand.mat';
average=load(average_file);
average=average.average_lab_all(:,5:7);
average=average(12,:);

save_folder=['Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\cropped\' ...
    'renderedLUTchoose\PreferNPMCC\findQst\rendered'];
num_points = readmatrix('Z:\homes\Peggy\oppoSkinExperi\points48.xlsx'); 
num_center = num_points(53,:); 
num_points(50:53,:)=[];
lab_PMCC=[62.11,18.96,19.76];


for i = 1:numel(files)
    num_of_g=1;
    num_inside_g=2;
    % num_of_g=floor(i/10);
    % num_inside_g=mod(i,10);
    if num_of_g==0
        group_string='indoorAdd';
    elseif num_of_g==1
        group_string='nightAdd';
    elseif num_of_g==2
        group_string='outdoorAdd';
    elseif num_of_g==3
        group_string='sunsetAdd';
    end
    DeCen_folder=fullfile(['Z:\homes\Peggy\oppoSkinExperi\ExperimentResult\' ...
        'analyseFile\all_delete'],group_string);
    DeCen_file=fullfile(DeCen_folder, 'sorted_results\matrix_sorted.mat');
    ReCen=load(DeCen_file);
    ReCen=ReCen.matrix_decenter;
    ReCen=cell2mat(ReCen(num_inside_g,2:4));

    white65=[95.04,100,108.89];
    
    filename = fullfile(files(i).folder, files(i).name);      
    img0=imread(filename);
    img=im2double(img0);
    [m,n,p]=size(img);
    % if i==6
    %     startCenter=15;
    %     endCenter=49;
    % else
        startCenter=49;
        endCenter=49;
    % end

    for i_points=startCenter:endCenter

        % delta_Lab=num_points(i_points,:)-num_center;
        % delta_Lab1=0.7*delta_Lab;
        % dlab=ReCen+delta_Lab1;
        % 
        % if delta_Lab1(1)>0
        %     bull=imread(strcat(dir_maskUp(i).folder,'\',dir_maskUp(i).name));
        % else
        %     bull=imread(strcat(dir_maskDown(i).folder,'\',dir_maskDown(i).name));
        % end
        % bull_reshaped=reshape(bull, [m * n, p])./255;
        % bull_reshaped = double(bull_reshaped);
        % output_folder=fullfile(save_folder,'Prefer');
        % if ~exist(output_folder, 'dir')
        %     mkdir(output_folder);
        % end
        % img_file=fullfile(output_folder ...
        %     ,strcat(files(i).name(1:end-4),'_',sprintf('%02d', i_points),'[',num2str(dlab(1,1)),',' ,...
        %     num2str(dlab(1,2)),',',num2str(dlab(1,3)),'].jpg'));
        % if exist(img_file, 'file') == 2
        %     continue
        % end
        % 
        % disp([num2str(i_points),'/49of',num2str(i),'/',num2str(numel(files)),' ',files(i).name,' begin']);
        % %---------渲染-----------
        % [out_rendering,outofgamut]=img_AddRender(img,bull,'LUT',delta_Lab1);
        % %---------渲染-----------
        % imshow(out_rendering);
        % 
        % disp([num2str(i_points),'/49of',num2str(i),'/',num2str(numel(files)),' ',files(i).name,' was done']);
        % 
        % imwrite(out_rendering,fullfile(output_folder, ...
        %     strcat(files(i).name(1:end-4),'_',sprintf('%02d', i_points),'[',num2str(dlab(1,1)),',' ,...
        %     num2str(dlab(1,2)),',',num2str(dlab(1,3)),'].jpg')) );
        % disp(['Out-of-gamut ratio:',num2str(outofgamut)]);
        % currentTime = datetime('now');    
        % formattedTime = datestr(currentTime, 'yyyy-mm-dd HH:MM:SS');
        % disp([files(i).name(1:end-4),'_',num2str(i_points),'finished: ', formattedTime]);
        
        %-------------Render PMCC-------------------
        delta_Lab=lab_PMCC-average;
        
        dlab=average+delta_Lab;

        if delta_Lab(1)>0
            bull=imread(strcat(dir_maskUp(i).folder,'\',dir_maskUp(i).name));
        else
            bull=imread(strcat(dir_maskDown(i).folder,'\',dir_maskDown(i).name));
        end
        bull_reshaped=reshape(bull, [m * n, p])./255;
        bull_reshaped = double(bull_reshaped);
        output_folder=fullfile(save_folder,'PMCC');
        if ~exist(output_folder, 'dir')
            mkdir(output_folder);
        end
        img_file=fullfile(output_folder ...
            ,strcat(files(i).name(1:end-4),'_',sprintf('%02d', i_points),'PMCC[',num2str(dlab(1,1)),',' ,...
            num2str(dlab(1,2)),',',num2str(dlab(1,3)),'].jpg'));
        % if exist(img_file, 'file') == 2
        %     continue
        % end
        
        disp([num2str(i_points),'/49of',num2str(i),'/',num2str(numel(files)),' ',files(i).name,' begin']);
        %---------渲染-----------
        [out_rendering,outofgamut]=img_AddRender(img,bull,'LUT',delta_Lab);
        %---------渲染-----------
        imshow(out_rendering);
    
        disp([num2str(i_points),'/49of',num2str(i),'/',num2str(numel(files)),' ',files(i).name,' was done']);

        imwrite(out_rendering,fullfile(output_folder, ...
            strcat(files(i).name(1:end-4),'_',sprintf('%02d', i_points),'PMCC[',num2str(dlab(1,1)),',' ,...
            num2str(dlab(1,2)),',',num2str(dlab(1,3)),'].jpg')) );
        disp(['Out-of-gamut ratio:',num2str(outofgamut)]);
        currentTime = datetime('now');    
        formattedTime = datestr(currentTime, 'yyyy-mm-dd HH:MM:SS');
        disp([files(i).name(1:end-4),'_',num2str(i_points),'PMCC finished: ', formattedTime]);

    end
    currentTime = datetime('now');  
    formattedTime = datestr(currentTime, 'yyyy-mm-dd HH:MM:SS');
    disp([files(i).name(1:end-4),'finished: ',formattedTime]);
end



