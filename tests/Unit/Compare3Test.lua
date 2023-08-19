local deps = {
    "Configuration\\SortMode.lua",
    "Collections\\Enumerable.lua",
    "Collections\\Comparer.lua",
}

local addon = nil
local fsCompare = nil
local fsConfig = nil
local M = {}

function M:setup()
    addon = {
        Collections = {},
        Configuration = {},
        Numerics = {},
        WoW = {
            Api = {},
        },
        Utils = {},
    }

    local helper = require("Helper")
    helper:LoadDependencies(addon, deps)

    local members = helper:GenerateUnits(3)
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

function M:test_sort_with_nonexistant_units()
    assertEquals(fsCompare:Compare("party3", "player", fsConfig.PlayerSortMode.Top, fsConfig.GroupSortMode.Group), false)
    assertEquals(fsCompare:Compare("player", "party3", fsConfig.PlayerSortMode.Top, fsConfig.GroupSortMode.Group), true)
end

function M:test_sort_player_top()
    assertEquals(fsCompare:Compare("player", "party1", fsConfig.PlayerSortMode.Top, fsConfig.GroupSortMode.Group), true)
    assertEquals(fsCompare:Compare("player", "party2", fsConfig.PlayerSortMode.Top, fsConfig.GroupSortMode.Group), true)

    assertEquals(fsCompare:Compare("party1", "party2", fsConfig.PlayerSortMode.Top, fsConfig.GroupSortMode.Group), true)
    assertEquals(fsCompare:Compare("party2", "party1", fsConfig.PlayerSortMode.Top, fsConfig.GroupSortMode.Group), false)

    assertEquals(fsCompare:Compare("party1", "player", fsConfig.PlayerSortMode.Top, fsConfig.GroupSortMode.Group), false)
    assertEquals(fsCompare:Compare("party2", "player", fsConfig.PlayerSortMode.Top, fsConfig.GroupSortMode.Group), false)
end

function M:test_sort_player_bottom()
    assertEquals(fsCompare:Compare("player", "party1", fsConfig.PlayerSortMode.Bottom, fsConfig.GroupSortMode.Group), false)
    assertEquals(fsCompare:Compare("player", "party2", fsConfig.PlayerSortMode.Bottom, fsConfig.GroupSortMode.Group), false)

    assertEquals(fsCompare:Compare("party1", "party2", fsConfig.PlayerSortMode.Bottom, fsConfig.GroupSortMode.Group), true)
    assertEquals(fsCompare:Compare("party2", "party1", fsConfig.PlayerSortMode.Bottom, fsConfig.GroupSortMode.Group), false)

    assertEquals(fsCompare:Compare("party1", "player", fsConfig.PlayerSortMode.Bottom, fsConfig.GroupSortMode.Group), true)
    assertEquals(fsCompare:Compare("party2", "player", fsConfig.PlayerSortMode.Bottom, fsConfig.GroupSortMode.Group), true)
end

function M:test_sort_player_middle()
    local presorted = { "player", "party1", "party2" }
    assertEquals(fsCompare:Compare("player", "party1", fsConfig.PlayerSortMode.Middle, fsConfig.GroupSortMode.Group, false, presorted), false)
    assertEquals(fsCompare:Compare("player", "party2", fsConfig.PlayerSortMode.Middle, fsConfig.GroupSortMode.Group, false, presorted), true)

    assertEquals(fsCompare:Compare("party1", "party2", fsConfig.PlayerSortMode.Middle, fsConfig.GroupSortMode.Group, false, presorted), true)
    assertEquals(fsCompare:Compare("party2", "party1", fsConfig.PlayerSortMode.Middle, fsConfig.GroupSortMode.Group, false, presorted), false)

    assertEquals(fsCompare:Compare("party1", "player", fsConfig.PlayerSortMode.Middle, fsConfig.GroupSortMode.Group, false, presorted), true)
    assertEquals(fsCompare:Compare("party2", "player", fsConfig.PlayerSortMode.Middle, fsConfig.GroupSortMode.Group, false, presorted), false)
end

return M
