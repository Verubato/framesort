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

local mock = require("Mock")
local fsCompare = addon.Compare
local M = {}

function M:setUp()
    -- wow api mocks
    local members = mock:GenerateUnits(3)
    UnitExists = function(unit) return mock:UnitExists(unit, members) end
    UnitIsUnit = function(left, right) return left == right end
    CRFSort_Group = function(left, right) return left < right end
end

function M:test_sort_with_nonexistant_units()
    assertEquals(fsCompare:Compare("party3", "player", addon.PlayerSortMode.Top, addon.GroupSortMode.Group), false)
    assertEquals(fsCompare:Compare("player", "party3", addon.PlayerSortMode.Top, addon.GroupSortMode.Group), true)
end

function M:test_sort_player_top()
    assertEquals(fsCompare:Compare("player", "party1", addon.PlayerSortMode.Top, addon.GroupSortMode.Group), true)
    assertEquals(fsCompare:Compare("player", "party2", addon.PlayerSortMode.Top, addon.GroupSortMode.Group), true)

    assertEquals(fsCompare:Compare("party1", "party2", addon.PlayerSortMode.Top, addon.GroupSortMode.Group), true)
    assertEquals(fsCompare:Compare("party2", "party1", addon.PlayerSortMode.Top, addon.GroupSortMode.Group), false)

    assertEquals(fsCompare:Compare("party1", "player", addon.PlayerSortMode.Top, addon.GroupSortMode.Group), false)
    assertEquals(fsCompare:Compare("party2", "player", addon.PlayerSortMode.Top, addon.GroupSortMode.Group), false)
end

function M:test_sort_player_bottom()
    assertEquals(fsCompare:Compare("player", "party1", addon.PlayerSortMode.Bottom, addon.GroupSortMode.Group), false)
    assertEquals(fsCompare:Compare("player", "party2", addon.PlayerSortMode.Bottom, addon.GroupSortMode.Group), false)

    assertEquals(fsCompare:Compare("party1", "party2", addon.PlayerSortMode.Bottom, addon.GroupSortMode.Group), true)
    assertEquals(fsCompare:Compare("party2", "party1", addon.PlayerSortMode.Bottom, addon.GroupSortMode.Group), false)

    assertEquals(fsCompare:Compare("party1", "player", addon.PlayerSortMode.Bottom, addon.GroupSortMode.Group), true)
    assertEquals(fsCompare:Compare("party2", "player", addon.PlayerSortMode.Bottom, addon.GroupSortMode.Group), true)
end

function M:test_sort_player_middle()
    local presorted = { "player", "party1", "party2" }
    assertEquals(fsCompare:Compare("player", "party1", addon.PlayerSortMode.Middle, addon.GroupSortMode.Group, false, presorted), false)
    assertEquals(fsCompare:Compare("player", "party2", addon.PlayerSortMode.Middle, addon.GroupSortMode.Group, false, presorted), true)

    assertEquals(fsCompare:Compare("party1", "party2", addon.PlayerSortMode.Middle, addon.GroupSortMode.Group, false, presorted), true)
    assertEquals(fsCompare:Compare("party2", "party1", addon.PlayerSortMode.Middle, addon.GroupSortMode.Group, false, presorted), false)

    assertEquals(fsCompare:Compare("party1", "player", addon.PlayerSortMode.Middle, addon.GroupSortMode.Group, false, presorted), true)
    assertEquals(fsCompare:Compare("party2", "player", addon.PlayerSortMode.Middle, addon.GroupSortMode.Group, false, presorted), false)
end

return M
