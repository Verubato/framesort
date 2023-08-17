local _, addon = ...
---@type WoW
local wow = addon.WoW
local fsScheduler = addon.Scheduler
local fsCompare = addon.Compare
local fsLog = addon.Log
---@class PlayerVisibilityController
local M = {}
addon.HidePlayer = M

local function UpdatePlayer(player, mode)
    if player:IsVisible() and mode == addon.PlayerSortMode.Hidden then
        wow.RegisterAttributeDriver(player, "state-visibility", "hide")
    elseif not player:IsVisible() and mode ~= addon.PlayerSortMode.Hidden then
        wow.RegisterAttributeDriver(player, "state-visibility", "show")
    end
end

local function Run()
    local blizzard = addon.Frame.Providers.Blizzard

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

---Initialises the player show/hide module.
function addon:InitPlayerHiding()
    local blizzard = addon.Frame.Providers.Blizzard
    blizzard:RegisterCallback(Run)
end
