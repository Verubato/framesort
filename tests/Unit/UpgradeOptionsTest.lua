local deps = {
    "Type\\SortMode.lua",
    "Config\\Upgrader.lua",
    "Config\\Defaults.lua",
}

local addon = {}
local helper = require("Helper")
helper:LoadDependencies(addon, deps)

local upgrader = addon.OptionsUpgrader
local M = {}

function M:test_upgrade_options_version2()
    local options = {
        PlayerSortMode = "Top",
        RaidSortMode = "Role",
        PartySortMode = "Group",
        RaidSortEnabled = false,
        PartySortEnabled = true,
    }

    local expected = {
        ArenaEnabled = true,
        ArenaPlayerSortMode = "Top",
        ArenaSortMode = "Group",
        DungeonEnabled = true,
        DungeonPlayerSortMode = "Top",
        DungeonSortMode = "Group",
        WorldEnabled = true,
        WorldPlayerSortMode = "Top",
        WorldSortMode = "Group",
        RaidEnabled = false,
        RaidSortMode = "Role",
        RaidPlayerSortMode = "Top",
        DebugEnabled = false,
        Version = 2,
    }

    upgrader:UpgradeToVersion2(options)
    assertEquals(options, expected)
end

function M:test_upgrade_options_version3()
    local options = {
        ArenaEnabled = true,
        ArenaPlayerSortMode = "Top",
        ArenaSortMode = "Group",
        DungeonEnabled = true,
        DungeonPlayerSortMode = "Top",
        DungeonSortMode = "Group",
        WorldEnabled = true,
        WorldPlayerSortMode = "Top",
        WorldSortMode = "Group",
        RaidEnabled = false,
        RaidSortMode = "Role",
        RaidPlayerSortMode = "Top",
        DebugEnabled = false,
        Version = 2,
    }

    local expected = {
        ArenaEnabled = true,
        ArenaPlayerSortMode = "Top",
        ArenaSortMode = "Group",
        DungeonEnabled = true,
        DungeonPlayerSortMode = "Top",
        DungeonSortMode = "Group",
        WorldEnabled = true,
        WorldPlayerSortMode = "Top",
        WorldSortMode = "Group",
        RaidEnabled = false,
        RaidSortMode = "Role",
        RaidPlayerSortMode = "Top",
        DebugEnabled = false,
        ExperimentalEnabled = false,
        Version = 3,
    }

    upgrader:UpgradeToVersion3(options)
    assertEquals(options, expected)
end

function M:test_upgrade_options_version4()
    local options = {
        ArenaEnabled = true,
        ArenaPlayerSortMode = "Top",
        ArenaSortMode = "Group",
        DungeonEnabled = true,
        DungeonPlayerSortMode = "Top",
        DungeonSortMode = "Group",
        WorldEnabled = true,
        WorldPlayerSortMode = "Top",
        WorldSortMode = "Group",
        RaidEnabled = false,
        RaidSortMode = "Role",
        RaidPlayerSortMode = "Top",
        DebugEnabled = false,
        ExperimentalEnabled = false,
        Version = 3,
    }

    local expected = {
        ArenaEnabled = true,
        ArenaPlayerSortMode = "Top",
        ArenaSortMode = "Group",
        DungeonEnabled = true,
        DungeonPlayerSortMode = "Top",
        DungeonSortMode = "Group",
        WorldEnabled = true,
        WorldPlayerSortMode = "Top",
        WorldSortMode = "Group",
        RaidEnabled = false,
        RaidSortMode = "Role",
        RaidPlayerSortMode = "Top",
        DebugEnabled = false,
        ExperimentalEnabled = false,
        SortingMethod = {
            TaintlessEnabled = true,
            TraditionalEnabled = false,
        },
        Version = 4,
    }

    upgrader:UpgradeToVersion4(options)
    assertEquals(options, expected)
end

