local _, addon = ...
local fsCompare = addon.Compare
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
local function CanSort(isRaid)
    if not IsInGroup() then
        return false
    end

    -- can't make changes during combat
    if InCombatLockdown() and not addon.Options.SortingMethod.TaintlessEnabled then
        fsLog:Warning("Cannot perform non-taintless sorting during combat.")
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

    if isRaid and fsFrame:KeepGroupsTogether(true) and not addon.Options.SortingMethod.TaintlessEnabled then
        fsLog:Warning("Cannot perform non-taintless sorting when the 'Keep Groups Together' setting is enabled.")
        return false
    end

    return true
end

---Determines whether party sorting can be performed.
---@return boolean
local function CanSortParty()
    return CompactPartyFrame and not CompactPartyFrame:IsForbidden() and CompactPartyFrame:IsVisible() and CanSort(false)
end

---Determines whether raid sorting can be performed.
---@return boolean
local function CanSortRaid()
    return CompactRaidFrameContainer and not CompactRaidFrameContainer:IsForbidden() and CompactRaidFrameContainer:IsVisible() and CanSort(true)
end

---Calls the post sorting callbacks.
local function InvokeCallbacks()
    for _, callback in pairs(callbacks) do
        callback()
    end
end

---Rearranges frames in order of the specified units.
---@param frames table[] the set of frames to rearrange.
---@param units string[] unit ids in the desired order.
local function RearrangeFrames(frames, units)
    local sorted = fsEnumerable
        :From(frames)
        :OrderBy(function(x, y)
            return fsCompare:CompareTopLeftFuzzy(x, y)
        end)
        :ToTable()
    local points = fsEnumerable
        :From(sorted)
        :Map(function(x)
            return fsPoint:GetPointEx(x)
        end)
        :ToTable()

    for unitIndex, unit in ipairs(units) do
        local _, frameIndex = fsEnumerable:From(sorted):First(function(f)
            return UnitIsUnit(f.unit, unit)
        end)

        if frameIndex and frameIndex ~= unitIndex then
            local from = points[frameIndex]
            local to = points[unitIndex]
            local frame = frames[frameIndex]

            if from.point == "TOPLEFT" and from.point == to.point and from.relativeTo == to.relativeTo and from.relativePoint == to.relativePoint then
                local xDelta = to.offsetX - from.offsetX
                local yDelta = to.offsetY - from.offsetY

                frame:AdjustPointsOffset(xDelta, yDelta)
            else
                fsLog:Error(string.format("Unable to move frame %s as it doesn't share to the same parent anchor.", frame:GetName()))
            end
        end
    end
end

---Rearranges the display of a frame chain in order of the specified units.
---@param frames table[] the set of frames to rearrange.
---@param units string[] unit ids in the desired order.
local function RearrangeFrameChain(frames, units)
    local points = fsEnumerable
        :From(frames)
        :OrderBy(function(x, y)
            return fsCompare:CompareTopLeftFuzzy(x, y)
        end)
        :Map(function(x)
            return {
                Top = x:GetTop(),
                Left = x:GetLeft(),
            }
        end)
        :ToTable()

    local chain = fsFrame:ToFrameChain(frames)
    if not chain.Valid then
        return
    end
    local current = chain

    while current do
        local source = current.Value
        local _, unitIndex = fsEnumerable:From(units):First(function(x)
            return UnitIsUnit(x, source.unit)
        end)

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

---Returns a sorted array of pet units from the given ordered player units.
---@param playerUnits string[]
---@param petUnits string[]
---@return string[] pet unit tokens
local function SortPets(playerUnits, petUnits)
    -- this is O(n^2) but it's tiny data so doesn't really matter
    -- might refactor in the future to a better algorithm
    return fsEnumerable
        :From(playerUnits)
        :Map(function(x)
            return x .. "pet"
        end)
        :Where(function(petFromPlayer)
            return fsEnumerable:From(petUnits):Any(function(pet)
                return UnitIsUnit(pet, petFromPlayer)
            end)
        end)
        :ToTable()
end

---Sorts raid pet frames.
---@return boolean sorted true if frames were sorted, otherwise false.
local function LayoutRaidPets(sortedPlayerUnits)
    local _, petFrames = fsFrame:GetRaidFrames()
    local petUnits = fsEnumerable
        :From(petFrames)
        :Map(function(x)
            return SecureButton_GetUnit(x)
        end)
        :OrderBy(sortFunction)
        :ToTable()

    local sorted = SortPets(sortedPlayerUnits, petUnits)

    RearrangeFrames(petFrames, sorted)

    return true
end

