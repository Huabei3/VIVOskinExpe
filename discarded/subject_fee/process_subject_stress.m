function process_subject_stress(dir_ind_csv, output_folder_ind)
% process_subject_stress 对指定文件夹中的csv文件进行处理，计算STRESS，并保存为.mat文件。
% dir_ind_csv: 包含csv文件信息的结构体，由dir函数生成。
% output_folder_ind: 输出.mat文件的目标文件夹路径。

% 获取所有文件的大小
file_sizes = [dir_ind_csv.bytes];

% 计算文件大小的众数
file_sizes=round(file_sizes./100).*100;
file_mode = mode(file_sizes);

% 设定阈值（10%）
threshold = 0.20 * file_mode;

% 找到并移除大小与众数相差超过10%的文件
% abs() 函数计算差的绝对值
% ismember() 函数用于查找哪些文件大小在保留列表中
valid_files_logic = abs(file_sizes - file_mode) <= threshold;
dir_ind_csv = dir_ind_csv(valid_files_logic);

% 检查是否有文件需要处理
if isempty(dir_ind_csv)
    disp('No valid CSV files to process after filtering.');
    return;
end

% 确保输出文件夹存在
if ~exist(output_folder_ind, 'dir')
    mkdir(output_folder_ind);
end

% 调用您的 process_data_stress 函数进行处理
% 假设 process_data_stress 已经存在于 utils 文件夹中
process_data_stress(dir_ind_csv, output_folder_ind);
end