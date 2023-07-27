local _, addon = ...

---@alias GroupSortMode
---| "Group"
---| "Role"
---| "Alphabetical"


addon.GroupSortMode = {
    Group = "Group",
    Role = "Role",
    Alphabetical = "Alphabetical",
}

---@alias PlayerSortMode
---| "Top"
---| "Middle"
---| "Bottom"
---| "Hidden"

addon.PlayerSortMode = {
    Top = "Top",
    Middle = "Middle",
    Bottom = "Bottom",
    Hidden = "Hidden",
}
