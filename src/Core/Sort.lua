local _, addon = ...
local fsUnit = addon.Unit
local fsCompare = addon.Compare
local fsFrame = addon.Frame
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

    if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
        if EditModeManagerFrame.editModeActive then
            fsLog:Debug("Not sorting while edit mode active.")
            return false
        end
    end

    if not addon.Options.SortingMethod.TaintlessEnabled and (isRaid and fsFrame:IsRaidGrouped() or (not isRaid and fsFrame:IsPartyGrouped())) then
        fsLog:Warning("Cannot perform non-taintless sorting when the 'Keep Groups Together' setting is enabled.")
        return false
    end

    local _, enabled = fsCompare:GetSortFunction()
    return enabled
end

---Determines whether party sorting can be performed.
---@return boolean
local function CanSortParty()
    local container = fsFrame:GetPartyFramesContainer()
    return container and not container:IsForbidden() and container:IsVisible() and CanSort(false)
end

---Determines whether raid sorting can be performed.
---@return boolean
local function CanSortRaid()
    local container = fsFrame:GetRaidFramesContainer()
    return container and not container:IsForbidden() and container:IsVisible() and CanSort(true)
end

---Calls the post sorting callbacks.
local function InvokeCallbacks()
    for _, callback in pairs(callbacks) do
        pcall(callback)
    end
end

---Rearranges frames in order of the specified units.
---@param frames table[] the set of frames to rearrange.
---@param enumerateOrder table[] the enumeration order for applying the spacing.
---@param units string[] unit ids in the desired order.
---@param getUnit fun(frame: table): string function to extract the unit from the given frame
local function RearrangeFrames(frames, enumerateOrder, units, getUnit)
    local sorted = fsEnumerable
        :From(frames)
        :OrderBy(function(x, y)
            return fsCompare:CompareTopLeftFuzzy(x, y)
        end)
        :ToTable()
    local points = fsEnumerable
        :From(sorted)
        :Map(function(x)
            return {
                Top = x:GetTop(),
                Left = x:GetLeft(),
            }
        end)
        :ToTable()

    for _, source in ipairs(enumerateOrder) do
        local _, unitIndex = fsEnumerable:From(units):First(function(x)
            return UnitIsUnit(x, getUnit(source))
        end)

        if unitIndex then
            local to = points[unitIndex]
            local from = { Top = source:GetTop(), Left = source:GetLeft() }
            local xDelta = to.Left - from.Left
            local yDelta = to.Top - from.Top

            source:AdjustPointsOffset(xDelta, yDelta)
        end
    end
end

local function Sort(name, frames, layoutTypeHint, units, getUnit)
    if #frames == 0 then
        return false
    end

    if layoutTypeHint == addon.LayoutType.Flat then
        if fsFrame:IsFlat(frames) then
            RearrangeFrames(frames, frames, units, getUnit)
            return true
        end

        local chain = fsFrame:ToFrameChain(frames)
        if chain.Valid then
            local enumerateOrder = fsFrame:FramesFromChain(chain)
            RearrangeFrames(frames, enumerateOrder, units, getUnit)

            fsLog:Debug(string.format("Layout hint for frames '%s' is flat but was it was actually a chain.", name))
            return true
        end
    elseif layoutTypeHint == addon.LayoutType.Chain then
        local chain = fsFrame:ToFrameChain(frames)
        if chain.Valid then
            local enumerateOrder = fsFrame:FramesFromChain(chain)
            RearrangeFrames(frames, enumerateOrder, units, getUnit)
            return true
        end

        if fsFrame:IsFlat(frames) then
            RearrangeFrames(frames, frames, units, getUnit)
            fsLog:Debug(string.format("Layout hint for frames '%s' is a chain but was it was actually flat.", name))
            return true
        end
    end

    fsLog:Error(string.format("Unable to sort frames '%s' as they aren't arranged in one of the supported layout types.", name))
    return false
end

---Returns a sorted array of pet units from the given ordered player units.
---@param playerUnits string[]
---@param petUnits string[]
---@return string[] pet unit tokens
local function SortPetUnits(playerUnits, petUnits)
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

---Sorts raid frames.
---@return boolean sorted true if frames were sorted, otherwise false.
local function SortRaid()
    local sortFunction = fsCompare:GetSortFunction()

    if fsFrame:IsRaidGrouped() then
        local groups = fsFrame:GetRaidGroups()
        if #groups == 0 then
            return false
        end

        for _, group in ipairs(groups) do
            local frames, getUnit = fsFrame:GetRaidGroupMembers(group)
            local units = fsEnumerable:From(frames):Map(getUnit):OrderBy(sortFunction):ToTable()

            if not Sort(group:GetName(), frames, addon.LayoutType.Chain, units, getUnit) then
                return false
            end
        end

        return true
    end

    local frames, getUnit = fsFrame:GetRaidFrames()
    local players = fsEnumerable
        :From(frames)
        :Where(function(frame)
            local unit = getUnit(frame)
            -- a unit can be both a player and a pet
            -- e.g. when occupying a vehicle
            -- so we want to filter out the pets
            return UnitIsPlayer(unit) and not fsUnit:IsPet(unit)
        end)
        :ToTable()

    local units = fsEnumerable:From(players):Map(getUnit):OrderBy(sortFunction):ToTable()

    return Sort("Raid", players, addon.LayoutType.Flat, units, getUnit)
