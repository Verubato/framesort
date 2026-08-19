---@type string, Addon
local _, addon = ...
local wow = addon.WoW.Api
local events = addon.WoW.Events
local wowEx = addon.WoW.WowEx
local capabilities = addon.WoW.Capabilities
local fsSortedUnits = addon.Modules.Sorting.SortedUnits
local fsRunner = addon.Modules
local fsProviders = addon.Providers
local fsInspector = addon.Modules.Inspector
local fsAutoLeader = addon.Modules.AutoLeader
local fsHidePlayer = addon.Modules.HidePlayer
local fsScheduler = addon.Scheduling.Scheduler
local fsLog = addon.Logging.Log
local eventsFrame = nil

-- the reason for this class is so we can guarantee the order events are processed in
---@class EventDispatcher : IInitialise
local M = {}
addon.Modules.EventDispatcher = M

-- Events that can only move frames which exist in an arena. Every provider answers the opponent
-- events by asking for a sort, and battlegrounds fire them in bursts of one per opponent slot.
--
-- A pet is the same story when its owner is nobody the group frames show: blizzard's raid
-- container leaves the frames where they are, so there is nothing to re-sort.
local function OnlyMattersInArena(event, ...)
    if event == events.ARENA_OPPONENT_UPDATE or event == events.ARENA_PREP_OPPONENT_SPECIALIZATIONS then
        return true
    end

    if event ~= events.UNIT_PET then
        return false
    end

    local owner = select(1, ...)

    -- an owner we can't read is treated as ours, so a sort is never skipped on a guess
    if type(owner) ~= "string" then
        return false
    end

    -- Copied from CompactRaidFrameContainerMixin:OnEvent in Blizzard_CompactRaidFrameContainer.lua:
    --     if unit == "player" or strsub(unit, 1, 4) == "raid" or strsub(unit, 1, 5) == "party" then
    -- Their prefixes, so we never skip a pet they act on. Asking whether the owner is friendly
    -- would be wrong: mind control makes a raid member hostile without moving their frame.
    return not (owner == "player" or string.sub(owner, 1, 4) == "raid" or string.sub(owner, 1, 5) == "party")
end

local function OnEvent(_, event, ...)
    if fsLog:IsEnabled() then
        local args = { ... }

        if #args > 0 then
            for i = 1, #args do
                args[i] = tostring(args[i])
            end

            local argsString = table.concat(args, ", ")
            fsLog:Debug("Event: %s %s.", event, argsString)
        else
            fsLog:Debug("Event: %s.", event)
        end
    end

    -- prioritise the scheduler
    fsScheduler:ProcessEvent(event)

    -- then pass to our sorted units cache in case it needs to be invalidated
    fsSortedUnits:ProcessEvent(event, ...)

    -- now pass to providers, unless they could only be interested in an arena we're not in
    if not OnlyMattersInArena(event, ...) or wowEx.IsInstanceArena() then
        local providers = fsProviders:EnabledNotSelfManaged()

        for _, provider in ipairs(providers) do
            if provider.ProcessEvent then
                provider:ProcessEvent(event, ...)
            end
        end
    end

    -- now the inspector
    fsInspector:ProcessEvent(event, ...)

    -- now the auto leader
    fsAutoLeader:ProcessEvent(event)

    -- now the hide player module
    fsHidePlayer:ProcessEvent(event)

    -- lastly pass to runner
    fsRunner:ProcessEvent(event, ...)
end

function M:Init()
    eventsFrame = wow.CreateFrame("Frame")
    eventsFrame:SetScript("OnEvent", OnEvent)

    -- loading screen
    eventsFrame:RegisterEvent(events.PLAYER_ENTERING_WORLD)

    -- friendly unit change events
    eventsFrame:RegisterEvent(events.GROUP_ROSTER_UPDATE)
    eventsFrame:RegisterEvent(events.PLAYER_ROLES_ASSIGNED)

    if capabilities.HasSpecializations() then
        eventsFrame:RegisterEvent(events.PLAYER_SPECIALIZATION_CHANGED)
    end

    -- arena unit change events
    eventsFrame:RegisterEvent(events.ARENA_OPPONENT_UPDATE)

    if capabilities.HasSpecializations() and capabilities.HasEnemySpecSupport() then
        eventsFrame:RegisterEvent(events.ARENA_PREP_OPPONENT_SPECIALIZATIONS)
    end

    -- friendly/enemy pet unit events
    eventsFrame:RegisterEvent(events.UNIT_PET)

    -- cvars changed
    eventsFrame:RegisterEvent(events.CVAR_UPDATE)

    -- combat events
    eventsFrame:RegisterEvent(events.PLAYER_REGEN_ENABLED)
    eventsFrame:RegisterEvent(events.PLAYER_REGEN_DISABLED)

    -- arena events
    if capabilities.HasPvPMatchState() then
        eventsFrame:RegisterEvent(events.PVP_MATCH_STATE_CHANGED)
    end

    -- inspection
    if fsInspector:CanRun() then
        eventsFrame:RegisterEvent(events.INSPECT_READY)
    end
end
