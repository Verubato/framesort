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

local function SetupEnemySpecs()
    capabilities.HasEnemySpecSupport = function()
        return true
    end

    fsInspector.EnemyUnitSpec = function(_, unit)
        if unit == "arena1" then
            return 101
        end

        if unit == "arena2" then
            return 202
        end

        if unit == "arena3" then
            return 303
        end

        return nil
    end

    wow.GetSpecializationInfoByID = function(specId)
        if specId == 101 then
            return nil, nil, nil, nil, "DAMAGER"
        end

        if specId == 202 then
            return nil, nil, nil, nil, "HEALER"
        end

        if specId == 303 then
            return nil, nil, nil, nil, "DAMAGER"
        end

        return nil, nil, nil, nil, "NONE"
    end

    fsUnit.ArenaUnits = function()
        return { "arena3", "arena2", "arena1" }
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
    fsUnit.ArenaUnits = function()
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
    fsUnit.ArenaUnits = function()
        return { "arena2", "arena1" }
    end

    local f0 = fsSortedUnits:FriendlyUnits()
    local e0 = fsSortedUnits:ArenaUnits()
    assertListEquals(f0, { "party1", "party2" })
    assertListEquals(e0, { "arena1", "arena2" })

    -- Change sources
    fsUnit.FriendlyUnits = function()
        return { "party9" }
    end
    fsUnit.ArenaUnits = function()
        return { "arena9" }
    end

    -- UNIT_PET for friendly owner => invalidates friendly cache only
    fsSortedUnits:ProcessEvent(events.UNIT_PET, "party1")

    local f1 = fsSortedUnits:FriendlyUnits()
    local e1 = fsSortedUnits:ArenaUnits()

    assertListEquals(f1, { "party9" }) -- recomputed
    assert(e1 == e0) -- enemy cache still valid (same table instance)
end

function M:test_unit_pet_enemy_owner_invalidates_enemy_only()
    -- Prime both caches
    fsUnit.FriendlyUnits = function()
        return { "party2", "party1" }
    end
    fsUnit.ArenaUnits = function()
        return { "arena2", "arena1" }
    end

    local f0 = fsSortedUnits:FriendlyUnits()
    local e0 = fsSortedUnits:ArenaUnits()

    -- Change sources
    fsUnit.FriendlyUnits = function()
        return { "party9" }
    end
    fsUnit.ArenaUnits = function()
        return { "arena9" }
    end

    -- UNIT_PET for enemy owner (not friend) => invalidates enemy cache only
    fsSortedUnits:ProcessEvent(events.UNIT_PET, "arena1")

    local f1 = fsSortedUnits:FriendlyUnits()
    local e1 = fsSortedUnits:ArenaUnits()

    assert(f1 == f0) -- friendly cache still valid
    assertListEquals(e1, { "arena9" }) -- enemy recomputed
    assert(e1 ~= e0)
end

function M:test_enemy_cache_invalidated_by_arena_events()
    fsUnit.ArenaUnits = function()
        return { "arena2", "arena1" }
    end

    local a = fsSortedUnits:ArenaUnits()
    local b = fsSortedUnits:ArenaUnits()
    assert(b == a)

    fsUnit.ArenaUnits = function()
        return { "arena3" }
    end

    fsSortedUnits:ProcessEvent(events.ARENA_OPPONENT_UPDATE)
    local c = fsSortedUnits:ArenaUnits()
    assertListEquals(c, { "arena3" })
    assert(c ~= a)

    fsUnit.ArenaUnits = function()
        return { "arena5", "arena4" }
    end

    fsSortedUnits:ProcessEvent(events.ARENA_PREP_OPPONENT_SPECIALIZATIONS)
    local d = fsSortedUnits:ArenaUnits()
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

