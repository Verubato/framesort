---@type string, Addon
local _, addon = ...
local wow = addon.WoW.Api
local fsProviders = addon.Providers
local fsCompare = addon.Collections.Comparer
local fsFrame = addon.WoW.Frame
local fsEnumerable = addon.Collections.Enumerable
local fsMath = addon.Numerics.Math
local M = {}
addon.Modules.Sorting.Secure.NoCombat = M

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
    -- don't move frames if they are have minuscule position differences
    -- it's just a rounding error and makes no visual impact
    -- this helps preventing spam on our callbacks
    local decimalSanity = 2

    -- first clear their existing point
    for _, frame in ipairs(frames) do
        local to = points[frame]
        if to then
            local point, relativeTo, relativePoint, xOffset, yOffset = frame:GetPoint()
            local different =
                point ~= to.Point or
                relativeTo ~= to.RelativeTo or
                relativePoint ~= to.RelativePoint or
                fsMath:Round(xOffset, decimalSanity) ~= fsMath:Round(to.XOffset, decimalSanity) or
                fsMath:Round(yOffset, decimalSanity) ~= fsMath:Round(to.YOffset, decimalSanity)

            if different then
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
---@param spacing Spacing?
---@param sort boolean?
---@return boolean sorted
local function SoftArrange(frames, spacing, sort)
    if #frames == 0 then
        return false
    end

    if sort == nil then sort = true end

    local ordered = sort and fsEnumerable
        :From(frames)
        :OrderBy(function(x, y)
            return fsCompare:CompareTopLeftFuzzy(x, y)
        end)
        :ToTable() or frames
    local points = fsEnumerable
        :From(ordered)
        :Map(function(frame)
            return {
                Frame = frame,
                -- keep a copy of the frame positions before they are moved
                Top = frame:GetTop(),
                Left = frame:GetLeft(),
            }
        end)
        :ToTable()
    local pointsByFrame = fsEnumerable
        :From(points)
        :ToLookup(function(x) return x.Frame end, function(x) return x end)

    if spacing then
        local orderedTopLeft = fsEnumerable
            :From(frames)
            :OrderBy(function(x, y)
                return fsCompare:CompareTopLeftFuzzy(x, y)
            end)
            :ToTable()

        local yDelta = 0
        for i = 2, #orderedTopLeft do
            local frame = orderedTopLeft[i]
            local previous = orderedTopLeft[i - 1]
            local point = pointsByFrame[frame]
            local sameColumn = fsMath:Round(frame:GetLeft()) == fsMath:Round(previous:GetLeft())

            if sameColumn then
                local existingSpace = previous:GetBottom() - frame:GetTop()
                yDelta = yDelta - (existingSpace - spacing.Vertical)
                point.Top = point.Top - yDelta
            end
        end

        local orderedLeftTop = fsEnumerable
            :From(frames)
            :OrderBy(function(x, y)
                return fsCompare:CompareLeftTopFuzzy(x, y)
            end)
            :ToTable()

        local xDelta = 0
        for i = 2, #orderedLeftTop do
            local frame = orderedLeftTop[i]
            local previous = orderedTopLeft[i - 1]
            local point = pointsByFrame[frame]
            local sameRow = fsMath:Round(frame:GetTop()) == fsMath:Round(previous:GetTop())

            if sameRow then
                local existingSpace = previous:GetRight() - frame:GetLeft()
                xDelta = xDelta + (existingSpace + spacing.Horizontal)
                point.Left = point.Left + xDelta
            end
        end
    end

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
---@param spacing Spacing
---@param offset Offset?
---@return boolean sorted
local function HardArrange(frames, container, isHorizontalLayout, spacing, offset)
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
    -- the block size is the largest height and width combination
    -- this is only useful when we have frames of different sizes
    -- which is the case of pet frames, where 2 pet frames can fit into 1 player frame
    local blockHeight = tallestFrame:GetHeight()
    local blockWidth = widestFrame:GetWidth()

    offset = offset or {
        X = 0,
        Y = 0
    }

    if container.title and type(container.title) == "table" and type(container.title.GetHeight) == "function" then
        offset.Y = offset.Y - container.title:GetHeight()
    end

    ---@type table<table, Point>
    local pointsByFrame = {}
    local row, col = 1, 1
    local xOffset = offset.X
    local yOffset = offset.Y
    local rowHeight = 0
    local currentBlockHeight = 0

    for _, frame in ipairs(frames) do
        pointsByFrame[frame] = {
            Point = "TOPLEFT",
            RelativeTo = container,
            RelativePoint = "TOPLEFT",
            XOffset = xOffset,
            YOffset = yOffset
        }

        if isHorizontalLayout then
            col = (col + 1)
            xOffset = xOffset + blockWidth + spacing.Horizontal
            -- keep track of the tallest frame within the row
            -- as the next row will be the tallest row frame + spacing
            rowHeight = math.max(rowHeight, frame:GetHeight())

            -- if we've reached the end then wrap around
            if col > width then
                xOffset = offset.X
                yOffset = yOffset - rowHeight - spacing.Vertical

                row = row + 1
                col = 1
                rowHeight = 0
            end
        else
            currentBlockHeight = currentBlockHeight + frame:GetHeight()

            -- subtract 1 for a bit of breathing room for rounding errors
            local isNewRow = currentBlockHeight >= (blockHeight - 1)

            if isNewRow then
                currentBlockHeight = 0
            end

            if isNewRow then
                yOffset = yOffset - frame:GetHeight() - spacing.Vertical
                row = (row + 1)
            else
                -- don't add spacing if we're still within a block
                yOffset = yOffset - frame:GetHeight()
            end

            -- if we've reached the end then wrap around
            if row > height then
                row = 1
                col = col + 1
                yOffset = offset.Y
                xOffset = xOffset + blockWidth + spacing.Horizontal
            end
        end
    end

    return Move(frames, pointsByFrame)
