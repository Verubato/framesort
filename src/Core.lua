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

    -- only attempt a sort after combat ends if one is pending
    if eventName == "PLAYER_REGEN_ENABLED" and not addon.SortPending then return end

    addon.SortPending = not addon:TrySort()
end

function addon:CanSort()
    -- nothing to sort if we're not in a group
    if not IsInGroup() then
        -- not worth logging anything here
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
        return false
    end

    -- don't try if edit mode is active
    if EditModeManagerFrame.editModeActive then
        addon:Debug("Not sorting while edit mode active.")
        return false
    end

    return true
end

-- attempts to sort the party/raid frames, returns true if sorted, otherwise false
function addon:TrySort()
    if not addon:CanSort() then return false end

    local sortFunc = addon:GetSortFunction()
    if sortFunc == nil then return false end

    if not CompactRaidFrameContainer:IsForbidden() and CompactRaidFrameContainer:IsVisible() then
        if addon.Options.ExperimentalEnabled then
            return CompactRaidFrameContainer:TryUpdate()
        else
            addon:Debug("Sorting raid frames.")
            CompactRaidFrameContainer:SetFlowSortFunction(sortFunc)
        end
    elseif not CompactPartyFrame:IsForbidden() and CompactPartyFrame:IsVisible() then
        if addon.Options.ExperimentalEnabled then
            addon:LayoutParty(CompactPartyFrame)
        else
            addon:Debug("Sorting party frames.")
            CompactPartyFrame_SetFlowSortFunction(sortFunc)
        end
    else
        return false
    end

    return true
end

function addon:LayoutParty(container)
    if not addon:CanSort() or container:IsForbidden() then
        addon.SortPending = true
        return
    end

    -- nothing to sort
    if not container:IsVisible() then return end

    addon:Debug("Sorting party frames (experimental).")

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

    local units = addon:GetUnits()
    table.sort(units, sortFunction)

    -- place the first frame at the beginning of the container
    local firstUnit = units[1]
    local firstFrame = frameByUnit[firstUnit]
    local firstFrameRelativePoint = useHorizontalGroups and "TOPLEFT" or "TOP"
    firstFrame:SetPoint(firstFrameRelativePoint, container, firstFrameRelativePoint, 0, -container.title:GetHeight());

    -- all other frames are placed relative to the frame before it
    local previous = firstFrame
    for i = 2, #units do
        local unit = units[i]
        local next = frameByUnit[unit]

        next:SetPoint(
            useHorizontalGroups and "LEFT" or "TOP",
            previous,
            useHorizontalGroups and "RIGHT" or "BOTTOM")

        previous = next
    end
end

function addon:LayoutRaid(container)
    if not addon:CanSort() or container:IsForbidden() then
        addon.SortPending = true
        return
    end

    -- nothing to sort
    if not container:IsVisible() then return end

    addon:Debug("Sorting raid frames (experimental).")

    -- existing frames
    local flowFrames = {}
    local framesByUnit = {}

    -- probably too complicated to calculate positions due to the whole flow container layout logic
    -- so instead we can just store the existing positions and re-use them
    -- probably safer and better supported this way anyway
    for i = 1, #container.flowFrames do
        local object = container.flowFrames[i]
        local objectType = type(object)

        if objectType == "table" and object.unit then
            local data = {
                frame = object,
                points = {},
            }

            local pointsCount = object:GetNumPoints()

            for j = 1, pointsCount do
                data.points[j] = { object:GetPoint(j) }
            end

            flowFrames[#flowFrames + 1] = data
            framesByUnit[object.unit] = data
        end
    end

    -- calculate the desired order
    local sortFunction = addon:GetSortFunction()
    -- sorting may be disabled in the player's current instance
    if sortFunction == nil then return end

    local units = addon:GetUnits()

    if #units ~= #flowFrames then
        -- this can happen in edit mode where fake raid frames are placed
        -- but we shouldn't actually get here anyway as CanSort() would return false
        addon:Debug("Unsupported: Not sorting as the number of raid frames is not equal to the number of raid units.")
        return
    end

    table.sort(units, sortFunction)

    for i = 1, #units do
        local sourceUnit = units[i]
        -- the current frame/position
        local source = framesByUnit[sourceUnit]
        -- the target frame/position
        local target = flowFrames[i]

        source.frame:ClearAllPoints()

        for j = 1, #target.points do
            local point = target.points[j]

            -- move the source frame to the target
            source.frame:SetPoint(
                point[1],
                point[2],
                point[3],
                point[4],
                point[5])
        end
    end
end

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

-- returns a table of group member unit tokens that exist (UnitExists())
function addon:GetUnits()
    local isRaid = IsInRaid()
    local prefix = isRaid and "raid" or "party"
    local toGenerate = isRaid and MAX_RAID_MEMBERS or (MEMBERS_PER_RAID_GROUP - 1)
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
