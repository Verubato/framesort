local _, addon = ...
local fsSort = addon.Sorting
local fsFrame = addon.Frame
local fsCompare = addon.Compare
local fsMath = addon.Math
local fsEnumerable = addon.Enumerable
local previousSpacing = {}
local M = {}
addon.Spacing = M

---Calculates the desired positions of the frames with spacing applied.
---The returning table is sparse, so if there are no changes required to a frame then it won't have an entry.
---@param frames table[] the set of frames to calculate positions on.
---@param spacing table the spacing to apply
---@param start table? an optional Top+Left position that frames should "start" at.
---@param blockHeight number? an optional manual override to specify the grid block height, otherwise it will be automatically calculated.
---@return table
local function Positions(frames, spacing, start, blockHeight)
    if #frames == 0 then
        return {}
    end

    local positions = {}
    local row = 1
    local yApplied = 0

    if not blockHeight then
        local tallestFrame = fsEnumerable:From(frames):Max(function(x)
            return x:GetHeight()
        end)

        blockHeight = tallestFrame:GetHeight()
    end

    local orderedLeftTop = fsEnumerable
        :From(frames)
        :OrderBy(function(x, y)
            return fsCompare:CompareLeftTopFuzzy(x, y)
        end)
        :ToTable()
    local currentBlockHeight = orderedLeftTop[1]:GetHeight()

    -- vertical spacing
    -- iterate top to bottom
    for i = 2, #orderedLeftTop do
        local frame = orderedLeftTop[i]
        local previous = orderedLeftTop[i - 1]
        local sameColumn = fsMath:Round(frame:GetLeft()) == fsMath:Round(previous:GetLeft())
        local top = nil

        if sameColumn then
            if currentBlockHeight >= blockHeight then
                currentBlockHeight = 0
            end

            local newBlock = currentBlockHeight == 0

            if newBlock then
                -- we've hit a new block or exceeded the block size
                local spacingToAdd = row * spacing.Vertical
                top = (previous:GetBottom() + yApplied) - spacingToAdd
                yApplied = yApplied + (previous:GetBottom() - frame:GetTop())
                row = row + 1
            else
                -- we're inside an existing block, e.g. a split cell
                -- by "block" I mean a segment of space in a grid layout which may contain 1 or more frames
                local spacingToAdd = (row - 1) * spacing.Vertical
                top = (previous:GetBottom() + yApplied) - spacingToAdd
            end

            if top then
                positions[frame] = {
                    Top = top,
                }
            end
        else
            row = 1
            yApplied = 0
            currentBlockHeight = 0
        end

        currentBlockHeight = currentBlockHeight + frame:GetHeight()
    end

    local column = 1
    local xApplied = 0
    local orderedTopLeft = fsEnumerable
        :From(frames)
        :OrderBy(function(x, y)
            return fsCompare:CompareTopLeftFuzzy(x, y)
        end)
        :ToTable()

    -- horizontal spacing
    -- iterate left to right
    for i = 2, #orderedTopLeft do
        local frame = orderedTopLeft[i]
        local previous = orderedTopLeft[i - 1]
        local sameRow = fsMath:Round(frame:GetTop()) == fsMath:Round(previous:GetTop())
        local sameColumn = fsMath:Round(frame:GetLeft()) == fsMath:Round(previous:GetLeft())
        local left = nil

        if sameColumn then
            local spacingToAdd = (column - 1) * spacing.Horizontal
            left = frame:GetLeft() + xApplied + spacingToAdd
        elseif sameRow then
            local spacingToAdd = column * spacing.Horizontal
            left = previous:GetRight() + xApplied + spacingToAdd
            xApplied = xApplied + (previous:GetRight() - frame:GetLeft())
            column = column + 1
        end

        if left then
            local position = positions[frame]
            if not position then
                position = {}
                positions[frame] = position
            end

            position.Left = left
        end

        if not sameRow then
            column = 1
            xApplied = 0
        end
    end

    -- apply the starting position offset
    if start then
        local first = orderedTopLeft[1]
        positions[first] = {
            Top = start.Top,
            Left = start.Left,
        }

        local xOffset = start.Left and (start.Left - first:GetLeft()) or nil
        local yOffset = start.Top and (first:GetTop() - start.Top) or nil

        for i = 2, #orderedTopLeft do
            local frame = orderedTopLeft[i]
            local pos = positions[frame]

            if yOffset or xOffset then
                if not pos then
                    pos = {}
                    positions[frame] = pos
                end

                if yOffset then
                    pos.Top = pos.Top or frame:GetTop()

                    local top = pos.Top - yOffset
                    pos.Top = top
                end

                if xOffset then
                    pos.Left = pos.Left or frame:GetLeft()

                    local left = pos.Left + xOffset
                    pos.Left = left
                end
            end
        end
    end

    return positions
