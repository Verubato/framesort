---@type string, Addon
local _, addon = ...
local fsProviders = addon.Providers
local fsScheduler = addon.Scheduling.Scheduler
local fsLog = addon.Logging.Log
local wow = addon.WoW.Api
local events = wow.Events
local M = addon.Modules
local timerFrame = nil
local eventFrame = nil
local pvpTimerType = 1

local function Run(provider)
    M:Run(provider)
end

local function OnProviderRequiresSort(provider)
    fsLog:Debug(string.format("Provider %s requested sort.", provider:Name()))
    Run(provider)
end

local function OnEditModeExited()
    if fsProviders.Blizzard:Enabled() then
        Run(fsProviders.Blizzard)
    end
end

local function OnTimer(_, _, timerType, timeSeconds)
    if timerType ~= pvpTimerType then return end

    -- TODO: there seems to be a bug in solo shuffle where enemy macros/targeting isn't updated
    -- unsure the specifics yet, but I have a feeling it's after round 1 that it occurs
    -- as a workaround, run 1 second after the gates open
    -- bug still happens even with ARENA_OPPONENT_UPDATE event registered
    fsScheduler:RunAfter(timeSeconds + 1, Run)
end

local function OnEvent(_, event)
    fsLog:Debug("Event: " .. event)
    Run()
end

function M:Run(provider)
    fsScheduler:RunWhenCombatEnds(function()
        -- run sorting first as it affects everything
        addon.Modules.Sorting:Run(provider)

        -- run hide player after as it may impact targeting
        addon.Modules.HidePlayer:Run()

        addon.Modules.Targeting:Run()
        addon.Modules.Macro:Run()
    end, "Runner")
end

---Initialises all modules.
function M:Init()
    addon.Modules.HidePlayer:Init()
    addon.Modules.Sorting:Init()
    addon.Modules.Targeting:Init()
    addon.Modules.Macro:Init()

    for _, provider in ipairs(fsProviders.All) do
        -- for any special events that individual providers request a sort for
        provider:RegisterRequestSortCallback(OnProviderRequiresSort)
    end

    wow.EventRegistry:RegisterCallback(events.EditModeExit, OnEditModeExited)

    -- delay the event subscriptions to hopefully help with being notified after other addons
    fsScheduler:RunWhenEnteringWorld(function()
        timerFrame = wow.CreateFrame("Frame")
        timerFrame:HookScript("OnEvent", OnTimer)
        timerFrame:RegisterEvent(wow.Events.START_TIMER)

        eventFrame = wow.CreateFrame("Frame")
        eventFrame:HookScript("OnEvent", OnEvent)
        eventFrame:RegisterEvent(events.GROUP_ROSTER_UPDATE)
        eventFrame:RegisterEvent(events.UNIT_PET)

        -- sometimes there is a delay from when a person joins group until their role is assigned
        -- so trigger a sort once we know their role
        eventFrame:RegisterEvent(events.PLAYER_ROLES_ASSIGNED)

        if wow.IsRetail() then
            eventFrame:RegisterEvent(events.ARENA_PREP_OPPONENT_SPECIALIZATIONS)

            -- TODO: is this event required? it's very noisy
            -- suspect ARENA_PREP_OPPONENT_SPECIALIZATIONS is sufficient for our use
            eventFrame:RegisterEvent(events.ARENA_OPPONENT_UPDATE)
        end

        -- perform the initial run
        fsLog:Debug("First run.")
        M:Run()
    end)
end
