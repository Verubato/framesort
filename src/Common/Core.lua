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
