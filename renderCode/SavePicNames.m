close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量

dir_pics=dir("F:\研一\oppoSkinExperi\实验界面\实验界面\picture\rendered\*.jpg");


pic_names = cell(size(dir_pics));
for i_pics=1:length(dir_pics)
    pic_names{i_pics} = dir_pics(i_pics).name;
end
save("F:\研一\oppoSkinExperi\实验界面\实验界面\newfile1.mat","pic_names");