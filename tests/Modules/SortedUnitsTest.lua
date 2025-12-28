---@diagnostic disable: duplicate-set-field, cast-local-type
---@type Addon
local addon
---@type SortedUnits
local fsSortedUnits
local fsCompare
local fsUnit
local fsSortedFrames
local fsFrame
local wow
local events
local capabilities
local fsInspector
local fsConfig

local M = {}

local function shallowEquals(a, b)
    if a == b then
        return true
    end
    if type(a) ~= "table" or type(b) ~= "table" then
        return false
    end
    if #a ~= #b then
        return false
    end
    for i = 1, #a do
        if a[i] ~= b[i] then
            return false
        end
    end
    return true
end

local function assertListEquals(actual, expected)
    if not shallowEquals(actual, expected) then
        error(string.format("list mismatch.\nexpected: %s\nactual:   %s", table.concat(expected, ", "), table.concat(actual or {}, ", ")), 2)
    end
end

function M:setup()
    local addonFactory = require("TestHarness\\AddonFactory")
    addon = addonFactory:Create()

    fsSortedUnits = addon.Modules.Sorting.SortedUnits
    fsCompare = addon.Modules.Sorting.Comparer
    fsUnit = addon.WoW.Unit
    fsSortedFrames = addon.Modules.Sorting.SortedFrames
    fsFrame = addon.WoW.Frame
    wow = addon.WoW.Api
    events = addon.WoW.Events
    capabilities = addon.WoW.Capabilities
    fsInspector = addon.Modules.Inspector
    fsConfig = addon.Configuration

    fsCompare.FriendlySortMode = function()
        return true
    end
    fsCompare.EnemySortMode = function()
        return true
    end

    -- Friendly sorts ascending (player, party1, party2...)
    fsCompare.SortFunction = function(_, _units)
        return function(a, b)
            return a < b
        end
    end

    -- Enemy sorts ascending (arena1, arena2...)
    fsCompare.EnemySortFunction = function(_, _units)
        return function(a, b)
            return a < b
        end
    end

    fsUnit.FriendlyUnits = function()
        return {}
    end
    fsUnit.EnemyUnits = function()
        return {}
    end

    -- Frame fallback: default none
    fsSortedFrames.FriendlyFrames = function()
        return {}
    end
    fsFrame.GetFrameUnit = function(_, frame)
        return frame and frame.Unit or nil
    end

    -- Pet friend/enemy routing
    wow.UnitIsFriend = function(_, unit)
        -- treat "party*" and "raid*" and "player" as friendly
        if unit == "player" then
            return true
        end
        if type(unit) == "string" and (unit:match("^party") or unit:match("^raid")) then
            return true
        end
        return false
    end

    -- Init once per test
    fsSortedUnits:InvalidateCache()
    fsSortedUnits:Init()
end

function M:teardown()
    addon = nil
    fsSortedUnits = nil
    fsCompare = nil
    fsUnit = nil
    fsSortedFrames = nil
    fsFrame = nil
    wow = nil
    events = nil
    capabilities = nil
    fsInspector = nil
    fsConfig = nil
end

function M:test_friendly_returns_sorted_and_caches_pointer()
    fsUnit.FriendlyUnits = function()
        return { "party2", "player", "party1" }
    end

    local a = fsSortedUnits:FriendlyUnits()
    assertListEquals(a, { "party1", "party2", "player" })

    -- Second call should be a cache hit and return the same table instance
    local b = fsSortedUnits:FriendlyUnits()
    assert(b == a)
end

function M:test_friendly_cache_invalidated_by_group_roster_update()
    fsUnit.FriendlyUnits = function()
        return { "party2", "player", "party1" }
    end

    local a = fsSortedUnits:FriendlyUnits()
    local b = fsSortedUnits:FriendlyUnits()
    assert(b == a)

    -- change underlying source to ensure recompute happens after invalidation
    fsUnit.FriendlyUnits = function()
        return { "party4", "party3" }
    end

    fsSortedUnits:ProcessEvent(events.GROUP_ROSTER_UPDATE)

    local c = fsSortedUnits:FriendlyUnits()
    assertListEquals(c, { "party3", "party4" })
    assert(c ~= a)
end

function M:test_friendly_cache_invalidated_by_player_roles_assigned()
    fsUnit.FriendlyUnits = function()
        return { "party2", "party1" }
    end

    local a = fsSortedUnits:FriendlyUnits()
    fsUnit.FriendlyUnits = function()
        return { "player" }
    end

    fsSortedUnits:ProcessEvent(events.PLAYER_ROLES_ASSIGNED)

    local b = fsSortedUnits:FriendlyUnits()
    assertListEquals(b, { "player" })
    assert(b ~= a)
end

