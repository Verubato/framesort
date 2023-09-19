---@type string, Addon
local _, addon = ...

---@class LayoutStrategy
addon.Configuration.LayoutStrategy = {
    ---Move frames by only adjusting their X/Y offsets so as to not disturb the anchor points.
    Soft = 1,
    ---Move frames by potentially completely changing their anchor points.
    Hard = 2
}
