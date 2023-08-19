---@type string, Addon
local _, addon = ...
local wow = addon.WoW.Api
local fsScheduler = addon.Scheduling.Scheduler
local fsCompare = addon.Collections.Comparer
local fsConfig = addon.Configuration
local fsProviders = addon.Providers
local fsLog = addon.Logging.Log
---@class HidePlayerModule: Initialise
local M = {}
addon.Modules.HidePlayer = M

local function UpdatePlayer(player, mode)
    if player:IsVisible() and mode == fsConfig.PlayerSortMode.Hidden then
        wow.RegisterAttributeDriver(player, "state-visibility", "hide")
    elseif not player:IsVisible() and mode ~= fsConfig.PlayerSortMode.Hidden then
        wow.RegisterAttributeDriver(player, "state-visibility", "show")
    end
end

local function Run()
    local blizzard = fsProviders.Blizzard

    if not blizzard:Enabled() then
        return
    end

    local enabled, mode, _, _ = fsCompare:FriendlySortMode()
    if not enabled then
        return
    end

    if wow.InCombatLockdown() then
        fsScheduler:RunWhenCombatEnds(Run)
        return
    end

    local frames = blizzard:PlayerRaidFrames()

    if #frames == 0 and wow.IsInGroup() then
        fsLog:Warning("Couldn't find player raid frame.")
        return
    end

    for _, player in ipairs(frames) do
        UpdatePlayer(player, mode)
    end
end

---Shows or hides the player (depending on settings).
function M:ShowHidePlayer()
    Run()
end

function M:Init()
    local blizzard = fsProviders.Blizzard
    blizzard:RegisterCallback(Run)
end
