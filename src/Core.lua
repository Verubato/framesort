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

    local groupSize = GetNumGroupMembers()
    if groupSize <= 0 then
        addon:Debug("Can't sort because group has 0 members.")
    end

    -- don't try if edit mode is active
    if EditModeManagerFrame.editModeActive then
        addon:Debug("Not sorting while edit mode active.")
        return false
    end

    local sortFunc = addon:GetSortFunction()
    if sortFunc == nil then return false end

    local maxPartySize = 5
    if groupSize > maxPartySize then
        if CompactRaidFrameContainer:IsForbidden() then return false end

        addon:Debug("Sorting raid frames.")
        if addon.Options.ExperimentalEnabled then
            CompactRaidGroup_UpdateLayout(CompactRaidFrameContainer)
        else
            CompactRaidFrameContainer:SetFlowSortFunction(sortFunc)
        end
    else
        if CompactPartyFrame:IsForbidden() then return false end

        addon:Debug("Sorting party frames.")
        if addon.Options.ExperimentalEnabled then
            CompactRaidGroup_UpdateLayout(CompactPartyFrame)
        else
            CompactPartyFrame_SetFlowSortFunction(sortFunc)
        end
    end

    return true
end

function addon:GetSortFunction()
    local inInstance, instanceType = IsInInstance()
    local enabled, playerSortMode, groupSortMode = addon:GetSortMode(inInstance, instanceType)

    if not enabled then return nil end

    if playerSortMode == addon.SortMode.Middle then
        -- we need to pre-sort to determine where the middle actually is
        local units = addon:GetUnits()
        table.sort(units, function(x, y) return addon:Compare(x, y, addon.SortMode.Top, groupSortMode) end)

        return function(x, y) return addon:Compare(x, y, playerSortMode, groupSortMode, units) end
    else
        return function(x, y) return addon:Compare(x, y, playerSortMode, groupSortMode) end
    end
end

-- returns a table of group member unit tokens that exist (UnitExists())
-- the second return value is the total count of units
function addon:GetUnits()
    local isRaid = IsInRaid()
    local prefix = isRaid and "raid" or "party"
    local toGenerate = isRaid and MEMBERS_PER_RAID_GROUP or (MEMBERS_PER_RAID_GROUP - 1)
    local members = {}
    local count = 0

    -- raids don't have the "player" token
    if not isRaid then
        table.insert(members, "player")
        count = 1
    end

    for i = 1, toGenerate do
        local unit = prefix .. i
        if UnitExists(unit) then
            table.insert(members, unit)
            count = count + 1
        end
    end

    return members, count
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

function addon:Layout(container)
    -- list of the party member frames
    local frames = { container:GetChildren() }
    -- true if using horizontal layout, otherwise false
    local useHorizontalGroups = EditModeManagerFrame:ShouldRaidFrameUseHorizontalRaidGroups(container.isParty)
    -- lookup of frame by unit token
    local frameByUnit = {}

    for _, frame in ipairs(frames) do
        -- remove all current anchors
        if frame.unit then
            frame:ClearAllPoints()
            frameByUnit[frame.unit] = frame
        end
    end

    -- calculate the desired order
    local sortFunction = addon:GetSortFunction()
    -- sorting may be disabled in the player's current instance
    if sortFunction == nil then return end

    local units, unitsCount = addon:GetUnits()
    table.sort(units, sortFunction)

    -- place the first frame at the beginning of the container
    local firstUnit = units[1]
    local firstFrame = frameByUnit[firstUnit]
    local firstFrameRelativePoint = useHorizontalGroups and "TOPLEFT" or "TOP"
    firstFrame:SetPoint(firstFrameRelativePoint, container, firstFrameRelativePoint, 0, -container.title:GetHeight());

    -- all other frames are placed relative to the frame before it
    local previous = firstFrame
    for i = 2, unitsCount do
        local unit = units[i]
        local next = frameByUnit[unit]

        next:SetPoint(
            useHorizontalGroups and "LEFT" or "TOP",
            previous,
            useHorizontalGroups and "RIGHT" or "BOTTOM")

        previous = next
    end
end
