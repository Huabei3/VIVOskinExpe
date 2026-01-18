close all; 
clc;       
clear;     
%%
files = dir('Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\cropped\*.jpg');  
dir_mask=dir("Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\cropped\mask\*.jpg");

%载入渲染中心
average_file='Z:\homes\Peggy\oppoSkinExperi\picked40\Hassel\downSampled1\cropped\aveSkinByHand\autoNhand.mat';
average=load(average_file);
average=average.average_lab_all(:,5:7);
average_inLab=average;

average_file='Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\cropped\aveSkinByHand\autoNhand.mat';
average=load(average_file);
average=average.average_lab_all(:,5:7);


%载入拟合中心
input_folder = 'Z:\homes\Peggy\oppoSkinExperi\ExperimentResult\analyseFile\inLab';
load(fullfile(input_folder, "ellipPara", "fitRes_level.mat"));
fit_lab_inLab = par_all(:,5:7);

par_All=[];
input_folder = 'Z:\homes\Peggy\oppoSkinExperi\ExperimentResult\analyseFile\indoorAdd';
load(fullfile(input_folder, "ellipPara", "fitRes_level.mat"));
par_All = [par_All; par_all];
input_folder = 'Z:\homes\Peggy\oppoSkinExperi\ExperimentResult\analyseFile\nightAdd';
load(fullfile(input_folder, "ellipPara", "fitRes_level.mat"));
par_All = [par_All; par_all];
input_folder = 'Z:\homes\Peggy\oppoSkinExperi\ExperimentResult\analyseFile\outdoorAdd';
load(fullfile(input_folder, "ellipPara", "fitRes_level.mat"));
par_All = [par_All; par_all];
input_folder = 'Z:\homes\Peggy\oppoSkinExperi\ExperimentResult\analyseFile\sunsetAdd';
load(fullfile(input_folder, "ellipPara", "fitRes_level.mat"));
par_All = [par_All; par_all];
fit_lab=par_All(:,5:7);


% [de_inLab,~,~,~] = cielabde(average_inLab,fit_lab_inLab);
% [de00_inLab,de00c_inLab] = deltaE2000(average_inLab,fit_lab_inLab);

% [de,~,~,~] = cielabde(average,fit_lab);
% [de00,de00c] = deltaE2000(average,fit_lab);


[de00_inLab,~] = deltaE2000(average_inLab,fit_lab_inLab);
[de00,~] = deltaE2000(average,fit_lab);
de00_inLab=de00_inLab';
de00=de00';