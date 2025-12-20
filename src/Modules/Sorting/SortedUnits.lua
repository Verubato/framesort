---@type string, Addon
local _, addon = ...
local fsCompare = addon.Modules.Sorting.Comparer
local fsFrame = addon.WoW.Frame
local fsUnit = addon.WoW.Unit
local fsEnumerable = addon.Collections.Enumerable
local fsInspector = addon.Modules.Inspector
local fsConfig = addon.Configuration
local fsSortedFrames = addon.Modules.Sorting.SortedFrames
local wow = addon.WoW.Api
local events = addon.WoW.Events
local capabilities = addon.WoW.Capabilities
local fsLog = addon.Logging.Log

---@class SortedUnits: IInitialise, IProcessEvents
local M = {}
addon.Modules.Sorting.SortedUnits = M

-- setting a value of false disables this module
local cacheEnabled = true

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
local currentStatsTick = 0
local logStatsInterval = 10

local function InvalidateFriendlyCache()
    friendlyCacheValid = false
end

local function InvalidateEnemyCache()
    enemyCacheValid = false
end

local function OnPetEvent(event, petOwner)
    -- UNIT_PET fires for both allies and enemies
    if wow.UnitIsFriend("player", petOwner) then
        InvalidateFriendlyCache()
    else
        InvalidateEnemyCache()
    end
end

local function OnInspectorInfo()
    InvalidateFriendlyCache()
end

local function OnConfigChanged()
    InvalidateFriendlyCache()
    InvalidateEnemyCache()
end

local function FriendlyUnitsFromFrames(sort)
    local frames = fsSortedFrames:FriendlyFrames()
    local units = fsEnumerable
        :From(frames)
        :Map(function(x)
            return fsFrame:GetFrameUnit(x)
        end)
        :ToTable()

    if not sort or #units == 0 then
        return units
    end

    local start = wow.GetTimePreciseSec()
    table.sort(units, fsCompare:SortFunction(units))
    local stop = wow.GetTimePreciseSec()
    fsLog:Debug("Friendly units table.sort() took %fms.", (stop - start) * 1000)

    return units
end

local function EnemyUnitsFromFrames(sort)
    local frames = fsSortedFrames:ArenaFrames()
    local units = fsEnumerable
        :From(frames)
        :Map(function(x)
            return fsFrame:GetFrameUnit(x)
        end)
        :ToTable()

    if not sort or #units == 0 then
        return units
    end

    local start = wow.GetTimePreciseSec()
    table.sort(units, fsCompare:EnemySortFunction(units))
    local stop = wow.GetTimePreciseSec()
    fsLog:Debug("Enemy units table.sort() took %fms.", (stop - start) * 1000)

    return units
end

local function FriendlyUnits()
    local units = fsUnit:FriendlyUnits()

    if #units == 0 then
        return units
    end

    local start = wow.GetTimePreciseSec()
    table.sort(units, fsCompare:SortFunction(units))
    local stop = wow.GetTimePreciseSec()
    fsLog:Debug("Friendly units table.sort() took %fms.", (stop - start) * 1000)

    return units
end

local function EnemyUnits()
    local units = fsUnit:ArenaUnits()

    if #units == 0 then
        return units
    end

    local start = wow.GetTimePreciseSec()
    table.sort(units, fsCompare:EnemySortFunction(units))
    local stop = wow.GetTimePreciseSec()
    fsLog:Debug("Enemy units table.sort() took %fms.", (stop - start) * 1000)

    return units
end

local function LogStatsTick()
    currentStatsTick = currentStatsTick + 1

    if currentStatsTick < logStatsInterval then
        return
    end

    M:LogStats()
    currentStatsTick = 0
end

---@return string[]
function M:FriendlyUnits()
    local sortEnabled = fsCompare:FriendlySortMode()

    -- sorting disabled, fallback to frame order
    if not sortEnabled then
        return FriendlyUnitsFromFrames(sortEnabled)
    end

    local hit = false
    local cache = true
    local units = nil

    if cacheEnabled and friendlyCacheValid then
        -- don't want our stats to reflect empty cache hits and misses
        hit = #cachedFriendlyUnits > 0
        units = cachedFriendlyUnits
    else
        units = FriendlyUnits()
    end

    -- try from frames, but don't cache the result
    -- as frames can change without us knowing
    if not units or #units == 0 then
        units = FriendlyUnitsFromFrames(true)
        cache = false
    end

    if cacheEnabled then
        if cache then
            cachedFriendlyUnits = units
            friendlyCacheValid = #units > 0
        end

        if hit then
            friendlyCacheHits = friendlyCacheHits + 1
        else
            friendlyCacheMisses = friendlyCacheMisses + 1
        end

        LogStatsTick()
    end

    return units
end

---@return string[]
function M:EnemyUnits()
    local sortEnabled = fsCompare:EnemySortMode()

    -- sorting disabled, fallback to frame order
    if not sortEnabled then
        return EnemyUnitsFromFrames(sortEnabled)
    end

    local hit = false
    local cache = true
    local units = nil

    if cacheEnabled and enemyCacheValid then
        -- don't want our stats to reflect empty cache hits and misses
        hit = #cachedEnemyUnits > 0
        units = cachedEnemyUnits
    else
        units = EnemyUnits()
    end

    -- try from frames, but don't cache the result
    -- as frames can change without us knowing
    if not units or #units == 0 then
        units = EnemyUnitsFromFrames(true)
        cache = false
    end

    if cacheEnabled then
        if cache then
            cachedEnemyUnits = units
            enemyCacheValid = #units > 0
        end

        if hit then
            enemyCacheHits = enemyCacheHits + 1
        else
            enemyCacheMisses = enemyCacheMisses + 1
        end

        LogStatsTick()
    end

    return units
end

function M:InvalidateCache()
    InvalidateFriendlyCache()
    InvalidateEnemyCache()
end

function M:LogStats()
    fsLog:Debug("Friendly cache %d hits %d misses, enemy cache %d hits %d misses.", friendlyCacheHits, friendlyCacheMisses, enemyCacheHits, enemyCacheMisses)
end

function M:ProcessEvent(event, ...)
    if not cacheEnabled then
        return
    end

    if event == events.GROUP_ROSTER_UPDATE then
        InvalidateFriendlyCache()
    elseif event == events.PLAYER_ROLES_ASSIGNED then
        InvalidateFriendlyCache()
    elseif event == events.ARENA_OPPONENT_UPDATE then
        InvalidateEnemyCache()
    elseif event == events.ARENA_PREP_OPPONENT_SPECIALIZATIONS then
        InvalidateEnemyCache()
    elseif event == events.UNIT_PET then
        local unit = select(1, ...)
        OnPetEvent(event, unit)
    end
end

function M:Init()
    if not cacheEnabled then
        return
    end

    fsInspector:RegisterCallback(OnInspectorInfo)
    fsConfig:RegisterConfigurationChangedCallback(OnConfigChanged)

    fsLog:Debug("Initialised the sorted units caching module.")
end
