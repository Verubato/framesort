---@type string, Addon
local _, addon = ...
local fsLog = addon.Log
---@class OptionsUpgrader
local M = {}

addon.OptionsUpgrader = M

function M:UpgradeToVersion2(options)
    assert(options.Version == nil or options.Version == 1)

    options.ArenaEnabled = options.PartySortEnabled
    options.ArenaPlayerSortMode = options.PlayerSortMode
    options.ArenaSortMode = options.PartySortMode

    options.DungeonEnabled = options.PartySortEnabled
    options.DungeonPlayerSortMode = options.PlayerSortMode
    options.DungeonSortMode = options.PartySortMode

    options.WorldEnabled = options.PartySortEnabled
    options.WorldPlayerSortMode = options.PlayerSortMode
    options.WorldSortMode = options.PartySortMode

    options.RaidEnabled = options.RaidSortEnabled
    options.RaidPlayerSortMode = options.PlayerSortMode

    options.DebugEnabled = false

    options.PartySortEnabled = nil
    options.PartySortMode = nil
    options.PlayerSortMode = nil
    options.RaidSortEnabled = nil

    options.Version = 2
end

function M:UpgradeToVersion3(options)
    assert(options.Version == 2)

    options.ExperimentalEnabled = false
    options.Version = 3
end

function M:UpgradeToVersion4(options)
    assert(options.Version == 3)

    options.SortingMethod = {
        TaintlessEnabled = true,
        TraditionalEnabled = false,
    }

    options.Version = 4
end

function M:UpgradeToVersion5(options)
    assert(options.Version == 4)

    options.Debug = {
        Enabled = options.DebugEnabled,
    }

    options.Arena = {
        Enabled = options.ArenaEnabled,
        PlayerSortMode = options.ArenaPlayerSortMode,
        GroupSortMode = options.ArenaSortMode,
    }

    options.Dungeon = {
        Enabled = options.DungeonEnabled,
        PlayerSortMode = options.DungeonPlayerSortMode,
        GroupSortMode = options.DungeonSortMode,
    }

    options.Raid = {
        Enabled = options.RaidEnabled,
        PlayerSortMode = options.RaidPlayerSortMode,
        GroupSortMode = options.RaidSortMode,
    }

    options.World = {
        Enabled = options.WorldEnabled,
        PlayerSortMode = options.WorldPlayerSortMode,
        GroupSortMode = options.WorldSortMode,
    }

    options.DebugEnabled = nil

    options.ArenaEnabled = nil
    options.ArenaPlayerSortMode = nil
    options.ArenaSortMode = nil

    options.DungeonEnabled = nil
    options.DungeonPlayerSortMode = nil
    options.DungeonSortMode = nil

    options.RaidEnabled = nil
    options.RaidPlayerSortMode = nil
    options.RaidSortMode = nil

    options.WorldEnabled = nil
    options.WorldPlayerSortMode = nil
    options.WorldSortMode = nil

    -- forgot to remove this in version 4
    options.ExperimentalEnabled = nil

    options.Version = 5
end

function M:UpgradeToVersion6(options)
    assert(options.Version == 5)

    options.Appearance = {
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
    }

    options.Version = 6
end

function M:UpgradeToVersion7(options)
    assert(options.Version == 6)

    options.Debug.Enabled = false
    options.Version = 7
end

function M:UpgradeToVersion8(options)
    assert(options.Version == 7)

    options.Arena.Reverse = false
    options.Dungeon.Reverse = false
    options.Raid.Reverse = false
    options.World.Reverse = false
    options.Version = 8
end

function M:UpgradeToVersion9(options)
    assert(options.Version == 8)

    options.Debug = nil
    options.Logging = {
        Enabled = false,
    }
    options.Version = 9
end

local function CleanTable(options, defaults)
    -- remove values that aren't ours
    for k, v in pairs(options) do
        if defaults[k] == nil then
            options[k] = nil
        elseif v ~= nil and type(v) == "table" then
            CleanTable(options[k], defaults[k])
        end
    end
end

local function AddMissing(options, defaults)
    -- add defaults for any missing values
    for k, v in pairs(defaults) do
        if options[k] == nil then
            options[k] = v
        elseif type(v) == "table" then
            AddMissing(options[k], defaults[k])
        end
    end
end

function M:UpgradeToVersion10(options)
    assert(options.Version == 9)

    -- encountered a clash with Ability Team Tracker also using the "Options" global variable
    -- so clean up our saved variable for anyone affected
    local v10Defaults = {
        Version = 10,
        Logging = {
            Enabled = false,
        },
        Arena = {
            Enabled = true,
            PlayerSortMode = addon.PlayerSortMode.Top,
            GroupSortMode = addon.GroupSortMode.Group,
            Reverse = false,
        },
        Dungeon = {
            Enabled = true,
            PlayerSortMode = addon.PlayerSortMode.Top,
            GroupSortMode = addon.GroupSortMode.Role,
            Reverse = false,
        },
        World = {
            Enabled = true,
            PlayerSortMode = addon.PlayerSortMode.Top,
            GroupSortMode = addon.GroupSortMode.Group,
            Reverse = false,
        },
        Raid = {
            Enabled = false,
            PlayerSortMode = addon.PlayerSortMode.Top,
            GroupSortMode = addon.GroupSortMode.Role,
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
    }

    -- remove clashing values
    CleanTable(options, v10Defaults)

    -- add any missing values back
    AddMissing(options, v10Defaults)

    options.Version = 10
end

function M:UpgradeToVersion11(options)
    assert(options.Version == 10)

    options.Appearance.EnemyArena = {
        Spacing = {
            Horizontal = 0,
            Vertical = 0,
        },
    }

    options.Version = 11
end

function M:UpgradeToVersion12(options)
    assert(options.Version == 11)

    options.EnemyArena = {
        Enabled = false,
        GroupSortMode = addon.GroupSortMode.Group,
        Reverse = false,
    }

    options.Version = 12
end

local upgradeFunctions = {
    Version2 = M.UpgradeToVersion2,
    Version3 = M.UpgradeToVersion3,
    Version4 = M.UpgradeToVersion4,
    Version5 = M.UpgradeToVersion5,
    Version6 = M.UpgradeToVersion6,
    Version7 = M.UpgradeToVersion7,
    Version8 = M.UpgradeToVersion8,
    Version9 = M.UpgradeToVersion9,
    Version10 = M.UpgradeToVersion10,
    Version11 = M.UpgradeToVersion11,
    Version12 = M.UpgradeToVersion12,
}

---Upgrades saved options to the current version.
function M:UpgradeOptions(options)
    while (options.Version or 1) < addon.Defaults.Version do
        local nextVersion = (options.Version or 1) + 1
        local next = upgradeFunctions["Version" .. nextVersion]
        assert(next ~= nil)

        fsLog:Debug("Upgrading options to version " .. nextVersion .. ".")
        next(M, options)
    end
end
