---@type string, Addon
local _, addon = ...
local wow = addon.WoW.Api
local M = addon.Modules.Sorting.Secure

---Initialises the module
function M:Init()
    M.InCombat:Init()
end

---Attempts to sort frames.
---@param provider FrameProvider?
---@return boolean sorted
function M:TrySort(provider)
    -- if we're in combat, the secure sorting will trigger itself
    return not wow.InCombatLockdown() and M.NoCombat:TrySort(provider)
end