function M:test_upgrade_options_version5()
    local options = {
        ArenaEnabled = true,
        ArenaPlayerSortMode = "Top",
        ArenaSortMode = "Group",
        DungeonEnabled = true,
        DungeonPlayerSortMode = "Top",
        DungeonSortMode = "Group",
        WorldEnabled = true,
        WorldPlayerSortMode = "Top",
        WorldSortMode = "Group",
        RaidEnabled = false,
        RaidSortMode = "Role",
        RaidPlayerSortMode = "Top",
        DebugEnabled = false,
        PartySortEnabled = nil,
        PlayerSortMode = nil,
        RaidSortEnabled = nil,
        ExperimentalEnabled = false,
        SortingMethod = {
            TaintlessEnabled = true,
            TraditionalEnabled = false,
        },
        Version = 4,
    }

    local expected = {
        Arena = {
            Enabled = true,
            PlayerSortMode = "Top",
            GroupSortMode = "Group",
        },
        Dungeon = {
            Enabled = true,
            PlayerSortMode = "Top",
            GroupSortMode = "Group",
        },
        World = {
            Enabled = true,
            PlayerSortMode = "Top",
            GroupSortMode = "Group",
        },
        Raid = {
            Enabled = false,
            PlayerSortMode = "Top",
            GroupSortMode = "Role",
        },
        Debug = { Enabled = false },
        SortingMethod = {
            TaintlessEnabled = true,
            TraditionalEnabled = false,
        },
        Version = 5,
    }

    upgrader:UpgradeToVersion5(options)
    assertEquals(options, expected)
end

function M:test_upgrade_options_version6()
    local options = {
        Arena = {
            Enabled = true,
            PlayerSortMode = "Top",
            GroupSortMode = "Group",
        },
        Dungeon = {
            Enabled = true,
            PlayerSortMode = "Top",
            GroupSortMode = "Group",
        },
        World = {
            Enabled = true,
            PlayerSortMode = "Top",
            GroupSortMode = "Group",
        },
        Raid = {
            Enabled = false,
            PlayerSortMode = "Top",
            GroupSortMode = "Role",
        },
        Debug = { Enabled = false },
        SortingMethod = {
            TaintlessEnabled = true,
            TraditionalEnabled = false,
        },
        Version = 5,
    }

    local expected = {
        Arena = {
            Enabled = true,
            PlayerSortMode = "Top",
            GroupSortMode = "Group",
        },
        Dungeon = {
            Enabled = true,
            PlayerSortMode = "Top",
            GroupSortMode = "Group",
        },
        World = {
            Enabled = true,
            PlayerSortMode = "Top",
            GroupSortMode = "Group",
        },
        Raid = {
            Enabled = false,
            PlayerSortMode = "Top",
            GroupSortMode = "Role",
        },
        Debug = { Enabled = false },
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
        },
        Version = 6,
    }

    upgrader:UpgradeToVersion6(options)
    assertEquals(options, expected)
end

function M:test_upgrade_options_version7()
    local options = {
        Arena = {
            Enabled = true,
            PlayerSortMode = "Top",
            GroupSortMode = "Group",
        },
        Dungeon = {
            Enabled = true,
            PlayerSortMode = "Top",
            GroupSortMode = "Group",
        },
        World = {
            Enabled = true,
            PlayerSortMode = "Top",
            GroupSortMode = "Group",
        },
        Raid = {
            Enabled = false,
            PlayerSortMode = "Top",
            GroupSortMode = "Role",
        },
        Debug = { Enabled = true },
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
        },
        Version = 6,
    }

    local expected = {
        Arena = {
            Enabled = true,
            PlayerSortMode = "Top",
            GroupSortMode = "Group",
        },
        Dungeon = {
            Enabled = true,
            PlayerSortMode = "Top",
            GroupSortMode = "Group",
        },
        World = {
            Enabled = true,
            PlayerSortMode = "Top",
            GroupSortMode = "Group",
        },
        Raid = {
            Enabled = false,
            PlayerSortMode = "Top",
            GroupSortMode = "Role",
        },
        Debug = { Enabled = false },
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
        },
        Version = 7,
    }

    upgrader:UpgradeToVersion7(options)
    assertEquals(options, expected)
