close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量
addpath("utils\")
%%
lastParts = {'f04r', 'f05r', 'f06r', 'm04r', 'm05r', 'm06r',...
'f01r', 'f02r', 'f03r', 'm01r', 'm02r', 'm03r',...
'f07r', 'f08r','m07r', 'm08r',...
'f09r', 'f10r','m09r', 'm10r'};
picnames_groups = ["rs01","rs02","rs03","rs04","rs05","rs06","rs07", ...
                 "rs08","rs09","rs10","rs11","rs12","rs13","rs14"];

wd65=[94.813  100.000  107.262];
source_folder="optmizedD\whiteSquare\XYZw_white";
if ~exist(source_folder,"dir")
    mkdir(source_folder);
end
datai_file = '..\renderCode\calibResults\data_ipv18_3.mat';
wd65=[94.813  100.000  107.262];
LUT=load(datai_file);
XYZw_LUT=LUT.XYZw;
wd65_scaled=wd65./100.*XYZw_LUT(2);

for i_lastPart=1:length(lastParts)
    clear("XYZw_white")
    lastPart=lastParts(i_lastPart);
    lastPart=char(lastPart);
    model=lastPart(1:end-1);
    iOr=lastPart(end);
    white_file=fullfile(source_folder,strcat(lastPart,".mat"));
    load(white_file,"XYZw_white");
    for i_para=1:size(XYZw_white,1)
        if XYZw_white(i_para,2)>XYZw_LUT(2)
            XYZw_white(i_para,:)=XYZw_white(i_para,:)./XYZw_white(i_para,2).*XYZw_LUT(2);
        end
    end
    save(fullfile(source_folder,strcat(lastPart,".mat")),"XYZw_white");
end
%%
% % picnames_groups = ["h3k","h4k","h5k","h6k","hd65","h7k","h8k",...
% %                 "m3k","m4k","m5k","m6k","md65","m7k","m8k",...
% %                  "l3k","l4k","l5k","l6k","ld65","l7k","l8k"];
% % lastParts = {'f04i', 'f05i', 'f06i', 'm04i', 'm05i', 'm06i',...
% % 'f01i', 'f02i', 'f03i', 'm01i', 'm02i', 'm03i',...
% % 'f07i', 'f08i','m07i', 'm08i',...
% % 'f09i', 'f10i','m09i', 'm10i'};
% 
% lastParts = {'f04r', 'f05r', 'f06r', 'm04r', 'm05r', 'm06r',...
% 'f01r', 'f02r', 'f03r', 'm01r', 'm02r', 'm03r',...
% 'f07r', 'f08r','m07r', 'm08r',...
% 'f09r', 'f10r','m09r', 'm10r'};
% picnames_groups = ["rs01","rs02","rs03","rs04","rs05","rs06","rs07", ...
%                  "rs08","rs09","rs10","rs11","rs12","rs13","rs14"];
% 
% wd65=[94.813  100.000  107.262];
% save_folder="optmizedD\whiteSquare\XYZw_white";
% if ~exist(save_folder,"dir")
%     mkdir(save_folder);
% end
% 
% 
% for i_lastPart=1:length(lastParts)
%     clear("XYZw_white")
%     lastPart=lastParts(i_lastPart);
%     lastPart=char(lastPart);
%     model=lastPart(1:end-1);
%     iOr=lastPart(end);
% 
% 
%     dir_XYZ=dir(fullfile("..\renderCode\XYZ",strrep(iOr,"r","rs"),lastPart,"*.mat"));
% 
%     for i_para = 1:length(picnames_groups)
% 
%             for i_xyz=1:length(dir_XYZ)
%                 if strcmp(iOr,'i')
%                     xyz_name_curr=dir_XYZ(i_xyz).name(1:end-4);
%                 elseif strcmp(iOr,'r')
%                     slash=find(dir_XYZ(i_xyz).name=='_');
%                     xyz_name_curr=dir_XYZ(i_xyz).name(slash+1:end-4);
%                 end
%                 if strcmpi(xyz_name_curr,picnames_groups(i_para))
%                     picname_check{i_para,1}=dir_XYZ(i_xyz).name(1:end-4);
%                     XYZdata=load(fullfile(dir_XYZ(i_xyz).folder,dir_XYZ(i_xyz).name));
%                     XYZ_cropped=XYZdata.XYZ_cropped;
%                     if strcmp(iOr,'r')
%                         XYZw_white(i_para,:) =XYZdata.XYZw;
%                     end
%                     break
%                 end
%             end
% 
%             if strcmp(iOr,'i')
%                 datafile = '..\renderCode\calibResults\data_ipv18_3.mat';
%                 LUT=load(datafile);
%                 XYZw_LUT=LUT.XYZw;
%                 wd65_scaled=wd65./100.*XYZw_LUT(2);
% 
%                 file_whiteSquare=fullfile("..\camera model-20240924\whiteSquare" , ...
%                     strcat("crop_rect_info_white_",lastPart,".mat"));
%                 load(file_whiteSquare);
% 
%                 reorder_indices = [1, 2, 3, 4, 7, 5, 6,...
%                     15, 16, 17, 18, 21, 19, 20, ...
%                     8, 9, 10, 11, 14, 12, 13];
%                 crop_rect_info = crop_rect_info(reorder_indices, :);
%                 gray_pos = crop_rect_info(i_para,:);
%                 XYZw_white(i_para,:) = mean(mean(XYZ_cropped(gray_pos(2): gray_pos(2)+30, ...
%                     gray_pos(1) :gray_pos(1)+30,:)));
%                 figure(1)
%                 hold on;
%                 imshow(XYZ_cropped./20);
%                 rectangle('Position', [gray_pos(1), gray_pos(2), 30, 30], ...
%                       'EdgeColor', 'r', ...        
%                       'LineWidth', 2);            
%                 check_folder=fullfile(save_folder,"check_pic",lastPart);
%                 if ~exist(check_folder,"dir")
%                     mkdir(check_folder);
%                 end
%                 exportgraphics(gcf,fullfile(check_folder, ...
%                     strcat(picname_check{i_para,1},".jpg")));
%             end
% 
%     end
% 
%     save(fullfile(save_folder,strcat(lastPart,".mat")), "XYZw_white");
% end
% disp("done");
% 
