---@type string, Addon
local _, addon = ...
---@class LuaEx
local M = {}

addon.Collections.LuaEx = M

---Returns the result of a property chain e.g. Something.else.a.b.c
---Otherwise nil if any of the fields are nil
---@param table table root of the property chain
---@param chain table<string>
function M:SafeGet(table, chain)
    local next = table

    for _, k in pairs(chain) do
        next = next[k]

        if next == nil then
            return nil
        end
    end

    return next
end
