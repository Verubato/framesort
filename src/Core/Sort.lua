local _, addon = ...
local eventFrame = nil
local sortPending = false
local callbacks = {}

---Determines whether general sorting can be performed.
---@return boolean
local function CanSort()
    -- nothing to sort if we're not in a group
    if not IsInGroup() then
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
        if EditModeManagerFrame.editModeActive then
            addon:Debug("Not sorting while edit mode active.")
            return false
        end
    end

    return true
end

---Determines whether party sorting can be performed.
---@return boolean
local function CanSortParty()
    if CompactPartyFrame:IsForbidden() or not CompactPartyFrame:IsVisible() then return false end

    if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
        local together = CompactRaidFrameManager_GetSetting("KeepGroupsTogether")
        if together then
            addon:Debug("Cannot sort frames when the 'Keep Groups Together' setting is enabled.")
            return false
        end
    end

    return CanSort()
end

---Determines whether raid sorting can be performed.
---@return boolean
local function CanSortRaid()
    if CompactRaidFrameContainer:IsForbidden() or not CompactRaidFrameContainer:IsVisible() then return false end

    if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
        local raidGroupDisplayType = EditModeManagerFrame:GetSettingValue(
            Enum.EditModeSystem.UnitFrame,
            Enum.EditModeUnitFrameSystemIndices.Raid,
            Enum.EditModeUnitFrameSetting.RaidGroupDisplayType)

        if raidGroupDisplayType ~= Enum.RaidGroupDisplayType.CombineGroupsVertical and
            raidGroupDisplayType ~= Enum.RaidGroupDisplayType.CombineGroupsHorizontal then
            addon:Debug("Cannot sort frames when 'Separate' raid display mode is being used.")
            return false
        end
    else
        local together = CompactRaidFrameManager_GetSetting("KeepGroupsTogether")
        if together then
            addon:Debug("Cannot sort frames when the 'Keep Groups Together' setting is enabled.")
            return false
        end
    end

    return CanSort()
end

---Calls the post sorting callbacks.
local function InvokeCallbacks()
    for _, callback in pairs(callbacks) do
        callback()
    end
end

---Rearranges frames in order of the specified units.
---@param orderedUnits table<string>
---@param framesByUnit table<string, table>
---@param framesByIndex table<FrameWithPosition>
local function RearrangeFrames(orderedUnits, framesByUnit, framesByIndex)
    -- probably too complicated to calculate positions due to the whole flow container layout logic
    -- so instead we can just re-use the existing positions and shuffle them
    -- probably safer and better supported this way anyway
    for i = 1, #orderedUnits do
        local sourceUnit = orderedUnits[i]
        local source = framesByUnit[sourceUnit]
        local target = framesByIndex[i]

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

