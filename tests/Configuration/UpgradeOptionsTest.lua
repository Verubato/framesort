local upgrader
local M = {}

function M:setup()
    local addonFactory = require("TestHarness\\AddonFactory")
    local addon = addonFactory:Create()
    upgrader = addon.Configuration.Upgrader
end

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

    local success = upgrader:UpgradeToVersion2(options)

    assertEquals(success, true)
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

    local success = upgrader:UpgradeToVersion3(options)

    assertEquals(success, true)
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

    local success = upgrader:UpgradeToVersion4(options)

    assertEquals(success, true)
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

    local success = upgrader:UpgradeToVersion5(options)

    assertEquals(success, true)
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

    local success = upgrader:UpgradeToVersion6(options)

    assertEquals(success, true)
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

    local success = upgrader:UpgradeToVersion7(options)

    assertEquals(success, true)
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

    local success = upgrader:UpgradeToVersion8(options)

    assertEquals(success, true)
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

    local success = upgrader:UpgradeToVersion9(options)

    assertEquals(success, true)
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

    local success = upgrader:UpgradeToVersion10(options)

    assertEquals(success, true)
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

    local success = upgrader:UpgradeToVersion11(options)

    assertEquals(success, true)
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

    local success = upgrader:UpgradeToVersion12(options)

    assertEquals(success, true)
    assertEquals(options, expected)
end

function M:test_upgrade_options_version13()
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
        SortingMethod = 2,
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
        Version = 13,
    }

    local success = upgrader:UpgradeToVersion13(options)

    assertEquals(success, true)
    assertEquals(options, expected)
end

function M:test_upgrade_options_version14()
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
        SortingMethod = 2,
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
        Version = 13,
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
        SortingMethod = 1,
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
        Version = 14,
    }

    local success = upgrader:UpgradeToVersion14(options)

    assertEquals(success, true)
    assertEquals(options, expected)
end

function M:test_upgrade_options_version15()
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
        SortingMethod = 1,
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
        Version = 14,
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
        SortingMethod = "Secure",
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
        Version = 15,
    }

    local success = upgrader:UpgradeToVersion15(options)

    assertEquals(success, true)
    assertEquals(options, expected)
end

