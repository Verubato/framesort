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
        local hasAttribute = frame:GetAttribute("framesort-state-visibility") ~= nil

        if show and hasAttribute then
            -- the frame may have moved to a different unit or the user wants the player raid frame to be shown again
            wow.UnregisterAttributeDriver(frame, "state-visibility")
            frame:SetAttribute("framesort-state-visibility", nil)
            frame:Show()
        end

        if isPlayer and not show then
            -- user has opted to hide the player unit frame
            wow.RegisterAttributeDriver(frame, "state-visibility", "hide")
            frame:SetAttribute("framesort-state-visibility", "hide")
        end
    end
end

function M:Run()
    assert(not wow.InCombatLockdown())

    local blizzard = fsProviders.Blizzard
    local enabled, mode, _, _ = fsCompare:FriendlySortMode()

    if not enabled or not blizzard:Enabled() then
        return
    end

    local show = mode ~= fsConfig.PlayerSortMode.Hidden
    ShowHide(show)
end

function M:Init() end
