---@type string, Addon
local _, addon = ...
local wow = addon.WoW.Api
local wowEx = addon.WoW.WowEx
local events = addon.WoW.Events
local fsSorting = addon.Modules.Sorting
local fsCompare = addon.Modules.Sorting.Comparer
local fsProviders = addon.Providers
local fsUnit = addon.WoW.Unit
local fsSortedUnits = addon.Modules.Sorting.SortedUnits
local fsScheduler = addon.Scheduling.Scheduler
local fsConfig = addon.Configuration
local fsEnumerable = addon.Collections.Enumerable
local fsLog = addon.Logging.Log
local fsFrame = addon.WoW.Frame
local M = {}
addon.Modules.Sorting.Secure.InCombat = M

local manager = nil
local memberHeader = nil
local petHeader = nil
local headers = {}
local secureMethods = {}

-- Findings:
-- * Calling RunAttribute has a massive overhead.
-- * RoundNative performs about 10x faster than the RunAttribute version.
-- So we want to avoid calling RunAttribute and instead inline code for tight loops.
secureMethods["OverheadTest"] = [[
    local run = control or self
    local times = 1000
    local decimalPlaces = 0

    run:CallMethod("StartTimer", "RoundMethod")
    for i = 1, times do
        local number = i + random()
        local rounded = run:RunAttribute("Round", number, decimalPlaces)
    end
    run:CallMethod("StopTimer", "RoundMethod", "RoundMethod took %fms.")

    run:CallMethod("StartTimer", "RoundNative")
    for i = 1, times do
        local number = i + random()
        local mult = 10 ^ (decimalPlaces or 0)
        local rounded = math.floor(number * mult + 0.5) / mult
    end
    run:CallMethod("StopTimer", "RoundNative", "RoundNative took %fms.")
]]

-- this method is no longer used because the overhead of calling RunAttribute is very expensive
-- and Round was being called in tight loops which caused significant time increase
-- even though overall we're only talking in milliseconds difference I still want to run as fast as possible
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
    local run = control or self
    local framesVariable = ...
    local frame = _G[framesVariable]

    if not frame then
        run:CallMethod("Log", "GetUnit was passed a nil frame.", LogLevel.Critical)
        return nil
    end

    local unit = frame:GetAttribute("unit")

    if not unit then
        local name = frame:GetName()
        return name and strmatch(name, "arena%d")
    end

    local underlyingUnit = gsub(unit, "pet", "")

    if UnitHasVehicleUI(underlyingUnit) then
        return underlyingUnit, unit
    end

    return unit, unit
]]

-- filters a set of frames to only unit frames
secureMethods["ExtractUnitFrames"] = [[
    local run = control or self
    local framesVariable, destinationVariable, visibleOnly = ...
    local children = _G[framesVariable]

    if not children then
        run:CallMethod("Log", format("ExtractUnitFrames was passed a nil value, framesVariable: %s, destinationVariable: %s.", framesVariable or "nil", destinationVariable or "nil"), LogLevel.Critical)
        return false
    end

    local unitFrames = newtable()

    for _, child in ipairs(children) do
        Frame = child
        local unit = run:RunAttribute("GetUnit", "Frame")
        Frame = nil

        -- in some rare cases frames can have no position, so exclude them
        local left, bottom, width, height = child:GetRect()

        local hasSize =  left and bottom and width and height

        if not hasSize then
            run:CallMethod("Log", format("Frame '%s' has no size.", child:GetName() or "nil"), LogLevel.Warning)
        end

        if unit and
            (child:IsVisible() or not visibleOnly) and
            (hasSize) then
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
    local run = control or self
    local fromName, toName = ...
    local from = _G[fromName]
    local to = _G[toName]

    if not from or not to then
        run:CallMethod("Log", format("CopyTable was passed a nil value, from: %s to: %s.", fromName or "nil", toName or "nil"), LogLevel.Critical)
        return
    end

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

    if not root then
        return false
    end

    -- assert we have a complete chain
    local count = 0
    local current = root
    local visited = newtable()

    while current do
        if visited[current] then
            -- protect against circular references
            return false
        end

        visited[current] = true
        count = count + 1
        current = current.Next
    end

    if count ~= #frames then
        return false
    end

    _G[destinationVariable] = root

    return true
]]

-- stable insertion sort
-- not going to write an nlog(n) sort algorithm in this environment
secureMethods["Sort"] = [[
    local run = control or self
    local arrayName, compareName, extraArg1 = ...
    local array = _G[arrayName]

    for i = 2, #array do
        local currentValue = array[i]
        local insertPos = i - 1

        -- Shift larger elements to the right
        while insertPos >= 1 do
            Left  = array[insertPos]
            Right = currentValue

            -- true means left should come before right
            local leftBeforeRight = run:RunAttribute(compareName, "Left", "Right", extraArg1)

            if leftBeforeRight then
                -- we've found the correct spot, bail out
                break
            else
                -- shift one step to the right
                array[insertPos + 1] = array[insertPos]
                insertPos = insertPos - 1
            end
        end

        -- Insert the saved element into its final position
        array[insertPos + 1] = currentValue
    end

    -- Cleanup
    Left, Right = nil, nil
]]

secureMethods["CompareFrameTopLeft"] = [[
    local run = control or self
    local leftVariable, rightVariable = ...
    local x, y = _G[leftVariable], _G[rightVariable]

    local left, bottom, width, height = x:GetRect()
    local nextLeft, nextBottom, nextWidth, nextHeight = y:GetRect()

    if not left or not bottom or not height or not width then
        return false
    end

    if not nextLeft or not nextBottom or not nextHeight or not nextWidth then
        return true
    end

    local mult = 10 ^ DecimalSanity
    local topFuzzy = math.floor((bottom + height) * mult + 0.5) / mult
    local nextTopFuzzy = math.floor((nextBottom + nextHeight) * mult + 0.5) / mult

    if topFuzzy ~= nextTopFuzzy then
        return topFuzzy > nextTopFuzzy
    end

    local leftFuzzy = math.floor(left * mult + 0.5) / mult
    local nextLeftFuzzy = math.floor(nextLeft * mult + 0.5) / mult

    return leftFuzzy < nextLeftFuzzy
]]

