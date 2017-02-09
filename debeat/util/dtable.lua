local M = {}

function M.copy_deep(orig)
	local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[M.deep_copy(orig_key)] = M.deep_copy(orig_value)
        end
        setmetatable(copy, M.deep_copy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function M.merge(t1, t2)
	for k,v in pairs(t2) do
		t1[k] = t1[k] or v
	end
	return t1
end

return M