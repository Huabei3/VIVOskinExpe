function [lab_out, p_out] = get_scene_data(picname, all_scenes, ...
        all_ethnicities, nation, all_attributes, attribute, ...
        all_observer_types, VIVO_table, scale_type, wd65, XYZw_LUT)
% GET_SCENE_DATA  从 VIVO_table 提取指定 scene/nation/attribute 的数据
%   并将 lab_values 从 LUT 白点 scale 到白场白点。
%
%   输入：
%     picname           - 场景名（字符串），用 endsWith 匹配 VIVO_table.scene
%     all_scenes        - string 列向量（VIVO_table.scene）
%     all_ethnicities   - string 列向量（VIVO_table.model_ethnicity）
%     nation            - 当前人种字符串
%     all_attributes    - string 列向量（VIVO_table.attribute）
%     attribute         - 当前属性字符串
%     all_observer_types- string 列向量（VIVO_table.observer_type）
%     VIVO_table        - 完整数据表
%     scale_type        - "scaled" 或 "unscaled"
%     wd65              - D65 白点 XYZ，如 [94.811, 100.00, 107.304]
%     XYZw_LUT          - LUT 白点 XYZ（标量或向量，取第2分量）
%
%   输出：
%     lab_out  - N×3 矩阵，scaled Lab 值（scale_type=="scaled"）或原始值
%     p_out    - N×1 向量，opinion scores

lab_out = [];
p_out   = [];

logic_idx = (endsWith(all_scenes, picname)) & ...
            (all_ethnicities == string(nation)) & ...
            (all_attributes == attribute) & ...
            (all_observer_types == "non_model");

filtered_rows = VIVO_table(logic_idx, :);
if size(filtered_rows, 1) == 0
    return;
end

for i_row = 1:size(filtered_rows, 1)
    XYZw_white = filtered_rows.other_info{i_row, 1}.XYZw_white_val;
    xyz_values = lab2xyz2(filtered_rows.lab_values{i_row}, "user", ...
        wd65 ./ wd65(2) .* XYZw_LUT(2));
    filtered_rows.lab_values_scaled{i_row} = xyz2lab(xyz_values, "user", ...
        wd65 ./ wd65(2) .* XYZw_white(2));
end

if strcmp(scale_type, "scaled")
    lab_out = vertcat(filtered_rows.lab_values_scaled{:});
else
    lab_out = vertcat(filtered_rows.lab_values{:});
end
p_out = vertcat(filtered_rows.opinion_scores{:});

end
