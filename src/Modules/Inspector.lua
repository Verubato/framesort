-- previously used LibGroupInSpecT but it hasn't been maintained and stopped working in Midnight
-- so we'll just make our own lightweight version instead
---@type string, Addon
local _, addon = ...
local wow = addon.WoW.Api
local wowEx = addon.WoW.WowEx
local events = addon.WoW.Events
local capabilities = addon.WoW.Capabilities
local fsUnit = addon.WoW.Unit
local fsLog = addon.Logging.Log
local fsConfig = addon.Configuration
local fsSpec = addon.Configuration.Specs
local fsScheduler = addon.Scheduling.Scheduler
---@class InspectorModule : IInitialise, IProcessEvents
local M = {}
addon.Modules.Inspector = M

-- how often in seconds to run our main loop
local inspectInterval = 0.5

-- key = unit, value = { SpecId: number, LastAttempt: number, LastSeen: number }
local unitGuidToSpec = {}

-- the latest/current an inspection is happening for
local requestedUnit

-- the latest/current unit we've requested an inspection for
local currentInspectUnit

--- true if we requested this inspection
local isOurInspect

-- true if we need to run and update spec information
local needUpdate = true

-- when we started out last inspect
local inspectStarted

-- if no API response after X seconds, retry
local inspectTimeout = 10

-- if a cache entry has a spec id of 0 (i.e. no data), retry after X seconds
local cacheTimeout = 60

-- if a cache entry hasn't been updated in this amount of time, remove it
-- 3 days
local cacheExpiry = 60 * 60 * 24 * 3

local callbacks = {}

local function OnNewSpecInformation()
    for _, callback in ipairs(callbacks) do
        local ok, err = pcall(callback)
        if not ok then
            fsLog:Error("OnNewSpecInformation callback failed: %s", tostring(err))
        end
    end
end

local function EnsureCacheEntry(unit)
    local guid = wow.UnitGUID(unit)

    -- this can happen sometimes if the unit is "mouseover"
    if not guid then
        return
    end

    if wow.issecretvalue(guid) then
        -- it'll be a secret value when this is an enemy unit
        return
    end

    local cacheEntry = unitGuidToSpec[guid] or {}
    unitGuidToSpec[guid] = cacheEntry

    return cacheEntry
end

local function Inspect(unit)
    local specId = wowEx.GetInspectSpecializationSafe(unit)

    if specId then
        local cacheEntry = EnsureCacheEntry(unit)

        if not cacheEntry then
            return
        end

        -- the spec id may be 0, in which case we'll use the previous value (if one exists)
        local before = cacheEntry.SpecId
        cacheEntry.SpecId = specId
        cacheEntry.LastSeen = wow.GetTimePreciseSec()
        local after = cacheEntry.SpecId

        if before ~= after then
            fsLog:Debug("Found spec information for unit '%s' spec id %s.", unit, specId)
            OnNewSpecInformation()
        end
    else
        fsLog:Debug("Failed to determine spec for unit '%s'.", unit)
    end

    if isOurInspect then
        currentInspectUnit = nil
        requestedUnit = nil
        isOurInspect = false
        wow.ClearInspectPlayer()
    end
end

local function GetNextTarget()
    local units = fsUnit:FriendlyUnits()

    -- first attempt to find someone we don't have any information for
    for _, unit in ipairs(units) do
        local guid = wow.UnitGUID(unit)

        if not guid then
            fsLog:Warning("Unable to request spec information for unit '%s' because their GUID is nil.", unit)
        -- this shouldn't be possible, but it does happen for some reason
        elseif not wow.issecretvalue(guid) then
            local cacheEntry = unitGuidToSpec[guid]

            if not wow.UnitIsUnit(unit, "player") and not cacheEntry and wow.CanInspect(unit) and wow.UnitIsConnected(unit) then
                return unit
            end
        else
            fsLog:Warning("Unable to request spec information for unit '%s' because their GUID is a secret.", unit)
        end
    end

    -- now attempt to find someone we have stale information for
    for _, unit in ipairs(units) do
        local guid = wow.UnitGUID(unit)

        if not guid then
            fsLog:Warning("Unable to request spec information for unit '%s' because their GUID is nil.", unit)
        -- this shouldn't be possible, but it does happen for some reason
        elseif not wow.issecretvalue(guid) then
            local cacheEntry = unitGuidToSpec[guid]

            if
                cacheEntry
                and (not cacheEntry.SpecId or cacheEntry.SpecId == 0)
                and wow.CanInspect(unit)
                and wow.UnitIsConnected(unit)
                and (not cacheEntry.LastAttempt or (wow.GetTimePreciseSec() - cacheEntry.LastAttempt > cacheTimeout))
            then
                return unit
            end
        else
            fsLog:Warning("Unable to request spec information for unit '%s' because their GUID is a secret.", unit)
        end
    end

    return nil
