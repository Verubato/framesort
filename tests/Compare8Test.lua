local deps = {
    "Util\\Enumerable.lua",
    "Type\\SortMode.lua",
    "Core\\Compare.lua"
}

local addon = {}
for _, fileName in ipairs(deps) do
    local module = loadfile("..\\src\\" .. fileName)
    if module == nil then error("Failed to load " .. fileName) end
    module("UnitTest", addon)
end

local fsCompare = addon.Compare
local mock = require("Mock")
local M = {}

function M:setUp()
    -- raids don't have a "player" token, so we'll just say we're raid2
    local playerToken = "raid2"
    local members = mock:GenerateUnits(8)
    UnitExists = function(unit) return unit == "player" or mock:UnitExists(unit, members) end
    UnitIsUnit = function(left, right) return left == right or (left == playerToken and right == "player") end
end

function M:test_sort_player_top()
    assertEquals(fsCompare:Compare("player", "raid1", addon.PlayerSortMode.Top, addon.GroupSortMode.Group), true)
    -- don't compare raid2 as that's the player
    assertEquals(fsCompare:Compare("player", "raid3", addon.PlayerSortMode.Top, addon.GroupSortMode.Group), true)
    assertEquals(fsCompare:Compare("player", "raid4", addon.PlayerSortMode.Top, addon.GroupSortMode.Group), true)
    assertEquals(fsCompare:Compare("player", "raid5", addon.PlayerSortMode.Top, addon.GroupSortMode.Group), true)
    assertEquals(fsCompare:Compare("player", "raid6", addon.PlayerSortMode.Top, addon.GroupSortMode.Group), true)
    assertEquals(fsCompare:Compare("player", "raid7", addon.PlayerSortMode.Top, addon.GroupSortMode.Group), true)
    assertEquals(fsCompare:Compare("player", "raid8", addon.PlayerSortMode.Top, addon.GroupSortMode.Group), true)

    assertEquals(fsCompare:Compare("raid1", "player", addon.PlayerSortMode.Top, addon.GroupSortMode.Group), false)
    assertEquals(fsCompare:Compare("raid3", "player", addon.PlayerSortMode.Top, addon.GroupSortMode.Group), false)
    assertEquals(fsCompare:Compare("raid4", "player", addon.PlayerSortMode.Top, addon.GroupSortMode.Group), false)
    assertEquals(fsCompare:Compare("raid5", "player", addon.PlayerSortMode.Top, addon.GroupSortMode.Group), false)
    assertEquals(fsCompare:Compare("raid6", "player", addon.PlayerSortMode.Top, addon.GroupSortMode.Group), false)
    assertEquals(fsCompare:Compare("raid7", "player", addon.PlayerSortMode.Top, addon.GroupSortMode.Group), false)
    assertEquals(fsCompare:Compare("raid8", "player", addon.PlayerSortMode.Top, addon.GroupSortMode.Group), false)
end

function M:test_sort_player_bottom()
    assertEquals(fsCompare:Compare("player", "raid1", addon.PlayerSortMode.Bottom, addon.GroupSortMode.Group), false)
    assertEquals(fsCompare:Compare("player", "raid3", addon.PlayerSortMode.Bottom, addon.GroupSortMode.Group), false)
    assertEquals(fsCompare:Compare("player", "raid4", addon.PlayerSortMode.Bottom, addon.GroupSortMode.Group), false)
    assertEquals(fsCompare:Compare("player", "raid5", addon.PlayerSortMode.Bottom, addon.GroupSortMode.Group), false)
    assertEquals(fsCompare:Compare("player", "raid6", addon.PlayerSortMode.Bottom, addon.GroupSortMode.Group), false)
    assertEquals(fsCompare:Compare("player", "raid7", addon.PlayerSortMode.Bottom, addon.GroupSortMode.Group), false)
    assertEquals(fsCompare:Compare("player", "raid8", addon.PlayerSortMode.Bottom, addon.GroupSortMode.Group), false)

    assertEquals(fsCompare:Compare("raid1", "player", addon.PlayerSortMode.Bottom, addon.GroupSortMode.Group), true)
    assertEquals(fsCompare:Compare("raid3", "player", addon.PlayerSortMode.Bottom, addon.GroupSortMode.Group), true)
    assertEquals(fsCompare:Compare("raid4", "player", addon.PlayerSortMode.Bottom, addon.GroupSortMode.Group), true)
    assertEquals(fsCompare:Compare("raid5", "player", addon.PlayerSortMode.Bottom, addon.GroupSortMode.Group), true)
    assertEquals(fsCompare:Compare("raid6", "player", addon.PlayerSortMode.Bottom, addon.GroupSortMode.Group), true)
    assertEquals(fsCompare:Compare("raid7", "player", addon.PlayerSortMode.Bottom, addon.GroupSortMode.Group), true)
    assertEquals(fsCompare:Compare("raid8", "player", addon.PlayerSortMode.Bottom, addon.GroupSortMode.Group), true)
end

function M:test_sort_player_middle()
    local presorted = { "raid1", "raid2", "raid3", "raid4", "raid5", "raid6", "raid7", "raid8" }
    assertEquals(fsCompare:Compare("player", "raid1", addon.PlayerSortMode.Middle, addon.GroupSortMode.Group, false, presorted), false)
    assertEquals(fsCompare:Compare("player", "raid3", addon.PlayerSortMode.Middle, addon.GroupSortMode.Group, false, presorted), false)
    assertEquals(fsCompare:Compare("player", "raid4", addon.PlayerSortMode.Middle, addon.GroupSortMode.Group, false, presorted), false)
    assertEquals(fsCompare:Compare("player", "raid5", addon.PlayerSortMode.Middle, addon.GroupSortMode.Group, false, presorted), false)
    -- there's no exact mid as we have an even number of raid members
    assertEquals(fsCompare:Compare("player", "raid6", addon.PlayerSortMode.Middle, addon.GroupSortMode.Group, false, presorted), true)
    assertEquals(fsCompare:Compare("player", "raid7", addon.PlayerSortMode.Middle, addon.GroupSortMode.Group, false, presorted), true)
    assertEquals(fsCompare:Compare("player", "raid8", addon.PlayerSortMode.Middle, addon.GroupSortMode.Group, false, presorted), true)
end

return M
