---@type string, Addon
local _, addon = ...
local wow = addon.WoW.Api
local fsSorting = addon.Modules.Sorting
local fsCompare = addon.Collections.Comparer
local fsProviders = addon.Providers
local fsEnumerable = addon.Collections.Enumerable
local fsUnit = addon.WoW.Unit
local fsScheduler = addon.Scheduling.Scheduler
local fsConfig = addon.Configuration
local fsLog = addon.Logging.Log
local M = {}
addon.Modules.Sorting.Secure.InCombat = M

local manager = nil
local headers = {}
local secureMethods = {}

-- prints a log message
secureMethods["Log"] = [[
    if not self:GetAttribute("LoggingEnabled") then return end

    local level, message = ...
    print(format("FrameSort - %s: %s", level, message))
]]

-- rounds a number to the specified decimal places
secureMethods["Round"] = [[
    local number, decimalPlaces = ...

    if number == nil then return nil end

    local mult = 10 ^ (decimalPlaces or 0)
    return math.floor(number * mult + 0.5) / mult
]]

-- returns true if in combat, otherwise false
secureMethods["InCombat"] = [[
    return SecureCmdOptionParse("[combat] true; false") == "true"
]]

-- gets the unit token from a frame
secureMethods["GetUnit"] = [[
    local framesVariable = ...
    local frame = _G[framesVariable]

    local unit = frame:GetAttribute("unit")

    if unit then return unit end

    local name = frame:GetName()
    if name and strmatch(name, "GladiusExButtonFrame") then
        unit = gsub(name, "GladiusExButtonFrame", "")
        return unit
    end

    return nil
]]

