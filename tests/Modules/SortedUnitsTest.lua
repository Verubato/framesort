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

function M:test_friendly_from_frames_caches()
    local frameA = { Unit = "party2" }
    local frameB = { Unit = "party1" }

    fsSortedFrames.FriendlyFrames = function()
        return { frameA, frameB }
    end

    fsCompare.FriendlySortMode = function()
        return true
    end

    local first = fsSortedUnits:FriendlyUnits()

    assertListEquals(first, { "party1", "party2" })

    local second = fsSortedUnits:FriendlyUnits()

    assert(first == second)
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
    fsSortedUnits:CycleFriendlyRoles({ "DAMAGER" })

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

    fsSortedUnits:CycleFriendlyRoles({ "DAMAGER" })
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

    fsSortedUnits:CycleFriendlyRoles({ "DAMAGER" })
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

    fsSortedUnits:CycleEnemyRoles({ "DAMAGER" })

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

    fsSortedUnits:CycleEnemyRoles({ "DAMAGER" })

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
    fsSortedUnits:CycleFriendlyRoles({ "DAMAGER" }, 2)

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
    fsSortedUnits:CycleFriendlyRoles({ "DAMAGER" }, 3)

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
    fsSortedUnits:CycleFriendlyRoles({ "DAMAGER" }, 10)

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

    fsSortedUnits:CycleFriendlyRoles({ "DAMAGER" })
    fsSortedUnits:CycleFriendlyRoles({ "DAMAGER" })
    fsSortedUnits:CycleFriendlyRoles({ "DAMAGER" })

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

    fsSortedUnits:CycleFriendlyRoles({ "DAMAGER" })
    fsSortedUnits:CycleFriendlyRoles({ "DAMAGER" })
    fsSortedUnits:CycleFriendlyRoles({ "DAMAGER" })

    local out = fsSortedUnits:FriendlyUnits()
    assertListEquals(out, { "party3", "party4", "player", "party1", "party2" })

    fsSortedUnits:ResetFriendlyCycles()

    out = fsSortedUnits:FriendlyUnits()

    assertListEquals(base, { "party1", "party2", "party3", "party4", "player" })
end

function M:test_cycle_enemy_dps_cycles()
    SetupEnemySpecs()

    local base = fsSortedUnits:ArenaUnits()
    assertListEquals(base, { "arena1", "arena2", "arena3" })

    fsSortedUnits:CycleEnemyRoles({ "DAMAGER" })

    local out = fsSortedUnits:ArenaUnits()
    assertListEquals(out, { "arena3", "arena2", "arena1" })
end

function M:test_cycle_enemy_dps_cycles_2_is_noop_when_two_dps()
    SetupEnemySpecs()

    local base = fsSortedUnits:ArenaUnits()
    assertListEquals(base, { "arena1", "arena2", "arena3" })

    fsSortedUnits:CycleEnemyRoles({ "DAMAGER" }, 2)

    local out = fsSortedUnits:ArenaUnits()
    assertListEquals(out, { "arena1", "arena2", "arena3" })
end

function M:test_cycle_enemy_dps_cycles_5_wraps_to_1_when_three_dps()
    SetupEnemySpecs()

    local base = fsSortedUnits:ArenaUnits()
    assertListEquals(base, { "arena1", "arena2", "arena3" })

    fsSortedUnits:CycleEnemyRoles({ "DAMAGER" }, 5)

    local out = fsSortedUnits:ArenaUnits()
    assertListEquals(out, { "arena3", "arena2", "arena1" })
end

function M:test_cycle_enemy_dps_cycles_multiple_calls()
    SetupEnemySpecs()

    local base = fsSortedUnits:ArenaUnits()
    assertListEquals(base, { "arena1", "arena2", "arena3" })

    fsSortedUnits:CycleEnemyRoles({ "DAMAGER" })
    fsSortedUnits:CycleEnemyRoles({ "DAMAGER" })
    fsSortedUnits:CycleEnemyRoles({ "DAMAGER" })

    local out = fsSortedUnits:ArenaUnits()
    assertListEquals(out, { "arena3", "arena2", "arena1" })
