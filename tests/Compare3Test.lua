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
    -- wow api mocks
    local members = mock:GenerateUnits(3)
    UnitExists = function(unit) return mock:UnitExists(unit, members) end
    UnitIsUnit = function(left, right) return left == right end
end

function M:test_sort_with_nonexistant_units()
    assertEquals(addon:Compare("party3", "player", addon.SortMode.Top, addon.SortMode.Group), false)
    assertEquals(addon:Compare("player", "party3", addon.SortMode.Top, addon.SortMode.Group), true)
end

function M:test_sort_player_top()
    assertEquals(addon:Compare("player", "party1", addon.SortMode.Top, addon.SortMode.Group), true)
    assertEquals(addon:Compare("player", "party2", addon.SortMode.Top, addon.SortMode.Group), true)

    assertEquals(addon:Compare("party1", "player", addon.SortMode.Top, addon.SortMode.Group), false)
    assertEquals(addon:Compare("party2", "player", addon.SortMode.Top, addon.SortMode.Group), false)
end

function M:test_sort_player_bottom()
    assertEquals(addon:Compare("player", "party1", addon.SortMode.Bottom, addon.SortMode.Group), false)
    assertEquals(addon:Compare("player", "party2", addon.SortMode.Bottom, addon.SortMode.Group), false)

    assertEquals(addon:Compare("party1", "player", addon.SortMode.Bottom, addon.SortMode.Group), true)
    assertEquals(addon:Compare("party2", "player", addon.SortMode.Bottom, addon.SortMode.Group), true)
end

function M:test_sort_player_middle()
    local presorted = { "player", "party1", "party2" }
    assertEquals(addon:Compare("player", "party1", addon.SortMode.Middle, addon.SortMode.Group, presorted), false)
    assertEquals(addon:Compare("player", "party2", addon.SortMode.Middle, addon.SortMode.Group, presorted), true)

    assertEquals(addon:Compare("party1", "player", addon.SortMode.Middle, addon.SortMode.Group, presorted), true)
    assertEquals(addon:Compare("party2", "player", addon.SortMode.Middle, addon.SortMode.Group, presorted), false)
end

return M
