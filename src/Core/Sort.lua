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

local function CanSort()
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

    local enabled, _, _, _ = fsCompare:SortMode()

    if not enabled then
        return false
    end

    return true
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

    local movedAny = false
    for _, source in ipairs(enumerateOrder) do
        local _, unitIndex = fsEnumerable:From(units):First(function(x)
            local unit = getUnit(source)
            return x == unit or UnitIsUnit(x, unit)
        end)

        if unitIndex then
            local to = points[unitIndex]
            local from = { Top = source:GetTop(), Left = source:GetLeft() }
            local xDelta = to.Left - from.Left
            local yDelta = to.Top - from.Top

            if xDelta ~= 0 or yDelta ~= 0 then
                source:AdjustPointsOffset(xDelta, yDelta)
                movedAny = true
            end
        end
    end

    return movedAny
end

local function Sort(name, frames, layoutTypeHint, units, getUnit)
    if #frames == 0 then
        return false
    end

    local sorted = false
    if layoutTypeHint == addon.LayoutType.Flat then
        if fsFrame:IsFlat(frames) then
            sorted = RearrangeFrames(frames, frames, units, getUnit)
            return sorted
        end

        local chain = fsFrame:ToFrameChain(frames)
        if chain.Valid then
            local enumerateOrder = fsFrame:FramesFromChain(chain)
            sorted = RearrangeFrames(frames, enumerateOrder, units, getUnit)

            fsLog:Debug(string.format("Layout hint for frames '%s' is flat but was it was actually a chain.", name))
            return sorted
        end
    elseif layoutTypeHint == addon.LayoutType.Chain then
        local chain = fsFrame:ToFrameChain(frames)
        if chain.Valid then
            local enumerateOrder = fsFrame:FramesFromChain(chain)
            sorted = RearrangeFrames(frames, enumerateOrder, units, getUnit)
            return sorted
        end

        if fsFrame:IsFlat(frames) then
            sorted = RearrangeFrames(frames, frames, units, getUnit)
            fsLog:Debug(string.format("Layout hint for frames '%s' is a chain but was it was actually flat.", name))
            return sorted
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
    local sorted = false

    if fsFrame:RaidGrouped() then
        local groups = fsFrame:RaidGroups()
        if #groups == 0 then
            return false
        end

        for _, group in ipairs(groups) do
            local frames, getUnit = fsFrame:RaidGroupMembers(group)
            local units = fsEnumerable:From(frames):Map(getUnit):ToTable()
            local sortFunction = fsCompare:SortFunction(units)

            table.sort(units, sortFunction)

            if Sort(group:GetName(), frames, addon.LayoutType.Chain, units, getUnit) then
                sorted = true
            end
        end

        return sorted
    end

    local frames, getUnit = fsFrame:RaidFrames()
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

    local units = fsEnumerable:From(players):Map(getUnit):ToTable()
    local sortFunction = fsCompare:SortFunction(units)

    table.sort(units, sortFunction)

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
    local sortedPlayers = false
    local frames, getUnit = fsFrame:PartyFrames()
    local players = fsEnumerable
        :From(frames)
        :Where(function(frame)
            local unit = getUnit(frame)

            -- might be in test mode
            if not IsInGroup() then
                return not fsUnit:IsPet(unit)
            end

            -- a unit can be both a player and a pet
            -- e.g. when occupying a vehicle
            -- so we want to filter out the pets
            return UnitIsPlayer(unit) and not fsUnit:IsPet(unit)
        end)
        :ToTable()

    local playerUnits = fsEnumerable:From(players):Map(getUnit):ToTable()
    local sortFunction = fsCompare:SortFunction(playerUnits)

    table.sort(playerUnits, sortFunction)

    sortedPlayers = Sort("Party-Players", players, addon.LayoutType.Chain, playerUnits, getUnit)

    if not fsFrame:ShowPartyPets() then
        return sortedPlayers
    end

    local pets = fsEnumerable
        :From(frames)
        :Where(function(frame)
            local unit = getUnit(frame)
            return fsUnit:IsPet(unit)
        end)
        :ToTable()

    local sortedPets = SortPartyPets(playerUnits, players, pets, getUnit)
    return sortedPlayers or sortedPets
end

---Sorts enemy arena frames.
---@return boolean sorted true if frames were sorted, otherwise false.
local function SortEnemyArena()
    local sortFunction = fsCompare:EnemySortFunction()
    local frames, getUnit = fsFrame:EnemyArenaFrames()
    local players = fsEnumerable
        :From(frames)
        :Where(function(frame)
            local unit = getUnit(frame)

            -- might be in test mode
            if not IsInGroup() then
                return not fsUnit:IsPet(unit)
            end
            -- a unit can be both a player and a pet
            -- e.g. when occupying a vehicle
            -- so we want to filter out the pets
            return UnitIsPlayer(unit) and not fsUnit:IsPet(unit)
        end)
        :ToTable()

    local playerUnits = fsEnumerable:From(players):Map(getUnit):OrderBy(sortFunction):ToTable()

    return Sort("EnemyArena-Players", players, addon.LayoutType.Chain, playerUnits, getUnit)
end

---Attempts to sort Blizzard frames using the traditional method.
---@return boolean sorted true if sorted, otherwise false.
local function TrySortTraditional()
    if fsFrame:RaidGrouped() or fsFrame:PartyGrouped() then
        fsLog:Warning("Cannot perform traditional sorting when the 'Keep Groups Together' setting is enabled.")
        return false
    end

    local sorted = false
    local sortFunction = fsCompare:SortFunction()

    if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
        if addon.FrameProviders.Blizzard:RaidFramesEnabled() then
            CompactRaidFrameContainer:SetFlowSortFunction(sortFunction)
            sorted = true
        end

        if addon.FrameProviders.Blizzard:PartyFramesEnabled() then
            CompactPartyFrame:SetFlowSortFunction(sortFunction)
            sorted = sorted or true
        end
    else
        if addon.FrameProviders.Blizzard:RaidFramesEnabled() then
            CompactRaidFrameContainer_SetFlowSortFunction(CompactRaidFrameContainer, sortFunction)
            sorted = true
        end
    end

    return sorted
end

---Attempts to sort frames using the taintless method.
---@return boolean sorted true if sorted, otherwise false.
local function TrySortTaintless()
    local sortedParty = SortParty()
    local sortedRaid = SortRaid()

    return sortedParty or sortedRaid
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

---Attempts to sort all frames.
---@return boolean sorted true if sorted, otherwise false.
function M:TrySort()
    if not CanSort() then
        return false
    end

    local sorted = false

    if addon.Options.SortingMethod.TaintlessEnabled then
        sorted = TrySortTaintless()
    elseif addon.FrameProviders.Blizzard:Enabled() then
        sorted = TrySortTraditional()
    end

    if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
        local arenaSorted = SortEnemyArena()
        sorted = sorted or arenaSorted
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
