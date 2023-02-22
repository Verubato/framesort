local _, addon = ...

---Returns a function that accepts two parameters of unit tokens and returns true if the left token should be ordered before the right.
---Sorting is based on the player's instance and configured options.
---Nil may be returned if sorting is not enabled for the player's current instance.
---@return function?
function addon:GetSortFunction()
    local inInstance, instanceType = IsInInstance()
    local enabled, playerSortMode, groupSortMode = addon:GetSortMode(inInstance, instanceType)

    if not enabled then return nil end

    assert(playerSortMode ~= nil)
    assert(groupSortMode ~= nil)

    if playerSortMode ~= addon.SortMode.Middle then
        return function(x, y) return addon:Compare(x, y, playerSortMode, groupSortMode) end
    end

    -- we need to pre-sort to determine where the middle actually is
    local units = addon:GetUnits()
    table.sort(units, function(x, y) return addon:Compare(x, y, addon.SortMode.Top, groupSortMode) end)

    return function(x, y) return addon:Compare(x, y, playerSortMode, groupSortMode, units) end
end

---Returns the sort mode from the configured options for the specified instance type.
---@param inInstance boolean
---@param instanceType string
---@return boolean enabled whether sorting is enabled.
---@return string? playerMode the player sort mode.
---@return string? groupMode the group sort mode.
function addon:GetSortMode(inInstance, instanceType)
    if inInstance and instanceType == "arena" then
        return addon.Options.ArenaEnabled, addon.Options.ArenaPlayerSortMode, addon.Options.ArenaSortMode
    elseif inInstance and instanceType == "party" then
        return addon.Options.DungeonEnabled, addon.Options.DungeonPlayerSortMode, addon.Options.DungeonSortMode
    elseif inInstance and (instanceType == "raid" or "pvp") then
        return addon.Options.RaidEnabled, addon.Options.RaidPlayerSortMode, addon.Options.RaidSortMode
    else
        if not addon.Options.WorldEnabled then return false, nil, nil end
        return addon.Options.WorldEnabled, addon.Options.WorldPlayerSortMode, addon.Options.WorldSortMode
    end
end

---Returns true if the left token should be ordered before the right token.
---preSortedUnits is required if playerSortMode == Middle.
---@param leftToken string
---@param rightToken string
---@param playerSortMode string
---@param groupSortMode string
---@param preSortedUnits table?
---@return boolean
function addon:Compare(leftToken, rightToken, playerSortMode, groupSortMode, preSortedUnits)
    if not UnitExists(leftToken) then
        return false
    elseif not UnitExists(rightToken) then
        return true
    elseif UnitIsUnit(leftToken, "player") then
        if playerSortMode == addon.SortMode.Middle then
            assert(preSortedUnits ~= nil)
            return addon:CompareMiddle(rightToken, preSortedUnits)
        else
            return playerSortMode == addon.SortMode.Top
        end
    elseif UnitIsUnit(rightToken, "player") then
        if playerSortMode == addon.SortMode.Middle then
            assert(preSortedUnits ~= nil)
            return not addon:CompareMiddle(leftToken, preSortedUnits)
        else
            return playerSortMode == addon.SortMode.Bottom
        end
    elseif groupSortMode == addon.SortMode.Group then
        return CRFSort_Group(leftToken, rightToken)
    elseif groupSortMode == addon.SortMode.Role then
        return CRFSort_Role(leftToken, rightToken)
    elseif groupSortMode == addon.SortMode.Alphabetical then
        return CRFSort_Alphabetical(leftToken, rightToken)
    else
        return leftToken < rightToken
    end
end

---Returns true if the specified token is ordered after the mid point.
---@param token string
---@param sortedUnits table
---@return boolean
function addon:CompareMiddle(token, sortedUnits)
    -- total number of members in the group
    local total = 0
    -- index of the token we are comparing with
    local index = nil
    for i, x in ipairs(sortedUnits) do
        total = total + 1
        if x == token then
            index = i
        end
    end

    -- most likely a non-existant unit
    if (index == nil) then return false end

    -- 0 based
    index = index - 1

    local mid = math.floor(total / 2)
    return index > mid
end

---Returns true if the left frame is "earlier" than the right frame.
---Earlier = more top left
---e.g. in raid frames where the top left most frame is first, and the bottom right most frame is last.
---@param leftFrame table a wow frame
---@param rightFrame table a wow frame
---@return boolean
function addon:CompareTopLeft(leftFrame, rightFrame)
    -- example with screen resolution of 2560x1440
    -- top of 0 = bottom of screen
    -- top of 1440 = top of screen
    -- left of 0 = leftmost of screen
    -- left of 2560 = rightmost of screen
    local leftY = leftFrame:GetTop()
    local rightY = rightFrame:GetTop()

    if leftY ~= rightY then return leftY > rightY end

    local leftX = leftFrame:GetLeft()
    local rightX = rightFrame:GetLeft()

    return leftX < rightX
end
