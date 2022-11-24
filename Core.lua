---@diagnostic disable: undefined-global
local addonName, addon = ...

-- default configuration
addon.Defaults = {
    PlayerSortMode = "Top",
    RaidSortMode = "Role",
    PartySortMode = "Group",
    RaidSortEnabled = false,
    PartySortEnabled = true
}

-- listens for addon onload events
function addon:OnLoadAddon(_, addOnName)
    if addOnName ~= addonName then return end

    -- load our saved variables or init them if this is the first run
    Options = Options or CopyTable(addon.Defaults)
    addon.Options = Options
    addon:InitOptions()
end

-- listens for events where we should refresh the party frames
function addon:OnEvent(eventName, _)
    if eventName == "GROUP_ROSTER_UPDATE" then
        -- group has changed, flag that we need to re-sort
        addon.NeedsSort = true
    end

    addon:TrySort()
end

-- invokes sorting of the party frames
function addon:TrySort()
    -- don't sort if addon is essentially disabled
    if not addon.Options.PartySortEnabled and not addon.Options.RaidSortEnabled then return false end
    -- avoid resorting if there is no need
    -- only have this logic to try and avoid taint issues
    if not addon.NeedsSort then return false end
    -- nothing to sort if we're not in a group
    if not IsInGroup() then return false end
    -- can't make changes during combat
    if InCombatLockdown() then return false end
    -- don't try if edit mode is active
    if EditModeManagerFrame.editModeActive then return false end

    local maxPartySize = 5
    local partySize = GetNumGroupMembers()

    if partySize <= maxPartySize then
        -- we're in a party
        if not addon.Options.PartySortEnabled then return false end
        if CompactPartyFrame:IsForbidden() then return false end

        CompactPartyFrame_SetFlowSortFunction((function(x, y) return addon:CompareParty(x, y) end))
        -- immediately after sorting, unset the sort function
        -- might help with avoiding taint issues
        -- this shouldn't be necessary and can be removed once blizzard fix their side
        CompactPartyFrame.flowSortFunc = nil
    else
        -- we're in a raid
        if not addon.Options.RaidSortEnabled then return false end
        if CompactRaidFrameContainer:IsForbidden() then return false end

        CompactRaidFrameContainer:SetFlowSortFunction((function(x, y) return addon:CompareRaid(x, y) end))
        CompactRaidFrameContainer.flowSortFunc = nil
    end

    addon.NeedsSort = false

    return true
end

function addon:CompareRaid(leftToken, rightToken)
    if not UnitExists(leftToken) then return false
    elseif not UnitExists(rightToken) then return true
    elseif UnitIsUnit(leftToken, "player") then return addon.Options.PlayerSortMode == "Top"
    elseif UnitIsUnit(rightToken, "player") then return addon.Options.PlayerSortMode == "Bottom"
    elseif addon.Options.RaidSortMode == "Group" then return CRFSort_Group(leftToken, rightToken)
    elseif addon.Options.RaidSortMode == "Role" then return CRFSort_Role(leftToken, rightToken)
    elseif addon.Options.RaidSortMode == "Alphabetical" then return CRFSort_Alphabetical(leftToken, rightToken)
    else return leftToken < rightToken end
end

function addon:CompareParty(leftToken, rightToken)
    if not UnitExists(leftToken) then return false
    elseif not UnitExists(rightToken) then return true
    elseif UnitIsUnit(leftToken, "player") then return addon.Options.PlayerSortMode == "Top"
    elseif UnitIsUnit(rightToken, "player") then return addon.Options.PlayerSortMode == "Bottom"
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
