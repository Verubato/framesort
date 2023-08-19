local deps = {
    "Configuration\\SortMode.lua",
    "Collections\\Enumerable.lua",
    "Collections\\Comparer.lua",
}

local addon = nil
local fsCompare = nil
local fsConfig = nil
local M = {}

function M:setUp()
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
    assertEquals(fsCompare:Compare("player", "party1", fsConfig.PlayerSortMode.Top, fsConfig.GroupSortMode.Group), true)
    assertEquals(fsCompare:Compare("player", "party2", fsConfig.PlayerSortMode.Top, fsConfig.GroupSortMode.Group), true)
    assertEquals(fsCompare:Compare("player", "party3", fsConfig.PlayerSortMode.Top, fsConfig.GroupSortMode.Group), true)
    assertEquals(fsCompare:Compare("player", "party4", fsConfig.PlayerSortMode.Top, fsConfig.GroupSortMode.Group), true)

    assertEquals(fsCompare:Compare("party1", "player", fsConfig.PlayerSortMode.Top, fsConfig.GroupSortMode.Group), false)
    assertEquals(fsCompare:Compare("party2", "player", fsConfig.PlayerSortMode.Top, fsConfig.GroupSortMode.Group), false)
    assertEquals(fsCompare:Compare("party3", "player", fsConfig.PlayerSortMode.Top, fsConfig.GroupSortMode.Group), false)
    assertEquals(fsCompare:Compare("party4", "player", fsConfig.PlayerSortMode.Top, fsConfig.GroupSortMode.Group), false)
end

function M:test_sort_player_bottom()
    assertEquals(fsCompare:Compare("player", "party1", fsConfig.PlayerSortMode.Bottom, fsConfig.GroupSortMode.Group), false)
    assertEquals(fsCompare:Compare("player", "party2", fsConfig.PlayerSortMode.Bottom, fsConfig.GroupSortMode.Group), false)
    assertEquals(fsCompare:Compare("player", "party3", fsConfig.PlayerSortMode.Bottom, fsConfig.GroupSortMode.Group), false)
    assertEquals(fsCompare:Compare("player", "party4", fsConfig.PlayerSortMode.Bottom, fsConfig.GroupSortMode.Group), false)

    assertEquals(fsCompare:Compare("party1", "player", fsConfig.PlayerSortMode.Bottom, fsConfig.GroupSortMode.Group), true)
    assertEquals(fsCompare:Compare("party2", "player", fsConfig.PlayerSortMode.Bottom, fsConfig.GroupSortMode.Group), true)
    assertEquals(fsCompare:Compare("party3", "player", fsConfig.PlayerSortMode.Bottom, fsConfig.GroupSortMode.Group), true)
    assertEquals(fsCompare:Compare("party4", "player", fsConfig.PlayerSortMode.Bottom, fsConfig.GroupSortMode.Group), true)
end

function M:test_sort_player_middle()
    local presorted = { "player", "party1", "party2", "party3", "party4" }
    assertEquals(fsCompare:Compare("player", "party1", fsConfig.PlayerSortMode.Middle, fsConfig.GroupSortMode.Group, false, presorted), false)
    assertEquals(fsCompare:Compare("player", "party2", fsConfig.PlayerSortMode.Middle, fsConfig.GroupSortMode.Group, false, presorted), false)
    -- mid here
    assertEquals(fsCompare:Compare("player", "party3", fsConfig.PlayerSortMode.Middle, fsConfig.GroupSortMode.Group, false, presorted), true)
    assertEquals(fsCompare:Compare("player", "party4", fsConfig.PlayerSortMode.Middle, fsConfig.GroupSortMode.Group, false, presorted), true)

    assertEquals(fsCompare:Compare("party1", "player", fsConfig.PlayerSortMode.Middle, fsConfig.GroupSortMode.Group, false, presorted), true)
    assertEquals(fsCompare:Compare("party2", "player", fsConfig.PlayerSortMode.Middle, fsConfig.GroupSortMode.Group, false, presorted), true)
    -- mid here
    assertEquals(fsCompare:Compare("party3", "player", fsConfig.PlayerSortMode.Middle, fsConfig.GroupSortMode.Group, false, presorted), false)
    assertEquals(fsCompare:Compare("party4", "player", fsConfig.PlayerSortMode.Middle, fsConfig.GroupSortMode.Group, false, presorted), false)
end

