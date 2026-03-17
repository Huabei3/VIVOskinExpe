function v = parse_numeric(x)
%PARSE_NUMERIC Convert common types to numeric vector.

if isnumeric(x)
    v = x;
    return;
end
if iscategorical(x)
    x = string(x);
end

if iscell(x)
    if all(cellfun(@(c) isnumeric(c) && isscalar(c), x))
        v = cell2mat(x);
        return;
    end
    x = string(x);
end

if ischar(x) || isstring(x)
    v = str2double(x);
else
    v = double(x);
end
end