end

---Applies spacing to frames that are organised in 'flat' mode.
---Flat mode is where frames are all placed relative to 1 point, i.e. the parent container.
local function Flat(frames, spacing, start, blockHeight)
    if #frames == 0 then
        return
    end

    -- calculate the desired positions (with spacing added)
    local positions = Positions(frames, spacing, start, blockHeight)

    for frame, to in pairs(positions) do
        local xDelta = to.Left and (to.Left - frame:GetLeft()) or 0
        local yDelta = to.Top and (to.Top - frame:GetTop()) or 0

        if xDelta ~= 0 or yDelta ~= 0 then
            frame:AdjustPointsOffset(xDelta, yDelta)
        end
    end
end

local function Chain(frames, spacing, above)
    if #frames == 0 then
        return
    end

    -- why all this complexity instead of just a simple sequence of SetPoint() calls?
    -- it's because SetPoint() can't be called in combat whereas AdjustPointsOffset() can
    -- SetPoint() is just completely disallowed (by unsecure code) in combat, even if only changing x/y points
    -- being able to run this in combat has the benefit that if blizzard reset/redraw frames mid-combat, we can reapply our sorting/spacing!
    local root = fsFrame:ToFrameChain(frames)
    if not root.Valid then
        return
    end

    -- store the top frame position before any movements
    local first = fsEnumerable
        :From(frames)
        :OrderBy(function(x, y)
            return fsCompare:CompareTopLeftFuzzy(x, y)
        end)
        :First()

    local start = nil

    if above then
        start = {
            Top = above:GetBottom() - spacing.Vertical,
        }
    else
        start = {
            Top = first:GetTop(),
            Left = first:GetLeft(),
        }
    end

    local positions = Positions(frames, spacing, start)

    -- apply the spacing
    local current = root
    while current do
        local frame = current.Value
        local to = positions[frame]

        if to then
            local xDelta = to.Left and (to.Left - frame:GetLeft()) or 0
            local yDelta = to.Top and (to.Top - frame:GetTop()) or 0

            if xDelta ~= 0 or yDelta ~= 0 then
                frame:AdjustPointsOffset(xDelta, yDelta)
            end
        end

        current = current.Next
    end
end

local function ShouldSpace(container, spacing)
    local previous = previousSpacing[container]
    local previousNonZero = previous and (previous.Horizontal ~= 0 or previous.Vertical ~= 0)
    local zeroSpacing = spacing.Horizontal == 0 and spacing.Vertical == 0

    return previousNonZero or not zeroSpacing
end

local function StorePreviousSpacing(container, spacing)
    previousSpacing[container] = {
        Horizontal = spacing.Horizontal,
        Vertical = spacing.Vertical,
    }
end

local function ApplyPartySpacing()
    local container = CompactPartyFrame
    local spacing = addon.Options.Appearance.Party.Spacing

    if not container or not ShouldSpace(container, spacing) then
        return
    end

    local players, pets = fsFrame:GetPartyFrames()

    Chain(players, spacing)
    StorePreviousSpacing(container, spacing)

    if not fsFrame:ShowPets() then
        return
    end

    local above = nil
    if not fsFrame:HorizontalLayout(false) then
        above = fsEnumerable
            :From(players)
            :OrderBy(function(x, y)
                return fsCompare:CompareBottomLeftFuzzy(x, y)
            end)
            :First()
    end

    Chain(pets, spacing, above)