end

---Sorts party pet frames.
---@return boolean sorted true if frames were sorted, otherwise false.
local function SortPartyPets(sortedPlayerUnits, playerFrames, petFrames, getUnit)
    local petUnits = fsEnumerable:From(petFrames):Map(getUnit):ToTable()
    local sortedPetUnits = SortPetUnits(sortedPlayerUnits, petUnits)

    if not Sort("Party-Pets", petFrames, addon.LayoutType.Chain, sortedPetUnits, getUnit) then
        return false
    end

    local chain = fsFrame:ToFrameChain(petFrames)
    if not chain.Valid then
        return false
    end

    -- next move the frame chain as a group beneath the player frames
    local rootPet = chain.Value
    if fsFrame:PartyHorizontalLayout() then
        local leftPlayer = fsEnumerable
            :From(playerFrames)
            :OrderBy(function(x, y)
                return fsCompare:CompareBottomLeftFuzzy(x, y)
            end)
            :First()

        local leftPet = fsEnumerable
            :From(petFrames)
            :OrderBy(function(x, y)
                return fsCompare:CompareBottomLeftFuzzy(x, y)
            end)
            :First()

        local xDelta = leftPlayer:GetLeft() - leftPet:GetLeft()
        rootPet:AdjustPointsOffset(xDelta, 0)
    else
        local bottomPlayer = fsEnumerable
            :From(playerFrames)
            :OrderBy(function(x, y)
                return fsCompare:CompareBottomLeftFuzzy(x, y)
            end)
            :First()

        local topPet = fsEnumerable
            :From(petFrames)
            :OrderBy(function(x, y)
                return fsCompare:CompareTopLeftFuzzy(x, y)
            end)
            :First()

        local yDelta = bottomPlayer:GetBottom() - topPet:GetTop()
        rootPet:AdjustPointsOffset(0, yDelta)
    end

    return true
end

---Sorts party frames.
---@return boolean sorted true if frames were sorted, otherwise false.
local function SortParty()
    local sortFunction = fsCompare:GetSortFunction()
    local frames, getUnit = fsFrame:GetPartyFrames()
    local players = fsEnumerable
        :From(frames)
        :Where(function(frame)
            local unit = getUnit(frame)
            -- a unit can be both a player and a pet
            -- e.g. when occupying a vehicle
            -- so we want to filter out the pets
            return UnitIsPlayer(unit) and not fsUnit:IsPet(unit)
        end)
        :ToTable()

    local playerUnits = fsEnumerable:From(players):Map(getUnit):OrderBy(sortFunction):ToTable()

    if not Sort("Party-Players", players, addon.LayoutType.Chain, playerUnits, getUnit) then
        return false
    end

    if not fsFrame:ShowPets() then
        return true
    end

    local pets = fsEnumerable
        :From(frames)
        :Where(function(frame)
            local unit = getUnit(frame)
            return fsUnit:IsPet(unit)
        end)
        :ToTable()

    return SortPartyPets(playerUnits, players, pets, getUnit)
end

---Attempts to sort the party/raid frames using the traditional method.
---@return boolean sorted true if sorted, otherwise false.
local function TrySortTraditional()
    local sorted = false
    local sortFunction = fsCompare:GetSortFunction()
    local partyContainer = fsFrame:GetPartyFramesContainer()
    local raidContainer = fsFrame:GetRaidFramesContainer()

    if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
        if CanSortRaid() then
            raidContainer:SetFlowSortFunction(sortFunction)
            sorted = true
        end

        if CanSortParty() then
            partyContainer:SetFlowSortFunction(sortFunction)
            sorted = sorted or true
        end
    else
        if CanSortRaid() then
            CompactRaidFrameContainer_SetFlowSortFunction(raidContainer, sortFunction)
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
        sorted = SortParty()
    end

    if CanSortRaid() then
        sorted = sorted or SortRaid()
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

---Event hook on exiting edit mode.
local function OnEditModeExited()
    M:TrySort()
end

---Register a callback to invoke after sorting has been performed.
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
    eventFrame:RegisterEvent(addon.Events.PLAYER_REGEN_ENABLED)
    eventFrame:RegisterEvent(addon.Events.PLAYER_ENTERING_WORLD)
    eventFrame:RegisterEvent(addon.Events.GROUP_ROSTER_UPDATE)
    eventFrame:RegisterEvent(addon.Events.PLAYER_ROLES_ASSIGNED)
    eventFrame:RegisterEvent(addon.Events.UNIT_PET)

    if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
        EventRegistry:RegisterCallback(addon.Events.EditModeExit, OnEditModeExited)
    end
end
