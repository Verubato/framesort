---@type string, Addon
local _, addon = ...

---@class GroupSortMode
addon.Configuration.GroupSortMode = {
    Group = "Group",
    Role = "Role",
    Alphabetical = "Alphabetical",
}

---@class PlayerSortMode
addon.Configuration.PlayerSortMode = {
    Top = "Top",
    Middle = "Middle",
    Bottom = "Bottom",
    Hidden = "Hidden",
}
