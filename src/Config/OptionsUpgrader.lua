local _, addon = ...

local function UpgradeToVersion2()
    addon.Options.ArenaEnabled = addon.Options.PartySortEnabled
    addon.Options.ArenaPlayerSortMode = addon.Options.PlayerSortMode
    addon.Options.ArenaSortMode = addon.Options.PartySortMode

    addon.Options.DungeonEnabled = addon.Options.PartySortEnabled
    addon.Options.DungeonPlayerSortMode = addon.Options.PlayerSortMode
    addon.Options.DungeonSortMode = addon.Options.PartySortMode

    addon.Options.WorldEnabled = addon.Options.PartySortEnabled
    addon.Options.WorldPlayerSortMode = addon.Options.PlayerSortMode
    addon.Options.WorldSortMode = addon.Options.PartySortMode

    addon.Options.RaidEnabled = addon.Options.RaidSortEnabled
    addon.Options.RaidPlayerSortMode = addon.Options.PlayerSortMode

    addon.Options.DebugEnabled = false

    addon.Options.PartySortEnabled = nil
    addon.Options.PlayerSortMode = nil
    addon.Options.RaidSortEnabled = nil

    addon.Options.Version = 2
end

local function UpgradeToVersion3()
    addon.Options.ExperimentalEnabled = false
    addon.Options.Version = 3
end

local function UpgradeToVersion4()
    addon.Options.SortingMethod = {
        TaintlessEnabled = true,
        TraditionalEnabled = false
    }

    addon.Options.Version = 4
end

local function UpgradeToVersion5()
    addon.Options.Debug = {
        Enabled = addon.Options.DebugEnabled
    }

    addon.Options.Arena = {
        Enabled = addon.Options.ArenaEnabled,
        PlayerSortMode = addon.Options.ArenaPlayerSortMode,
        GroupSortMode = addon.Options.ArenaSortMode
    }

    addon.Options.Dungeon = {
        Enabled = addon.Options.DungeonEnabled,
        PlayerSortMode = addon.Options.DungeonPlayerSortMode,
        GroupSortMode = addon.Options.DungeonSortMode
    }

    addon.Options.Raid = {
        Enabled = addon.Options.RaidEnabled,
        PlayerSortMode = addon.Options.RaidPlayerSortMode,
        GroupSortMode = addon.Options.RaidSortMode
    }

    addon.Options.World = {
        Enabled = addon.Options.WorldEnabled,
        PlayerSortMode = addon.Options.WorldPlayerSortMode,
        GroupSortMode = addon.Options.WorldSortMode
    }

    addon.Options.DebugEnabled = nil

    addon.Options.ArenaEnabled = nil
    addon.Options.ArenaPlayerSortMode = nil
    addon.Options.ArenaSortMode = nil

    addon.Options.DungeonEnabled = nil
    addon.Options.DungeonPlayerSortMode = nil
    addon.Options.DungeonSortMode = nil

    addon.Options.RaidEnabled = nil
    addon.Options.RaidPlayerSortMode = nil
    addon.Options.RaidSortMode = nil

    addon.Options.WorldEnabled = nil
    addon.Options.WorldPlayerSortMode = nil
    addon.Options.WorldSortMode = nil

    -- forgot to remove this in version 4
    addon.Options.ExperimentalEnabled = nil

    addon.Options.Version = 5
end

local function UpgradeToVersion6()
    addon.Options.Appearance = addon.Defaults.Appearance
    addon.Options.Version = 6
end

---Upgrades saved options to the current version.
function addon:UpgradeOptions()
    if addon.Options.Version == nil then
        addon:Debug("Upgrading options to version 2.")
        UpgradeToVersion2()
    end

    if addon.Options.Version == 2 then
        addon:Debug("Upgrading options to version 3.")
        UpgradeToVersion3()
    end

    if addon.Options.Version == 3 then
        addon:Debug("Upgrading options to version 4.")
        UpgradeToVersion4()
    end

    if addon.Options.Version == 4 then
        addon:Debug("Upgrading options to version 5.")
        UpgradeToVersion5()
    end

    if addon.Options.Version == 5 then
        addon:Debug("Upgrading options to version 6.")
        UpgradeToVersion6()
    end
end
