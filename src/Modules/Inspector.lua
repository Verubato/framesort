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

-- key = unit, value = { SpecId: number, LastAttempt: number, LastSeen: number }
local unitGuidToSpec

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

-- if a cache entry hasn't been updated in this amount of time, remove it
-- 3 days
local cacheExpiry = 60 * 60 * 24 * 3

local callbacks = {}

local function OnNewSpecInformation()
    for _, callback in ipairs(callbacks) do
        pcall(callback)
    end
end

local function EnsureCacheEntry(unit)
    local guid = wow.UnitGUID(unit)
    local cacheEntry = unitGuidToSpec[guid] or {}
    unitGuidToSpec[guid] = cacheEntry

    return cacheEntry
end

local function Inspect(unit)
    -- it's entirely possible someone else requested an inspection for a different unit
    -- in which case our request is stale and we won't get any data returned
    -- this is fine and we'll just retry later
    local guid = wow.UnitGUID(unit)

    if wow.issecretvalue(guid) then
        -- it'll be a secret value when this is an enemy unit
        return
    end

    local specId = wow.GetInspectSpecialization(unit)
    local cacheEntry = EnsureCacheEntry(unit)

    -- the spec id may be 0, in which case we'll use the previous value (if one exists)
    local before = cacheEntry.SpecId
    cacheEntry.SpecId = specId ~= 0 and specId or cacheEntry.SpecId
    local after = cacheEntry.SpecId

    if before ~= after then
        fsLog:Debug("Found new spec information, notifying callbacks.")
        OnNewSpecInformation()
    end

    cacheEntry.LastSeen = wow.GetTime()

    fsLog:Debug("Found spec information for unit: " .. unit .. " spec id: " .. specId)

    wow.ClearInspectPlayer()
end

local function GetNextTarget()
    local units = fsUnit:FriendlyUnits()

    -- first attempt to find someone we don't have any information for
    for _, unit in ipairs(units) do
        local guid = wow.UnitGUID(unit)

        -- this shouldn't be possible, but it does happen for some reason
        if not wow.issecretvalue(guid) then
            local cacheEntry = unitGuidToSpec[guid]

            if not wow.UnitIsUnit(unit, "player") and not cacheEntry and wow.CanInspect(unit) and wow.UnitIsConnected(unit) then
                return unit
            end
        end
    end

    -- now attempt to find someone we have stale information for
    for _, unit in ipairs(units) do
        local guid = wow.UnitGUID(unit)

        -- this shouldn't be possible, but it does happen for some reason
        if not wow.issecretvalue(guid) then
            local cacheEntry = unitGuidToSpec[guid]

            if
                cacheEntry
                and cacheEntry.SpecId == 0
                and wow.CanInspect(unit)
                and wow.UnitIsConnected(unit)
                and (not cacheEntry.LastAttempt or (wow.GetTime() - cacheEntry.LastAttempt > cacheTimeout))
            then
                return unit
            end
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

    -- create a cache entry for this unit so we don't attempt this unit again in the next iteration
    local cacheEntry = EnsureCacheEntry(unit)
    cacheEntry.LastAttempt = wow.GetTime()

    fsLog:Debug("Requesting inspection for unit: " .. unit)

    return true
end

local function InvalidateEntry(unit)
    -- could flag it as stale, but might as well just remove it entirely
    local guid = wow.UnitGUID(unit)

    if wow.issecretvalue(guid) then
        return
    end

    unitGuidToSpec[guid] = nil

    needUpdate = true
end

local function OnEvent(_, event, arg1)
    if event == wow.Events.INSPECT_READY then
        if unitInspecting then
            Inspect(unitInspecting)
        end
    elseif event == wow.Events.GROUP_ROSTER_UPDATE then
        needUpdate = true
    elseif event == wow.Events.PLAYER_SPECIALIZATION_CHANGED then
        InvalidateEntry(arg1)
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

local function OnNotifyInspect(unit)
    -- override the inspected unit so we get it's information
    unitInspecting = unit
    inspectStarted = wow.GetTime()
end

local function PurgeOldEntries()
    local now = wow.GetTime()
    local toRemove = {}

    -- to keep the saved variable size down
    -- remove any old entries we don't care about anymore
    for guid, entry in pairs(unitGuidToSpec) do
        if not entry.LastSeen or (now - entry.LastSeen) > cacheExpiry then
            toRemove[#toRemove + 1] = guid
        end
    end

    for _, guid in ipairs(toRemove) do
        fsLog:Debug("Purging expired cache entry for unit: " .. guid)
        unitGuidToSpec[guid] = nil
    end
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

function M:PurgeCache()
    local db = addon.DB
    db.SpecCache = {}
    unitGuidToSpec = db.SpecCache
end

---Registers a callback to be invoked when new spec information has been found.
---@param callback function
function M:RegisterCallback(callback)
    callbacks[#callbacks + 1] = callback
end

function M:Init()
    local canRun = (wow.CanInspect and wow.NotifyInspect and wow.ClearInspectPlayer and wow.GetInspectSpecialization) ~= nil

    if not canRun then
        fsLog:Warning("Inspector module unable to run, role sorting won't work.")
        return
    end

    -- persist cache as a saved variable
    local db = addon.DB
    db.SpecCache = db.SpecCache or {}
    unitGuidToSpec = db.SpecCache

    PurgeOldEntries()

    local frame = wow.CreateFrame("Frame")
    frame:HookScript("OnEvent", OnEvent)
    frame:HookScript("OnUpdate", OnUpdate)
    frame:RegisterEvent(wow.Events.INSPECT_READY)
    frame:RegisterEvent(wow.Events.GROUP_ROSTER_UPDATE)
    frame:RegisterEvent(wow.Events.PLAYER_SPECIALIZATION_CHANGED)

    -- hook it so we gain the benefit inspection results from other callers
    wow.hooksecurefunc("NotifyInspect", OnNotifyInspect)
    fsLog:Debug("Initialised the spec inspector module.")
end