end

function M:test_upgrade_options_version8()
    local options = {
        Arena = {
            Enabled = true,
            PlayerSortMode = "Top",
            GroupSortMode = "Group",
        },
        Dungeon = {
            Enabled = true,
            PlayerSortMode = "Top",
            GroupSortMode = "Group",
        },
        World = {
            Enabled = true,
            PlayerSortMode = "Top",
            GroupSortMode = "Group",
        },
        Raid = {
            Enabled = false,
            PlayerSortMode = "Top",
            GroupSortMode = "Role",
        },
        Debug = { Enabled = false },
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
        },
        Version = 7,
    }

    local expected = {
        Arena = {
            Enabled = true,
            PlayerSortMode = "Top",
            GroupSortMode = "Group",
            Reverse = false,
        },
        Dungeon = {
            Enabled = true,
            PlayerSortMode = "Top",
            GroupSortMode = "Group",
            Reverse = false,
        },
        World = {
            Enabled = true,
            PlayerSortMode = "Top",
            GroupSortMode = "Group",
            Reverse = false,
        },
        Raid = {
            Enabled = false,
            PlayerSortMode = "Top",
            GroupSortMode = "Role",
            Reverse = false,
        },
        Debug = { Enabled = false },
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
        },
        Version = 8,
    }

    upgrader:UpgradeToVersion8(options)
    assertEquals(options, expected)
end

function M:test_upgrade_options_version9()
    local options = {
        Arena = {
            Enabled = true,
            PlayerSortMode = "Top",
            GroupSortMode = "Group",
            Reverse = false,
        },
        Dungeon = {
            Enabled = true,
            PlayerSortMode = "Top",
            GroupSortMode = "Group",
            Reverse = false,
        },
        World = {
            Enabled = true,
            PlayerSortMode = "Top",
            GroupSortMode = "Group",
            Reverse = false,
        },
        Raid = {
            Enabled = false,
            PlayerSortMode = "Top",
            GroupSortMode = "Role",
            Reverse = false,
        },
        Debug = { Enabled = false },
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
        },
        Version = 8,
    }

    local expected = {
        Logging = {
            Enabled = false,
        },
        Arena = {
            Enabled = true,
            PlayerSortMode = "Top",
            GroupSortMode = "Group",
            Reverse = false,
        },
        Dungeon = {
            Enabled = true,
            PlayerSortMode = "Top",
            GroupSortMode = "Group",
            Reverse = false,
        },
        World = {
            Enabled = true,
            PlayerSortMode = "Top",
            GroupSortMode = "Group",
            Reverse = false,
        },
        Raid = {
            Enabled = false,
            PlayerSortMode = "Top",
            GroupSortMode = "Role",
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
        },
        Version = 9,
    }

    upgrader:UpgradeToVersion9(options)
    assertEquals(options, expected)
end

