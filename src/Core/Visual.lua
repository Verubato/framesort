local _, addon = ...

---Returns the set of visible unit frames, ordered by their visual representation.
function addon:GetVisuallyOrderedFrames()
    local party = addon:GetPartyFrames()
    local frames = nil

    if party and #party > 0 then
        frames = party
    else
        frames = addon:GetRaidFrames()
    end

    if not frames or #frames == 0 then
        return {}
    end

    table.sort(frames, function(x, y) return addon:CompareTopLeft(x, y) end)

    return frames
end

---Returns the set of visible unit tokens, ordered by their visual representation.
function addon:GetVisuallyOrderedUnits()
    local frames = addon:GetVisuallyOrderedFrames()
    local units = {}

    for _, frame in ipairs(frames) do
        print(frame.unit)
        units[#units + 1] = frame.unit
    end

    return units
end
