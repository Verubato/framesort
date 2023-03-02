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

local function UpdateRaidSpacing(frames, spacing)
    local previousFrame = nil
    local xStep = 0
    local yStep = 0

    -- iterate over the frames from top left to bottom right
    -- (frames assumed they are in order)
    for _, frame in ipairs(frames) do
        TrackRaidFrame(frame)

        local isNewRow = previousFrame and frame:GetLeft() < previousFrame:GetLeft()
        if isNewRow then
            -- we've hit a new row
            -- i.e. this frame is the far left frame of the next row
            -- reset x spacing back to 0
            -- and up the y spacing
            xStep = 0
            yStep = yStep + spacing.Vertical
        elseif previousFrame then
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
        frame.FrameSort.CurrentPosition = {
            X = frame:GetLeft(),
            Y = frame:GetTop()
        }

        previousFrame = frame
    end
end

---Applies spacing to party/raid frames (depending on which are shown).
function addon:ApplySpacing()
    if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
        if not CompactRaidFrameContainer:IsForbidden() and CompactRaidFrameContainer:IsVisible() then
            return addon:ApplyRaidFrameSpacing()
        elseif not CompactPartyFrame:IsForbidden() and CompactPartyFrame:IsVisible() then
            return addon:ApplyPartyFrameSpacing()
        end
    else
        if not CompactRaidFrameContainer:IsForbidden() and CompactRaidFrameContainer:IsVisible() then
            return addon:ApplyRaidFrameSpacing()
        end
    end
end

---Applies spacing to party frames.
function addon:ApplyPartyFrameSpacing()
    local spacing = addon.Options.Appearance.Party.Spacing
    if spacing.Horizontal == 0 and spacing.Vertical == 0 then
        return
    end

    local frames = addon:GetPartyFrames()
    if #frames == 0 then
        return
    end

    addon:Debug("Applying party frame spacing.")

    local horizontalLayout = EditModeManagerFrame:ShouldRaidFrameUseHorizontalRaidGroups(CompactPartyFrame.isParty)

    -- iterate over the frames from top left to bottom right
    for i = 2, #frames do
        local frame = frames[i]
        local _, _, _, offsetX, offsetY = frame:GetPoint()

        -- party frames are placed relative of each other
        -- so we offset values contain what spacing we've previously applied (if any)
        local xDelta = horizontalLayout and spacing.Horizontal - offsetX or 0
        local yDelta = not horizontalLayout and spacing.Vertical + offsetY or 0

        -- apply the spacing
        frame:AdjustPointsOffset(xDelta, -yDelta)
    end
end

---Applies spacing to the raid frames.
function addon:ApplyRaidFrameSpacing()
    local spacing = addon.Options.Appearance.Raid.Spacing
    if spacing.Horizontal == 0 and spacing.Vertical == 0 then
        return
    end

    local memberFrames, petFrames, _ = addon:GetRaidFrames()
    if #memberFrames == 0 then
        return
    end

    addon:Debug("Applying raid frame spacing.")
    UpdateRaidSpacing(memberFrames, addon.Options.Appearance.Raid.Spacing)
    UpdateRaidSpacing(petFrames, addon.Options.Appearance.Raid.Spacing)
end
