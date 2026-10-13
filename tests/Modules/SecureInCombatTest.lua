---@diagnostic disable: duplicate-set-field, cast-local-type

---@type Addon
local addon
local wow
local events
---@type SortedUnits
local fsSortedUnits
local M = {}

function M:setup()
    local addonFactory = require("TestHarness.AddonFactory")

    addon = addonFactory:Create()
    wow = addon.WoW.Api
    events = addon.WoW.Events
    fsSortedUnits = addon.Modules.Sorting.SortedUnits

    addon.Modules:Init()
end

function M:teardown()
    addon = nil
    wow = nil
    events = nil
    fsSortedUnits = nil
end

function M:test_combat_starting_invalidates_the_friendly_cache_before_loading_units()
    local invalidated = 0
    local invalidatedWhenLoaded = nil
    local originalInvalidate = fsSortedUnits.InvalidateFriendlyCache
    local originalFriendlyUnits = fsSortedUnits.FriendlyUnits

    fsSortedUnits.InvalidateFriendlyCache = function(...)
        invalidated = invalidated + 1
        return originalInvalidate(...)
    end

    fsSortedUnits.FriendlyUnits = function(...)
        invalidatedWhenLoaded = invalidatedWhenLoaded or invalidated
        return originalFriendlyUnits(...)
    end

    wow.FireEvent(events.PLAYER_REGEN_DISABLED)

    assert(invalidated == 1)
    assert(invalidatedWhenLoaded == 1)
end

function M:test_combat_starting_loads_enemy_spacing_only_from_the_sort_mode()
    addon.DB.Options.Sorting.Method = addon.Configuration.SortingMethod.Secure
    addon.Modules.Sorting.Secure:Init()
    addon.Modules.Sorting.Comparer.EnemySortMode = function()
        return true, "Group", false, true
    end

    local manager
    for _, frame in ipairs(wow.State.Frames) do
        if frame:GetAttribute("_onstate-framesort-run") then
            manager = frame
        end
    end
    assert(manager)

    -- the mock frame ignores this call, so record it
    local loaded = {}
    manager.SetAttributeNoHandler = function(_, name, value)
        loaded[name] = value
    end

    wow.FireEvent(events.PLAYER_REGEN_DISABLED)

    assertEquals(loaded.EnemySortEnabled, true)
    assertEquals(loaded.EnemySpacingOnly, true)
end

function M:test_combat_starting_loads_the_marked_enemy_order_and_role_sort_mode()
    addon.DB.Options.Sorting.Method = addon.Configuration.SortingMethod.Secure
    addon.Modules.Sorting.Secure:Init()
    addon.WoW.Capabilities.HasEnemySpecSupport = function()
        return true
    end
    wow.GetBuildInfo = function()
        return "x", "0", "0", 120105
    end
    addon.WoW.WowEx.MockInstance(true, "arena")
    addon.WoW.Unit.ArenaUnits = function()
        return { "arena1", "arena2", "arena3" }
    end
    local config = addon.DB.Options.Sorting.EnemyArena
    config.Enabled = true
    config.GroupSortMode = addon.Configuration.GroupSortMode.Role

    local manager
    for _, frame in ipairs(wow.State.Frames) do
        if frame:GetAttribute("_onstate-framesort-run") then
            manager = frame
        end
    end
    assert(manager)

    -- the mock frame ignores this call, so record it
    local loaded = {}
    manager.SetAttributeNoHandler = function(_, name, value)
        loaded[name] = value
    end

    -- the run would re-sort real frames, which this test has none of
    addon.Modules.Run = function() end
    -- the cache is filled first so only a mark change can empty it
    fsSortedUnits:ArenaUnits()
    local marks = addon.Modules.EnemyAssignments
    marks:Set(1, "DAMAGER")
    marks:Set(2, "HEALER")
    marks:Set(3, "TANK")

    wow.FireEvent(events.PLAYER_REGEN_DISABLED)
    addon.WoW.WowEx.ClearMockInstance()

    assertEquals(loaded.EnemySortEnabled, true)
    assertEquals(loaded.EnemyGroupSortMode, "Role")
    assertEquals(loaded.EnemySpacingOnly, false)
    assertEquals(loaded.EnemyUnit1, "arena3")
    assertEquals(loaded.EnemyUnit2, "arena2")
    assertEquals(loaded.EnemyUnit3, "arena1")
end

return M
