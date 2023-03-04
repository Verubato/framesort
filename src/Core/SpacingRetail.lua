local _, addon = ...

local function TrackRaidFrame(frame)
    local currentPosition = {
        X = frame:GetLeft(),
        Y = frame:GetTop()
    }

    -- TODO: is it safe to store our properties on a blizzard object?
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

local function CombinedMode(frames)
    local spacing = addon.Options.Appearance.Raid.Spacing
    local previous = nil
    local xStep = 0
    local yStep = 0

    -- iterate over the frames from top left to bottom right
    -- (frames assumed they are in order)
    for _, frame in ipairs(frames) do
        TrackRaidFrame(frame)

        local isNewRow = previous and frame:GetLeft() < previous:GetLeft()
        if isNewRow then
            -- we've hit a new row
            -- i.e. this frame is the far left frame of the next row
            -- reset x spacing back to 0
            -- and up the y spacing
            xStep = 0
            yStep = yStep + spacing.Vertical
        elseif previous then
            -- still within the same row
            -- increase the x spacing for each subsequent frame
            xStep = xStep + spacing.Horizontal
        end

        -- calculate the offset based on the current and original position
        local xDelta = xStep - (frame:GetLeft() - frame.FrameSort.OriginalPosition.X)
        local yDelta = yStep + (frame:GetTop() - frame.FrameSort.OriginalPosition.Y)

        -- apply the spacing
        frame:AdjustPointsOffset(xDelta, -yDelta)

        -- store the position we moved it to
        StoreCurrentPosition(frame)

        previous = frame
    end
end

local function SeparateHorizontalMode(groups)
    local spacing = addon.Options.Appearance.Raid.Spacing

    for i = 1, #groups do
        local group = groups[i]
        local members = addon:GetRaidFrameGroupMembers(group)

        TrackRaidFrame(group)

        if i > 1 then
            -- add vertical spacing between each group
            local yDelta = ((i - 1) * spacing.Vertical) + ((group:GetTop() or 0) - (group.FrameSort.OriginalPosition.Y or 0))

            group:AdjustPointsOffset(0, -yDelta)
            StoreCurrentPosition(group)
        end

        for j = 2, #members do
            -- add horizontal spacing between each member
            local member = members[j]
            local _, _, _, offsetX, _ = member:GetPoint()
            local xDelta = spacing.Horizontal - (offsetX or 0)
            member:AdjustPointsOffset(xDelta, 0)
        end
    end
end

local function SeparateVerticalMode(groups)
    local spacing = addon.Options.Appearance.Raid.Spacing

    for i = 1, #groups do
        local group = groups[i]
        local members = addon:GetRaidFrameGroupMembers(group)

        TrackRaidFrame(group)

        if i > 1 then
            -- add horizontal spacing between each group
            local xDelta = ((i - 1) * spacing.Horizontal) - ((group:GetLeft() or 0) - (group.FrameSort.OriginalPosition.X or 0))

            group:AdjustPointsOffset(xDelta, 0)
            StoreCurrentPosition(group)
        end

        for j = 2, #members do
            -- add vertical spacing between each member
            local member = members[j]
            local _, _, _, _, offsetY = member:GetPoint()
            local yDelta = spacing.Vertical + (offsetY or 0)
            member:AdjustPointsOffset(0, -yDelta)
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

if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
    ---Applies spacing to party frames.
    function addon:ApplyPartyFrameSpacing()
        local frames = addon:GetPartyFrames()

        if #frames == 0 then
            return
        end

        addon:Debug("Applying party frame spacing.")

        local horizontalLayout = EditModeManagerFrame:ShouldRaidFrameUseHorizontalRaidGroups(CompactPartyFrame.isParty)
        local spacing = addon.Options.Appearance.Party.Spacing

        -- iterate over the frames from top left to bottom right
        for i = 2, #frames do
            local frame = frames[i]
            local _, _, _, offsetX, offsetY = frame:GetPoint()

            -- party frames are placed relative of each other
            -- so we offset values contain what spacing we've previously applied (if any)
            local xDelta = 0
            local yDelta = 0

            if horizontalLayout then
                xDelta = spacing.Horizontal - (offsetX or 0)
            else
                yDelta = spacing.Vertical + (offsetY or 0)
            end

            -- apply the spacing
            frame:AdjustPointsOffset(xDelta, -yDelta)
        end
    end
end

---Applies spacing to the raid frames.
function addon:ApplyRaidFrameSpacing()
    local raidGroupDisplayType = EditModeManagerFrame:GetSettingValue(
        Enum.EditModeSystem.UnitFrame,
        Enum.EditModeUnitFrameSystemIndices.Raid,
        Enum.EditModeUnitFrameSetting.RaidGroupDisplayType)

    local isCombined =
        raidGroupDisplayType == Enum.RaidGroupDisplayType.CombineGroupsVertical or
        raidGroupDisplayType == Enum.RaidGroupDisplayType.CombineGroupsHorizontal

    local horizontal = raidGroupDisplayType == Enum.RaidGroupDisplayType.SeparateGroupsHorizontal

    if isCombined then
        local _, _, frames = addon:GetRaidFrames()
        if #frames == 0 then return end

        addon:Debug("Applying raid frame spacing.")
        CombinedMode(frames)
    else
        local groups = addon:GetRaidFrameGroups()
        if #groups == 0 then return end

        addon:Debug("Applying raid frame spacing.")

        if horizontal then
            SeparateHorizontalMode(groups)
        else
            SeparateVerticalMode(groups)
        end
    end
end
