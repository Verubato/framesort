local _, addon = ...
local eventFrame = nil
local previousPartySpacing = nil
local previousRaidSpacing = nil
local fsMath = addon.Math

--- Returns a lookup table of frames to their row and column positions.
local function GridLayout(frames)
    table.sort(frames, function(x, y) return addon:CompareTopLeftFuzzy(x, y) end)

    local byGroup = {}
    local byLookup = {}
    local row = 0
    local col = 0

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
                col = 0
            else
                col = col + 1
            end
        end

        byGroup[frame] = {
            Row = row,
            Column = col
        }
        byLookup[row] = byLookup[row] or {}
        byLookup[row][col] = frame
    end

    return byGroup, byLookup, maxRow, maxCol
end

---Applies spacing to frames that are organised in 'flat' mode.
---Flat mode is where frames are all placed relative to 1 point, i.e. the parent container.
local function FlatMode(frames, spacing)
    local previousPos = nil

    -- iterate over the frames from top left to bottom right
    table.sort(frames, function(x, y) return addon:CompareTopLeft(x, y) end)

    for i, current in ipairs(frames) do
        local previous = i > 1 and frames[i - 1] or nil
        local xDelta = 0
        local yDelta = 0

        if previous then
            local isNewRow = ((current:GetLeft() or 0) < previousPos.left) or ((current:GetTop() or 0) < previousPos.top)

            if isNewRow then
                -- we've hit a new row
                -- subtract existing vertical spacing
                yDelta = spacing.Vertical + ((current:GetTop() or 0) - (previous:GetBottom() or 0))
            elseif not addon:IsPet(current.unit) then
                -- we're within the same row
                -- subtract existing spacing
                xDelta = spacing.Horizontal - ((current:GetLeft() or 0) - (previous:GetRight() or 0))
                yDelta = current:GetTop() - previous:GetTop()
            end
        end

        -- store the unmodified coords
        previousPos = {
            left = current:GetLeft() or 0,
            top = current:GetTop() or 0,
        }

        -- apply the spacing
        current:AdjustPointsOffset(xDelta, -yDelta)
    end
end

local function FlatModePets(pets, spacing, membersFlat, horizontal, relativeTo)
    table.sort(pets, function(x, y) return addon:CompareTopLeft(x, y) end)

    -- move pet frames as if they were a group
    local xDelta = 0
    local yDelta = 0

    if membersFlat then
        if relativeTo:GetLeft() > pets[1]:GetLeft() then
            xDelta = relativeTo:GetLeft() - pets[1]:GetLeft()
        end
        yDelta = (relativeTo:GetBottom() - pets[1]:GetTop()) - spacing.Vertical
    else
        if horizontal then
            yDelta = (relativeTo:GetBottom() - pets[1]:GetTop()) - spacing.Vertical
        else
            yDelta = relativeTo:GetTop() - pets[1]:GetTop()
            xDelta = (relativeTo:GetRight() - pets[1]:GetLeft()) + spacing.Horizontal
        end
    end

    for _, pet in pairs(pets) do
        pet:AdjustPointsOffset(xDelta, yDelta)
    end
end

local function GroupedModeMembers(members, spacing, horizontal)
    -- not sure why, but group member top values aren't exact
    -- so use fuzzy sorting
    table.sort(members, function(x, y) return addon:CompareTopLeftFuzzy(x, y) end)

    for i = 1, #members do
        local member = members[i]
        local _, _, _, offsetX, offsetY = member:GetPoint()
        local xDelta = 0
        local yDelta = 0

        if i == 1 then
            -- no idea why, but sometimes the first member X offset is set when it shouldn't be
            if horizontal then xDelta = -offsetX end
        else
            -- frames are placed relative of each other
            -- so offset values contain what spacing we've previously applied
            if horizontal then
                xDelta = spacing.Horizontal - (offsetX or 0)
            else
                yDelta = spacing.Vertical + (offsetY or 0)
            end
        end

        member:AdjustPointsOffset(xDelta, -yDelta)
    end
end

