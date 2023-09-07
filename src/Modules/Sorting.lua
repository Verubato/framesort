---@type string, Addon
local _, addon = ...
local wow = addon.WoW.Api
local fsScheduler = addon.Scheduling.Scheduler
local fsUnit = addon.WoW.Unit
local fsCompare = addon.Collections.Comparer
local fsFrame = addon.WoW.Frame
local fsEnumerable = addon.Collections.Enumerable
local fsLog = addon.Logging.Log
local fsConfig = addon.Configuration
local fsProviders = addon.Providers
local callbacks = {}
---@class SortingModule: Initialise
local M = {}
addon.Modules.Sorting = M

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
            return x == unit or wow.UnitIsUnit(x, unit)
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
    if layoutTypeHint == fsConfig.LayoutType.Flat then
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
    elseif layoutTypeHint == fsConfig.LayoutType.Chain then
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
                return wow.UnitIsUnit(pet, petFromPlayer)
            end)
        end)
        :ToTable()
end

---Sorts raid frames.
---@param provider FrameProvider
---@return boolean sorted true if frames were sorted, otherwise false.
local function SortRaid(provider)
    local sorted = false

    local getUnit = function(frame)
        return provider:GetUnit(frame)
    end

    if provider:IsRaidGrouped() then
        local groups = provider:RaidGroups()
        if #groups == 0 then
            return false
        end

        for _, group in ipairs(groups) do
            local frames = provider:RaidGroupMembers(group)
            local units = fsEnumerable:From(frames):Map(getUnit):ToTable()
            local sortFunction = fsCompare:SortFunction(units)

            table.sort(units, sortFunction)

            if Sort(group:GetName(), frames, fsConfig.LayoutType.Chain, units, getUnit) then
                sorted = true
            end
        end

        return sorted
    end

    local frames = provider:RaidFrames()
    local players = fsEnumerable
        :From(frames)
        :Where(function(frame)
            local unit = provider:GetUnit(frame)
            -- a unit can be both a player and a pet
            -- e.g. when occupying a vehicle
            -- so we want to filter out the pets
            return unit and wow.UnitIsPlayer(unit) and not fsUnit:IsPet(unit)
        end)
        :ToTable()

    local units = fsEnumerable:From(players):Map(getUnit):ToTable()
    local sortFunction = fsCompare:SortFunction(units)

    table.sort(units, sortFunction)

    return Sort("Raid", players, fsConfig.LayoutType.Flat, units, getUnit)
end

---Sorts party pet frames.
---@return boolean sorted true if frames were sorted, otherwise false.
local function SortPartyPets(provider, sortedPlayerUnits, playerFrames, petFrames)
    local getUnit = function(frame)
        return provider:GetUnit(frame)
    end
    local petUnits = fsEnumerable:From(petFrames):Map(getUnit):ToTable()
    local sortedPetUnits = SortPetUnits(sortedPlayerUnits, petUnits)
    local sorted = Sort("Party-Pets", petFrames, fsConfig.LayoutType.Chain, sortedPetUnits, getUnit)

    local chain = fsFrame:ToFrameChain(petFrames)
    if not chain.Valid then
        return sorted
    end

    -- next move the frame chain as a group beneath the player frames
    local rootPet = chain.Value
    assert(rootPet ~= nil)

    if fsFrame:IsHorizontalLayout(playerFrames) then
        local leftPlayer = fsEnumerable
            :From(playerFrames)
            :OrderBy(function(x, y)
                return fsCompare:CompareBottomLeftFuzzy(x, y)
            end)
            :First(function(x)
                return x:IsVisible()
            end)

        if not leftPlayer then
            return sorted
        end

        local leftPet = fsEnumerable
            :From(petFrames)
            :OrderBy(function(x, y)
                return fsCompare:CompareBottomLeftFuzzy(x, y)
            end)
            :First(function(x)
                return x:IsVisible()
            end)

        if not leftPet then
            return sorted
        end

        local xDelta = leftPlayer:GetLeft() - leftPet:GetLeft()

        if xDelta ~= 0 then
            rootPet:AdjustPointsOffset(xDelta, 0)
            sorted = true
        end
    else
        local bottomPlayer = fsEnumerable
            :From(playerFrames)
            :OrderBy(function(x, y)
                return fsCompare:CompareBottomLeftFuzzy(x, y)
            end)
            :First(function(x)
                return x:IsVisible()
            end)

        if not bottomPlayer then
            return sorted
        end

        local topPet = fsEnumerable
            :From(petFrames)
            :OrderBy(function(x, y)
                return fsCompare:CompareTopLeftFuzzy(x, y)
            end)
            :First(function(x)
                return x:IsVisible()
            end)

        if not topPet then
            return sorted
        end

        local yDelta = bottomPlayer:GetBottom() - topPet:GetTop()
        if yDelta ~= 0 then
            rootPet:AdjustPointsOffset(0, yDelta)
            sorted = true
        end
    end

    return sorted
end

