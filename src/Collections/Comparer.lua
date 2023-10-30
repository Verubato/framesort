---@type string, Addon
local _, addon = ...
local wow = addon.WoW.Api
local fsUnit = addon.WoW.Unit
local fsMath = addon.Numerics.Math
local fsEnumerable = addon.Collections.Enumerable
local fsConfig = addon.Configuration
local fuzzyDecimalPlaces = 0
local roleOrdering = {
    -- tank > healer > dps
    [fsConfig.RoleOrdering.TankHealerDps] = { MAINTANK = 1, MAINASSIST = 2, TANK = 3, HEALER = 4, DAMAGER = 5, NONE = 6 },
    -- healer > tank > dps
    [fsConfig.RoleOrdering.HealerTankDps] = { HEALER = 1, MAINTANK = 2, MAINASSIST = 3, TANK = 4, DAMAGER = 5, NONE = 6 },
    -- healer > dps > tank
    [fsConfig.RoleOrdering.HealerDpsTank] = { HEALER = 1, DAMAGER = 2, MAINTANK = 3, MAINASSIST = 4, TANK = 5, NONE = 6 },
}
---@class Comparer
local M = {}
addon.Collections.Comparer = M

local function EmptyCompare(x, y)
    return x < y
end

local function CompareAlphabetical(leftToken, rightToken)
    local name1, name2 = wow.UnitName(leftToken), wow.UnitName(rightToken)
    if name1 and name2 then
        return name1 < name2
    end

    return leftToken < rightToken
end

local function CompareGroup(leftToken, rightToken)
    local leftStr = string.match(leftToken, "%d+")
    local rightStr = string.match(rightToken, "%d+")

    if not leftStr or not rightStr then
        return leftToken < rightToken
    end

    local leftNumber = tonumber(leftStr)
    local rightNumber = tonumber(rightStr)

    return leftNumber < rightNumber
end

local function CompareRole(leftToken, rightToken)
    local isArena = string.match(leftToken, "arena")
    local leftRole, rightRole = nil, nil

    if isArena then
        local leftStr = string.match(leftToken, "%d+")
        local rightStr = string.match(rightToken, "%d+")

        if not leftStr or not rightStr then
            return leftToken < rightToken
        end

        local leftNumber = tonumber(leftStr)
        local rightNumber = tonumber(rightStr)

        if not leftNumber or not rightNumber then
            return leftToken < rightToken
        end

        local leftSpecId = wow.GetArenaOpponentSpec(leftNumber)
        local rightSpecId = wow.GetArenaOpponentSpec(rightNumber)

        if leftSpecId and rightSpecId then
            leftRole = select(5, wow.GetSpecializationInfoByID(leftSpecId))
            rightRole = select(5, wow.GetSpecializationInfoByID(rightSpecId))
        end
    else
        local leftId, rightId = wow.UnitInRaid(leftToken), wow.UnitInRaid(rightToken)

        if leftId then
            leftRole = select(12, wow.GetRaidRosterInfo(leftId))
        end

        if rightId then
            rightRole = select(12, wow.GetRaidRosterInfo(rightId))
        end

        leftRole = leftRole or wow.UnitGroupRolesAssigned(leftToken)
        rightRole = rightRole or wow.UnitGroupRolesAssigned(rightToken)
    end

    if leftRole and rightRole then
        local roleValues = roleOrdering[addon.DB.Options.Sorting.RoleOrdering] or roleOrdering[1]
        local leftValue, rightValue = roleValues[leftRole], roleValues[rightRole]
        if leftValue ~= rightValue then
            return leftValue < rightValue
        end
    end

    return leftToken < rightToken
end

