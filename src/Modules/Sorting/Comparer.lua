---@type string, Addon
local _, addon = ...
local wow = addon.WoW.Api
local fsUnit = addon.WoW.Unit
local fsMath = addon.Numerics.Math
local fsEnumerable = addon.Collections.Enumerable
local fsConfig = addon.Configuration
local fsInspector = addon.Modules.Inspector
local fsLog = addon.Logging.Log
local fuzzyDecimalPlaces = 0
---@return { [number]: SpecInfo }
local specIdLookup = fsEnumerable:From(fsConfig.Specs.Specs):ToLookup(function(item)
    return item.SpecId
end, function(item)
    return item
end)

---@class Comparer
local M = {}
addon.Modules.Sorting.Comparer = M

local warnedAbout = {}
local cachedRoleLookup, cachedSpecLookup, cachedClassLookup
local cachedConfigSnapshot

local function SnapshotOrderingConfig(config)
    return table.concat({
        config.Tanks,
        config.Healers,
        config.Casters,
        config.Hunters,
        config.Melee,
    }, ":")
end

---@return { [string]: number } roleOrderLookup
---@return { [number]: number } specOrderLookup
---@return { [number]: number } classOrderLookup
local function Ordering()
    local config = addon.DB.Options.Sorting.Ordering
    local currentSnapshot = SnapshotOrderingConfig(config)

    if cachedConfigSnapshot == currentSnapshot and cachedRoleLookup then
        return cachedRoleLookup, cachedSpecLookup, cachedClassLookup
    end

    local specs = fsConfig.Specs
    local specOrdering = fsEnumerable:New()
    local roleLookup = {}
    local ordering = {}

    ordering[config.Tanks] = "Tanks"
    ordering[config.Healers] = "Healers"
    ordering[config.Casters] = "Casters"
    ordering[config.Hunters] = "Hunters"
    ordering[config.Melee] = "Melee"

    for order, type in pairs(ordering) do
        if type == "Tanks" then
            local tanks = fsEnumerable:From(specs.Specs):Where(function(item)
                return item.Type == specs.Type.Tank
            end)

            specOrdering = specOrdering:Concat(tanks)
            roleLookup["TANK"] = order
        elseif type == "Healers" then
            local healers = fsEnumerable:From(specs.Specs):Where(function(item)
                return item.Type == specs.Type.Healer
            end)

            specOrdering = specOrdering:Concat(healers)
            roleLookup["HEALER"] = order
        elseif type == "Casters" then
            local casters = fsEnumerable:From(specs.Specs):Where(function(item)
                return item.Type == specs.Type.Caster
            end)

            specOrdering = specOrdering:Concat(casters)
        elseif type == "Hunters" then
            local hunters = fsEnumerable:From(specs.Specs):Where(function(item)
                return item.Type == specs.Type.Hunter
            end)

            specOrdering = specOrdering:Concat(hunters)
        elseif type == "Melee" then
            local melee = fsEnumerable:From(specs.Specs):Where(function(item)
                return item.Type == specs.Type.Melee
            end)

            specOrdering = specOrdering:Concat(melee)
        end
    end

    local specLookup = specOrdering:ToLookup(function(item, _)
        return item.SpecId
    end, function(_, index)
        return index
    end)

    local classLookup = fsEnumerable:From(specs.Specs):ToLookup(function(item)
        return item.ClassId
    end, function(item)
        if item.Type == specs.Type.Tank then
            return config.Tanks
        elseif item.Type == specs.Type.Healer then
            return config.Healers
        elseif item.Type == specs.Type.Hunter then
            return config.Hunters
        elseif item.Type == specs.Type.Caster then
            return config.Casters
        elseif item.Type == specs.Type.Melee then
            return config.Melee
        else
            return 99
        end
    end)

    cachedConfigSnapshot = currentSnapshot
    cachedRoleLookup = roleLookup
    cachedSpecLookup = specLookup
    cachedClassLookup = classLookup

    return roleLookup, specLookup, classLookup
end

