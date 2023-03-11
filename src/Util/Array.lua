local _, addon = ...
local array = {}
addon.Array = array

---Compares the two arrays and returns true if their items are equivalent, otherwise false
---@param left table<any>
---@param right table<any>
---@return boolean
function array:ArrayEquals(left, right)
    if #left ~= #right then return false end

    for i = 0, #left do
        if left[i] ~= right[i] then return false end
    end

    return true
end
