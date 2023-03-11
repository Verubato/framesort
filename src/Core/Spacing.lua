local _, addon = ...

--- Applies spacing to frames that are organised in 'flat' mode.
--- Flat mode is where frames are all placed relative to 1 point, i.e. the parent container.
local function FlatMode(frames, spacing)
    local xDelta = 0
    local yDelta = 0
    local previousPos = nil

    -- iterate over the frames from top left to bottom right
    table.sort(frames, function(x, y) return addon:CompareTopLeft(x, y) end)

    for i, current in ipairs(frames) do
        local previous = i > 1 and frames[i - 1] or nil

        if previous then
            local isNewRow = ((current:GetLeft() or 0) < previousPos.left) or ((current:GetTop() or 0) < previousPos.top)
            local isPetAfterPet = addon:IsPet(current.unit) and addon:IsPet(previous.unit)

            if isPetAfterPet then
                -- TODO: get pet spacing to work
                -- pets are such a pain to add spacing to
                -- so just ignore them for now
            elseif not isNewRow then
                -- we're within the same row
                -- subtract existing spacing
                xDelta = spacing.Horizontal - ((current:GetLeft() or 0) - (previous:GetRight() or 0))
            elseif isNewRow then
                -- we've hit a new row
                -- subtract existing vertical spacing
                yDelta = spacing.Vertical + ((current:GetTop() or 0) - (previous:GetBottom() or 0))
                -- reset the horizontal spacing
                xDelta = 0
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

local function FlatModePets(pets, spacing, horizontal, relativeTo)
    if #pets == 0 then return end

    -- move pet frames as if they were a group
    local xOffset = 0
    local yOffset = 0

    if horizontal then
        yOffset = (relativeTo:GetBottom() - pets[1]:GetTop()) - spacing.Vertical
    else
        xOffset = (relativeTo:GetRight() - pets[1]:GetLeft()) + spacing.Horizontal

        -- in vertical mode, blizzard doesn't align the pet frame nicely
        yOffset = relativeTo:GetTop() - pets[1]:GetTop()
    end

    for _, pet in pairs(pets) do
        pet:AdjustPointsOffset(xOffset, yOffset)
    end

    FlatMode(pets, spacing)
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
    local petsReferencePoint = groups[1]
    local previousGroupMembers = nil

    table.sort(groups, function(x, y) return addon:CompareTopLeft(x, y) end)

    if pets then
        table.sort(pets, function(x, y) return addon:CompareTopLeft(x, y) end)
    end

    for i, group in ipairs(groups) do
        local previous = i > 1 and groups[i - 1] or nil
        local members = addon:GetRaidFrameGroupMembers(group)

        if previous then
            local xDelta = 0
            local yDelta = 0

            if horizontal then
                if group:GetLeft() == previous:GetLeft() then
                    -- add vertical spacing between each group
                    yDelta = ((i - 1) * spacing.Vertical) + (group:GetTop() - previous:GetBottom())
                end

                if group:GetTop() <= previous:GetTop() then
                    petsReferencePoint = members[1]
                end
            else
                if group:GetLeft() >= previous:GetLeft() then
                    petsReferencePoint = members[1]
                end

                -- add horizontal spacing between each group
                if group:GetTop() == previous:GetTop() then
                    xDelta = ((i - 1) * spacing.Horizontal) - (group:GetLeft() - previous:GetRight())
                elseif not horizontal and previousGroupMembers and #previousGroupMembers > 0 then
                    local lastPreviousGroupMember = previousGroupMembers[#previousGroupMembers]
                    yDelta = ((i - 1) * spacing.Vertical) + (group:GetTop() - lastPreviousGroupMember:GetBottom())
                end
            end

            group:AdjustPointsOffset(xDelta, -yDelta)
        end

        previousGroupMembers = members
        GroupedModeMembers(members, spacing, horizontal)
    end

    if pets and #pets > 0 then
        FlatModePets(pets, spacing, horizontal, petsReferencePoint)
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

    table.sort(frames, function(x, y) return addon:CompareTopLeft(x, y) end)
    local flat, horizontal, showPets, spacing = GetSettings(false)

    addon:Debug("Applying party frame spacing (" .. (horizontal and "horizontal" or "vertical") .. " layout).")

    GroupedModeMembers(frames, spacing, horizontal)

    if not flat and showPets then
        local _, pets, _ = addon:GetRaidFrames()
        FlatModePets(pets, spacing, horizontal, frames[1])
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

---Event hook on blizzard performing frame layouts.
local function OnLayout(container)
    if not container or container:IsForbidden() or not container:IsVisible() then return end
    if container ~= CompactRaidFrameContainer then return end
    if container.flowPauseUpdates then return end

    addon:ApplySpacing()
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

---Initialises the spacing module.
function addon:InitSpacing()
    hooksecurefunc("FlowContainer_DoLayout", OnLayout)
end
