---@type string, Addon
local _, addon = ...
local fsProviders = addon.Providers
local fsCompare = addon.Modules.Sorting.Comparer
local fsFrame = addon.WoW.Frame
local fsUnit = addon.WoW.Unit
local fsSortedUnits = addon.Modules.Sorting.SortedUnits
local fsEnumerable = addon.Collections.Enumerable
local fsMath = addon.Numerics.Math
local fsLog = addon.Logging.Log
local wow = addon.WoW.Api
local M = {}
addon.Modules.Sorting.Secure.NoCombat = M

local function SortFramesByUnits(frames, sortedUnits)
    local unitsToIndex = {}
    for index, unit in ipairs(sortedUnits) do
        unitsToIndex[unit] = index
    end

    table.sort(frames, function(leftFrame, rightFrame)
        -- not sure why sometimes we get null arguments here, but it does happen on very rare occasions
        -- https://github.com/Verubato/framesort/issues/33
        if not leftFrame then
            return false
        end
        if not rightFrame then
            return true
        end

        if fsFrame:IsForbidden(leftFrame) then
            return false
        end

        if fsFrame:IsForbidden(rightFrame) then
            return true
        end

        local leftUnit = fsFrame:GetFrameUnit(leftFrame)
        local rightUnit = fsFrame:GetFrameUnit(rightFrame)

        if not leftUnit then
            return false
        end

        if not rightUnit then
            return true
        end

        local leftIndex = unitsToIndex[leftUnit]
        local rightIndex = unitsToIndex[rightUnit]

        if leftIndex and rightIndex and leftIndex ~= rightIndex then
            return leftIndex < rightIndex
        end

        -- from here on out, pretty much only happens in test/edit mode
        if leftFrame:IsVisible() and not rightFrame:IsVisible() then
            return true
        elseif not leftFrame:IsVisible() and rightFrame:IsVisible() then
            return false
        end

        local leftName = leftFrame:GetName()
        local rightName = rightFrame:GetName()

        if leftName and rightName then
            return leftName < rightName
        end

        return leftUnit < rightUnit
    end)
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
            local different = point ~= to.Point
                or relativeTo ~= to.RelativeTo
                or relativePoint ~= to.RelativePoint
                or fsMath:Round(xOffset or 0, decimalSanity) ~= fsMath:Round(to.XOffset or 0, decimalSanity)
                or fsMath:Round(yOffset or 0, decimalSanity) ~= fsMath:Round(to.YOffset or 0, decimalSanity)

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

---Applies spacing on a set of points.
---@param frames table[]
---@param spacing Spacing
---@param pointsByFrame table<table, Point>
local function ApplySpacing(frames, spacing, pointsByFrame)
    local orderedTopLeft = fsEnumerable
        :From(frames)
        :OrderBy(function(x, y)
            return fsCompare:CompareTopLeftFuzzy(x, y)
        end)
        :ToTable()

    local horizontalSpacing = spacing.Horizontal or 0
    local verticalSpacing = spacing.Vertical or 0

    local yDelta = 0
    for i = 2, #orderedTopLeft do
        local frame = orderedTopLeft[i]
        local previous = orderedTopLeft[i - 1]
        local point = pointsByFrame[frame]
        local sameColumn = fsMath:Round(frame:GetLeft()) == fsMath:Round(previous:GetLeft())

        if sameColumn then
            local existingSpace = previous:GetBottom() - frame:GetTop()
            yDelta = yDelta - (existingSpace - verticalSpacing)
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
        local previous = orderedLeftTop[i - 1]
        local point = pointsByFrame[frame]
        local sameRow = fsMath:Round(frame:GetTop()) == fsMath:Round(previous:GetTop())

        if sameRow then
            local existingSpace = previous:GetRight() - frame:GetLeft()
            xDelta = xDelta + (existingSpace + horizontalSpacing)
            point.Left = point.Left + xDelta
        end
    end
end

---Applies spacing to a set of groups that contain frames.
---@param frames table[]
---@return boolean sorted
local function SpaceGroups(frames, spacing)
    if #frames == 0 then
        return false
    end

    local points = fsEnumerable
        :From(frames)
        :OrderBy(function(x, y)
            return fsCompare:CompareTopLeftFuzzy(x, y)
        end)
        :Map(function(frame)
            return {
                Frame = frame,
                -- keep a copy of the frame positions before they are moved
                Top = frame:GetTop(),
                Left = frame:GetLeft(),
            }
        end)
        :ToTable()
    local pointsByFrame = fsEnumerable:From(points):ToDictionary(function(x)
        return x.Frame
    end, function(x)
        return x
    end)

    ApplySpacing(frames, spacing, pointsByFrame)

    local movedAny = false
    for _, source in ipairs(frames) do
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

