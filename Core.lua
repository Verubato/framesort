---@diagnostic disable: undefined-global
local addonName, addon = ...

-- listens for addon onload events
function addon:OnLoadAddon(_, addOnName)
    if addOnName ~= addonName then return end

    -- load our saved variables or init them if this is the first run
    Options = Options or CopyTable(addon.Defaults)
    addon.Options = Options
    addon:InitOptions()
end

-- listens for events where we should refresh the frames
function addon:OnEvent(eventName, _)
    -- TODO: the GROUP_ROSTER_UPDATE event fires even if there are no changes to the party/raid
    -- to avoid taint issues, it'd be nice if we can ignore performing a sort unless the group has changed
    -- however, if we avoid sorting on this event, blizzard will still perform a sort and the frames end up all over the place
    -- so future TODO to see if we can somehow hook some functions to prevent blizzard from re-sorting frames when it's not needed
    -- of course this logic wouldn't event be required if the taint issues weren't so prevalent at the time of writing
    -- as then performing a re-sort wouldn't hurt
    local forceSort = eventName == "GROUP_ROSTER_UPDATE" or eventName == "PLAYER_ENTERING_WORLD"
    addon:TrySort(forceSort)
end

-- invokes sorting of the party frames
function addon:TrySort(forceSort)
    -- don't sort if addon is essentially disabled
    if not addon.Options.PartySortEnabled and not addon.Options.RaidSortEnabled then return false end
    -- nothing to sort if we're not in a group
    if not IsInGroup() then return false end
    -- can't make changes during combat
    if InCombatLockdown() then return false end
    -- don't try if edit mode is active
    if EditModeManagerFrame.editModeActive then return false end
    -- avoid resorting if the group hasn't changed
    -- only have this logic to try and avoid taint issues
    if not forceSort and not addon:IsGroupDifferent(addon.PreviousSort or {}, addon:GetGroupMembers()) then return false end

    local maxPartySize = 5
    local groupSize = GetNumGroupMembers()

    if groupSize > maxPartySize then
        if not addon.Options.RaidSortEnabled then return false end
        if CompactRaidFrameContainer:IsForbidden() then return false end

        CompactRaidFrameContainer:SetFlowSortFunction((
            function(x, y) return addon:Compare(x, y, addon.Options.PlayerSortMode, addon.Options.RaidSortMode) end))
        -- immediately after sorting, unset the sort function
        -- might help with avoiding taint issues
        -- this shouldn't be necessary and can be removed once blizzard fix their side
        CompactRaidFrameContainer.flowSortFunc = nil
    else
        -- we're in a party
        if not addon.Options.PartySortEnabled then return false end
        if CompactPartyFrame:IsForbidden() then return false end

        CompactPartyFrame_SetFlowSortFunction((
            function(x, y) return addon:Compare(x, y, addon.Options.PlayerSortMode, addon.Options.PartySortMode) end))
        CompactPartyFrame.flowSortFunc = nil
    end

    addon.PreviousSort = addon:GetGroupMembers()

    return true
end

-- returns a table of all the unit types for the current group type (party/raid)
function addon:GetGroupUnits()
    local unitType = IsInRaid() and "raid" or "party"
    local size = IsInRaid() and MAX_RAID_MEMBERS or MAX_PARTY_MEMBERS
    local units = {};

    for i = 1, size do
        table.insert(units, unitType .. i);
    end

    return units
end

function addon:GetGroupMembers()
    local units = addon:GetGroupUnits()
    local members = {}

    for _, unit in pairs(units) do
        members[unit] = UnitExists(unit) and GetUnitName(unit, true) or nil
    end

    return members
end

function addon:IsGroupDifferent(previous, current)
    local units = addon:GetGroupUnits()

    for _, unit in pairs(units) do
        local before = previous[unit]
        local now = current[unit]

        if before ~= now then return true end
    end

    return false
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

-- listen for the addon being loaded
addon.Loader = CreateFrame("Frame")
addon.Loader:HookScript("OnEvent", addon.OnLoadAddon)
addon.Loader:RegisterEvent("ADDON_LOADED")

-- listen for events where we should trigger our sorting function
addon.EventLoop = CreateFrame("Frame")
addon.EventLoop:HookScript("OnEvent", addon.OnEvent)
-- Fired whenever a group or raid is formed or disbanded, players are leaving or joining the group or raid.
addon.EventLoop:RegisterEvent("GROUP_ROSTER_UPDATE")
-- Fired after ending combat, as regen rates return to normal.
-- Useful for determining when a player has left combat.
-- This occurs when you are not on the hate list of any NPC, or a few seconds after the latest pvp attack that you were involved with.
addon.EventLoop:RegisterEvent("PLAYER_REGEN_ENABLED")
-- Fires when the player logs in, /reloads the UI or zones between map instances.
-- Basically whenever the loading screen appears.
addon.EventLoop:RegisterEvent("PLAYER_ENTERING_WORLD")
