---@type string, Addon
local _, addon = ...
local fsProviders = addon.Providers
local fsCompare = addon.Collections.Comparer
local fsFrame = addon.WoW.Frame
local fsUnit = addon.WoW.Unit
local fsEnumerable = addon.Collections.Enumerable
local fsMath = addon.Numerics.Math
local fsLog = addon.Logging.Log
local wow = addon.WoW.Api
local M = {}
addon.Modules.Sorting.Secure.NoCombat = M

local function FrameSortFunction(unitSortFunction)
    return function(left, right)
        local leftUnit = fsFrame:GetFrameUnit(left)
        local rightUnit = fsFrame:GetFrameUnit(right)

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
                fsMath:Round(xOffset or 0, decimalSanity) ~= fsMath:Round(to.XOffset or 0, decimalSanity) or
                fsMath:Round(yOffset or 0, decimalSanity) ~= fsMath:Round(to.YOffset or 0, decimalSanity)

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
---@return boolean sorted
local function SoftArrange(frames, spacing)
    if #frames == 0 then
        return false
    end

    local ordered = fsEnumerable
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
---@param framesPerLine number?
---@param spacing Spacing?
---@param offset Offset?
---@return boolean sorted
local function HardArrange(frames, container, isHorizontalLayout, framesPerLine, spacing, offset)
    if #frames == 0 then
        return false
    end

    -- the block size is the largest height and width combination
    -- this is only useful when we have frames of different sizes
    -- which is the case of pet frames, where 2 pet frames can fit into 1 player frame
    -- we could find max height/width, but this should almost certaintly be equal to the first frame in the array
    -- so save the cpu cycles and just use the first frame
    local blockHeight, blockWidth = frames[1]:GetHeight(), frames[1]:GetWidth()

    offset = offset or {
        X = 0,
        Y = 0
    }

    spacing = spacing or {
        Vertical = 0,
        Horizontal = 0
    }

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
            if framesPerLine and col > framesPerLine then
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
            if framesPerLine and row > framesPerLine then
                row = 1
                col = col + 1
                yOffset = offset.Y
                xOffset = xOffset + blockWidth + spacing.Horizontal
            end
        end
    end

    return Move(frames, pointsByFrame)
end

---@param container FrameContainer
---@return boolean
local function SetNameList(container)
    local isFriendly = container.Type == fsFrame.ContainerType.Party or container.Type == fsFrame.ContainerType.Raid
    local units = isFriendly and fsUnit:FriendlyUnits(true) or fsUnit:EnemyUnits(true)
    local sortFunction = fsCompare:SortFunction(units)

    table.sort(units, sortFunction)

    -- groupFilter must be set to nil for nameList to be used
    container.Frame:SetAttribute("groupFilter", nil)
    container.Frame:SetAttribute("sortMethod", "NAMELIST")

    local names = ""

    for i, unit in ipairs(units) do
        local unitName = wow.GetUnitName(unit, true)

        if i > 1 then
            names = names .. "," .. unitName
        else
            names = unitName
        end
    end

    local existingNameList = container.Frame:GetAttribute("nameList")

    if existingNameList == names then
        return false
    end

    container.Frame:SetAttribute("nameList", names)
    return true
end

---Determines the offset to use for the ungrouped portion of the raid frames.
---@param container FrameContainer
---@return Offset
local function UngroupedOffset(container, spacing)
    local offset = {
        X = 0,
        Y = 0
    }
    local groups = fsFrame:ExtractGroups(container.Frame)
    local horizontal = container.IsHorizontalLayout and container:IsHorizontalLayout()
    local frames = fsEnumerable
        :From(groups)
        :Map(function(group) return fsFrame:ExtractUnitFrames(group, container.VisibleOnly) end)
        :Flatten()
        :ToTable()

    if #frames == 0 then return offset end

    if horizontal then
        local bottomLeftFrame = fsEnumerable
            :From(frames)
            :OrderBy(function(x, y) return fsCompare:CompareBottomLeftFuzzy(x, y) end)
            :First()

        offset.Y = -(container.Frame:GetTop() - bottomLeftFrame:GetBottom() + spacing.Vertical)
        offset.X = -(container.Frame:GetLeft() - bottomLeftFrame:GetLeft())
    else
        local topRightFrame = fsEnumerable
            :From(frames)
            :OrderBy(function(x, y) return fsCompare:CompareTopRightFuzzy(x, y) end)
            :First()

        offset.X = -(container.Frame:GetLeft() - topRightFrame:GetRight() - spacing.Horizontal)
        offset.Y = -(container.Frame:GetTop() - topRightFrame:GetTop())
    end

    return offset
end

