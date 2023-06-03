local _, addon = ...
local fsSort = addon.Sorting
local fsFrame = addon.Frame
local fsCompare = addon.Compare
local fsPoint = addon.Point
local fsMath = addon.Math
local fsEnumerable = addon.Enumerable
local previousPartySpacing = nil
local previousRaidSpacing = nil
local M = {}
addon.Spacing = M

--- Returns a lookup table of frames to their row and column positions.
local function GridLayout(frames)
    table.sort(frames, function(x, y) return fsCompare:CompareTopLeftFuzzy(x, y) end)

    local byFrame = {}
    local byPos = {}
    local row = 1
    local col = 1
    local maxRow = 1
    local maxCol = 1

    -- build a view of the row/col layout
    for i, frame in ipairs(frames) do
        local previous = i > 1 and frames[i - 1] or nil

        if previous then
            local groupFuzzyLeft = fsMath:Round(frame:GetLeft() or 0)
            local groupFuzzyTop = fsMath:Round(frame:GetTop() or 0)
            local previousFuzzyLeft = fsMath:Round(previous:GetLeft() or 0)
            local previousFuzzyTop = fsMath:Round(previous:GetTop() or 0)
            local isNewRow = groupFuzzyLeft < previousFuzzyLeft or groupFuzzyTop < previousFuzzyTop

            if isNewRow then
                row = row + 1
                maxRow = row
                col = 1
            else
                col = col + 1

                if col > maxCol then maxCol = col end
            end
        end

        byFrame[frame] = {
            Row = row,
            Column = col
        }
        byPos[row] = byPos[row] or {}
        byPos[row][col] = frame
    end

    return byFrame, byPos, maxRow, maxCol
end

local function GetSettings(isRaid)
    local flat = nil
    local horizontal = nil
    local showPets = CompactRaidFrameManager_GetSetting("DisplayPets")
    local spacing = isRaid and addon.Options.Appearance.Raid.Spacing or addon.Options.Appearance.Party.Spacing

    if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
        if isRaid then
            local displayType = EditModeManagerFrame:GetSettingValue(
                Enum.EditModeSystem.UnitFrame,
                Enum.EditModeUnitFrameSystemIndices.Raid,
                Enum.EditModeUnitFrameSetting.RaidGroupDisplayType)

            flat =
                displayType == Enum.RaidGroupDisplayType.CombineGroupsVertical or
                displayType == Enum.RaidGroupDisplayType.CombineGroupsHorizontal

            horizontal =
                displayType == Enum.RaidGroupDisplayType.SeparateGroupsHorizontal or
                displayType == Enum.RaidGroupDisplayType.CombineGroupsHorizontal
        else
            flat = true

            horizontal = EditModeManagerFrame:GetSettingValueBool(
                Enum.EditModeSystem.UnitFrame,
                Enum.EditModeUnitFrameSystemIndices.Party,
                Enum.EditModeUnitFrameSetting.UseHorizontalGroups)
        end
    else
        flat = not CompactRaidFrameManager_GetSetting("KeepGroupsTogether")
        if flat then
            -- classic doesn't have the option for horizontal flat
            horizontal = false
        else
            horizontal = CompactRaidFrameManager_GetSetting("HorizontalGroups")
        end
        spacing = addon.Options.Appearance.Raid.Spacing
    end

    return flat, horizontal, showPets, spacing
end

---Applies spacing to frames that are organised in 'flat' mode.
---Flat mode is where frames are all placed relative to 1 point, i.e. the parent container.
local function FlatMembers(frames, spacing)
    local _, frameByPos = GridLayout(frames)

    local row = 1
    while frameByPos[row] do
        local xDelta = 0
        local yDelta = 0

        if row > 1 then
            local first = frameByPos[row][1]
            local above = frameByPos[row - 1][1]

            yDelta = (above:GetBottom() or 0) - (first:GetTop() or 0) - spacing.Vertical
        end

        local col = 1
        while frameByPos[row][col] do
            local frame = frameByPos[row][col]

            if col > 1 then
                local left = frameByPos[row][col - 1]
                xDelta = spacing.Horizontal - ((frame:GetLeft() or 0) - (left:GetRight() or 0))
            end

            if xDelta ~= 0 or yDelta ~= 0 then
                frame:AdjustPointsOffset(xDelta, yDelta)
            end

            col = col + 1
        end

        row = row + 1
    end
