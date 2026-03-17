% 功能：递归将源文件夹及其子文件夹中所有CSV文件的第C列数字置0
% 使用说明：修改下面的sourceDir和targetColumn变量，然后运行脚本

% 设置源文件夹路径和目标列（列索引从1开始）
sourceDir = 'F:\VIVOskinExpe\reimbursement\expRes';  % 替换为你的源文件夹路径
targetColumn = 3;                          % 替换为你要置0的列数

% 检查源文件夹是否存在
if ~exist(sourceDir, 'dir')
    error('源文件夹不存在: %s', sourceDir);
end

% 递归获取所有CSV文件
csvFiles = dir(fullfile(sourceDir, '**', '*.csv'));

% 检查是否找到CSV文件
if isempty(csvFiles)
    disp('未找到任何CSV文件。');
    return;
end

% 处理每个CSV文件
fileCount = 0;
for i = 1:length(csvFiles)
    % 获取完整文件路径
    filePath = fullfile(csvFiles(i).folder, csvFiles(i).name);
    disp(['正在处理: ', filePath]);
    
    try
        % 读取CSV文件，使用自动检测格式
        data = readmatrix(filePath);
        
        % 检查目标列是否存在
        if targetColumn > size(data, 2)
            warning('文件 %s 没有第%d列，已跳过', filePath, targetColumn);
            continue;
        end
        
        % 将目标列的所有数值置0
        data(:, targetColumn) = 0;
        
        % 将修改后的数据写回CSV文件
        writematrix(data, filePath);
        
        fileCount = fileCount + 1;
    catch err
        warning('处理文件 %s 时出错: %s', filePath, err.message);
    end
end

disp(['处理完成。成功修改了 ', num2str(fileCount), ' 个CSV文件。']);
