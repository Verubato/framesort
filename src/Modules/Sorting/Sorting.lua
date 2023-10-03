---@type string, Addon
local _, addon = ...
local wow = addon.WoW.Api
local fsScheduler = addon.Scheduling.Scheduler
local fsCompare = addon.Collections.Comparer
local fsLog = addon.Logging.Log
local fsConfig = addon.Configuration
local fsProviders = addon.Providers
local callbacks = {}
local M = addon.Modules.Sorting

local function OnProviderRequiresSort(provider)
    M:TrySort(provider)
end

---Calls the post sorting callbacks.
function M:InvokeCallbacks()
    for _, callback in ipairs(callbacks) do
        pcall(callback)
    end
end

---Register a callback to invoke after sorting has been performed.
---@param callback function
function M:RegisterPostSortCallback(callback)
    callbacks[#callbacks + 1] = callback
end

---Attempts to sort all frames.
---@return boolean sorted true if sorted, otherwise false.
---@param provider FrameProvider? optionally specify the provider to sort, otherwise sorts all providers.
function M:TrySort(provider)
    local friendlyEnabled, _, _, _ = fsCompare:FriendlySortMode()
    local enemyEnabled, _, _ = fsCompare:EnemySortMode()

    if not friendlyEnabled and not enemyEnabled then
        return false
    end

    if wow.IsRetail() and wow.EditModeManagerFrame.editModeActive then
        fsLog:Debug("Not sorting while edit mode active.")
        return false
    end

    if wow.InCombatLockdown() then
        -- can't make changes during combat
        fsScheduler:RunWhenCombatEnds(function()
            M:TrySort(provider)
        end, "TrySort" .. (provider and provider:Name() or ""))

        return false
    end

    local sorted = false

    if addon.DB.Options.SortingMethod == fsConfig.SortingMethod.Traditional then
        sorted = M.Traditional:TrySort()
    elseif addon.DB.Options.SortingMethod == fsConfig.SortingMethod.Secure then
        sorted = M.Secure:TrySort(provider)
    end

    if sorted then
        fsLog:Debug("Sorted frames.")
        M:InvokeCallbacks()
    end

    return sorted
end

---Initialises the module.
function M:Init()
    if addon.DB.Options.SortingMethod == fsConfig.SortingMethod.Secure then
        M.Secure:Init()
    end

    if #callbacks > 0 then
        callbacks = {}
    end

    for _, provider in ipairs(fsProviders.All) do
        provider:RegisterCallback(OnProviderRequiresSort)
    end
end
