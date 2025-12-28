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

local function FriendlyUnitsFromFrames()
    local frames = fsSortedFrames:FriendlyFrames()
    local units = fsEnumerable
        :From(frames)
        :Map(function(x)
            return fsFrame:GetFrameUnit(x)
        end)
        :ToTable()

    if #units == 0 then
        return units
    end

    local sortEnabled = fsCompare:FriendlySortMode()

    if not sortEnabled then
        return units
    end

    local start = wow.GetTimePreciseSec()
    table.sort(units, fsCompare:SortFunction(units))
    local stop = wow.GetTimePreciseSec()
    fsLog:Debug("Friendly units table.sort() took %fms.", (stop - start) * 1000)

    return units
end

local function FriendlyUnits()
    local units = fsUnit:FriendlyUnits()

    if #units == 0 then
        return units
    end

    local sortEnabled = fsCompare:FriendlySortMode()

    if not sortEnabled then
        return units
    end

    local start = wow.GetTimePreciseSec()
    table.sort(units, fsCompare:SortFunction(units))
    local stop = wow.GetTimePreciseSec()
    fsLog:Debug("Friendly units table.sort() took %fms.", (stop - start) * 1000)

    return units
end

local function EnemyUnits()
    local units, type = fsUnit:EnemyUnits()

    if #units == 0 then
        return units, type
    end

    local sortEnabled = fsCompare:EnemySortMode()

    if not sortEnabled then
        return units, type
    end

    local start = wow.GetTimePreciseSec()
    table.sort(units, fsCompare:EnemySortFunction(units))
    local stop = wow.GetTimePreciseSec()
    fsLog:Debug("Enemy units table.sort() took %fms.", (stop - start) * 1000)

    return units, type
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
    local hit = false
    local cache = true
    local units

    if cacheEnabled and friendlyCacheValid then
        hit = true
        units = cachedFriendlyUnits
    else
        units = FriendlyUnits()
    end

    if not units or #units == 0 then
        -- try from frames but don't cache the result
        -- as frames can change without us knowing
        units = FriendlyUnitsFromFrames()
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

    return units or {}
end

---@return string[]
function M:EnemyUnits()
    local hit = false
    local units
    local unitsType

    if cacheEnabled and enemyCacheValid then
        hit = true
        units = cachedEnemyUnits
    else
        units, unitsType = EnemyUnits()
    end

    -- don't try fallback from arena frames as this seems to cause issues with erroneous units popping up
    -- so just retry EnemyUnits() on next attempt
    if cacheEnabled then
        cachedEnemyUnits = units
        -- there's no event we can use to invalidate bg units, so don't cache them
        enemyCacheValid = #units > 0 and unitsType ~= "bg"

        if hit then
            enemyCacheHits = enemyCacheHits + 1
        else
            enemyCacheMisses = enemyCacheMisses + 1
        end

        LogStatsTick()
    end

    return units or {}
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