function M:test_cycle_friendly_dps_rotates_only_dps_slots()
    -- roles:
    -- player = HEALER
    -- party1 = DPS
    -- party2 = TANK
    -- party3 = DPS
    -- party4 = DPS
    wow.UnitGroupRolesAssigned = function(unit)
        if unit == "player" then
            return "HEALER"
        end
        if unit == "party2" then
            return "TANK"
        end
        if unit == "party1" or unit == "party3" or unit == "party4" then
            return "DAMAGER"
        end
        return "NONE"
    end

    capabilities.HasRoleAssignments = function()
        return true
    end

    fsUnit.FriendlyUnits = function()
        -- unsorted on purpose; comparer sorts ascending
        return { "party4", "party3", "party2", "party1", "player" }
    end

    -- Prime: sorted but not cycled yet
    local a = fsSortedUnits:FriendlyUnits()
    assertListEquals(a, { "party1", "party2", "party3", "party4", "player" })

    -- Enable cycling + invalidation
    fsSortedUnits:CycleFriendlyDps()

    local b = fsSortedUnits:FriendlyUnits()
    -- DPS indices in sorted list are [1,3,4] => party1, party3, party4
    -- rotate down: [party4, party1, party3] in those slots
    assertListEquals(b, { "party4", "party2", "party1", "party3", "player" })
    assert(b ~= a)
end

function M:test_cycle_friendly_dps_does_nothing_with_0_or_1_dps()
    capabilities.HasRoleAssignments = function()
        return true
    end

    -- Case 1: 0 DPS
    wow.UnitGroupRolesAssigned = function(unit)
        if unit == "player" then
            return "HEALER"
        end
        if unit == "party1" then
            return "TANK"
        end
        return "NONE"
    end

    fsUnit.FriendlyUnits = function()
        return { "party1", "player" }
    end

    fsSortedUnits:InvalidateCache()
    local a = fsSortedUnits:FriendlyUnits()
    assertListEquals(a, { "party1", "player" })

    fsSortedUnits:CycleFriendlyDps()
    local b = fsSortedUnits:FriendlyUnits()
    assertListEquals(b, { "party1", "player" })

    -- Case 2: 1 DPS
    wow.UnitGroupRolesAssigned = function(unit)
        if unit == "party1" then
            return "DAMAGER"
        end
        return "HEALER"
    end

    fsUnit.FriendlyUnits = function()
        return { "party1", "player" }
    end

    fsSortedUnits:InvalidateCache()
    local c = fsSortedUnits:FriendlyUnits()
    assertListEquals(c, { "party1", "player" })

    fsSortedUnits:CycleFriendlyDps()
    local d = fsSortedUnits:FriendlyUnits()
    assertListEquals(d, { "party1", "player" })
end

function M:test_cycle_enemy_dps_rotates_only_dps_slots()
    capabilities.HasEnemySpecSupport = function()
        return true
    end

    -- Map arena unit -> specId
    fsInspector.EnemyUnitSpec = function(_, unit)
        if unit == "arena1" then
            return 101
        end -- DPS
        if unit == "arena2" then
            return 202
        end -- HEALER
        if unit == "arena3" then
            return 303
        end -- DPS
        return nil
    end

    -- specId -> role (5th return value)
    wow.GetSpecializationInfoByID = function(specId)
        if specId == 101 then
            return nil, nil, nil, nil, "DAMAGER"
        end
        if specId == 202 then
            return nil, nil, nil, nil, "HEALER"
        end
        if specId == 303 then
            return nil, nil, nil, nil, "DAMAGER"
        end
        return nil, nil, nil, nil, "NONE"
    end

    fsUnit.ArenaUnits = function()
        return { "arena3", "arena2", "arena1" }
    end

    -- Prime: sorted ascending (arena1, arena2, arena3)
    local a = fsSortedUnits:ArenaUnits()
    assertListEquals(a, { "arena1", "arena2", "arena3" })

    fsSortedUnits:CycleEnemyDps()

    local b = fsSortedUnits:ArenaUnits()
    -- DPS indices [1,3] => arena1, arena3 rotate => arena3, arena1
    assertListEquals(b, { "arena3", "arena2", "arena1" })
    assert(b ~= a)
end

