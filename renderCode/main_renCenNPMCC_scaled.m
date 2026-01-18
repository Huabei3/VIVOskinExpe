close all; 
clc;       
clear;     
%%
files = dir('Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\cropped\*.jpg');  
dir_maskUp=dir("Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\cropped\maskUp\*.jpg");
dir_maskDown=dir("Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\cropped\maskDown\*.jpg");

average_file='Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\cropped\aveSkinByHand\autoNhand.mat';
average=load(average_file);
average=average.average_lab_all(:,5:7);

save_folder=['Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\cropped\' ...
    'renderedLUTchoose\PreferNPMCC_scaled'];
if ~exist(save_folder,"dir")
    mkdir(save_folder);
end
num_points = readmatrix('Z:\homes\Peggy\oppoSkinExperi\points48.xlsx'); 
num_center = num_points(53,:); 
num_points(50:53,:)=[];
lab_PMCC=[62.11,18.96,19.76];

smallDePMCC=[12,13,23];
% BigDePMCC=[12,13,14,21,22,23,25,30,33,36];
% smallHue=[37,38];

% for i = 33:33
for i = 1:numel(files)
    if (~ismember(i, smallDePMCC))
        continue
    end   
    % if (~ismember(i, smallHue))&&(~ismember(i, BigDePMCC))
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
    DeCen_folder=fullfile(['Z:\homes\Peggy\oppoSkinExperi\ExperimentResult\analyseFile\' ...
        'all_delete\scaled'],group_string);
    DeCen_file=fullfile(DeCen_folder, 'ellipPara_scaled\fitRes_level.mat');
    ReCen=load(DeCen_file);
    ReCen=ReCen.parNr_all;
%     ReCen=cell2mat(ReCen(num_inside_g,5:7));
    ReCen=ReCen(num_inside_g,5:7);

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
%%
%-------------Render prefer-------------------
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
        % if ~(exist(img_file, 'file') == 2)
        % 
        %     disp([num2str(i_points),'/49of',num2str(i),'/',num2str(numel(files)),' ',files(i).name,' prefer begin']);
        %     %---------渲染-----------
        %     [out_rendering,outofgamut]=img_AddRenderscaled(img,bull,'LUT',delta_Lab1);
        %     %---------渲染-----------
        %     imshow(out_rendering);
        % 
        %     disp([num2str(i_points),'/49of',num2str(i),'/',num2str(numel(files)),' ',files(i).name,' was done']);
        % 
        %     imwrite(out_rendering,fullfile(output_folder, ...
        %         strcat(files(i).name(1:end-4),'_',sprintf('%02d', i_points),'[',num2str(dlab(1,1)),',' ,...
        %         num2str(dlab(1,2)),',',num2str(dlab(1,3)),'].jpg')) );
        %     disp(['Out-of-gamut ratio:',num2str(outofgamut)]);
        %     currentTime = datetime('now');    
        %     formattedTime = datestr(currentTime, 'yyyy-mm-dd HH:MM:SS');
        %     disp([files(i).name(1:end-4),'_',num2str(i_points),'finished: ', formattedTime]);
        % end
