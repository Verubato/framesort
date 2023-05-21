local _, addon = ...

---Returns the set of visible unit tokens ordered by their visual representation.
function addon:GetVisuallyOrderedUnits()
    local frames = addon:GetPartyFrames()

    if #frames == 0 then
        frames = addon:GetRaidFrames()
    end

    -- for some reason frames can be off by tiny amounts but they look visually aligned
    -- so do a fuzzy compare to ignore any minor x/y differences
    return addon.Enumerable
        :From(frames)
        :OrderBy(function(x, y) return addon:CompareTopLeftFuzzy(x, y) end)
        :Map(function(x) return x.unit end)
        :ToTable()
end
