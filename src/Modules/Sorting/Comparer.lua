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

local orderingCache = {}

---@return { [string]: number } roleOrderLookup
---@return { [number]: number } specOrderLookup
---@return { [number]: number } classOrderLookup
local function Ordering()
    local config = addon.DB.Options.Sorting.Ordering
    local cacheKey = string.format("Tanks:%d,Healers:%d,Casters:%d,Hunters:%d,Melee:%d", config.Tanks, config.Healers, config.Casters, config.Hunters, config.Melee)
    local cached = orderingCache[cacheKey]

    if cached then
        return cached.RoleLookup, cached.SpecLookup, cached.ClassLookup
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

    orderingCache[cacheKey] = {
        RoleLookup = roleLookup,
        SpecLookup = specLookup,
        ClassLookup = classLookup,
    }

    return roleLookup, specLookup, classLookup
end

local function RoleAndClassValue(role, class)
    local roleOrderLookup, _, classOrderLookup = Ordering()
    local roleOrder = roleOrderLookup[role]

    if roleOrder then
        return roleOrder
    end

    if class then
        local classOrder = classOrderLookup[class]
        return classOrder
    end

    return nil
end

local function EmptyCompare(x, y)
    return x < y
end

local function CompareGroup(leftToken, rightToken, isArena)
    if not wow.IsInRaid() then
        -- string comparison is ok to use as party doesn't go above 1 digit
        return leftToken < rightToken
    end

    if isArena then
        local id1 = tonumber(string.sub(leftToken, 6))
        local id2 = tonumber(string.sub(rightToken, 6))

        if id1 and id2 then
            return id1 < id2
        end
    else
        -- the same way blizzard do it in CRFSort_Group
        local id1 = tonumber(string.sub(leftToken, 5))
        local id2 = tonumber(string.sub(rightToken, 5))

        if id1 and id2 then
            return id1 < id2
        end
    end

    -- the below probably isn't needed anymore
    -- fallback to a slower but more reliable comparison
    local left = tonumber(string.match(leftToken, "%d+"))
    local right = tonumber(string.match(rightToken, "%d+"))

    if left and right then
        return left < right
    end

    return leftToken < rightToken
end

local function CompareAlphabetical(leftToken, rightToken)
    local name1, name2 = wow.UnitName(leftToken), wow.UnitName(rightToken)

    if name1 and name2 then
        return name1 < name2
    end

    return CompareGroup(leftToken, rightToken, string.match(leftToken, "arena.*"))
end

