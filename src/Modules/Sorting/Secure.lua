---@type string, Addon
local _, addon = ...
local wow = addon.WoW.Api
local M = addon.Modules.Sorting.Secure

function M:Init()
    M.InCombat:Init()
end

---@param provider FrameProvider?
---@return boolean
function M:TrySort(provider)
    -- if we're in combat, the secure sorting will trigger itself
    return not wow.InCombatLockdown() and M.NoCombat:TrySort(provider)
end

---@return boolean
function M:TrySpace()
    M.InCombat:TrySpace()
    return M.NoCombat:TrySpace()
end