end

local function InspectNext()
    local unit = GetNextTarget()

    if not unit then
        inspectStarted = nil
        requestedUnit = nil
        currentInspectUnit = nil
        return false
    end

    wow.ClearInspectPlayer()
    wow.NotifyInspect(unit)
    isOurInspect = true

    inspectStarted = wow.GetTimePreciseSec()
    requestedUnit = unit
    currentInspectUnit = unit

    -- create a cache entry for this unit so we don't attempt this unit again in the next iteration
    local cacheEntry = EnsureCacheEntry(unit)

    if not cacheEntry then
        -- return true to try another unit next run
        return true
    end

    cacheEntry.LastAttempt = wow.GetTimePreciseSec()

    fsLog:Debug("Requesting inspection for unit '%s'.", unit)

    return true
end

local function InvalidateEntry(unit)
    -- could flag it as stale, but might as well just remove it entirely
    local guid = wow.UnitGUID(unit)

    if not guid then
        return
    end

    if wow.issecretvalue(guid) then
        return
    end

    unitGuidToSpec[guid] = nil

    needUpdate = true
end

local function RoleSortingEnabled()
    local db = addon.DB
    local sorting = db.Options.Sorting

    if sorting.Dungeon.Enabled and sorting.Dungeon.GroupSortMode == fsConfig.GroupSortMode.Role then
        return true
    end
    if sorting.World.Enabled and sorting.World.GroupSortMode == fsConfig.GroupSortMode.Role then
        return true
    end
    if sorting.Raid.Enabled and sorting.Raid.GroupSortMode == fsConfig.GroupSortMode.Role then
        return true
    end

    return false
end

local function OnClearInspect()
    -- someone finished with their inspection
    -- set unitInspecting to nil so we can queue ours up next
    requestedUnit = nil
end

local function OnNotifyInspect(unit)
    if currentInspectUnit and unit ~= currentInspectUnit then
        fsLog:Debug("Someone else has overridden our inspect player request.")
        currentInspectUnit = nil
    end

    -- override the inspected unit so we get it's information
    requestedUnit = unit
    inspectStarted = wow.GetTimePreciseSec()
    isOurInspect = false
end