end

function M:test_cycle_enemy_dps_reset_cycles()
    SetupEnemySpecs()

    local base = fsSortedUnits:ArenaUnits()
    assertListEquals(base, { "arena1", "arena2", "arena3" })

    fsSortedUnits:CycleEnemyRoles({ "DAMAGER" })

    local out = fsSortedUnits:ArenaUnits()
    assertListEquals(out, { "arena3", "arena2", "arena1" })

    fsSortedUnits:ResetEnemyCycles()

    out = fsSortedUnits:ArenaUnits()
    assertListEquals(out, { "arena1", "arena2", "arena3" })
end

function M:test_cycle_friendly_multiple_roles_dps_and_healer_rotates_both_roles_together()
    -- roles:
    -- player = HEALER
    -- party1 = DPS
    -- party2 = TANK (should NOT move)
    -- party3 = DPS
    -- party4 = HEALER
    wow.UnitGroupRolesAssigned = function(unit)
        if unit == "player" then
            return "HEALER"
        end
        if unit == "party4" then
            return "HEALER"
        end
        if unit == "party2" then
            return "TANK"
        end
        if unit == "party1" or unit == "party3" then
            return "DAMAGER"
        end
        return "NONE"
    end

    capabilities.HasRoleAssignments = function()
        return true
    end

    fsUnit.FriendlyUnits = function()
        -- unsorted; comparer sorts ascending
        return { "party4", "party3", "party2", "party1", "player" }
    end

    local base = fsSortedUnits:FriendlyUnits()
    assertListEquals(base, { "party1", "party2", "party3", "party4", "player" })

    -- Matching indices in sorted list for roles {DAMAGER, HEALER} are [1,3,4,5]
    -- Values are [party1, party3, party4, player]
    -- cycles=1 => rotate down by 1 => [player, party1, party3, party4]
    fsSortedUnits:CycleFriendlyRoles({ "DAMAGER", "HEALER" })

    local out = fsSortedUnits:FriendlyUnits()
    assertListEquals(out, { "player", "party2", "party1", "party3", "party4" })
end

function M:test_cycle_friendly_multiple_roles_dps_and_healer_cycles_2()
    -- same role layout as above, but verify cycles=2
    wow.UnitGroupRolesAssigned = function(unit)
        if unit == "player" then
            return "HEALER"
        end
        if unit == "party4" then
            return "HEALER"
        end
        if unit == "party2" then
            return "TANK"
        end
        if unit == "party1" or unit == "party3" then
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

    -- Matching indices [1,3,4,5] values [party1, party3, party4, player]
    -- cycles=2 => rotate down by 2 => [party4, player, party1, party3]
    fsSortedUnits:CycleFriendlyRoles({ "DAMAGER", "HEALER" }, 2)

    local out = fsSortedUnits:FriendlyUnits()
    assertListEquals(out, { "party4", "party2", "player", "party1", "party3" })
end

function M:test_cycle_friendly_multiple_roles_noop_when_only_one_matching_unit()
    capabilities.HasRoleAssignments = function()
        return true
    end

    -- only one unit matches {DAMAGER, HEALER} => no-op
    wow.UnitGroupRolesAssigned = function(unit)
        if unit == "party1" then
            return "DAMAGER"
        end
        return "TANK"
    end

    fsUnit.FriendlyUnits = function()
        return { "party2", "party1", "player" }
    end

    fsSortedUnits:InvalidateCache()
    local base = fsSortedUnits:FriendlyUnits()
    assertListEquals(base, { "party1", "party2", "player" }) -- sorted by comparer

    fsSortedUnits:CycleFriendlyRoles({ "DAMAGER", "HEALER" })

    local out = fsSortedUnits:FriendlyUnits()
    assertListEquals(out, { "party1", "party2", "player" })
