local deps = {
    "Types\\SortMode.lua",
    "Util\\Enumerable.lua",
    "Util\\Compare.lua",
}

local addon = nil
local M = {}

function M:setUp()
    addon = { WoW = {} }

    local helper = require("Helper")
    helper:LoadDependencies(addon, deps)

    local members = helper:GenerateUnits(3)
    addon.WoW.UnitExists = function(unit)
        return helper:UnitExists(unit, members)
    end
    addon.WoW.IsInGroup = function()
        return true
    end
    addon.WoW.UnitIsUnit = function(left, right)
        return left == right
    end
end

function M:test_sort_with_nonexistant_units()
    assertEquals(addon.Compare:Compare("party3", "player", addon.PlayerSortMode.Top, addon.GroupSortMode.Group), false)
    assertEquals(addon.Compare:Compare("player", "party3", addon.PlayerSortMode.Top, addon.GroupSortMode.Group), true)
end

function M:test_sort_player_top()
    assertEquals(addon.Compare:Compare("player", "party1", addon.PlayerSortMode.Top, addon.GroupSortMode.Group), true)
    assertEquals(addon.Compare:Compare("player", "party2", addon.PlayerSortMode.Top, addon.GroupSortMode.Group), true)

    assertEquals(addon.Compare:Compare("party1", "party2", addon.PlayerSortMode.Top, addon.GroupSortMode.Group), true)
    assertEquals(addon.Compare:Compare("party2", "party1", addon.PlayerSortMode.Top, addon.GroupSortMode.Group), false)

    assertEquals(addon.Compare:Compare("party1", "player", addon.PlayerSortMode.Top, addon.GroupSortMode.Group), false)
    assertEquals(addon.Compare:Compare("party2", "player", addon.PlayerSortMode.Top, addon.GroupSortMode.Group), false)
end

function M:test_sort_player_bottom()
    assertEquals(addon.Compare:Compare("player", "party1", addon.PlayerSortMode.Bottom, addon.GroupSortMode.Group), false)
    assertEquals(addon.Compare:Compare("player", "party2", addon.PlayerSortMode.Bottom, addon.GroupSortMode.Group), false)

    assertEquals(addon.Compare:Compare("party1", "party2", addon.PlayerSortMode.Bottom, addon.GroupSortMode.Group), true)
    assertEquals(addon.Compare:Compare("party2", "party1", addon.PlayerSortMode.Bottom, addon.GroupSortMode.Group), false)

    assertEquals(addon.Compare:Compare("party1", "player", addon.PlayerSortMode.Bottom, addon.GroupSortMode.Group), true)
    assertEquals(addon.Compare:Compare("party2", "player", addon.PlayerSortMode.Bottom, addon.GroupSortMode.Group), true)
end

function M:test_sort_player_middle()
    local presorted = { "player", "party1", "party2" }
    assertEquals(addon.Compare:Compare("player", "party1", addon.PlayerSortMode.Middle, addon.GroupSortMode.Group, false, presorted), false)
    assertEquals(addon.Compare:Compare("player", "party2", addon.PlayerSortMode.Middle, addon.GroupSortMode.Group, false, presorted), true)

    assertEquals(addon.Compare:Compare("party1", "party2", addon.PlayerSortMode.Middle, addon.GroupSortMode.Group, false, presorted), true)
    assertEquals(addon.Compare:Compare("party2", "party1", addon.PlayerSortMode.Middle, addon.GroupSortMode.Group, false, presorted), false)

    assertEquals(addon.Compare:Compare("party1", "player", addon.PlayerSortMode.Middle, addon.GroupSortMode.Group, false, presorted), true)
    assertEquals(addon.Compare:Compare("party2", "player", addon.PlayerSortMode.Middle, addon.GroupSortMode.Group, false, presorted), false)
end

return M
