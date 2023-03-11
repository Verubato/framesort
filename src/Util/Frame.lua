local _, addon = ...

---Returns the set of visible raid frames.
---@return table<table>,table<table>,table<table> frames member frames, pet frames, member and pet frames combined
function addon:GetRaidFrames()
    local container = CompactRaidFrameContainer

    if not container then return {}, {}, {} end
    if container:IsForbidden() or not container:IsVisible() then return {}, {}, {} end

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

    return members, pets, combined
end

---Returns the set of visible raid frame group frames.
---@return table<table> frames group frames
function addon:GetRaidFrameGroups()
    local frames = {}
    local container = CompactRaidFrameContainer

    if not container then return frames end
    if container:IsForbidden() or not container:IsVisible() then return frames end

    local children = { container:GetChildren() }

    for _, frame in pairs(children) do
        if not frame:IsForbidden() and frame:IsVisible() and string.match(frame:GetName() or "", "CompactRaidGroup") then
            frames[#frames + 1] = frame
        end
    end

    return frames
end

---Returns the set of visible member frames within a raid group frame.
---@return table<table> frames group frames
function addon:GetRaidFrameGroupMembers(group)
    local frames = { group:GetChildren() }
    local members = {}

    for _, frame in ipairs(frames) do
        if frame and not frame:IsForbidden() and frame:IsVisible() and frame.unitExists then
            members[#members + 1] = frame
        end
    end

    return members
end

---Returns the set of visible party frames.
---@return table<table> frames party frames
function addon:GetPartyFrames()
    local frames = {}
    local container = CompactPartyFrame

    if not container then return frames end
    if container:IsForbidden() or not container:IsVisible() then return frames end

    if not CompactPartyFrame then
        return frames
    end

    local children = { container:GetChildren() }

    for _, frame in pairs(children) do
        if frame and not frame:IsForbidden() and frame.unit and frame.unitExists and frame:IsVisible() then
            frames[#frames + 1] = frame
        end
    end

    return frames
end
