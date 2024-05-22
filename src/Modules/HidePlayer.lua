---@type string, Addon
local _, addon = ...
local wow = addon.WoW.Api
local fsCompare = addon.Collections.Comparer
local fsConfig = addon.Configuration
local fsProviders = addon.Providers
local fsFrame = addon.WoW.Frame
local fsEnumerable = addon.Collections.Enumerable
---@class HidePlayerModule: IInitialise
local M = {}
addon.Modules.HidePlayer = M
local previousSetting = true

local function ShowHide(show)
    local blizzard = fsProviders.Blizzard
    local party = fsFrame:GetFrames(blizzard, fsFrame.ContainerType.Party, false)
    local raid = fsFrame:GetFrames(blizzard, fsFrame.ContainerType.Raid, false)
    local all = fsEnumerable:From(party):Concat(raid):ToTable()

    -- we need to update all frames as units are not fixed to a frame
    -- so the player unit may have moved from frame1 to frame3 for example
    for _, frame in ipairs(all) do
        local unit = fsFrame:GetFrameUnit(frame)

        assert(unit ~= nil)

        local isPlayer = wow.UnitIsUnit(unit, "player")

        if isPlayer then
            wow.RegisterAttributeDriver(frame, "state-visibility", show and "show" or "hide")
        else
            wow.UnregisterAttributeDriver(frame, "state-visibility")
        end
    end
end

function M:Run()
    assert(not wow.InCombatLockdown())

    local blizzard = fsProviders.Blizzard

    if not blizzard:Enabled() then
        return
    end

    local enabled, mode, _, _ = fsCompare:FriendlySortMode()
    if not enabled then
        return
    end

    local show = mode ~= fsConfig.PlayerSortMode.Hidden

    -- no point in attempting it again, so save some cpu cycles
    if previousSetting == show then
        return
    end

    ShowHide(show)
    previousSetting = show
end

function M:Init()
    -- reset state
    previousSetting = true
end