end

local function ApplyRaidSpacing()
    local container = CompactRaidFrameContainer
    local spacing = addon.Options.Appearance.Raid.Spacing

    if not container or not ShouldSpace(container, spacing) then
        return
    end

    local players, pets = fsFrame:GetRaidFrames()

    if #players == 0 and #pets == 0 then
        return
    end

    local together = fsFrame:KeepGroupsTogether(true)

    if not together then
        if fsFrame:ShowPets() then
            local all = fsEnumerable:From(players):Concat(pets):ToTable()
            Flat(all, spacing)
        else
            Flat(players, spacing)
        end

        StorePreviousSpacing(container, spacing)
        return
    end

    local groups = fsFrame:GetGroups(container)
    if #groups > 0 then
        for _, group in ipairs(groups) do
            local members = fsFrame:GetRaidFrameGroupMembers(group)
            Chain(members, spacing)
        end

        Flat(groups, spacing)
    else
        Chain(players, spacing)
    end

    StorePreviousSpacing(container, spacing)

    if not fsFrame:ShowPets() then
        return
    end

    local start = {}

    if fsFrame:HorizontalLayout(true) then
        local bottomGroup = fsEnumerable:From(groups):Min(function(x)
            return x:GetBottom()
        end)
        local bottom = bottomGroup and fsEnumerable:From(fsFrame:GetRaidFrameGroupMembers(bottomGroup)):Min(function(x)
            return x:GetBottom()
        end)

        if bottom then
            start.Top = bottom:GetBottom() - spacing.Vertical
        end
    else
        local rightGroup = fsEnumerable:From(groups):Max(function(x)
            return x:GetRight()
        end)
        local right = rightGroup and fsEnumerable:From(fsFrame:GetRaidFrameGroupMembers(rightGroup)):Max(function(x)
            return x:GetRight()
        end)
        local topGroup = fsEnumerable:From(groups):Max(function(x)
            return x:GetTop()
        end)
        local top = topGroup and fsEnumerable:From(fsFrame:GetRaidFrameGroupMembers(topGroup)):Max(function(x)
            return x:GetTop()
        end)

        if top then
            start.Top = top:GetTop()
        end

        if right then
            start.Left = right:GetRight() + spacing.Horizontal
        end
    end

    -- manually specify the block height to the player frames height
    -- otherwise it would auto detect the pet frame height
    local blockHeight = #players > 0 and players[1]:GetHeight() or nil
    Flat(pets, spacing, start, blockHeight)
end

local function ApplyEnemyArenaSpacing()
    local container = CompactArenaFrame
    local spacing = addon.Options.Appearance.EnemyArena.Spacing

    if not container or not ShouldSpace(container, spacing) then
        return
    end

    local players, pets, _ = fsFrame:GetEnemyArenaFrames()
    local all = fsEnumerable:From(players):Concat(pets):ToTable()

    Flat(all, spacing)
    StorePreviousSpacing(container, spacing)
end

---Applies spacing to party and raid frames.
function M:ApplySpacing()
    ApplyPartySpacing()
    ApplyRaidSpacing()
    ApplyEnemyArenaSpacing()
end

local function Run()
    M:ApplySpacing()
end

---Initialises the spacing module.
function addon:InitSpacing()
    fsSort:RegisterPostSortCallback(Run)

    local eventFrame = CreateFrame("Frame")
    eventFrame:HookScript("OnEvent", Run)
    eventFrame:RegisterEvent(addon.Events.PLAYER_ENTERING_WORLD)
    eventFrame:RegisterEvent(addon.Events.GROUP_ROSTER_UPDATE)
    eventFrame:RegisterEvent(addon.Events.PLAYER_ROLES_ASSIGNED)
    eventFrame:RegisterEvent(addon.Events.UNIT_PET)

    if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
        EventRegistry:RegisterCallback(addon.Events.EditModeExit, Run)
    end
end