---Sorts party frames.
---@param provider FrameProvider
---@return boolean sorted true if frames were sorted, otherwise false.
local function SortParty(provider)
    local sortedPlayers = false
    local frames = provider:PartyFrames()
    local getUnit = function(frame)
        return provider:GetUnit(frame)
    end

    local players = fsEnumerable
        :From(frames)
        :Where(function(frame)
            local unit = provider:GetUnit(frame)

            if not unit then
                return false
            end

            -- a unit can be both a player and a pet
            -- e.g. when occupying a vehicle
            -- so we want to filter out the pets
            if fsUnit:IsPet(unit) then
                return false
            end

            -- might be in test mode
            if not wow.IsInGroup() then
                return true
            end

            return wow.UnitIsPlayer(unit)
        end)
        :ToTable()

    local playerUnits = fsEnumerable:From(players):Map(getUnit):ToTable()
    local sortFunction = fsCompare:SortFunction(playerUnits)

    table.sort(playerUnits, sortFunction)

    sortedPlayers = Sort("Party-Players", players, fsConfig.LayoutType.Chain, playerUnits, getUnit)

    if not provider:ShowPartyPets() then
        return sortedPlayers
    end

    local pets = fsEnumerable
        :From(frames)
        :Where(function(frame)
            if not frame:IsVisible() then
                return false
            end

            local unit = provider:GetUnit(frame)
            return unit and fsUnit:IsPet(unit)
        end)
        :ToTable()

    local sortedPets = SortPartyPets(provider, playerUnits, players, pets)
    return sortedPlayers or sortedPets
end

---Sorts enemy arena frames.
---@param provider FrameProvider
---@return boolean sorted true if frames were sorted, otherwise false.
local function SortEnemyArena(provider)
    local sortFunction = fsCompare:EnemySortFunction()
    local getUnit = function(frame)
        return provider:GetUnit(frame)
    end
    local frames = provider:EnemyArenaFrames()
    local players = fsEnumerable
        :From(frames)
        :Where(function(frame)
            local unit = provider:GetUnit(frame)

            return unit and not fsUnit:IsPet(unit)
        end)
        :ToTable()

    local playerUnits = fsEnumerable:From(players):Map(getUnit):OrderBy(sortFunction):ToTable()

    return Sort("EnemyArena-Players", players, fsConfig.LayoutType.Chain, playerUnits, getUnit)
end

---Attempts to sort Blizzard frames using the traditional method.
---@return boolean sorted true if sorted, otherwise false.
local function TrySortTraditional()
    local enabled, _, _, _ = fsCompare:FriendlySortMode()
    if not enabled then
        return false
    end

    local sorted = false
    local sortFunction = fsCompare:SortFunction()

    if wow.IsRetail() then
        if wow.CompactRaidFrameContainer and not wow.CompactRaidFrameContainer:IsForbidden() and wow.CompactRaidFrameContainer:IsVisible() then
            wow.CompactRaidFrameContainer:SetFlowSortFunction(sortFunction)
            sorted = true
        end

        if wow.CompactPartyFrame and not wow.CompactPartyFrame:IsForbidden() and wow.CompactPartyFrame:IsVisible() then
            wow.CompactPartyFrame:SetFlowSortFunction(sortFunction)
            sorted = sorted or true
        end
    else
        if wow.CompactRaidFrameContainer and not wow.CompactRaidFrameContainer:IsForbidden() and wow.CompactRaidFrameContainer:IsVisible() then
            wow.CompactRaidFrameContainer_SetFlowSortFunction(wow.CompactRaidFrameContainer, sortFunction)
            sorted = true
        end
    end

    return sorted
end

function TrySortTaintless(provider)
    local sorted = false
    local friendlyEnabled, _, _, _ = fsCompare:FriendlySortMode()
    local enemyEnabled, _, _ = fsCompare:EnemySortMode()

    if friendlyEnabled then
        local sortedParty = SortParty(provider)
        local sortedRaid = SortRaid(provider)

        sorted = sorted or sortedRaid or sortedParty
    end

    if enemyEnabled and wow.IsRetail() then
        local arenaSorted = SortEnemyArena(provider)
        sorted = sorted or arenaSorted
    end

    return sorted
end

local function OnProviderRequiresSort(provider)
    M:TrySort(provider)
end

---Register a callback to invoke after sorting has been performed.
---@param callback function
function M:RegisterPostSortCallback(callback)
    callbacks[#callbacks + 1] = callback
end

---Attempts to sort all frames.
---@return boolean sorted true if sorted, otherwise false.
---@param provider FrameProvider? optionally specify the provider to sort, otherwise sorts all providers.
function M:TrySort(provider)
    local friendlyEnabled, _, _, _ = fsCompare:FriendlySortMode()
    local enemyEnabled, _, _ = fsCompare:EnemySortMode()

    if not friendlyEnabled and not enemyEnabled then
        return false
    end

    if wow.InCombatLockdown() then
        fsLog:Warning("Cannot perform sorting during combat.")
        -- can't make changes during combat
        fsScheduler:RunWhenCombatEnds(function()
            M:TrySort(provider)
        end)

        return false
    end

    if wow.IsRetail() and wow.EditModeManagerFrame.editModeActive then
        fsLog:Debug("Not sorting while edit mode active.")
        return false
    end

    local sorted = false
    local providers = provider and { provider } or fsProviders:Enabled()

    for _, p in ipairs(providers) do
        local providerSorted = false

        if p == fsProviders.Blizzard and addon.DB.Options.SortingMethod.TraditionalEnabled then
            providerSorted = TrySortTraditional()
        else
            providerSorted = TrySortTaintless(p)
        end

        sorted = sorted or providerSorted
    end

    if sorted then
        InvokeCallbacks()
    end

    return sorted
end

function M:Init()
    if #callbacks > 0 then
        callbacks = {}
    end

    for _, provider in ipairs(fsProviders:Enabled()) do
        provider:RegisterCallback(OnProviderRequiresSort)
    end
end