%%
        %-------------Render PMCC-------------------
        delta_Lab=lab_PMCC-average(i,:);

        dlab=average(i,:)+delta_Lab;

        if delta_Lab(1)>0
            bull=imread(strcat(dir_maskUp(i).folder,'\',dir_maskUp(i).name));
        else
            bull=imread(strcat(dir_maskDown(i).folder,'\',dir_maskDown(i).name));
        end
        bull_reshaped=reshape(bull, [m * n, p])./255;
        bull_reshaped = double(bull_reshaped);
        output_folder=fullfile(save_folder,'PMCC_scaled');
        if ~exist(output_folder, 'dir')
            mkdir(output_folder);
        end
        img_file=fullfile(output_folder ...
            ,strcat(files(i).name(1:end-4),'_',sprintf('%02d', i_points),'PMCC[',num2str(dlab(1,1)),',' ,...
            num2str(dlab(1,2)),',',num2str(dlab(1,3)),'].jpg'));
        % if ~(exist(img_file, 'file') == 2)
            disp([num2str(i_points),'/49of',num2str(i),'/',num2str(numel(files)),' ',files(i).name,'PMCC begin']);
            %---------渲染-----------
            [out_rendering,outofgamut]=img_AddRenderscaled(img,bull,'LUT',delta_Lab);
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
        % end
%%
        %-------------Render PMCC ori L-------------------

        % delta_Lab=lab_PMCC-average(i,:);
        % dlab=average(i,:)+delta_Lab;
        % dlab(1,1)=average(i,1);
        % 
        % if delta_Lab(1)>0
        %     bull=imread(strcat(dir_maskUp(i).folder,'\',dir_maskUp(i).name));
        % else
        %     bull=imread(strcat(dir_maskDown(i).folder,'\',dir_maskDown(i).name));
        % end
        % bull_reshaped=reshape(bull, [m * n, p])./255;
        % bull_reshaped = double(bull_reshaped);
        % output_folder=fullfile(save_folder,'PMCC_ori_L');
        % if ~exist(output_folder, 'dir')
        %     mkdir(output_folder);
        % end
        % img_file=fullfile(output_folder ...
        %     ,strcat(files(i).name(1:end-4),'_',sprintf('%02d', i_points),'PMCC[',num2str(dlab(1,1)),',' ,...
        %     num2str(dlab(1,2)),',',num2str(dlab(1,3)),'].jpg'));
        % if ~(exist(img_file, 'file') == 2)
        % 
        %     disp([num2str(i_points),'/49of',num2str(i),'/',num2str(numel(files)),' ',files(i).name,'PMCC ori L begin']);
        %     %---------渲染-----------
        %     [out_rendering,outofgamut]=img_AddRenderscaled(img,bull,'LUT',delta_Lab);
        %     %---------渲染-----------
        %     imshow(out_rendering);
        % 
        %     disp([num2str(i_points),'/49of',num2str(i),'/',num2str(numel(files)),' ',files(i).name,' was done']);
        % 
        %     imwrite(out_rendering,fullfile(output_folder, ...
        %         strcat(files(i).name(1:end-4),'_',sprintf('%02d', i_points),'PMCC[',num2str(dlab(1,1)),',' ,...
        %         num2str(dlab(1,2)),',',num2str(dlab(1,3)),'].jpg')) );
        %     disp(['Out-of-gamut ratio:',num2str(outofgamut)]);
        %     currentTime = datetime('now');    
        %     formattedTime = datestr(currentTime, 'yyyy-mm-dd HH:MM:SS');
        %     disp([files(i).name(1:end-4),'_',num2str(i_points),'PMCC finished: ', formattedTime]);
        % end
%%
        %-------------Render prefer ori L-------------------

        % delta_Lab=num_points(i_points,:)-num_center;
        % delta_Lab1=0.7*delta_Lab;
        % dlab=ReCen+delta_Lab1;
        % dlab(1,1)=average(i,1);
        % 
        % if delta_Lab1(1)>0
        %     bull=imread(strcat(dir_maskUp(i).folder,'\',dir_maskUp(i).name));
        % else
        %     bull=imread(strcat(dir_maskDown(i).folder,'\',dir_maskDown(i).name));
        % end
        % bull_reshaped=reshape(bull, [m * n, p])./255;
        % bull_reshaped = double(bull_reshaped);
        % output_folder=fullfile(save_folder,'Prefer_ori_L');
        % if ~exist(output_folder, 'dir')
        %     mkdir(output_folder);
        % end
        % img_file=fullfile(output_folder ...
        %     ,strcat(files(i).name(1:end-4),'_',sprintf('%02d', i_points),'[',num2str(dlab(1,1)),',' ,...
        %     num2str(dlab(1,2)),',',num2str(dlab(1,3)),'].jpg'));
        % if ~(exist(img_file, 'file') == 2)
        % 
        %     disp([num2str(i_points),'/49of',num2str(i),'/',num2str(numel(files)),' ',files(i).name,'prefer ori L begin']);
        %     %---------渲染-----------
        %     [out_rendering,outofgamut]=img_AddRenderscaled(img,bull,'LUT',delta_Lab1);
        %     %---------渲染-----------
        %     imshow(out_rendering);
        % 
        %     disp([num2str(i_points),'/49of',num2str(i),'/',num2str(numel(files)),' ',files(i).name,' was done']);
        % 
        %     imwrite(out_rendering,fullfile(output_folder, ...
        %         strcat(files(i).name(1:end-4),'_',sprintf('%02d', i_points),'[',num2str(dlab(1,1)),',' ,...
        %         num2str(dlab(1,2)),',',num2str(dlab(1,3)),'].jpg')) );
        %     disp(['Out-of-gamut ratio:',num2str(outofgamut)]);
        %     currentTime = datetime('now');    
        %     formattedTime = datestr(currentTime, 'yyyy-mm-dd HH:MM:SS');
        %     disp([files(i).name(1:end-4),'_',num2str(i_points),'finished: ', formattedTime]);
        % 
        % end
    %%
        %-------------Render prefer PMCC L-------------------

        delta_Lab1=ReCen-average(i,:);
        delta_Lab1(1,1)=lab_PMCC(1,1)-average(i,1);
        dlab=average(i,:)+delta_Lab1;

        

        if delta_Lab1(1)>0
            bull=imread(strcat(dir_maskUp(i).folder,'\',dir_maskUp(i).name));
        else
            bull=imread(strcat(dir_maskDown(i).folder,'\',dir_maskDown(i).name));
        end
        bull_reshaped=reshape(bull, [m * n, p])./255;
        bull_reshaped = double(bull_reshaped);
        output_folder=fullfile(save_folder,'Prefer_PMCC_L');
        if ~exist(output_folder, 'dir')
            mkdir(output_folder);
        end
        img_file=fullfile(output_folder ...
            ,strcat(files(i).name(1:end-4),'_',sprintf('%02d', i_points),'[',num2str(dlab(1,1)),',' ,...
            num2str(dlab(1,2)),',',num2str(dlab(1,3)),'].jpg'));
        if ~(exist(img_file, 'file') == 2)

            disp([num2str(i_points),'/49of',num2str(i),'/',num2str(numel(files)),' ',files(i).name,'prefer PMCC L begin']);
            %---------渲染-----------
            [out_rendering,outofgamut]=img_AddRenderscaled(img,bull,'LUT',delta_Lab1);
            %---------渲染-----------
            imshow(out_rendering);
    
            disp([num2str(i_points),'/49of',num2str(i),'/',num2str(numel(files)),' ',files(i).name,' was done']);
    
            imwrite(out_rendering,fullfile(output_folder, ...
                strcat(files(i).name(1:end-4),'_',sprintf('%02d', i_points),'[',num2str(dlab(1,1)),',' ,...
                num2str(dlab(1,2)),',',num2str(dlab(1,3)),'].jpg')) );
            disp(['Out-of-gamut ratio:',num2str(outofgamut)]);
            currentTime = datetime('now');    
            formattedTime = datestr(currentTime, 'yyyy-mm-dd HH:MM:SS');
            disp([files(i).name(1:end-4),'_',num2str(i_points),'finished: ', formattedTime]);
        end
    end
    currentTime = datetime('now');  
    formattedTime = datestr(currentTime, 'yyyy-mm-dd HH:MM:SS');
    disp([files(i).name(1:end-4),'finished: ',formattedTime]);
end



