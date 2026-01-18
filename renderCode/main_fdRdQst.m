close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量
%%
files = dir('Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\cropped\cropped_*.jpg');  % 读取文件夹中的所有.jpg文件
dir_pointsfiles=dir("Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\cropped\setPoints\setPoints*.mat");
dir_mask=dir("Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\cropped\mask\*.jpg");

% files = dir('Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\cropped\findRdQst\Ori\*.jpg');  % 读取文件夹中的所有.jpg文件
% dir_pointsfiles=dir("Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\cropped\findRdQst\setPoints\*.mat");
% dir_mask=dir("Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\cropped\findRdQst\mask\*.jpg");
% for i = 6:6
for i = 9:numel(files)  %改为1：numel(files),可以实现对文件夹中图片进行批量操作
    close all   
    white65=[95.04,100,108.89];
%     load(strcat(dir_pointsfiles(1).folder,'\',dir_pointsfiles(1).name));%加载setPoints
    load(strcat(dir_pointsfiles(i).folder,'\',dir_pointsfiles(i).name));%加载setPoints
    spq=1;
    mode=3;         %1 caucasian,2 brown,3 chinese,4 sky ,5 grass，6 black
    load zip/w.mat   %ddddd
    
    filename = fullfile(files(i).folder, files(i).name);  % 获取文件名,包含路径
    img0=imread(filename);
    img=im2double(img0);

    for i_points=1:length(centers)
        dlab=centers(i_points,:);
        [predict_white,rgbnew,ccT,duv,bull,bullx,ratio,lab,xyz,center0,center1]=AWBrendering_srgb(img,mode,spq,w,dlab,'srgb');%渲染函数
        bull=imread(strcat(dir_mask(i).folder,'\',dir_mask(i).name));

        [out_rendering,outxyz,k,out_awb,outofgamut]=imgcat_fdQst(img,bull,predict_white,white65,white65,w,'sRGB',i,i_points);%根据计算得到的白点，进行cat变化，得到渲染后的图像
        imshow(out_rendering);
    
        disp([num2str(i_points),'/49of',num2str(i),'/',num2str(numel(files)),' ',files(i).name,' was done']);
        if outofgamut<0.15
            imwrite(out_rendering,['Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\cropped\findRdQst\fdQstRendered\' ...
            ,files(i).name(1:end-4),'_',num2str(i_points),'[',num2str(dlab(1,1)),',' ,...
            num2str(dlab(1,2)),',',num2str(dlab(1,3)),'].jpg'] );
        else
            imwrite(out_rendering,['Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\cropped\findRdQst\fdQstRendered\' ...
            ,'outofgamut\',files(i).name(1:end-4),'_',num2str(i_points),'Out_[',num2str(dlab(1,1)),',' ,...
            num2str(dlab(1,2)),',',num2str(dlab(1,3)),'].jpg'] );
        end

%         save(strcat("D:\oppoSkinExperi\picked40\iphone" + ...
%             "\aveSkinColor",files(i).name(9:end-4),".mat"),'center0');
    % 获取当前日期和时间
    currentTime = datetime('now');    
    formattedTime = datestr(currentTime, 'yyyy-mm-dd HH:MM:SS');
    % 打印当前日期和时间
    disp([files(i).name(1:end-4),'_',num2str(i_points),'结束，当前时间是: ', formattedTime]);
    end
        % 获取当前日期和时间
    currentTime = datetime('now');  
    formattedTime = datestr(currentTime, 'yyyy-mm-dd HH:MM:SS');
    % 打印当前日期和时间
    disp([files(i).name(1:end-4),'结束，当前时间是: ',formattedTime]);
end



