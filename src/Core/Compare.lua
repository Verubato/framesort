local _, addon = ...
local fsUnit = addon.Unit
local fsMath = addon.Math
local fsEnumerable = addon.Enumerable
local fuzzyDecimalPlaces = 0
local roleValues = { MAINTANK = 1, MAINASSIST = 2, TANK = 3, HEALER = 4, DAMAGER = 5, NONE = 6 }
local M = {}
addon.Compare = M

local function EmptyCompare(x, y)
    return x < y
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
---@return PlayerSortMode? playerMode the player sort mode.
---@return GroupSortMode? groupMode the group sort mode.
---@return boolean? reverse whether the sorting is reversed.
function M:FriendlySortMode()
    local inInstance, instanceType = IsInInstance()

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
---@return GroupSortMode? groupMode the group sort mode.
---@return boolean? reverse whether the sorting is reversed.
function M:EnemySortMode()
    local inInstance, instanceType = IsInInstance()

    if inInstance and instanceType == "arena" then
        return addon.Options.EnemyArena.Enabled, addon.Options.EnemyArena.GroupSortMode, addon.Options.EnemyArena.Reverse
    end

    return false, nil, nil
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
    if playerSortMode and playerSortMode ~= "" then
        if leftToken == "player" or UnitIsUnit(leftToken, "player") then
            if playerSortMode == addon.PlayerSortMode.Hidden then
                return false
            elseif playerSortMode == addon.PlayerSortMode.Middle then
                assert(preSortedUnits ~= nil)
                return CompareMiddle(rightToken, preSortedUnits)
            else
                return playerSortMode == addon.PlayerSortMode.Top
            end
        end

        if rightToken == "player" or UnitIsUnit(rightToken, "player") then
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
        return CRFSort_Group(leftToken, rightToken)
    elseif groupSortMode == addon.GroupSortMode.Role then
        return CRFSort_Role(leftToken, rightToken)
    elseif groupSortMode == addon.GroupSortMode.Alphabetical then
        return CRFSort_Alphabetical(leftToken, rightToken)
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

    local leftStr = string.match(leftToken, "%d+")
    local rightStr = string.match(rightToken, "%d+")

    if not leftStr or not rightStr then
        return leftToken < rightToken
    end

    local leftNumber = tonumber(leftStr)
    local rightNumber = tonumber(rightStr)

    if groupSortMode == addon.GroupSortMode.Group then
        return leftNumber < rightNumber
    end

    local inInstance, instanceType = IsInInstance()

    if groupSortMode == addon.GroupSortMode.Role and inInstance and instanceType == "arena" and WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
        local leftSpecId = GetArenaOpponentSpec(leftNumber)
        local rightSpecId = GetArenaOpponentSpec(rightNumber)

        if leftSpecId and rightSpecId then
            local _, _, _, _, leftRole, _, _ = GetSpecializationInfoByID(leftSpecId)
            local _, _, _, _, rightRole, _, _ = GetSpecializationInfoByID(rightSpecId)
            local leftValue, rightValue = roleValues[leftRole], roleValues[rightRole]

            return leftValue < rightValue
        end
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
