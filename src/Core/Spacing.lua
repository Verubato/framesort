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
local function FlatPositions(frames, spacing)
    if #frames == 0 then
        return {}
    end

    local positions = {}
    local row = 1
    local yApplied = 0
    local orderedLeftTop = fsEnumerable
        :From(frames)
        :OrderBy(function(x, y)
            return fsCompare:CompareLeftTopFuzzy(x, y)
        end)
        :ToTable()

    for i = 2, #orderedLeftTop do
        local frame = orderedLeftTop[i]
        local previous = orderedLeftTop[i - 1]
        local sameColumn = fsMath:Round(frame:GetLeft()) == fsMath:Round(previous:GetLeft())

        if sameColumn then
            local spacingToAdd = row * spacing.Vertical
            positions[frame] = {
                Top = (previous:GetBottom() + yApplied) - spacingToAdd,
            }

            yApplied = yApplied + (previous:GetBottom() - frame:GetTop())
            row = row + 1
        end

        if not sameColumn then
            row = 1
            yApplied = 0
        end
    end

    local column = 1
    local xApplied = 0
    local orderedTopLeft = fsEnumerable
        :From(frames)
        :OrderBy(function(x, y)
            return fsCompare:CompareTopLeftFuzzy(x, y)
        end)
        :ToTable()

    for i = 2, #orderedTopLeft do
        local frame = orderedTopLeft[i]
        local previous = orderedTopLeft[i - 1]
        local sameRow = fsMath:Round(frame:GetTop()) == fsMath:Round(previous:GetTop())

        if sameRow then
            local position = positions[frame]
            if not position then
                position = {}
                positions[frame] = position
            end

            local spacingToAdd = column * spacing.Horizontal
            position.Left = (previous:GetRight() + xApplied) + spacingToAdd
            xApplied = xApplied + (previous:GetRight() - frame:GetLeft())
            column = column + 1
        end

        if not sameRow then
            column = 1
            xApplied = 0
        end
    end

    return positions
end

---Applies spacing to frames that are organised in 'flat' mode.
---Flat mode is where frames are all placed relative to 1 point, i.e. the parent container.
local function Flat(frames, spacing)
    if #frames == 0 then
        return
    end

    -- calculate the desired positions (with spacing added)
    local positions = FlatPositions(frames, spacing)

    for frame, to in pairs(positions) do
        local xDelta = to.Left and (to.Left - frame:GetLeft()) or 0
        local yDelta = to.Top and (to.Top - frame:GetTop()) or 0

        if xDelta ~= 0 or yDelta ~= 0 then
            frame:AdjustPointsOffset(xDelta, yDelta)
        end
    end
end

---Adjusts flat frames to ensure they sit outside the boundary
local function AdjustBoundary(frames, spacing, top, bottom, right)
    if #frames == 0 then
        return
    end

    local topLeft = fsEnumerable
        :From(frames)
        :OrderBy(function(x, y)
            return fsCompare:CompareTopLeftFuzzy(x, y)
        end)
        :First()

    if bottom then
        local yDelta = (bottom:GetBottom() - topLeft:GetTop()) - spacing.Vertical

        for _, frame in ipairs(frames) do
            frame:AdjustPointsOffset(0, yDelta)
        end
    end

    if right then
        local xDelta = spacing.Horizontal - (topLeft:GetLeft() - right:GetRight())

        for _, frame in ipairs(frames) do
            frame:AdjustPointsOffset(xDelta, 0)
        end
    end

    if top then
        local yDelta = top:GetTop() - topLeft:GetTop()

        for _, frame in ipairs(frames) do
            frame:AdjustPointsOffset(0, yDelta)
        end
    end
end

local function Chain(frames, spacing, anchor)
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

    -- ensure it's ordered
    local ordered = fsEnumerable
        :From(frames)
        :OrderBy(function(x, y)
            return fsCompare:CompareTopLeftFuzzy(x, y)
        end)
        :ToTable()

    -- calculate the desired positions (with spacing added)
    local positions = {}
    local xApplied = 0
    local yApplied = 0

    for i, frame in ipairs(ordered) do
        if i == 1 then
            positions[i] = {
                Top = frame:GetTop(),
                Left = frame:GetLeft(),
            }
        else
            local previous = ordered[i - 1]
            local isSameColumn = fsMath:Round(frame:GetLeft()) == fsMath:Round(previous:GetLeft())

            if isSameColumn then
                local spacingToAdd = (i - 1) * spacing.Vertical
                positions[i] = {
                    Top = (previous:GetBottom() + yApplied) - spacingToAdd,
                    Left = previous:GetLeft(),
                }

                yApplied = yApplied + (previous:GetBottom() - frame:GetTop())
            else
                local spacingToAdd = (i - 1) * spacing.Horizontal
                positions[i] = {
                    Top = previous:GetTop(),
                    Left = (previous:GetRight() + xApplied) + spacingToAdd,
                }

                xApplied = xApplied + (previous:GetRight() - frame:GetLeft())
            end
        end
    end

    -- apply the spacing
    local current = root
    while current do
        local frame = current.Value
        local index = fsEnumerable:From(ordered):IndexOf(frame)
        local to = positions[index]
        local xDelta = to.Left - frame:GetLeft()
        local yDelta = to.Top - frame:GetTop()

        if xDelta ~= 0 or yDelta ~= 0 then
            frame:AdjustPointsOffset(xDelta, yDelta)
        end

        current = current.Next
    end

    if not anchor then
        return
    end

    -- space the root relative to the anchor
    local rootFrame = root.Value
    local topFrame = ordered[1]
    local isSameColumn = fsMath:Round(rootFrame:GetLeft()) == fsMath:Round(anchor:GetLeft())

    if isSameColumn then
        local yDelta = (anchor:GetBottom() - topFrame:GetTop()) - spacing.Vertical
        rootFrame:AdjustPointsOffset(0, yDelta)
    else
        local xDelta = (anchor:GetLeft() - topFrame:GetLeft())
        rootFrame:AdjustPointsOffset(xDelta, 0)
    end
