local _, addon = ...
local fsFrame = addon.Frame
local fsCompare = addon.Compare
local M = {}
addon.Visual = M

---Returns the set of visible unit tokens ordered by their visual representation.
function M:GetVisuallyOrderedUnits()
    local frames = fsFrame:GetPartyFrames()

    if #frames == 0 then
        frames = fsFrame:GetRaidFrames()
    end

    -- for some reason frames can be off by tiny amounts but they look visually aligned
    -- so do a fuzzy compare to ignore any minor x/y differences
    return addon.Enumerable
        :From(frames)
        :OrderBy(function(x, y) return fsCompare:CompareTopLeftFuzzy(x, y) end)
        :Map(function(x) return x.unit end)
        :ToTable()
end
