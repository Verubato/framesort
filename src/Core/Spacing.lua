local _, addon = ...

local function TrackFrame(frame)
    local currentPosition = {
        X = frame:GetLeft(),
        Y = frame:GetTop()
    }

    if not frame.FrameSort then
        frame.FrameSort = {
            OriginalPosition = currentPosition,
            CurrentPosition = currentPosition
        }
    end

    -- if the frame has moved then we need to reset the stored positions
    local hasMoved =
        currentPosition.X ~= frame.FrameSort.CurrentPosition.X or
        currentPosition.Y ~= frame.FrameSort.CurrentPosition.Y

    if hasMoved then
        frame.FrameSort.OriginalPosition = currentPosition
        frame.FrameSort.CurrentPosition = currentPosition
    end
end

local function UpdateCurrentPosition(frame)
    frame.FrameSort.CurrentPosition = {
        X = frame:GetLeft(),
        Y = frame:GetTop()
    }
end

--- Applies spacing to frames that are organised in 'flat' mode.
--- Flat mode is where frames are all placed relative to 1 point, i.e. the parent container.
local function FlatMode(frames, spacing, offset)
    local xStep = 0
    local yStep = 0

    -- iterate over the frames from top left to bottom right
    -- (frames are assumed to be in order)
    for i, current in ipairs(frames) do
        local previous = i > 1 and frames[i - 1] or nil

        TrackFrame(current)

        if previous then
            local isNewRow =
                (current.FrameSort.OriginalPosition.X or 0) < (previous.FrameSort.OriginalPosition.X or 0) or
                (current.FrameSort.OriginalPosition.Y or 0) < (previous.FrameSort.OriginalPosition.Y or 0)

            if isNewRow then
                xStep = 0
                yStep = yStep + spacing.Vertical
            else
                xStep = xStep + spacing.Horizontal
            end
        end

        -- calculate the offset based on the current and original position
        local xDelta = xStep - ((current:GetLeft() or 0) - (current.FrameSort.OriginalPosition.X or 0))
        local yDelta = yStep + ((current:GetTop() or 0) - (current.FrameSort.OriginalPosition.Y or 0))

        -- any additional offset to be applied
        if offset then
            xDelta = xDelta + offset.X
            yDelta = yDelta + offset.Y
        end

        -- apply the spacing
        current:AdjustPointsOffset(xDelta, -yDelta)

        -- store the position we moved it to
        UpdateCurrentPosition(current)
    end
end

local function FlatModePets(pets, spacing, groupsCount, horizontal, firstMemberFrame)
    local offset = {
        X = not horizontal and groupsCount * spacing.Horizontal or 0,
        Y = horizontal and groupsCount * spacing.Vertical or 0
    }

    -- in vertical mode, blizzard haven't aligned the pet frames nicely
    -- so let's do that
    if not horizontal and #pets > 0 and firstMemberFrame then
        TrackFrame(firstMemberFrame)
        TrackFrame(pets[1])

        local yfix = firstMemberFrame.FrameSort.OriginalPosition.Y - pets[1].FrameSort.OriginalPosition.Y
        offset.Y = offset.Y - yfix
    end

    -- pets are shown outside of groups (i.e. the "flat" mode)
    FlatMode(pets, spacing, offset)
end

local function GroupedModeMembers(members, spacing, horizontal)
    for j = 2, #members do
        local member = members[j]
        local _, _, _, offsetX, offsetY = member:GetPoint()
        local xDelta = 0
        local yDelta = 0

        -- frames are placed relative of each other
        -- so offset values contain what spacing we've previously applied
        if horizontal then
            xDelta = spacing.Horizontal - (offsetX or 0)
        else
            yDelta = spacing.Vertical + (offsetY or 0)
        end

        member:AdjustPointsOffset(xDelta, -yDelta)
    end
end

---Applies spacing to frames that are organised in 'grouped' mode.
---Grouped mode is where frames are placed relative to the frame before it within one or more groups,
---e.g.: group1: frame3 is placed relative to frame2 which is placed relative to frame 1.
---e.g.: group2: frame5 is placed relative to frame4.
local function GroupedMode(groups, pets, spacing, horizontal)
    local firstMember = nil
    for i, group in ipairs(groups) do
        TrackFrame(group)

        if i > 1 then
            local xDelta = 0
            local yDelta = 0

            if horizontal then
                -- add vertical spacing between each group
                yDelta = ((i - 1) * spacing.Vertical) + ((group:GetTop() or 0) - (group.FrameSort.OriginalPosition.Y or 0))
            else
                -- add horizontal spacing between each group
                xDelta = ((i - 1) * spacing.Horizontal) - ((group:GetLeft() or 0) - (group.FrameSort.OriginalPosition.X or 0))
            end

            group:AdjustPointsOffset(xDelta, -yDelta)
            UpdateCurrentPosition(group)
        end

        local members = addon:GetRaidFrameGroupMembers(group)
        firstMember = firstMember or members[1]
        GroupedModeMembers(members, spacing, horizontal)
    end

    if pets and #pets > 0 then
        FlatModePets(pets, spacing, #groups, horizontal, firstMember)
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
        FlatModePets(pets, spacing, 1, horizontal, frames[1])
    end
end

local function ApplyRaidFrameSpacing()
    local flat, horizontal, showPets, spacing = GetSettings(true)

    if flat then
        local _, _, frames = addon:GetRaidFrames()
        if #frames == 0 then return end

        addon:Debug("Applying raid frame spacing (flattened layout).")
        FlatMode(frames, spacing)
    else
        local groups = addon:GetRaidFrameGroups()
        if #groups == 0 then return end

        local pets = nil
        if showPets then
            _, pets, _ = addon:GetRaidFrames()
        end

        local withPets = showPets and " with pets" or ""
        if horizontal then
            addon:Debug("Applying raid frame spacing" .. withPets .. " (horizontal grouped layout).")
        else
            addon:Debug("Applying raid frame spacing" .. withPets .. " (vertical grouped layout).")
        end

        GroupedMode(groups, pets, spacing, horizontal)
    end
end

---Applies spacing to party and raid frames.
function addon:ApplySpacing()
    if InCombatLockdown() then
        addon:Debug("Can't apply spacing during combat.")
        return
    end

    if CompactRaidFrameContainer and not CompactRaidFrameContainer:IsForbidden() and CompactRaidFrameContainer:IsVisible() then
        ApplyRaidFrameSpacing()
    end

    if CompactPartyFrame and not CompactPartyFrame:IsForbidden() and CompactPartyFrame:IsVisible() then
        ApplyPartyFrameSpacing()
    end
end
