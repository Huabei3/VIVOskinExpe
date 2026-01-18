clear;
%%
files = dir('Z:\homes\Peggy\oppoSkinExperi\ExperimentResult\loadFiles\cropped\*.jpg'); 
aveSkin_inLab=load(['Z:\homes\Peggy\oppoSkinExperi\picked40\Hassel\' ...
    'downSampled1\cropped\aveSkinByHand\autoNhand.mat']);
aveSkin_inLab=aveSkin_inLab.average_lab_all(:,5:7);
aveSkin_scene=load(['Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\cropped\' ...
    'aveSkinByHand\autoNhand.mat']);
aveSkin_scene=aveSkin_scene.average_lab_all(:,5:7);
aveSkin=[aveSkin_inLab(1:10,:);aveSkin_scene(1:10,:);
    aveSkin_inLab(11:end,:);aveSkin_scene(11:end,:)];

filename = 'Z:\homes\Peggy\oppoSkinExperi\points48.xlsx';                               %文件名
num_points = readmatrix(filename); 
num_center = num_points(53,:); 
num_points(50:53,:)=[];
save_folder=['Z:\homes\Peggy\oppoSkinExperi\ExperimentResult\loadFiles\' ...
    'cropped\setPointsUseMask07'];

cellMatrix = cell(numel(files), 2);

for i = 1:numel(files) 
    
    for i_points=1:length(num_points)
        delta_Lab(i_points,:)=num_points(i_points,:)-num_center;
        centers(i_points,:)=0.7*delta_Lab(i_points,:)+aveSkin(i,:);
    end

    cellMatrix{i, 1} = centers;
    cellMatrix{i, 2} = files(i).name(1:end-4);
    
end
    save(fullfile(save_folder,"group_Lab.mat"), ...
    'cellMatrix');