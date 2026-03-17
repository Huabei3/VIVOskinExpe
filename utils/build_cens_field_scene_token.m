function cens_field = build_cens_field_scene_token(T, tokens)
%BUILD_CENS_FIELD_SCENE_TOKEN Group LabCh by scene token matches.

lab_center = extract_lab_center(T);
if size(lab_center, 2) ~= 3
    error("lab_center must be Nx3, got %dx%d", size(lab_center, 1), size(lab_center, 2));
end

L = lab_center(:, 1);
a = lab_center(:, 2);
b = lab_center(:, 3);
C = sqrt(a.^2 + b.^2);
h = mod(atan2d(b, a) + 360, 360);
lab_ch = [L, a, b, C, h];

scene_val = T.scene;
if iscell(scene_val) || ischar(scene_val)
    scene_val = string(scene_val);
elseif iscategorical(scene_val)
    scene_val = string(scene_val);
end

valid = ~any(isnan(lab_ch), 2) & ~ismissing(scene_val);
scene_val = scene_val(valid);
lab_ch = lab_ch(valid, :);

n_tokens = numel(tokens);
cens_field = cell(n_tokens, 2);
for i = 1:n_tokens
    token = tokens(i);
    mask = contains(scene_val, token, "IgnoreCase", true);
    cens_field{i, 1} = lab_ch(mask, :);
    cens_field{i, 2} = token;
end
end
