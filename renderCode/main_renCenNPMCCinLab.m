close all; 
clc;       
clear;     
%%

files = dir('Z:\homes\Peggy\oppoSkinExperi\picked40\Hassel\downSampled1\cropped\*.jpg'); 
average_file='Z:\homes\Peggy\oppoSkinExperi\picked40\Hassel\downSampled1\cropped\aveSkinByHand\autoNhand.mat';
dir_mask=dir("Z:\homes\Peggy\oppoSkinExperi\picked40\Hassel\downSampled1\cropped\mask\*.jpg");

average=load(average_file);
average=average.average_lab_all(:,5:7);

save_folder=['Z:\homes\Peggy\oppoSkinExperi\picked40\Hassel\downSampled1\' ...
    'cropped\PreferNPMCC'];

num_points = readmatrix('Z:\homes\Peggy\oppoSkinExperi\points48.xlsx'); 
num_center = num_points(53,:); 
num_points(50:53,:)=[];

DeCen_folder=['Z:\homes\Peggy\oppoSkinExperi\ExperimentResult\analyseFile\' ...
    'all_delete\inLab\List'];
DeCen_file=fullfile(DeCen_folder, 'fit_List_ellipsoidNoMat1.mat');
ReCen=load(DeCen_file);
ReCen=ReCen.list2(:,1:3);

lab_PMCC=[62.11,18.96,19.76];

BigDePMCC=[3,4,5];

% for i = 33:33
for i = 1:numel(files)
    if ~ismember(i, BigDePMCC)
        continue
    end    


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
        % dlab=ReCen(i,:)+delta_Lab1;
        % bull=imread(strcat(dir_mask(i).folder,'\',dir_mask(i).name));
        % 
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
        delta_Lab=lab_PMCC-average(i,:);
        
        dlab=average(i,:)+delta_Lab;

        bull=imread(strcat(dir_mask(i).folder,'\',dir_mask(i).name));

        bull_reshaped=reshape(bull, [m * n, p])./255;
        bull_reshaped = double(bull_reshaped);
        output_folder=fullfile(save_folder,'PMCC');
        if ~exist(output_folder, 'dir')
            mkdir(output_folder);
        end
        img_file=fullfile(output_folder ...
            ,strcat(files(i).name(1:end-4),'_',sprintf('%02d', i_points),'PMCC[',num2str(dlab(1,1)),',' ,...
            num2str(dlab(1,2)),',',num2str(dlab(1,3)),'].jpg'));
        if exist(img_file, 'file') == 2
            continue
        end
        
        disp([num2str(i_points),'/49of',num2str(i),'/',num2str(numel(files)),' ',files(i).name,' begin']);
        %---------渲染-----------
        [out_rendering,outofgamut]=img_AddRenderD65(img,bull,'LUT',delta_Lab);
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



