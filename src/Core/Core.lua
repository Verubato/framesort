local _, addon = ...

---Listens for events where we should refresh the frames.
---@param eventName string
function addon:OnEvent(eventName)
    addon:Debug("Event: " .. eventName)

    -- only attempt a sort after combat ends if one is pending
    if eventName == "PLAYER_REGEN_ENABLED" and not addon.SortPending then return end

    addon.SortPending = not addon:TrySort()
end

---Determines whether sorting can be performed.
---@return boolean
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

    if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
        -- don't try if edit mode is active
        if EditModeManagerFrame.editModeActive then
            addon:Debug("Not sorting while edit mode active.")
            return false
        end
    end

    return true
end

---Attempts to sort the party/raid frames.
---@return boolean sorted true if sorted, otherwise false.
function addon:TrySort()
    if not addon:CanSort() then return false end

    local sortFunc = addon:GetSortFunction()
    if sortFunc == nil then return false end

    if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
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
    else
        if not CompactRaidFrameContainer:IsForbidden() and CompactRaidFrameContainer:IsVisible() then
            if addon.Options.ExperimentalEnabled then
                return CompactRaidFrameContainer_TryUpdate(CompactRaidFrameContainer)
            else
                addon:Debug("Sorting raid frames.")
                CompactRaidFrameContainer_SetFlowSortFunction(CompactRaidFrameContainer, sortFunc)
            end
        else
            return false
        end
    end

    return true
end

---Sorts and positions the raid frames.
---@param container table CompactRaidFrameContainer.
---@return boolean sorted true if frames were sorted, otherwise false.
function addon:LayoutRaid(container)
    if not addon:CanSort() or container:IsForbidden() then
        addon.SortPending = true
        return false
    end

    -- nothing to sort
    if not container:IsVisible() then return false end

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
    if sortFunction == nil then return false end

    local units = addon:GetUnits()

    if #units ~= #flowFrames then
        -- this can happen in edit mode where fake raid frames are placed
        -- but we shouldn't actually get here anyway as CanSort() would return false
        addon:Debug("Unsupported: Not sorting as the number of raid frames is not equal to the number of raid units.")
        return false
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
            ---@diagnostic disable-next-line: deprecated
            source.frame:SetPoint(unpack(point))
        end
    end

    return true
end

if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
    ---Sorts and positions the party frames.
    ---@param container table CompactPartyFrame.
    ---@return boolean sorted true if frames were sorted, otherwise false.
    function addon:LayoutParty(container)
        if not addon:CanSort() or container:IsForbidden() then
            addon.SortPending = true
            return false
        end

        -- nothing to sort
        if not container:IsVisible() then return false end

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
        if sortFunction == nil then return false end

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

        return true
    end
end