local function PurgeOldEntries()
    local now = wow.GetTimePreciseSec()
    local toRemove = {}

    -- to keep the saved variable size down
    -- remove any old entries we don't care about anymore
    for guid, entry in pairs(unitGuidToSpec) do
        if not entry or type(entry) ~= "table" or not entry.LastSeen or (now - entry.LastSeen) > cacheExpiry then
            toRemove[#toRemove + 1] = guid
        end
    end

    for _, guid in ipairs(toRemove) do
        fsLog:Debug("Purging expired cache entry for unit: %s", guid)
        unitGuidToSpec[guid] = nil
    end
end

local function RunLoop()
    -- schedule the next run
    fsScheduler:RunAfter(inspectInterval, RunLoop)

    if not RoleSortingEnabled() then
        return
    end

    local timeSinceLastInspect = inspectStarted and (wow.GetTimePreciseSec() - inspectStarted)

    -- if we've requested an inspection and we're still within the timeout period
    if requestedUnit ~= nil and timeSinceLastInspect < inspectTimeout then
        return
    end

    -- Timeout occurred - reset state
    if requestedUnit ~= nil and timeSinceLastInspect >= inspectTimeout then
        if isOurInspect then
            fsLog:Debug("Inspect timeout for unit '%s'.", requestedUnit)
        end

        requestedUnit = nil
        currentInspectUnit = nil
        isOurInspect = false
        wow.ClearInspectPlayer()
    end

    if not needUpdate then
        return
    end

    needUpdate = InspectNext()
end

function M:ProcessEvent(event, ...)
    if event == events.INSPECT_READY then
        if requestedUnit then
            Inspect(requestedUnit)
        end
    elseif event == events.GROUP_ROSTER_UPDATE then
        needUpdate = true
    elseif event == events.PLAYER_SPECIALIZATION_CHANGED then
        local unit = select(1, ...)
        InvalidateEntry(unit)
    end
end

---Returns the spec id of a friendly player unit.
---@param unit string
---@return number|nil
function M:FriendlyUnitSpec(unit)
    if not unit then
        fsLog:Error("Inspector:FriendlyUnitSpec() - unit must not be nil.")
        return nil
    end

    if (unit == "player" or wow.UnitIsUnit("player", unit)) and wow.GetSpecialization and wow.GetSpecializationInfo then
        local index = wow.GetSpecialization()
        local id = wow.GetSpecializationInfo(index)
        return id
    end

    local guid = wow.UnitGUID(unit)

    if not guid then
        fsLog:Warning("Encountered nil guid for unit '%s'.", unit)
        return nil
    end

    if wow.issecretvalue(guid) then
        fsLog:Warning("Encountered secret guid for unit '%s'.", unit)
        return nil
    end

    local cacheEntry = unitGuidToSpec[guid]

    if not cacheEntry then
        return nil
    end

    return cacheEntry.SpecId
end

---Returns the spec id of an enemy unit.
---@param unit string
---@return number|nil
function M:EnemyUnitSpec(unit)
    if not unit then
        fsLog:Error("Inspector:EnemyUnitSpec() - unit must not be nil.")
        return nil
    end

    if unit:match("^arenapet%d+$") then
        -- pets don't have a spec
        return nil
    end

    local isArena = unit:match("^arena%d+$")
    local unitNumber = tonumber(string.match(unit, "%d+"))
    local specId = isArena and unitNumber and wowEx.GetArenaOpponentSpecSafe(unitNumber)

    if specId then
        return specId
    end

    local guid = wow.UnitGUID(unit)

    if not guid then
        fsLog:Warning("Encountered nil guid for unit '%s'.", unit)
        return nil
    end

    if wow.issecretvalue(guid) then
        fsLog:Warning("Encountered secret guid for unit '%s'.", unit)
        return nil
    end

    local cacheEntry = unitGuidToSpec[guid]

    if cacheEntry and cacheEntry.SpecId and cacheEntry.SpecId > 0 then
        return cacheEntry.SpecId
    end

    if not capabilities.HasC_PvP() or not wow.C_PvP or not wow.C_PvP.GetScoreInfoByPlayerGuid then
        return nil
    end

    -- fallback: query the scoreboard by GUID (works in BGs/brawls/arena when the scoreboard is shown)
    local info = wow.C_PvP.GetScoreInfoByPlayerGuid(guid)

    if not info then
        return nil
    end

    if info.classToken and info.talentSpec then
        specId = fsSpec:SpecIdFromName(info.classToken, info.talentSpec)

        if not specId then
            return nil
        end

        cacheEntry = EnsureCacheEntry(unit)

        if not cacheEntry then
            return specId
        end

        cacheEntry.SpecId = specId
        cacheEntry.LastSeen = wow.GetTimePreciseSec()

        return specId
    end

    return nil
end

---Manually adds a spec id entry.
---@param unit string
---@param specId number
function M:Add(unit, specId)
    if not unit then
        fsLog:Error("Inspector:Add() - unit must not be nil.")
        return
    end

    if not specId then
        fsLog:Error("Inspector:Add() - specId must not be nil.")
        return
    end

    local cacheEntry = EnsureCacheEntry(unit)

    if not cacheEntry then
        return
    end

    cacheEntry.SpecId = specId
    cacheEntry.LastSeen = wow.GetTimePreciseSec()
end

function M:PurgeCache()
    local db = addon.DB
    db.SpecCache = {}
    unitGuidToSpec = db.SpecCache
end

---Registers a callback to be invoked when new spec information has been found.
---@param callback function
function M:RegisterCallback(callback)
    if not callback then
        fsLog:ErrorOnce("Inspector:RegisterCallback() - callback must not be nil.")
        return
    end

    callbacks[#callbacks + 1] = callback
end

function M:CanRun()
    return (wow.CanInspect and wow.NotifyInspect and wow.ClearInspectPlayer and wow.GetInspectSpecialization) ~= nil and capabilities.HasSpecializations()
end

function M:Init()
    if not M:CanRun() then
        fsLog:Debug("Inspector module not loading because this wow client doesn't have specializations.")
        return
    end

    -- persist cache as a saved variable
    local db = addon.DB
    db.SpecCache = db.SpecCache or {}
    unitGuidToSpec = db.SpecCache

    PurgeOldEntries()

    -- hook it so we gain the benefit inspection results from other callers
    wow.hooksecurefunc("NotifyInspect", OnNotifyInspect)
    wow.hooksecurefunc("ClearInspectPlayer", OnClearInspect)

    RunLoop()

    fsLog:Debug("Initialised the spec inspector module.")
end
