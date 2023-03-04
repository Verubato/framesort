local _, addon = ...

local function TrackRaidFrame(frame)
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

local function StoreCurrentPosition(frame)
    frame.FrameSort.CurrentPosition = {
        X = frame:GetLeft(),
        Y = frame:GetTop()
    }
end

local function FlatMode(frames, rowBased)
    local spacing = addon.Options.Appearance.Raid.Spacing
    local previous = nil
    local xStep = 0
    local yStep = 0

    -- iterate over the frames from top left to bottom right
    -- (frames assumed they are in order)
    for _, frame in ipairs(frames) do
        TrackRaidFrame(frame)

        if rowBased then
            -- retail uses rows
            local isNewRow = previous and (frame:GetLeft() or 0) < (previous:GetLeft() or 0)
            if isNewRow then
                xStep = 0
                yStep = yStep + spacing.Vertical
            elseif previous then
                xStep = xStep + spacing.Horizontal
            end
        else
            -- wotlk uses columns
            local isNewCol = previous and frame:GetLeft() ~= previous:GetLeft()
            if isNewCol then
                yStep = 0
                xStep = xStep + spacing.Horizontal
            elseif previous then
                yStep = yStep + spacing.Vertical
            end
        end

        -- calculate the offset based on the current and original position
        local xDelta = xStep - ((frame:GetLeft() or 0) - (frame.FrameSort.OriginalPosition.X or 0))
        local yDelta = yStep + ((frame:GetTop() or 0) - (frame.FrameSort.OriginalPosition.Y or 0))

        -- apply the spacing
        frame:AdjustPointsOffset(xDelta, -yDelta)

        -- store the position we moved it to
        StoreCurrentPosition(frame)

        previous = frame
    end
end

local function SeparateMode(groups, horizontal)
    local spacing = addon.Options.Appearance.Raid.Spacing

    for i = 1, #groups do
        local group = groups[i]
        local members = addon:GetRaidFrameGroupMembers(group)

        TrackRaidFrame(group)

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
            StoreCurrentPosition(group)
        end

        for j = 2, #members do
            local member = members[j]
            local _, _, _, offsetX, offsetY = member:GetPoint()
            local xDelta = 0
            local yDelta = 0

            if horizontal then
                -- add horizontal spacing between each member
                xDelta = spacing.Horizontal - (offsetX or 0)
            else
                -- add vertical spacing between each member
                yDelta = spacing.Vertical + (offsetY or 0)
            end

            member:AdjustPointsOffset(xDelta, -yDelta)
        end
    end
end

---Applies spacing to party/raid frames (depending on which are shown).
function addon:ApplySpacing()
    if InCombatLockdown() then
        return
    end

    if not CompactRaidFrameContainer:IsForbidden() and CompactRaidFrameContainer:IsVisible() then
        addon:ApplyRaidFrameSpacing()
    end

    if not CompactPartyFrame:IsForbidden() and CompactPartyFrame:IsVisible() then
        addon:ApplyPartyFrameSpacing()
    end
end

---Applies spacing to party frames.
function addon:ApplyPartyFrameSpacing()
    local frames = addon:GetPartyFrames()

    if #frames == 0 then
        return
    end

    addon:Debug("Applying party frame spacing.")

    local horizontal = false
    local spacing = addon.Options.Appearance.Party.Spacing

    if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
        horizontal = EditModeManagerFrame:ShouldRaidFrameUseHorizontalRaidGroups(CompactPartyFrame.isParty)
    else
        spacing = addon.Options.Appearance.Raid.Spacing
        horizontal = CompactRaidFrameManager_GetSetting("HorizontalGroups")
    end

    -- iterate over the frames from top left to bottom right
    for i = 2, #frames do
        local frame = frames[i]
        local _, _, _, offsetX, offsetY = frame:GetPoint()

        -- party frames are placed relative of each other
        -- so we offset values contain what spacing we've previously applied (if any)
        local xDelta = 0
        local yDelta = 0

        if horizontal then
            xDelta = spacing.Horizontal - (offsetX or 0)
        else
            yDelta = spacing.Vertical + (offsetY or 0)
        end

        -- apply the spacing
        frame:AdjustPointsOffset(xDelta, -yDelta)
    end
end

---Applies spacing to the raid frames.
function addon:ApplyRaidFrameSpacing()
    -- TODO: Pets spacing not working properly in Wotlk when "Keep Groups Together" == true
    local flat = nil
    local horizontal = nil
    local rowBased = nil

    if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
        local raidGroupDisplayType = EditModeManagerFrame:GetSettingValue(
            Enum.EditModeSystem.UnitFrame,
            Enum.EditModeUnitFrameSystemIndices.Raid,
            Enum.EditModeUnitFrameSetting.RaidGroupDisplayType)

        flat =
            raidGroupDisplayType == Enum.RaidGroupDisplayType.CombineGroupsVertical or
            raidGroupDisplayType == Enum.RaidGroupDisplayType.CombineGroupsHorizontal

        horizontal = raidGroupDisplayType == Enum.RaidGroupDisplayType.SeparateGroupsHorizontal
        rowBased = true
    else
        flat = not CompactRaidFrameManager_GetSetting("KeepGroupsTogether")
        horizontal = CompactRaidFrameManager_GetSetting("HorizontalGroups")
        rowBased = false
    end

    if flat then
        local _, _, frames = addon:GetRaidFrames()
        if #frames == 0 then return end

        addon:Debug("Applying raid frame spacing (flattened layout).")
        FlatMode(frames, rowBased)
    else
        local groups = addon:GetRaidFrameGroups()
        if #groups == 0 then return end

        if horizontal then
            addon:Debug("Applying raid frame spacing (horizontal grouped layout).")
        else
            addon:Debug("Applying raid frame spacing (vertical grouped layout).")
        end

        SeparateMode(groups, horizontal)
    end
end