---Sorts raid frames.
---@return boolean sorted true if frames were sorted, otherwise false.
local function LayoutRaid()
    local sortFunction = fsCompare:GetSortFunction()
    local playerFrames = fsFrame:GetRaidFrames()

    if not sortFunction or #playerFrames == 0 then
        return false
    end

    local playerUnits = fsEnumerable
        :From(playerFrames)
        :Map(function(x)
            return SecureButton_GetUnit(x)
        end)
        :OrderBy(sortFunction)
        :ToTable()

    if fsFrame:KeepGroupsTogether(true) then
        local groups = fsFrame:GetRaidFrameGroups()

        for _, group in ipairs(groups) do
            local frames = fsFrame:GetRaidFrameGroupMembers(group)
            local groupUnits = fsEnumerable
                :From(frames)
                :Map(function(x)
                    return SecureButton_GetUnit(x)
                end)
                :OrderBy(sortFunction)
                :ToTable()
            RearrangeFrameChain(frames, groupUnits)
        end
    else
        RearrangeFrames(playerFrames, playerUnits)
    end

    return not fsFrame:ShowPets() or LayoutRaidPets(playerUnits)
end

---Sorts party pet frames.
---@return boolean sorted true if frames were sorted, otherwise false.
local function LayoutPartyPets(sortedPlayerUnits)
    -- firstly sort the frames
    local playerFrames, petFrames = fsFrame:GetPartyFrames()

    local chain = fsFrame:ToFrameChain(petFrames)
    if not chain.Valid then
        return false
    end

    local petUnits = fsEnumerable
        :From(petFrames)
        :Map(function(x)
            return SecureButton_GetUnit(x)
        end)
        :ToTable()
    local sortedPetUnits = SortPets(sortedPlayerUnits, petUnits)

    RearrangeFrameChain(petFrames, sortedPetUnits)

    -- next move the frame chain as a group beneath the player frames
    local rootPet = chain.Value

    if not fsFrame:HorizontalLayout(false) then
        local bottomFrame = fsEnumerable
            :From(playerFrames)
            :OrderBy(function(x, y)
                return fsCompare:CompareBottomLeftFuzzy(x, y)
            end)
            :First(function(x)
                return x:IsVisible()
            end)
        local topPetFrame = fsEnumerable
            :From(petFrames)
            :OrderBy(function(x, y)
                return fsCompare:CompareTopLeftFuzzy(x, y)
            end)
            :First(function(x)
                return x:IsVisible()
            end)

        local yDelta = bottomFrame:GetBottom() - topPetFrame:GetTop()
        rootPet:AdjustPointsOffset(0, yDelta)
    end

    return true
end

---Sorts party frames.
---@return boolean sorted true if frames were sorted, otherwise false.
local function LayoutParty()
    local sortFunction = fsCompare:GetSortFunction()
    local playerFrames, petFrames = fsFrame:GetPartyFrames()

    if not sortFunction or #playerFrames == 0 then
        return false
    end

    local playerUnits = fsEnumerable
        :From(playerFrames)
        :Map(function(x)
            return SecureButton_GetUnit(x)
        end)
        :OrderBy(sortFunction)
        :ToTable()

    RearrangeFrameChain(playerFrames, playerUnits)

    local shouldSortPets = fsFrame:ShowPets() and #petFrames > 0

    return not shouldSortPets or LayoutPartyPets(playerUnits)
end

---Attempts to sort the party/raid frames using the traditional method.
---@return boolean sorted true if sorted, otherwise false.
local function TrySortTraditional()
    local sortFunc = fsCompare:GetSortFunction()
    if sortFunc == nil then
        return false
    end

    local sorted = false

    if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
        if CanSortRaid() then
            CompactRaidFrameContainer:SetFlowSortFunction(sortFunc)
            sorted = true
        end

        if CanSortParty() then
            CompactPartyFrame:SetFlowSortFunction(sortFunc)
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

    if CanSortParty() then
        sorted = LayoutParty()
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
    if eventName == "PLAYER_REGEN_ENABLED" and not sortPending then
        return
    end

    M:TrySort()
end

---Event hook on blizzard performing frame layouts.
local function OnLayout()
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

    -- previously used FlowContainer_DoLayout but was encountering weird issues
    -- where frames didn't have x/y coords (perhaps too early in the loading process?)
    -- and also frames that didn't have units assigned
    if addon.Options.SortingMethod.TaintlessEnabled then
        if CompactRaidFrameContainer.LayoutFrames then
            -- retail
            hooksecurefunc(CompactRaidFrameContainer, "LayoutFrames", OnLayout)
        elseif CompactRaidFrameContainer_LayoutFrames then
            -- wotlk/classic
            hooksecurefunc("CompactRaidFrameContainer_LayoutFrames", OnLayout)
        end
    end
end
