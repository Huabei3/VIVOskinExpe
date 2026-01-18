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
    'renderedLUTchoose\PMCCcen'];
if ~exist(save_folder,"dir")
    mkdir(save_folder);
end
num_points = readmatrix('Z:\homes\Peggy\oppoSkinExperi\points48.xlsx'); 
num_center = num_points(53,:); 
num_points(50:53,:)=[];
num_points=num_points-repmat(num_points(49,:),length(num_points),1);
lab_PMCC=[62.11,18.96,19.76];

darkModel=[5,16,27,33];

for i = 1:numel(files)
    if ~ismember(i,darkModel)
        continue
    end


    white65=[95.04,100,108.89];
    
    filename = fullfile(files(i).folder, files(i).name);      
    img0=imread(filename);
    %跑小图
    img0=imresize(img0,[size(img0,1)/5,size(img0,2)/5]);

    img=im2double(img0);
    [m,n,p]=size(img);
    % if i==6
    %     startCenter=15;
    %     endCenter=49;
    % else
        startCenter=1;
        endCenter=49;
    % end
    
    for i_points=startCenter:endCenter
        delta_Lab=lab_PMCC+num_points(i_points,:)-average(i,:);
        dlab=lab_PMCC+num_points(i_points,:);

        if delta_Lab(1)>0
            bull=imread(strcat(dir_maskUp(i).folder,'\',dir_maskUp(i).name));
        else
            bull=imread(strcat(dir_maskDown(i).folder,'\',dir_maskDown(i).name));
        end
        %跑小图
        bull=imresize(bull,[size(bull,1)/5,size(bull,2)/5]);

        bull_reshaped=reshape(bull, [m * n, p])./255;
        bull_reshaped = double(bull_reshaped);
        output_folder=fullfile(save_folder,'PMCCcen_dlab');
        if ~exist(output_folder, 'dir')
            mkdir(output_folder);
        end
        img_file=fullfile(output_folder ...
            ,strcat(files(i).name(1:end-4),'_',sprintf('%02d', i_points),'[',num2str(dlab(1,1)),',' ,...
            num2str(dlab(1,2)),',',num2str(dlab(1,3)),'].jpg'));
        if ~exist(img_file, 'file')
            disp([num2str(i_points),'/49of',num2str(i),'/',num2str(numel(files)),' ',files(i).name,'PMCC begin']);
            %---------渲染-----------
            [out_rendering,outofgamut]=img_AddRender_dlab(img,bull,'LUT',dlab);
            %---------渲染-----------
            imshow(out_rendering);
    
            disp([num2str(i_points),'/49of',num2str(i),'/',num2str(numel(files)),' ',files(i).name,' was done']);
    
            imwrite(out_rendering,fullfile(output_folder, ...
                strcat(files(i).name(1:end-4),'_',sprintf('%02d', i_points),'[',num2str(dlab(1,1)),',' ,...
                num2str(dlab(1,2)),',',num2str(dlab(1,3)),'].jpg')) );
            disp(['Out-of-gamut ratio:',num2str(outofgamut)]);
            currentTime = datetime('now');    
            formattedTime = datestr(currentTime, 'yyyy-mm-dd HH:MM:SS');
            disp([files(i).name(1:end-4),'_',num2str(i_points),'PMCC finished: ', formattedTime]);
        end
    end
end



