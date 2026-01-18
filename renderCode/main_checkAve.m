close all; 
clc;       
clear;     
%%
files = dir('Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\cropped\*.jpg');  
dir_maskUp=dir("Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\cropped\maskUp\*.jpg");
dir_maskDown=dir("Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\cropped\maskDown\*.jpg");

average_file='Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\cropped\aveSkinByHand\autoNhand1.mat';
average=load(average_file);
average=average.average_lab_all(:,5:7);
average_file='Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\cropped\aveSkinByHand\autoNhand1.mat';
average1=load(average_file);
average1=average1.average_lab_all(:,5:7);

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
    % img0=imresize(img0,[size(img0,1)/5,size(img0,2)/5]);

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
        delta_Lab=lab_PMCC+num_points(i_points,:)-average(i,:);
        dlab=lab_PMCC+num_points(i_points,:);

        if delta_Lab(1)>0
            bull=imread(strcat(dir_maskUp(i).folder,'\',dir_maskUp(i).name));
        else
            bull=imread(strcat(dir_maskDown(i).folder,'\',dir_maskDown(i).name));
        end
        %跑小图
        % bull=imresize(bull,[size(bull,1)/5,size(bull,2)/5]);

        bull_reshaped=reshape(bull, [m * n, p])./255;
        bull_reshaped = double(bull_reshaped);
        output_folder=fullfile(save_folder,'PMCCcen1');
        if ~exist(output_folder, 'dir')
            mkdir(output_folder);
        end
        img_file=fullfile(output_folder ...
            ,strcat(files(i).name(1:end-4),'_',sprintf('%02d', i_points),'[',num2str(dlab(1,1)),',' ,...
            num2str(dlab(1,2)),',',num2str(dlab(1,3)),'].jpg'));
        % if ~exist(img_file, 'file')
            % disp([num2str(i_points),'/49of',num2str(i),'/',num2str(numel(files)),' ',files(i).name,'PMCC begin']);
            %---------渲染-----------
            [mean_lab(i,:)]=img_checkAve(img,bull,'LUT',delta_Lab,dlab);
            %---------渲染-----------


        % end
    end
end


%%

function [mean_lab] = img_checkAve(img, bull, string,delta_Lab,dlab)
    % outnew 鏄?(targetwhite)鏍囧噯D65锛孻=100浣滀负鍙傝?冪櫧鏃剁殑缁撴灉锛屽浘鍍忎寒搴褰掍竴鍖栧埌0-100锛屾墍鏈夊儚绱犵殑xyz鍧囦箻浠ヤ寒搴︾郴鏁発L锛屽彲浠ヤ綔涓烘覆鏌撶粨鏋滀娇鐢紝鍥犱负鍙傝?冨厜婧愭亽瀹氫负D65锛孻=100
    % outxyz鍚岀悊锛屼娇鐢╕=100鏍囧噯D65杞崲鍒發ab

    
    % outnew2 鏄?(targetwhite)D65锛屼寒搴︿繚鎸佸師鍥句寒搴︾殑缁撴灉锛寈yz娌℃湁涔樼郴鏁帮紝鑰屾槸鍙傝?冪櫧D65鐨勪寒搴=100*kL,鍙互鐢ㄤ綔鐧藉钩琛★紝鍥犱负姣忎釜鍙傝?冪櫧閮芥牴鎹浘鐗囦寒搴﹀仛浜嗛?傚簲
    switch string
        case 'srgb'
            matrix = 1;
        case 'polynomial'
            matrix = 2;
        case 'LUT'
            matrix = 3;
    end

    [m, n, p] = size(img);
    out = reshape(img, [m * n, p]); % 灞曞紑
    xyz2 = zeros(size(out));
    bull_reshaped=reshape(bull, [m * n, p])./255;
    bull_reshaped = double(bull_reshaped);
    logicalIndex = all(bull_reshaped == 0, 2);
    % 璁＄畻浜害绯绘暟鍜屼慨姝ｇ殑鐧界偣

%     datai_file = 'Z:\homes\Peggy\oppoSkinExperi\LUT3d\results\datai_sorted53_3OV.mat';
    datai_file = 'Z:\homes\Peggy\oppoSkinExperi\LUT3d\results\datai_sorted40_3.mat';

    % RGB 杞崲鍒? XYZ
    if matrix == 1
        xyz1 = srgb2xyz(out);
    elseif matrix == 2
        xyz1 = rgb2xyz(out, w);
    elseif matrix == 3
        out = out * 255;
        xyz1 = lut3d_rgb2xyz1(out, datai_file);
        % disp(['lut3d_rgb2xyz1 over: ' datestr(now, 'yyyy-mm-dd HH:MM:SS')]);

    end
    XYZw=load(datai_file);
    XYZw=XYZw.XYZw;
    d65w=[94.811 100.00 107.304];
    d65w_scaled=d65w./100.*XYZw(2);

    [lab1] = xyz2lab(xyz1,'user',d65w_scaled);
    mean_lab=mean(lab1(~logicalIndex, :));
    n_face=length(lab1(~logicalIndex, :));
    rela=lab1(~logicalIndex, :)-repmat(mean_lab,n_face,1);
    lab2=lab1 ;
    lab2(~logicalIndex, :)=repmat(dlab,n_face,1)+rela;
    [xyz2] = lab2xyz2(lab2,'user',d65w_scaled);
end


