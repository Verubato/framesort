---@type string, Addon
local _, addon = ...
local fsProviders = addon.Providers
local fsScheduler = addon.Scheduling.Scheduler
local fsInspector = addon.Modules.Inspector
local fsUnit = addon.WoW.Unit
local fsLog = addon.Logging.Log
local fsEnumerable = addon.Collections.Enumerable
local wow = addon.WoW.Api
local events = wow.Events
local M = addon.Modules
local timerFrame = nil
local eventFrame = nil
local combatFrame = nil
local pvpTimerType = 1
local run = false
local runAll = false
---@type { [FrameProvider]: boolean }
local runProviders = {}

local function ScheduleSort(provider)
    run = true

    if provider then
        runProviders[provider] = true
    else
        runAll = true
    end
end

local function OnProviderRequiresSort(provider)
    fsLog:Debug("Provider %s requested sort.", provider:Name())
    ScheduleSort(provider)
end

local function Run(forceRunAll)
    local all = runAll or forceRunAll

    -- swap the flags before attempting to run
    -- as this is happening in OnUpdate, if we for some reason encounter an error then we don't want to retry the run
    runAll = false
    run = false
    local providers = nil

    if not all then
        providers = {}

        for provider, _ in pairs(runProviders) do
            providers[#providers + 1] = provider
        end

        runProviders = {}
    end

    M:Run(providers)
end

local function OnCombat()
    if not run then
        return
    end

    -- we are entering combat, last chance to run a sort if one was scheduled
    -- there is a scenario with Gladius where an enemy stealthy comes out of stealth
    -- at the same time as the play enters combat, e.g. a rogue cheapshot on you
    -- at this time an ARENA_OPPONENT_UPDATE is sent with "seen" parameter
    -- which triggers gladius to reposition it's frames
    -- by default we would then schedule a sort to occur, but I think it's too late
    -- as OnUpdate may have already ran this frame, and the next frame we are in lockdown
    -- this is all conjecture, need to confirm what order of events this happens in
    -- and whether this is actually needed or not
    -- TODO: is this required, or will OnUpdate run anyway?
    fsLog:Debug("Running sort just before combat starts.")
    Run(true)
end

local function OnTimer(_, _, timerType, timeSeconds)
    if timerType ~= pvpTimerType then
        return
    end

    -- TODO: I don't think this is required anymore
    -- it was added to workaround a bug where enemy macros weren't being updated
    -- but that bug was macro cache related and not a timing issue, so this workaround didn't do anything AFAIK
    -- would need to do more testing before feeling comfortable to remove this
    fsScheduler:RunAfter(timeSeconds + 1, function()
        fsLog:Debug("Timer requested sort.")
        ScheduleSort()
    end)
end

local function OnInspectorInfo()
    -- technically it's beneficial if we know at least 2 specs then perform a sort
    -- but from a practical standpoint it's probably better for performance to wait until we have quorum
    -- and it might help reduce frame flicker as it reduces sorting noise
    local units = fsUnit:FriendlyUnits()

    if #units == 0 then
        return
    end

    local nonPets = fsEnumerable
        :From(units)
        :Where(function(unit)
            return not fsUnit:IsPet(unit)
        end)
        :ToTable()

    local knownSpecs = 0

    for i = 1, #nonPets do
        local unit = nonPets[i]
        local guid = wow.UnitGUID(unit)

        if guid and not wow.issecretvalue(guid) then
            local spec = fsInspector:UnitSpec(guid)

            if spec then
                knownSpecs = knownSpecs + 1
            end
        end
    end

    -- re-sort every 5th spec known
    local everyNth = 5
    local shouldSort = knownSpecs == #nonPets or knownSpecs % everyNth == 0

    if not shouldSort then
        return
    end

    fsLog:Debug("Scheduling sort as we have spec quorum of %d/%d.", knownSpecs, #nonPets)
    ScheduleSort()
end

local function OnUpdate()
    if not run then
        return
    end

    Run()
end

local function OnEvent(_, event)
    fsLog:Debug("Event: %s", event)

    -- flag that a run needs to occur
    -- the reason we do this instead of just running straight away is because multiple events may have fired during a single frame
    -- and for efficiency/performance sake we only want to run once
    ScheduleSort()
end

function M:Run(providers)
    fsScheduler:RunWhenCombatEnds(function()
        local start = wow.GetTimePreciseSec()

        -- run auto promotion first
        addon.Modules.AutoLeader:Run()

        -- run hide player next as it may impact the rest
        addon.Modules.HidePlayer:Run()

        -- now sort as it affects targeting and macros
        if providers and #providers > 0 then
            for _, provider in ipairs(providers) do
                addon.Modules.Sorting:Run(provider)
            end
        else
            addon.Modules.Sorting:Run()
        end

        addon.Modules.Targeting:Run()
        addon.Modules.Macro:Run()

        local stop = wow.GetTimePreciseSec()
        fsLog:Debug("Overall run time took %fms", (stop - start) * 1000)
    end, "Runner")
end

---Initialises all modules.
function M:Init()
    addon.Modules.Sorting.SortedUnits:Init()
    addon.Modules.AutoLeader:Init()
    addon.Modules.HidePlayer:Init()
    addon.Modules.Sorting:Init()
    addon.Modules.Targeting:Init()
    addon.Modules.Macro:Init()
    addon.Modules.Inspector:Init()
    addon.Modules.UnitTracker:Init()

    for _, provider in ipairs(fsProviders.All) do
        -- for any special events that individual providers request a sort for
        provider:RegisterRequestSortCallback(OnProviderRequiresSort)
    end

    -- delay the event subscriptions to hopefully help with being notified after other addons
    -- probably not needed anymore now that we sort in OnUpdate
    fsScheduler:RunWhenEnteringWorldOnce(function()
        timerFrame = wow.CreateFrame("Frame")
        timerFrame:HookScript("OnEvent", OnTimer)
        timerFrame:HookScript("OnUpdate", OnUpdate)
        timerFrame:RegisterEvent(wow.Events.START_TIMER)

        eventFrame = wow.CreateFrame("Frame")
        eventFrame:HookScript("OnEvent", OnEvent)
        eventFrame:RegisterEvent(events.GROUP_ROSTER_UPDATE)
        eventFrame:RegisterEvent(events.UNIT_PET)

        -- sometimes there is a delay from when a person joins group until their role is assigned
        -- so trigger a sort once we know their role
        eventFrame:RegisterEvent(events.PLAYER_ROLES_ASSIGNED)

        if wow.HasEnemySpecSupport() then
            eventFrame:RegisterEvent(events.ARENA_PREP_OPPONENT_SPECIALIZATIONS)
            eventFrame:RegisterEvent(events.ARENA_OPPONENT_UPDATE)
        end

        combatFrame = wow.CreateFrame("Frame")
        combatFrame:HookScript("OnEvent", OnCombat)
        combatFrame:RegisterEvent(wow.Events.PLAYER_REGEN_DISABLED)

        -- perform the initial run
        fsLog:Debug("First run.")
        M:Run()
    end)

    fsInspector:RegisterCallback(OnInspectorInfo)
end
