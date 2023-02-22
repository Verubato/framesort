local _, addon = ...

---Returns the set of raid frames ordered by their display order.
---Will only return frames that are visible and have a unit attached.
function addon:GetRaidFrames()
    local frames = {}

    for i = 1, MAX_RAID_MEMBERS do
        local frame = _G["CompactRaidFrame" .. i]

        if frame and not frame:IsForbidden() and frame.unit and frame.unitExists and frame:IsVisible() then
            frames[#frames + 1] = frame
        end
    end

    -- frames can and will most likely be completely out of order if a previous sort has occurred
    -- so we need to sort them
    table.sort(frames, function(x, y) return addon:CompareTopLeft(x, y) end)
    return frames
end

---Returns the set of party frames which may or may not be in order.
---Will only return frames that are visible and have a unit attached.
function addon:GetPartyFrames()
    local frames = {}
    local children = { CompactPartyFrame:GetChildren() }

    for _, frame in pairs(children) do
        if frame and not frame:IsForbidden() and frame.unit and frame.unitExists and frame:IsVisible() then
            frames[#frames + 1] = frame
        end
    end

    return frames
end
