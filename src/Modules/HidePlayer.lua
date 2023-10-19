---@type string, Addon
local _, addon = ...
local wow = addon.WoW.Api
local fsScheduler = addon.Scheduling.Scheduler
local fsCompare = addon.Collections.Comparer
local fsConfig = addon.Configuration
local fsProviders = addon.Providers
local fsUnit = addon.WoW.Unit
local fsFrame = addon.WoW.Frame
local fsEnumerable = addon.Collections.Enumerable
local fsLog = addon.Logging.Log
---@class HidePlayerModule: IInitialise
local M = {}
addon.Modules.HidePlayer = M

local function UpdatePlayer(player, mode)
    if player:IsVisible() and mode == fsConfig.PlayerSortMode.Hidden then
        wow.RegisterAttributeDriver(player, "state-visibility", "hide")
    elseif not player:IsVisible() and mode ~= fsConfig.PlayerSortMode.Hidden then
        wow.RegisterAttributeDriver(player, "state-visibility", "show")
    end
end

local function PlayerRaidFrames()
    local blizzard = fsProviders.Blizzard
    local party = fsFrame:PartyFrames(blizzard)
    local raid = fsFrame:RaidFrames(blizzard)

    return fsEnumerable
        :From(party)
        :Concat(raid)
        :Where(function(frame)
            local unit = frame.unit
            -- a player can have more than one frame if they occupy a vehicle
            -- as both the player and vehicle pet frame are shown
            return unit and (unit == "player" or wow.UnitIsUnit(unit, "player")) and not fsUnit:IsPet(unit)
        end)
        :ToTable()
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
        fsScheduler:RunWhenCombatEnds(Run, "HidePlayer")
        return
    end

    local frames = PlayerRaidFrames()

    if #frames == 0 and wow.IsInGroup() then
        fsLog:Warning("Couldn't find player raid frame.")
        return
    end

    for _, player in ipairs(frames) do
        UpdatePlayer(player, mode)
    end
end

---Shows or hides the player (depending on settings).
function M:Run()
    fsScheduler:RunWhenCombatEnds(Run, "UpdateTargets")
end

function M:Init()
    local blizzard = fsProviders.Blizzard
    blizzard:RegisterRequestSortCallback(Run)
end