local function PrecomputeUnitMetadata(units)
    local meta = {}

    if #units == 0 then
        return meta
    end

    local start = wow.GetTimePreciseSec()
    local inRaid = wow.IsInRaid()
    local trim = inRaid and 5 or 6
    local roleOrderLookup, specOrderLookup, classOrderLookup = Ordering()

    meta.RoleOrderLookup = roleOrderLookup
    meta.SpecOrderLookup = specOrderLookup
    meta.ClassOrderLookup = classOrderLookup

    if not wow.GetArenaOpponentSpec and not warnedAbout["GetArenaOpponentSpec"] then
        fsLog:Error("Your wow client is missing the GetArenaOpponentSpec API.")
        warnedAbout["GetArenaOpponentSpec"] = true
    end

    if not wow.GetSpecializationInfoByID and not warnedAbout["GetSpecializationInfoByID"] then
        fsLog:Error("Your wow client is missing the GetSpecializationInfoByID API.")
        warnedAbout["GetSpecializationInfoByID"] = true
    end

    if not wow.UnitGroupRolesAssigned and not warnedAbout["UnitGroupRolesAssigned"] then
        fsLog:Error("Your wow client is missing the UnitGroupRolesAssigned API.")
        warnedAbout["UnitGroupRolesAssigned"] = true
    end

    for _, unit in ipairs(units) do
        local data = {}
        meta[unit] = data

        data.IsPet = fsUnit:IsPet(unit)
        data.IsArena = unit:sub(1, 5) == "arena"
        data.IsPlayer = not data.IsPet and fsUnit:IsPlayer(unit)

        if data.IsArena then
            data.Exists = fsUnit:ArenaUnitExists(unit)
            data.UnitNumber = tonumber(string.sub(unit, 6))

            data.SpecId = wow.GetArenaOpponentSpec and wow.GetArenaOpponentSpec(data.UnitNumber)
            data.Role = wow.GetSpecializationInfoByID and select(5, wow.GetSpecializationInfoByID(data.SpecId))

            local specInfo = data.SpecId and specIdLookup[data.SpecId]
            data.ClassId = specInfo and specInfo.ClassId
        else
            data.Exists = wow.UnitExists(unit)
            data.Name = wow.UnitName and wow.UnitName(unit)

            if not data.IsPet then
                data.UnitNumber = tonumber(string.sub(unit, trim))
                data.Role = wow.UnitGroupRolesAssigned and wow.UnitGroupRolesAssigned(unit)
                data.Guid = wow.UnitGUID and wow.UnitGUID(unit)
                data.ClassId = wow.UnitClass and select(3, wow.UnitClass(unit))

                if not data.Guid then
                    fsLog:Warning("Unable to determine unit spec for '%s' as it's guid is nil.", unit)
                elseif wow.issecretvalue(data.Guid) then
                    fsLog:Warning("Unable to determine unit spec for '%s' as it's guid is a secret value.", unit)
                else
                    data.SpecId = fsInspector:UnitSpec(data.Guid)
                end
            end
        end

        if not data.UnitNumber then
            -- fallback to a slower but more reliable method
            -- mostly for pets
            data.UnitNumber = tonumber(string.match(unit, "%d+"))
        end

        if not data.IsPet then
            if not data.Role then
                fsLog:Warning("Failed to determine role for unit %s.", unit)
            end
            if not data.ClassId then
                fsLog:Warning("Failed to determine class for unit %s.", unit)
            end
        end
    end

    local stop = wow.GetTimePreciseSec()
    fsLog:Debug("Pre-computing unit metadata took %fms for %d units.", (stop - start) * 1000, #units)

    return meta
end

local function RoleAndClassValue(role, class, meta)
    local roleOrder = meta.RoleOrderLookup[role]

    if roleOrder then
        return roleOrder
    end

    if class then
        local classOrder = meta.ClassOrderLookup[class]
        return classOrder
    end

    return nil
end

local function EmptyCompare(x, y)
    return x < y
end

local function CompareGroup(leftToken, rightToken, meta)
    local leftMeta, rightMeta = meta[leftToken], meta[rightToken]

    assert(leftMeta)
    assert(rightMeta)

    if leftMeta.UnitNumber and rightMeta.UnitNumber then
        return leftMeta.UnitNumber < rightMeta.UnitNumber
    end

    -- could be "player" or "pet"
    return leftToken < rightToken
end

local function CompareAlphabetical(leftToken, rightToken, meta)
    local leftMeta, rightMeta = meta[leftToken], meta[rightToken]

    assert(leftMeta)
    assert(rightMeta)

    local leftName, rightName = leftMeta.Name, rightMeta.Name

    if leftName and rightName then
        return leftName < rightName
    end

    return CompareGroup(leftToken, rightToken, meta)
end

local function CompareRole(leftToken, rightToken, meta)
    local leftMeta, rightMeta = meta[leftToken], meta[rightToken]
    local leftRole, rightRole = nil, nil
    local leftSpec, rightSpec = nil, nil
    local leftClass, rightClass = nil, nil

    assert(leftMeta)
    assert(rightMeta)

    leftSpec = leftMeta.SpecId
    rightSpec = rightMeta.SpecId

    leftRole = leftMeta.Role
    rightRole = rightMeta.Role

    leftClass = leftMeta.ClassId
    rightClass = rightMeta.ClassId

    -- prioritise their spec information if we have it
    if leftSpec and leftSpec > 0 and rightSpec and rightSpec > 0 and leftSpec ~= rightSpec then
        local leftSpecOrder = meta.SpecOrderLookup[leftSpec]
        local rightSpecOrder = meta.SpecOrderLookup[rightSpec]

        if leftSpecOrder and rightSpecOrder and leftSpecOrder ~= rightSpecOrder then
            return leftSpecOrder < rightSpecOrder
        end
    end

    -- check their role + class combination
    if leftRole and rightRole then
        local leftRoleOrder = RoleAndClassValue(leftRole, leftClass, meta)
        local rightRoleOrder = RoleAndClassValue(rightRole, rightClass, meta)

        if leftRoleOrder and rightRoleOrder and leftRoleOrder ~= rightRoleOrder then
            return leftRoleOrder < rightRoleOrder
        end
    end

    -- check the class on its own
    if leftClass and rightClass and leftClass ~= rightClass then
        return leftClass < rightClass
    end

    -- if they are the same role, class, and spec, then fallback to group sort
    return CompareGroup(leftToken, rightToken, meta)
end

---Returns true if the specified token is ordered after the mid point of player units.
---Pet units are ignored.
---@param token string
---@param meta table
---@return boolean
local function CompareMiddle(token, meta)
    local index = meta.IndexLookup[token]

    if not index then
        return false
    end

    return index > meta.Mid
end

---Returns true if the left token should be ordered before the right token.
---@param leftToken string
---@param rightToken string
---@param playerSortMode? string
---@param groupSortMode? string
---@param reverse boolean?
---@param meta table
---@return boolean
local function Compare(leftToken, rightToken, playerSortMode, groupSortMode, reverse, meta)
    local leftMeta, rightMeta = meta[leftToken], meta[rightToken]

    assert(leftMeta)
    assert(rightMeta)

    if leftMeta.Exists and not rightMeta.Exists then
        return true
    elseif not leftMeta.Exists and rightMeta.Exists then
        return false
    end

    if leftMeta.IsPet or rightMeta.IsPet then
        -- place players before pets
        if not leftMeta.IsPet then
            return true
        end

        if not rightMeta.IsPet then
            return false
        end

        -- both are pets, compare their parent
        local leftTokenParent = fsUnit:PetParent(leftToken)
        local rightTokenParent = fsUnit:PetParent(rightToken)

        return Compare(leftTokenParent, rightTokenParent, playerSortMode, groupSortMode, reverse, meta)
    end

    if playerSortMode and playerSortMode ~= "" then
        if leftMeta.IsPlayer then
            if playerSortMode == fsConfig.PlayerSortMode.Hidden then
                return false
            elseif playerSortMode == fsConfig.PlayerSortMode.Middle then
                return CompareMiddle(rightToken, meta)
            else
                return playerSortMode == fsConfig.PlayerSortMode.Top
            end
        end

        if rightMeta.IsPlayer then
            if playerSortMode == fsConfig.PlayerSortMode.Hidden then
                return true
            elseif playerSortMode == fsConfig.PlayerSortMode.Middle then
                return not CompareMiddle(leftToken, meta)
            else
                return playerSortMode == fsConfig.PlayerSortMode.Bottom
            end
        end
    end

    if reverse then
        leftToken, rightToken = rightToken, leftToken
    end

    if groupSortMode == fsConfig.GroupSortMode.Group then
        return CompareGroup(leftToken, rightToken, meta)
    elseif groupSortMode == fsConfig.GroupSortMode.Role then
        return CompareRole(leftToken, rightToken, meta)
    elseif groupSortMode == fsConfig.GroupSortMode.Alphabetical then
        return CompareAlphabetical(leftToken, rightToken, meta)
    end

    return leftToken < rightToken
end

---Returns true if the left token should be ordered before the right token.
---@param leftToken string
---@param rightToken string
---@param groupSortMode? string
---@param reverse boolean?
---@param meta table
---@return boolean
local function EnemyCompare(leftToken, rightToken, groupSortMode, reverse, meta)
    local leftMeta, rightMeta = meta[leftToken], meta[rightToken]

    assert(leftMeta)
    assert(rightMeta)

    -- used to have UnitExists() checks here
    -- but it returns false in the starting room
    -- it also seemed to bring some problems when a new round starts in shuffle
    -- so leaving it out for now
    if leftMeta.IsPet or rightMeta.IsPet then
        -- place player before pets
        if not leftMeta.IsPet then
            return true
        end
        if not rightMeta.IsPet then
            return false
        end

        -- both are pets, compare their parent
        local leftTokenParent = fsUnit:PetParent(leftToken)
        local rightTokenParent = fsUnit:PetParent(rightToken)

        return EnemyCompare(leftTokenParent, rightTokenParent, groupSortMode, reverse, meta)
    end

    if reverse then
        leftToken, rightToken = rightToken, leftToken
    end

    if groupSortMode == fsConfig.GroupSortMode.Group then
        return CompareGroup(leftToken, rightToken, meta)
    end

    local inInstance, instanceType = wow.IsInInstance()

    if groupSortMode == fsConfig.GroupSortMode.Role and inInstance and instanceType == "arena" then
        return CompareRole(leftToken, rightToken, meta)
    end

    return leftToken < rightToken
end

---Returns a function that accepts two parameters of unit tokens and returns true if the left token should be ordered before the right.
---Sorting is based on the current instance and configured options.
---@param units string[]? the unit tokens that will be sorted. required for performance reasons.
---@return function sort
function M:SortFunction(units)
    local enabled, playerSortMode, groupSortMode, reverse = M:FriendlySortMode()

    if not enabled then
        return EmptyCompare
    end

    units = units or fsUnit:FriendlyUnits()
    local meta = PrecomputeUnitMetadata(units)

    if playerSortMode ~= fsConfig.PlayerSortMode.Middle then
        return function(x, y)
            return Compare(x, y, playerSortMode, groupSortMode, reverse, meta)
        end
    end

    -- we need to pre-sort to determine where the middle actually is
    -- making use of Enumerable:OrderBy() so we don't re-order the original array
    units = fsEnumerable
        :From(units)
        :Where(function(x)
            return not wow.UnitIsUnit(x, "player")
        end)
        :OrderBy(function(x, y)
            return Compare(x, y, fsConfig.PlayerSortMode.Top, groupSortMode, reverse, meta)
        end)
        :ToTable()

    -- prepare data used for the middle sort comparator
    local index = {}
    local notPets = {}

    for _, unit in ipairs(units) do
        local unitMeta = meta[unit]

        if not unitMeta.IsPet and unitMeta.Exists then
            notPets[#notPets + 1] = unit
            index[unit] = #notPets
        end
    end

    meta.IndexLookup = index
    meta.Mid = math.floor(#notPets / 2)

    return function(x, y)
        return Compare(x, y, playerSortMode, groupSortMode, reverse, meta)
    end
end

---Returns a function that accepts two parameters of unit tokens and returns true if the left token should be ordered before the right.
---@param units string[] the unit tokens that will be sorted. required for performance reasons.
---@return function sort
function M:EnemySortFunction(units)
    local enabled, groupSortMode, reverse = M:EnemySortMode()

    if not enabled then
        return EmptyCompare
    end

    units = units or fsUnit:EnemyUnits()

    local meta = PrecomputeUnitMetadata(units)
    return function(x, y)
        return EnemyCompare(x, y, groupSortMode, reverse, meta)
    end
end

---Returns the sort mode from the configured options for the current instance.
---@return boolean enabled whether sorting is enabled.
---@return string? playerMode the player sort mode.
---@return string? groupMode the group sort mode.
---@return boolean? reverse whether the sorting is reversed.
function M:FriendlySortMode()
    local inInstance, instanceType = wow.IsInInstance()
    local config = addon.DB.Options.Sorting

    if inInstance and instanceType == "arena" then
        local instanceSize = wow.GetNumGroupMembers()
        local arena = instanceSize == 2 and config.Arena.Twos or config.Arena.Default

        return arena.Enabled, arena.PlayerSortMode, arena.GroupSortMode, arena.Reverse
    elseif inInstance and (instanceType == "party" or instanceType == "scenario") then
        -- scenario = delves
        return config.Dungeon.Enabled, config.Dungeon.PlayerSortMode, config.Dungeon.GroupSortMode, config.Dungeon.Reverse
    elseif inInstance and (instanceType == "raid" or instanceType == "pvp") then
        return config.Raid.Enabled, config.Raid.PlayerSortMode, config.Raid.GroupSortMode, config.Raid.Reverse
    end

    -- default to world rules for all other instance types
    return config.World.Enabled, config.World.PlayerSortMode, config.World.GroupSortMode, config.World.Reverse
end

---Returns the sort mode from the configured options for the current instance.
---@return boolean enabled whether sorting is enabled.
---@return string? groupMode the group sort mode.
---@return boolean? reverse whether the sorting is reversed.
function M:EnemySortMode()
    local config = addon.DB.Options.Sorting.EnemyArena

    return config.Enabled, config.GroupSortMode, config.Reverse
end

---Returns true if the left frame is "earlier" than the right frame.
---Earlier = more top left
---Fuzziness provides some leeway when comparing the top and left values.
---@param leftFrame table a wow frame
---@param rightFrame table a wow frame
---@return boolean
function M:CompareTopLeftFuzzy(leftFrame, rightFrame)
    if not leftFrame then
        return false
    end
    if not rightFrame then
        return true
    end

    local leftY = fsMath:Round(leftFrame:GetTop(), fuzzyDecimalPlaces)
    local rightY = fsMath:Round(rightFrame:GetTop(), fuzzyDecimalPlaces)

    if leftY ~= rightY then
        return leftY > rightY
    end

    local leftX = fsMath:Round(leftFrame:GetLeft(), fuzzyDecimalPlaces)
    local rightX = fsMath:Round(rightFrame:GetLeft(), fuzzyDecimalPlaces)

    return leftX < rightX
end

---Returns true if the left frame is "earlier" than the right frame.
---Earlier = more left top
---Fuzziness provides some leeway when comparing the top and left values.
---@param leftFrame table a wow frame
---@param rightFrame table a wow frame
---@return boolean
function M:CompareLeftTopFuzzy(leftFrame, rightFrame)
    if not leftFrame then
        return false
    end
    if not rightFrame then
        return true
    end

    local leftX = fsMath:Round(leftFrame:GetLeft(), fuzzyDecimalPlaces)
    local rightX = fsMath:Round(rightFrame:GetLeft(), fuzzyDecimalPlaces)

    if leftX ~= rightX then
        return leftX < rightX
    end

    local leftY = fsMath:Round(leftFrame:GetTop(), fuzzyDecimalPlaces)
    local rightY = fsMath:Round(rightFrame:GetTop(), fuzzyDecimalPlaces)

    return leftY > rightY
end

---Returns true if the left frame is "earlier" than the right frame.
---Earlier = more top right
---Fuzziness provides some leeway when comparing the top and left values.
---@param leftFrame table a wow frame
---@param rightFrame table a wow frame
---@return boolean
function M:CompareTopRightFuzzy(leftFrame, rightFrame)
    if not leftFrame then
        return false
    end
    if not rightFrame then
        return true
    end

    local leftY = fsMath:Round(leftFrame:GetTop(), fuzzyDecimalPlaces)
    local rightY = fsMath:Round(rightFrame:GetTop(), fuzzyDecimalPlaces)

    if leftY ~= rightY then
        return leftY > rightY
    end

    local leftX = fsMath:Round(leftFrame:GetLeft(), fuzzyDecimalPlaces)
    local rightX = fsMath:Round(rightFrame:GetLeft(), fuzzyDecimalPlaces)

    return leftX > rightX
end

---Returns true if the left frame is "earlier" than the right frame.
---Earlier = more bottom left
---Fuzziness provides some leeway when comparing the top and left values.
---@param leftFrame table a wow frame
---@param rightFrame table a wow frame
---@return boolean
function M:CompareBottomLeftFuzzy(leftFrame, rightFrame)
    if not leftFrame then
        return false
    end
    if not rightFrame then
        return true
    end

    local leftY = fsMath:Round(leftFrame:GetBottom(), fuzzyDecimalPlaces)
    local rightY = fsMath:Round(rightFrame:GetBottom(), fuzzyDecimalPlaces)

    if leftY ~= rightY then
        return leftY < rightY
    end

    local leftX = fsMath:Round(leftFrame:GetLeft(), fuzzyDecimalPlaces)
    local rightX = fsMath:Round(rightFrame:GetLeft(), fuzzyDecimalPlaces)

    return leftX < rightX
end
