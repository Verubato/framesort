local _, addon = ...
local fsSort = addon.Sorting
local fsFrame = addon.Frame
local fsCompare = addon.Compare
local fsPoint = addon.Point
local fsMath = addon.Math
local fsEnumerable = addon.Enumerable
local previousSpacing = {}
local M = {}
addon.Spacing = M

---Applies spacing to frames that are organised in 'flat' mode.
---Flat mode is where frames are all placed relative to 1 point, i.e. the parent container.
local function FlatMembers(frames, spacing)
    if #frames == 0 then
        return
    end

    local orderedLeftTop = fsEnumerable
        :From(frames)
        :OrderBy(function(x, y)
            return fsCompare:CompareLeftTopFuzzy(x, y)
        end)
        :ToTable()

    for i = 2, #orderedLeftTop do
        local frame = orderedLeftTop[i]
        local previous = orderedLeftTop[i - 1]
        local yDelta = 0

        -- same column
        if fsMath:Round(frame:GetLeft()) == fsMath:Round(previous:GetLeft()) then
            yDelta = (previous:GetBottom() - frame:GetTop()) - spacing.Vertical
        end

        if yDelta ~= 0 then
            frame:AdjustPointsOffset(0, yDelta)
        end
    end

    local orderedTopLeft = fsEnumerable
        :From(frames)
        :OrderBy(function(x, y)
            return fsCompare:CompareTopLeftFuzzy(x, y)
        end)
        :ToTable()

    for i = 2, #orderedTopLeft do
        local frame = orderedTopLeft[i]
        local previous = orderedTopLeft[i - 1]
        local xDelta = 0

        -- same row
        if fsMath:Round(frame:GetTop()) == fsMath:Round(previous:GetTop()) then
            xDelta = spacing.Horizontal - (frame:GetLeft() - previous:GetRight())
        end

        if xDelta ~= 0 then
            frame:AdjustPointsOffset(xDelta, 0)
        end
    end
end

