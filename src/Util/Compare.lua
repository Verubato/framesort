---@type string, Addon
local _, addon = ...
---@type WoW
local wow = addon.WoW
local fsUnit = addon.Unit
local fsMath = addon.Math
local fsEnumerable = addon.Enumerable
local fuzzyDecimalPlaces = 0
local roleValues = { MAINTANK = 1, MAINASSIST = 2, TANK = 3, HEALER = 4, DAMAGER = 5, NONE = 6 }
---@class Compare
local M = {}
addon.Compare = M

local function EmptyCompare(x, y)
    return x < y
end

function CompareAlphabetical(leftToken, rightToken)
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
            leftRole = select(10, wow.GetRaidRosterInfo(leftId))
        end

        if rightId then
            rightRole = select(10, wow.GetRaidRosterInfo(rightId))
        end

        leftRole = leftRole or wow.UnitGroupRolesAssigned(leftToken)
        rightRole = rightRole or wow.UnitGroupRolesAssigned(rightToken)
    end

    if leftRole and rightRole then
        local leftValue, rightValue = roleValues[leftRole], roleValues[rightRole]
        if leftValue ~= rightValue then
            return leftValue < rightValue
        end
    end

    return leftToken < rightToken
end

---Returns true if the specified token is ordered after the mid point.
---@param token string
---@param sortedUnits table
---@return boolean
local function CompareMiddle(token, sortedUnits)
    -- index of the token we are comparing with
    local index = fsEnumerable:From(sortedUnits):IndexOf(token)

    -- most likely a non-existant unit
    if not index then
        return false
    end

    -- 0 based
    index = index - 1

    local mid = math.floor(#sortedUnits / 2)
    return index > mid
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

    if playerSortMode ~= addon.PlayerSortMode.Middle then
        return function(x, y)
            return M:Compare(x, y, playerSortMode, groupSortMode, reverse)
        end
    end

    units = units or fsUnit:FriendlyUnits()

    -- we need to pre-sort to determine where the middle actually is
    -- making use of Enumerable:OrderBy() so we don't re-order the original array
    units = fsEnumerable
        :From(units)
        :OrderBy(function(x, y)
            return M:Compare(x, y, addon.PlayerSortMode.Top, groupSortMode, reverse)
        end)
        :ToTable()

    return function(x, y)
        return M:Compare(x, y, playerSortMode, groupSortMode, reverse, units)
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
        return M:EnemyCompare(x, y, groupSortMode, reverse)
    end
end

---Returns the sort mode from the configured options for the current instance.
---@return boolean enabled whether sorting is enabled.
---@return string? playerMode the player sort mode.
---@return string? groupMode the group sort mode.
---@return boolean? reverse whether the sorting is reversed.
function M:FriendlySortMode()
    local inInstance, instanceType = wow.IsInInstance()

    if inInstance and instanceType == "arena" then
        return addon.Options.Arena.Enabled, addon.Options.Arena.PlayerSortMode, addon.Options.Arena.GroupSortMode, addon.Options.Arena.Reverse
    elseif inInstance and instanceType == "party" then
        return addon.Options.Dungeon.Enabled, addon.Options.Dungeon.PlayerSortMode, addon.Options.Dungeon.GroupSortMode, addon.Options.Dungeon.Reverse
    elseif inInstance and (instanceType == "raid" or instanceType == "pvp") then
        return addon.Options.Raid.Enabled, addon.Options.Raid.PlayerSortMode, addon.Options.Raid.GroupSortMode, addon.Options.Raid.Reverse
    end

    -- default to world rules for all other instance types
    return addon.Options.World.Enabled, addon.Options.World.PlayerSortMode, addon.Options.World.GroupSortMode, addon.Options.World.Reverse
end

---Returns the sort mode from the configured options for the current instance.
---@return boolean enabled whether sorting is enabled.
---@return string? groupMode the group sort mode.
---@return boolean? reverse whether the sorting is reversed.
function M:EnemySortMode()
    return addon.Options.EnemyArena.Enabled, addon.Options.EnemyArena.GroupSortMode, addon.Options.EnemyArena.Reverse
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
function M:Compare(leftToken, rightToken, playerSortMode, groupSortMode, reverse, preSortedUnits)
    -- if not in a group, we might be in test mode
    if wow.IsInGroup() then
        if not wow.UnitExists(leftToken) then
            return false
        end
        if not wow.UnitExists(rightToken) then
            return true
        end
    end

    if playerSortMode and playerSortMode ~= "" then
        if leftToken == "player" or wow.UnitIsUnit(leftToken, "player") then
            if playerSortMode == addon.PlayerSortMode.Hidden then
                return false
            elseif playerSortMode == addon.PlayerSortMode.Middle then
                assert(preSortedUnits ~= nil)
                return CompareMiddle(rightToken, preSortedUnits)
            else
                return playerSortMode == addon.PlayerSortMode.Top
            end
        end

        if rightToken == "player" or wow.UnitIsUnit(rightToken, "player") then
            if playerSortMode == addon.PlayerSortMode.Hidden then
                return true
            elseif playerSortMode == addon.PlayerSortMode.Middle then
                assert(preSortedUnits ~= nil)
                return not CompareMiddle(leftToken, preSortedUnits)
            else
                return playerSortMode == addon.PlayerSortMode.Bottom
            end
        end
    end

    if reverse then
        local tmp = leftToken
        leftToken = rightToken
        rightToken = tmp
    end

    if groupSortMode == addon.GroupSortMode.Group then
        return CompareGroup(leftToken, rightToken)
    elseif groupSortMode == addon.GroupSortMode.Role then
        return CompareRole(leftToken, rightToken)
    elseif groupSortMode == addon.GroupSortMode.Alphabetical then
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
function M:EnemyCompare(leftToken, rightToken, groupSortMode, reverse)
    if reverse then
        local tmp = leftToken
        leftToken = rightToken
        rightToken = tmp
    end

    if groupSortMode == addon.GroupSortMode.Group then
        return CompareGroup(leftToken, rightToken)
    end

    local inInstance, instanceType = wow.IsInInstance()

    if groupSortMode == addon.GroupSortMode.Role and inInstance and instanceType == "arena" and wow.IsRetail() then
        return CompareRole(leftToken, rightToken)
    end

    return leftToken < rightToken
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
