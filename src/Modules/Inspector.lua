-- previously used LibGroupInSpecT but it hasn't been maintained and stopped working in Midnight
-- so we'll just make our own lightweight version instead
---@type string, Addon
local _, addon = ...
local wow = addon.WoW.Api
local fsUnit = addon.WoW.Unit
local fsEnumerable = addon.Collections.Enumerable
local fsLog = addon.Logging.Log
---@class InspectorModule : IInitialise
local M = {}
addon.Modules.Inspector = M

-- key = unit, value = { Stale: boolean, SpecId: number }
local unitGuidToSpec = {}

-- the latest/current unit we've requested an inspection for
local unitInspecting

-- true if we need to run and update spec information
local needUpdate = true

-- when we started out last inspect
local inspectStarted

-- if no API response after X seconds, retry
local inspectTimeout = 10

-- if a cache entry has a spec id of 0 (i.e. no data), retry after X seconds
local cacheTimeout = 60

local function EnsureCacheEntry(unit)
    local guid = wow.UnitGUID(unit)
    local cacheEntry = unitGuidToSpec[guid] or {}
    unitGuidToSpec[guid] = cacheEntry

    cacheEntry.SpecId = cacheEntry.SpecId or 0
    cacheEntry.Stale = cacheEntry.Stale or true
    cacheEntry.LastAttempt = nil

    return cacheEntry
end

local function Inspect(unit)
    -- it's entirely possible someone else requested an inspection for a different unit
    -- in which case our request is stale and we won't get any data returned
    -- this is fine and we'll just retry later

    local guid = wow.UnitGUID(unit)
    local specId = wow.GetInspectSpecialization(unit)
    local cacheEntry = EnsureCacheEntry(unit)

    -- the spec id may be 0, in which case we'll use the previous value (if one exists)
    cacheEntry.SpecId = specId ~= 0 and specId or cacheEntry.SpecId
    cacheEntry.LastAttempt = wow.GetTime()

    fsLog:Debug("Found spec information for unit: " .. unit .. " spec id: " .. specId)

    wow.ClearInspectPlayer()
end

local function GetNextTarget()
    local units = fsUnit:FriendlyUnits()

    -- first attempt to find someone we don't have any information for
    for _, unit in ipairs(units) do
        local guid = wow.UnitGUID(unit)
        local cacheEntry = unitGuidToSpec[guid]

        if not wow.UnitIsUnit(unit, "player") and not cacheEntry and wow.CanInspect(unit) and wow.UnitIsConnected(unit) then
            return unit
        end
    end

    -- now attempt to find someone we have stale information for
    for _, unit in ipairs(units) do
        local guid = wow.UnitGUID(unit)
        local cacheEntry = unitGuidToSpec[guid]

        if cacheEntry and cacheEntry.SpecId == 0 and wow.CanInspect(unit) and wow.UnitIsConnected(unit) and (wow.GetTime() - cacheEntry.LastAttempt > cacheTimeout) then
            return unit
        end
    end

    return nil
end

local function InspectNext()
    local unit = GetNextTarget()

    if not unit then
        inspectStarted = nil
        unitInspecting = nil
        return false
    end

    wow.ClearInspectPlayer()
    wow.NotifyInspect(unit)

    inspectStarted = wow.GetTime()
    unitInspecting = unit

    fsLog:Debug("Requesting inspection for unit: " .. unit)

    return true
end

local function OnEvent(_, event)
    if event == wow.Events.INSPECT_READY then
        if unitInspecting then
            Inspect(unitInspecting)
        end
    elseif event == wow.Events.GROUP_ROSTER_UPDATE then
        needUpdate = true
    end
end

local function OnUpdate()
    local timeSinceLastInspect = inspectStarted and (wow.GetTime() - inspectStarted)

    -- if we've requested an inspection and we're still within the timeout period
    if unitInspecting ~= nil and timeSinceLastInspect < inspectTimeout then
        return
    end

    if not needUpdate then
        return
    end

    needUpdate = InspectNext()
end

function M:UnitSpec(unitGuid)
    if unitGuid == wow.UnitGUID("player") and wow.GetSpecialization and wow.GetSpecializationInfo then
        local index = wow.GetSpecialization()
        local id = wow.GetSpecializationInfo(index)
        return id
    end

    local cacheEntry = unitGuidToSpec[unitGuid]

    if not cacheEntry then
        return nil
    end

    return cacheEntry.SpecId
end

-- for debugging purposes
function M:GetCache()
    return unitGuidToSpec
end

function M:Init()
    local canRun = (wow.CanInspect and wow.NotifyInspect and wow.ClearInspectPlayer and wow.GetInspectSpecialization) ~= nil

    if not canRun then
        fsLog:Warning("Inspector unable to run, role sorting won't work.")
        return
    end

    local frame = wow.CreateFrame("Frame")
    frame:HookScript("OnEvent", OnEvent)
    frame:HookScript("OnUpdate", OnUpdate)
    frame:RegisterEvent(wow.Events.INSPECT_READY)
    frame:RegisterEvent(wow.Events.GROUP_ROSTER_UPDATE)
end