secureMethods["CompareFrameTopRight"] = [[
    local run = control or self
    local leftVariable, rightVariable = ...
    local x, y = _G[leftVariable], _G[rightVariable]

    local left, bottom, width, height = x:GetRect()
    local nextLeft, nextBottom, nextWidth, nextHeight = y:GetRect()

    if not left or not bottom or not height or not width then
        return false
    end

    if not nextLeft or not nextBottom or not nextHeight or not nextWidth then
        return true
    end

    local mult = 10 ^ DecimalSanity
    local topFuzzy = math.floor((bottom + height) * mult + 0.5) / mult
    local nextTopFuzzy = math.floor((nextBottom + nextHeight) * mult + 0.5) / mult

    if topFuzzy ~= nextTopFuzzy then
        return topFuzzy > nextTopFuzzy
    end

    local rightFuzzy = math.floor((left + width) * mult + 0.5) / mult
    local nextRightFuzzy = math.floor((nextLeft + nextWidth) * mult + 0.5) / mult

    return rightFuzzy > nextRightFuzzy
]]

secureMethods["CompareFrameBottomLeft"] = [[
    local run = control or self
    local leftVariable, rightVariable = ...
    local x, y = _G[leftVariable], _G[rightVariable]

    local left, bottom, width, height = x:GetRect()
    local nextLeft, nextBottom, nextWidth, nextHeight = y:GetRect()

    if not left or not bottom or not height or not width then
        return false
    end

    if not nextLeft or not nextBottom or not nextHeight or not nextWidth then
        return true
    end

    local mult = 10 ^ DecimalSanity
    local bottomFuzzy = math.floor(bottom * mult + 0.5) / mult
    local nextBottomFuzzy = math.floor(nextBottom * mult + 0.5) / mult

    if bottomFuzzy ~= nextBottomFuzzy then
        return bottomFuzzy < nextBottomFuzzy
    end

    local leftFuzzy = math.floor(left * mult + 0.5) / mult
    local nextLeftFuzzy = math.floor(nextLeft * mult + 0.5) / mult

    return leftFuzzy < nextLeftFuzzy
]]

secureMethods["ComparePointTopLeft"] = [[
    local run = control or self
    local leftVariable, rightVariable = ...
    local x, y = _G[leftVariable], _G[rightVariable]

    if not x.Bottom or not x.Height or not x.Left then
        return false
    end

    if not y.Bottom or not y.Height or not y.Left then
        return true
    end

    local mult = 10 ^ DecimalSanity
    local topFuzzy = math.floor((x.Bottom + x.Height) * mult + 0.5) / mult
    local nextTopFuzzy = math.floor((y.Bottom + y.Height) * mult + 0.5) / mult

    if topFuzzy ~= nextTopFuzzy then
        return topFuzzy > nextTopFuzzy
    end

    local leftFuzzy = math.floor(x.Left * mult + 0.5) / mult
    local nextLeftFuzzy = math.floor(y.Left * mult + 0.5) / mult

    return leftFuzzy < nextLeftFuzzy
]]

secureMethods["ComparePointLeftTop"] = [[
    local run = control or self
    local leftVariable, rightVariable = ...
    local x, y = _G[leftVariable], _G[rightVariable]

    if not x.Bottom or not x.Height or not x.Left then
        return false
    end

    if not y.Bottom or not y.Height or not y.Left then
        return true
    end

    local mult = 10 ^ DecimalSanity
    local topFuzzy = math.floor((x.Bottom + x.Height) * mult + 0.5) / mult
    local nextTopFuzzy = math.floor((y.Bottom + y.Height) * mult + 0.5) / mult

    if topFuzzy ~= nextTopFuzzy then
        return topFuzzy > nextTopFuzzy
    end

    local leftFuzzy = math.floor(x.Left * mult + 0.5) / mult
    local nextLeftFuzzy = math.floor(y.Left * mult + 0.5) / mult

    return leftFuzzy < nextLeftFuzzy
]]

secureMethods["CompareFrameGroup"] = [[
    local run = control or self
    local leftVariable, rightVariable, playerSortMode = ...
    local leftFrame = _G[leftVariable]
    local rightFrame = _G[rightVariable]

    -- Get their units
    Frame = leftFrame
    local leftUnit = run:RunAttribute("GetUnit", "Frame")
    Frame = rightFrame
    local rightUnit = run:RunAttribute("GetUnit", "Frame")
    Frame = nil

    if not leftUnit or not rightUnit then
        -- if we don't know, keep existing order
        return false
    end

    local isLeftPet = strfind(leftUnit, "pet") ~= nil
    local isRightPet = strfind(rightUnit, "pet") ~= nil

    if isLeftPet and not isRightPet then
        return false
    elseif not isLeftPet and isRightPet then
        return true
    end

    -- Top/Bottom is good enough, won't worry about middle in this environment
    -- if we got here we're in a fallback position anyway
    if playerSortMode and leftUnit == "player" then
        return playerSortMode == "Top"
    end

    if playerSortMode and rightUnit == "player" then
        return playerSortMode == "Bottom"
    end

    local leftIndex = tonumber(strmatch(leftUnit, "%d+")) or 0
    local rightIndex = tonumber(strmatch(rightUnit, "%d+")) or 0

    return leftIndex < rightIndex
]]

