function lab_center = extract_lab_center(T)
%EXTRACT_LAB_CENTER Extract lab_center from table.

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
