local _, addon = ...
local fsCompare = addon.Compare
local fsUnit = addon.Unit
local fsFrame = addon.Frame
local fsPoint = addon.Point
local fsEnumerable = addon.Enumerable
local fsLog = addon.Log
local sortPending = false
local callbacks = {}
local M = {}
addon.Sorting = M

---Determines whether general sorting can be performed.
---@return boolean
local function CanSort()
    if not IsInGroup() then
        return false
    end

    -- can't make changes during combat
    if InCombatLockdown() and not addon.Options.SortingMethod.TaintlessEnabled then
        fsLog:Warning("Can't perform non-taintless sorting during combat.")
        return false
    end

    local groupSize = GetNumGroupMembers()
    if groupSize <= 0 then
        fsLog:Warning("Can't sort because group has 0 members.")
        return false
    end

    if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
        if EditModeManagerFrame.editModeActive then
            fsLog:Debug("Not sorting while edit mode active.")
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
            fsLog:Warning("Cannot sort frames when the 'Keep Groups Together' setting is enabled.")
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
            fsLog:Warning("Cannot sort frames when 'Separate' raid display mode is being used.")
            return false
        end
    else
        local together = CompactRaidFrameManager_GetSetting("KeepGroupsTogether")
        if together then
            fsLog:Warning("Cannot sort frames when the 'Keep Groups Together' setting is enabled.")
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
---@param frames table<table> the set of frames to rearrange.
---@param units table<string> unit ids in the desired order.
local function RearrangeFrames(frames, units)
    local sorted = fsEnumerable
        :From(frames)
        :OrderBy(function(x, y) return fsCompare:CompareTopLeftFuzzy(x, y) end)
        :ToTable()
    local points = fsEnumerable
        :From(sorted)
        :Map(function(x) return fsPoint:GetPointEx(x) end)
        :ToTable()

    for unitIndex, unit in ipairs(units) do
        ---@type any, number
        local _, frameIndex = fsEnumerable
            :From(sorted)
            :First(function(f) return UnitIsUnit(f.unit, unit) end)

        if frameIndex and frameIndex ~= unitIndex then
            local from = points[frameIndex]
            local to = points[unitIndex]
            local frame = frames[frameIndex]

            if from.point == "TOPLEFT" and
                from.point == to.point and
                from.relativeTo == to.relativeTo and
                from.relativePoint == to.relativePoint then
                local xDelta = to.offsetX - from.offsetX
                local yDelta = to.offsetY - from.offsetY

                -- TODO why is lua_ls getting type confused here when removing the above @type specifier?
                frame:AdjustPointsOffset(xDelta, yDelta)
            else
                fsLog:Error(string.format("Unable to move frame %s as it doesn't share to the same parent anchor.", frame:GetName()))
            end
        end
    end
end

---Rearranges the display of a frame chain in order of the specified units.
---@param frames table<table> the set of frames to rearrange.
---@param units table<string> unit ids in the desired order.
local function RearrangeFrameChain(frames, units)
    local points = fsEnumerable
        :From(frames)
        :OrderBy(function(x, y) return fsCompare:CompareTopLeftFuzzy(x, y) end)
        :Map(function(x)
            return {
                Top = x:GetTop(),
                Left = x:GetLeft()
            }
        end)
        :ToTable()

    local chain = fsFrame:ToFrameChain(frames)
    if not chain.Valid then return end
    local current = chain

    while current do
        local source = current.Value
        local _, unitIndex = fsEnumerable
            :From(units)
            :First(function(x) return UnitIsUnit(x, source.unit) end)

        if unitIndex then
            local to = points[unitIndex]
            local from = { Top = source:GetTop(), Left = source:GetLeft() }
            local xDelta = to.Left - from.Left
            local yDelta = to.Top - from.Top

            source:AdjustPointsOffset(xDelta, yDelta)
        end

        current = current.Next
    end
end

---Sorts raid frames.
---@return boolean sorted true if frames were sorted, otherwise false.
local function LayoutRaid()
    local sortFunction = fsCompare:GetSortFunction()
    local memberFrames, petFrames = fsFrame:GetRaidFrames()

    if not sortFunction or #memberFrames == 0 then return false end

    local units = fsEnumerable
        :From(memberFrames)
        :Map(function(x) return SecureButton_GetUnit(x) end)
        :OrderBy(sortFunction)
        :ToTable()

    RearrangeFrames(memberFrames, units)

    if #petFrames > 0 then
        -- get pets based off the sorted units instead of the frames
        -- as this comes with the benefit that the pets will also be sorted
        local pets = fsUnit:GetPets(units)
        if #pets ~= #petFrames then
            fsLog:Warning(string.format("Unexpectedly encoutered a different number of pet frames '%d' vs pet units '%d'.", #petFrames, #pets))
            return true
        end

        RearrangeFrames(petFrames, pets)
    end

    return true
end

---Sorts party frames.
---@return boolean sorted true if frames were sorted, otherwise false.
local function LayoutParty()
    local sortFunction = fsCompare:GetSortFunction()
    local frames = fsFrame:GetPartyFrames()

    if not sortFunction or #frames == 0 then return false end

    local units = fsEnumerable
        :From(frames)
        :Map(function(x) return SecureButton_GetUnit(x) end)
        :OrderBy(sortFunction)
        :ToTable()

    RearrangeFrameChain(frames, units)

    return true
end

---Attempts to sort the party/raid frames using the traditional method.
---@return boolean sorted true if sorted, otherwise false.
local function TrySortTraditional()
    local sortFunc = fsCompare:GetSortFunction()
    if sortFunc == nil then return false end

    local sorted = false

    if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
        if CanSortRaid() then
            CompactRaidFrameContainer:SetFlowSortFunction(sortFunc)
            sorted = true
        end

        if CanSortParty() then
            CompactPartyFrame_SetFlowSortFunction(sortFunc)
            sorted = sorted or true
        end
    else
        if CanSortRaid() then
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

    M:TrySort()
end

---Event hook on blizzard performing frame layouts.
local function OnLayout(container)
    if container ~= CompactRaidFrameContainer then return end
    if container.flowPauseUpdates then return end

    M:TrySort()
end

---Register a callback to call after sorting has been performed.
---@param callback function
function M:RegisterPostSortCallback(callback)
    callbacks[#callbacks + 1] = callback
end

---Attempts to sort the party/raid frames.
---@return boolean sorted true if sorted, otherwise false.
function M:TrySort()
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
    local eventFrame = CreateFrame("Frame")
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

    -- Fired when people within the raid group change their tank/healer/dps role
    eventFrame:RegisterEvent("PLAYER_ROLES_ASSIGNED")

    if addon.Options.SortingMethod.TaintlessEnabled then
        hooksecurefunc("FlowContainer_DoLayout", OnLayout)
    end
end
