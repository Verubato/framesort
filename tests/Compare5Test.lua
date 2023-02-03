local subject = loadfile("..\\src\\Core.lua")
if subject == nil then error('Failed to load Core.lua') end

local options = loadfile("..\\src\\Options.lua")
if options == nil then error('Failed to load Options.lua') end

local addon = {}
subject("UnitTest", addon)
options("UnitTest", addon)

local mock = require("Mock")
local M = {}

function M:setUp()
    -- wow api mocks
    local members = mock:GenerateUnits(5)
    UnitExists = function(unit) return mock:UnitExists(unit, members) end
    UnitIsUnit = function(left, right) return left == right end
end

function M:test_sort_player_top()
    assertEquals(addon:Compare("player", "party1", addon.SortMode.Top, addon.SortMode.Group), true)
    assertEquals(addon:Compare("player", "party2", addon.SortMode.Top, addon.SortMode.Group), true)
    assertEquals(addon:Compare("player", "party3", addon.SortMode.Top, addon.SortMode.Group), true)
    assertEquals(addon:Compare("player", "party4", addon.SortMode.Top, addon.SortMode.Group), true)

    assertEquals(addon:Compare("party1", "player", addon.SortMode.Top, addon.SortMode.Group), false)
    assertEquals(addon:Compare("party2", "player", addon.SortMode.Top, addon.SortMode.Group), false)
    assertEquals(addon:Compare("party3", "player", addon.SortMode.Top, addon.SortMode.Group), false)
    assertEquals(addon:Compare("party4", "player", addon.SortMode.Top, addon.SortMode.Group), false)
end

function M:test_sort_player_bottom()
    assertEquals(addon:Compare("player", "party1", addon.SortMode.Bottom, addon.SortMode.Group), false)
    assertEquals(addon:Compare("player", "party2", addon.SortMode.Bottom, addon.SortMode.Group), false)
    assertEquals(addon:Compare("player", "party3", addon.SortMode.Bottom, addon.SortMode.Group), false)
    assertEquals(addon:Compare("player", "party4", addon.SortMode.Bottom, addon.SortMode.Group), false)

    assertEquals(addon:Compare("party1", "player", addon.SortMode.Bottom, addon.SortMode.Group), true)
    assertEquals(addon:Compare("party2", "player", addon.SortMode.Bottom, addon.SortMode.Group), true)
    assertEquals(addon:Compare("party3", "player", addon.SortMode.Bottom, addon.SortMode.Group), true)
    assertEquals(addon:Compare("party4", "player", addon.SortMode.Bottom, addon.SortMode.Group), true)
end

function M:test_sort_player_middle()
    local presorted = { "player", "party1", "party2", "party3", "party4" }
    assertEquals(addon:Compare("player", "party1", addon.SortMode.Middle, addon.SortMode.Group, presorted), false)
    assertEquals(addon:Compare("player", "party2", addon.SortMode.Middle, addon.SortMode.Group, presorted), false)
    -- mid here
    assertEquals(addon:Compare("player", "party3", addon.SortMode.Middle, addon.SortMode.Group, presorted), true)
    assertEquals(addon:Compare("player", "party4", addon.SortMode.Middle, addon.SortMode.Group, presorted), true)

    assertEquals(addon:Compare("party1", "player", addon.SortMode.Middle, addon.SortMode.Group, presorted), true)
    assertEquals(addon:Compare("party2", "player", addon.SortMode.Middle, addon.SortMode.Group, presorted), true)
    -- mid here
    assertEquals(addon:Compare("party3", "player", addon.SortMode.Middle, addon.SortMode.Group, presorted), false)
    assertEquals(addon:Compare("party4", "player", addon.SortMode.Middle, addon.SortMode.Group, presorted), false)
end

return M

