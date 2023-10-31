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

    local playerToken = "raid2"
    local members = helper:GenerateUnits(8)
    addon.WoW.Api.UnitExists = function(unit)
        return unit == "player" or helper:UnitExists(unit, members)
    end
    addon.WoW.Api.IsInGroup = function()
        return true
    end
    addon.WoW.Api.UnitIsUnit = function(left, right)
        return left == right or (left == playerToken and right == "player")
    end
    addon.WoW.Api.IsInInstance = function() return false end
    addon.WoW.Api.IsInRaid = function() return true end

    addon.DB = {
        Options = {
            Sorting = {
                World = {
                    Enabled = true,
                }
            }
        }
    }
end

function M:test_sort_player_top()
    assert(addon)

    local config = addon.DB.Options.Sorting.World
    config.PlayerSortMode = fsConfig.PlayerSortMode.Top
    config.GroupSortMode = fsConfig.GroupSortMode.Group

    local subject = { "raid1", "raid2", "raid3", "raid4", "raid5", "raid6", "raid7", "raid8" }
    local sortFunction = fsCompare:SortFunction(subject)

    table.sort(subject, sortFunction)

    assertEquals(subject, { "raid2", "raid1", "raid3", "raid4", "raid5", "raid6", "raid7", "raid8" })
end

function M:test_sort_player_bottom()
    assert(addon)

    local config = addon.DB.Options.Sorting.World
    config.PlayerSortMode = fsConfig.PlayerSortMode.Bottom
    config.GroupSortMode = fsConfig.GroupSortMode.Group

    local subject = { "raid8", "raid3", "raid4", "raid1", "raid2", "raid7", "raid5", "raid6" }
    local sortFunction = fsCompare:SortFunction(subject)

    table.sort(subject, sortFunction)

    assertEquals(subject, { "raid1", "raid3", "raid4", "raid5", "raid6", "raid7", "raid8", "raid2" })
end

function M:test_sort_player_middle()
    assert(addon)

    local config = addon.DB.Options.Sorting.World
    config.PlayerSortMode = fsConfig.PlayerSortMode.Middle
    config.GroupSortMode = fsConfig.GroupSortMode.Group

    local subject = { "raid2", "raid3", "raid4", "raid7", "raid1", "raid5", "raid6" }
    local sortFunction = fsCompare:SortFunction(subject)

    table.sort(subject, sortFunction)

    assertEquals(subject, { "raid1", "raid3", "raid4", "raid2", "raid5", "raid6", "raid7" })
end

return M