function M:test_upgrade_options_version10()
    local options = {
        -- Ability Team Tracker values
        ["backdropColorAlpha"] = 0.800000011920929,
        ["NineSlice"] = {
            ["BottomLeftCorner"] = {},
            ["TopEdge"] = {},
            ["BottomEdge"] = {},
            ["Center"] = {},
            ["TopRightCorner"] = {},
            ["BottomRightCorner"] = {},
            ["TopLeftCorner"] = {},
            ["RightEdge"] = {},
            ["LeftEdge"] = {},
        },
        ["layoutType"] = "TooltipDefaultLayout",
        Logging = {
            Enabled = false,
        },
        -- missing Arena to be reset
        Arena = nil,
        Dungeon = {
            Enabled = true,
            PlayerSortMode = "Top",
            GroupSortMode = "Group",
            Reverse = false,
        },
        World = {
            Enabled = true,
            PlayerSortMode = "Top",
            GroupSortMode = "Group",
            Reverse = false,
        },
        Raid = {
            Enabled = false,
            -- missing sorting modes
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
        },
        Version = 9,
    }

    local expected = {
        Logging = {
            Enabled = false,
        },
        Arena = {
            Enabled = true,
            PlayerSortMode = "Top",
            GroupSortMode = "Group",
            Reverse = false,
        },
        Dungeon = {
            Enabled = true,
            PlayerSortMode = "Top",
            GroupSortMode = "Group",
            Reverse = false,
        },
        World = {
            Enabled = true,
            PlayerSortMode = "Top",
            GroupSortMode = "Group",
            Reverse = false,
        },
        Raid = {
            Enabled = false,
            PlayerSortMode = "Top",
            GroupSortMode = "Role",
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
        },
        Version = 10,
    }

    upgrader:UpgradeToVersion10(options)
    assertEquals(options, expected)
end

function M:test_upgrade_options_version11()
    local options = {
        Logging = {
            Enabled = false,
        },
        Arena = {
            Enabled = true,
            PlayerSortMode = "Top",
            GroupSortMode = "Group",
            Reverse = false,
        },
        Dungeon = {
            Enabled = true,
            PlayerSortMode = "Top",
            GroupSortMode = "Group",
            Reverse = false,
        },
        World = {
            Enabled = true,
            PlayerSortMode = "Top",
            GroupSortMode = "Group",
            Reverse = false,
        },
        Raid = {
            Enabled = false,
            PlayerSortMode = "Top",
            GroupSortMode = "Role",
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
        },
        Version = 10,
    }

    local expected = {
        Logging = {
            Enabled = false,
        },
        Arena = {
            Enabled = true,
            PlayerSortMode = "Top",
            GroupSortMode = "Group",
            Reverse = false,
        },
        Dungeon = {
            Enabled = true,
            PlayerSortMode = "Top",
            GroupSortMode = "Group",
            Reverse = false,
        },
        World = {
            Enabled = true,
            PlayerSortMode = "Top",
            GroupSortMode = "Group",
            Reverse = false,
        },
        Raid = {
            Enabled = false,
            PlayerSortMode = "Top",
            GroupSortMode = "Role",
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
        Version = 11,
    }

    upgrader:UpgradeToVersion11(options)
    assertEquals(options, expected)
end

function M:test_upgrade_options_version12()
    local options = {
        Logging = {
            Enabled = false,
        },
        Arena = {
            Enabled = true,
            PlayerSortMode = "Top",
            GroupSortMode = "Group",
            Reverse = false,
        },
        Dungeon = {
            Enabled = true,
            PlayerSortMode = "Top",
            GroupSortMode = "Group",
            Reverse = false,
        },
        World = {
            Enabled = true,
            PlayerSortMode = "Top",
            GroupSortMode = "Group",
            Reverse = false,
        },
        Raid = {
            Enabled = false,
            PlayerSortMode = "Top",
            GroupSortMode = "Role",
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
        Version = 11,
    }

    local expected = {
        Logging = {
            Enabled = false,
        },
        Arena = {
            Enabled = true,
            PlayerSortMode = "Top",
            GroupSortMode = "Group",
            Reverse = false,
        },
        EnemyArena = {
            Enabled = false,
            GroupSortMode = "Group",
            Reverse = false,
        },
        Dungeon = {
            Enabled = true,
            PlayerSortMode = "Top",
            GroupSortMode = "Group",
            Reverse = false,
        },
        World = {
            Enabled = true,
            PlayerSortMode = "Top",
            GroupSortMode = "Group",
            Reverse = false,
        },
        Raid = {
            Enabled = false,
            PlayerSortMode = "Top",
            GroupSortMode = "Role",
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
        Version = 12,
    }

    upgrader:UpgradeToVersion12(options)

    assertEquals(options, expected)
end

return M
