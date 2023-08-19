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

    fsCompare = addon.Collections.Comparer
    fsConfig = addon.Configuration
end

function M:test_sort_player_top()
    assertEquals(fsCompare:Compare("player", "raid1", fsConfig.PlayerSortMode.Top, fsConfig.GroupSortMode.Group), true)
    -- don't compare raid2 as that's the player
    assertEquals(fsCompare:Compare("player", "raid3", fsConfig.PlayerSortMode.Top, fsConfig.GroupSortMode.Group), true)
    assertEquals(fsCompare:Compare("player", "raid4", fsConfig.PlayerSortMode.Top, fsConfig.GroupSortMode.Group), true)
    assertEquals(fsCompare:Compare("player", "raid5", fsConfig.PlayerSortMode.Top, fsConfig.GroupSortMode.Group), true)
    assertEquals(fsCompare:Compare("player", "raid6", fsConfig.PlayerSortMode.Top, fsConfig.GroupSortMode.Group), true)
    assertEquals(fsCompare:Compare("player", "raid7", fsConfig.PlayerSortMode.Top, fsConfig.GroupSortMode.Group), true)
    assertEquals(fsCompare:Compare("player", "raid8", fsConfig.PlayerSortMode.Top, fsConfig.GroupSortMode.Group), true)

    assertEquals(fsCompare:Compare("raid1", "player", fsConfig.PlayerSortMode.Top, fsConfig.GroupSortMode.Group), false)
    assertEquals(fsCompare:Compare("raid3", "player", fsConfig.PlayerSortMode.Top, fsConfig.GroupSortMode.Group), false)
    assertEquals(fsCompare:Compare("raid4", "player", fsConfig.PlayerSortMode.Top, fsConfig.GroupSortMode.Group), false)
    assertEquals(fsCompare:Compare("raid5", "player", fsConfig.PlayerSortMode.Top, fsConfig.GroupSortMode.Group), false)
    assertEquals(fsCompare:Compare("raid6", "player", fsConfig.PlayerSortMode.Top, fsConfig.GroupSortMode.Group), false)
    assertEquals(fsCompare:Compare("raid7", "player", fsConfig.PlayerSortMode.Top, fsConfig.GroupSortMode.Group), false)
    assertEquals(fsCompare:Compare("raid8", "player", fsConfig.PlayerSortMode.Top, fsConfig.GroupSortMode.Group), false)
end

function M:test_sort_player_bottom()
    assertEquals(fsCompare:Compare("player", "raid1", fsConfig.PlayerSortMode.Bottom, fsConfig.GroupSortMode.Group), false)
    assertEquals(fsCompare:Compare("player", "raid3", fsConfig.PlayerSortMode.Bottom, fsConfig.GroupSortMode.Group), false)
    assertEquals(fsCompare:Compare("player", "raid4", fsConfig.PlayerSortMode.Bottom, fsConfig.GroupSortMode.Group), false)
    assertEquals(fsCompare:Compare("player", "raid5", fsConfig.PlayerSortMode.Bottom, fsConfig.GroupSortMode.Group), false)
    assertEquals(fsCompare:Compare("player", "raid6", fsConfig.PlayerSortMode.Bottom, fsConfig.GroupSortMode.Group), false)
    assertEquals(fsCompare:Compare("player", "raid7", fsConfig.PlayerSortMode.Bottom, fsConfig.GroupSortMode.Group), false)
    assertEquals(fsCompare:Compare("player", "raid8", fsConfig.PlayerSortMode.Bottom, fsConfig.GroupSortMode.Group), false)

    assertEquals(fsCompare:Compare("raid1", "player", fsConfig.PlayerSortMode.Bottom, fsConfig.GroupSortMode.Group), true)
    assertEquals(fsCompare:Compare("raid3", "player", fsConfig.PlayerSortMode.Bottom, fsConfig.GroupSortMode.Group), true)
    assertEquals(fsCompare:Compare("raid4", "player", fsConfig.PlayerSortMode.Bottom, fsConfig.GroupSortMode.Group), true)
    assertEquals(fsCompare:Compare("raid5", "player", fsConfig.PlayerSortMode.Bottom, fsConfig.GroupSortMode.Group), true)
    assertEquals(fsCompare:Compare("raid6", "player", fsConfig.PlayerSortMode.Bottom, fsConfig.GroupSortMode.Group), true)
    assertEquals(fsCompare:Compare("raid7", "player", fsConfig.PlayerSortMode.Bottom, fsConfig.GroupSortMode.Group), true)
    assertEquals(fsCompare:Compare("raid8", "player", fsConfig.PlayerSortMode.Bottom, fsConfig.GroupSortMode.Group), true)
end

function M:test_sort_player_middle()
    local presorted = { "raid1", "raid2", "raid3", "raid4", "raid5", "raid6", "raid7", "raid8" }
    assertEquals(fsCompare:Compare("player", "raid1", fsConfig.PlayerSortMode.Middle, fsConfig.GroupSortMode.Group, false, presorted), false)
    assertEquals(fsCompare:Compare("player", "raid3", fsConfig.PlayerSortMode.Middle, fsConfig.GroupSortMode.Group, false, presorted), false)
    assertEquals(fsCompare:Compare("player", "raid4", fsConfig.PlayerSortMode.Middle, fsConfig.GroupSortMode.Group, false, presorted), false)
    assertEquals(fsCompare:Compare("player", "raid5", fsConfig.PlayerSortMode.Middle, fsConfig.GroupSortMode.Group, false, presorted), false)
    -- there's no exact mid as we have an even number of raid members
    assertEquals(fsCompare:Compare("player", "raid6", fsConfig.PlayerSortMode.Middle, fsConfig.GroupSortMode.Group, false, presorted), true)
    assertEquals(fsCompare:Compare("player", "raid7", fsConfig.PlayerSortMode.Middle, fsConfig.GroupSortMode.Group, false, presorted), true)
    assertEquals(fsCompare:Compare("player", "raid8", fsConfig.PlayerSortMode.Middle, fsConfig.GroupSortMode.Group, false, presorted), true)
end

return M
