dir_preNori=dir("E:\documents\MATLAB\SkinColorPreferenceScale\level_data\preNori*.mat");
n_preNori=length(dir_preNori);
for i_preNori=1:n_preNori
    A{i_preNori}=load(strcat(dir_preNori(i_preNori).folder,'\',dir_preNori(i_preNori).name));
end