---@type string, Addon
local _, addon = ...
local wow = addon.WoW.Api
local fsUnit = addon.WoW.Unit
local fsCompare = addon.Collections.Comparer
local fsFrame = addon.WoW.Frame
local fsEnumerable = addon.Collections.Enumerable
local fsLog = addon.Logging.Log
local fsConfig = addon.Configuration
local fsSorting = addon.Modules.Sorting
local fsProviders = addon.Providers
local M = {}
addon.Modules.Sorting.Taintless = M

local frameRefreshEvents = {
    wow.Events.UNIT_PET,
    wow.Events.GROUP_ROSTER_UPDATE,
}

---Moves the frame to the new positions.
---@param enumerateOrder table[] the enumeration order for applying the spacing.
---@param points table<table, Coordinate>
local function Move(enumerateOrder, points)
    local movedAny = false
    for _, source in ipairs(enumerateOrder) do
        local to = points[source]
        if to then
            local xDelta = to.X - source:GetLeft()
            local yDelta = to.Y - source:GetTop()

            if xDelta ~= 0 or yDelta ~= 0 then
                source:AdjustPointsOffset(xDelta, yDelta)
                movedAny = true
            end
        end
    end

    return movedAny
end

local function Sort(name, frames, layoutTypeHint, points)
    if #frames == 0 then
        return false
    end

    local sorted = false
    if layoutTypeHint == fsConfig.LayoutType.Flat then
        if fsFrame:IsFlat(frames) then
            return Move(frames, points)
        end

        local chain = fsFrame:ToFrameChain(frames)
        if chain.Valid then
            local enumerateOrder = fsFrame:FramesFromChain(chain)
            sorted = Move(enumerateOrder, points)

            fsLog:Debug(string.format("Layout hint for frames '%s' is flat but was it was actually a chain.", name))
            return sorted
        end
    elseif layoutTypeHint == fsConfig.LayoutType.Chain then
        local chain = fsFrame:ToFrameChain(frames)
        if chain.Valid then
            local enumerateOrder = fsFrame:FramesFromChain(chain)
            sorted = Move(enumerateOrder, points)
            return sorted
        end

        if fsFrame:IsFlat(frames) then
            sorted = Move(frames, points)
            fsLog:Debug(string.format("Layout hint for frames '%s' is a chain but was it was actually flat.", name))
            return sorted
        end
    end

    fsLog:Error(string.format("Unable to sort frames '%s' as they aren't arranged in one of the supported layout types.", name))
    return false
end

---Sorts raid frames.
---@param provider FrameProvider
---@param points table<table, Coordinate>
---@return boolean sorted true if frames were sorted, otherwise false.
local function SortRaid(provider, points)
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

            if Sort(group:GetName(), frames, fsConfig.LayoutType.Chain, points) then
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

    return Sort("Raid", players, fsConfig.LayoutType.Flat, points)
end

---Sorts party frames.
---@param provider FrameProvider
---@param points table<table, Coordinate>
---@return boolean sorted true if frames were sorted, otherwise false.
local function SortParty(provider, points)
    local sortedPlayers = false
    local frames = provider:PartyFrames()

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

    sortedPlayers = Sort("Party-Players", players, fsConfig.LayoutType.Chain, points)

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

    local sortedPets = Sort("Party-Pets", pets, fsConfig.LayoutType.Chain, points)
    return sortedPlayers or sortedPets
end

---Sorts enemy arena frames.
---@param provider FrameProvider
---@param points table<table, Coordinate>
---@return boolean sorted true if frames were sorted, otherwise false.
local function SortEnemyArena(provider, points)
    local frames = provider:EnemyArenaFrames()
    local players = fsEnumerable
        :From(frames)
        :Where(function(frame)
            local unit = provider:GetUnit(frame)

            return unit and not fsUnit:IsPet(unit)
        end)
        :ToTable()

    return Sort("EnemyArena-Players", players, fsConfig.LayoutType.Chain, points)
end

local function BlockFrameUpdates(container)
    for _, event in ipairs(frameRefreshEvents) do
        container:UnregisterEvent(event)
    end
end

local function EnableFrameUpdates(container)
    for _, event in ipairs(frameRefreshEvents) do
        container:RegisterEvent(event)
    end
end

local function OnCombatEnded()
    local containers = {
        fsProviders.Blizzard:PartyContainer(),
        fsProviders.Blizzard:RaidContainer(),
        fsProviders.Blizzard:EnemyArenaContainer(),
    }

    for _, container in ipairs(containers) do
        if container then
            EnableFrameUpdates(container)
        end
    end
end

local function OnCombatStarting()
    local containers = {
        fsProviders.Blizzard:PartyContainer(),
        fsProviders.Blizzard:RaidContainer(),
        fsProviders.Blizzard:EnemyArenaContainer(),
    }

    for _, container in ipairs(containers) do
        if container then
            BlockFrameUpdates(container)
        end
    end
end

local function OnEvent(_, event)
    if event == wow.Events.PLAYER_REGEN_ENABLED then
        OnCombatEnded()
    elseif event == wow.Events.PLAYER_REGEN_DISABLED then
        OnCombatStarting()
    end
end

---Attempts to sort frames.
---@return boolean sorted true if sorted, otherwise false.
---@param provider FrameProvider the provider to sort.
function M:TrySort(provider)
    local sorted = false
    local points = fsSorting.Positions:Points(provider)
    local friendlyEnabled, _, _, _ = fsCompare:FriendlySortMode()
    local enemyEnabled, _, _ = fsCompare:EnemySortMode()

    if friendlyEnabled then
        local sortedParty = SortParty(provider, points)
        local sortedRaid = SortRaid(provider, points)

        sorted = sorted or sortedRaid or sortedParty
    end

    if enemyEnabled and wow.IsRetail() then
        local arenaSorted = SortEnemyArena(provider, points)
        sorted = sorted or arenaSorted
    end

    return sorted
end

function M:Init()
    local eventFrame = wow.CreateFrame("Frame")
    eventFrame:HookScript("OnEvent", OnEvent)
    eventFrame:RegisterEvent(wow.Events.PLAYER_REGEN_ENABLED)
    eventFrame:RegisterEvent(wow.Events.PLAYER_REGEN_DISABLED)
end
