function cens_field = build_cens_field(table_data, field_name)
%BUILD_CENS_FIELD Group lab_center by field and build LabCh per group.

T = resolve_table(table_data);
field_name = string(field_name);

if ~ismember(field_name, T.Properties.VariableNames)
    error("Field not found: %s", field_name);
end

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

if field_name == "lab_center"
    cens_field = cell(1, 2);
    cens_field{1, 1} = lab_ch;
    cens_field{1, 2} = "all";
    return;
end

group_var = T.(field_name);
[group_var, lab_ch] = filter_valid(group_var, lab_ch);

if isnumeric(group_var) || islogical(group_var)
    group_key = group_var;
else
    group_key = string(group_var);
end

[group_vals, ~, idx] = unique(group_key, "stable");
n_groups = numel(group_vals);
cens_field = cell(n_groups, 2);
for i = 1:n_groups
    cens_field{i, 1} = lab_ch(idx == i, :);
    cens_field{i, 2} = group_vals(i);
end
end

function T = resolve_table(table_data)
if istable(table_data)
    T = table_data;
    return;
end

if isstruct(table_data)
    fields = fieldnames(table_data);
    for i = 1:numel(fields)
        candidate = table_data.(fields{i});
        if istable(candidate)
            T = candidate;
            return;
        end
    end
end

error("Input table_data must be a table or a struct containing a table.");
end

function lab_center = extract_lab_center(T)
if ismember("lab_center", T.Properties.VariableNames)
    lab_center = T.lab_center;
    if iscell(lab_center)
        lab_center = cell2mat(lab_center);
    end
elseif all(ismember(["lab_center_1","lab_center_2","lab_center_3"], T.Properties.VariableNames))
    lab_center = [T.lab_center_1, T.lab_center_2, T.lab_center_3];
else
    error("lab_center fields not found in table_data.");
end
end

function [group_var, lab_ch] = filter_valid(group_var, lab_ch)
if iscell(group_var) || ischar(group_var)
    group_var = string(group_var);
end

if isnumeric(group_var) || islogical(group_var)
    valid = ~isnan(group_var);
else
    valid = ~ismissing(group_var);
end
valid = valid & ~any(isnan(lab_ch), 2);

group_var = group_var(valid);
lab_ch = lab_ch(valid, :);

if isstring(group_var) || iscellstr(group_var)
    group_var = categorical(group_var);
end
end
