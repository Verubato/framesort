local addonName, addon = ...
local logPrefix = addonName .. ": "

-- prints a debug message to the chat window if DebugMode is enabled
function addon:Debug(msg)
    if addon.Options.DebugEnabled then
        print(logPrefix .. msg)
    end
end

-- listens for events where we should refresh the frames
function addon:OnEvent(eventName)
    addon:Debug("Event: " .. eventName)
    addon:TrySort()
end

-- attempts to sort the party/raid frames, returns true if sorted, otherwise false
function addon:TrySort()
    -- nothing to sort if we're not in a group
    if not IsInGroup() then
        addon:Debug("Not sorting because not in a group.")
        return false
    end

    -- can't make changes during combat
    if InCombatLockdown() then
        addon:Debug("Can't sort during combat.")
        return false
    end

    -- don't try if edit mode is active
    if EditModeManagerFrame.editModeActive then
        addon:Debug("Can't sort while edit mode active.")
        return false
    end

    local inInstance, instanceType = IsInInstance()
    local enabled, playerSortMode, groupSortMode = addon:GetSortMode(inInstance, instanceType)

    if not enabled then return false end

    addon:Debug("In instance: " .. tostring(inInstance) .. ", type: " .. instanceType)

    local groupSize = GetNumGroupMembers()
    if groupSize <= 0 then
        addon:Debug("Can't sort because group has 0 members.")
    end

    local sortFunc = nil

    if playerSortMode == addon.SortMode.Middle then
        -- we need to pre-sort to determine where the middle actually is
        local units = addon:GetUnits()
        table.sort(units, function(x, y) return addon:Compare(x, y, addon.SortMode.Top, groupSortMode) end)

        sortFunc = function(x, y) return addon:Compare(x, y, playerSortMode, groupSortMode, units) end
    else
        sortFunc = function(x, y) return addon:Compare(x, y, playerSortMode, groupSortMode) end
    end

    local maxPartySize = 5
    if groupSize > maxPartySize then
        if CompactRaidFrameContainer:IsForbidden() then return false end

        addon:Debug("Sorting raid frames.")
        CompactRaidFrameContainer:SetFlowSortFunction(sortFunc)
    else
        if CompactPartyFrame:IsForbidden() then return false end

        addon:Debug("Sorting party frames.")
        CompactPartyFrame_SetFlowSortFunction(sortFunc)
    end

    return true
end

-- returns a table of group member unit tokens that exist (UnitExists())
function addon:GetUnits()
    local isRaid = IsInRaid()
    local prefix = isRaid and "raid" or "party"
    local toGenerate = isRaid and MEMBERS_PER_RAID_GROUP or (MEMBERS_PER_RAID_GROUP - 1)
    local members = {}

    -- raids don't have the "player" token
    if not isRaid then
        table.insert(members, "player")
    end

    for i = 1, toGenerate do
        local unit = prefix .. i
        if UnitExists(unit) then
            table.insert(members, unit)
        end
    end

    return members
end

-- returns (enabled, playerMode, groupMode)
function addon:GetSortMode(inInstance, instanceType)
    if inInstance and instanceType == "arena" then
        return addon.Options.ArenaEnabled, addon.Options.ArenaPlayerSortMode, addon.Options.ArenaSortMode
    elseif inInstance and instanceType == "party" then
        return addon.Options.DungeonEnabled, addon.Options.DungeonPlayerSortMode, addon.Options.DungeonSortMode
    elseif inInstance and (instanceType == "raid" or "pvp") then
        return addon.Options.RaidEnabled, addon.Options.RaidPlayerSortMode, addon.Options.RaidSortMode
    else if not addon.Options.WorldEnabled then return false end
        return addon.Options.WorldEnabled, addon.Options.WorldPlayerSortMode, addon.Options.WorldSortMode
    end
end

-- returns true if the left token should be ordered before the right token
-- preSortedUnits is required if playerSortMode == Middle
function addon:Compare(leftToken, rightToken, playerSortMode, groupSortMode, preSortedUnits)
    assert(playerSortMode ~= addon.SortMode.Middle or preSortedUnits ~= nil)

    if not UnitExists(leftToken) then return false
    elseif not UnitExists(rightToken) then return true
    elseif UnitIsUnit(leftToken, "player") then
        if playerSortMode == addon.SortMode.Middle then return addon:CompareMiddle(rightToken, preSortedUnits)
        else return playerSortMode == addon.SortMode.Top end
    elseif UnitIsUnit(rightToken, "player") then
        if playerSortMode == addon.SortMode.Middle then return not addon:CompareMiddle(leftToken, preSortedUnits)
        else return playerSortMode == addon.SortMode.Bottom end
    elseif groupSortMode == addon.SortMode.Group then return CRFSort_Group(leftToken, rightToken)
    elseif groupSortMode == addon.SortMode.Role then return CRFSort_Role(leftToken, rightToken)
    elseif groupSortMode == addon.SortMode.Alphabetical then return CRFSort_Alphabetical(leftToken, rightToken)
    else return leftToken < rightToken end
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
