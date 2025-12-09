---@type string, Addon
local _, addon = ...
local fsCompare = addon.Modules.Sorting.Comparer
local fsFrame = addon.WoW.Frame
local fsUnit = addon.WoW.Unit
local fsEnumerable = addon.Collections.Enumerable
local fsInspector = addon.Modules.Inspector
local fsConfig = addon.Configuration
local wow = addon.WoW.Api
local events = wow.Events
local fsLog = addon.Logging.Log

---@class SortedUnits
local M = {}
addon.Modules.Sorting.SortedUnits = M

-- setting a value of false disables this module
local cacheEnabled = true
local friendlyEventsFrame = nil
local enemyEventsFrame = nil
local petEventsFrame = nil

-- true means cached values are up to date
local friendlyCacheValid = false
local enemyCacheValid = false

-- the amount of times we returned a cached value
local friendlyCacheHits = 0
local enemyCacheHits = 0
-- the amount of times we returned a non-cached value
local friendlyCacheMisses = 0
local enemyCacheMisses = 0

-- the cached values
local cachedEnemyUnits = {}
local cachedFriendlyUnits = {}

-- log stats ever X hits/misses
local currentStatsInterval = 0
local logStatsInterval = 100

local function InvalidateFriendlyCache()
    friendlyCacheValid = false
end

local function InvalidateEnemyCache()
    enemyCacheValid = false
end

local function OnFriendlyEvent(_, event)
    InvalidateFriendlyCache()
end

local function OnPetEvent(_, event, petOwner)
    -- UNIT_PET fires for both allies and enemies
    if wow.UnitIsFriend("player", petOwner) then
        InvalidateFriendlyCache()
    else
        InvalidateEnemyCache()
    end
end

local function OnEnemyEvent(_, event)
    InvalidateEnemyCache()
end

local function OnInspectorInfo()
    InvalidateFriendlyCache()
end

local function OnConfigChanged()
    InvalidateFriendlyCache()
    InvalidateEnemyCache()
end

-- merge new units into our probably almost sorted array
-- then do a sorting pass over it to finalise the array
local function MergeNewUnits(sortedUnits, newUnits)
    local seen = {}

    for i = 1, #sortedUnits do
        seen[sortedUnits[i]] = true
    end

    for i = 1, #newUnits do
        local unit = newUnits[i]

        if not seen[unit] then
            seen[unit] = true
            sortedUnits[#sortedUnits + 1] = unit
        end
    end

    return sortedUnits
end

local function RefreshFriendlyUnits(existingUnits)
    local units = fsUnit:FriendlyUnits()
    local sortEnabled = fsCompare:FriendlySortMode()

    if not sortEnabled then
        return units
    end

    local toSort = existingUnits and MergeNewUnits(existingUnits, units) or units

    local start = wow.GetTimePreciseSec()
    table.sort(toSort, fsCompare:SortFunction(toSort))
    local stop = wow.GetTimePreciseSec()
    fsLog:Debug("table.sort() took %fms.", (stop - start) * 1000)

    return toSort
end

local function RefreshEnemyUnits(existingUnits)
    local units = fsUnit:EnemyUnits()
    local sortEnabled = fsCompare:EnemySortMode()

    if not sortEnabled then
        return units
    end

    local toSort = existingUnits and MergeNewUnits(existingUnits, units) or units

    table.sort(toSort, fsCompare:EnemySortFunction(toSort))

    return toSort
end

function LogStatsInterval()
    currentStatsInterval = currentStatsInterval + 1

    if currentStatsInterval < logStatsInterval then
        return
    end

    M:LogStats()
    currentStatsInterval = 0
end

---@return string[]
function M:FriendlyUnits()
    if not cacheEnabled then
        return RefreshFriendlyUnits()
    end

    if friendlyCacheValid then
        -- don't want our stats to reflect empty cache hits and misses
        if #cachedFriendlyUnits > 0 then
            friendlyCacheHits = friendlyCacheHits + 1
            LogStatsInterval()
        end

        return cachedFriendlyUnits
    end

    cachedFriendlyUnits = RefreshFriendlyUnits(cachedFriendlyUnits)
    friendlyCacheValid = true

    if #cachedFriendlyUnits > 0 then
        friendlyCacheMisses = friendlyCacheMisses + 1
        LogStatsInterval()
    end

    return cachedFriendlyUnits
end

---@return string[]
function M:EnemyUnits()
    if not cacheEnabled then
        return RefreshEnemyUnits()
    end

    if enemyCacheValid then
        if #cachedEnemyUnits > 0 then
            enemyCacheHits = enemyCacheHits + 1
            LogStatsInterval()
        end

        return cachedEnemyUnits
    end

    cachedEnemyUnits = RefreshEnemyUnits(cachedEnemyUnits)
    enemyCacheValid = true

    if #cachedEnemyUnits > 0 then
        enemyCacheMisses = enemyCacheMisses + 1
        LogStatsInterval()
    end

    return cachedEnemyUnits
end

function M:InvalidateCache()
    InvalidateFriendlyCache()
    InvalidateEnemyCache()
end

function M:LogStats()
    fsLog:Debug("Friendly cache hits %d misses %d, enemy cache hits %d misses %d.", friendlyCacheHits, friendlyCacheMisses, enemyCacheHits, enemyCacheMisses)
end

function M:Init()
    if not cacheEnabled then
        return
    end

    friendlyEventsFrame = wow.CreateFrame("Frame")
    friendlyEventsFrame:HookScript("OnEvent", OnFriendlyEvent)
    friendlyEventsFrame:RegisterEvent(events.GROUP_ROSTER_UPDATE)
    friendlyEventsFrame:RegisterEvent(events.PLAYER_ROLES_ASSIGNED)

    petEventsFrame = wow.CreateFrame("Frame")
    petEventsFrame:HookScript("OnEvent", OnPetEvent)
    petEventsFrame:RegisterEvent(events.UNIT_PET)

    if wow.HasSpecializationInfo() then
        enemyEventsFrame = wow.CreateFrame("Frame")
        enemyEventsFrame:HookScript("OnEvent", OnEnemyEvent)
        enemyEventsFrame:RegisterEvent(events.ARENA_PREP_OPPONENT_SPECIALIZATIONS)
        enemyEventsFrame:RegisterEvent(events.ARENA_OPPONENT_UPDATE)
    end

    fsInspector:RegisterCallback(OnInspectorInfo)
    fsConfig:RegisterConfigurationChangedCallback(OnConfigChanged)

    fsLog:Debug("Initialised the sorted units caching module.")
end
