% 检查 .mat 文件中的参数
close all; clc; clear;

output_mat_folder = fullfile("AnalyseResults_p\efit_p\unscaled\model_fullpara", ...
    "d65\new\i\non_model\1_drop");

nations = {"AS", "CA", "SA", "AF", "all"};

for i_n = 1:length(nations)
    nation = nations{i_n};
    mat_file = fullfile(output_mat_folder, sprintf("%s_n_drop1.mat", nation));
    
    fprintf('\n===== 检查 .mat 文件: %s =====\n', nation);
    
    if exist(mat_file, 'file')
        try
            data = load(mat_file);
            fields = fieldnames(data);
            
            fprintf('  文件包含 %d 个 subject 字段:\n', length(fields));
            
            % 检查第一个 subject 的第一个 attribute
            if length(fields) > 0
                first_subj = fields{1};
                fprintf('  第一个 subject: %s\n', first_subj);
                
                subj_data = data.(first_subj);
                attr_fields = fieldnames(subj_data);
                
                if length(attr_fields) > 0
                    first_attr = attr_fields{1};
                    fprintf('  第一个 attribute: %s\n', first_attr);
                    
                    params = subj_data.(first_attr);
                    
                    fprintf('    参数结构:\n');
                    param_fields = fieldnames(params);
                    for f = 1:length(param_fields)
                        field_name = param_fields{f};
                        value = params.(field_name);
                        if isnumeric(value)
                            if length(value) == 1
                                fprintf('      %s = %.4f', field_name, value);
                                if isnan(value)
                                    fprintf(' ← NaN!\n');
                                else
                                    fprintf('\n');
                                end
                            else
                                fprintf('      %s = [%s]', field_name, mat2str(value, 4));
                                if any(isnan(value))
                                    fprintf(' ← 包含 NaN!\n');
                                else
                                    fprintf('\n');
                                end
                            end
                        end
                    end
                else
                    fprintf('  没有 attribute 字段\n');
                end
            else
                fprintf('  没有 subject 字段\n');
            end
            
            % 统计 NaN 情况
            fprintf('\n  统计所有 subject 和 attribute 的 NaN 情况:\n');
            total_params = 0;
            nan_params = 0;
            
            for s = 1:length(fields)
                subj = fields{s};
                subj_data = data.(subj);
                attr_fields = fieldnames(subj_data);
                
                for a = 1:length(attr_fields)
                    attr = attr_fields{a};
                    params = subj_data.(attr);
                    
                    if isfield(params, 'a_C_L')
                        a_C_L = params.a_C_L;
                        if any(isnan(a_C_L))
                            nan_params = nan_params + 1;
                            fprintf('    %s.%s: a_C_L 包含 NaN\n', subj, attr);
                        end
                        total_params = total_params + 1;
                    end
                end
            end
            
            if total_params > 0
                fprintf('  a_C_L 包含 NaN 的比例: %d/%d (%.1f%%)\n', ...
                    nan_params, total_params, nan_params/total_params*100);
            end
            
        catch ME
            fprintf('  读取失败: %s\n', ME.message);
        end
    else
        fprintf('  文件不存在: %s\n', mat_file);
    end
end