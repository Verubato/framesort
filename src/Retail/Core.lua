local _, addon = ...

---Attempts to sort the party/raid frames.
---@return boolean sorted true if sorted, otherwise false.
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