function M:test_sort_player_reversed()
    assertEquals(fsCompare:Compare("player", "party1", fsConfig.PlayerSortMode.Top, fsConfig.GroupSortMode.Group), true)
    assertEquals(fsCompare:Compare("player", "party2", fsConfig.PlayerSortMode.Top, fsConfig.GroupSortMode.Group), true)
    assertEquals(fsCompare:Compare("player", "party3", fsConfig.PlayerSortMode.Top, fsConfig.GroupSortMode.Group), true)
    assertEquals(fsCompare:Compare("player", "party4", fsConfig.PlayerSortMode.Top, fsConfig.GroupSortMode.Group), true)

    assertEquals(fsCompare:Compare("party1", "player", fsConfig.PlayerSortMode.Top, fsConfig.GroupSortMode.Group), false)
    assertEquals(fsCompare:Compare("party2", "player", fsConfig.PlayerSortMode.Top, fsConfig.GroupSortMode.Group), false)
    assertEquals(fsCompare:Compare("party3", "player", fsConfig.PlayerSortMode.Top, fsConfig.GroupSortMode.Group), false)
    assertEquals(fsCompare:Compare("party4", "player", fsConfig.PlayerSortMode.Top, fsConfig.GroupSortMode.Group), false)

    assertEquals(fsCompare:Compare("party1", "party2", fsConfig.PlayerSortMode.Top, fsConfig.GroupSortMode.Group, false), true)
    assertEquals(fsCompare:Compare("party1", "party3", fsConfig.PlayerSortMode.Top, fsConfig.GroupSortMode.Group, false), true)
    assertEquals(fsCompare:Compare("party1", "party4", fsConfig.PlayerSortMode.Top, fsConfig.GroupSortMode.Group, false), true)

    assertEquals(fsCompare:Compare("party1", "party2", fsConfig.PlayerSortMode.Top, fsConfig.GroupSortMode.Group, true), false)
    assertEquals(fsCompare:Compare("party1", "party3", fsConfig.PlayerSortMode.Top, fsConfig.GroupSortMode.Group, true), false)
    assertEquals(fsCompare:Compare("party1", "party4", fsConfig.PlayerSortMode.Top, fsConfig.GroupSortMode.Group, true), false)

    assertEquals(fsCompare:Compare("party2", "party1", fsConfig.PlayerSortMode.Top, fsConfig.GroupSortMode.Group, false), false)
    assertEquals(fsCompare:Compare("party2", "party3", fsConfig.PlayerSortMode.Top, fsConfig.GroupSortMode.Group, false), true)
    assertEquals(fsCompare:Compare("party2", "party4", fsConfig.PlayerSortMode.Top, fsConfig.GroupSortMode.Group, false), true)

    assertEquals(fsCompare:Compare("party2", "party1", fsConfig.PlayerSortMode.Top, fsConfig.GroupSortMode.Group, true), true)
    assertEquals(fsCompare:Compare("party2", "party3", fsConfig.PlayerSortMode.Top, fsConfig.GroupSortMode.Group, true), false)
    assertEquals(fsCompare:Compare("party2", "party4", fsConfig.PlayerSortMode.Top, fsConfig.GroupSortMode.Group, true), false)

    assertEquals(fsCompare:Compare("party3", "party1", fsConfig.PlayerSortMode.Top, fsConfig.GroupSortMode.Group, false), false)
    assertEquals(fsCompare:Compare("party3", "party2", fsConfig.PlayerSortMode.Top, fsConfig.GroupSortMode.Group, false), false)
    assertEquals(fsCompare:Compare("party3", "party4", fsConfig.PlayerSortMode.Top, fsConfig.GroupSortMode.Group, false), true)

    assertEquals(fsCompare:Compare("party3", "party1", fsConfig.PlayerSortMode.Top, fsConfig.GroupSortMode.Group, true), true)
    assertEquals(fsCompare:Compare("party3", "party2", fsConfig.PlayerSortMode.Top, fsConfig.GroupSortMode.Group, true), true)
    assertEquals(fsCompare:Compare("party3", "party4", fsConfig.PlayerSortMode.Top, fsConfig.GroupSortMode.Group, true), false)

    assertEquals(fsCompare:Compare("party4", "party1", fsConfig.PlayerSortMode.Top, fsConfig.GroupSortMode.Group, false), false)
    assertEquals(fsCompare:Compare("party4", "party2", fsConfig.PlayerSortMode.Top, fsConfig.GroupSortMode.Group, false), false)
    assertEquals(fsCompare:Compare("party4", "party3", fsConfig.PlayerSortMode.Top, fsConfig.GroupSortMode.Group, false), false)

    assertEquals(fsCompare:Compare("party4", "party1", fsConfig.PlayerSortMode.Top, fsConfig.GroupSortMode.Group, true), true)
    assertEquals(fsCompare:Compare("party4", "party2", fsConfig.PlayerSortMode.Top, fsConfig.GroupSortMode.Group, true), true)
    assertEquals(fsCompare:Compare("party4", "party3", fsConfig.PlayerSortMode.Top, fsConfig.GroupSortMode.Group, true), true)
end

return M
