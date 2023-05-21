local _, addon = ...

local function ExtractFrames(children, includeInvisible)
    local frames = {}
    for _, frame in pairs(children) do
        if frame and not frame:IsForbidden() and (includeInvisible or frame:IsVisible()) and frame.unitExists then
            frames[#frames + 1] = frame
        elseif string.match(frame:GetName() or "", "CompactRaidGroup") then
            -- if the raid frames are separated by group
            -- then the member frames are further nested
            local groupChildren = { frame:GetChildren() }

            for _, sub in pairs(groupChildren) do
                if sub and not sub:IsForbidden() and (includeInvisible or sub:IsVisible()) and sub.unitExists then
                    frames[#frames + 1] = sub
                end
            end
        end
    end

    return frames
end

---Returns the set of raid frames.
---@param includeInvisible boolean true to include invisible frames, otherwise false.
---@return Enumerable<table>,Enumerable<table> frames member frames, pet frames
function addon:GetRaidFrames(includeInvisible)
    local empty = addon.Enumerable:Empty():ToTable()
    local container = CompactRaidFrameContainer

    if not container then return empty, empty end
    if container:IsForbidden() or not container:IsVisible() then return empty, empty end

    local children = { CompactRaidFrameContainer:GetChildren() }
    local frames = ExtractFrames(children, includeInvisible)
    local members = addon.Enumerable:From(frames)
        :Where(function(x) return addon:IsMember(x.unit) end)
    local pets = addon.Enumerable:From(frames)
        :Where(function(x) return addon:IsPet(x.unit) end)

    return members:ToTable(), pets:ToTable()
end

---Returns the set of raid frame group frames.
---@param includeInvisible boolean true to include invisible frames, otherwise false.
---@return table<table> frames group frames
function addon:GetRaidFrameGroups(includeInvisible)
    local empty = addon.Enumerable:Empty():ToTable()
    local container = CompactRaidFrameContainer

    if not container then return empty end
    if container:IsForbidden() or not container:IsVisible() then return empty end

    return addon.Enumerable
        :From({ container:GetChildren() })
        :Where(function(frame)
            return
                not frame:IsForbidden()
                and (includeInvisible or frame:IsVisible())
                and string.match(frame:GetName() or "", "CompactRaidGroup")
        end)
        :ToTable()
end

---Returns the set of visible member frames within a raid group frame.
---@param includeInvisible boolean true to include invisible frames, otherwise false.
---@return table<table> frames group frames
function addon:GetRaidFrameGroupMembers(group, includeInvisible)
    return addon.Enumerable
        :From({ group:GetChildren() })
        :Where(function(frame)
            return
                frame
                and not frame:IsForbidden()
                and (includeInvisible or frame:IsVisible())
                and frame.unitExists
        end)
        :ToTable()
end

---Returns the set of visible party frames.
---@param includeInvisible boolean true to include invisible frames, otherwise false.
---@return table<table> frames party frames
function addon:GetPartyFrames(includeInvisible)
    local empty = addon.Enumerable:Empty():ToTable()
    local container = CompactPartyFrame

    if not container then return empty end
    if container:IsForbidden() or not container:IsVisible() then return empty end

    return addon.Enumerable
        :From({ container:GetChildren() })
        :Where(function(frame)
            return
                frame
                and not frame:IsForbidden()
                and frame.unitExists
                and (includeInvisible or frame:IsVisible())
        end)
        :ToTable()
end

---Returns the player compact raid frame.
---@return table? playerFrame
function addon:GetPlayerFrame()
    local frames = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE and addon:GetPartyFrames(true) or nil

    if not frames or #frames == 0 then
        frames = addon:GetRaidFrames(true)
    end

    -- find the player frame
    return addon.Enumerable
        :From(frames)
        :First(function(frame) return UnitIsUnit("player", frame.unit) end)
end

---Returns the frames in order of their relative positioning to each other.
---@param frames table<table> frames in any particular order
---@return LinkedListNode root in order of parent -> child -> child -> child
function addon:ToFrameChain(frames)
    local empty = addon.Enumerable:Empty():ToTable()
    local nodesByFrame = addon.Enumerable
        :From(frames)
        :ToLookup(function(frame) return frame end, function(frame)
            return {
                Next = nil,
                Previous = nil,
                Value = frame
            }
        end)

    local root = nil
    for _, child in pairs(nodesByFrame) do
        local _, relativeTo, _, _, _ = child.Value:GetPoint()
        local parent = nodesByFrame[relativeTo]

        if parent then
            if parent.Next then
                addon:Error(string.format("Encountered multiple children for frame %s in frame frame chain.", parent.Value:GetName()))
                return empty
            end

            parent.Next = child
            child.Previous = parent
        else
            root = child
        end
    end

    -- assert we have a complete chain
    local count = 0
    local current = root

    while current do
        count = count + 1
        current = current.Next
    end

    if count ~= #frames then
        addon:Error(string.format("Incomplete/broken frame chain: expected %d nodes but only found %d", #frames, count))
        return empty
    end

    return root
end
