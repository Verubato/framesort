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
        Configuration = {},
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

    fsCompare = addon.Collections.Comparer
    fsConfig = addon.Configuration
end

function M:test_sort_player_top()
    local subject = { "party2", "party1", "player", "party3", "party4" }
    local sortFunction = function(x, y) return fsCompare:Compare(x, y, fsConfig.PlayerSortMode.Top, fsConfig.GroupSortMode.Group, false, nil) end

    table.sort(subject, sortFunction)

    assertEquals(subject, { "player", "party1", "party2", "party3", "party4" })
end

function M:test_sort_player_bottom()
    local subject = { "party2", "party1", "player", "party3", "party4" }
    local sortFunction = function(x, y) return fsCompare:Compare(x, y, fsConfig.PlayerSortMode.Bottom, fsConfig.GroupSortMode.Group, false, nil) end

    table.sort(subject, sortFunction)

    assertEquals(subject, { "party1", "party2", "party3", "party4", "player" })
end

function M:test_sort_player_middle()
    local presorted = { "party1", "party2", "party3", "party4" }
    local subject = { "player", "party2", "party1", "party4", "party3" }

    local sortFunction = function(x, y) return fsCompare:Compare(x, y, fsConfig.PlayerSortMode.Middle, fsConfig.GroupSortMode.Group, false, presorted) end

    table.sort(subject, sortFunction)

    assertEquals(subject, { "party1", "party2", "player", "party3", "party4" })
end

function M:test_sort_with_nonexistant_units()
    local subject = { "party2", "party1", "hello5", "player", "party3", "party4" }
    local sortFunction = function(x, y) return fsCompare:Compare(x, y, fsConfig.PlayerSortMode.Top, fsConfig.GroupSortMode.Group, false, nil) end

    table.sort(subject, sortFunction)

    assertEquals(subject, { "player", "party1", "party2", "party3", "party4", "hello5" })
end

return M
