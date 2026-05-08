close all; % 关闭所有图窗
clc;       % 清空命令窗口
clear;     % 清除工作区所有变量
% 给定的系数
A = 0.191505188243304;
B = -0.0851113588015956;
C = 0.192214488736576;
D = 4.52989451613761;
E = 3.52618681832225;
F = 0.153831780537345;

% 方法1: 计算倾斜角 theta
theta1 = 0.5 * atan(B / (A - C));
theta1_degrees = rad2deg(theta1);

% 构造二次形式的矩阵 Q 并求解特征向量
Q = [A, B/2; B/2, C];
[V, D] = eig(Q);
[~, maxIndex] = max(diag(D));
principalAxis = V(:, maxIndex);
theta2 = atan2(principalAxis(2), principalAxis(1));
theta2_degrees = rad2deg(theta2);


