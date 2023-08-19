---@type string, Addon
local _, addon = ...
local fsConfig = addon.Configuration

---@class Options
fsConfig.Defaults = {
    Version = 12,
    Logging = {
        Enabled = false,
    },
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
    SortingMethod = {
        TaintlessEnabled = true,
        TraditionalEnabled = false,
    },
    Appearance = {
        Party = {
            Spacing = {
                Horizontal = 0,
                Vertical = 0,
            },
        },
        Raid = {
            Spacing = {
                Horizontal = 0,
                Vertical = 0,
            },
        },
        EnemyArena = {
            Spacing = {
                Horizontal = 0,
                Vertical = 0,
            },
        },
    },
}