function M:test_unit_pet_friendly_owner_invalidates_friendly_only()
    -- Prime both caches
    fsUnit.FriendlyUnits = function()
        return { "party2", "party1" }
    end
    fsUnit.EnemyUnits = function()
        return { "arena2", "arena1" }
    end

    local f0 = fsSortedUnits:FriendlyUnits()
    local e0 = fsSortedUnits:EnemyUnits()
    assertListEquals(f0, { "party1", "party2" })
    assertListEquals(e0, { "arena1", "arena2" })

    -- Change sources
    fsUnit.FriendlyUnits = function()
        return { "party9" }
    end
    fsUnit.EnemyUnits = function()
        return { "arena9" }
    end

    -- UNIT_PET for friendly owner => invalidates friendly cache only
    fsSortedUnits:ProcessEvent(events.UNIT_PET, "party1")

    local f1 = fsSortedUnits:FriendlyUnits()
    local e1 = fsSortedUnits:EnemyUnits()

    assertListEquals(f1, { "party9" }) -- recomputed
    assert(e1 == e0) -- enemy cache still valid (same table instance)
end

function M:test_unit_pet_enemy_owner_invalidates_enemy_only()
    -- Prime both caches
    fsUnit.FriendlyUnits = function()
        return { "party2", "party1" }
    end
    fsUnit.EnemyUnits = function()
        return { "arena2", "arena1" }
    end

    local f0 = fsSortedUnits:FriendlyUnits()
    local e0 = fsSortedUnits:EnemyUnits()

    -- Change sources
    fsUnit.FriendlyUnits = function()
        return { "party9" }
    end
    fsUnit.EnemyUnits = function()
        return { "arena9" }
    end

    -- UNIT_PET for enemy owner (not friend) => invalidates enemy cache only
    fsSortedUnits:ProcessEvent(events.UNIT_PET, "arena1")

    local f1 = fsSortedUnits:FriendlyUnits()
    local e1 = fsSortedUnits:EnemyUnits()

    assert(f1 == f0) -- friendly cache still valid
    assertListEquals(e1, { "arena9" }) -- enemy recomputed
    assert(e1 ~= e0)
end

function M:test_enemy_cache_invalidated_by_arena_events()
    fsUnit.EnemyUnits = function()
        return { "arena2", "arena1" }
    end

    local a = fsSortedUnits:EnemyUnits()
    local b = fsSortedUnits:EnemyUnits()
    assert(b == a)

    fsUnit.EnemyUnits = function()
        return { "arena3" }
    end

    fsSortedUnits:ProcessEvent(events.ARENA_OPPONENT_UPDATE)
    local c = fsSortedUnits:EnemyUnits()
    assertListEquals(c, { "arena3" })
    assert(c ~= a)

    fsUnit.EnemyUnits = function()
        return { "arena5", "arena4" }
    end

    fsSortedUnits:ProcessEvent(events.ARENA_PREP_OPPONENT_SPECIALIZATIONS)
    local d = fsSortedUnits:EnemyUnits()
    assertListEquals(d, { "arena4", "arena5" })
end

function M:test_invalidate_cache_forces_recompute_next_call()
    fsUnit.FriendlyUnits = function()
        return { "party2", "party1" }
    end
    local a = fsSortedUnits:FriendlyUnits()
    local b = fsSortedUnits:FriendlyUnits()
    assert(b == a)

    fsUnit.FriendlyUnits = function()
        return { "party9" }
    end

    fsSortedUnits:InvalidateCache()
    local c = fsSortedUnits:FriendlyUnits()
    assertListEquals(c, { "party9" })
    assert(c ~= a)
end

function M:test_friendly_fallback_from_frames_when_units_empty_and_does_not_cache_fallback()
    -- Unit source returns empty -> triggers frames fallback and cache=false
    fsUnit.FriendlyUnits = function()
        return {}
    end

    local frameA = { Unit = "party2" }
    local frameB = { Unit = "party1" }
    fsSortedFrames.FriendlyFrames = function()
        return { frameA, frameB }
    end

    -- sort enabled
    fsCompare.FriendlySortMode = function()
        return true
    end

    local first = fsSortedUnits:FriendlyUnits()
    -- note: FriendlyUnitsFromFrames() sorts too, so we expect sorted units
    assertListEquals(first, { "party1", "party2" })

    -- Change frames; since fallback result is NOT cached, we should see new values immediately
    local frameC = { Unit = "party9" }
    fsSortedFrames.FriendlyFrames = function()
        return { frameC }
    end

    local second = fsSortedUnits:FriendlyUnits()
    assertListEquals(second, { "party9" })

    -- Also ensure it is not returning the same table instance as prior fallback
    assert(second ~= first)
end

function M:test_sort_disabled_returns_units_unmodified_and_still_caches_pointer()
    fsUnit.FriendlyUnits = function()
        return { "party2", "party1" }
    end

    fsCompare.FriendlySortMode = function()
        return false
    end

    local a = fsSortedUnits:FriendlyUnits()
    -- not sorted if sort mode disabled
    assertListEquals(a, { "party2", "party1" })

    local b = fsSortedUnits:FriendlyUnits()
    assert(b == a)
end

return M