-- performs an out of place sort on an array frames by the order of the units array
secureMethods["SortFramesByUnits"] = [[
    local run = control or self
    local framesVariable, unitsVariable, destinationVariable = ...
    local frames = _G[framesVariable]
    local units = _G[unitsVariable]
    local index = 1
    local framesByUnit = newtable()
    local frameWasSorted = newtable()

    for i = 1, #frames do
        local frame = frames[i]

        Frame = frame
        local unit = run:RunAttribute("GetUnit", "Frame")
        Frame = nil

        if unit then
            local existingFrame = framesByUnit[unit]

            if existingFrame then
                -- this happens when the unit is in a vehicle
                -- in which case they will have 2 frames; their player frame which becomesvehicle frame, and a pet frame
                -- we want the player frame first, so sort by frame height

                if frame:GetHeight() > existingFrame:GetHeight() then
                    -- unsort the existing frame and it'll just go to the end
                    frameWasSorted[existingFrame] = false

                    -- insert the new frame
                    framesByUnit[unit] = frame
                    frameWasSorted[frame] = true
                end
            else
                framesByUnit[unit] = frame
            end
        else
            run:CallMethod("Log", format("Failed to determine unit of frame: %s.", frame:GetName() or "nil"), LogLevel.Warning)
        end
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

    -- any frames left unsorted at this point?
    local unsortedFrames = false

    for i = 1, #frames do
        local frame = frames[i]

        if not frameWasSorted[frame] and frame:IsVisible() then
            Frame = frame
            local unit, maybePet = run:RunAttribute("GetUnit", "Frame")
            Frame = nil

            local isPet = maybePet and strfind(maybePet, "pet") ~= nil

            -- don't care if it's an unsorted pet, as we'll just place them at the end
            if not isPet then
                run:CallMethod("Log", format("Couldn't find destination position for frame %s with unit %s", frame:GetName() or "nil", unit or "nil"), LogLevel.Error)
                unsortedFrames = true
                break
            end
        end
    end

    -- we can't sort frames, something has changed during combat
    if unsortedFrames then
        return false
    end

    -- we may not have all pet unit information
    -- so any frames that didn't make it we can just add on to the end
    for i = 1, #frames do
        local frame = frames[i]

        if not frameWasSorted[frame] then
            sorted[#sorted + 1] = frame
        end
    end

    _G[destinationVariable] = sorted
    return true
]]

-- adjusts the x and y offsets of a frame
secureMethods["AdjustPointsOffset"] = [[
    local framesVariable, xDelta, yDelta = ...
    local frame = _G[framesVariable]

    if not frame then
        run:CallMethod("Log", format("AdjustPointsOffset was passed a nil frame, framesVariable: %s.", framesVariable or "nil"), LogLevel.Critical)
        return nil
    end

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

    local newRelativeTo = relativeTo

    if not newRelativeTo then
        newRelativeTo = "$parent"
    else
        local isProtected, explicitly = false, false

        if type(newRelativeTo) == "table" and newRelativeTo.IsProtected then
            isProtected, explicitly = newRelativeTo:IsProtected()
        end

        if not isProtected or not explicitly then
            newRelativeTo = "$parent"
        end
    end

    frame:SetPoint(point, newRelativeTo, relativePoint, newOffsetX, newOffsetY)
    return true
]]

-- returns the spacing configuration for the specified container type
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

-- applies spacing on a set of points
secureMethods["ApplySpacing"] = [[
    local run = control or self
    local pointsVariable, spacingVariable = ...
    local points = _G[pointsVariable]
    local spacing = _G[spacingVariable]

    if not points or not spacing then
        run:CallMethod("Log", format("ApplySpacing was passed a nil value, pointsVariable: %s, spacingVariable: %s.", pointsVariable or "nil", spacingVariable or "nil"), LogLevel.Critical)
        return nil
    end

    local horizontal = spacing.Horizontal or 0
    local vertical = spacing.Vertical or 0

    OrderedTopLeft = newtable()
    OrderedLeftTop = newtable()

    run:RunAttribute("CopyTable", pointsVariable, "OrderedTopLeft")
    run:RunAttribute("CopyTable", pointsVariable, "OrderedLeftTop")

    run:RunAttribute("Sort", "OrderedTopLeft", "ComparePointTopLeft")
    run:RunAttribute("Sort", "OrderedLeftTop", "ComparePointLeftTop")

    local changed = false
    local mult = 10 ^ DecimalSanity

    for i = 2, #OrderedLeftTop do
        local point = OrderedLeftTop[i]
        local previous = OrderedLeftTop[i - 1]
        local pointTopFuzzy = math.floor((point.Bottom + point.Height) * mult + 0.5) / mult
        local previousTopFuzzy = math.floor((previous.Bottom + previous.Height) * mult + 0.5) / mult
        local sameRow = pointTopFuzzy == previousTopFuzzy

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
        local leftFuzzy = math.floor(point.Left * mult + 0.5) / mult
        local previousLeftFuzzy = math.floor(previous.Left * mult + 0.5) / mult
        local sameColumn = leftFuzzy == previousLeftFuzzy

        if sameColumn then
            local existingSpace = previous.Bottom - (point.Bottom + point.Height)
            local yDelta = vertical - existingSpace
            point.Bottom = point.Bottom - yDelta
            changed = changed or yDelta ~= 0
        end
    end

    OrderedTopLeft = nil
    OrderedLeftTop = nil

    return changed
]]

-- applies spacing between raid groups
secureMethods["SpaceGroups"] = [[
    local run = control or self
    local groupsVariable, spacingVariable = ...
    local groups = _G[groupsVariable]
    local spacing = _G[spacingVariable]

    local points = newtable()
    local pointsByGroup = newtable()

    for _, group in ipairs(groups) do
        local point = newtable()
        local left, bottom, width, height = group:GetRect()

        if not left or not bottom or not width or  not height then
            run:CallMethod("Log", format("Group frame %s has no position.", group:GetName() or "nil"), LogLevel.Critical)
        else
            point.Left = left
            point.Bottom = bottom
            point.Width = width
            point.Height = height

            points[#points + 1] = point
            pointsByGroup[group] = point
        end
    end

    GroupPoints = points

    if not run:RunAttribute("ApplySpacing", "GroupPoints", spacingVariable) then
        GroupPoints = nil
        return false
    end

    GroupPoints = nil

    local movedAny = false
    local mult = 10 ^ DecimalSanity

    for _, group in ipairs(groups) do
        local point = pointsByGroup[group]

        if point then
            local left, bottom, _, _ = group:GetRect()
            local xDelta = point.Left - left
            local yDelta = point.Bottom - bottom
            local xDeltaRounded = math.floor(xDelta * mult + 0.5) / mult
            local yDeltaRounded = math.floor(yDelta * mult + 0.5) / mult

            if xDeltaRounded ~= 0 or yDeltaRounded ~= 0 then
                Group = group
                local moved = run:RunAttribute("AdjustPointsOffset", "Group", xDelta, yDelta)
                movedAny = movedAny or moved
                Group = nil
            end
        end
    end

    return movedAny
]]

-- rearranges a set of frames by only modifying the x and y offsets
secureMethods["SoftArrange"] = [[
    local run = control or self
    local framesVariable, spacingVariable = ...
    local frames = _G[framesVariable]

    OrderedByTopLeft = newtable()

    run:RunAttribute("CopyTable", framesVariable, "OrderedByTopLeft")
    run:RunAttribute("Sort", "OrderedByTopLeft", "CompareFrameTopLeft")

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
        run:RunAttribute("ApplySpacing", "Points", spacingVariable)
        Points = nil
    end

    Root = nil
    local isChain = run:RunAttribute("FrameChain", framesVariable, "Root")
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
    local mult = 10 ^ DecimalSanity

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
            local xDeltaRounded = math.floor(xDelta * mult + 0.5) / mult
            local yDeltaRounded = math.floor(yDelta * mult + 0.5) / mult

            if xDeltaRounded ~= 0 or yDeltaRounded ~= 0 then
                Frame = source
                local moved = run:RunAttribute("AdjustPointsOffset", "Frame", xDelta, yDelta)
                movedAny = movedAny or moved
                Frame = nil
            end
        else
            run:CallMethod("Log", "Unable to determine frame's desired index (in-combat).", LogLevel.Warning)
        end
    end

    return movedAny
]]

-- rearranges a set of frames by modifying their anchors and offsets
secureMethods["HardArrange"] = [[
    local run = control or self
    local framesVariable, containerVariable, spacingVariable, blockHeight = ...
    local frames = _G[framesVariable]
    local container = _G[containerVariable]
    local spacing = spacingVariable and _G[spacingVariable]
    local verticalSpacing = spacing and spacing.Vertical or 0
    local horizontalSpacing = spacing and spacing.Horizontal or 0
    local isHorizontalLayout = container.IsHorizontalLayout
    local blocksPerLine = container.FramesPerLine
    local _, _, firstFrameWidth, firstFrameHeight = frames[1]:GetRect()
    local offset = container.Offset or newtable()
    local blockWidth = firstFrameWidth
    blockHeight = blockHeight or firstFrameHeight

    offset.X = offset.X or 0
    offset.Y = offset.Y or 0

    local pointsByFrame = newtable()
    local row, col = 0, 0
    local xOffset = offset.X
    local yOffset = offset.Y
    local currentBlockHeight = 0
    local mult = 10 ^ DecimalSanity

    for _, frame in ipairs(frames) do
        local isNewBlock = currentBlockHeight > 0
            -- add/subtract 1 for a bit of breathing room for rounding errors
            and (
                currentBlockHeight >= (blockHeight - 1)
                or (currentBlockHeight + frame:GetHeight()) >= (blockHeight + 1)
            )

        if isNewBlock then
            currentBlockHeight = 0

            if isHorizontalLayout then
                col = col + 1
            else
                row = row + 1
            end

            xOffset = col * (blockWidth + horizontalSpacing) + offset.X
            yOffset = -row * (blockHeight + verticalSpacing) + offset.Y
        end

        -- if we've reached the end then wrap around
        if isHorizontalLayout and blocksPerLine and col >= blocksPerLine then
            col = 0
            row = row + 1

            xOffset = offset.X
            yOffset = -row * (blockHeight + verticalSpacing) + offset.Y
            currentBlockHeight = 0
        elseif not isHorizontalLayout and blocksPerLine and row >= blocksPerLine then
            row = 0
            col = col + 1

            yOffset = offset.Y
            xOffset = col * (blockWidth + horizontalSpacing) + offset.X
            currentBlockHeight = 0
        end

        local framePoint = newtable()
        framePoint.Point = container.AnchorPoint or "TOPLEFT"
        framePoint.RelativeTo = container.Anchor or container.Frame
        framePoint.RelativePoint = container.AnchorPoint or "TOPLEFT"
        framePoint.XOffset = xOffset
        framePoint.YOffset = yOffset
        pointsByFrame[frame] = framePoint

        currentBlockHeight = currentBlockHeight + frame:GetHeight()
        yOffset = yOffset - frame:GetHeight()
    end

    local framesToMove = newtable()

    for _, frame in ipairs(frames) do
        local to = pointsByFrame[frame]
        local point, relativeTo, relativePoint, xOffset, yOffset = frame:GetPoint()
        local xOffsetRounded = math.floor((xOffset or 0) * mult + 0.5) / mult
        local yOffsetRounded = math.floor((yOffset or 0) * mult + 0.5) / mult
        local toXOffsetRounded = math.floor((to.XOffset or 0) * mult + 0.5) / mult
        local toYOffsetRounded = math.floor((to.YOffset or 0) * mult + 0.5) / mult

        local different =
            point ~= to.Point or
            relativeTo ~= to.RelativeTo or
            relativePoint ~= to.RelativePoint or
            xOffsetRounded ~= toXOffsetRounded or
            yOffsetRounded ~= toYOffsetRounded

        if different then
            framesToMove[#framesToMove + 1] = frame
            frame:ClearAllPoints()
        end
    end

    -- now move them
    for _, frame in ipairs(framesToMove) do
        local to = pointsByFrame[frame]
        -- since 10.2.7 this broke where to.RelativeTo must be a protected frame
        -- thankfully we can use a magic string to default it to the parent even if it's not protected
        local newRelativeTo = to.RelativeTo

        if not newRelativeTo then
            newRelativeTo = "$parent"
        else
            local isProtected, explicitly = false, false

            if type(newRelativeTo) == "table" and newRelativeTo.IsProtected then
                isProtected, explicitly = newRelativeTo:IsProtected()
            end

            if not isProtected or not explicitly then
                newRelativeTo = "$parent"
            end
        end

        frame:SetPoint(to.Point, newRelativeTo, to.RelativePoint, to.XOffset, to.YOffset)
    end

    return #framesToMove > 0
]]

-- determines the offset to use for the ungrouped portion of the raid frames.
secureMethods["UngroupedOffset"] = [[
    local run = control or self
    local containerVariable, spacingVariable = ...
    local container = _G[containerVariable]
    local spacing = _G[spacingVariable]

    if not run:RunAttribute("ExtractGroups", containerVariable, "OffsetGroups") then
        return 0, 0
    end

    local lastGroup = nil

    for i = #OffsetGroups, 1, -1 do
        local group = OffsetGroups[i]

        if group:IsVisible() then
            lastGroup = group
            break
        end
    end

    if not lastGroup then
        OffsetGroups = nil
        return 0, 0
    end

    OffsetGroupChildren = newtable()

    lastGroup:GetChildList(OffsetGroupChildren)

    if not run:RunAttribute("ExtractUnitFrames", "OffsetGroupChildren", "OffsetGroupFrames", container.VisibleOnly) then
        OffsetGroups = nil
        OffsetGroupFrames = nil
        OffsetGroupChildren = nil
        return 0, 0
    end

    local horizontal = container.IsHorizontalLayout

    if not spacing then
        spacing = newtable()
        spacing.Horizontal = 0
        spacing.Vertical = 0
    end

    local x, y = 0, 0
    local left, bottom, width, height = container.Frame:GetRect()

    if horizontal then
        run:RunAttribute("Sort", "OffsetGroupFrames", "CompareFrameBottomLeft")

        local bottomLeftFrame = OffsetGroupFrames[1]
        local bottomFrameLeft, bottomFrameBottom, _, _ = bottomLeftFrame:GetRect()

        x = -(left - bottomFrameLeft)
        y = -((bottom + height) - bottomFrameBottom + spacing.Vertical)
    else
        run:RunAttribute("Sort", "OffsetGroupFrames", "CompareFrameTopRight")

        local topRightFrame = OffsetGroupFrames[1]
        local topFrameLeft, topFrameBottom, topFrameWidth, topFrameHeight = topRightFrame:GetRect()

        x = -(left - (topFrameLeft + topFrameWidth) - spacing.Horizontal)
        y = -((bottom + height) - (topFrameBottom + topFrameHeight))
    end

    OffsetGroupChildren = nil
    OffsetGroupFrames = nil
    OffsetGroups = nil

    return x, y
]]

secureMethods["TrySortContainerGroups"] = [[
    local run = control or self
    local containerVariable, providerVariable = ...
    local container = _G[containerVariable]
    local provider = _G[providerVariable]

    local sorted = false
    Groups = nil

    if not run:RunAttribute("ExtractGroups", containerVariable, "Groups") then
        return false
    end

    for _, group in ipairs(Groups) do
        GroupContainer = newtable()
        -- just copy over all the attributes to make code simpler
        run:RunAttribute("CopyTable", containerVariable, "GroupContainer")

        -- now re-write over the top
        GroupContainer.Frame = group
        GroupContainer.Offset = newtable()

        if container.GroupOffset then
            GroupContainer.Offset.X = container.GroupOffset.X
            GroupContainer.Offset.Y = container.GroupOffset.Y
        end

        sorted = run:RunAttribute("TrySortContainer", "GroupContainer", providerVariable) or sorted

        GroupContainer = nil
    end

    if not container.SupportsSpacing then
        Groups = nil
        return sorted
    end

    local horizontalSpacing, verticalSpacing = run:RunAttribute("SpacingForContainer", container.Type)

    if not horizontalSpacing and not verticalSpacing or (horizontalSpacing == 0 and verticalSpacing == 0) then
        Groups = nil
        return sorted
    end

    GroupSpacing = newtable()
    GroupSpacing.Horizontal = horizontalSpacing or 0
    GroupSpacing.Vertical = verticalSpacing or 0

    sorted = run:RunAttribute("SpaceGroups", "Groups", "GroupSpacing") or sorted

    local offsetX, offsetY = run:RunAttribute("UngroupedOffset", containerVariable, "GroupSpacing")

    UngroupedChildren = newtable()
    UngroupedFrames = newtable()

    -- import into the global table for filtering
    container.Frame:GetChildList(UngroupedChildren)

    if not run:RunAttribute("ExtractUnitFrames", "UngroupedChildren", "UngroupedFrames", container.VisibleOnly) then
        UngroupedChildren = nil
        UngroupedFrames = nil
        GroupSpacing = nil
        return false
    end

    UngroupedContainer = newtable()

    -- just copy over all the attributes to make code simpler
    run:RunAttribute("CopyTable", containerVariable, "UngroupedContainer")

    -- now re-write over the top
    UngroupedContainer.Offset = newtable()
    UngroupedContainer.Offset.X = offsetX
    UngroupedContainer.Offset.Y = offsetY

    -- use the block height of a member frame as pet frames are smaller
    local blockHeight = UngroupedFrames[1]:GetHeight() * 2

    sorted = run:RunAttribute("HardArrange", "UngroupedFrames", "UngroupedContainer", "GroupSpacing", blockHeight)

    UngroupedContainer = nil
    UngroupedChildren = nil
    UngroupedFrames = nil
    GroupSpacing = nil
    Groups = nil

    return sorted
]]

-- attempts to sort the frames within the container
secureMethods["TrySortContainer"] = [=[
    local run = control or self
    local friendlyEnabled = self:GetAttribute("FriendlySortEnabled")
    local enemyEnabled = self:GetAttribute("EnemySortEnabled")
    local friendlyPlayerMode = self:GetAttribute("FriendlyPlayerSortMode")
    local friendlyGroupMode = self:GetAttribute("FriendlyGroupSortMode")
    local enemyGroupMode = self:GetAttribute("EnemyGroupSortMode")
    local containerVariable, providerVariable = ...
    local container = _G[containerVariable]
    local provider = _G[providerVariable]
    local units = nil
    local sortMode = nil
    local playerSortMode = nil

    if container.LayoutType == LayoutType.NameList then
        -- there's no way to get a unit's name in the restricted environment
        -- so we can't do anything
        return false
    end

    if container.Type == ContainerType.Party or container.Type == ContainerType.Raid then
        units = FriendlyUnits
        sortMode = friendlyGroupMode
        playerSortMode = friendlyPlayerMode
    elseif container.Type == ContainerType.EnemyArena then
        units = EnemyUnits
        sortMode = enemyGroupMode
    else
        run:CallMethod("Log", format("Invalid container type: %s", container.Type or "nil"), LogLevel.Error)
        return false
    end

    Children = newtable()
    Frames = newtable()

    if container.Frames then
        Frames = container.Frames
    else
        -- import into the global table for filtering
        container.Frame:GetChildList(Children)

        if not run:RunAttribute("ExtractUnitFrames", "Children", "Frames", container.VisibleOnly) then
            Children, Frames = nil, nil
            return false
        end
    end

    if #Frames <= 1 then
        -- nothing to do
        Children, Frames = nil, nil
        return true
    end

    Units = units or newtable()

    -- sort the frames to the desired locations
    SortedFrames = nil
    local couldSort = run:RunAttribute("SortFramesByUnits", "Frames", "Units", "SortedFrames")
    local warnedAlready = self:GetAttribute("WarnedAboutUnsorted")

    if not couldSort then
        run:RunAttribute("Sort", "Frames", "CompareFrameGroup", playerSortMode)
        SortedFrames = Frames

        if sortMode ~= "Group" and not warnedAlready then
            run:CallMethod("Log",
                "Sorry, we were unable to sort your frames accurately during combat by '" .. (sortMode or "nil").. "' and there is nothing we can do about it due to Blizzard API restrictions. " ..
                "We've temporarily sorted by group until combat drops.", LogLevel.Critical)

            self:SetAttribute("WarnedAboutUnsorted", true)
        end
    end

    local sorted = false

    if container.Spacing then
        Spacing = newtable()
        Spacing.Horizontal = container.SpacingHorizontal
        Spacing.Vertical = container.SpacingVertical
    elseif container.SupportsSpacing then
        local horizontalSpacing, verticalSpacing = run:RunAttribute("SpacingForContainer", container.Type)

        if (horizontalSpacing and horizontalSpacing ~= 0) or (verticalSpacing and verticalSpacing ~= 0) then
            Spacing = newtable()
            Spacing.Horizontal = horizontalSpacing
            Spacing.Vertical = verticalSpacing
        end
    end

    if container.LayoutType == LayoutType.Hard then
        sorted = run:RunAttribute("HardArrange", "SortedFrames", containerVariable, Spacing and "Spacing")
    elseif container.LayoutType == LayoutType.Soft then
        sorted = run:RunAttribute("SoftArrange", "SortedFrames", Spacing and "Spacing")
    end

    SortedFrames = nil
    Children = nil
    Frames = nil
    Spacing = nil

    return sorted
]=]

-- top level perform sort routine
secureMethods["TrySort"] = [[
    local run = control or self

    if not run:RunAttribute("InCombat") then return false end

    local friendlyEnabled = self:GetAttribute("FriendlySortEnabled")
    local enemyEnabled = self:GetAttribute("EnemySortEnabled")

    if not friendlyEnabled and not enemyEnabled then return false end

    local loadedUnits = self:GetAttribute("LoadedUnits")
    if not loadedUnits then
        run:RunAttribute("LoadUnits")
        self:SetAttribute("LoadedUnits", true)
    end

    local toSort = newtable()

    for _, provider in pairs(Providers) do
        local providerEnabled = self:GetAttribute("Provider" .. provider.Name .. "Enabled")

        if providerEnabled then
            for _, container in ipairs(provider.Containers) do
                if not container.Frame:IsProtected() then
                    run:CallMethod("Log", format("Container for %s must be protected.", provider.Name), LogLevel.Error)
                elseif container.Frame:IsVisible() then
                    local shouldAdd = false

                    if container.EnableInBattlegrounds ~= nil and not container.EnableInBattlegrounds and self:GetAttribute("IsBattleground") then
                        shouldAdd = false
                    elseif (container.Type == ContainerType.Party or container.Type == ContainerType.Raid) and friendlyEnabled then
                        shouldAdd = true
                    elseif container.Type == ContainerType.EnemyArena and enemyEnabled then
                        shouldAdd = true
                    end

                    if shouldAdd then
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

        run:CallMethod("StartTimer", "TrySort")

        local providerSorted = false

        if Container.IsGrouped then
            providerSorted = run:RunAttribute("TrySortContainerGroups", "Container", "Provider") or providerSorted
        else
            providerSorted = run:RunAttribute("TrySortContainer", "Container", "Provider") or providerSorted
        end

        local message = format("In-combat sort for %s took %sms, result: %s.", Provider.Name, "%f", providerSorted and "sorted" or "not sorted")
        run:CallMethod("StopTimer", "TrySort", message)
        Provider = nil
        Container = nil

        sorted = sorted or providerSorted
    end

    if sorted then
        run:CallMethod("NotifySorted")
    end

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
        container.SpacingVertical = self:GetAttribute(prefix .. "SpacingVertical")
        container.SpacingHorizontal = self:GetAttribute(prefix .. "SpacingHorizontal")
        container.VisibleOnly = self:GetAttribute(prefix .. "VisibleOnly")
        container.AnchorPoint = self:GetAttribute(prefix .. "AnchorPoint")
        container.Anchor = self:GetAttribute(prefix .. "Anchor")
        container.IsGrouped = self:GetAttribute(prefix .. "IsGrouped")
        container.IsHorizontalLayout = self:GetAttribute(prefix .. "IsHorizontalLayout")
        container.FramesPerLine = self:GetAttribute(prefix .. "FramesPerLine")
        container.EnableInBattlegrounds = self:GetAttribute(prefix .. "EnableInBattlegrounds")

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

        local framesCount = self:GetAttribute(prefix .. "FramesCount")

        if framesCount then
            local frames = newtable()

            for j = 1, framesCount do
                local frame = self:GetFrameRef(prefix .. "Frame" .. j)
                frames[#frames + 1] = frame
            end

            container.Frames = frames
        end

        provider.Containers[#provider.Containers + 1] = container
    end
]]

secureMethods["LoadUnits"] = [[
    FriendlyUnits = newtable()
    EnemyUnits = newtable()

    local friendlyUnitsCount = self:GetAttribute("FriendlyUnitsCount") or 0
    local enemyUnitsCount = self:GetAttribute("EnemyUnitsCount") or 0

    for i = 1, friendlyUnitsCount do
        local unit = self:GetAttribute("FriendlyUnit" .. i)
        FriendlyUnits[#FriendlyUnits + 1] = unit
    end

    for i = 1, enemyUnitsCount do
        local unit = self:GetAttribute("EnemyUnit" .. i)
        EnemyUnits[#EnemyUnits + 1] = unit
    end
]]

secureMethods["Init"] = [[
    Providers = newtable()

    -- Must match Comparer.DecimalSanity for consistency
    DecimalSanity = 0

    -- must match the enums specified in Frame.lua
    ContainerType = newtable()
    ContainerType.Party = 1
    ContainerType.Raid = 2
    ContainerType.EnemyArena = 3

    LayoutType = newtable()
    LayoutType.Soft = 1
    LayoutType.Hard = 2
    LayoutType.NameList = 3

    LogLevel = newtable()
    LogLevel.Debug = 1
    LogLevel.Notify = 2
    LogLevel.Warning = 3
    LogLevel.Error = 4
    LogLevel.Critical = 5
    LogLevel.Bug = 6
]]

local function ResetWarnings()
	assert(manager)

	manager:SetAttributeNoHandler("WarnedAboutUnsorted", false)
end

local function LoadUnits()
	assert(manager)

	local friendlyUnits = fsSortedUnits:FriendlyUnits()
	local enemyUnits = fsSortedUnits:EnemyUnits()

	for i, unit in ipairs(friendlyUnits) do
		manager:SetAttributeNoHandler("FriendlyUnit" .. i, unit)
	end

	for i, unit in ipairs(enemyUnits) do
		manager:SetAttributeNoHandler("EnemyUnit" .. i, unit)
	end

	manager:SetAttributeNoHandler("FriendlyUnitsCount", #friendlyUnits)
	manager:SetAttributeNoHandler("EnemyUnitsCount", #enemyUnits)

	-- flag that the units need to be reloaded
	manager:SetAttributeNoHandler("LoadedUnits", false)
end

local function LoadSortMode()
	assert(manager)

	local friendlyEnabled, friendlyPlayerMode, friendlyGroupMode = fsCompare:FriendlySortMode()
	local enemyEnabled, enemyGroupMode = fsCompare:EnemySortMode()

	manager:SetAttributeNoHandler("FriendlySortEnabled", friendlyEnabled)
	manager:SetAttributeNoHandler("FriendlyPlayerSortMode", friendlyPlayerMode)
	manager:SetAttributeNoHandler("FriendlyGroupSortMode", friendlyGroupMode)

	manager:SetAttributeNoHandler("EnemySortEnabled", enemyEnabled)
	manager:SetAttributeNoHandler("EnemyGroupSortMode", enemyGroupMode)

	for _, provider in ipairs(fsProviders.All) do
		manager:SetAttributeNoHandler("Provider" .. provider:Name() .. "Enabled", provider:Enabled())
	end
end

local function LoadSpacing()
	assert(manager)

	for type, value in pairs(addon.DB.Options.Spacing) do
		manager:SetAttributeNoHandler(type .. "SpacingHorizontal", value.Horizontal)
		manager:SetAttributeNoHandler(type .. "SpacingVertical", value.Vertical)
	end
end

---@param provider FrameProvider
local function LoadProvider(provider)
	assert(manager)

	local containers = fsEnumerable
		:From(provider:Containers())
		:Where(function(c)
			return c.InCombatSortingRequired
		end)
		:ToTable()

	if #containers == 0 then
		return
	end

	manager:SetAttributeNoHandler("ProviderName", provider:Name())

	for i, container in ipairs(containers) do
		local offset = container.FramesOffset and container:FramesOffset()
		local groupOffset = container.GroupFramesOffset and container:GroupFramesOffset()
		local containerPrefix = provider:Name() .. "Container" .. i

		manager:SetFrameRef(containerPrefix .. "Frame", container.Frame)
		manager:SetAttributeNoHandler(containerPrefix .. "Type", container.Type)
		manager:SetAttributeNoHandler(containerPrefix .. "LayoutType", container.LayoutType)
		manager:SetAttributeNoHandler(
			containerPrefix .. "IsHorizontalLayout",
			container.IsHorizontalLayout and container:IsHorizontalLayout()
		)
		manager:SetAttributeNoHandler(
			containerPrefix .. "FramesPerLine",
			container.FramesPerLine and container:FramesPerLine()
		)
		manager:SetAttributeNoHandler(containerPrefix .. "VisibleOnly", container.VisibleOnly or false)
		manager:SetAttributeNoHandler(containerPrefix .. "AnchorPoint", container.AnchorPoint)
		manager:SetAttributeNoHandler(containerPrefix .. "Anchor", container.Anchor)
		manager:SetAttributeNoHandler(containerPrefix .. "SupportsSpacing", container.SupportsSpacing)
		manager:SetAttributeNoHandler(containerPrefix .. "IsGrouped", container.IsGrouped and container:IsGrouped())
		manager:SetAttributeNoHandler(containerPrefix .. "OffsetX", offset and offset.X)
		manager:SetAttributeNoHandler(containerPrefix .. "OffsetY", offset and offset.Y)
		manager:SetAttributeNoHandler(containerPrefix .. "GroupOffsetX", groupOffset and groupOffset.X)
		manager:SetAttributeNoHandler(containerPrefix .. "GroupOffsetY", groupOffset and groupOffset.Y)
		manager:SetAttributeNoHandler(containerPrefix .. "EnableInBattlegrounds", container.EnableInBattlegrounds)

		local spacing = container.Spacing and container:Spacing()
		manager:SetAttributeNoHandler(containerPrefix .. "SpacingHorizontal", spacing and spacing.Horizontal)
		manager:SetAttributeNoHandler(containerPrefix .. "SpacingVertical", spacing and spacing.Vertical)

		if container.Frames then
			local frames = container.Frames()
			manager:SetAttributeNoHandler(containerPrefix .. "FramesCount", #frames)

			for j, frame in ipairs(frames) do
				manager:SetFrameRef(containerPrefix .. "Frame" .. j, frame)
			end
		end
	end

	manager:SetAttributeNoHandler(provider:Name() .. "ContainersCount", #containers)
	manager:Execute([[
        local run = control or self
        run:RunAttribute("LoadProvider")
    ]])

	for _, item in ipairs(containers) do
		-- flag as imported
		-- SetAttributeNoHandler may not exist on frames we didn't create
		-- doesn't exist in wow 3.3.5
		item.Frame:SetAttribute("FrameSortLoaded", true)
	end
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

-- TODO: I don't think this should make a difference anymore, but re-adding it for testing.
local function ResubscribeEvents()
	-- we want our sorting code to run after blizzard and other frame addons refresh their frames
	-- i.e., we want to handle GROUP_ROSTER_UPDATE/UNT_PET after frame addons have performed their update handling
	-- this is easily achieved in the insecure environment by using hooks, however in the restricted environment we have no such luxury
	-- fortunately it seems blizzard invoke event handlers roughly in the order that they were registered
	-- so if we register our events later, our code will run later
	-- of course it's not good to rely on this and we should generally treat event ordering as undefined
	-- perhaps in a future patch this implementation detail could change and our code will break
	-- however until a better solution can be found, this is our only hope

	assert(memberHeader ~= nil)
	assert(petHeader ~= nil)

	memberHeader:UnregisterEvent(events.GROUP_ROSTER_UPDATE)
	memberHeader:UnregisterEvent(events.UNIT_NAME_UPDATE)

	memberHeader:RegisterEvent(events.GROUP_ROSTER_UPDATE)
	memberHeader:RegisterEvent(events.UNIT_NAME_UPDATE)

	petHeader:UnregisterEvent(events.GROUP_ROSTER_UPDATE)
	petHeader:UnregisterEvent(events.UNIT_PET)
	petHeader:UnregisterEvent(events.UNIT_NAME_UPDATE)

	petHeader:RegisterEvent(events.GROUP_ROSTER_UPDATE)
	petHeader:RegisterEvent(events.UNIT_PET)
	petHeader:RegisterEvent(events.UNIT_NAME_UPDATE)
end

---@param container FrameContainer
local function WatchChildrenVisibility(container)
	assert(manager)

	local children = fsFrame:ExtractUnitFrames(container.Frame, false, false, false)

	for _, child in ipairs(children) do
		if not child:GetAttribute("framesort-watching-visibility") then
			wow.SecureHandlerSetFrameRef(child, "Manager", manager)

			-- not sure why, but postBody scripts don't work for OnShow/OnHide
			wow.SecureHandlerWrapScript(
				child,
				"OnShow",
				manager,
				[[
                    local manager = self:GetFrameRef("Manager")
                    manager:SetAttribute("state-framesort-run", "ignore")
                ]]
			)
			wow.SecureHandlerWrapScript(
				child,
				"OnHide",
				manager,
				[[
                    local manager = self:GetFrameRef("Manager")
                    manager:SetAttribute("state-framesort-run", "ignore")
                ]]
			)

			child:SetAttribute("framesort-watching-visibility", true)
		end
	end
end

local function WatchVisibility()
	local containersToSubscribe = fsEnumerable
		:From(fsProviders.All)
		:Map(function(provider)
			return provider:Containers()
		end)
		:Flatten()
		:Where(function(container)
			return container.SubscribeToVisibility
		end)
		:ToTable()

	for _, container in ipairs(containersToSubscribe) do
		WatchChildrenVisibility(container)
	end
end

local function LoadInstanceType()
	assert(manager)

	manager:SetAttributeNoHandler("IsBattleground", wowEx.IsInstanceBattleground())
end

local function OnCombatStarting()
	LoadSortMode()
	LoadUnits()
	ResubscribeEvents()
	WatchVisibility()
	LoadInstanceType()
	ResetWarnings()
end

local function OnProviderContainersChanged(provider)
	fsScheduler:RunWhenCombatEnds(function()
		LoadProvider(provider)
	end, "LoadProvider" .. provider:Name())
end

local function OnConfigChanged()
	fsScheduler:RunWhenCombatEnds(function()
		LoadSpacing()
	end, "SecureSortConfigChanged")
end

local function ConfigureHeader(header)
	InjectSecureHelpers(header)

	function header:UnitButtonCreated(index)
		local children = { header:GetChildren() }
		local frame = children[index]

		if not frame then
			fsLog:Bug("Failed to find unit button %s", index)
			return
		end

		fsScheduler:RunWhenCombatEnds(function()
			-- the refreshUnitChange script doesn't capture when the unit is changed to nil
			-- which can happen when someone leaves the group, or a pet ceases to exist
			-- so we're really only interested in unit changing to nil here
			frame:SetAttribute(
				"_onattributechanged",
				[[
                local manager = self:GetAttribute("Manager")
                manager:SetAttribute("state-framesort-run", "ignore")
                ]]
			)

			frame:SetAttribute("HaveSetAttributeHandler", true)
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
	header:SetAttribute(
		"initialConfigFunction",
		[=[
        UnitButtonsCount = (UnitButtonsCount or 0) + 1

        -- self = the newly created unit button
        self:SetWidth(0)
        self:SetHeight(0)
        self:SetID(UnitButtonsCount)
        self:SetAttribute("Manager", Manager)
        self:SetAttribute("Header", Header)

        RefreshUnitChange = [[
            -- Blizzard iterate over all the unit buttons and change their unit token so this snippet is called a lot
            -- we want to avoid spamming multiple sort attempts and only perform after all the buttons have been updated
            -- we can do this by changing our attribute to some temporary value which blizzard will change back when it re-evaluates state attributes
            local manager = self:GetAttribute("Manager")
            manager:SetAttribute("state-framesort-run", "ignore")
        ]]

        self:SetAttribute("refreshUnitChange", RefreshUnitChange)

        if Header.CallMethod then
            Header:CallMethod("UnitButtonCreated", UnitButtonsCount)
        else
            local run = control or self
            run:RunFor(Header, [[
                control:CallMethod("UnitButtonCreated")
            ]])
        end
    ]=]
	)

	header:SetFrameRef("Manager", manager)

	header:Execute([[
        Header = self
        Manager = self:GetFrameRef("Manager")
    ]])

	-- must be shown for it to work
	header:SetPoint("TOPLEFT", wow.UIParent, "TOPLEFT")
	header:Show()
end

function M:RunOverheadTest()
	if wow.InCombatLockdown() or not manager then
		return
	end

	manager:Execute([[
        local run = control or self

        run:RunAttribute("OverheadTest")
    ]])
end

function M:Init()
	manager = wow.CreateFrame("Frame", nil, wow.UIParent, "SecureHandlerStateTemplate")

	InjectSecureHelpers(manager)

	function manager:StartTimer(name)
		if not name then
			fsLog:Bug("StartTimer called without a name.")
			return
		end

		manager[name .. "TimeStart"] = wow.GetTimePreciseSec()
	end

	function manager:StopTimer(name, message)
		local start = manager[name .. "TimeStart"]

		if not start then
			fsLog:Bug("StopTimer called without corresponding StartTimer for %s.", name)
			return
		end

		local stop = wow.GetTimePreciseSec()
		local ms = (stop - start) * 1000

		fsLog:Debug(message, ms)

		manager[name .. "TimeStart"] = nil
	end

	function manager:NotifySorted()
		fsSorting:NotifySorted()
	end

	function manager:Log(msg, level)
		fsLog:Log(msg, level)
	end

	for name, snippet in pairs(secureMethods) do
		manager:SetAttributeNoHandler(name, snippet)
	end

	manager:Execute([[
        -- wotlk 3.3.5 doesn't have the control methods on self
        -- those methods exist on the "control" global
        local run = control or self

        run:RunAttribute("Init")
    ]])

	manager:SetAttribute(
		"_onstate-framesort-run",
		[[
        if newstate == "ignore" then return end

        local run = control or self
        run:RunAttribute("TrySort")
        ]]
	)

	-- https://www.wowinterface.com/forums/showthread.php?t=58697
	-- this attribute driver is used for delaying the sorting function
	-- the actual conditional value doesn't really matter
	-- we'll change the value of this to "ignore" from group header events
	-- and then blizzard will later detect the value has changed from "pet" or "nopet" and invoke our attribute changed handler
	wow.RegisterAttributeDriver(manager, "state-framesort-run", "[pet] pet; nopet;")

	memberHeader = wow.CreateFrame("Frame", nil, wow.UIParent, "SecureGroupHeaderTemplate")
	petHeader = wow.CreateFrame("Frame", nil, wow.UIParent, "SecureGroupPetHeaderTemplate")

	headers = { memberHeader, petHeader }

	for _, header in ipairs(headers) do
		ConfigureHeader(header)
	end

	for _, provider in ipairs(fsProviders.All) do
		provider:RegisterContainersChangedCallback(OnProviderContainersChanged)
	end

	-- wait until the providers have created their frames
	fsScheduler:RunWhenEnteringWorldOnce(function()
		for _, provider in ipairs(fsProviders:Enabled()) do
			LoadProvider(provider)
		end
	end)

	LoadSortMode()
	LoadSpacing()

	fsConfig:RegisterConfigurationChangedCallback(OnConfigChanged)

	local combatStartingFrame = wow.CreateFrame("Frame", nil, wow.UIParent)
	combatStartingFrame:HookScript("OnEvent", OnCombatStarting)
	combatStartingFrame:RegisterEvent(events.PLAYER_REGEN_DISABLED)
end
