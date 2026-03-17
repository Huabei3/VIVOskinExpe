function T = resolve_table(table_data)
%RESOLVE_TABLE Extract a table from a table or struct wrapper.

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

error("table_data must be a table or a struct containing a table.");
end
