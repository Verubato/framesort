local deps = {
    "Type\\SortMode.lua",
    "Util\\Enumerable.lua",
    "Util\\Compare.lua",
}

local addon = nil
local M = {}

function M:setUp()
    addon = { WoW = {} }

    local helper = require("Helper")
    helper:LoadDependencies(addon, deps)

    local playerToken = "raid2"
    local members = helper:GenerateUnits(8)
    addon.WoW.UnitExists = function(unit)
        return unit == "player" or helper:UnitExists(unit, members)
    end
    addon.WoW.IsInGroup = function()
        return true
    end
    addon.WoW.UnitIsUnit = function(left, right)
        return left == right or (left == playerToken and right == "player")
    end
end

function M:test_sort_player_top()
    assertEquals(addon.Compare:Compare("player", "raid1", addon.PlayerSortMode.Top, addon.GroupSortMode.Group), true)
    -- don't compare raid2 as that's the player
    assertEquals(addon.Compare:Compare("player", "raid3", addon.PlayerSortMode.Top, addon.GroupSortMode.Group), true)
    assertEquals(addon.Compare:Compare("player", "raid4", addon.PlayerSortMode.Top, addon.GroupSortMode.Group), true)
    assertEquals(addon.Compare:Compare("player", "raid5", addon.PlayerSortMode.Top, addon.GroupSortMode.Group), true)
    assertEquals(addon.Compare:Compare("player", "raid6", addon.PlayerSortMode.Top, addon.GroupSortMode.Group), true)
    assertEquals(addon.Compare:Compare("player", "raid7", addon.PlayerSortMode.Top, addon.GroupSortMode.Group), true)
    assertEquals(addon.Compare:Compare("player", "raid8", addon.PlayerSortMode.Top, addon.GroupSortMode.Group), true)

    assertEquals(addon.Compare:Compare("raid1", "player", addon.PlayerSortMode.Top, addon.GroupSortMode.Group), false)
    assertEquals(addon.Compare:Compare("raid3", "player", addon.PlayerSortMode.Top, addon.GroupSortMode.Group), false)
    assertEquals(addon.Compare:Compare("raid4", "player", addon.PlayerSortMode.Top, addon.GroupSortMode.Group), false)
    assertEquals(addon.Compare:Compare("raid5", "player", addon.PlayerSortMode.Top, addon.GroupSortMode.Group), false)
    assertEquals(addon.Compare:Compare("raid6", "player", addon.PlayerSortMode.Top, addon.GroupSortMode.Group), false)
    assertEquals(addon.Compare:Compare("raid7", "player", addon.PlayerSortMode.Top, addon.GroupSortMode.Group), false)
    assertEquals(addon.Compare:Compare("raid8", "player", addon.PlayerSortMode.Top, addon.GroupSortMode.Group), false)
end

function M:test_sort_player_bottom()
    assertEquals(addon.Compare:Compare("player", "raid1", addon.PlayerSortMode.Bottom, addon.GroupSortMode.Group), false)
    assertEquals(addon.Compare:Compare("player", "raid3", addon.PlayerSortMode.Bottom, addon.GroupSortMode.Group), false)
    assertEquals(addon.Compare:Compare("player", "raid4", addon.PlayerSortMode.Bottom, addon.GroupSortMode.Group), false)
    assertEquals(addon.Compare:Compare("player", "raid5", addon.PlayerSortMode.Bottom, addon.GroupSortMode.Group), false)
    assertEquals(addon.Compare:Compare("player", "raid6", addon.PlayerSortMode.Bottom, addon.GroupSortMode.Group), false)
    assertEquals(addon.Compare:Compare("player", "raid7", addon.PlayerSortMode.Bottom, addon.GroupSortMode.Group), false)
    assertEquals(addon.Compare:Compare("player", "raid8", addon.PlayerSortMode.Bottom, addon.GroupSortMode.Group), false)

    assertEquals(addon.Compare:Compare("raid1", "player", addon.PlayerSortMode.Bottom, addon.GroupSortMode.Group), true)
    assertEquals(addon.Compare:Compare("raid3", "player", addon.PlayerSortMode.Bottom, addon.GroupSortMode.Group), true)
    assertEquals(addon.Compare:Compare("raid4", "player", addon.PlayerSortMode.Bottom, addon.GroupSortMode.Group), true)
    assertEquals(addon.Compare:Compare("raid5", "player", addon.PlayerSortMode.Bottom, addon.GroupSortMode.Group), true)
    assertEquals(addon.Compare:Compare("raid6", "player", addon.PlayerSortMode.Bottom, addon.GroupSortMode.Group), true)
    assertEquals(addon.Compare:Compare("raid7", "player", addon.PlayerSortMode.Bottom, addon.GroupSortMode.Group), true)
    assertEquals(addon.Compare:Compare("raid8", "player", addon.PlayerSortMode.Bottom, addon.GroupSortMode.Group), true)
end

function M:test_sort_player_middle()
    local presorted = { "raid1", "raid2", "raid3", "raid4", "raid5", "raid6", "raid7", "raid8" }
    assertEquals(addon.Compare:Compare("player", "raid1", addon.PlayerSortMode.Middle, addon.GroupSortMode.Group, false, presorted), false)
    assertEquals(addon.Compare:Compare("player", "raid3", addon.PlayerSortMode.Middle, addon.GroupSortMode.Group, false, presorted), false)
    assertEquals(addon.Compare:Compare("player", "raid4", addon.PlayerSortMode.Middle, addon.GroupSortMode.Group, false, presorted), false)
    assertEquals(addon.Compare:Compare("player", "raid5", addon.PlayerSortMode.Middle, addon.GroupSortMode.Group, false, presorted), false)
    -- there's no exact mid as we have an even number of raid members
    assertEquals(addon.Compare:Compare("player", "raid6", addon.PlayerSortMode.Middle, addon.GroupSortMode.Group, false, presorted), true)
    assertEquals(addon.Compare:Compare("player", "raid7", addon.PlayerSortMode.Middle, addon.GroupSortMode.Group, false, presorted), true)
    assertEquals(addon.Compare:Compare("player", "raid8", addon.PlayerSortMode.Middle, addon.GroupSortMode.Group, false, presorted), true)
end

return M