end

function M:test_cycle_enemy_multiple_roles_dps_and_healer_rotates_both_roles_together()
    -- Arena units: arena1, arena2, arena3 after sort
    -- arena1 = DAMAGER
    -- arena2 = HEALER
    -- arena3 = DAMAGER
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

    local base = fsSortedUnits:ArenaUnits()
    assertListEquals(base, { "arena1", "arena2", "arena3" })

    -- Matching indices for roles {DAMAGER, HEALER} are [1,2,3]
    -- values [arena1, arena2, arena3]
    -- cycles=1 => rotate down by 1 => [arena3, arena1, arena2]
    fsSortedUnits:CycleEnemyRoles({ "DAMAGER", "HEALER" })

    local out = fsSortedUnits:ArenaUnits()
    assertListEquals(out, { "arena3", "arena1", "arena2" })
end

function M:test_cycle_enemy_multiple_roles_dps_and_healer_cycles_2()
    SetupEnemySpecs()

    local base = fsSortedUnits:ArenaUnits()
    assertListEquals(base, { "arena1", "arena2", "arena3" })

    -- With SetupEnemySpecs, roles are:
    -- arena1 = DAMAGER, arena2 = HEALER, arena3 = DAMAGER
    -- Matching indices [1,2,3] => cycles=2 => rotate down by 2 => [arena2, arena3, arena1]
    fsSortedUnits:CycleEnemyRoles({ "DAMAGER", "HEALER" }, 2)

    local out = fsSortedUnits:ArenaUnits()
    assertListEquals(out, { "arena2", "arena3", "arena1" })
end

function M:test_cycle_friendly_multiple_roles_array_and_set_forms_match()
    -- sanity test: passing roles as array vs set should behave the same
    wow.UnitGroupRolesAssigned = function(unit)
        if unit == "party1" then
            return "DAMAGER"
        end
        if unit == "party2" then
            return "HEALER"
        end
        if unit == "party3" then
            return "DAMAGER"
        end
        return "TANK"
    end

    capabilities.HasRoleAssignments = function()
        return true
    end

    fsUnit.FriendlyUnits = function()
        return { "party3", "party2", "party1", "player" }
    end

    fsSortedUnits:InvalidateCache()
    local base = fsSortedUnits:FriendlyUnits()
    assertListEquals(base, { "party1", "party2", "party3", "player" })

    fsSortedUnits:CycleFriendlyRoles({ "DAMAGER", "HEALER" }, 1)
    local outArray = fsSortedUnits:FriendlyUnits()

    -- reset + run again using set form
    fsSortedUnits:ResetFriendlyCycles()
    fsSortedUnits:InvalidateCache()
    local base2 = fsSortedUnits:FriendlyUnits()
    assertListEquals(base2, { "party1", "party2", "party3", "player" })

    fsSortedUnits:CycleFriendlyRoles({ ["DAMAGER"] = true, ["HEALER"] = true }, 1)
    local outSet = fsSortedUnits:FriendlyUnits()

    assertListEquals(outArray, outSet)
end

function M:test_cycle_friendly_all_three_roles_rotates_everyone_except_none()
    -- roles:
    -- player = HEALER
    -- party1 = DAMAGER
    -- party2 = TANK
    -- party3 = DAMAGER
    -- party4 = HEALER
    wow.UnitGroupRolesAssigned = function(unit)
        if unit == "party2" then
            return "TANK"
        end
        if unit == "party1" or unit == "party3" then
            return "DAMAGER"
        end
        if unit == "player" or unit == "party4" then
            return "HEALER"
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

    fsSortedUnits:CycleFriendlyRoles({ "TANK", "DAMAGER", "HEALER" })

    local out = fsSortedUnits:FriendlyUnits()
    assertListEquals(out, { "player", "party1", "party2", "party3", "party4" })
end

