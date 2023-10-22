---@type string, Addon
local _, addon = ...
local fsConfig = addon.Configuration

---@class Options
fsConfig.Defaults = {
    Version = 18,
    Logging = {
        Enabled = false,
    },
    Sorting = {
        RoleOrdering = 1,
        Method = fsConfig.SortingMethod.Secure,
        Arena = {
            Enabled = true,
            PlayerSortMode = fsConfig.PlayerSortMode.Top,
            GroupSortMode = fsConfig.GroupSortMode.Group,
            Reverse = false,
        },
        EnemyArena = {
            Enabled = false,
            GroupSortMode = fsConfig.GroupSortMode.Group,
            Reverse = false,
        },
        Dungeon = {
            Enabled = true,
            PlayerSortMode = fsConfig.PlayerSortMode.Top,
            GroupSortMode = fsConfig.GroupSortMode.Role,
            Reverse = false,
        },
        World = {
            Enabled = true,
            PlayerSortMode = fsConfig.PlayerSortMode.Top,
            GroupSortMode = fsConfig.GroupSortMode.Group,
            Reverse = false,
        },
        Raid = {
            Enabled = false,
            PlayerSortMode = fsConfig.PlayerSortMode.Top,
            GroupSortMode = fsConfig.GroupSortMode.Role,
            Reverse = false,
        },
    },
    Spacing = {
        Party = {
            Horizontal = 0,
            Vertical = 0,
        },
        Raid = {
            Horizontal = 0,
            Vertical = 0,
        },
        EnemyArena = {
            Horizontal = 0,
            Vertical = 0,
        },
    },
}
