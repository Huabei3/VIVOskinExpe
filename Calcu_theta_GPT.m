% 椭圆参数：k1, k2, k3, a0, b0, alpha（每行一组）
close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量
load("E:\documents\MATLAB\SkinColorPreferenceScale\level_data\fitRes_level.mat");
params=par_all;
theta_all=[];
isshort=[];
% n_level=size(params)
% 遍历每组参数
for i = 1:size(params, 1)
    % 提取当前组的参数
    k1 = params(i, 1);
    k2 = params(i, 2);
    k3 = params(i, 3);
    a0 = params(i, 4);
    b0 = params(i, 5);
    alpha = params(i, 6);
    
    % 计算倾角theta，这里使用atan2d来直接得到角度
    theta = 0.5 * atan2d_360(2 * k3, (k1 - k2));
    
    % 确保theta在0到180度之间
%     if theta < 0
%         theta = theta + 180;
%     end
    theta_all=[theta_all;theta];
    isshort=[isshort;k1<k2];
    
    % 打印结果
%     fprintf('组 %d: 长轴与a轴的夹角为 %.2f 度', i, theta);
end


function degree = atan2d_360(y, x)
    degree = atan2d(y, x);
    if degree < 0
        degree = degree + 360;
    end
end