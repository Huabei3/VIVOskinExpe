% 定义源文件路径和目标目录
dir_all=dir("D:\oppoSkinExperi\哈苏jpg\已裁剪\result\setPoints*.mat");
for i_all=1:length(dir_all)
    load([dir_all(i_all).folder,'\',dir_all(i_all).name]);
    sourceFile_folder=dir_all(i_all).folder;
    sourceFile_name=['Rendered_',dir_all(i_all).name(13:end-4),...
        '[',num2str(center0(1)),',',num2str(center0(2)),',',num2str(center0(3)),'].jpg'];
    sourceFile = [dir_all(i_all).folder,'\',sourceFile_name]; % 源文件名，假设它位于当前工作目录中
    targetDir = 'D:\oppoSkinExperi\哈苏jpg\已裁剪\result\原图'; % 目标目录的路径
    
    % 构建目标文件路径
    targetFile = fullfile(targetDir, sourceFile_name);
    
    % 移动文件
    moveResult = movefile(sourceFile, targetFile);
    
    % 检查操作是否成功
    if moveResult
        disp('文件成功移动。');
    else
        disp('文件移动失败。');
    end
end
