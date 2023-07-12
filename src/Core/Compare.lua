local _, addon = ...
local fsUnit = addon.Unit
local fsMath = addon.Math
local fsEnumerable = addon.Enumerable
local fuzzyDecimalPlaces = 0
local M = {}
addon.Compare = M

---Returns a function that accepts two parameters of unit tokens and returns true if the left token should be ordered before the right.
---Sorting is based on the player's instance and configured options.
---Nil may be returned if sorting is not enabled for the player's current instance.
---@return function?
function M:GetSortFunction()
    local enabled, playerSortMode, groupSortMode, reverse = M:GetSortMode()

    if not enabled then
        return nil
    end

    if playerSortMode ~= addon.PlayerSortMode.Middle then
        return function(x, y)
            return M:Compare(x, y, playerSortMode, groupSortMode, reverse)
        end
    end

    -- we need to pre-sort to determine where the middle actually is
    local units = fsUnit:GetUnits()
    table.sort(units, function(x, y)
        return M:Compare(x, y, addon.PlayerSortMode.Top, groupSortMode, reverse)
    end)

    return function(x, y)
        return M:Compare(x, y, playerSortMode, groupSortMode, reverse, units)
    end
end

---Returns the sort mode from the configured options for the current instance.
---@return boolean enabled whether sorting is enabled.
---@return PlayerSortMode? playerMode the player sort mode.
---@return GroupSortMode? groupMode the group sort mode.
---@return boolean? reverse whether the sorting is reversed.
function M:GetSortMode()
    local inInstance, instanceType = IsInInstance()

    if inInstance and instanceType == "arena" then
        return addon.Options.Arena.Enabled, addon.Options.Arena.PlayerSortMode, addon.Options.Arena.GroupSortMode, addon.Options.Arena.Reverse
    elseif inInstance and instanceType == "party" then
        return addon.Options.Dungeon.Enabled, addon.Options.Dungeon.PlayerSortMode, addon.Options.Dungeon.GroupSortMode, addon.Options.Dungeon.Reverse
    elseif inInstance and (instanceType == "raid" or instanceType == "pvp") then
        return addon.Options.Raid.Enabled, addon.Options.Raid.PlayerSortMode, addon.Options.Raid.GroupSortMode, addon.Options.Raid.Reverse
    elseif (inInstance and instanceType == "scenario") or not inInstance then
        -- use the world sorting rules for scenarios
        return addon.Options.World.Enabled, addon.Options.World.PlayerSortMode, addon.Options.World.GroupSortMode, addon.Options.World.Reverse
    end

    return false, nil, nil, nil
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
    if not UnitExists(leftToken) then
        return false
    end
    if not UnitExists(rightToken) then
        return true
    end

    if playerSortMode and playerSortMode ~= "" then
        if UnitIsUnit(leftToken, "player") then
            if playerSortMode == addon.PlayerSortMode.Hidden then
                return false
            elseif playerSortMode == addon.PlayerSortMode.Middle then
                assert(preSortedUnits ~= nil)
                return M:CompareMiddle(rightToken, preSortedUnits)
            else
                return playerSortMode == addon.PlayerSortMode.Top
            end
        end

        if UnitIsUnit(rightToken, "player") then
            if playerSortMode == addon.PlayerSortMode.Hidden then
                return true
            elseif playerSortMode == addon.PlayerSortMode.Middle then
                assert(preSortedUnits ~= nil)
                return not M:CompareMiddle(leftToken, preSortedUnits)
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

    if groupSortMode and groupSortMode ~= "" then
        if groupSortMode == addon.GroupSortMode.Group then
            return CRFSort_Group(leftToken, rightToken)
        elseif groupSortMode == addon.GroupSortMode.Role then
            return CRFSort_Role(leftToken, rightToken)
        elseif groupSortMode == addon.GroupSortMode.Alphabetical then
            return CRFSort_Alphabetical(leftToken, rightToken)
        end
    end

    return leftToken < rightToken
end

---Returns true if the specified token is ordered after the mid point.
---@param token string
---@param sortedUnits table
---@return boolean
function M:CompareMiddle(token, sortedUnits)
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
