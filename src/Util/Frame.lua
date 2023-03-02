local _, addon = ...

---Returns the set of raid frames ordered by their display order.
---Will only return frames that are visible and have a unit attached.
---@return table<table>,table<table>,table<table> frames member frames, pet frames, unknown frames
function addon:GetRaidFrames()
    local members = {}
    local pets = {}
    local unknown = {}

    for i = 1, MAX_RAID_MEMBERS do
        local frame = _G["CompactRaidFrame" .. i]

        if frame and not frame:IsForbidden() and frame:IsVisible() and frame.unitExists then
            if addon:IsMember(frame.unit) then
                members[#members + 1] = frame
            elseif addon:IsPet(frame.unit) then
                pets[#pets + 1] = frame
            else
                unknown[#unknown + 1] = frame
            end
        end
    end

    -- frames can and will most likely be completely out of order if a previous sort has occurred
    -- so we need to sort them
    table.sort(members, function(x, y) return addon:CompareTopLeft(x, y) end)
    table.sort(pets, function(x, y) return addon:CompareTopLeft(x, y) end)
    return members, pets, unknown
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
