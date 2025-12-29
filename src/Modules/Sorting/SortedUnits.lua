---@type string, Addon
local _, addon = ...
local fsCompare = addon.Modules.Sorting.Comparer
local fsFrame = addon.WoW.Frame
local fsUnit = addon.WoW.Unit
local fsEnumerable = addon.Collections.Enumerable
local fsInspector = addon.Modules.Inspector
local fsConfig = addon.Configuration
local fsSortedFrames = addon.Modules.Sorting.SortedFrames
local fsLog = addon.Logging.Log
local wow = addon.WoW.Api
local wowEx = addon.WoW.WowEx
local capabilities = addon.WoW.Capabilities
local events = addon.WoW.Events

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

-- the number of times to cycle/shift dps units down
local cycleFriendlyDps = 0
local cycleEnemyDps = 0

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

local function ArenaUnits()
    local units = fsUnit:ArenaUnits()

    if #units == 0 then
        return units
    end

    local sortEnabled = fsCompare:EnemySortMode()

    if not sortEnabled then
        return units
    end

    local start = wow.GetTimePreciseSec()
    table.sort(units, fsCompare:EnemySortFunction(units))
    local stop = wow.GetTimePreciseSec()
    fsLog:Debug("Arena units table.sort() took %fms.", (stop - start) * 1000)

    return units
end

local function CycleDps(units, isFriendly, cycles)
    cycles = tonumber(cycles) or 1
    if cycles <= 0 then
        return
    end

    if isFriendly and not capabilities.HasRoleAssignments() then
        return
    end

    if not isFriendly and (not capabilities.HasEnemySpecSupport() or not wow.GetSpecializationInfoByID) then
        return
    end

    -- collect indices of DPS units (in current order)
    local dpsIdx = {}
    for i = 1, #units do
        local unit = units[i]
        local role

        if isFriendly then
            role = wow.UnitGroupRolesAssigned(unit)
        else
            local specId = fsInspector:EnemyUnitSpec(unit)
            if specId then
                -- GetSpecializationInfoByID returns role as 5th return value
                local _, _, _, _, specRole = wow.GetSpecializationInfoByID(specId)
                role = specRole
            end
        end

        if role == wowEx.Role.Dps then
            dpsIdx[#dpsIdx + 1] = i
        end
    end

    local n = #dpsIdx
    if n <= 1 then
        return
    end

    -- reduce cycles to the minimum required rotations
    cycles = cycles % n
    if cycles == 0 then
        return
    end

    -- snapshot current DPS units in order
    local temp = {}
    for i = 1, n do
        temp[i] = units[dpsIdx[i]]
    end

    -- rotate DPS units within their own slots
    for i = 1, n do
        -- move backwards by `cycles`
        local sourceIndex = i - cycles

        -- wrap around if we go below 1
        while sourceIndex <= 0 do
            sourceIndex = sourceIndex + n
        end

        units[dpsIdx[i]] = temp[sourceIndex]
    end
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

        if cycleFriendlyDps > 0 and #units > 0 then
            CycleDps(units, true, cycleFriendlyDps)
        end
    end

    if not units or #units == 0 then
        -- try from frames but don't cache the result
        -- as frames can change without us knowing
        units = FriendlyUnitsFromFrames()
        cache = false

        if cycleFriendlyDps > 0 and #units > 0 then
            CycleDps(units, true, cycleFriendlyDps)
        end
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
function M:ArenaUnits()
    local hit = false
    local units

    if cacheEnabled and enemyCacheValid then
        hit = true
        units = cachedEnemyUnits
    else
        units = ArenaUnits()

        if cycleEnemyDps > 0 and #units > 0 then
            CycleDps(units, false, cycleEnemyDps)
        end
    end

    -- don't try fallback from arena frames as this seems to cause issues with erroneous units popping up
    -- so just retry EnemyUnits() on next attempt
    if cacheEnabled then
        cachedEnemyUnits = units
        enemyCacheValid = #units > 0

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

function M:CycleFriendlyDps(cycles)
    if type(cycles) == "number" then
        cycleFriendlyDps = cycleFriendlyDps + cycles
    else
        cycleFriendlyDps = cycleFriendlyDps + 1
    end

    InvalidateFriendlyCache()
end

function M:CycleEnemyDps(cycles)
    if type(cycles) == "number" then
        cycleEnemyDps = cycleEnemyDps + cycles
    else
        cycleEnemyDps = cycleEnemyDps + 1
    end

    InvalidateEnemyCache()
end

function M:ResetFriendlyDpsCycles()
    cycleFriendlyDps = 0
    InvalidateFriendlyCache()
end

function M:ResetEnemyDpsCycles()
    cycleEnemyDps = 0
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
    elseif event == events.PLAYER_ENTERING_WORLD then
        -- reset cycles after loading screen
        cycleFriendlyDps = 0
        cycleEnemyDps = 0
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