function M:test_cycle_friendly_multiple_instructions_healer_then_dps()
    -- roles:
    -- player = HEALER
    -- party1 = DAMAGER
    -- party2 = TANK
    -- party3 = DAMAGER
    -- party4 = HEALER
    wow.UnitGroupRolesAssigned = function(unit)
        if unit == "party2" then
            return "TANK"
        end
        if unit == "party1" or unit == "party3" then
            return "DAMAGER"
        end
        if unit == "player" or unit == "party4" then
            return "HEALER"
        end
        return "NONE"
    end

    capabilities.HasRoleAssignments = function()
        return true
    end

    fsUnit.FriendlyUnits = function()
        return { "party4", "party3", "party2", "party1", "player" }
    end

    -- Baseline: sorted ascending
    local base = fsSortedUnits:FriendlyUnits()
    assertListEquals(base, { "party1", "party2", "party3", "party4", "player" })

    -- Add two separate instructions:
    -- 1) rotate HEALERs: indices [4,5] => [player, party4]
    -- 2) rotate DAMAGERs: indices [1,3] (after step 1) => swap party1/party3
    fsSortedUnits:CycleFriendlyRoles({ "HEALER" })
    fsSortedUnits:CycleFriendlyRoles({ "DAMAGER" })

    local out = fsSortedUnits:FriendlyUnits()
    assertListEquals(out, { "party3", "party2", "party1", "player", "party4" })
end

function M:test_cycle_friendly_multiple_instructions_dps_then_healer_order_matters()
    -- roles:
    -- player = HEALER
    -- party1 = DAMAGER
    -- party2 = TANK
    -- party3 = DAMAGER
    -- party4 = HEALER
    wow.UnitGroupRolesAssigned = function(unit)
        if unit == "party2" then
            return "TANK"
        end
        if unit == "party1" or unit == "party3" then
            return "DAMAGER"
        end
        if unit == "player" or unit == "party4" then
            return "HEALER"
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

    -- Reverse order of the other test:
    -- 1) rotate DAMAGERs: indices [1,3] => [party3, party1]
    --    result: [party3, party2, party1, party4, player]
    -- 2) rotate HEALERs: indices [4,5] => [player, party4]
    --    result: [party3, party2, party1, player, party4]
    fsSortedUnits:CycleFriendlyRoles({ "DAMAGER" })
    fsSortedUnits:CycleFriendlyRoles({ "HEALER" })

    local out = fsSortedUnits:FriendlyUnits()
    assertListEquals(out, { "party3", "party2", "party1", "player", "party4" })
end

function M:test_cycle_friendly_multiple_instructions_same_roles_accumulate_effect()
    -- make everyone DAMAGER so rotation is easy to reason about
    wow.UnitGroupRolesAssigned = function(_)
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

    -- Two separate instructions, same roles, should rotate twice total:
    -- step1 (cycles=1): [player, party1, party2, party3, party4]
    -- step2 (cycles=1): [party4, player, party1, party2, party3]
    fsSortedUnits:CycleFriendlyRoles({ "DAMAGER" })
    fsSortedUnits:CycleFriendlyRoles({ "DAMAGER" })

    local out = fsSortedUnits:FriendlyUnits()
    assertListEquals(out, { "party4", "player", "party1", "party2", "party3" })
end

function M:test_cycle_friendly_multiple_instructions_cycles_parameter_applies_per_instruction()
    -- everyone DAMAGER again
    wow.UnitGroupRolesAssigned = function(_)
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

    -- instruction A: cycles=2
    -- instruction B: cycles=3
    -- with 5 units: net effect is 2 then 3 (in-order)
    -- A (2): [party4, player, party1, party2, party3]
    -- B (3): rotate down by 3 => same as rotate up by 2
    --   result: [party1, party2, party3, party4, player]
    fsSortedUnits:CycleFriendlyRoles({ "DAMAGER" }, 2)
    fsSortedUnits:CycleFriendlyRoles({ "DAMAGER" }, 3)

    local out = fsSortedUnits:FriendlyUnits()
    assertListEquals(out, { "party1", "party2", "party3", "party4", "player" })
