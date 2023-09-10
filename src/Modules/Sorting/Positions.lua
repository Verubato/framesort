---@type string, Addon
local _, addon = ...
local wow = addon.WoW.Api
local fsUnit = addon.WoW.Unit
local fsCompare = addon.Collections.Comparer
local fsFrame = addon.WoW.Frame
local fsEnumerable = addon.Collections.Enumerable
local M = {}
addon.Modules.Sorting.Positions = M

local function MergeTable(from, into)
    for key, value in pairs(from) do
        into[key] = value
    end
end

---Returns a key value pair collection of frame -> adjustment.
---@param frames table[] the set of frames to rearrange.
---@param units string[] unit ids in the desired order.
---@param getUnit fun(frame: table): string function to extract the unit from the given frame
---@return table<table, Coordinate>
local function FramePoints(frames, units, getUnit)
    local points = {}
    local sorted = fsEnumerable
        :From(frames)
        :OrderBy(function(x, y)
            return fsCompare:CompareTopLeftFuzzy(x, y)
        end)
        :ToTable()
    local ordered = fsEnumerable
        :From(sorted)
        :Map(function(x)
            return {
                Top = x:GetTop(),
                Left = x:GetLeft(),
            }
        end)
        :ToTable()

    for _, source in ipairs(frames) do
        local _, unitIndex = fsEnumerable:From(units):First(function(x)
            local unit = getUnit(source)
            return x == unit or wow.UnitIsUnit(x, unit)
        end)

        assert(unitIndex ~= nil)

        local to = ordered[unitIndex]

        points[source] = {
            X = to.Left,
            Y = to.Top,
        }
    end

    return points
end

---@param provider FrameProvider
---@return table<table, Coordinate>
local function RaidPoints(provider)
    local getUnit = function(frame)
        return provider:GetUnit(frame)
    end

    if provider:IsRaidGrouped() then
        local adjustments = {}
        local groups = provider:RaidGroups()

        if #groups == 0 then
            return adjustments
        end

        for _, group in ipairs(groups) do
            local frames = provider:RaidGroupMembers(group)
            local units = fsEnumerable:From(frames):Map(getUnit):ToTable()
            local sortFunction = fsCompare:SortFunction(units)

            table.sort(units, sortFunction)

            local groupAdjustments = FramePoints(frames, units, getUnit)
            MergeTable(groupAdjustments, adjustments)
        end

        return adjustments:ToTable()
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

    return FramePoints(players, units, getUnit)
end

---@return table<table, Coordinate>
local function PartyPetPoints(provider, sortedPlayerUnits, playerFrames, petFrames)
    local getUnit = function(frame)
        return provider:GetUnit(frame)
    end
    local petUnits = fsEnumerable:From(petFrames):Map(getUnit):ToTable()
    -- this is O(n^2) but it's tiny data so doesn't really matter
    -- might refactor in the future to a better algorithm
    local sortedPetUnits = fsEnumerable
        :From(sortedPlayerUnits)
        :Map(function(x)
            return x .. "pet"
        end)
        :Where(function(petFromPlayer)
            return fsEnumerable:From(petUnits):Any(function(pet)
                return wow.UnitIsUnit(pet, petFromPlayer)
            end)
        end)
        :ToTable()
    local adjustments = FramePoints(petFrames, sortedPetUnits, getUnit)

    local chain = fsFrame:ToFrameChain(petFrames)
    if not chain.Valid then
        return adjustments
    end

    -- next move the frame chain as a group beneath the player frames
    local rootPet = chain.Value
    assert(rootPet ~= nil)

    local rootAdjustment = adjustments[rootPet]
    if not rootAdjustment then
        rootAdjustment = {
            X = 0,
            Y = 0,
        }
        adjustments[rootPet] = rootAdjustment
    end

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
            return adjustments
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
            return adjustments
        end

        local xDelta = leftPlayer:GetLeft() - leftPet:GetLeft()

        if xDelta ~= 0 then
            rootAdjustment.X = rootAdjustment.X + xDelta
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
            return adjustments
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
            return adjustments
        end

        local yDelta = bottomPlayer:GetBottom() - topPet:GetTop()
        if yDelta ~= 0 then
            rootAdjustment.Y = rootAdjustment.Y + yDelta
        end
    end

    return adjustments
end

---@param provider FrameProvider
---@return table<table, Coordinate>
local function PartyPoints(provider)
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

    local adjustments = FramePoints(players, playerUnits, getUnit)

    if not provider:ShowPartyPets() then
        return adjustments
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

    local petAdjustments = PartyPetPoints(provider, playerUnits, players, pets)
    MergeTable(petAdjustments, adjustments)

    return adjustments
end

---@param provider FrameProvider
---@return table<table, Coordinate>
local function EnemyArenaPoints(provider)
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

    return FramePoints(players, playerUnits, getUnit)
end

function M:Points(provider)
    local friendlyEnabled, _, _, _ = fsCompare:FriendlySortMode()
    local enemyEnabled, _, _ = fsCompare:EnemySortMode()
    local points = {}

    if friendlyEnabled then
        local party = PartyPoints(provider)
        local raid = RaidPoints(provider)

        MergeTable(party, points)
        MergeTable(raid, points)
    end

    if enemyEnabled and wow.IsRetail() then
        local arena = EnemyArenaPoints(provider)

        MergeTable(arena, points)
    end

    return points
end
