local subject = loadfile("..\\src\\Core.lua")
if subject == nil then error('Failed to load Core.lua') end

local options = loadfile("..\\src\\Options.lua")
if options == nil then error('Failed to load Options.lua') end

local addon = {}
subject("UnitTest", addon)
options("UnitTest", addon)

-- wow api mocks
UnitExists = function(token) return string.match(token, "exists") end
UnitIsUnit = function(left, right)
    assertEquals(right, "player")
    return string.match(left, "player")
end

M = {}

function M:test_sort_with_nonexistant_units()
    assertEquals(addon:Compare("noone", "noone", addon.SortMode.Top, addon.SortMode.Group), false)
    assertEquals(addon:Compare("exists", "noone", addon.SortMode.Top, addon.SortMode.Group), true)
end

function M:test_sort_player_top()
    assertEquals(addon:Compare("playerexists", "party1exists", addon.SortMode.Top, addon.SortMode.Group), true)
    assertEquals(addon:Compare("playerexists", "party2exists", addon.SortMode.Top, addon.SortMode.Group), true)

    assertEquals(addon:Compare("party1exists", "playerexists", addon.SortMode.Top, addon.SortMode.Group), false)
    assertEquals(addon:Compare("party2exists", "playerexists", addon.SortMode.Top, addon.SortMode.Group), false)
end

function M:test_sort_player_bottom()
    assertEquals(addon:Compare("playerexists", "party1exists", addon.SortMode.Bottom, addon.SortMode.Group), false)
    assertEquals(addon:Compare("playerexists", "party2exists", addon.SortMode.Bottom, addon.SortMode.Group), false)

    assertEquals(addon:Compare("party1exists", "playerexists", addon.SortMode.Bottom, addon.SortMode.Group), true)
    assertEquals(addon:Compare("party2exists", "playerexists", addon.SortMode.Bottom, addon.SortMode.Group), true)
end

return M