end

local function Pets(members, spacing, horizontal)
    local _, pets = fsFrame:GetRaidFrames()

    if #pets == 0 or #members == 0 then return end

    table.sort(pets, function(x, y) return fsCompare:CompareTopLeftFuzzy(x, y) end)
    table.sort(members, function(x, y) return fsCompare:CompareTopLeftFuzzy(x, y) end)

    local _, byPos, maxRow, maxCol = GridLayout(members)
    local firstPet = pets[1]
    local firstPetPoint = fsPoint:GetPointEx(firstPet)
    local parent = CompactRaidFrameContainer
    local placeHorizontal = horizontal

    if horizontal and maxRow > 1 then
        placeHorizontal = false
    elseif not horizontal and maxCol > 1 then
        placeHorizontal = true
    end

    if placeHorizontal then
        local firstRow = byPos[1]
        local topRight = firstRow[#firstRow]
        local top, left = fsPoint:RelativeTopLeft(topRight, parent)
        local xDelta = left - (firstPetPoint.offsetX - topRight:GetWidth() - spacing.Horizontal)
        local yDelta = top - firstPetPoint.offsetY

        if xDelta ~= 0 or yDelta ~= 0 then
            firstPet:AdjustPointsOffset(xDelta, yDelta)
        end
    else
        local bottomLeft = byPos[maxRow][1]
        local top, left = fsPoint:RelativeTopLeft(bottomLeft, parent)
        local xDelta = left - firstPetPoint.offsetX
        local yDelta = top - firstPetPoint.offsetY - bottomLeft:GetHeight() - spacing.Vertical

        if xDelta ~= 0 or yDelta ~= 0 then
            firstPet:AdjustPointsOffset(xDelta, yDelta)
        end
    end

    local petsPerRaidFrame = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE and 3 or 2

    -- move all the remaining pets
    for i = 2, #pets do
        local pet = pets[i]
        local petPoint = fsPoint:GetPointEx(pet)
        local previous = pets[i - 1]
        -- in classic 2 pet frames fit into 1 member raid frame
        -- so for the 2nd frame just anchor it to the first
        -- in retail 3 pet frames almost fit
        local addSpacing = i % petsPerRaidFrame == fsPoint
        local xDelta = 0
        local yDelta = 0

        if addSpacing then
            if horizontal then
                local cellBefore = pets[i - petsPerRaidFrame]
                local top, left = fsPoint:RelativeTopLeft(cellBefore, parent)
                xDelta = (left - petPoint.offsetX) + cellBefore:GetWidth() + spacing.Horizontal
                yDelta = top - petPoint.offsetY
            else
                local top, left = fsPoint:RelativeTopLeft(previous, parent)
                xDelta = left - petPoint.offsetX
                yDelta = top - petPoint.offsetY - previous:GetHeight() - spacing.Vertical
            end
        else
            local top, left = fsPoint:RelativeTopLeft(previous, parent)
            xDelta = left - petPoint.offsetX
            yDelta = top - petPoint.offsetY - previous:GetHeight()
        end

        if xDelta ~= 0 or yDelta ~= 0 then
            pet:AdjustPointsOffset(xDelta, yDelta)
        end
    end
end

local function GroupedMembers(frames, spacing, horizontal)
    if #frames == 0 then return end

    -- why all this complexity instead of just a simple sequence of SetPoint() calls?
    -- it's because SetPoint() can't be called in combat whereas AdjustPointsOffset() can
    -- SetPoint() is just completely disallowed (by unsecure code) in combat, even if only changing x/y points
    -- being able to run this in combat has the benefit that if blizzard reset/redraw frames mid-combat, we can reapply our sorting/spacing!
    local root = fsFrame:ToFrameChain(frames)

    -- ensure it's ordered
    local ordered = fsEnumerable
        :From(frames)
        :OrderBy(function(x, y) return fsCompare:CompareTopLeftFuzzy(x, y) end)
        :ToTable()

    -- calculate the desired positions (with spacing added)
    local positions = {}
    local currentSpacing = 0

    for i, frame in ipairs(ordered) do
        if i == 1 then
            positions[i] = {
                Top = frame:GetTop() or 0,
                Left = frame:GetLeft() or 0
            }
        else
            local previous = ordered[i - 1]

            if horizontal then
                local spacingToAdd = (i - 1) * spacing.Horizontal
                positions[i] = {
                    Top = (previous:GetTop() or 0),
                    Left = ((previous:GetRight() or 0) + currentSpacing) + spacingToAdd,
                }

                currentSpacing = currentSpacing + (previous:GetRight() - frame:GetLeft())
            else
                local spacingToAdd = (i - 1) * spacing.Vertical
                positions[i] = {
                    Top = ((previous:GetBottom() or 0) + currentSpacing) - spacingToAdd,
                    Left = (previous:GetLeft() or 0)
                }

                currentSpacing = currentSpacing + (previous:GetBottom() - frame:GetTop())
            end
        end
    end

    local current = root
    while current do
        local frame = current.Value
        local index = fsEnumerable:From(ordered):IndexOf(frame)
        local to = positions[index]
        local xDelta = to.Left - (frame:GetLeft() or 0)
        local yDelta = to.Top - (frame:GetTop() or 0)

        if xDelta ~= 0 or yDelta ~= 0 then
            frame:AdjustPointsOffset(xDelta, yDelta)
        end

        current = current.Next
    end
end

---Applies spacing to frames that are organised in 'grouped' mode.
---Grouped mode is where frames are placed relative to the frame before it within one or more groups,
---e.g.: group1: frame3 is placed relative to frame2 which is placed relative to frame 1.
---e.g.: group2: frame5 is placed relative to frame4.
local function Groups(groups, spacing, horizontal)
    local posByGroup, groupByPos = GridLayout(groups)
    local membersByGroup = fsEnumerable
        :From(groups)
        :ToLookup(
            function(group) return group end,
            function(group)
                local members = fsFrame:GetRaidFrameGroupMembers(group)
                table.sort(members, function(x, y) return fsCompare:CompareTopLeftFuzzy(x, y) end)
                return members
            end)

    --- apply spacing to the member frames
    for _, group in ipairs(groups) do
        local members = membersByGroup[group]
        GroupedMembers(members, spacing, horizontal)
    end

    -- determine the vertical anchors
    local verticalAnchorsByRow = {}
    for _, group in ipairs(groups) do
        local pos = posByGroup[group]

        if pos.Row > 1 then
            if horizontal then
                -- in horizontal mode, the anchor is simply the group above
                local above = pos.Row > 1 and groupByPos[pos.Row - 1][pos.Column]
                verticalAnchorsByRow[pos.Row] = above
            else
                -- in vertical mode, the anchor is the bottom most member of the groups in the above row
                local previousRow = groupByPos[pos.Row - 1]
                local lastMembers = fsEnumerable
                    :From(previousRow)
                    :Map(function(g)
                        local members = membersByGroup[g]
                        return members[#members]
                    end)
                local bottomMost = lastMembers:Min(function(member) return member:GetBottom() or 0 end)
                verticalAnchorsByRow[pos.Row] = bottomMost
            end
        end
    end

    -- determine the horizontal anchors
    local horizontalAnchorsByColumn = {}
    for _, group in ipairs(groups) do
        local pos = posByGroup[group]

        if pos.Column > 1 then
            if not horizontal then
                -- in vertical mode, the anchor is simply the group to the left
                local left = pos.Column > 1 and groupByPos[pos.Row][pos.Column - 1] or nil
                horizontalAnchorsByColumn[pos.Column] = left
            else
                -- in horizontal mode, the anchor is the left most member of the groups in the left column
                local leftMembers = fsEnumerable
                    :From(groupByPos)
                    :Map(function(g)
                        local members = membersByGroup[g]
                        return members[#members]
                    end)
                local leftMost = leftMembers:Max(function(member) return member:GetRight() or 0 end)
                horizontalAnchorsByColumn[pos.Column] = leftMost
            end
        end
    end

    -- apply spacing between the groups
    for i = 1, #groups do
        local group = groups[i]
        local pos = posByGroup[group]
        local xDelta = 0
        local yDelta = 0

        -- vertical spacing
        if pos.Row > 1 then
            local anchor = verticalAnchorsByRow[pos.Row]

            if anchor then
                yDelta = (anchor:GetBottom() or 0) - (group:GetTop() or 0) - spacing.Vertical
            end
        end

        -- horizontal spacing
        if pos.Column > 1 then
            local anchor = horizontalAnchorsByColumn[pos.Column]

            if anchor then
                xDelta = spacing.Horizontal - ((group:GetLeft() or 0) - (anchor:GetRight() or 0))
            end
        end

        if xDelta ~= 0 or yDelta ~= 0 then
            group:AdjustPointsOffset(xDelta, yDelta)
        end
    end
end

local function ApplyPartyFrameSpacing()
    local frames = fsFrame:GetPartyFrames()
    local _, horizontal, showPets, spacing = GetSettings(false)

    GroupedMembers(frames, spacing, horizontal)

    if showPets then
        Pets(frames, spacing, horizontal)
    end
end

local function ApplyRaidFrameSpacing()
    local flat, horizontal, showPets, spacing = GetSettings(true)
    local members, _ = fsFrame:GetRaidFrames()

    if flat then
        FlatMembers(members, spacing)
    else
        local groups = fsFrame:GetRaidFrameGroups()

        Groups(groups, spacing, horizontal)
    end

    if showPets then
        Pets(members, spacing, horizontal)
    end
end

---Applies spacing to party and raid frames.
function M:ApplySpacing()
    if CompactRaidFrameContainer and not CompactRaidFrameContainer:IsForbidden() and CompactRaidFrameContainer:IsVisible() then
        local _, _, _, spacing = GetSettings(true)
        local zeroSpacing = spacing.Horizontal == 0 and spacing.Vertical == 0
        local previousNonZero = previousRaidSpacing and (previousRaidSpacing.Horizontal ~= 0 or previousRaidSpacing.Vertical ~= 0)

        -- avoid applying 0 spacing
        if not zeroSpacing or previousNonZero then
            ApplyRaidFrameSpacing()
            previousRaidSpacing = spacing
        end
    end

    if CompactPartyFrame and not CompactPartyFrame:IsForbidden() and CompactPartyFrame:IsVisible() then
        local _, _, _, spacing = GetSettings(false)
        local zeroSpacing = spacing.Horizontal == 0 and spacing.Vertical == 0
        local previousNonZero = previousPartySpacing and (previousPartySpacing.Horizontal ~= 0 or previousPartySpacing.Vertical ~= 0)

        if not zeroSpacing or previousNonZero then
            ApplyPartyFrameSpacing()
            previousPartySpacing = spacing
        end
    end
end

local function OnLayout(container)
    if container ~= CompactRaidFrameContainer then return end
    if container.flowPauseUpdates then return end

    M:ApplySpacing()
end

local function Run()
    M:ApplySpacing()
end

---Initialises the spacing module.
function addon:InitSpacing()
    local eventFrame = CreateFrame("Frame")
    eventFrame:HookScript("OnEvent", Run)
    eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
    eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    eventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
    eventFrame:RegisterEvent("PLAYER_ROLES_ASSIGNED")
    eventFrame:RegisterEvent("UNIT_PET")
    fsSort:RegisterPostSortCallback(Run)
    hooksecurefunc("FlowContainer_DoLayout", OnLayout)
end