end

---Applies spacing to frames that are organised in 'grouped' mode.
---Grouped mode is where frames are placed relative to the frame before it within one or more groups,
---e.g.: group1: frame3 is placed relative to frame2 which is placed relative to frame 1.
---e.g.: group2: frame5 is placed relative to frame4.
local function Groups(groups, spacing)
    if #groups == 0 then
        return
    end

    table.sort(groups, function(x, y)
        return fsCompare:CompareTopLeftFuzzy(x, y)
    end)

    -- apply spacing between the groups
    for _, group in ipairs(groups) do
        local xDelta = 0
        local yDelta = 0

        -- vertical spacing
        local above = fsEnumerable
            :From(groups)
            -- grab the groups above
            :Where(function(g)
                return fsMath:Round(g:GetTop()) > fsMath:Round(group:GetTop())
            end)
            -- grab the member frames
            :Map(function(g)
                return fsFrame:GetRaidFrameGroupMembers(g)
            end)
            -- flatten members
            :Flatten()
            -- find the bottom most frame
            :Min(function(frame)
                return frame:GetBottom()
            end)

        if above then
            yDelta = above:GetBottom() - group:GetTop() - spacing.Vertical
        else
            -- no frames above us, anchor to parent
            local parent = group:GetParent()
            yDelta = parent:GetTop() - group:GetTop()
        end

        -- horizontal spacing
        local left = fsEnumerable
            :From(groups)
            -- grab the groups left
            :Where(function(g)
                return fsMath:Round(g:GetLeft()) < fsMath:Round(group:GetLeft())
            end)
            -- grab the member frames
            :Map(function(g)
                return fsFrame:GetRaidFrameGroupMembers(g)
            end)
            -- flatten members
            :Flatten()
            -- find the right most frame
            :Max(function(frame)
                return frame:GetRight()
            end)

        if left then
            xDelta = spacing.Horizontal - (group:GetLeft() - left:GetRight())
        else
            -- no frames left of us, anchor to parent
            local parent = group:GetParent()
            xDelta = group:GetLeft() - parent:GetLeft()
        end

        if xDelta ~= 0 or yDelta ~= 0 then
            group:AdjustPointsOffset(xDelta, yDelta)
        end
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

    if fsFrame:ShowPets() then
        local playerAnchor = fsEnumerable
            :From(players)
            :OrderBy(function(x, y)
                return fsCompare:CompareBottomLeftFuzzy(x, y)
            end)
            :First()

        Chain(pets, spacing, playerAnchor)
    end

    StorePreviousSpacing(container, spacing)
end

local function ApplyRaidSpacing()
    local container = CompactRaidFrameContainer
    local spacing = addon.Options.Appearance.Raid.Spacing

    if not container or not ShouldSpace(container, spacing) then
        return
    end

    local players, pets = fsFrame:GetRaidFrames()
    local together = fsFrame:KeepGroupsTogether(true)

    if not together then
        if fsFrame:ShowPets() then
            local all = fsEnumerable:From(players):Concat(pets):ToTable()
            Flat(all, spacing)
        else
            Flat(players, spacing)
        end
    else
        local groups = fsFrame:GetGroups(container)
        if #groups > 0 then
            for _, group in ipairs(groups) do
                local members = fsFrame:GetRaidFrameGroupMembers(group)
                Chain(members, spacing)
            end

            Groups(groups, spacing)
        else
            Chain(players, spacing)
        end

        if fsFrame:ShowPets() then
            Flat(pets, spacing)

            if fsFrame:HorizontalLayout(true) then
                local bottom = fsEnumerable
                    :From(groups)
                    :OrderBy(function(x, y)
                        return fsCompare:CompareBottomLeftFuzzy(x, y)
                    end)
                    :First()

                AdjustBoundary(pets, spacing, nil, bottom, nil)
            else
                local rightGroup = fsEnumerable
                    :From(groups)
                    :OrderBy(function(x, y)
                        return fsCompare:CompareTopRightFuzzy(x, y)
                    end)
                    :First()
                local top = rightGroup and fsEnumerable:From(fsFrame:GetRaidFrameGroupMembers(rightGroup)):Max(function(frame)
                    return frame:GetRight()
                end)

                AdjustBoundary(pets, spacing, top, nil, rightGroup)
            end
        end
    end

    StorePreviousSpacing(container, spacing)
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