local function CompareRole(leftToken, rightToken, isArena)
    local leftRole, rightRole = nil, nil
    local leftSpec, rightSpec = nil, nil
    local leftClass, rightClass = nil, nil

    if isArena then
        local leftId = tonumber(string.match(leftToken, "%d+"))
        local rightId = tonumber(string.match(rightToken, "%d+"))

        if not leftId or not rightId then
            fsLog:Error("Arena unit tokens are missing numbers.")
            return CompareGroup(leftToken, rightToken, isArena)
        end

        if wow.GetArenaOpponentSpec then
            leftSpec = wow.GetArenaOpponentSpec(leftId)
            rightSpec = wow.GetArenaOpponentSpec(rightId)
        else
            fsLog:Error("Your wow client is missing the GetArenaOpponentSpec API.")
        end

        local specError = "Failed to determine spec for arena unit %s."

        if not leftSpec then
            fsLog:Warning(specError, leftToken)
        end

        if not rightSpec then
            fsLog:Warning(specError, rightToken)
        end

        if not leftSpec or not rightSpec then
            return CompareGroup(leftToken, rightToken, isArena)
        end

        if wow.GetSpecializationInfoByID then
            leftRole = select(5, wow.GetSpecializationInfoByID(leftSpec))
            rightRole = select(5, wow.GetSpecializationInfoByID(rightSpec))
        else
            fsLog:Error("Your wow client is missing the GetSpecializationInfoByID API.")
        end

        local leftSpecInfo = specIdLookup[leftSpec]
        local rightSpecInfo = specIdLookup[rightSpec]

        leftClass = leftSpecInfo and leftSpecInfo.ClassId
        rightClass = rightSpecInfo and rightSpecInfo.ClassId
    else
        local leftGuid = wow.UnitGUID(leftToken)
        local rightGuid = wow.UnitGUID(rightToken)
        local nilGuidError = "Unable to determine unit spec for '%s' as it's guid is nil."
        local secretGuidError = "Unable to determine unit spec for '%s' as it's guid is a secret value."

        if not leftGuid then
            fsLog:Warning(nilGuidError, leftToken)
        elseif not rightGuid then
            fsLog:Warning(nilGuidError, rightToken)
        elseif wow.issecretvalue(leftGuid) then
            fsLog:Warning(secretGuidError, leftToken)
        elseif wow.issecretvalue(rightGuid) then
            fsLog:Warning(secretGuidError, rightToken)
        else
            leftSpec = fsInspector:UnitSpec(leftGuid)
            rightSpec = fsInspector:UnitSpec(rightGuid)
        end

        if wow.UnitGroupRolesAssigned then
            leftRole = wow.UnitGroupRolesAssigned(leftToken)
            rightRole = wow.UnitGroupRolesAssigned(rightToken)
        else
            fsLog:Error("Your wow client is missing the UnitGroupRolesAssigned API.")
        end

        leftClass = select(3, wow.UnitClass(leftToken))
        rightClass = select(3, wow.UnitClass(rightToken))
    end

    -- grab our ordering values
    local _, specOrderLookup, _ = Ordering()

    -- prioritise their spec information if we have it
    if leftSpec and leftSpec > 0 and rightSpec and rightSpec > 0 and leftSpec ~= rightSpec then
        local leftSpecOrder = specOrderLookup[leftSpec]
        local rightSpecOrder = specOrderLookup[rightSpec]

        if leftSpecOrder and rightSpecOrder and leftSpecOrder ~= rightSpecOrder then
            return leftSpecOrder < rightSpecOrder
        end
    end

    local roleError = "Failed to determine role for unit %s."
    local classError = "Failed to determine class for unit %s."

    if not leftRole then
        fsLog:Warning(roleError, leftToken)
    end

    if not rightRole then
        fsLog:Warning(roleError, rightToken)
    end

    if not leftClass then
        fsLog:Warning(classError, leftToken)
    end

    if not rightClass then
        fsLog:Warning(classError, rightToken)
    end

    -- check their role + class combination
    if leftRole and rightRole then
        local leftRoleOrder = RoleAndClassValue(leftRole, leftClass)
        local rightRoleOrder = RoleAndClassValue(rightRole, rightClass)

        if leftRoleOrder and rightRoleOrder and leftRoleOrder ~= rightRoleOrder then
            return leftRoleOrder < rightRoleOrder
        end
    end

    -- check the class on its own
    if leftClass and rightClass and leftClass ~= rightClass then
        return leftClass < rightClass
    end

    -- if they are the same role, class, and spec, then fallback to group sort
    return CompareGroup(leftToken, rightToken, isArena)
end

---Returns true if the specified token is ordered after the mid point of player units.
---Pet units are ignored.
---@param token string
---@param context table
---@return boolean
local function CompareMiddle(token, context)
    local index = context.IndexLookup[token]

    if not index then
        return false
    end

    return index > context.Mid
end

---Returns true if the left token should be ordered before the right token.
---middleContext is required if playerSortMode == Middle.
---@param leftToken string
---@param rightToken string
---@param playerSortMode? string
---@param groupSortMode? string
---@param reverse boolean?
---@param middleContext table?
---@return boolean
local function Compare(leftToken, rightToken, playerSortMode, groupSortMode, reverse, middleContext)
    if wow.UnitExists(leftToken) and not wow.UnitExists(rightToken) then
        return true
    elseif wow.UnitExists(rightToken) and not wow.UnitExists(leftToken) then
        return false
    end

    if fsUnit:IsPet(leftToken) or fsUnit:IsPet(rightToken) then
        -- place players before pets
        if not fsUnit:IsPet(leftToken) then
            return true
        end

        if not fsUnit:IsPet(rightToken) then
            return false
        end

        -- both are pets, compare their parent
        -- remove "pet" from the token to get the parent
        local leftTokenParent = leftToken == "pet" and "player" or string.gsub(leftToken, "pet", "")
        local rightTokenParent = rightToken == "pet" and "player" or string.gsub(rightToken, "pet", "")

        return Compare(leftTokenParent, rightTokenParent, playerSortMode, groupSortMode, reverse, middleContext)
    end

    if playerSortMode and playerSortMode ~= "" then
        if fsUnit:IsPlayer(leftToken) then
            if playerSortMode == fsConfig.PlayerSortMode.Hidden then
                return false
            elseif playerSortMode == fsConfig.PlayerSortMode.Middle then
                assert(middleContext ~= nil)
                return CompareMiddle(rightToken, middleContext)
            else
                return playerSortMode == fsConfig.PlayerSortMode.Top
            end
        end

        if fsUnit:IsPlayer(rightToken) then
            if playerSortMode == fsConfig.PlayerSortMode.Hidden then
                return true
            elseif playerSortMode == fsConfig.PlayerSortMode.Middle then
                assert(middleContext ~= nil)
                return not CompareMiddle(leftToken, middleContext)
            else
                return playerSortMode == fsConfig.PlayerSortMode.Bottom
            end
        end
    end

    if reverse then
        leftToken, rightToken = rightToken, leftToken
    end

    if groupSortMode == fsConfig.GroupSortMode.Group then
        return CompareGroup(leftToken, rightToken)
    elseif groupSortMode == fsConfig.GroupSortMode.Role then
        return CompareRole(leftToken, rightToken)
    elseif groupSortMode == fsConfig.GroupSortMode.Alphabetical then
        return CompareAlphabetical(leftToken, rightToken)
    end

    return leftToken < rightToken
