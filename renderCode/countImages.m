clear;
%%
folderPath ='Z:\homes\Peggy\oppoSkinExperi\picked40\iphone\cropped\renderedLUTchoose\renderedReCen07\drawable_2perScene';
% folderPath = 'Z:\homes\Peggy\oppoSkinExperi\picked40\Hassel\downSampled1\cropped\renderedAdd\renderedAdd07';
% 获取所有jpg文件
jpgFiles = dir(fullfile(folderPath, '*.JPG'));

% 初始化一个空的容器
fileGroups = containers.Map('KeyType', 'char', 'ValueType', 'any');

% 遍历每个文件
for i = 1:length(jpgFiles)
    % 获取文件名
    [~, fileName, ~] = fileparts(jpgFiles(i).name);

    % 使用正则表达式提取第二个下划线前的内容
    tokens = regexp(fileName, '^[^_]*', 'match');
    % tokens = regexp(fileName, '^([^_]+_[^_]+)_', 'tokens', 'once');
    if ~isempty(tokens)
        key = tokens{1};
        % 将文件路径添加到对应的组
        if isKey(fileGroups, key)
            fileGroups(key) = [fileGroups(key); {fullfile(folderPath, jpgFiles(i).name)}];
        else
            fileGroups(key) = {fullfile(folderPath, jpgFiles(i).name)};
        end
    end
end

% 转换为cell矩阵
groupKeys = keys(fileGroups);
cellMatrix = cell(length(groupKeys), 2);
for i = 1:length(groupKeys)
    cellMatrix{i, 1} = fileGroups(groupKeys{i});
    cellMatrix{i, 2} = groupKeys{i};
end
disp("done");