---Returns true if the specified token is ordered after the mid point of player units.
---Pet units are ignored.
---@param token string
---@param sortedUnits table
---@return boolean
local function CompareMiddle(token, sortedUnits)
    local notPets = fsEnumerable
        :From(sortedUnits)
        :Where(function(unit) return not fsUnit:IsPet(unit) and wow.UnitExists(unit) end)
        :ToTable()

    -- index of the token we are comparing with
    local index = fsEnumerable
        :From(notPets)
        :IndexOf(token)

    -- most likely a non-existant unit
    if not index then
        return false
    end

    local mid = math.floor(#notPets / 2)
    return index > mid
end

---Returns true if the left token should be ordered before the right token.
---preSortedUnits is required if playerSortMode == Middle.
---@param leftToken string
---@param rightToken string
---@param playerSortMode? string
---@param groupSortMode? string
---@param reverse boolean?
---@param preSortedUnits table?
---@return boolean
local function Compare(leftToken, rightToken, playerSortMode, groupSortMode, reverse, preSortedUnits)
    -- if not in a group, we might be in test mode
    if wow.IsInGroup() then
        if not wow.UnitExists(leftToken) then
            return false
        end
        if not wow.UnitExists(rightToken) then
            return true
        end
    end

    if fsUnit:IsPet(leftToken) or fsUnit:IsPet(rightToken) then
        -- place player before pets
        if not fsUnit:IsPet(leftToken) then return true end
        if not fsUnit:IsPet(rightToken) then return false end

        -- both are pets, compare their parent
        local leftTokenParent = string.gsub(leftToken, "pet", "")
        local rightTokenParent = string.gsub(rightToken, "pet", "")

        return Compare(leftTokenParent, rightTokenParent, playerSortMode, groupSortMode, reverse, preSortedUnits)
    end

    if playerSortMode and playerSortMode ~= "" then
        if leftToken == "player" or wow.UnitIsUnit(leftToken, "player") then
            if playerSortMode == fsConfig.PlayerSortMode.Hidden then
                return false
            elseif playerSortMode == fsConfig.PlayerSortMode.Middle then
                assert(preSortedUnits ~= nil)
                return CompareMiddle(rightToken, preSortedUnits)
            else
                return playerSortMode == fsConfig.PlayerSortMode.Top
            end
        end

        if rightToken == "player" or wow.UnitIsUnit(rightToken, "player") then
            if playerSortMode == fsConfig.PlayerSortMode.Hidden then
                return true
            elseif playerSortMode == fsConfig.PlayerSortMode.Middle then
                assert(preSortedUnits ~= nil)
                return not CompareMiddle(leftToken, preSortedUnits)
            else
                return playerSortMode == fsConfig.PlayerSortMode.Bottom
            end
        end
    end

    if reverse then
        local tmp = leftToken
        leftToken = rightToken
        rightToken = tmp
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
    if fsUnit:IsPet(leftToken) or fsUnit:IsPet(rightToken) then
        -- place player before pets
        if not fsUnit:IsPet(leftToken) then return true end
        if not fsUnit:IsPet(rightToken) then return false end

        -- both are pets, compare their parent
        local leftTokenParent = string.gsub(leftToken, "pet", "")
        local rightTokenParent = string.gsub(rightToken, "pet", "")

        return EnemyCompare(leftTokenParent, rightTokenParent, groupSortMode, reverse)
    end

    if reverse then
        local tmp = leftToken
        leftToken = rightToken
        rightToken = tmp
    end

    if groupSortMode == fsConfig.GroupSortMode.Group then
        return CompareGroup(leftToken, rightToken)
    end

    local inInstance, instanceType = wow.IsInInstance()

    if groupSortMode == fsConfig.GroupSortMode.Role and inInstance and instanceType == "arena" and wow.IsRetail() then
        return CompareRole(leftToken, rightToken)
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
        :Where(function(x) return not wow.UnitIsUnit(x, "player") end)
        :OrderBy(function(x, y)
            return Compare(x, y, fsConfig.PlayerSortMode.Top, groupSortMode, reverse)
        end)
        :ToTable()

    return function(x, y)
        return Compare(x, y, playerSortMode, groupSortMode, reverse, units)
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
        return config.Arena.Enabled, config.Arena.PlayerSortMode, config.Arena.GroupSortMode, config.Arena.Reverse
    elseif inInstance and instanceType == "party" then
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