end

---Determines the offset to use for the ungrouped portion of the raid frames.
---@param provider FrameProvider
---@return Offset
local function UngroupedOffset(provider, spacing)
    local offset = {
        X = 0,
        Y = 0
    }
    local container = provider:RaidContainer()
    local groups = provider:RaidGroups()
    local horizontal = provider:IsRaidHorizontalLayout()
    local frames = fsEnumerable
        :From(groups)
        :Map(function(group) return provider:RaidGroupMembers(group) end)
        :Flatten()
        :ToTable()

    if #frames == 0 then return offset end

    if horizontal then
        local bottomLeftFrame = fsEnumerable
            :From(frames)
            :OrderBy(function(x, y) return fsCompare:CompareBottomLeftFuzzy(x, y) end)
            :First()

        offset.Y = -(container:GetTop() - bottomLeftFrame:GetBottom() + spacing.Vertical)
        offset.X = -(container:GetLeft() - bottomLeftFrame:GetLeft())
    else
        local topRightFrame = fsEnumerable
            :From(frames)
            :OrderBy(function(x, y) return fsCompare:CompareTopRightFuzzy(x, y) end)
            :First()

        offset.X = -(container:GetLeft() - topRightFrame:GetRight() - spacing.Horizontal)
        offset.Y = -(container:GetTop() - topRightFrame:GetTop())
    end

    return offset
end

---@param provider FrameProvider
---@return boolean
local function SortRaid(provider)
    local getUnit = function(frame)
        return provider:GetUnit(frame)
    end

    local sorted = false
    local offset = {
        X = 0,
        Y = 0
    }
    local container = provider:RaidContainer()
    if not container then return false end

    local horizontal = provider:IsRaidHorizontalLayout()
    local spacing = addon.DB.Options.Appearance.Raid.Spacing

    if provider:IsRaidGrouped() then
        local groups = provider:RaidGroups()

        for _, group in ipairs(groups) do
            local frames = provider:RaidGroupMembers(group)
            local units = fsEnumerable:From(frames):Map(getUnit):ToTable()
            local sortFunction = FrameSortFunction(fsCompare:SortFunction(units), provider)

            table.sort(frames, sortFunction)

            local sortedGroup = false

            if provider == fsProviders.Blizzard then
                sortedGroup = HardArrange(frames, group, horizontal, spacing)
            else
                sortedGroup = SoftArrange(frames)
            end

            sorted = sorted or sortedGroup
        end

        if provider == fsProviders.Blizzard then
            local spacedGroups = SoftArrange(groups, spacing, false)
            sorted = sorted or spacedGroups

            local ungroupedOffset = UngroupedOffset(provider, spacing)
            offset.X = offset.X + ungroupedOffset.X
            offset.Y = offset.Y + ungroupedOffset.Y
        end
    end

    local ungrouped = provider:RaidFrames()
    local ungroupedUnits = fsEnumerable:From(ungrouped):Map(getUnit):ToTable()
    local ungroupedSortFunction = FrameSortFunction(fsCompare:SortFunction(ungroupedUnits), provider)

    table.sort(ungrouped, ungroupedSortFunction)

    local sortedUngrouped = false

    if provider == fsProviders.Blizzard then
        sortedUngrouped = HardArrange(ungrouped, container, horizontal, spacing, offset)
    else
        sortedUngrouped = SoftArrange(ungrouped, spacing)
    end

    sorted = sorted or sortedUngrouped

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
    local spacing = addon.DB.Options.Appearance.Party.Spacing

    table.sort(frames, sortFunction)

    if provider == fsProviders.Blizzard then
        return HardArrange(frames, provider:PartyContainer(), provider:IsPartyHorizontalLayout(), spacing)
    else
        return SoftArrange(frames)
    end
end

---@param provider FrameProvider
---@return boolean
local function SortEnemyArena(provider)
    local sortFunction = FrameSortFunction(fsCompare:EnemySortFunction(), provider)
    local frames = provider:EnemyArenaFrames()
    table.sort(frames, sortFunction)

    local spacing = provider == fsProviders.Blizzard
        and addon.DB.Options.Appearance.EnemyArena.Spacing
        or nil

    return SoftArrange(frames, spacing)
end

---@param provider FrameProvider?
---@return boolean
function M:TrySort(provider)
    local friendlyEnabled, _, _, _ = fsCompare:FriendlySortMode()
    local enemyEnabled, _, _ = fsCompare:EnemySortMode()
    local sorted = false

    local providers = provider and { provider } or fsProviders:Enabled()

    for _, p in ipairs(providers) do
        if friendlyEnabled then
            local sortedParty = SortParty(p)
            local sortedRaid = SortRaid(p)

            sorted = sorted or sortedParty or sortedRaid
        end

        if enemyEnabled and wow.IsRetail() then
            local arenaSorted = SortEnemyArena(p)
            sorted = sorted or arenaSorted
        end
    end

    return sorted
end