end

function M:test_cycle_friendly_multiple_instructions_mixed_multi_role_sets()
    -- roles:
    -- party1 = DAMAGER
    -- party2 = TANK
    -- party3 = HEALER
    -- party4 = DAMAGER
    -- player = HEALER
    wow.UnitGroupRolesAssigned = function(unit)
        if unit == "party2" then
            return "TANK"
        end
        if unit == "party1" or unit == "party4" then
            return "DAMAGER"
        end
        if unit == "party3" or unit == "player" then
            return "HEALER"
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

    -- instruction 1: rotate (DAMAGER + HEALER) indices [1,3,4,5]
    --   values [party1, party3, party4, player] -> [player, party1, party3, party4]
    --   result: [player, party2, party1, party3, party4]
    -- instruction 2: rotate TANK indices [2] => no-op (n<=1)
    fsSortedUnits:CycleFriendlyRoles({ "DAMAGER", "HEALER" })
    fsSortedUnits:CycleFriendlyRoles({ "TANK" })

    local out = fsSortedUnits:FriendlyUnits()
    assertListEquals(out, { "player", "party2", "party1", "party3", "party4" })
end

function M:test_cycle_friendly_multiple_instructions_reset_clears_queue()
    wow.UnitGroupRolesAssigned = function(_)
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

    fsSortedUnits:CycleFriendlyRoles({ "DAMAGER" })
    fsSortedUnits:CycleFriendlyRoles({ "DAMAGER" })

    local cycled = fsSortedUnits:FriendlyUnits()
    assertListEquals(cycled, { "party4", "player", "party1", "party2", "party3" })

    fsSortedUnits:ResetFriendlyCycles()

    local resetOut = fsSortedUnits:FriendlyUnits()
    assertListEquals(resetOut, { "party1", "party2", "party3", "party4", "player" })
end

function M:test_cycle_friendly_and_enemy_multiple_instruction_queues_are_independent()
    -- Friendly: everyone DAMAGER
    wow.UnitGroupRolesAssigned = function(_)
        return "DAMAGER"
    end
    capabilities.HasRoleAssignments = function()
        return true
    end
    fsUnit.FriendlyUnits = function()
        return { "party2", "party1", "player" }
    end

    -- Enemy: use SetupEnemySpecs() roles (arena1=DAMAGER, arena2=HEALER, arena3=DAMAGER)
    SetupEnemySpecs()

    local fBase = fsSortedUnits:FriendlyUnits()
    assertListEquals(fBase, { "party1", "party2", "player" })

    local eBase = fsSortedUnits:ArenaUnits()
    assertListEquals(eBase, { "arena1", "arena2", "arena3" })

    -- Queue instructions on both sides
    fsSortedUnits:CycleFriendlyRoles({ "DAMAGER" }) -- affects friendly only
    fsSortedUnits:CycleEnemyRoles({ "DAMAGER", "HEALER" }, 2) -- affects enemy only

    local fOut = fsSortedUnits:FriendlyUnits()
    -- 3 units, rotate down by 1 => [player, party1, party2]
    assertListEquals(fOut, { "player", "party1", "party2" })

    local eOut = fsSortedUnits:ArenaUnits()
    -- [arena1, arena2, arena3] rotate down by 2 => [arena2, arena3, arena1]
    assertListEquals(eOut, { "arena2", "arena3", "arena1" })
end

