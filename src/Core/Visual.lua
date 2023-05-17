local _, addon = ...

---Returns the set of visible unit frames ordered by their visual representation.
local function GetVisuallyOrderedFrames()
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

    -- for some reason frames can be off by tiny amounts but they look visually aligned
    -- so do a fuzzy compare to ignore any minor x/y differences
    table.sort(frames, function(x, y) return addon:CompareTopLeftFuzzy(x, y) end)

    return frames
end

---Returns the set of visible unit tokens ordered by their visual representation.
function addon:GetVisuallyOrderedUnits()
    local frames = GetVisuallyOrderedFrames()
    local units = {}

    for _, frame in ipairs(frames) do
        units[#units + 1] = frame.unit
    end

    return units
end
