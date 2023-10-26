---@type string, Addon
local _, addon = ...
local fsProviders = addon.Providers
local fsScheduler = addon.Scheduling.Scheduler
local wow = addon.WoW.Api
local M = addon.Modules
local eventFrame = nil
local pvpTimerType = 1

local function OnProviderRequiresSort(provider)
    M:Run(provider)
end

local function OnEvent(_, event, timerType, timeSeconds)
    if timerType ~= pvpTimerType then return end

    -- TODO: there seems to be a bug in solo shuffle where enemy macros/targeting isn't updated
    -- unsure the specifics yet, but I have a feeling it's after round 1 that it occurs
    -- as a workaround, run 1 second after the gates open
    fsScheduler:RunAfter(timeSeconds + 1, function()
        M:Run()
    end)
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
        provider:RegisterRequestSortCallback(OnProviderRequiresSort)
    end

    fsScheduler:RunWhenEnteringWorld(function() M:Run() end)

    eventFrame = wow.CreateFrame("Frame")
    eventFrame:HookScript("OnEvent", OnEvent)
    eventFrame:RegisterEvent(wow.Events.START_TIMER)
end
