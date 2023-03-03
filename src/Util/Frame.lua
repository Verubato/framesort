local _, addon = ...

---Returns the set of raid frames ordered by their display order.
---Will only return frames that are visible and have a unit attached.
---@return table<table>,table<table>,table<table> frames member frames, pet frames, member and pet frames combined
function addon:GetRaidFrames()
    local frames = {}
    local members = {}
    local pets = {}
    local combined = {}
    local children = { CompactRaidFrameContainer:GetChildren() }

    for _, frame in pairs(children) do
        if frame and not frame:IsForbidden() and frame:IsVisible() and frame.unitExists then
            frames[#frames + 1] = frame
        elseif string.match(frame:GetName() or "", "CompactRaidGroup") then
            -- if the raid frames are separated by group
            -- then the member frames are further nested
            local groupChildren = { frame:GetChildren() }

            for _, sub in pairs(groupChildren) do
                if sub and not sub:IsForbidden() and sub:IsVisible() and sub.unitExists then
                    frames[#frames + 1] = sub
                end
            end
        end
    end

    for _, frame in pairs(frames) do
        if addon:IsMember(frame.unit) then
            members[#members + 1] = frame
            combined[#combined + 1] = frame
        elseif addon:IsPet(frame.unit) then
            pets[#pets + 1] = frame
            combined[#combined + 1] = frame
        else
            addon:Debug("Unknown unit type: " .. frame.unit)
        end
    end

    -- frames can and will most likely be completely out of order if a previous sort has occurred
    -- so we need to sort them
    table.sort(members, function(x, y) return addon:CompareTopLeft(x, y) end)
    table.sort(pets, function(x, y) return addon:CompareTopLeft(x, y) end)
    table.sort(combined, function(x, y) return addon:CompareTopLeft(x, y) end)

    return members, pets, combined
end

---Returns the raid frame group frames.
---@return table<table> frames group frames
function addon:GetRaidFrameGroups()
    local frames = {}
    local children = { CompactRaidFrameContainer:GetChildren() }

    for _, frame in pairs(children) do
        if string.match(frame:GetName() or "", "CompactRaidGroup") then
            frames[#frames + 1] = frame
        end
    end

    table.sort(frames, function(x, y) return addon:CompareTopLeft(x, y) end)
    return frames
end

---Returns the member frames within a raid group frame.
---@return table<table> frames group frames
function addon:GetRaidFrameGroupMembers(group)
    local frames = { group:GetChildren() }
    local members = {}

    for _, frame in ipairs(frames) do
        if frame.unitExists then
            members[#members + 1] = frame
        end
    end

    return members
end

---Returns the set of party frames ordered by their display order.
---Will only return frames that are visible and have a unit attached.
---@return table<table> frames party frames
function addon:GetPartyFrames()
    local frames = {}
    local children = { CompactPartyFrame:GetChildren() }

    for _, frame in pairs(children) do
        if frame and not frame:IsForbidden() and frame.unit and frame.unitExists and frame:IsVisible() then
            frames[#frames + 1] = frame
        end
    end

    table.sort(frames, function(x, y) return addon:CompareTopLeft(x, y) end)

    return frames
end