---Applies spacing to frames that are organised in 'grouped' mode.
---Grouped mode is where frames are placed relative to the frame before it within one or more groups,
---e.g.: group1: frame3 is placed relative to frame2 which is placed relative to frame 1.
---e.g.: group2: frame5 is placed relative to frame4.
local function GroupedMode(groups, spacing, horizontal)
    local posByGroup, groupByPos = GridLayout(groups)
    local membersByGroup = {}

    for _, group in ipairs(groups) do
        local members = addon:GetRaidFrameGroupMembers(group)
        table.sort(members, function(x, y) return addon:CompareTopLeftFuzzy(x, y) end)

        membersByGroup[group] = members
    end

    local debugRow = 0
    while groupByPos[debugRow] do
        local debugCol = 0

        while groupByPos[debugRow][debugCol] do
            local group = groupByPos[debugRow][debugCol]
            addon:Debug(group.title:GetText() .. ": Row = " .. debugRow .. " Col = " .. debugCol)
            debugCol = debugCol + 1
        end

        debugRow = debugRow + 1
    end

    --- apply spacing to the member frames
    for _, group in ipairs(groups) do
        local members = membersByGroup[group]
        GroupedModeMembers(members, spacing, horizontal)
    end

    -- determine the vertical anchors
    local verticalAnchorsByRow = {}
    for i = 1, #groups do
        local group = groups[i]
        local pos = posByGroup[group]

        if pos.Row >= 1 then
            if horizontal then
                -- in horizontal mode, the anchor is simply the group above
                local above = pos.Row >= 1 and groupByPos[pos.Row - 1][pos.Column]
                verticalAnchorsByRow[pos.Row] = above
            else
                -- in vertical mode, the anchor is the bottom most member of the groups in the above row
                local previousRow = groupByPos[pos.Row - 1]
                local bottomMost = nil
                local col = 0

                while previousRow[col] do
                    local next = previousRow[col]
                    local members = membersByGroup[next]
                    local lastMember = members[#members]

                    if not bottomMost or (lastMember:GetBottom() or 0) < (bottomMost:GetBottom() or 0) then
                        bottomMost = lastMember
                    end

                    col = col + 1
                end

                verticalAnchorsByRow[pos.Row] = bottomMost
            end
        end
    end

    -- determine the horizontal anchors
    local horizontalAnchorsByColumn = {}
    for i = 1, #groups do
        local group = groups[i]
        local pos = posByGroup[group]

        if pos.Column >= 1 then
            if not horizontal then
                -- in vertical mode, the anchor is simply the group to the left
                local left = pos.Column >= 1 and groupByPos[pos.Row][pos.Column - 1] or nil
                horizontalAnchorsByColumn[pos.Column] = left
            else
                -- in horizontal mode, the anchor is the left most member of the groups in the left column
                local leftMost = nil
                local row = 0

                while groupByPos[row] do
                    local next = groupByPos[row][pos.Column - 1]

                    if next then
                        local members = membersByGroup[next]
                        local lastMember = members[#members]

                        if not leftMost or (lastMember:GetRight() or 0) > (leftMost:GetRight() or 0) then
                            leftMost = lastMember
                        end
                    end

                    row = row + 1
                end

                horizontalAnchorsByColumn[pos.Column] = leftMost
            end
        end
    end

    -- finally, apply spacing between the groups
    for i = 1, #groups do
        local group = groups[i]
        local pos = posByGroup[group]
        local xDelta = 0
        local yDelta = 0

        -- vertical spacing
        if pos.Row >= 1 then
            local anchor = verticalAnchorsByRow[pos.Row]

            if anchor then
                yDelta = spacing.Vertical + (group:GetTop() - anchor:GetBottom())
            end
        end

        -- horizontal spacing
        if pos.Column >= 1 then
            local anchor = horizontalAnchorsByColumn[pos.Column]

            if anchor then
                xDelta = spacing.Horizontal - (group:GetLeft() - anchor:GetRight())
            end
        end

        group:AdjustPointsOffset(xDelta, -yDelta)
    end
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
        horizontal = CompactRaidFrameManager_GetSetting("HorizontalGroups")
        spacing = addon.Options.Appearance.Raid.Spacing
    end

    return flat, horizontal, showPets, spacing
end

local function ApplyPartyFrameSpacing()
    local frames = addon:GetPartyFrames()
    if #frames == 0 then return end

    local flat, horizontal, showPets, spacing = GetSettings(false)

    addon:Debug("Applying party frame spacing (" .. (horizontal and "horizontal" or "vertical") .. " layout).")

    GroupedModeMembers(frames, spacing, horizontal)

    if not flat and showPets then
        local _, pets, _ = addon:GetRaidFrames()
        FlatModePets(pets, spacing, false, horizontal, frames[1])
    end
end

local function ApplyRaidFrameSpacing()
    local flat, horizontal, showPets, spacing = GetSettings(true)

    addon:Debug("Applying raid frame spacing" ..
    (showPets and " with pets " or " ") ..
    (horizontal and "(horizontal " or "(vertical ") ..
    (flat and "flattened" or "grouped") ..
    " layout.")

    if flat then
        local members, pets, _ = addon:GetRaidFrames()
        if #members == 0 and #pets == 0 then return end

        FlatMode(members, spacing)

        if not pets or #pets == 0 then return end

        table.sort(members, function(x, y) return addon:CompareLeftTop(x, y) end)
        FlatModePets(pets, spacing, true, horizontal, members[#members])
    else
        local groups = addon:GetRaidFrameGroups()
        if #groups == 0 then return end

        GroupedMode(groups, spacing, horizontal)

        local pets = nil
        if showPets then
            _, pets, _ = addon:GetRaidFrames()
        end

        if not pets or #pets == 0 then return end

        local lastGroup = groups[#groups]
        local lastGroupMembers = addon:GetRaidFrameGroupMembers(lastGroup)

        FlatModePets(pets, spacing, false, horizontal, lastGroupMembers[1])
    end
end

---Event hook on blizzard performing frame layouts.
local function OnLayout(container)
    if container ~= CompactRaidFrameContainer then return end
    if container.flowPauseUpdates then return end

    addon:ApplySpacing()
end

local function OnEvent()
    addon:ApplySpacing()
end

---Applies spacing to party and raid frames.
function addon:ApplySpacing()
    if InCombatLockdown() then
        addon:Debug("Can't apply spacing during combat.")
        return
    end

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

---Initialises the spacing module.
function addon:InitSpacing()
    eventFrame = CreateFrame("Frame")
    eventFrame:HookScript("OnEvent", OnEvent)
    eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
    eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    eventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
    addon:RegisterPostSortCallback(OnEvent)
    hooksecurefunc("FlowContainer_DoLayout", OnLayout)
end