---Sorts raid frames.
---@return boolean sorted true if frames were sorted, otherwise false.
local function LayoutRaid()
    if not CanSortRaid() then
        sortPending = true
        return false
    end

    local sortFunction = addon:GetSortFunction()
    local memberFrames, petFrames = addon:GetRaidFrames()

    if not sortFunction or #memberFrames == 0 then return false end

    -- frames can and will most likely be completely out of order if a previous sort has occurred
    -- so we need to sort them
    table.sort(memberFrames, function(x, y) return addon:CompareTopLeftFuzzy(x, y) end)
    table.sort(petFrames, function(x, y) return addon:CompareTopLeftFuzzy(x, y) end)

    local units = {}
    for _, frame in pairs(memberFrames) do
        units[#units + 1] = SecureButton_GetUnit(frame)
    end

    table.sort(units, sortFunction)

    local framesByUnit = {}
    local memberFramesByIndex = {}
    local petFramesByIndex = {}

    -- add players to the lookup table
    for i, frame in ipairs(memberFrames) do
        local data = addon:ToFrameWithPosition(frame)
        local unit = SecureButton_GetUnit(frame)

        framesByUnit[unit] = data
        memberFramesByIndex[i] = data
    end

    addon:Debug("Sorting raid frames (taintless).")
    RearrangeFrames(units, framesByUnit, memberFramesByIndex)

    -- add pets to the lookup table
    for i, frame in ipairs(petFrames) do
        local data = addon:ToFrameWithPosition(frame)
        local unit = SecureButton_GetUnit(frame)
        petFramesByIndex[i] = data

        -- TODO: see if there is a way we can do without the need for aliases
        -- we can get the pet units from the pet frames, but we'd then need to sort them separately
        local aliases = addon:GetUnitAliases(unit)
        for j = 1, #aliases do
            framesByUnit[aliases[j]] = data
        end
    end

    if #petFrames > 0 then
        -- get pets based off the sorted units instead of the frames
        -- as this comes with the benefit that the pets will also be sorted
        local pets = addon:GetPets(units)
        if #pets ~= #petFrames then
            addon:Warning("Unexpectedly encoutered a different number of pet frames '" .. #petFrames .. "' vs pet units '" .. #pets .. "'.")
            return true
        end

        addon:Debug("Sorting pet frames (taintless).")
        RearrangeFrames(pets, framesByUnit, petFramesByIndex)
    end

    return true
end

---Sorts party frames.
---@return boolean sorted true if frames were sorted, otherwise false.
local function LayoutParty()
    if not CanSortParty() then
        sortPending = true
        return false
    end

    local sortFunction = addon:GetSortFunction()
    local frames = addon:GetPartyFrames()

    if not sortFunction or #frames == 0 then return false end

    table.sort(frames, function(x, y) return addon:CompareTopLeft(x, y) end)

    local useHorizontalGroups = EditModeManagerFrame:ShouldRaidFrameUseHorizontalRaidGroups(CompactPartyFrame.isParty)
    local frameByUnit = {}
    local units = {}

    for _, frame in ipairs(frames) do
        local unit = SecureButton_GetUnit(frame)

        if unit then
            units[#units + 1] = unit
            frameByUnit[unit] = frame
            frame:ClearAllPoints()
        end
    end

    table.sort(units, sortFunction)
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

---Attempts to sort the party/raid frames using the traditional method.
---@return boolean sorted true if sorted, otherwise false.
local function TrySortTraditional()
    local sortFunc = addon:GetSortFunction()
    if sortFunc == nil then return false end

    local sorted = false

    if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
        if CanSortRaid() then
            addon:Debug("Sorting raid frames (traditional).")
            CompactRaidFrameContainer:SetFlowSortFunction(sortFunc)
            sorted = true
        end

        if CanSortParty() then
            addon:Debug("Sorting party frames (traditional).")
            CompactPartyFrame_SetFlowSortFunction(sortFunc)
            sorted = sorted or true
        end
    else
        if CanSortRaid() then
            addon:Debug("Sorting raid frames (traditional).")
            CompactRaidFrameContainer_SetFlowSortFunction(CompactRaidFrameContainer, sortFunc)
            sorted = true
        end
    end

    return sorted
end

---Attempts to sort the party/raid frames using the taintless method.
---@return boolean sorted true if sorted, otherwise false.
local function TrySortTaintless()
    local sorted = false

    if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
        if CanSortParty() then
            sorted = LayoutParty()
        end
    end

    if CanSortRaid() then
        sorted = sorted or LayoutRaid()
    end

    return sorted
end

---Listens for events where we should perform a sort.
---@param eventName string
local function OnEvent(_, eventName)
    -- only attempt to run after combat ends if one is pending
    if eventName == "PLAYER_REGEN_ENABLED" and not sortPending then return end

    addon:TrySort()
end

---Event hook on blizzard performing frame layouts.
local function OnLayout(container)
    if container ~= CompactRaidFrameContainer then return end
    if container.flowPauseUpdates then return end

    LayoutRaid()
end

---Register a callback to call after sorting has been performed.
---@param callback function
function addon:RegisterPostSortCallback(callback)
    callbacks[#callbacks + 1] = callback
end

---Attempts to sort the party/raid frames.
---@return boolean sorted true if sorted, otherwise false.
function addon:TrySort()
    local sorted = false

    if addon.Options.SortingMethod.TaintlessEnabled then
        sorted = TrySortTaintless()
    else
        sorted = TrySortTraditional()
    end

    if sorted then
        InvokeCallbacks()
    end

    sortPending = not sorted
    return sorted
end

---Initialises the sorting module.
function addon:InitSorting()
    eventFrame = CreateFrame("Frame")
    eventFrame:HookScript("OnEvent", OnEvent)
    -- Fired after ending combat, as regen rates return to normal.
    -- Useful for determining when a player has left combat.
    -- This occurs when you are not on the hate list of any NPC, or a few seconds after the latest pvp attack that you were involved with.
    -- It seems Blizzard do an update layout after combat ends, so even for the experimental mode we also need to re-sort.
    eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")

    -- Fires when the player logs in, /reloads the UI or zones between map instances.
    -- Basically whenever the loading screen appears.
    eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

    -- Fired whenever a group or raid is formed or disbanded, players are leaving or joining the group or raid.
    eventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")

    if addon.Options.SortingMethod.TaintlessEnabled then
        hooksecurefunc("FlowContainer_DoLayout", OnLayout)
    end
end
