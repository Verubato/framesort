---@type string, Addon
local _, addon = ...
local fsConfig = addon.Configuration

---@class DbDefaults
fsConfig.DbDefaults = {
    SpecCache = {},

    ---@class Options
    Options = {
        Version = 23,
        Sorting = {
            Ordering = {
                Tanks = 1,
                Healers = 2,
                Casters = 3,
                Hunters = 4,
                Melee = 5,
            },
            Method = fsConfig.SortingMethod.Secure,
            SpecPriority = {
                Tanks = {},
                Healers = {},
                Hunters = {},
                Melee = {},
                Casters = {},
            },
            Arena = {
                Twos = {
                    Enabled = true,
                    PlayerSortMode = fsConfig.PlayerSortMode.Top,
                    GroupSortMode = fsConfig.GroupSortMode.Group,
                    Reverse = false,
                },
                Default = {
                    Enabled = true,
                    PlayerSortMode = fsConfig.PlayerSortMode.Top,
                    GroupSortMode = fsConfig.GroupSortMode.Group,
                    Reverse = false,
                },
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
        AutoLeader = {
            Enabled = true,
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
        Nameplates = {
            FriendlyEnabled = false,
            EnemyEnabled = false,
            FriendlyFormat = "$framenumber",
            EnemyFormat = "$framenumber",
        },
    },
}
