local _, addon = ...

-- the player and group sort modes
addon.SortMode = {
    Group = "Group",
    Role = "Role",
    Alphabetical = "Alphabetical",
    Top = "Top",
    Middle = "Middle",
    Bottom = "Bottom"
}

function addon:GetSortFunction()
    local inInstance, instanceType = IsInInstance()
    local enabled, playerSortMode, groupSortMode = addon:GetSortMode(inInstance, instanceType)

    if not enabled then return nil end

    if playerSortMode ~= addon.SortMode.Middle then
        return function(x, y) return addon:Compare(x, y, playerSortMode, groupSortMode) end
    end

    -- we need to pre-sort to determine where the middle actually is
    local units = addon:GetUnits()
    table.sort(units, function(x, y) return addon:Compare(x, y, addon.SortMode.Top, groupSortMode) end)

    return function(x, y) return addon:Compare(x, y, playerSortMode, groupSortMode, units) end
end

-- returns (enabled, playerMode, groupMode)
function addon:GetSortMode(inInstance, instanceType)
    if inInstance and instanceType == "arena" then
        return addon.Options.ArenaEnabled, addon.Options.ArenaPlayerSortMode, addon.Options.ArenaSortMode
    elseif inInstance and instanceType == "party" then
        return addon.Options.DungeonEnabled, addon.Options.DungeonPlayerSortMode, addon.Options.DungeonSortMode
    elseif inInstance and (instanceType == "raid" or "pvp") then
        return addon.Options.RaidEnabled, addon.Options.RaidPlayerSortMode, addon.Options.RaidSortMode
    else
        if not addon.Options.WorldEnabled then return false end
        return addon.Options.WorldEnabled, addon.Options.WorldPlayerSortMode, addon.Options.WorldSortMode
    end
end

-- returns true if the left token should be ordered before the right token
-- preSortedUnits is required if playerSortMode == Middle
function addon:Compare(leftToken, rightToken, playerSortMode, groupSortMode, preSortedUnits)
    assert(playerSortMode ~= addon.SortMode.Middle or preSortedUnits ~= nil)

    if not UnitExists(leftToken) then
        return false
    elseif not UnitExists(rightToken) then
        return true
    elseif UnitIsUnit(leftToken, "player") then
        if playerSortMode == addon.SortMode.Middle then
            return addon:CompareMiddle(rightToken, preSortedUnits)
        else
            return playerSortMode == addon.SortMode.Top
        end
    elseif UnitIsUnit(rightToken, "player") then
        if playerSortMode == addon.SortMode.Middle then
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

-- returns true if the specified token is ordered after the mid point
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