-- filters a set of frames to only unit frames
secureMethods["ExtractUnitFrames"] = [[
    local framesVariable, destinationVariable, visibleOnly = ...
    local children = _G[framesVariable]
    local unitFrames = newtable()

    for _, child in ipairs(children) do
        Frame = child
        local unit = self:RunAttribute("GetUnit", "Frame")
        Frame = nil

        -- in some rare cases frames can have no position, so exclude them
        local left, bottom, width, height = child:GetRect()

        if unit and
            (child:IsVisible() or not visibleOnly) and
            (left and bottom and width and height) then
            unitFrames[#unitFrames + 1] = child
        end
    end

    _G[destinationVariable] = unitFrames
    return #unitFrames > 0
]]

-- extracts a set of groups from a container
secureMethods["ExtractGroups"] = [[
    local containerTableName, destinationTableName = ...
    local container = _G[containerTableName]
    local children = newtable()

    container.Frame:GetChildList(children)
    if #children == 0 then return false end

    local groups = newtable()

    for _, child in ipairs(children) do
        local name = child:GetName()
        local left, bottom, width, height = child:GetRect()

        if child:IsVisible() and name and (left and bottom and width and height) then
            if strmatch(name, "CompactRaidGroup") or strmatch(name, "CompactPartyFrame") then
                groups[#groups + 1] = child
            end
        end
    end

    _G[destinationTableName] = groups
    return #groups > 0
]]

-- copies elements from one table to another
secureMethods["CopyTable"] = [[
    local fromName, toName = ...
    local from = _G[fromName]
    local to = _G[toName]

    for k, v in pairs(from) do
        to[k] = v
    end
]]

-- converts an array of frames in a chain layout to a linked list
-- where the root node is the start of the chain
-- and each subsequent node depends on the one before it
-- i.e. root -> frame1 -> frame2 -> frame3
secureMethods["FrameChain"] = [[
    local framesVariable, destinationVariable = ...
    local frames = _G[framesVariable]
    local nodesByFrame = newtable()

    for _, frame in pairs(frames) do
        local node = newtable()
        node.Value = frame

        nodesByFrame[frame] = node
    end

    local root = nil
    for _, child in pairs(nodesByFrame) do
        local _, relativeTo, _, _, _ = child.Value:GetPoint()
        local parent = nodesByFrame[relativeTo]

        if parent then
            if parent.Next then
                return false, nil
            end

            parent.Next = child
            child.Previous = parent
        else
            root = child
        end
    end

    -- assert we have a complete chain
    local count = 0
    local current = root

    while current do
        count = count + 1
        current = current.Next
    end

    if count ~= #frames then
        return false
    end

    _G[destinationVariable] = root

    return true
]]

-- performs an in place sort on an array of frames by their visual order
secureMethods["SortFramesByTopLeft"] = [[
    local framesVariable = ...
    local frames = _G[framesVariable]

    -- bubble sort because it's easier to write
    -- not going to write an Olog(n) sort algorithm in this environment
    for i = 1, #frames do
        for j = 1, #frames - i do
            local left, bottom, width, height = frames[j]:GetRect()
            local nextLeft, nextBottom, nextWidth, nextHeight = frames[j + 1]:GetRect()

            local topFuzzy = self:RunAttribute("Round", bottom + height)
            local nextTopFuzzy = self:RunAttribute("Round", nextBottom + nextHeight)
            local leftFuzzy = self:RunAttribute("Round", left)
            local nextLeftFuzzy = self:RunAttribute("Round", nextLeft)

            if topFuzzy < nextTopFuzzy or leftFuzzy > nextLeftFuzzy then
                frames[j], frames[j + 1] = frames[j + 1], frames[j]
            end
        end
    end
]]

-- performs an in place sort on an array of frames by their visual order
secureMethods["SortFramesByTopRight"] = [[
    local framesVariable = ...
    local frames = _G[framesVariable]

    for i = 1, #frames do
        for j = 1, #frames - i do
            local left, bottom, width, height = frames[j]:GetRect()
            local nextLeft, nextBottom, nextWidth, nextHeight = frames[j + 1]:GetRect()

            local topFuzzy = self:RunAttribute("Round", bottom + height)
            local nextTopFuzzy = self:RunAttribute("Round", nextBottom + nextHeight)
            local rightFuzzy = self:RunAttribute("Round", left + width)
            local nextRightFuzzy = self:RunAttribute("Round", nextLeft + nextWidth)

            if topFuzzy < nextTopFuzzy or rightFuzzy < nextRightFuzzy then
                frames[j], frames[j + 1] = frames[j + 1], frames[j]
            end
        end
    end
]]

-- performs an in place sort on an array of frames by their visual order
secureMethods["SortFramesByBottomLeft"] = [[
    local framesVariable = ...
    local frames = _G[framesVariable]

    for i = 1, #frames do
        for j = 1, #frames - i do
            local left, bottom, width, height = frames[j]:GetRect()
            local nextLeft, nextBottom, nextWidth, nextHeight = frames[j + 1]:GetRect()

            local bottomFuzzy = self:RunAttribute("Round", bottom)
            local nextBottomFuzzy = self:RunAttribute("Round", nextBottom)
            local leftFuzzy = self:RunAttribute("Round", left)
            local nextLeftFuzzy = self:RunAttribute("Round", nextLeft)

            if bottomFuzzy > nextBottomFuzzy or leftFuzzy > nextLeftFuzzy then
                frames[j], frames[j + 1] = frames[j + 1], frames[j]
            end
        end
    end
]]

-- performs an in place sort on an array of points by their top left coordinate
secureMethods["SortPointsByTopLeft"] = [[
    local pointsVariable = ...
    local points = _G[pointsVariable]

    for i = 1, #points do
        for j = 1, #points - i do
            local point = points[j]
            local next = points[j + 1]

            local topFuzzy = self:RunAttribute("Round", point.Bottom + point.Height)
            local nextTopFuzzy = self:RunAttribute("Round", next.Bottom + next.Height)
            local leftFuzzy = self:RunAttribute("Round", point.Left)
            local nextLeftFuzzy = self:RunAttribute("Round", next.Left)

            if topFuzzy < nextTopFuzzy or leftFuzzy > nextLeftFuzzy then
                points[j], points[j + 1] = points[j + 1], points[j]
            end
        end
    end
]]

-- performs an in place sort on an array of points by their top left coordinate
secureMethods["SortPointsByLeftTop"] = [[
    local pointsVariable = ...
    local points = _G[pointsVariable]

    for i = 1, #points do
        for j = 1, #points - i do
            local point = points[j]
            local next = points[j + 1]

            local topFuzzy = self:RunAttribute("Round", point.Bottom + point.Height)
            local nextTopFuzzy = self:RunAttribute("Round", next.Bottom + next.Height)
            local leftFuzzy = self:RunAttribute("Round", point.Left)
            local nextLeftFuzzy = self:RunAttribute("Round", next.Left)

            if leftFuzzy > nextLeftFuzzy or topFuzzy < nextTopFuzzy then
                points[j], points[j + 1] = points[j + 1], points[j]
            end
        end
    end
]]

-- performs an out of place sort on an array frames by the order of the units array
secureMethods["SortFramesByUnits"] = [[
    local framesVariable, unitsVariable, destinationVariable = ...
    local frames = _G[framesVariable]
    local units = _G[unitsVariable]
    local index = 1
    local framesByUnit = newtable()
    local frameWasSorted = newtable()

    for i = 1, #frames do
        local frame = frames[i]

        Frame = frame
        local unit = self:RunAttribute("GetUnit", "Frame")
        Frame = nil

        if unit then
            framesByUnit[unit] = frame
        else
            framesWithoutUnits = frame
        end

        frameWasSorted[frame] = false
    end

    local sorted = newtable()

    for i = 1, #units do
        local unit = units[i]
        local frame = framesByUnit[unit]

        if frame then
            sorted[#sorted + 1] = frame
            frameWasSorted[frame] = true
        end
    end

    -- we may not have all unit information
    -- so any frames that didn't make it we can just add on to the end
    for i = 1, #frames do
        local frame = frames[i]

        if not frameWasSorted[frame] then
            sorted[#sorted + 1] = frame
        end
    end

    _G[destinationVariable] = sorted
]]

-- adjusts the x and y offsets of a frame
secureMethods["AdjustPointsOffset"] = [[
    local framesVariable, xDelta, yDelta = ...
    local frame = _G[framesVariable]

    if xDelta == 0 and yDelta == 0 then
        return false
    end

    local point, relativeTo, relativePoint, offsetX, offsetY = frame:GetPoint()

    if not point or not relativeTo or not relativePoint then
        -- something weird going on with this frame
        return false
    end

    local newOffsetX = (offsetX or 0) + xDelta
    local newOffsetY = (offsetY or 0) + yDelta

    frame:SetPoint(point, relativeTo, relativePoint, newOffsetX, newOffsetY)
    return true
]]

secureMethods["SpacingForContainer"] = [[
    local containerType = ...
    local spacingType = nil

    if containerType == ContainerType.Party then
        spacingType = "Party"
    elseif containerType == ContainerType.Raid then
        spacingType = "Raid"
    elseif containerType == ContainerType.EnemyArena then
        spacingType = "EnemyArena"
    else
        return nil, nil
    end

    local horizontalSpacing = self:GetAttribute(spacingType .. "SpacingHorizontal")
    local verticalSpacing = self:GetAttribute(spacingType .. "SpacingVertical")

    return horizontalSpacing, verticalSpacing
]]

secureMethods["ApplySpacing"] = [[
    local pointsVariable, spacingVariable = ...
    local points = _G[pointsVariable]
    local spacing = _G[spacingVariable]
    local horizontal = spacing.Horizontal or 0
    local vertical = spacing.Vertical or 0

    OrderedTopLeft = newtable()
    OrderedLeftTop = newtable()

    self:RunAttribute("CopyTable", pointsVariable, "OrderedTopLeft")
    self:RunAttribute("CopyTable", pointsVariable, "OrderedLeftTop")

    self:RunAttribute("SortPointsByTopLeft", "OrderedTopLeft")
    self:RunAttribute("SortPointsByLeftTop", "OrderedLeftTop")

    local changed = false

    for i = 2, #OrderedLeftTop do
        local point = OrderedLeftTop[i]
        local previous = OrderedLeftTop[i - 1]
        local sameRow = self:RunAttribute("Round", point.Bottom + point.Height) == self:RunAttribute("Round", previous.Bottom + previous.Height)

        if sameRow then
            local existingSpace = point.Left - (previous.Left + previous.Width)
            local xDelta = horizontal - existingSpace
            point.Left = point.Left + xDelta
            changed = changed or xDelta ~= 0
        end
    end

    for i = 2, #OrderedTopLeft do
        local point = OrderedTopLeft[i]
        local previous = OrderedTopLeft[i - 1]
        local sameColumn = self:RunAttribute("Round", point.Left) == self:RunAttribute("Round", previous.Left)

        if sameColumn then
            local existingSpace = previous.Bottom - (point.Bottom + point.Height)
            local yDelta = vertical - existingSpace
            point.Bottom = point.Bottom - yDelta
            changed = changed or yDelta ~= 0
        end
    end

    return changed
]]

-- rearranges a set of frames accoding to the pre-sorted unit positions
secureMethods["SpaceGroups"] = [[
    local groupsVariable, spacingVariable = ...
    local groups = _G[groupsVariable]
    local spacing = _G[spacingVariable]

    local points = newtable()
    local pointsByGroup = newtable()

    for _, group in ipairs(groups) do
        local point = newtable()
        local left, bottom, width, height = group:GetRect()

        point.Left = left
        point.Bottom = bottom
        point.Width = width
        point.Height = height

        points[#points + 1] = point
        pointsByGroup[group] = point
    end

    GroupPoints = points

    if not self:RunAttribute("ApplySpacing", "GroupPoints", spacingVariable) then
        GroupPoints = nil
        return false
    end

    GroupPoints = nil

    local movedAny = false

    for _, group in ipairs(groups) do
        local point = pointsByGroup[group]
        local left, bottom, _, _ = group:GetRect()
        local xDelta = point.Left - left
        local yDelta = point.Bottom - bottom
        local xDeltaRounded = self:RunAttribute("Round", xDelta, DecimalSanity)
        local yDeltaRounded = self:RunAttribute("Round", yDelta, DecimalSanity)

        if xDeltaRounded ~= 0 or yDeltaRounded ~= 0 then
            Group = group
            local moved = self:RunAttribute("AdjustPointsOffset", "Group", xDelta, yDelta)
            movedAny = movedAny or moved
            Group = nil
        end
    end

    return movedAny
]]

-- rearranges a set of frames by only modifying the x and y offsets
secureMethods["SoftArrange"] = [[
    local framesVariable, spacingVariable = ...
    local frames = _G[framesVariable]

    OrderedByTopLeft = newtable()

    self:RunAttribute("CopyTable", framesVariable, "OrderedByTopLeft")
    self:RunAttribute("SortFramesByTopLeft", "OrderedByTopLeft")

    local points = newtable()
    for _, frame in ipairs(OrderedByTopLeft) do
        local point = newtable()
        local left, bottom, width, height = frame:GetRect()

        point.Left = left
        point.Bottom = bottom
        point.Width = width
        point.Height = height

        points[#points + 1] = point
    end

    if spacingVariable then
        Points = points
        self:RunAttribute("ApplySpacing", "Points", spacingVariable)
        Points = nil
    end

    Root = nil
    local isChain = self:RunAttribute("FrameChain", framesVariable, "Root")
    local root = Root
    Root = nil

    local enumerationOrder = nil

    if isChain then
        enumerationOrder = newtable()

        local next = root
        while next do
            enumerationOrder[#enumerationOrder + 1] = next.Value
            next = next.Next
        end
    else
        enumerationOrder = OrderedByTopLeft
    end

    OrderedByTopLeft = nil

    local movedAny = false

    for i, source in ipairs(enumerationOrder) do
        local desiredIndex = -1
        for j = 1, #frames do
            if source == frames[j] then
                desiredIndex = j
                break
            end
        end

        if desiredIndex > 0 and desiredIndex <= #points then
            local left, bottom, width, height = source:GetRect()
            local destination = points[desiredIndex]
            local xDelta = destination.Left - left
            local yDelta = destination.Bottom - bottom
            local xDeltaRounded = self:RunAttribute("Round", xDelta, DecimalSanity)
            local yDeltaRounded = self:RunAttribute("Round", yDelta, DecimalSanity)

            if xDeltaRounded ~= 0 or yDeltaRounded ~= 0 then
                Frame = source
                local moved = self:RunAttribute("AdjustPointsOffset", "Frame", xDelta, yDelta)
                movedAny = movedAny or moved
                Frame = nil
            end
        else
            self:RunAttribute("Log", "Warning", "Unable to determine frame's desired index")
        end
    end

    return movedAny
]]

-- rearranges a set of frames by modifying their anchors and offsets
secureMethods["HardArrange"] = [[
    local framesVariable, containerVariable, spacingVariable = ...
    local frames = _G[framesVariable]
    local container = _G[containerVariable]
    local spacing = spacingVariable and _G[spacingVariable]
    local verticalSpacing = spacing and spacing.Vertical or 0
    local horizontalSpacing = spacing and spacing.Horizontal or 0
    local isHorizontalLayout = container.IsHorizontalLayout
    local _, _, blockWidth, blockHeight = frames[1]:GetRect()
    local offset = container.Offset or newtable()

    offset.X = offset.X or 0
    offset.Y = offset.Y or 0

    local pointsByFrame = newtable()
    local row, col = 1, 1
    local xOffset = offset.X
    local yOffset = offset.Y
    local rowHeight = 0
    local currentBlockHeight = 0

    for _, frame in ipairs(frames) do
        local framePoint = newtable()
        framePoint.Point = "TOPLEFT"
        framePoint.RelativeTo = container.Frame
        framePoint.RelativePoint = "TOPLEFT"
        framePoint.XOffset = xOffset
        framePoint.YOffset = yOffset
        pointsByFrame[frame] = framePoint

        local _, _, _, height = frame:GetRect()

        if isHorizontalLayout then
            col = (col + 1)
            xOffset = xOffset + blockWidth + horizontalSpacing
            -- keep track of the tallest frame within the row
            -- as the next row will be the tallest row frame + spacing
            rowHeight = max(rowHeight, height)

            -- if we've reached the end then wrap around
            if container.FramesPerLine and col > container.FramesPerLine then
                xOffset = offset.X
                yOffset = yOffset - rowHeight - verticalSpacing

                row = row + 1
                col = 1
                rowHeight = 0
            end
        else
            currentBlockHeight = currentBlockHeight + height

            -- subtract 1 for a bit of breathing room for rounding errors
            local isNewRow = currentBlockHeight >= (blockHeight - 1)

            if isNewRow then
                currentBlockHeight = 0
            end

            if isNewRow then
                yOffset = yOffset - height - verticalSpacing
                row = (row + 1)
            else
                -- don't add spacing if we're still within a block
                yOffset = yOffset - height
            end

            -- if we've reached the end then wrap around
            if container.FramesPerLine and row > container.FramesPerLine then
                row = 1
                col = col + 1
                yOffset = offset.Y
                xOffset = xOffset + blockWidth + horizontalSpacing
            end
        end
    end

    local framesToMove = newtable()

    for _, frame in ipairs(frames) do
        local to = pointsByFrame[frame]
        local point, relativeTo, relativePoint, xOffset, yOffset = frame:GetPoint()
        local different =
            point ~= to.Point or
            relativeTo ~= to.RelativeTo or
            relativePoint ~= to.RelativePoint or
            self:RunAttribute("Round", xOffset, DecimalSanity) ~= self:RunAttribute("Round", to.XOffset, DecimalSanity) or
            self:RunAttribute("Round", yOffset, DecimalSanity) ~= self:RunAttribute("Round", to.YOffset, DecimalSanity)

        if different then
            framesToMove[#framesToMove + 1] = frame
            frame:ClearAllPoints()
        end
    end

    -- now move them
    for _, frame in ipairs(framesToMove) do
        local to = pointsByFrame[frame]
        frame:SetPoint(to.Point, to.RelativeTo, to.RelativePoint, to.XOffset, to.YOffset)
    end

    return #framesToMove > 0
]]

-- determines the offset to use for the ungrouped portion of the raid frames.
secureMethods["UngroupedOffset"] = [[
    local containerVariable, spacingVariable = ...
    local container = _G[containerVariable]
    local spacing = _G[spacingVariable]

    if not self:RunAttribute("ExtractGroups", containerVariable, "OffsetGroups") then
        return 0, 0
    end

    local frames = newtable()
    local horizontal = container.IsHorizontalLayout

    -- TODO: don't get frames from all groups, get frames from the bottom/right most group
    for i, group in ipairs(OffsetGroups) do
        OffsetGroupChildren = newtable()
        group:GetChildList(OffsetGroupChildren)

        if self:RunAttribute("ExtractUnitFrames", "OffsetGroupChildren", "OffsetGroupFrames", container.VisibleOnly) then
            for _, frame in ipairs(OffsetGroupFrames) do
                frames[#frames + 1] = frame
            end
        end

        OffsetGroupChildren = nil
        OffsetGroupFrames = nil
    end

    if #frames == 0 then return 0, 0 end

    UngroupedFrames = frames

    local x, y = 0, 0
    local left, bottom, width, height = container.Frame:GetRect()

    if horizontal then
        self:RunAttribute("SortFramesByBottomLeft", "UngroupedFrames")
        local bottomLeftFrame = UngroupedFrames[1]
        local bottomFrameLeft, bottomFrameBottom, _, _ = bottomLeftFrame:GetRect()

        x = -(left - bottomFrameLeft)
        y = -((bottom + height) - bottomFrameBottom + spacing.Vertical)
    else
        self:RunAttribute("SortFramesByTopRight", "UngroupedFrames")
        local topRightFrame = UngroupedFrames[1]
        local topFrameLeft, topFrameBottom, topFrameWidth, topFrameHeight = topRightFrame:GetRect()

        x = -(left - (topFrameLeft + topFrameWidth) - spacing.Horizontal)
        y = -((bottom + height) - (topFrameBottom + topFrameHeight))
    end

    UngroupedFrames = nil
    OffsetGroups = nil

    return x, y
]]

secureMethods["TrySortContainerGroups"] = [[
    local containerVariable, providerVariable = ...
    local container = _G[containerVariable]
    local provider = _G[providerVariable]

    local sorted = false
    Groups = nil

    if not self:RunAttribute("ExtractGroups", containerVariable, "Groups") then
        return false
    end

    for _, group in ipairs(Groups) do
        GroupContainer = newtable()
        -- just copy over all the attributes to make code simpler
        self:RunAttribute("CopyTable", containerVariable, "GroupContainer")

        -- now re-write over the top
        GroupContainer.Frame = group
        GroupContainer.Offset = newtable()

        if container.GroupOffset then
            GroupContainer.Offset.X = container.GroupOffset.X
            GroupContainer.Offset.Y = container.GroupOffset.Y
        end

        sorted = self:RunAttribute("TrySortContainer", "GroupContainer", providerVariable) or sorted

        GroupContainer = nil
    end

    if container.SupportsSpacing then
        local horizontalSpacing, verticalSpacing = self:RunAttribute("SpacingForContainer", container.Type)

        if (horizontalSpacing and horizontalSpacing ~= 0) or (verticalSpacing and verticalSpacing ~= 0) then
            GroupSpacing = newtable()
            GroupSpacing.Horizontal = horizontalSpacing
            GroupSpacing.Vertical = verticalSpacing

            local spacedGroup = self:RunAttribute("SpaceGroups", "Groups", "GroupSpacing")
            sorted = sorted or spacedGroup
        end
    end

    local offsetX, offsetY = self:RunAttribute("UngroupedOffset", containerVariable, "GroupSpacing")

    -- now re-write over the top
    UngroupedContainer = newtable()
    -- just copy over all the attributes to make code simpler
    self:RunAttribute("CopyTable", containerVariable, "UngroupedContainer")

    UngroupedContainer.Offset = newtable()
    UngroupedContainer.Offset.X = offsetX or 0
    UngroupedContainer.Offset.Y = offsetY or 0

    sorted = self:RunAttribute("TrySortContainer", "UngroupedContainer", providerVariable) or sorted

    UngroupedContainer = nil
    GroupSpacing = nil
    Groups = nil
    return sorted
]]

-- attempts to sort the frames within the container
secureMethods["TrySortContainer"] = [[
    local friendlyEnabled = self:GetAttribute("FriendlySortEnabled")
    local enemyEnabled = self:GetAttribute("EnemySortEnabled")
    local containerVariable, providerVariable = ...
    local container = _G[containerVariable]
    local provider = _G[providerVariable]
    local units = nil

    if container.Type == ContainerType.Party then
        units = FriendlyUnits
    elseif container.Type == ContainerType.Raid then
        units = FriendlyUnits
    elseif container.Type == ContainerType.EnemyArena then
        units = EnemyUnits
    else
        self:RunAttribute("Log", "Error", "Invalid container type: " .. (container.Type or 'nil'))
        return false
    end

    Children = newtable()
    Frames = newtable()

    -- import into the global table for filtering
    container.Frame:GetChildList(Children)

    if not self:RunAttribute("ExtractUnitFrames", "Children", "Frames", container.VisibleOnly) then
        return false
    end

    Units = units or newtable()

    -- sort the frames to the desired locations
    FramesInUnitOrder = nil
    self:RunAttribute("SortFramesByUnits", "Frames", "Units", "FramesInUnitOrder")

    local sorted = false

    if container.SupportsSpacing then
        local horizontalSpacing, verticalSpacing = self:RunAttribute("SpacingForContainer", container.Type)

        if (horizontalSpacing and horizontalSpacing ~= 0) or (verticalSpacing and verticalSpacing ~= 0) then
            Spacing = newtable()
            Spacing.Horizontal = horizontalSpacing
            Spacing.Vertical = verticalSpacing
        end
    end

    if container.LayoutType == LayoutType.Hard then
        sorted = self:RunAttribute("HardArrange", "FramesInUnitOrder", containerVariable, Spacing and "Spacing")
    else
        sorted = self:RunAttribute("SoftArrange", "FramesInUnitOrder", Spacing and "Spacing")
    end

    FramesInUnitOrder = nil
    Children = nil
    Frames = nil
    Spacing = nil

    return sorted
]]

-- top level perform sort routine
secureMethods["TrySort"] = [[
    if not self:RunAttribute("InCombat") then return false end

    local friendlyEnabled = self:GetAttribute("FriendlySortEnabled")
    local enemyEnabled = self:GetAttribute("EnemySortEnabled")

    if not friendlyEnabled and not enemyEnabled then return false end

    local loadedUnits = self:GetAttribute("LoadedUnits")
    if not loadedUnits then
        self:RunAttribute("LoadUnits")
        self:SetAttribute("LoadedUnits", true)
    end

    local toSort = newtable()

    for _, provider in pairs(Providers) do
        local providerEnabled = self:GetAttribute("Provider" .. provider.Name .. "Enabled")
        if providerEnabled then
            for _, container in ipairs(provider.Containers) do
                if container.Frame and container.Frame:IsVisible() then
                    if ((container.Type == ContainerType.Party or container.Type == ContainerType.Raid) and friendlyEnabled) or
                        (container.Type == ContainerType.EnemyArena and enemyEnabled) then
                        local add = newtable()
                        add.Provider = provider
                        add.Container = container

                        toSort[#toSort + 1] = add
                    end
                end
            end
        end
    end

    local sorted = false

    for _, item in ipairs(toSort) do
        Container = item.Container
        Provider = item.Provider

        if Container.IsGrouped then
            sorted = self:RunAttribute("TrySortContainerGroups", "Container", "Provider") or sorted
        else
            sorted = self:RunAttribute("TrySortContainer", "Container", "Provider") or sorted
        end

        Provider = nil
        Container = nil
    end

    if sorted then
        -- notify unsecure code to invoke callbacks
        self:CallMethod("InvokeCallbacks")
    end

    self:RunAttribute("Log", "Debug", format("Performed in-combat sort, result: %s.", sorted and "sorted" or "not sorted"))

    return sorted
]]

secureMethods["LoadProvider"] = [[
    local name = self:GetAttribute("ProviderName")
    local provider = Providers[name]

    if not provider then
        provider = newtable()
        provider.Name = name
        Providers[name] = provider
    end

    -- replace existing containers (if any)
    provider.Containers = newtable()

    local containersCount = self:GetAttribute(name .. "ContainersCount")

    for i = 1, containersCount do
        local prefix = name .. "Container" .. i
        local container = newtable()

        container.Frame = self:GetFrameRef(prefix .. "Frame")
        container.Type = self:GetAttribute(prefix .. "Type")
        container.LayoutType = self:GetAttribute(prefix .. "LayoutType")
        container.SupportsSpacing = self:GetAttribute(prefix .. "SupportsSpacing")
        container.VisibleOnly = self:GetAttribute(prefix .. "SupportsSpacing")
        container.IsGrouped = self:GetAttribute(prefix .. "IsGrouped")
        container.IsHorizontalLayout = self:GetAttribute(prefix .. "IsHorizontalLayout")
        container.FramesPerLine = self:GetAttribute(prefix .. "FramesPerLine")

        local offsetX = self:GetAttribute(prefix .. "OffsetX")
        local offsetY = self:GetAttribute(prefix .. "OffsetY")

        if offsetX or offsetY then
            container.Offset = newtable()
            container.Offset.X = offsetX or 0
            container.Offset.Y = offsetY or 0
        end

        local groupOffsetX = self:GetAttribute(prefix .. "GroupOffsetX")
        local groupOffsetY = self:GetAttribute(prefix .. "GroupOffsetY")

        if groupOffsetX or groupOffsetY then
            container.GroupOffset = newtable()
            container.GroupOffset.X = groupOffsetX or 0
            container.GroupOffset.Y = groupOffsetY or 0
        end

        provider.Containers[#provider.Containers + 1] = container
    end
]]

secureMethods["LoadUnits"] = [[
    FriendlyUnits = newtable()
    EnemyUnits = newtable()

    local friendlyUnitsCount = self:GetAttribute("FriendlyUnitsCount")
    local enemyUnitsCount = self:GetAttribute("EnemyUnitsCount")

    if friendlyUnitsCount then
        for i = 1, friendlyUnitsCount do
            local unit = self:GetAttribute("FriendlyUnit" .. i)
            FriendlyUnits[#FriendlyUnits + 1] = unit
        end
    end

    if enemyUnitsCount then
        for i = 1, enemyUnitsCount do
            local unit = self:GetAttribute("EnemyUnit" .. i)
            EnemyUnits[#EnemyUnits + 1] = unit
        end
    end
]]

secureMethods["Init"] = [[
    Providers = newtable()

    -- don't move frames if they are have minuscule position differences
    -- it's just a rounding error and makes no visual impact
    -- this helps preventing spam on our callbacks
    DecimalSanity = 2

    -- must match the enums specified in Frame.lua
    ContainerType = newtable()
    ContainerType.Party = 1
    ContainerType.Raid = 2
    ContainerType.EnemyArena = 3

    LayoutType = newtable()
    LayoutType.Soft = 1
    LayoutType.Hard = 2
]]

local function LoadUnits()
    assert(manager ~= nil)

    local start = wow.GetTimePreciseSec()

    -- TODO: we could transfer unit info to the restricted environment
    -- then perform the unit sort inside which would give us more control
    local friendlyUnits = fsUnit:FriendlyUnits()
    local enemyUnits = fsUnit:EnemyUnits()
    local friendlyCompare = fsCompare:SortFunction(friendlyUnits)
    local enemyCompare = fsCompare:EnemySortFunction()

    table.sort(friendlyUnits, friendlyCompare)
    table.sort(enemyUnits, enemyCompare)

    for i, unit in ipairs(friendlyUnits) do
        manager:SetAttribute("FriendlyUnit" .. i, unit)
    end

    for i, unit in ipairs(enemyUnits) do
        manager:SetAttribute("EnemyUnit" .. i, unit)
    end

    manager:SetAttribute("FriendlyUnitsCount", #friendlyUnits)
    manager:SetAttribute("EnemyUnitsCount", #enemyUnits)
    -- flag that the units need to be reloaded
    manager:SetAttribute("LoadedUnits", false)

    local stop = wow.GetTimePreciseSec()

    fsLog:Debug(string.format("Sent units to the secure environment in %fms.", (stop - start) * 100))
end

local function LoadEnabled()
    assert(manager ~= nil)

    local friendlyEnabled = fsCompare:FriendlySortMode()
    local enemyEnabled = fsCompare:EnemySortMode()

    manager:SetAttribute("FriendlySortEnabled", friendlyEnabled)
    manager:SetAttribute("EnemySortEnabled", enemyEnabled)
    manager:SetAttribute("LoggingEnabled", addon.DB.Options.Logging.Enabled)

    for _, provider in ipairs(fsProviders.All) do
        manager:SetAttribute("Provider" .. provider:Name() .. "Enabled", provider:Enabled())
    end

    fsLog:Debug("Sent enabled values to the secure environment.")
end

local function LoadSpacing()
    assert(manager ~= nil)

    local appearance = addon.DB.Options.Appearance

    for type, value in pairs(appearance) do
        manager:SetAttribute(type .. "SpacingHorizontal", value.Spacing.Horizontal)
        manager:SetAttribute(type .. "SpacingVertical", value.Spacing.Vertical)
    end

    fsLog:Debug("Sent spacing values to the secure environment.")
end

---@param provider FrameProvider
local function LoadProvider(provider, force)
    assert(manager ~= nil)

    local containers = provider:Containers()

    -- skip loading the container if we've already loaded it
    -- 99% of the time we've already loaded it
    local shouldLoad = force or fsEnumerable
        :From(containers)
        :Any(function(x)
            return x.Frame and not x.Frame:GetAttribute("FrameSortLoaded")
        end)

    if not shouldLoad then
        return
    end

    manager:SetAttribute("ProviderName", provider:Name())

    for i, container in ipairs(containers) do
        -- to fix a current blizzard bug where GetPoint() returns nil values on secure frames when their parent's are unsecure
        -- https://github.com/Stanzilla/WoWUIBugs/issues/470
        -- https://github.com/Stanzilla/WoWUIBugs/issues/480
        container.Frame:SetProtected()

        local offset = container.FramesOffset and container:FramesOffset()
        local groupOffset = container.GroupFramesOffset and container:GroupFramesOffset()
        local containerPrefix = provider:Name() .. "Container" .. i

        manager:SetFrameRef(containerPrefix .. "Frame", container.Frame)
        manager:SetAttribute(containerPrefix .. "Type", container.Type)
        manager:SetAttribute(containerPrefix .. "LayoutType", container.LayoutType)
        manager:SetAttribute(containerPrefix .. "IsHorizontalLayout", container.IsHorizontalLayout and container:IsHorizontalLayout())
        manager:SetAttribute(containerPrefix .. "FramesPerLine", container.FramesPerLine and container:FramesPerLine())
        manager:SetAttribute(containerPrefix .. "VisibleOnly", container.VisibleOnly or false)
        manager:SetAttribute(containerPrefix .. "SupportsSpacing", container.SupportsSpacing)
        manager:SetAttribute(containerPrefix .. "IsGrouped", container.IsGrouped and container:IsGrouped())
        manager:SetAttribute(containerPrefix .. "OffsetX", offset and offset.X)
        manager:SetAttribute(containerPrefix .. "OffsetY", offset and offset.Y)
        manager:SetAttribute(containerPrefix .. "GroupOffsetX", groupOffset and groupOffset.X)
        manager:SetAttribute(containerPrefix .. "GroupOffsetY", groupOffset and groupOffset.Y)
    end

    manager:SetAttribute(provider:Name() .. "ContainersCount", #containers)
    manager:Execute([[ self:RunAttribute("LoadProvider") ]])

    for _, item in ipairs(containers) do
        -- flag as imported
        item.Frame:SetAttribute("FrameSortLoaded", true)
    end

    fsLog:Debug(string.format("Sent provider %s to the secure environment.", provider:Name()))
end

local function InjectSecureHelpers(secureFrame)
    if not secureFrame.Execute then
        function secureFrame:Execute(body)
            return wow.SecureHandlerExecute(self, body)
        end
    end

    if not secureFrame.WrapScript then
        function secureFrame:WrapScript(frame, script, preBody, postBody)
            return wow.SecureHandlerWrapScript(frame, script, self, preBody, postBody)
        end
    end

    if not secureFrame.SetFrameRef then
        function secureFrame:SetFrameRef(label, refFrame)
            return wow.SecureHandlerSetFrameRef(self, label, refFrame)
        end
    end
end

local function OnCombatStarting()
    -- we want our sorting code to run after blizzard and other frame addons refresh their frames
    -- i.e., we want to handle GROUP_ROSTER_UPDATE/UNT_PET after frame addons have performed their update handling
    -- this is easily achieved in the insecure environment by using hooks, however in the restricted environment we have no such luxury
    -- fortunately it seems blizzard invoke event handlers roughly in the order that they were registered
    -- so if we register our events later, our code will run later
    -- of course it's not good to rely on this and we should generally treat event ordering as undefined
    -- perhaps in a future patch this implementation detail could change and our code will break
    -- however until a better solution can be found, this is our only hope

    for _, header in ipairs(headers) do
        header:UnregisterEvent(wow.Events.GROUP_ROSTER_UPDATE)
        header:UnregisterEvent(wow.Events.UNIT_PET)
        header:UnregisterEvent(wow.Events.UNIT_NAME_UPDATE)

        header:RegisterEvent(wow.Events.GROUP_ROSTER_UPDATE)
        header:RegisterEvent(wow.Events.UNIT_PET)
        header:RegisterEvent(wow.Events.UNIT_NAME_UPDATE)
    end
end

local function OnProviderContainersChanged(provider)
    fsScheduler:RunWhenCombatEnds(function()
        LoadProvider(provider, true)
    end)
end

local function OnProviderRequestSort(provider)
    -- don't respond to provider events during combat
    if wow.InCombatLockdown() then return end

    -- we may have loaded the provider before it had a chance to initialise itself
    -- so re-import the provider if it's changed
    -- there's likely a better event to place this instead of here as it's too noisy
    LoadProvider(provider)
end

local function OnConfigChanged()
    fsScheduler:RunWhenCombatEnds(function()
        LoadSpacing()
        LoadEnabled()
    end, "SecureSortConfigChanged")
end

local function OnRaidGroupLoaded(group)
    if not group or group:IsProtected() then return end

    fsScheduler:RunWhenCombatEnds(function()
        group:SetProtected()
    end)
end

local function ConfigureHeader(header)
    InjectSecureHelpers(header)

    function header:UnitButtonCreated(index)
        local children = { header:GetChildren() }
        local frame = children[index]

        if not frame then
            fsLog:Error("Failed to find unit button " .. index)
            return
        end

        fsScheduler:RunWhenCombatEnds(function()
            -- the refreshUnitChange script doesn't capture when the unit is changed to nil
            -- which can happen when a pet is dismissed or dies
            -- so we're only interested in unit changing to nil here
            frame:SetAttribute("_onattributechanged", [[
                if name ~= "unit" or value ~= nil then return end
                if SecureCmdOptionParse("[combat] true; false") ~= "true" then return end

                local manager = self:GetAttribute("Manager")
                manager:SetAttribute("state-framesort-toggle", random())
            ]])
        end)
    end

    -- show as much as possible
    header:SetAttribute("showRaid", true)
    header:SetAttribute("showParty", true)
    header:SetAttribute("showPlayer", true)
    header:SetAttribute("showSolo", true)

    -- unit buttons template type
    header:SetAttribute("template", "SecureHandlerAttributeTemplate")

    -- fired when a new unit button is created
    header:SetAttribute("initialConfigFunction", [=[
        UnitButtonsCount = (UnitButtonsCount or 0) + 1

        -- self = the newly created unit button
        self:SetWidth(0)
        self:SetHeight(0)
        self:SetAttribute("Manager", Manager)

        RefreshUnitChange = [[
            if SecureCmdOptionParse("[combat] true; false") ~= "true" then return end

            local manager = self:GetAttribute("Manager")

            -- Blizzard iterate over all the unit buttons and change their unit token
            -- so to avoid spamming multiple sort attempts, only perform a sort once the last unit button has been updated
            -- we can determine this by knowing that our button ordering is the default group ordering
            -- so the last unit (unitN) will be where the next unit (unitN+1) doesn't exist
            local unit = self:GetAttribute("unit")
            local unitNumber = strmatch(unit, "%d+")

            -- might be "player" or "pet"
            if not unitNumber then return end

            local nextUnit = gsub(unit, unitNumber, tonumber(unitNumber) + 1)

            -- if the next unit exists, we'll get called again in Blizzard's next loop iteration
            if UnitExists(nextUnit) then return end

            manager:SetAttribute("state-framesort-toggle", random())
        ]]

        self:SetAttribute("refreshUnitChange", RefreshUnitChange)

        Header:CallMethod("UnitButtonCreated", UnitButtonsCount)
    ]=])

    header:SetFrameRef("Manager", manager)

    header:Execute([[
        Header = self
        Manager = self:GetFrameRef("Manager")
    ]])

    -- must be shown for it to work
    header:SetPoint("TOPLEFT", wow.UIParent, "TOPLEFT")
    header:Show()
end

function M:Init()
    manager = wow.CreateFrame("Frame", nil, wow.UIParent, "SecureHandlerStateTemplate")

    InjectSecureHelpers(manager)

    function manager:InvokeCallbacks()
        fsSorting:InvokeCallbacks()
    end

    for name, snippet in pairs(secureMethods) do
        manager:SetAttribute(name, snippet)
    end

    manager:Execute([[ self:RunAttribute("Init") ]])

    manager:WrapScript(
        manager,
        "OnAttributeChanged",
        [[
            if not strmatch(name, "framesort") then return end

            self:RunAttribute("TrySort")
        ]])

    local groupHeader = wow.CreateFrame("Frame", nil, wow.UIParent, "SecureGroupHeaderTemplate")
    local petHeader = wow.CreateFrame("Frame", nil, wow.UIParent, "SecureGroupPetHeaderTemplate")

    headers = { groupHeader, petHeader }
    for _, header in ipairs(headers) do
        ConfigureHeader(header)
    end

    for _, provider in ipairs(fsProviders.All) do
        LoadProvider(provider)
        provider:RegisterRequestSortCallback(OnProviderRequestSort)
        provider:RegisterContainersChangedCallback(OnProviderContainersChanged)
    end

    LoadEnabled()
    LoadUnits()
    LoadSpacing()

    fsConfig:RegisterConfigurationChangedCallback(OnConfigChanged)

    wow.hooksecurefunc("CompactRaidGroup_OnLoad", OnRaidGroupLoaded)

    local combatStartingFrame = wow.CreateFrame("Frame", nil, wow.UIParent)
    combatStartingFrame:HookScript("OnEvent", OnCombatStarting)
    combatStartingFrame:RegisterEvent(wow.Events.PLAYER_REGEN_DISABLED)
end

function M:RefreshUnits()
    LoadUnits()
end
