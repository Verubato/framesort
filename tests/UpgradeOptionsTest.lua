local deps = {
    "Config\\OptionsUpgrader.lua"
}

local addon = {}
for _, fileName in ipairs(deps) do
    local module = loadfile("..\\src\\" .. fileName)
    if module == nil then error("Failed to load " .. fileName) end
    module("UnitTest", addon)
end

local upgrader = addon.OptionsUpgrader
local M = {}

function M:test_upgrade_options_version2()
    local options = {
        PlayerSortMode = "Top",
        RaidSortMode = "Role",
        PartySortMode = "Group",
        RaidSortEnabled = false,
        PartySortEnabled = true
    }

    upgrader:UpgradeToVersion2(options)

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
        Version = 2
    }

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
        Version = 2
    }

    upgrader:UpgradeToVersion3(options)

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
        Version = 3
    }

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
        Version = 3
    }

    upgrader:UpgradeToVersion4(options)

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
            TraditionalEnabled = false
        },
        Version = 4
    }

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
            TraditionalEnabled = false
        },
        Version = 4,
    }

    upgrader:UpgradeToVersion5(options)

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
            TraditionalEnabled = false
        },
        Version = 5,
    }

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
            TraditionalEnabled = false
        },
        Version = 5
    }

    upgrader:UpgradeToVersion6(options)

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
            TraditionalEnabled = false
        },
        Appearance = {
            Party = {
                Spacing = {
                    Horizontal = 0,
                    Vertical = 0
                },
            },
            Raid = {
                Spacing = {
                    Horizontal = 0,
                    Vertical = 0
                }
            }
        },
        Version = 6,
    }

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
            TraditionalEnabled = false
        },
        Appearance = {
            Party = {
                Spacing = {
                    Horizontal = 0,
                    Vertical = 0
                },
            },
            Raid = {
                Spacing = {
                    Horizontal = 0,
                    Vertical = 0
                }
            }
        },
        Version = 6,
    }

    upgrader:UpgradeToVersion7(options)

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
            TraditionalEnabled = false
        },
        Appearance = {
            Party = {
                Spacing = {
                    Horizontal = 0,
                    Vertical = 0
                },
            },
            Raid = {
                Spacing = {
                    Horizontal = 0,
                    Vertical = 0
                }
            }
        },
        Version = 7
    }

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
            TraditionalEnabled = false
        },
        Appearance = {
            Party = {
                Spacing = {
                    Horizontal = 0,
                    Vertical = 0
                },
            },
            Raid = {
                Spacing = {
                    Horizontal = 0,
                    Vertical = 0
                }
            }
        },
        Version = 7
    }

    upgrader:UpgradeToVersion8(options)

    local expected = {
        Arena = {
            Enabled = true,
            PlayerSortMode = "Top",
            GroupSortMode = "Group",
            Reverse = false
        },
        Dungeon = {
            Enabled = true,
            PlayerSortMode = "Top",
            GroupSortMode = "Group",
            Reverse = false
        },
        World = {
            Enabled = true,
            PlayerSortMode = "Top",
            GroupSortMode = "Group",
            Reverse = false
        },
        Raid = {
            Enabled = false,
            PlayerSortMode = "Top",
            GroupSortMode = "Role",
            Reverse = false
        },
        Debug = { Enabled = false },
        SortingMethod = {
            TaintlessEnabled = true,
            TraditionalEnabled = false
        },
        Appearance = {
            Party = {
                Spacing = {
                    Horizontal = 0,
                    Vertical = 0
                },
            },
            Raid = {
                Spacing = {
                    Horizontal = 0,
                    Vertical = 0
                }
            }
        },
        Version = 8
    }


    assertEquals(options, expected)
end

function M:test_upgrade_options_version9()
    local options = {
        Arena = {
            Enabled = true,
            PlayerSortMode = "Top",
            GroupSortMode = "Group",
            Reverse = false
        },
        Dungeon = {
            Enabled = true,
            PlayerSortMode = "Top",
            GroupSortMode = "Group",
            Reverse = false
        },
        World = {
            Enabled = true,
            PlayerSortMode = "Top",
            GroupSortMode = "Group",
            Reverse = false
        },
        Raid = {
            Enabled = false,
            PlayerSortMode = "Top",
            GroupSortMode = "Role",
            Reverse = false
        },
        Debug = { Enabled = false },
        SortingMethod = {
            TaintlessEnabled = true,
            TraditionalEnabled = false
        },
        Appearance = {
            Party = {
                Spacing = {
                    Horizontal = 0,
                    Vertical = 0
                },
            },
            Raid = {
                Spacing = {
                    Horizontal = 0,
                    Vertical = 0
                }
            }
        },
        Version = 8
    }

    upgrader:UpgradeToVersion9(options)

    local expected = {
        Logging = {
            Enabled = false
        },
        Arena = {
            Enabled = true,
            PlayerSortMode = "Top",
            GroupSortMode = "Group",
            Reverse = false
        },
        Dungeon = {
            Enabled = true,
            PlayerSortMode = "Top",
            GroupSortMode = "Group",
            Reverse = false
        },
        World = {
            Enabled = true,
            PlayerSortMode = "Top",
            GroupSortMode = "Group",
            Reverse = false
        },
        Raid = {
            Enabled = false,
            PlayerSortMode = "Top",
            GroupSortMode = "Role",
            Reverse = false
        },
        SortingMethod = {
            TaintlessEnabled = true,
            TraditionalEnabled = false
        },
        Appearance = {
            Party = {
                Spacing = {
                    Horizontal = 0,
                    Vertical = 0
                },
            },
            Raid = {
                Spacing = {
                    Horizontal = 0,
                    Vertical = 0
                }
            }
        },
        Version = 9
    }

    assertEquals(options, expected)
end

return M
