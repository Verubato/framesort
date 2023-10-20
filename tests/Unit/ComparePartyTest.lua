local deps = {
    "Collections\\Enumerable.lua",
    "Wow\\Unit.lua",
    "Configuration\\SortMode.lua",
    "Collections\\Comparer.lua",
}

local addon = nil
---@type Comparer
local fsCompare = nil
---@type Configuration
local fsConfig = nil
local M = {}

function M:setup()
    addon = {
        Collections = {},
        Configuration = {
            RoleOrdering = {
                TankHealerDps = 1,
                HealerTankDps = 2,
                HealerDpsTank = 3
            }
        },
        Numerics = {},
        WoW = {
            Api = {
                MAX_RAID_MEMBERS = 40,
                MEMBERS_PER_RAID_GROUP = 5
            },
        },
        Utils = {},
    }

    local helper = require("Helper")
    helper:LoadDependencies(addon, deps)

    fsCompare = addon.Collections.Comparer
    fsConfig = addon.Configuration

    local members = helper:GenerateUnits(5)
    addon.WoW.Api.UnitExists = function(unit)
        return helper:UnitExists(unit, members)
    end
    addon.WoW.Api.IsInGroup = function()
        return true
    end
    addon.WoW.Api.UnitIsUnit = function(left, right)
        return left == right
    end
    addon.WoW.Api.IsInInstance = function() return false end

    addon.DB = {
        Options = {
            World = {
                Enabled = true,
            }
        }
    }
end

function M:test_sort_player_top()
    assert(addon)

    addon.DB.Options.World.PlayerSortMode = fsConfig.PlayerSortMode.Top
    addon.DB.Options.World.GroupSortMode = fsConfig.GroupSortMode.Group

    local subject = { "party2", "party1", "player", "party3", "party4" }
    local sortFunction = fsCompare:SortFunction()

    table.sort(subject, sortFunction)

    assertEquals(subject, { "player", "party1", "party2", "party3", "party4" })
end

function M:test_sort_player_bottom()
    assert(addon)

    addon.DB.Options.World.PlayerSortMode = fsConfig.PlayerSortMode.Bottom
    addon.DB.Options.World.GroupSortMode = fsConfig.GroupSortMode.Group

    local subject = { "party2", "party1", "player", "party3", "party4" }
    local sortFunction = fsCompare:SortFunction()

    table.sort(subject, sortFunction)

    assertEquals(subject, { "party1", "party2", "party3", "party4", "player" })
end

function M:test_sort_player_middle_size_2()
    assert(addon)

    addon.DB.Options.World.PlayerSortMode = fsConfig.PlayerSortMode.Middle
    addon.DB.Options.World.GroupSortMode = fsConfig.GroupSortMode.Group

    local subject = { "player", "party1" }
    local sortFunction = fsCompare:SortFunction(subject)

    table.sort(subject, sortFunction)

    assertEquals(subject, { "player", "party1" })
end

function M:test_sort_player_middle_size_3()
    assert(addon)

    addon.DB.Options.World.PlayerSortMode = fsConfig.PlayerSortMode.Middle
    addon.DB.Options.World.GroupSortMode = fsConfig.GroupSortMode.Group

    local subject = { "player", "party1", "party2" }
    local sortFunction = fsCompare:SortFunction(subject)

    table.sort(subject, sortFunction)

    assertEquals(subject, { "party1", "player", "party2" })
end

function M:test_sort_player_middle_size_4()
    assert(addon)

    addon.DB.Options.World.PlayerSortMode = fsConfig.PlayerSortMode.Middle
    addon.DB.Options.World.GroupSortMode = fsConfig.GroupSortMode.Group

    local subject = { "player", "party1", "party2", "party3" }
    local sortFunction = fsCompare:SortFunction(subject)

    table.sort(subject, sortFunction)

    assertEquals(subject, { "party1", "player", "party2", "party3" })
end

function M:test_sort_player_middle_size_5()
    assert(addon)

    addon.DB.Options.World.PlayerSortMode = fsConfig.PlayerSortMode.Middle
    addon.DB.Options.World.GroupSortMode = fsConfig.GroupSortMode.Group

    local subject = { "player", "party1", "party2", "party3", "party4" }
    local sortFunction = fsCompare:SortFunction(subject)

    table.sort(subject, sortFunction)

    assertEquals(subject, { "party1", "party2", "player", "party3", "party4" })
end

function M:test_sort_with_nonexistant_units()
    assert(addon)

    addon.DB.Options.World.PlayerSortMode = fsConfig.PlayerSortMode.Top
    addon.DB.Options.World.GroupSortMode = fsConfig.GroupSortMode.Group

    local subject = { "party2", "party1", "hello5", "player", "party3", "party4" }
    local sortFunction = fsCompare:SortFunction(subject)

    table.sort(subject, sortFunction)

    assertEquals(subject, { "player", "party1", "party2", "party3", "party4", "hello5" })
end

return M