local function Pets(pets, members, spacing, horizontal)
    if #pets == 0 or #members == 0 then
        return
    end

    table.sort(pets, function(x, y)
        return fsCompare:CompareTopLeftFuzzy(x, y)
    end)

    local firstPet = pets[1]
    local firstPetPoint = fsPoint:GetPointEx(firstPet)
    local parent = firstPet:GetParent()
    local placeHorizontal = horizontal
    local hasMoreThanOneRow = fsEnumerable:From(members):Any(function(x)
        return fsMath:Round(x:GetBottom()) > fsMath:Round(members[1]:GetBottom())
    end)
    local hasMoreThanOneColumn = fsEnumerable:From(members):Any(function(x)
        return fsMath:Round(x:GetLeft()) > fsMath:Round(members[1]:GetLeft())
    end)

    if horizontal and hasMoreThanOneRow then
        placeHorizontal = false
    elseif not horizontal and hasMoreThanOneColumn then
        placeHorizontal = true
    end

    if placeHorizontal then
        local topRight = fsEnumerable
            :From(members)
            :OrderBy(function(x, y)
                return fsCompare:CompareTopRightFuzzy(x, y)
            end)
            :First(function(x)
                return x:IsVisible()
            end)

        if not topRight then
            return
        end

        local top, left = fsPoint:RelativeTopLeft(topRight, parent)
        local xDelta = left - (firstPetPoint.offsetX - topRight:GetWidth() - spacing.Horizontal)
        local yDelta = top - firstPetPoint.offsetY

        if xDelta ~= 0 or yDelta ~= 0 then
            firstPet:AdjustPointsOffset(xDelta, yDelta)
        end
    else
        local bottomLeft = fsEnumerable
            :From(members)
            :OrderBy(function(x, y)
                return fsCompare:CompareBottomLeftFuzzy(x, y)
            end)
            :First(function(x)
                return x:IsVisible()
            end)

        if not bottomLeft then
            return
        end

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
        local addSpacing = i % petsPerRaidFrame == 1
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
    local currentSpacing = 0

    for i, frame in ipairs(ordered) do
        if i == 1 then
            positions[i] = {
                Top = frame:GetTop(),
                Left = frame:GetLeft(),
            }
        else
            local previous = ordered[i - 1]

            if horizontal then
                local spacingToAdd = (i - 1) * spacing.Horizontal
                positions[i] = {
                    Top = previous:GetTop(),
                    Left = (previous:GetRight() + currentSpacing) + spacingToAdd,
                }

                currentSpacing = currentSpacing + (previous:GetRight() - frame:GetLeft())
            else
                local spacingToAdd = (i - 1) * spacing.Vertical
                positions[i] = {
                    Top = (previous:GetBottom() + currentSpacing) - spacingToAdd,
                    Left = previous:GetLeft(),
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
        local xDelta = to.Left - frame:GetLeft()
        local yDelta = to.Top - frame:GetTop()

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
    if #groups == 0 then
        return
    end

    table.sort(groups, function(x, y)
        return fsCompare:CompareTopLeftFuzzy(x, y)
    end)

    --- apply spacing to the member frames
    for _, group in ipairs(groups) do
        local members = fsFrame:GetRaidFrameGroupMembers(group)
        GroupedMembers(members, spacing, horizontal)
    end

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
            -- only consider visible frames
            :Where(function(frame)
                return frame:IsVisible()
            end)
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
            -- only consider visible frames
            :Where(function(frame)
                return frame:IsVisible()
            end)
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

local function ApplySpacing(container, petsContainer, spacing, together, horizontal, showPets)
    local players = fsFrame:GetUnitFrames(container)

    if together then
        local groups = fsFrame:GetGroups(container)
        if #groups ~= 0 then
            Groups(groups, spacing, horizontal)
        else
            GroupedMembers(players, spacing, horizontal)
        end
    else
        FlatMembers(players, spacing)
    end

    if showPets then
        local _, pets = fsFrame:GetUnitFrames(petsContainer or container)
        Pets(pets, players, spacing, horizontal)
    end
end

---Applies spacing to party and raid frames.
function M:ApplySpacing()
    local containers = {
        {
            container = CompactPartyFrame,
            spacing = WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE and addon.Options.Appearance.Raid.Spacing or addon.Options.Appearance.Party.Spacing,
            petsContainer = CompactRaidFrameContainer,
            together = fsFrame:KeepGroupsTogether(false),
            horizontal = fsFrame:HorizontalLayout(false),
            showPets = fsFrame:ShowPets(),
        },
        {
            container = CompactRaidFrameContainer,
            spacing = addon.Options.Appearance.Raid.Spacing,
            together = fsFrame:KeepGroupsTogether(true),
            horizontal = fsFrame:HorizontalLayout(true),
            showPets = fsFrame:ShowPets(),
        },
        {
            container = CompactArenaFrame,
            spacing = addon.Options.Appearance.EnemyArena.Spacing,
            together = false,
            horizontal = false,
            showPets = true,
        },
    }

    for _, x in ipairs(containers) do
        if x.container then
            local zeroSpacing = x.spacing.Horizontal == 0 and x.spacing.Vertical == 0
            local previous = previousSpacing[x.container]
            local previousNonZero = previous and (previous.Horizontal ~= 0 or previous.Vertical ~= 0)

            -- avoid applying 0 spacing
            if previousNonZero or not zeroSpacing then
                ApplySpacing(x.container, x.petsContainer, x.spacing, x.together, x.horizontal, x.showPets)
                previousSpacing[x.container] = {
                    Horizontal = x.spacing.Horizontal,
                    Vertical = x.spacing.Vertical,
                }
            end
        end
    end
end

local function Run()
    M:ApplySpacing()
end

---Initialises the spacing module.
function addon:InitSpacing()
    fsSort:RegisterPostSortCallback(Run)

    if CompactParyFrame then
        hooksecurefunc(CompactArenaFrame, "UpdateLayout", Run)
    end

    if CompactRaidFrameContainer then
        if CompactRaidFrameContainer.LayoutFrames then
            hooksecurefunc(CompactRaidFrameContainer, "LayoutFrames", Run)
        elseif CompactRaidFrameContainer_LayoutFrames then
            hooksecurefunc("CompactRaidFrameContainer_LayoutFrames", Run)
        end

        if CompactRaidFrameContainer.OnSizeChanged then
            hooksecurefunc(CompactRaidFrameContainer, "OnSizeChanged", Run)
        elseif CompactRaidFrameContainer_OnSizeChanged then
            hooksecurefunc("CompactRaidFrameContainer_OnSizeChanged", Run)
        end
    end

    if CompactArenaFrame then
        hooksecurefunc(CompactArenaFrame, "UpdateLayout", Run)
    end
end
