clear;
%%
% %小图变大图
dir_rendered=dir("Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\cropped\renderedLUTchoose\renderedLUT07\night\*.jpg");
dir_ori=dir("Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\*.jpg");
dir_para=dir("Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\cropped\crop_para\crop_para*.mat");
i_ori=1;
rendered_ori=zeros(length(dir_rendered),1);
% for i_rendered=197:245
for i_rendered=1:length(dir_rendered)
    rendered_img=imread([dir_rendered(i_rendered).folder,'\',dir_rendered(i_rendered).name]);
    while(contains(dir_rendered(i_rendered).name,dir_ori(i_ori).name(1:end-4))==0)
        i_ori=i_ori+1;
    end
    rendered_ori(i_rendered)=i_ori;
%     i_ori=floor(i_rendered/49)+1;
    ori_img=imread([dir_ori(i_ori).folder,'\',dir_ori(i_ori).name]);    
    load([dir_para(i_ori).folder,'\',dir_para(i_ori).name]);
    ori_img(cropRect(2):(cropRect(2)+cropRect(4)), cropRect(1):(cropRect(1)+cropRect(3)), :) = rendered_img;

    % 步骤6: 保存最终图像
    imwrite(ori_img, ['Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\cropped\' ...
        'renderedLUTchoose\renderedLUT07\night\rendered_big_night\', ...
        dir_rendered(i_rendered).name]);

end

% save('Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\cropped\renderedLUTchoose\renderedLUT07\drawable_indoor\rendered_ori.mat','rendered_ori');