---Rearranges frames by only modifying the X/Y offsets and not changing any point anchors.
---@param frames table[]
---@return boolean sorted
local function SoftArrange(frames, spacing)
    if #frames == 0 then
        return false
    end

    local points = fsEnumerable
        :From(frames)
        :OrderBy(function(x, y)
            return fsCompare:CompareTopLeftFuzzy(x, y)
        end)
        :Map(function(frame)
            return {
                Frame = frame,
                -- keep a copy of the frame positions before they are moved
                Top = frame:GetTop(),
                Left = frame:GetLeft(),
            }
        end)
        :ToTable()

    if spacing then
        local pointsByFrame = fsEnumerable:From(points):ToDictionary(function(x)
            return x.Frame
        end, function(x)
            return x
        end)

        ApplySpacing(frames, spacing, pointsByFrame)
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
---@param container FrameContainer
---@param frames table[]
---@param spacing Spacing?
---@param offset Offset?
---@param blockHeight number?
---@return boolean sorted
local function HardArrange(container, frames, spacing, offset, blockHeight)
    if #frames == 0 then
        return false
    end

    local start = wow.GetTimePreciseSec()
    local relativeTo = container.Anchor or container.Frame
    local isHorizontalLayout = container.IsHorizontalLayout and container:IsHorizontalLayout() or false
    local blocksPerLine = container.FramesPerLine and container:FramesPerLine()
    local anchorPoint = container.AnchorPoint or "TOPLEFT"

    offset = offset or (container.FramesOffset and container:FramesOffset())

    -- the block size is the largest height and width combination
    -- this is only useful when we have frames of different sizes
    -- which is the case of pet frames, where 2 pet frames can fit into 1 player frame
    -- we could find max height/width, but this should almost certaintly be equal to the first frame in the array
    -- so save the cpu cycles and just use the first frame
    blockHeight = blockHeight or frames[1]:GetHeight()
    local blockWidth = frames[1]:GetWidth()

    offset = offset or {
        X = 0,
        Y = 0,
    }

    spacing = spacing or {
        Vertical = 0,
        Horizontal = 0,
    }

    ---@type table<table, Point>
    local pointsByFrame = {}
    local row, col = 0, 0
    local xOffset = offset.X
    local yOffset = offset.Y
    local currentBlockHeight = 0

    for _, frame in ipairs(frames) do
        local isNewBlock = currentBlockHeight > 0
            -- add/subtract 1 for a bit of breathing room for rounding errors
            and (currentBlockHeight >= (blockHeight - 1) or (currentBlockHeight + frame:GetHeight()) >= (blockHeight + 1))

        if isNewBlock then
            currentBlockHeight = 0

            if isHorizontalLayout then
                col = col + 1
            else
                row = row + 1
            end

            xOffset = col * (blockWidth + spacing.Horizontal) + offset.X
            yOffset = -row * (blockHeight + spacing.Vertical) + offset.Y
        end

        -- if we've reached the end then wrap around
        if isHorizontalLayout and blocksPerLine and col >= blocksPerLine then
            col = 0
            row = row + 1

            xOffset = offset.X
            yOffset = -row * (blockHeight + spacing.Vertical) + offset.Y
            currentBlockHeight = 0
        elseif not isHorizontalLayout and blocksPerLine and row >= blocksPerLine then
            row = 0
            col = col + 1

            yOffset = offset.Y
            xOffset = col * (blockWidth + spacing.Horizontal) + offset.X
            currentBlockHeight = 0
        end

        pointsByFrame[frame] = {
            Point = anchorPoint,
            RelativeTo = relativeTo,
            RelativePoint = anchorPoint,
            XOffset = xOffset,
            YOffset = yOffset,
        }

        currentBlockHeight = currentBlockHeight + frame:GetHeight()
        yOffset = yOffset - frame:GetHeight()
    end

    local moved = Move(frames, pointsByFrame)
    local stop = wow.GetTimePreciseSec()
    fsLog:Debug("Moving %d frames for container %s took %fms.", #frames, container.Frame:GetName() or "nil", (stop - start) * 1000)

    return moved
end

---@param container FrameContainer
---@return boolean
local function SetNameList(container)
    local isFriendly = container.Type == fsFrame.ContainerType.Party or container.Type == fsFrame.ContainerType.Raid
    local units = isFriendly and fsSortedUnits:FriendlyUnits() or fsSortedUnits:EnemyUnits()

    if isFriendly and #units == 0 then
        -- ensure player always exists for friendly units
        -- as they might be showing party frames even when not in a party in order to shown their own frame
        units = { "player" }
    end

    if container.ShowUnit then
        local filtered = fsEnumerable
            :From(units)
            :Where(function(unit)
                return container:ShowUnit(unit)
            end)
            :ToTable()

        units = filtered
    end

    local previousSortMethod = container.Frame:GetAttribute("sortMethod")
    local previousGroupFilter = container.Frame:GetAttribute("groupFilter")

    container.Frame:SetAttribute("FrameSortHasSorted", true)
    container.Frame:SetAttribute("FrameSortPreviousSortMethod", previousSortMethod)
    container.Frame:SetAttribute("FrameSortPreviousGroupFilter", previousGroupFilter)

    -- groupFilter must be set to nil for nameList to be used
    container.Frame:SetAttribute("groupFilter", nil)
    container.Frame:SetAttribute("sortMethod", "NAMELIST")

    local unitNames = fsEnumerable
        :From(units)
        :Map(function(unit)
            return wow.GetUnitName(unit, true)
        end)
        :ToTable()

    local names = wow.strjoin(",", unitNames)
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
        Y = 0,
    }

    local groups = fsFrame:ExtractGroups(container.Frame)
    local horizontal = container.IsHorizontalLayout and container:IsHorizontalLayout()

    spacing = spacing or {
        Horizontal = 0,
        Vertical = 0,
    }

    local lastGroup = fsEnumerable:From(groups):Reverse():First(function(x)
        return x:IsVisible()
    end)

    if not lastGroup then
        return offset
    end

    local frames = fsFrame:ExtractUnitFrames(lastGroup, container.VisibleOnly, container.ExistsOnly)

    if #frames == 0 then
        return offset
    end

    if horizontal then
        local bottomLeftFrame = fsEnumerable
            :From(frames)
            :OrderBy(function(x, y)
                return fsCompare:CompareBottomLeftFuzzy(x, y)
            end)
            :First()

        offset.Y = -(container.Frame:GetTop() - bottomLeftFrame:GetBottom() + spacing.Vertical)
        offset.X = -(container.Frame:GetLeft() - bottomLeftFrame:GetLeft())
    else
        local topRightFrame = fsEnumerable
            :From(frames)
            :OrderBy(function(x, y)
                return fsCompare:CompareTopRightFuzzy(x, y)
            end)
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

    local sortedUnits = nil
    local frames = (container.Frames and container:Frames()) or fsFrame:ExtractUnitFrames(container.Frame, true, container.VisibleOnly)

    if #frames <= 1 then
        return false
    end

    if container.Type == fsFrame.ContainerType.Party or container.Type == fsFrame.ContainerType.Raid then
        sortedUnits = fsSortedUnits:FriendlyUnits()
    elseif container.Type == fsFrame.ContainerType.EnemyArena then
        sortedUnits = fsSortedUnits:EnemyUnits()
    else
        fsLog:Bug("Unknown container type: %s.", container.Type or "nil")
        return false
    end

    SortFramesByUnits(frames, sortedUnits)

    local spacing = nil

    if container.Spacing then
        spacing = container:Spacing()
    elseif container.SupportsSpacing then
        local config = addon.DB.Options.Spacing
        if container.Type == fsFrame.ContainerType.Party then
            spacing = config.Party
        elseif container.Type == fsFrame.ContainerType.Raid then
            spacing = config.Raid
        elseif container.Type == fsFrame.ContainerType.EnemyArena then
            spacing = config.EnemyArena
        end
    end

    local sorted = false

    if container.LayoutType == fsFrame.LayoutType.Soft then
        sorted = SoftArrange(frames, spacing)
    elseif container.LayoutType == fsFrame.LayoutType.Hard then
        sorted = HardArrange(container, frames, spacing)
    else
        fsLog:Bug("Unknown layout type: %s.", container.Type or "nil")
        return false
    end

    if sorted and container.PostSort then
        container:PostSort()
    end

    return sorted