function M:test_upgrade_options_version16()
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
        SortingMethod = "Secure",
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
        Version = 15,
    }

    local expected = {
        Logging = {
            Enabled = false,
        },
        Sorting = {
            RoleOrdering = 1,
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
        SortingMethod = "Secure",
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
        Version = 16,
    }

    local success = upgrader:UpgradeToVersion16(options)

    assertEquals(success, true)
    assertEquals(options, expected)
end

function M:test_upgrade_options_version17()
    local options = {
        Logging = {
            Enabled = false,
        },
        Sorting = {
            RoleOrdering = 1,
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
        SortingMethod = "Secure",
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
        Version = 16,
    }

    local expected = {
        Logging = {
            Enabled = false,
        },
        Sorting = {
            RoleOrdering = 1,
            Method = "Secure",
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
        Version = 17,
    }

    local success = upgrader:UpgradeToVersion17(options)

    assertEquals(success, true)
    assertEquals(options, expected)
end

function M:test_upgrade_options_version18()
    local options = {
        Logging = {
            Enabled = false,
        },
        SortingMethod = "Secure",
        Sorting = {
            RoleOrdering = 1,
            Method = "Secure",
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
        Version = 17,
    }

    local expected = {
        Logging = {
            Enabled = false,
        },
        Sorting = {
            RoleOrdering = 1,
            Method = "Secure",
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
        Version = 18,
    }

    local success = upgrader:UpgradeToVersion18(options)

    assertEquals(success, true)
    assertEquals(options, expected)
end

function M:test_upgrade_options_version19()
    local options = {
        Logging = {
            Enabled = false,
        },
        Sorting = {
            RoleOrdering = 1,
            Method = "Secure",
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
        Version = 18,
    }

    local expected = {
        Logging = {
            Enabled = false,
        },
        Sorting = {
            RoleOrdering = 1,
            Method = "Secure",
            Arena = {
                Twos = {
                    Enabled = true,
                    PlayerSortMode = "Top",
                    GroupSortMode = "Group",
                    Reverse = false,
                },
                Default = {
                    Enabled = true,
                    PlayerSortMode = "Top",
                    GroupSortMode = "Group",
                    Reverse = false,
                },
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
        Version = 19,
    }

    local success = upgrader:UpgradeToVersion19(options)

    assertEquals(success, true)
    assertEquals(options, expected)
end

function M:test_upgrade_options_version20()
    local options = {
        Logging = {
            Enabled = false,
        },
        Sorting = {
            RoleOrdering = 1,
            Method = "Secure",
            Arena = {
                Twos = {
                    Enabled = true,
                    PlayerSortMode = "Top",
                    GroupSortMode = "Group",
                    Reverse = false,
                },
                Default = {
                    Enabled = true,
                    PlayerSortMode = "Top",
                    GroupSortMode = "Group",
                    Reverse = false,
                },
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
        Version = 19,
    }

    local expected = {
        Logging = {
            Enabled = false,
        },
        Sorting = {
            RoleOrdering = 1,
            Method = "Secure",
            Arena = {
                Twos = {
                    Enabled = true,
                    PlayerSortMode = "Top",
                    GroupSortMode = "Group",
                    Reverse = false,
                },
                Default = {
                    Enabled = true,
                    PlayerSortMode = "Top",
                    GroupSortMode = "Group",
                    Reverse = false,
                },
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
        Version = 20,
    }

    local success = upgrader:UpgradeToVersion20(options)

    assertEquals(success, true)
    assertEquals(options, expected)
end

function M:test_upgrade_options_version21()
    local options = {
        Logging = {
            Enabled = false,
        },
        Sorting = {
            RoleOrdering = 1,
            Method = "Secure",
            Arena = {
                Twos = {
                    Enabled = true,
                    PlayerSortMode = "Top",
                    GroupSortMode = "Group",
                    Reverse = false,
                },
                Default = {
                    Enabled = true,
                    PlayerSortMode = "Top",
                    GroupSortMode = "Group",
                    Reverse = false,
                },
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
        Version = 20,
    }

    local expected = {
        Logging = {
            Enabled = false,
        },
        Sorting = {
            Ordering = {
                Tanks = 1,
                Healers = 2,
                Casters = 3,
                Hunters = 4,
                Melee = 5,
            },
            Method = "Secure",
            Arena = {
                Twos = {
                    Enabled = true,
                    PlayerSortMode = "Top",
                    GroupSortMode = "Group",
                    Reverse = false,
                },
                Default = {
                    Enabled = true,
                    PlayerSortMode = "Top",
                    GroupSortMode = "Group",
                    Reverse = false,
                },
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
        Version = 21,
    }

    local success = upgrader:UpgradeToVersion21(options)

    assertEquals(success, true)
    assertEquals(options, expected)
end

function M:test_upgrade_options_version22()
    local options = {
        Logging = {
            Enabled = false,
        },
        Sorting = {
            Ordering = {
                Tanks = 1,
                Healers = 2,
                Casters = 3,
                Hunters = 4,
                Melee = 5,
            },
            Method = "Secure",
            Arena = {
                Twos = {
                    Enabled = true,
                    PlayerSortMode = "Top",
                    GroupSortMode = "Group",
                    Reverse = false,
                },
                Default = {
                    Enabled = true,
                    PlayerSortMode = "Top",
                    GroupSortMode = "Group",
                    Reverse = false,
                },
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
        Version = 21,
    }

    local expected = {
        Sorting = {
            Ordering = {
                Tanks = 1,
                Healers = 2,
                Casters = 3,
                Hunters = 4,
                Melee = 5,
            },
            Method = "Secure",
            Arena = {
                Twos = {
                    Enabled = true,
                    PlayerSortMode = "Top",
                    GroupSortMode = "Group",
                    Reverse = false,
                },
                Default = {
                    Enabled = true,
                    PlayerSortMode = "Top",
                    GroupSortMode = "Group",
                    Reverse = false,
                },
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
        Version = 22,
    }

    local success = upgrader:UpgradeToVersion22(options)

    assertEquals(success, true)
    assertEquals(options, expected)
end

function M:test_upgrade_options_version1_to_latest()
    local options = {
        PlayerSortMode = "Top",
        RaidSortMode = "Role",
        PartySortMode = "Group",
        RaidSortEnabled = false,
        PartySortEnabled = true,
    }

    local expected = {
        Sorting = {
            Ordering = {
                Tanks = 1,
                Healers = 2,
                Casters = 3,
                Hunters = 4,
                Melee = 5,
            },
            Method = "Secure",
            Arena = {
                Twos = {
                    Enabled = true,
                    PlayerSortMode = "Top",
                    GroupSortMode = "Group",
                    Reverse = false,
                },
                Default = {
                    Enabled = true,
                    PlayerSortMode = "Top",
                    GroupSortMode = "Group",
                    Reverse = false,
                },
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
        Version = 22,
    }

    local success = upgrader:UpgradeOptions(options)

    assertEquals(success, true)
    assertEquals(options, expected)
end

function M:test_upgrade_options_latest_to_latest_passes()
    local options = {
        Sorting = {
            Ordering = {
                Tanks = 1,
                Healers = 2,
                Casters = 3,
                Hunters = 4,
                Melee = 5,
            },
            SpecPriority = {
                Tanks = { 1, 2, 3 },
            },
            Method = "Secure",
            Arena = {
                Twos = {
                    Enabled = true,
                    PlayerSortMode = "Top",
                    GroupSortMode = "Group",
                    Reverse = false,
                },
                Default = {
                    Enabled = true,
                    PlayerSortMode = "Top",
                    GroupSortMode = "Group",
                    Reverse = false,
                },
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
        Version = 22,
    }

    local success = upgrader:UpgradeOptions(options)

    assertEquals(success, true)
end

function M:test_upgrade_options_higher_than_current_fails()
    local options = {
        Sorting = {
            Ordering = {
                Tanks = 1,
                Healers = 2,
                Casters = 3,
                Hunters = 4,
                Melee = 5,
            },
            Method = "Secure",
            Arena = {
                Twos = {
                    Enabled = true,
                    PlayerSortMode = "Top",
                    GroupSortMode = "Group",
                    Reverse = false,
                },
                Default = {
                    Enabled = true,
                    PlayerSortMode = "Top",
                    GroupSortMode = "Group",
                    Reverse = false,
                },
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
        Version = 99,
    }

    local success = upgrader:UpgradeOptions(options)

    assertEquals(success, false)
end

return M
