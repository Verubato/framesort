local addonName, addon = ...
local logPrefix = addonName .. ": "

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

    local maxPartySize = 5
    local groupSize = GetNumGroupMembers()

    if groupSize > maxPartySize then
        if CompactRaidFrameContainer:IsForbidden() then return false end

        addon:Debug("Sorting raid frames.")
        CompactRaidFrameContainer:SetFlowSortFunction((function(x, y) return addon:Compare(x, y, playerSortMode, groupSortMode) end))
    else
        if CompactPartyFrame:IsForbidden() then return false end

        addon:Debug("Sorting party frames.")
        CompactPartyFrame_SetFlowSortFunction((function(x, y) return addon:Compare(x, y, playerSortMode, groupSortMode) end))
    end

    return true
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

function addon:Compare(leftToken, rightToken, playerSortMode, groupSortMode)
    if not UnitExists(leftToken) then return false
    elseif not UnitExists(rightToken) then return true
    elseif UnitIsUnit(leftToken, "player") then return playerSortMode == addon.SortMode.Top
    elseif UnitIsUnit(rightToken, "player") then return playerSortMode == addon.SortMode.Bottom
    elseif groupSortMode == addon.SortMode.Group then return CRFSort_Group(leftToken, rightToken)
    elseif groupSortMode == addon.SortMode.Role then return CRFSort_Role(leftToken, rightToken)
    elseif groupSortMode == addon.SortMode.Alphabetical then return CRFSort_Alphabetical(leftToken, rightToken)
    else return leftToken < rightToken end
end