end

---@param container FrameContainer
---@return boolean
local function TrySortContainerGroups(container)
    local sorted = false
    local groups = fsFrame:ExtractGroups(container.Frame, container.VisibleOnly)

    if #groups == 0 then
        return false
    end

    local isHorizontalLayout = container.IsHorizontalLayout and container:IsHorizontalLayout() or false

    for _, group in ipairs(groups) do
        ---@type FrameContainer
        local groupContainer = {
            Frame = group,
            Type = container.Type,
            IsHorizontalLayout = function()
                return isHorizontalLayout
            end,
            VisibleOnly = container.VisibleOnly,
            LayoutType = container.LayoutType,
            SupportsSpacing = container.SupportsSpacing,
            FramesPerLine = container.FramesPerLine,
            -- we want to use the group frames offset here
            FramesOffset = container.GroupFramesOffset,
            IsGrouped = function()
                return false
            end,
        }

        sorted = TrySortContainer(groupContainer) or sorted
    end

    if not container.SupportsSpacing then
        -- to avoid issues with main tank and assist frames don't move ungrouped frames if we don't need to
        return sorted
    end

    local spacing = nil
    local config = addon.DB.Options.Spacing

    if container.Type == fsFrame.ContainerType.Party then
        spacing = config.Party
    elseif container.Type == fsFrame.ContainerType.Raid then
        spacing = config.Raid
    elseif container.Type == fsFrame.ContainerType.EnemyArena then
        spacing = config.EnemyArena
    end

    if not spacing or (spacing.Horizontal == 0 and spacing.Vertical == 0) then
        return sorted
    end

    sorted = SpaceGroups(groups, spacing) or sorted

    -- ungrouped frames include pets, vehicles, and main tank/assist frames
    local ungroupedFrames = fsFrame:ExtractUnitFrames(container.Frame, true, container.VisibleOnly)

    if #ungroupedFrames == 0 then
        return sorted
    end

    local ungroupedOffset = UngroupedOffset(container, spacing)
    -- pet frames are half the height of a member frame
    -- it'd be technically better to get the height of a member frame
    -- but want a way to do that efficiently, e.g. get the frames back from TrySortContainer or something
    local blockHeight = ungroupedFrames[1]:GetHeight() * 2

    sorted = HardArrange(container, ungroupedFrames, spacing, ungroupedOffset, blockHeight)

    return true
