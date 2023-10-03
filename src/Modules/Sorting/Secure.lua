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
    if wow.InCombatLockdown() then
        return false
    end

    if M.NoCombat:TrySort(provider) then
        M.InCombat:RefreshUnits()
        return true
    end

    return false
end

---@return boolean
function M:TrySpace()
    M.InCombat:RefreshSpacing()
    return M.NoCombat:TrySpace()
end
