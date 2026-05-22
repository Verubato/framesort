---@type string, Addon
local _, addon = ...
local wow = addon.WoW.Api
local fsCompare = addon.Modules.Sorting.Comparer
local fsConfig = addon.Configuration
local fsProviders = addon.Providers
local fsFrame = addon.WoW.Frame
local fsEnumerable = addon.Collections.Enumerable
local fsLog = addon.Logging.Log
local events = addon.WoW.Events
---@class HidePlayerModule: IInitialise, IProcessEvents
local M = {}
addon.Modules.HidePlayer = M

-- whether the player frame should currently be kept hidden
local hidePlayerActive = false
-- set when a re-hide was requested during combat and deferred until it ends
local pendingHide = false
local hooked = false

local function ShowHide(show)
    local blizzard = fsProviders.Blizzard
    local party = fsFrame:GetFrames(blizzard, fsFrame.ContainerType.Party, false)
    local raid = fsFrame:GetFrames(blizzard, fsFrame.ContainerType.Raid, false)
    local all = fsEnumerable:From(party):Concat(raid):ToTable()

    -- we need to update all frames as units are not fixed to a frame
    -- so the player unit may have moved from frame1 to frame3 for example
    for _, frame in ipairs(all) do
        local unit = fsFrame:GetFrameUnit(frame)

        if unit then
            if show and wow.UnitExists(unit) and not frame:IsVisible() then
                -- the frame may have moved to a different unit or the user wants the player raid frame to be shown again
                wow.RegisterUnitWatch(frame)
                frame:Show()
            elseif not show and wow.UnitIsUnit(unit, "player") then
                -- user has opted to hide the player unit frame
                wow.UnregisterUnitWatch(frame)
                frame:Hide()
            end
        end
    end
end

-- Blizzard re-shows frames via CompactUnitFrame_UpdateVisible (vehicle, pet, level,
-- encounter end, mind control); re-hide to keep the player hidden, deferring in combat.
local function OnUpdateVisible(frame)
    if not hidePlayerActive then
        return
    end

    if not frame or not frame.unit or not frame:IsShown() then
        return
    end

    if not wow.UnitIsUnit(frame.unit, "player") then
        return
    end

    if wow.InCombatLockdown() then
        pendingHide = true
        return
    end

    wow.UnregisterUnitWatch(frame)
    frame:Hide()
end

local function OnCombatEnd()
    if not pendingHide then
        return
    end

    pendingHide = false

    if hidePlayerActive then
        ShowHide(false)
    end
end

local function EnsureHooks()
    if hooked then
        return
    end

    hooked = true

    if CompactUnitFrame_UpdateVisible then
        wow.hooksecurefunc("CompactUnitFrame_UpdateVisible", OnUpdateVisible)
    end
end

function M:ProcessEvent(event)
    if event == events.PLAYER_REGEN_ENABLED then
        OnCombatEnd()
    end
end

function M:Run()
    if wow.InCombatLockdown() then
        fsLog:Error("Cannot run hide player module during combat.")
        return
    end

    local blizzard = fsProviders.Blizzard
    local enabled, mode, _, _ = fsCompare:FriendlySortMode()

    if not enabled or not blizzard:Enabled() then
        hidePlayerActive = false
        return
    end

    local show = mode ~= fsConfig.PlayerSortMode.Hidden
    hidePlayerActive = not show
    ShowHide(show)
end

function M:Init()
    EnsureHooks()
    fsLog:Debug("Initialised the hide player module.")
end