function M:test_units_sort_friendly_uses_friendly_mode_and_sort_function()
    local called = {
        friendlyMode = 0,
        enemyMode = 0,
        friendlyFn = 0,
        enemyFn = 0,
    }

    fsCompare.FriendlySortMode = function()
        called.friendlyMode = called.friendlyMode + 1
        return true
    end
    fsCompare.EnemySortMode = function()
        called.enemyMode = called.enemyMode + 1
        return true
    end

    fsCompare.SortFunction = function(_, _units)
        called.friendlyFn = called.friendlyFn + 1
        -- reverse alpha so we can prove the comparator is used
        return function(a, b)
            return a > b
        end
    end

    fsCompare.EnemySortFunction = function(_, _units)
        called.enemyFn = called.enemyFn + 1
        return function(a, b)
            return a < b
        end
    end

    local units = { "party2", "player", "party1" }
    local out = fsSortedUnits:Sort(units, true)

    -- in-place + return same reference
    assert(out == units)

    -- sorted using friendly comparator (descending)
    assertListEquals(out, { "player", "party2", "party1" })

    assert(called.friendlyMode == 1)
    assert(called.friendlyFn == 1)
    assert(called.enemyMode == 0)
    assert(called.enemyFn == 0)
end

function M:test_units_sort_enemy_uses_enemy_mode_and_enemy_sort_function()
    local called = {
        friendlyMode = 0,
        enemyMode = 0,
        friendlyFn = 0,
        enemyFn = 0,
    }

    fsCompare.FriendlySortMode = function()
        called.friendlyMode = called.friendlyMode + 1
        return true
    end
    fsCompare.EnemySortMode = function()
        called.enemyMode = called.enemyMode + 1
        return true
    end

    fsCompare.SortFunction = function(_, _units)
        called.friendlyFn = called.friendlyFn + 1
        return function(a, b)
            return a < b
        end
    end

    fsCompare.EnemySortFunction = function(_, _units)
        called.enemyFn = called.enemyFn + 1
        -- reverse alpha so we can prove the enemy comparator is used
        return function(a, b)
            return a > b
        end
    end

    local units = { "arena2", "arena1", "arena3" }
    local out = fsSortedUnits:Sort(units, false)

    assert(out == units)
    assertListEquals(out, { "arena3", "arena2", "arena1" })

    assert(called.enemyMode == 1)
    assert(called.enemyFn == 1)
    assert(called.friendlyMode == 0)
    assert(called.friendlyFn == 0)
end

function M:test_units_sort_disabled_still_applies_cycle_instructions()
    -- Make sure cycles start clean
    if fsSortedUnits and fsSortedUnits.ResetFriendlyCycles then
        fsSortedUnits:ResetFriendlyCycles()
    end

    -- Disable sorting; we want to prove cycling still runs
    fsCompare.FriendlySortMode = function()
        return false
    end

    -- Role map: two DPS + one healer
    capabilities.HasRoleAssignments = function()
        return true
    end
    wow.UnitGroupRolesAssigned = function(unit)
        if unit == "party1" or unit == "party2" then
            return "DAMAGER"
        end
        if unit == "player" then
            return "HEALER"
        end
        return "NONE"
    end

    -- Queue a friendly cycle for DAMAGER (rotate down by 1)
    -- Expected: [party1, party2, player] -> DPS indices [1,2] => [party2, party1]
    fsSortedUnits:CycleFriendlyRoles({ "DAMAGER" }, 1)

    local units = { "party1", "party2", "player" }
    local out = fsSortedUnits:Sort(units, true)

    assert(out == units)
    assertListEquals(out, { "party2", "party1", "player" })
end

function M:test_units_sort_returns_same_reference_for_enemy_and_friendly()
    fsCompare.FriendlySortMode = function()
        return true
    end
    fsCompare.EnemySortMode = function()
        return true
    end

    fsCompare.SortFunction = function(_, _units)
        return function(a, b)
            return a < b
        end
    end

    fsCompare.EnemySortFunction = function(_, _units)
        return function(a, b)
            return a < b
        end
    end

    local f = { "party2", "party1" }
    local e = { "arena2", "arena1" }

    local fOut = fsSortedUnits:Sort(f, true)
    local eOut = fsSortedUnits:Sort(e, false)

    assert(fOut == f)
    assert(eOut == e)

    assertListEquals(fOut, { "party1", "party2" })
    assertListEquals(eOut, { "arena1", "arena2" })
end

return M
