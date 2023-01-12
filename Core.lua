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
function addon:OnEvent(_, _)
    addon:TrySort()
end

-- invokes sorting of the party frames
function addon:TrySort()
    -- nothing to sort if we're not in a group
    if not IsInGroup() then return false end
    -- can't make changes during combat
    if InCombatLockdown() then return false end
    -- don't try if edit mode is active
    if EditModeManagerFrame.editModeActive then return false end

    local maxPartySize = 5
    local groupSize = GetNumGroupMembers()
    local playerSortMode = addon.Options.WorldPlayerSortMode
    local groupSortMode = addon.Options.WorldSortMode
    local inInstance, instanceType = IsInInstance()

    if inInstance and instanceType == "arena" then
        if not addon.Options.ArenaEnabled then return false end

        playerSortMode = addon.Options.ArenaPlayerSortMode
        groupSortMode = addon.Options.ArenaSortMode
    elseif inInstance and instanceType == "party" then
        if not addon.Options.DungeonEnabled then return false end

        playerSortMode = addon.Options.DungeonPlayerSortMode
        groupSortMode = addon.Options.DungeonSortMode
    elseif inInstance and instanceType == "raid" then
        if not addon.Options.RaidEnabled then return false end

        playerSortMode = addon.Options.RaidPlayerSortMode
        groupSortMode = addon.Options.RaidSortMode
    else if not addon.Options.WorldEnabled then return false end
    end

    if groupSize > maxPartySize then
        if CompactRaidFrameContainer:IsForbidden() then return false end

        CompactRaidFrameContainer:SetFlowSortFunction((
            function(x, y) return addon:Compare(x, y, playerSortMode, groupSortMode) end))
        -- immediately after sorting, unset the sort function
        -- this might help with avoiding taint issues
        -- but shouldn't be necessary and can be removed once blizzard fix their side
        CompactRaidFrameContainer.flowSortFunc = nil
    else
        if CompactPartyFrame:IsForbidden() then return false end

        CompactPartyFrame_SetFlowSortFunction((
            function(x, y) return addon:Compare(x, y, playerSortMode, groupSortMode) end))
        CompactPartyFrame.flowSortFunc = nil
    end

    return true
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
