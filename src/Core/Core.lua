local _, addon = ...

---Listens for events where we should refresh the frames.
---@param eventName string
function addon:OnEvent(eventName)
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
    local sorted = false

    if addon.Options.SortingMethod.TaintlessEnabled then
        sorted = addon:TrySortTaintless()
    else
        sorted = addon:TrySortTraditional()
    end

    if sorted then
        addon:UpdateTargets()
    end

    return sorted
end

---Attempts to sort the party/raid frames using the traditional method.
---@return boolean sorted true if sorted, otherwise false.
function addon:TrySortTraditional()
    if not addon:CanSort() then return false end

    local sortFunc = addon:GetSortFunction()
    if sortFunc == nil then return false end

    if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
        if not CompactRaidFrameContainer:IsForbidden() and CompactRaidFrameContainer:IsVisible() then
            addon:Debug("Sorting raid frames (traditional).")
            CompactRaidFrameContainer:SetFlowSortFunction(sortFunc)
            return true
        elseif not CompactPartyFrame:IsForbidden() and CompactPartyFrame:IsVisible() then
            addon:Debug("Sorting party frames (traditional).")
            CompactPartyFrame_SetFlowSortFunction(sortFunc)
            return true
        end
    else
        if not CompactRaidFrameContainer:IsForbidden() and CompactRaidFrameContainer:IsVisible() then
            addon:Debug("Sorting raid frames (traditional).")
            CompactRaidFrameContainer_SetFlowSortFunction(CompactRaidFrameContainer, sortFunc)
            return true
        end
    end

    return false
end

---Attempts to sort the party/raid frames using the taintless method.
---@return boolean sorted true if sorted, otherwise false.
function addon:TrySortTaintless()
    if not addon:CanSort() then return false end

    if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
        if not CompactRaidFrameContainer:IsForbidden() and CompactRaidFrameContainer:IsVisible() then
            return addon:LayoutRaid()
        elseif not CompactPartyFrame:IsForbidden() and CompactPartyFrame:IsVisible() then
            return addon:LayoutParty()
        end
    else
        if not CompactRaidFrameContainer:IsForbidden() and CompactRaidFrameContainer:IsVisible() then
            return addon:LayoutRaid()
        end
    end

    return false
end

---Sorts raid frames.
---@return boolean sorted true if frames were sorted, otherwise false.
function addon:LayoutRaid()
    if not addon:CanSort() then
        addon.SortPending = true
        return false
    end

    local sortFunction = addon:GetSortFunction()
    local memberFrames, petFrames, unknownFrames = addon:GetRaidFrames()

    if not sortFunction or #memberFrames == 0 then return false end
    if #unknownFrames ~= 0 then
        addon:Debug("Warning: " .. #unknownFrames .. " unknown raid frames detected.")
    end

    local units = addon:GetUnits()
    if #units == 0 then return false end

    table.sort(units, sortFunction)

    if #units ~= #memberFrames then
        addon:Debug("Unsupported: Not sorting as the number of member frames " .. #memberFrames .. " is not equal to the number of member units " .. #units .. ".")
        return false
    end

    local memberFramesWithPoints = {}
    local memberFramesByUnit = {}

    for i = 1, #memberFrames do
        local data = addon:ToFrameWithPosition(memberFrames[i])
        memberFramesWithPoints[i] = data
        memberFramesByUnit[memberFrames[i].unit] = data
    end

    addon:SetTargets(units)
    addon:Debug("Sorting raid frames (taintless).")
    addon:ShuffleFrames(units, memberFramesByUnit, memberFramesWithPoints)

    local pets = addon:GetPets(units)

    if #petFrames == 0 or #pets == 0 then return true end
    if #pets ~= #petFrames then
        addon:Debug("Unsupported: Not sorting pets as the number of pet frames " .. #petFrames .. " is not equal to the number of pet units " .. #pets .. ".")
        return false
    end

    local petFramesWithPoints = {}
    local petFramesByUnit = {}

    for i = 1, #petFrames do
        local data = addon:ToFrameWithPosition(petFrames[i])
        petFramesWithPoints[i] = data

        -- pets can be partyXpet or partypetX
        local aliases = addon:GetUnitAliases(petFrames[i].unit)
        for j = 1, #aliases do
            petFramesByUnit[aliases[j]] = data
        end
    end

    addon:Debug("Sorting pet frames (taintless).")
    addon:ShuffleFrames(pets, petFramesByUnit, petFramesWithPoints)

    return true
end

---Rearranges frames in order of the specified units.
---@param orderedUnits table<string>
---@param framesByUnit table<string, table>
---@param framesWithPoints table<FrameWithPosition>
function addon:ShuffleFrames(orderedUnits, framesByUnit, framesWithPoints)
    -- probably too complicated to calculate positions due to the whole flow container layout logic
    -- so instead we can just re-use the existing positions and shuffle them
    -- probably safer and better supported this way anyway
    for i = 1, #orderedUnits do
        local sourceUnit = orderedUnits[i]
        local source = framesByUnit[sourceUnit]
        local target = framesWithPoints[i]

        assert(source ~= nil)
        assert(target ~= nil)

        source.Frame:ClearAllPoints()

        for j = 1, #target.Points do
            local point = target.Points[j]

            -- move the source frame to the target
            ---@diagnostic disable-next-line: deprecated
            source.Frame:SetPoint(unpack(point))
        end
    end
end

if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
    ---Sorts party frames.
    ---@return boolean sorted true if frames were sorted, otherwise false.
    function addon:LayoutParty()
        if not addon:CanSort() then
            addon.SortPending = true
            return false
        end

        local sortFunction = addon:GetSortFunction()

        -- sorting may be disabled in the player's current instance
        if not sortFunction then return false end

        -- list of the party member frames
        local frames = addon:GetPartyFrames()

        -- no frames, nothing to do
        if #frames == 0 then return false end

        -- true if using horizontal layout, otherwise false
        local useHorizontalGroups = EditModeManagerFrame:ShouldRaidFrameUseHorizontalRaidGroups(CompactPartyFrame.isParty)

        -- lookup of frame by unit token
        local frameByUnit = {}

        for _, frame in ipairs(frames) do
            -- remove all current anchors
            if frame.unit then
                frame:ClearAllPoints()
                frameByUnit[frame.unit] = frame
            end
        end

        local units = addon:GetUnits()

        table.sort(units, sortFunction)
        addon:SetTargets(units)
        addon:Debug("Sorting party frames (taintless).")

        -- place the first frame at the beginning of the container
        local firstUnit = units[1]
        local firstFrame = frameByUnit[firstUnit]
        local firstFrameRelativePoint = useHorizontalGroups and "TOPLEFT" or "TOP"
        firstFrame:SetPoint(firstFrameRelativePoint, CompactPartyFrame, firstFrameRelativePoint, 0, -CompactPartyFrame.title:GetHeight());

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
