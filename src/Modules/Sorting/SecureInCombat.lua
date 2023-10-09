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
local secureMethods = {}

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

        if child:IsVisible() and
            name and
            strmatch(name, "CompactRaidGroup") and
            (left and bottom and width and height) then
            groups[#groups + 1] = child
        end
    end

    _G[destinationTableName] = groups
    return #groups > 0
]]

-- returns the index of the item within the array, or -1 if it doesn't exist
secureMethods["ArrayIndex"] = [[
    local arrayVariable, item = ...
    local array = _G[arrayVariable]

    for i, value in ipairs(array) do
        if value == item then
            return i
        end
    end

    return -1
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

-- returns the width x height of the frames in a grid layout.
secureMethods["GridSize"] = [[
    local framesVariable = ...
    local frames = _G[framesVariable]

    if #frames == 0 then return 0, 0 end
    if #frames == 1 then return 1, 1 end

    local width = 1
    local height = 1

    local byCol = newtable()
    local byRow = newtable()

    ByCol = byCol
    self:RunAttribute("CopyTable", framesVariable, "ByCol")
    self:RunAttribute("SortFramesByLeftTop", "ByCol")
    ByCol = nil

    ByRow = byRow
    self:RunAttribute("CopyTable", framesVariable, "ByRow")
    self:RunAttribute("SortFramesByTopLeft", "ByRow")
    ByRow = nil

    local columnHeight = 1
    for i = 2, #byCol do
        local frame = byCol[i]
        local previous = byCol[i - 1]
        local left, _, _, _ = frame:GetRect()
        local previousLeft, _, _, _ = previous:GetRect()
        local sameColumn = self:RunAttribute("Round", left) == self:RunAttribute("Round", previousLeft)

        if sameColumn then
            columnHeight = columnHeight + 1
            height = max(height, columnHeight)
        else
            columnHeight = 0
        end
    end

    local rowWidth = 1
    for i = 2, #byRow do
        local frame = byRow[i]
        local previous = byRow[i - 1]
        local _, bottom, _, height = frame:GetRect()
        local _, previousBottom, _, previousHeight = previous:GetRect()
        local sameRow = self:RunAttribute("Round", bottom + height) == self:RunAttribute("Round", previousBottom + previousHeight)

        if sameRow then
            rowWidth = rowWidth + 1
            width = max(width, rowWidth)
        else
            rowWidth = 0
        end
    end

    return width, height
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
secureMethods["SortFramesByLeftTop"] = [[
    local framesVariable = ...
    local frames = _G[framesVariable]

    for i = 1, #frames do
        for j = 1, #frames - i do
            local left, bottom, width, height = frames[j]:GetRect()
            local nextLeft, nextBottom, nextWidth, nextHeight = frames[j + 1]:GetRect()

            local topFuzzy = self:RunAttribute("Round", bottom + height)
            local nextTopFuzzy = self:RunAttribute("Round", nextBottom + nextHeight)
            local leftFuzzy = self:RunAttribute("Round", left)
            local nextLeftFuzzy = self:RunAttribute("Round", nextLeft)

            if leftFuzzy > nextLeftFuzzy or topFuzzy < nextTopFuzzy then
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
        local sameRow = self:RunAttribute("Round", point.Bottom) == self:RunAttribute("Round", previous.Bottom)

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
            -- TODO: this would be a bug, log it
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

    local width, height = self:RunAttribute("GridSize", framesVariable)

    -- TODO: source this value properly
    local isHorizontalLayout = width > height

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
            xOffset = xOffset + blockWidth + spacing.Horizontal
            -- keep track of the tallest frame within the row
            -- as the next row will be the tallest row frame + spacing
            rowHeight = max(rowHeight, height)

            -- if we've reached the end then wrap around
            if col > width then
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
            if row > height then
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

secureMethods["TrySortContainerGroups"] = [[
    local containerVariable, providerVariable = ...
    local container = _G[containerVariable]
    local provider = _G[providerVariable]

    Groups = nil

    local sorted = false

    if not self:RunAttribute("ExtractGroups", containerVariable, "Groups") then
        return false
    end

    for _, group in ipairs(Groups) do
        GroupContainer = newtable()
        GroupContainer.Frame = group
        GroupContainer.Type = container.Type

        local groupSorted = self:RunAttribute("TrySortContainer", "GroupContainer", providerVariable)
        sorted = sorted or groupSorted

        GroupContainer = nil
    end

    local horizontalSpacing = self:GetAttribute(container.Type .. "SpacingHorizontal")
    local verticalSpacing = self:GetAttribute(container.Type .. "SpacingVertical")

    if horizontalSpacing or verticalSpacing then
        GroupSpacing = newtable()
        GroupSpacing.Horizontal = horizontalSpacing
        GroupSpacing.Vertical = verticalSpacing

        local spacedGroup = self:RunAttribute("SpaceGroups", "Groups", "GroupSpacing")
        sorted = sorted or spacedGroup
    end

    Groups = nil
]]

-- attempts to sort the frames within the container
secureMethods["TrySortContainer"] = [[
    local friendlyEnabled = self:GetAttribute("FriendlySortEnabled")
    local enemyEnabled = self:GetAttribute("EnemySortEnabled")

    local containerVariable, providerVariable = ...
    local container = _G[containerVariable]
    local provider = _G[providerVariable]

    Children = newtable()
    Frames = newtable()

    -- import into the global table for filtering
    container.Frame:GetChildList(Children)

    -- blizzard frames can have non-existant units assigned, so filter them out
    if not self:RunAttribute("ExtractUnitFrames", "Children", "Frames", provider.IsBlizzard) then
        return false
    end

    Spacing = nil

    if provider.IsBlizzard then
        local horizontalSpacing = self:GetAttribute(container.Type .. "SpacingHorizontal")
        local verticalSpacing = self:GetAttribute(container.Type .. "SpacingVertical")

        if (horizontalSpacing and horizontalSpacing ~= 0) or (verticalSpacing and verticalSpacing ~= 0) then
            Spacing = newtable()
            Spacing.Horizontal = horizontalSpacing
            Spacing.Vertical = verticalSpacing
        end
    end

    local units = nil

    if container.Type == "Party" then
        units = FriendlyUnits
    elseif container.Type == "Raid" then
        units = FriendlyUnits
    elseif container.Type == "EnemyArena" then
        units = EnemyUnits
    else
        -- TODO: log bug
    end

    Units = units or newtable()

    -- sort the frames to the desired locations
    FramesInUnitOrder = nil
    self:RunAttribute("SortFramesByUnits", "Frames", "Units", "FramesInUnitOrder")

    local sorted = false

    if container.LayoutType == "Hard" then
        sorted = self:RunAttribute("HardArrange", "FramesInUnitOrder", containerVariable, Spacing and "Spacing")
    else
        sorted = self:RunAttribute("SoftArrange", "FramesInUnitOrder", Spacing and "Spacing")
    end

    FramesInUnitOrder = nil
    Spacing = nil

    return sorted
]]

-- top level perform sort routine
secureMethods["TrySort"] = [[
    if not self:RunAttribute("InCombat") then return false end
    if not Providers then return false end

    local friendlyEnabled = self:GetAttribute("FriendlySortEnabled")
    local enemyEnabled = self:GetAttribute("EnemySortEnabled")

    if not friendlyEnabled and not enemyEnabled then return false end

    local loadedUnits = self:GetAttribute("LoadedUnits")
    if not loadedUnits then
        self:RunAttribute("LoadUnits")
        self:SetAttribute("LoadedUnits", true)
    end

    local sorted = false

    for _, provider in pairs(Providers) do
        local providerEnabled = self:GetAttribute("Provider" .. provider.Name .. "Enabled")
        if providerEnabled then
            local containers = newtable()

            if friendlyEnabled then
                containers[#containers + 1] = provider.Party
                containers[#containers + 1] = provider.Raid
            end

            if enemyEnabled then
                containers[#containers + 1] = provider.EnemyArena
            end

            for _, container in ipairs(containers) do
                if container.Frame and container.Frame:IsVisible() then
                    Container = container
                    Provider = provider

                    local containerSorted = self:RunAttribute("TrySortContainer", "Container", "Provider")
                    sorted = sorted or containerSorted

                    local hasGroups = provider.IsBlizzard and container.Type == "Raid"

                    if hasGroups then
                        local sortedGroups = self:RunAttribute("TrySortContainerGroups", "Container", "Provider")
                        sorted = sorted or sortedGroups
                    end

                    Provider = nil
                    Container = nil
                end
            end
        end
    end

    if sorted then
        -- notify unsecure code to invoke callbacks
        self:CallMethod("InvokeCallbacks")
    end

    return sorted
]]

secureMethods["LoadProvider"] = [[
    local name = self:GetAttribute("ProviderName")
    local provider = Providers[name]

    if not provider then
        provider = newtable()
        provider.Name = name
        provider.IsBlizzard = name == "Blizzard"
        Providers[name] = provider
    end

    local types = newtable()
    types[#types + 1] = "Party"
    types[#types + 1] = "Raid"
    types[#types + 1] = "EnemyArena"

    for _, type in ipairs(types) do
        local frame = self:GetFrameRef(type .. "Container")
        local hasType = self:GetAttribute(type)

        if frame and hasType then
            local data = newtable()

            data.Frame = frame
            data.Type = type

            local offsetX = self:GetAttribute(type .. "OffsetX")
            local offsetY = self:GetAttribute(type .. "OffsetY")

            if offsetX or offsetY then
                data.Offset = newtable()
                data.Offset.X = offsetX or 0
                data.Offset.Y = offsetY or 0
            end

            data.LayoutType = self:GetAttribute(type .. "LayoutType")

            provider[type] = data
        end
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
    manager = self
    Providers = newtable()

    -- don't move frames if they are have minuscule position differences
    -- it's just a rounding error and makes no visual impact
    -- this helps preventing spam on our callbacks
    DecimalSanity = 2
]]

local function LoadUnits()
    assert(manager ~= nil)

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

    fsLog:Debug("Sent units to the secure environment.")
end

local function LoadEnabled()
    assert(manager ~= nil)

    local friendlyEnabled = fsCompare:FriendlySortMode()
    local enemyEnabled = fsCompare:EnemySortMode()

    manager:SetAttribute("FriendlySortEnabled", friendlyEnabled)
    manager:SetAttribute("EnemySortEnabled", enemyEnabled)

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
local function LoadProvider(provider)
    assert(manager ~= nil)

    local data = {
        {
            Container = provider:PartyContainer(),
            Type = "Party"
        },
        {
            Container = provider:RaidContainer(),
            Type = "Raid"
        },
        {
            Container = provider:EnemyArenaContainer(),
            Type = "EnemyArena"
        }
    }

    if provider == fsProviders.Blizzard then
        if provider:IsRaidGrouped() then
            local groups = provider:RaidGroups()

            -- c'mon blizzard, seriously?
            for _, group in ipairs(groups) do
                group:SetProtected()
            end
        end

        for i = 1, #data do
            local row = data[i]
            local container = row.Container
            if container.title and type(container.title) == "table" and type(container.title.GetHeight) == "function" then
                row.Offset = {
                    Y = -container.title:GetHeight()
                }
            end
        end
    end

    -- skip loading the container if we've already loaded it
    -- 99% of the time we've already loaded it
    local shouldLoad = fsEnumerable
        :From(data)
        :Any(function(x)
            return x.Container and not x.Container:GetAttribute("FrameSortLoaded")
        end)

    if not shouldLoad then
        return
    end

    manager:SetAttribute("ProviderName", provider:Name())

    for _, item in ipairs(data) do
        manager:SetAttribute(item.Type, item.Container and true or false)

        if item.Container then
            -- to fix a current blizzard bug where GetPoint() returns nil values on secure frames when their parent's are unsecure
            -- https://github.com/Stanzilla/WoWUIBugs/issues/470
            -- https://github.com/Stanzilla/WoWUIBugs/issues/480
            item.Container:SetProtected()

            manager:SetAttribute(item.Type .. "OffsetX", item.Offset and item.Offset.X)
            manager:SetAttribute(item.Type .. "OffsetY", item.Offset and item.Offset.Y)
            manager:SetAttribute(item.Type .. "LayoutType", provider == fsProviders.Blizzard and "Hard" or "Soft")
            manager:SetFrameRef(item.Type .. "Container", item.Container)
        end
    end

    manager:Execute([[ self:RunAttribute("LoadProvider") ]])

    for _, item in ipairs(data) do
        if item.Container then
            -- flag as imported
            item.Container:SetAttribute("FrameSortLoaded", true)
        end
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

local function OnProviderUpdate(provider)
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

local function OnBlizzardUnitFrameCreated(frame)
    assert(manager ~= nil)

    local alreadyWatching = frame:GetAttribute("FrameSortWatching")
    if alreadyWatching then return end

    local attributeHandler = [[
        if not strmatch(name, "unit") then return end

        local manager = self:GetFrameRef("FrameSortManager")

        if manager then
            manager:RunAttribute("TrySort")
        end
    ]]

    local showHideHandler = [[
        local manager = self:GetFrameRef("FrameSortManager")

        if manager then
            manager:RunAttribute("TrySort")
        end
    ]]

    fsScheduler:RunWhenCombatEnds(function()
        wow.SecureHandlerSetFrameRef(frame, "FrameSortManager", manager)

        manager:WrapScript(frame, "OnAttributeChanged", attributeHandler)
        manager:WrapScript(frame, "OnShow", showHideHandler)
        manager:WrapScript(frame, "OnHide", showHideHandler)

        frame:SetAttribute("FrameSortWatching", true)
        fsLog:Debug("Watching frame " .. (frame:GetName() or "nil"))
    end)
end

function M:Init()
    manager = wow.CreateFrame("Frame", "FrameSortGroupmanager", wow.UIParent, "SecureHandlerStateTemplate")

    InjectSecureHelpers(manager)

    function manager:InvokeCallbacks()
        fsSorting:InvokeCallbacks()
    end

    for name, snippet in pairs(secureMethods) do
        manager:SetAttribute(name, snippet)
    end

    manager:Execute([[ self:RunAttribute("Init") ]])

    -- TODO: remove the need for this dodgy workaround once we capture all frame refresh events
    wow.RegisterAttributeDriver(manager, "state-framesort-mod", "[mod] true; false")

    for i = 0, wow.MAX_RAID_MEMBERS do
        wow.RegisterAttributeDriver(manager, "state-framesort-raid" .. i, string.format("[@raid%d, exists] true; false", i))
        wow.RegisterAttributeDriver(manager, "state-framesort-raidpet" .. i, string.format("[@raidpet%d, exists] true; false", i))
    end

    for i = 0, wow.MEMBERS_PER_RAID_GROUP - 1 do
        wow.RegisterAttributeDriver(manager, "state-framesort-party" .. i, string.format("[@party%d, exists] true; false", i))
        wow.RegisterAttributeDriver(manager, "state-framesort-partypet" .. i, string.format("[@partypet%d, exists] true; false", i))
    end

    for i = 0, wow.MEMBERS_PER_RAID_GROUP - 1 do
        wow.RegisterAttributeDriver(manager, "state-framesort-arena" .. i, string.format("[@arena%d, exists] true; false", i))
        wow.RegisterAttributeDriver(manager, "state-framesort-arenapet" .. i, string.format("[@arenapet%d, exists] true; false", i))
    end

    manager:WrapScript(
        manager,
        "OnAttributeChanged",
        [[
            if not strmatch(name, "framesort") then return end

            self:RunAttribute("TrySort")
        ]])

    for _, provider in ipairs(fsProviders.All) do
        LoadProvider(provider)
        provider:RegisterCallback(OnProviderUpdate)
    end

    LoadEnabled()
    LoadUnits()
    LoadSpacing()

    fsConfig:RegisterConfigurationChangedCallback(OnConfigChanged)

    ---@diagnostic disable-next-line: undefined-global
    if CompactUnitFrame_SetUpFrame then
        wow.hooksecurefunc("CompactUnitFrame_SetUpFrame", OnBlizzardUnitFrameCreated)
    end
end

function M:RefreshUnits()
    LoadUnits()
end
