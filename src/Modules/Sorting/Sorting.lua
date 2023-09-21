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

---Calls the post sorting callbacks.
local function InvokeCallbacks()
    for _, callback in pairs(callbacks) do
        pcall(callback)
    end
end

local function OnProviderRequiresSort(provider)
    M:TrySort(provider)
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

    -- if wow.IsRetail() and wow.EditModeManagerFrame.editModeActive then
    --     fsLog:Debug("Not sorting while edit mode active.")
    --     return false
    -- end

    if wow.InCombatLockdown() then
        -- can't make changes during combat
        fsScheduler:RunWhenCombatEnds(function()
            M:TrySort(provider)
        end, "Sort" .. (provider and provider:Name() or ""))

        return false
    end

    local sorted = false

    if addon.DB.Options.SortingMethod == fsConfig.SortingMethod.Traditional then
        sorted = M.Traditional:TrySort()

        if sorted then
            InvokeCallbacks()
        end

        return sorted
    end

    local providers = provider and { provider } or fsProviders:Enabled()

    for _, p in ipairs(providers) do
        local providerSorted = M.Secure:TrySort(p)

        sorted = sorted or providerSorted
    end

    if sorted then
        fsLog:Debug("Sorted frames.")
        InvokeCallbacks()
    end

    return sorted
end

function M:Init()
    if addon.DB.Options.SortingMethod == fsConfig.SortingMethod.Secure then
        M.Secure:Init()
    end

    if #callbacks > 0 then
        callbacks = {}
    end

    for _, provider in ipairs(fsProviders:Enabled()) do
        provider:RegisterCallback(function() OnProviderRequiresSort(provider) end)
    end
end