---@param container FrameContainer
---@return boolean
local function TrySortContainer(container)
    if container.LayoutType == fsFrame.LayoutType.NameList then
        return SetNameList(container)
    end

    local frames = fsFrame:ExtractUnitFrames(container.Frame, container.VisibleOnly)
    local sortFunction = nil

    if container.Type == fsFrame.ContainerType.Party or
        container.Type == fsFrame.ContainerType.Raid then
        local units = fsEnumerable:From(frames):Map(function(frame) return fsFrame:GetFrameUnit(frame) end):ToTable()
        local unitSortFunction = fsCompare:SortFunction(units)
        sortFunction = FrameSortFunction(unitSortFunction)
    elseif container.Type == fsFrame.ContainerType.EnemyArena then
        local unitSortFunction = fsCompare:EnemySortFunction()
        sortFunction = FrameSortFunction(unitSortFunction)
    else
        fsLog:Error("Unknown container type: " .. (container.Type or "nil"))
        return false
    end

    table.sort(frames, sortFunction)

    local spacing = nil

    if container.SupportsSpacing then
        local config = addon.DB.Options.Spacing
        if container.Type == fsFrame.ContainerType.Party then
            spacing = config.Party
        elseif container.Type == fsFrame.ContainerType.Raid then
            spacing = config.Raid
        elseif container.Type == fsFrame.ContainerType.EnemyArena then
            spacing = config.EnemyArena
        end
    end

    if container.LayoutType == fsFrame.LayoutType.Soft then
        return SoftArrange(frames, spacing)
    elseif container.LayoutType == fsFrame.LayoutType.Hard then
        return HardArrange(
            frames,
            container.Frame,
            container.IsHorizontalLayout and container:IsHorizontalLayout() or false,
            container.FramesPerLine and container:FramesPerLine(),
            spacing,
            container.FramesOffset and container:FramesOffset())
    else
        fsLog:Error("Unknown layout type: " .. (container.Type or "nil"))
        return false
    end
end

---@param container FrameContainer
---@return boolean
local function TrySortContainerGroups(container)
    local sorted = false
    local groups = fsFrame:ExtractGroups(container.Frame, container.VisibleOnly)

    if #groups == 0 then
        return false
    end

    for _, group in ipairs(groups) do
        ---@type FrameContainer
        local groupContainer = {
            Frame = group,
            Type = container.Type,
            IsHorizontalLayout = function() return container.IsHorizontalLayout and container:IsHorizontalLayout() end,
            VisibleOnly = container.VisibleOnly,
            LayoutType = container.LayoutType,
            SupportsSpacing = container.SupportsSpacing,
            FramesPerLine = container.FramesPerLine,
            -- we want to use the group frames offset here
            FramesOffset = function() return container.GroupFramesOffset and container:GroupFramesOffset() end,
            GroupFramesOffset = function() return nil end,
            IsGrouped = function() return false end,
        }

        sorted = TrySortContainer(groupContainer) or sorted
    end

    local spacing = nil
    if container.SupportsSpacing then
        local config = addon.DB.Options.Spacing
        if container.Type == fsFrame.ContainerType.Party then
            spacing = config.Party
        elseif container.Type == fsFrame.ContainerType.Raid then
            spacing = config.Raid
        elseif container.Type == fsFrame.ContainerType.EnemyArena then
            spacing = config.EnemyArena
        end
    end

    if container.SupportsSpacing and spacing then
        sorted = SoftArrange(groups, spacing) or sorted
    end

    -- ungrouped frames include pets, vehicles, and main tank/assist frames
    local ungroupedOffset = UngroupedOffset(container, spacing)
    local ungroupedContainer = {
        Frame = container.Frame,
        Type = container.Type,
        IsHorizontalLayout = function() return container.IsHorizontalLayout and container:IsHorizontalLayout() end,
        VisibleOnly = container.VisibleOnly,
        LayoutType = container.LayoutType,
        SupportsSpacing = container.SupportsSpacing,
        FramesPerLine = container.FramesPerLine,
        -- we want to use the group frames offset here
        FramesOffset = function() return ungroupedOffset end,
        GroupFramesOffset = function() return nil end,
        IsGrouped = function() return false end,
    }

    sorted = TrySortContainer(ungroupedContainer) or sorted

    return sorted
end

---@param provider FrameProvider?
---@return boolean
function M:TrySort(provider)
    assert(not wow.InCombatLockdown())

    local friendlyEnabled, _, _, _ = fsCompare:FriendlySortMode()
    local enemyEnabled, _, _ = fsCompare:EnemySortMode()

    if not friendlyEnabled and not enemyEnabled then
        return false
    end

    local sorted = false
    local providers = provider and { provider } or fsProviders:Enabled()

    for _, p in ipairs(providers) do
        local containers = p:Containers()

        for _, container in ipairs(containers) do
            if ((container.Type == fsFrame.ContainerType.Party or container.Type == fsFrame.ContainerType.Raid) and friendlyEnabled) or
                (container.Type == fsFrame.ContainerType.EnemyArena and enemyEnabled) then
                if container.IsGrouped and container:IsGrouped() then
                    sorted = TrySortContainerGroups(container) or sorted
                else
                    sorted = TrySortContainer(container) or sorted
                end
            end
        end
    end

    return sorted
end