function M:test_cycle_enemy_dps_noop_when_enemy_spec_support_missing()
    -- Force feature off
    capabilities.HasEnemySpecSupport = function()
        return false
    end

    fsUnit.ArenaUnits = function()
        return { "arena2", "arena1" }
    end

    fsSortedUnits:InvalidateCache()
    local a = fsSortedUnits:ArenaUnits()
    assertListEquals(a, { "arena1", "arena2" })

    fsSortedUnits:CycleEnemyDps()

    local b = fsSortedUnits:ArenaUnits()
    -- still sorted, not cycled
    assertListEquals(b, { "arena1", "arena2" })
end

function M:test_cycle_friendly_dps_cycles_2()
    -- roles:
    -- player = HEALER
    -- party1 = DPS
    -- party2 = TANK
    -- party3 = DPS
    -- party4 = DPS
    wow.UnitGroupRolesAssigned = function(unit)
        if unit == "player" then
            return "HEALER"
        end
        if unit == "party2" then
            return "TANK"
        end
        if unit == "party1" or unit == "party3" or unit == "party4" then
            return "DAMAGER"
        end
        return "NONE"
    end

    capabilities.HasRoleAssignments = function()
        return true
    end

    fsUnit.FriendlyUnits = function()
        -- unsorted on purpose; comparer sorts ascending
        return { "party4", "party3", "party2", "party1", "player" }
    end

    -- Prime: sorted baseline
    local base = fsSortedUnits:FriendlyUnits()
    assertListEquals(base, { "party1", "party2", "party3", "party4", "player" })

    -- DPS indices in sorted list are [1,3,4] => [party1, party3, party4]
    -- cycles=2 => rotate down by 2: [party3, party4, party1] in those slots
    fsSortedUnits:CycleFriendlyDps(2)

    local out = fsSortedUnits:FriendlyUnits()
    assertListEquals(out, { "party3", "party2", "party4", "party1", "player" })
end

function M:test_cycle_friendly_dps_cycles_3_is_noop_when_three_dps()
    wow.UnitGroupRolesAssigned = function(unit)
        if unit == "player" then
            return "HEALER"
        end
        if unit == "party2" then
            return "TANK"
        end
        if unit == "party1" or unit == "party3" or unit == "party4" then
            return "DAMAGER"
        end
        return "NONE"
    end

    capabilities.HasRoleAssignments = function()
        return true
    end

    fsUnit.FriendlyUnits = function()
        return { "party4", "party3", "party2", "party1", "player" }
    end

    local base = fsSortedUnits:FriendlyUnits()
    assertListEquals(base, { "party1", "party2", "party3", "party4", "player" })

    -- 3 DPS => cycles=3 => 3 % 3 == 0 => no-op
    fsSortedUnits:CycleFriendlyDps(3)

    local out = fsSortedUnits:FriendlyUnits()
    assertListEquals(out, { "party1", "party2", "party3", "party4", "player" })
end

function M:test_cycle_friendly_dps_cycles_10_wraps_to_1_when_three_dps()
    wow.UnitGroupRolesAssigned = function(unit)
        if unit == "player" then
            return "HEALER"
        end
        if unit == "party2" then
            return "TANK"
        end
        if unit == "party1" or unit == "party3" or unit == "party4" then
            return "DAMAGER"
        end
        return "NONE"
    end

    capabilities.HasRoleAssignments = function()
        return true
    end

    fsUnit.FriendlyUnits = function()
        return { "party4", "party3", "party2", "party1", "player" }
    end

    local base = fsSortedUnits:FriendlyUnits()
    assertListEquals(base, { "party1", "party2", "party3", "party4", "player" })

    -- 3 DPS => 10 % 3 == 1 => same as single cycle
    fsSortedUnits:CycleFriendlyDps(10)

    local out = fsSortedUnits:FriendlyUnits()
    assertListEquals(out, { "party4", "party2", "party1", "party3", "player" })
end

