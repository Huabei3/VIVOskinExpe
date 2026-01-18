% Define the folder path containing the JPEG files.
% Make sure to replace 'yourFolderPathHere' with the actual path.
folderPath = 'D:\oppoSkinExperi\picked40\iphone';

% Get the folder's name from the folderPath
[~, folderName, ~] = fileparts(folderPath);

% Get a list of all JPEG files in the folder.
% This looks for files with the .jpg extension.
jpgFiles = dir(fullfile(folderPath, '*.jpg'));

% Loop through each JPEG file in the folder.
for k = 1:length(jpgFiles)
    % Original file name and path
    originalFileName = jpgFiles(k).name;
    originalFilePath = fullfile(folderPath, originalFileName);
    
    % New file name and path
    % The new file name is folderName followed by the number k
    newFileName = [originalFileName(1:end-5),'0',originalFileName(end-4:end)];
    newFilePath = fullfile(folderPath, newFileName);
    
    % Rename the file
    movefile(originalFilePath, newFilePath);
    

end

% Indicate completion
disp('All files have been renamed.');