end

---Returns true if the left token should be ordered before the right token.
---@param leftToken string
---@param rightToken string
---@param groupSortMode? string
---@param reverse boolean?
---@return boolean
local function EnemyCompare(leftToken, rightToken, groupSortMode, reverse)
    -- used to have UnitExists() checks here
    -- but it returns false in the starting room
    -- it also seemed to bring some problems when a new round starts in shuffle
    -- so leaving it out for now
    if fsUnit:IsPet(leftToken) or fsUnit:IsPet(rightToken) then
        -- place player before pets
        if not fsUnit:IsPet(leftToken) then
            return true
        end
        if not fsUnit:IsPet(rightToken) then
            return false
        end

        -- both are pets, compare their parent
        local leftTokenParent = string.gsub(leftToken, "pet", "")
        local rightTokenParent = string.gsub(rightToken, "pet", "")

        return EnemyCompare(leftTokenParent, rightTokenParent, groupSortMode, reverse)
    end

    if reverse then
        leftToken, rightToken = rightToken, leftToken
    end

    if groupSortMode == fsConfig.GroupSortMode.Group then
        return CompareGroup(leftToken, rightToken, true)
    end

    local inInstance, instanceType = wow.IsInInstance()

    if groupSortMode == fsConfig.GroupSortMode.Role and inInstance and instanceType == "arena" then
        return CompareRole(leftToken, rightToken, true)
    end

    return leftToken < rightToken
end

---Returns a function that accepts two parameters of unit tokens and returns true if the left token should be ordered before the right.
---Sorting is based on the current instance and configured options.
---@param units string[]? the set of all unit tokens, only required if the player sort mode is "Middle"
---@return function sort
function M:SortFunction(units)
    local enabled, playerSortMode, groupSortMode, reverse = M:FriendlySortMode()

    if not enabled then
        return EmptyCompare
    end

    if playerSortMode ~= fsConfig.PlayerSortMode.Middle then
        return function(x, y)
            return Compare(x, y, playerSortMode, groupSortMode, reverse)
        end
    end

    units = units or fsUnit:FriendlyUnits()

    -- we need to pre-sort to determine where the middle actually is
    -- making use of Enumerable:OrderBy() so we don't re-order the original array
    units = fsEnumerable
        :From(units)
        :Where(function(x)
            return not wow.UnitIsUnit(x, "player")
        end)
        :OrderBy(function(x, y)
            return Compare(x, y, fsConfig.PlayerSortMode.Top, groupSortMode, reverse)
        end)
        :ToTable()

    -- prepare data used for the middle sort comparator
    local index = {}
    local notPets = {}

    for _, unit in ipairs(units) do
        if not fsUnit:IsPet(unit) and wow.UnitExists(unit) then
            notPets[#notPets + 1] = unit
            index[unit] = #notPets
        end
    end

    local middleContext = {
        IndexLookup = index,
        Mid = math.floor(#notPets / 2),
    }

    return function(x, y)
        return Compare(x, y, playerSortMode, groupSortMode, reverse, middleContext)
    end
end

---Returns a function that accepts two parameters of unit tokens and returns true if the left token should be ordered before the right.
---@return function sort
function M:EnemySortFunction()
    local enabled, groupSortMode, reverse = M:EnemySortMode()

    if not enabled then
        return EmptyCompare
    end

    return function(x, y)
        return EnemyCompare(x, y, groupSortMode, reverse)
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
