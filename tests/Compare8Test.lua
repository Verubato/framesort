local deps = {
    "Type\\SortMode.lua",
    "Core\\Compare.lua"
}

local addon = {}
for _, fileName in ipairs(deps) do
    local module = loadfile("..\\src\\" .. fileName)
    if module == nil then error("Failed to load " .. fileName) end
    module("UnitTest", addon)
end

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
    assertEquals(addon:Compare("player", "raid1", addon.SortMode.Top, addon.SortMode.Group), true)
    -- don't compare raid2 as that's the player
    assertEquals(addon:Compare("player", "raid3", addon.SortMode.Top, addon.SortMode.Group), true)
    assertEquals(addon:Compare("player", "raid4", addon.SortMode.Top, addon.SortMode.Group), true)
    assertEquals(addon:Compare("player", "raid5", addon.SortMode.Top, addon.SortMode.Group), true)
    assertEquals(addon:Compare("player", "raid6", addon.SortMode.Top, addon.SortMode.Group), true)
    assertEquals(addon:Compare("player", "raid7", addon.SortMode.Top, addon.SortMode.Group), true)
    assertEquals(addon:Compare("player", "raid8", addon.SortMode.Top, addon.SortMode.Group), true)

    assertEquals(addon:Compare("raid1", "player", addon.SortMode.Top, addon.SortMode.Group), false)
    assertEquals(addon:Compare("raid3", "player", addon.SortMode.Top, addon.SortMode.Group), false)
    assertEquals(addon:Compare("raid4", "player", addon.SortMode.Top, addon.SortMode.Group), false)
    assertEquals(addon:Compare("raid5", "player", addon.SortMode.Top, addon.SortMode.Group), false)
    assertEquals(addon:Compare("raid6", "player", addon.SortMode.Top, addon.SortMode.Group), false)
    assertEquals(addon:Compare("raid7", "player", addon.SortMode.Top, addon.SortMode.Group), false)
    assertEquals(addon:Compare("raid8", "player", addon.SortMode.Top, addon.SortMode.Group), false)
end

function M:test_sort_player_bottom()
    assertEquals(addon:Compare("player", "raid1", addon.SortMode.Bottom, addon.SortMode.Group), false)
    assertEquals(addon:Compare("player", "raid3", addon.SortMode.Bottom, addon.SortMode.Group), false)
    assertEquals(addon:Compare("player", "raid4", addon.SortMode.Bottom, addon.SortMode.Group), false)
    assertEquals(addon:Compare("player", "raid5", addon.SortMode.Bottom, addon.SortMode.Group), false)
    assertEquals(addon:Compare("player", "raid6", addon.SortMode.Bottom, addon.SortMode.Group), false)
    assertEquals(addon:Compare("player", "raid7", addon.SortMode.Bottom, addon.SortMode.Group), false)
    assertEquals(addon:Compare("player", "raid8", addon.SortMode.Bottom, addon.SortMode.Group), false)

    assertEquals(addon:Compare("raid1", "player", addon.SortMode.Bottom, addon.SortMode.Group), true)
    assertEquals(addon:Compare("raid3", "player", addon.SortMode.Bottom, addon.SortMode.Group), true)
    assertEquals(addon:Compare("raid4", "player", addon.SortMode.Bottom, addon.SortMode.Group), true)
    assertEquals(addon:Compare("raid5", "player", addon.SortMode.Bottom, addon.SortMode.Group), true)
    assertEquals(addon:Compare("raid6", "player", addon.SortMode.Bottom, addon.SortMode.Group), true)
    assertEquals(addon:Compare("raid7", "player", addon.SortMode.Bottom, addon.SortMode.Group), true)
    assertEquals(addon:Compare("raid8", "player", addon.SortMode.Bottom, addon.SortMode.Group), true)
end

function M:test_sort_player_middle()
    local presorted = { "raid1", "raid2", "raid3", "raid4", "raid5", "raid6", "raid7", "raid8" }
    assertEquals(addon:Compare("player", "raid1", addon.SortMode.Middle, addon.SortMode.Group, presorted), false)
    assertEquals(addon:Compare("player", "raid3", addon.SortMode.Middle, addon.SortMode.Group, presorted), false)
    assertEquals(addon:Compare("player", "raid4", addon.SortMode.Middle, addon.SortMode.Group, presorted), false)
    assertEquals(addon:Compare("player", "raid5", addon.SortMode.Middle, addon.SortMode.Group, presorted), false)
    -- there's no exact mid as we have an even number of raid members
    assertEquals(addon:Compare("player", "raid6", addon.SortMode.Middle, addon.SortMode.Group, presorted), true)
    assertEquals(addon:Compare("player", "raid7", addon.SortMode.Middle, addon.SortMode.Group, presorted), true)
    assertEquals(addon:Compare("player", "raid8", addon.SortMode.Middle, addon.SortMode.Group, presorted), true)
end

return M
