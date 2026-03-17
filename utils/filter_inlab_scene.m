function T_out = filter_inlab_scene(T)
%FILTER_INLAB_SCENE Keep only rows whose scene starts with "inLab".

scene_val = T.scene;
if iscell(scene_val) || ischar(scene_val)
    scene_val = string(scene_val);
elseif iscategorical(scene_val)
    scene_val = string(scene_val);
end

mask = startsWith(scene_val, "inLab", "IgnoreCase", true);
T_out = T(mask, :);
end