function M:test_cycle_friendly_dps_cycles_multiple_calls()
    wow.UnitGroupRolesAssigned = function(unit)
        return "DAMAGER"
    end

    capabilities.HasRoleAssignments = function()
        return true
    end

    fsUnit.FriendlyUnits = function()
        return { "party4", "party3", "party2", "party1", "player" }
    end

    local base = fsSortedUnits:FriendlyUnits()
    assertListEquals(base, { "party1", "party2", "party3", "party4", "player" })

    fsSortedUnits:CycleFriendlyDps()
    fsSortedUnits:CycleFriendlyDps()
    fsSortedUnits:CycleFriendlyDps()

    local out = fsSortedUnits:FriendlyUnits()
    assertListEquals(out, { "party3", "party4", "player", "party1", "party2" })
end

function M:test_cycle_friendly_dps_reset_cycles()
    wow.UnitGroupRolesAssigned = function(unit)
        return "DAMAGER"
    end

    capabilities.HasRoleAssignments = function()
        return true
    end

    fsUnit.FriendlyUnits = function()
        return { "party4", "party3", "party2", "party1", "player" }
    end

    local base = fsSortedUnits:FriendlyUnits()
    assertListEquals(base, { "party1", "party2", "party3", "party4", "player" })

    fsSortedUnits:CycleFriendlyDps()
    fsSortedUnits:CycleFriendlyDps()
    fsSortedUnits:CycleFriendlyDps()

    local out = fsSortedUnits:FriendlyUnits()
    assertListEquals(out, { "party3", "party4", "player", "party1", "party2" })

    fsSortedUnits:ResetFriendlyDpsCycles()

    out = fsSortedUnits:FriendlyUnits()

    assertListEquals(base, { "party1", "party2", "party3", "party4", "player" })
end

function M:test_cycle_enemy_dps_cycles()
    SetupEnemySpecs()

    local base = fsSortedUnits:ArenaUnits()
    assertListEquals(base, { "arena1", "arena2", "arena3" })

    fsSortedUnits:CycleEnemyDps()

    local out = fsSortedUnits:ArenaUnits()
    assertListEquals(out, { "arena3", "arena2", "arena1" })
end

function M:test_cycle_enemy_dps_cycles_2_is_noop_when_two_dps()
    SetupEnemySpecs()

    local base = fsSortedUnits:ArenaUnits()
    assertListEquals(base, { "arena1", "arena2", "arena3" })

    fsSortedUnits:CycleEnemyDps(2)

    local out = fsSortedUnits:ArenaUnits()
    assertListEquals(out, { "arena1", "arena2", "arena3" })
end

function M:test_cycle_enemy_dps_cycles_5_wraps_to_1_when_three_dps()
    SetupEnemySpecs()

    local base = fsSortedUnits:ArenaUnits()
    assertListEquals(base, { "arena1", "arena2", "arena3" })

    fsSortedUnits:CycleEnemyDps(5)

    local out = fsSortedUnits:ArenaUnits()
    assertListEquals(out, { "arena3", "arena2", "arena1" })
end

function M:test_cycle_enemy_dps_cycles_multiple_calls()
    SetupEnemySpecs()

    local base = fsSortedUnits:ArenaUnits()
    assertListEquals(base, { "arena1", "arena2", "arena3" })

    fsSortedUnits:CycleEnemyDps()
    fsSortedUnits:CycleEnemyDps()
    fsSortedUnits:CycleEnemyDps()

    local out = fsSortedUnits:ArenaUnits()
    assertListEquals(out, { "arena3", "arena2", "arena1" })
end

function M:test_cycle_enemy_dps_reset_cycles()
    SetupEnemySpecs()

    local base = fsSortedUnits:ArenaUnits()
    assertListEquals(base, { "arena1", "arena2", "arena3" })

    fsSortedUnits:CycleEnemyDps()

    local out = fsSortedUnits:ArenaUnits()
    assertListEquals(out, { "arena3", "arena2", "arena1" })

    fsSortedUnits:ResetEnemyDpsCycles()

    out = fsSortedUnits:ArenaUnits()
    assertListEquals(out, { "arena1", "arena2", "arena3" })
end

return M