end

local function ClearSorting(providers, friendlyEnabled, enemyEnabled)
    ---@type FrameContainer
    local nameListContainers = fsEnumerable
        :From(providers)
        :Map(function(provider)
            return provider:Containers()
        end)
        :Flatten()
        :Where(function(container)
            if (container.Type == fsFrame.ContainerType.Party or container.Type == fsFrame.ContainerType.Raid) and friendlyEnabled then
                return false
            end

            if container.Type == fsFrame.ContainerType.EnemyArena and enemyEnabled then
                return false
            end

            -- after exiting an arena, elvui retains the nameList property
            -- so we want to clear it if they've disabled sorting in the world
            if container.LayoutType ~= fsFrame.LayoutType.NameList then
                return false
            end

            local hasTouched = container.Frame:GetAttribute("FrameSortHasSorted") or false
            return hasTouched
        end)
        :ToTable()

    for _, container in ipairs(nameListContainers) do
        local previousSortMethod = container.Frame:GetAttribute("FrameSortPreviousSortMethod") or "INDEX"
        local previousGroupFilter = container.Frame:GetAttribute("FrameSortPreviousGroupFilter")

        container.Frame:SetAttribute("nameList", nil)
        container.Frame:SetAttribute("sortMethod", previousSortMethod)
        container.Frame:SetAttribute("groupFilter", previousGroupFilter)

        fsLog:Debug("Cleared sorting on container %s.", container.Frame:GetName() or "")
    end

    return #nameListContainers > 0
end

---@param provider FrameProvider?
---@return boolean
function M:TrySort(provider)
    if wow.InCombatLockdown() then
        fsLog:Error("Cannot run non-combat sorting module during combat.")
        return false
    end

    local sorted = false
    local friendlyEnabled, _, _, _ = fsCompare:FriendlySortMode()
    local enemyEnabled, _, _ = fsCompare:EnemySortMode()
    local providers = provider and { provider } or fsProviders:Enabled()

    if not friendlyEnabled or not enemyEnabled then
        sorted = ClearSorting(providers, friendlyEnabled, enemyEnabled)
    end

    if not friendlyEnabled and not enemyEnabled then
        return sorted
    end

    for _, p in ipairs(providers) do
        local start = wow.GetTimePreciseSec()
        local containers = fsEnumerable
            :From(p:Containers())
            :Where(function(container)
                if not container.Frame then
                    return false
                end

                if not container.Frame:IsVisible() then
                    return false
                end

                if (container.Type == fsFrame.ContainerType.Party or container.Type == fsFrame.ContainerType.Raid) and not friendlyEnabled then
                    return false
                end

                if container.Type == fsFrame.ContainerType.EnemyArena and not enemyEnabled then
                    return false
                end

                if container.EnableInBattlegrounds ~= nil and not container.EnableInBattlegrounds and wow.IsInstanceBattleground() then
                    return false
                end

                return true
            end)
            :ToTable()

        local providerSorted = false
        for _, container in ipairs(containers) do
            local containerSorted = false

            if container.IsGrouped and container:IsGrouped() then
                containerSorted = TrySortContainerGroups(container)
            else
                containerSorted = TrySortContainer(container)
            end

            providerSorted = providerSorted or containerSorted

            fsLog:Debug("Container %s for provider %s was %s.", container.Frame:GetName() or "nil", p:Name(), containerSorted and "sorted" or "not sorted")
        end

        sorted = sorted or providerSorted

        local stop = wow.GetTimePreciseSec()

        if #containers > 0 then
            fsLog:Debug("Sort for %s took %fms, result: %s.", p:Name(), (stop - start) * 1000, providerSorted and "sorted" or "not sorted")
        end
    end

    return sorted
end
