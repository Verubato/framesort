---@type string, Addon
local _, addon = ...
local wow = addon.WoW.Api
local fsCompare = addon.Collections.Comparer
local fsFrame = addon.WoW.Frame
local fsEnumerable = addon.Collections.Enumerable
local fsProviders = addon.Providers
local fsConfig = addon.Configuration
local fsLog = addon.Logging.Log
local M = {}
addon.Modules.Sorting.Core = M

local function FrameSortFunction(unitSortFunction, provider)
    return function(left, right)
        local leftUnit = provider:GetUnit(left)
        local rightUnit = provider:GetUnit(right)

        return unitSortFunction(leftUnit, rightUnit)
    end
end

---@return boolean sorted
---@param frames table[]
---@param points table<table, Point>
local function Move(frames, points)
    local framesToMove = {}
    -- first clear their existing point
    for _, frame in ipairs(frames) do
        local to = points[frame]
        if to then
            local point, relativeTo, relativePoint, xOffset, yOffset = frame:GetPoint()

            if point ~= to.Point or relativeTo ~= to.RelativeTo or relativePoint ~= to.RelativePoint or xOffset ~= to.XOffset or yOffset ~= to.YOffset then
                framesToMove[#framesToMove + 1] = frame
                frame:ClearAllPoints()
            end
        end
    end

    -- now move them
    for _, frame in ipairs(framesToMove) do
        local to = points[frame]
        frame:SetPoint(to.Point, to.RelativeTo, to.RelativePoint, to.XOffset, to.YOffset)
    end

    return #framesToMove > 0
end

---Rearranges frames by only modifying the X/Y offsets and not changing any point anchors.
---@param frames table[]
---@return boolean sorted
local function SoftArrange(frames)
    if #frames == 0 then
        return false
    end

    local ordered = fsEnumerable
        :From(frames)
        :OrderBy(function(x, y)
            return fsCompare:CompareTopLeftFuzzy(x, y)
        end)
        :ToTable()
    -- keep a copy of the frame positions before they are moved
    local points = fsEnumerable
        :From(ordered)
        :Map(function(frame)
            return {
                Top = frame:GetTop(),
                Left = frame:GetLeft()
            }
        end)
        :ToTable()

    local enumerationOrder = frames
    local chain = fsFrame:ToFrameChain(frames)
    if chain.Valid then
        enumerationOrder = fsFrame:FramesFromChain(chain)
    end

    local movedAny = false
    for _, source in ipairs(enumerationOrder) do
        local desiredIndex = fsEnumerable:From(frames):IndexOf(source)
        local destination = points[desiredIndex]
        local xDelta = destination.Left - source:GetLeft()
        local yDelta = destination.Top - source:GetTop()

        if xDelta ~= 0 or yDelta ~= 0 then
            source:AdjustPointsOffset(xDelta, yDelta)
            movedAny = true
        end
    end

    return movedAny
end

---Rearranges frames by modifying their entire anchor point.
---@param frames table[]
---@param container table
---@param isHorizontalLayout boolean
---@param spacing table
---@return boolean sorted
local function HardArrange(frames, container, isHorizontalLayout, spacing)
    if #frames == 0 then
        return false
    end

    local width, height = fsFrame:GridSize(frames)
    local tallestFrame = fsEnumerable:From(frames):Max(function(x)
        return x:GetHeight()
    end)
    local widestFrame = fsEnumerable:From(frames):Max(function(x)
        return x:GetWidth()
    end)
    local blockHeight = tallestFrame:GetHeight()
    local blockWidth = widestFrame:GetWidth()
    local top = 0

    if container.title and type(container.title) == "table" and type(container.title.GetHeight) == "function" then
        top = container.title:GetHeight()
    end

    ---@type table<table, Point>
    local pointsByFrame = {}
    local row, col = 1, 1
    local xOffset = 0
    local yOffset = 0
    local currentBlockHeight = 0

    for _, frame in ipairs(frames) do
        pointsByFrame[frame] = {
            Point = "TOPLEFT",
            RelativeTo = container,
            RelativePoint = "TOPLEFT",
            XOffset = xOffset,
            YOffset = yOffset - top
        }

        currentBlockHeight = currentBlockHeight + frame:GetHeight()
        -- subtract 1 for a bit of breathing room for rounding errors
        local isNewBlock = currentBlockHeight >= (blockHeight - 1)

        if isNewBlock then
            currentBlockHeight = 0
        end

        if isHorizontalLayout then
            col = (col + 1)
            xOffset = xOffset + blockWidth + spacing.Horizontal

            -- if we've reached the end then wrap around
            if col > width then
                row = row + 1
                col = 1
                xOffset = 0
                yOffset = yOffset - blockHeight - spacing.Vertical
            end
        else
            row = (row + 1)

            if isNewBlock then
                yOffset = yOffset - blockHeight - spacing.Vertical
            else
                -- don't add spacing if we're still within a block
                yOffset = yOffset - frame:GetHeight()
            end

            -- if we've reached the end then wrap around
            if row > height then
                row = 1
                col = col + 1
                yOffset = 0
                xOffset = xOffset + blockWidth + spacing.Horizontal
            end
        end
    end

    return Move(frames, pointsByFrame)
end

---Rearranges frames using the provider's layout strategy.
---@param provider FrameProvider
---@param frames table[]
---@param container table
---@param isHorizontalLayout boolean
---@param spacing table
---@return boolean sorted
local function Arrange(provider, frames, container, isHorizontalLayout, spacing)
    if #frames == 0 then return false end

    local strat = provider:LayoutStrategy()

    if strat == fsConfig.LayoutStrategy.Soft then
        return SoftArrange(frames)
    elseif strat == fsConfig.LayoutStrategy.Hard then
        return HardArrange(frames, container, isHorizontalLayout, spacing)
    else
        fsLog:Error(string.format("Unknown layout strategy %d for provider %s ", strat, provider:Name()))
        return false
    end
end

---@param provider FrameProvider
---@return boolean
local function SortRaid(provider)
    local getUnit = function(frame)
        return provider:GetUnit(frame)
    end

    local ungrouped = provider:RaidFrames()
    local ungroupedUnits = fsEnumerable:From(ungrouped):Map(getUnit):ToTable()
    local ungroupedSortFunction = FrameSortFunction(fsCompare:SortFunction(ungroupedUnits), provider)

    table.sort(ungrouped, ungroupedSortFunction)

    local sorted = Arrange(provider, ungrouped, provider:RaidContainer(), provider:IsRaidHorizontalLayout(), addon.DB.Options.Appearance.Raid.Spacing)

    if not provider:IsRaidGrouped() then
        return sorted
    end

    local groups = provider:RaidGroups()

    for _, group in ipairs(groups) do
        local frames = provider:RaidGroupMembers(group)
        local units = fsEnumerable:From(frames):Map(getUnit):ToTable()
        local sortFunction = FrameSortFunction(fsCompare:SortFunction(units), provider)

        table.sort(frames, sortFunction)

        local sortedGroup = Arrange(provider, frames, group, provider:IsRaidHorizontalLayout(), addon.DB.Options.Appearance.Raid.Spacing)
        sorted = sorted or sortedGroup
    end

    return sorted
end

---@param provider FrameProvider
---@return boolean
local function SortParty(provider)
    local getUnit = function(frame)
        return provider:GetUnit(frame)
    end
    local frames = provider:PartyFrames()
    local units = fsEnumerable:From(frames):Map(getUnit):ToTable()
    local sortFunction = FrameSortFunction(fsCompare:SortFunction(units), provider)

    table.sort(frames, sortFunction)

    return Arrange(provider, frames, provider:PartyContainer(), provider:IsPartyHorizontalLayout(), addon.DB.Options.Appearance.Party.Spacing)
end

---@param provider FrameProvider
---@return boolean
local function SortEnemyArena(provider)
    local sortFunction = FrameSortFunction(fsCompare:EnemySortFunction(), provider)
    local frames = provider:EnemyArenaFrames()
    table.sort(frames, sortFunction)

    return Arrange(provider, frames, provider:EnemyArenaContainer(), provider:IsEnemyArenaHorizontalLayout(), addon.DB.Options.Appearance.EnemyArena.Spacing)
end

---@param provider FrameProvider
---@return boolean
function M:TrySort(provider)
    local friendlyEnabled, _, _, _ = fsCompare:FriendlySortMode()
    local enemyEnabled, _, _ = fsCompare:EnemySortMode()
    local sorted = false

    if friendlyEnabled then
        local sortedParty = SortParty(provider)
        local sortedRaid = SortRaid(provider)

        sorted = sorted or sortedParty or sortedRaid
    end

    if enemyEnabled and wow.IsRetail() then
        local arenaSorted = SortEnemyArena(provider)
        sorted = sorted or arenaSorted
    end

    return sorted
end
