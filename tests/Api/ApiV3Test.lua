---@type Addon
local addon
local M = {}
local partyUnitsCount = 3
local raidUnitsCount = 6
local arenaUnitsCount = 3

function M:setup()
    local addonFactory = require("TestHarness.AddonFactory")
    local frameMock = require("TestHarness.FrameMock")
    local providerFactory = require("TestHarness.ProviderFactory")

    addon = addonFactory:Create()
    addon.Locale:Init()
    addon.Api:Init()
    addon.Modules:Init()

    local fsFrame = addon.WoW.Frame
    local provider = providerFactory:Create()

    addon.Providers.Test = provider
    addon.Providers.All[#addon.Providers.All + 1] = provider

    local party = fsFrame:GetContainer(provider, fsFrame.ContainerType.Party)

    assert(party)

    local partyContainer = party.Frame

    for i = 1, partyUnitsCount do
        local unit = frameMock:New("Frame", nil, partyContainer, nil)
        unit.unit = "party" .. i
    end

    local raid = fsFrame:GetContainer(provider, fsFrame.ContainerType.Raid)

    assert(raid)

    local raidContainer = raid.Frame

    for i = 1, raidUnitsCount do
        local unit = frameMock:New("Frame", nil, raidContainer, nil)
        unit.unit = "raid" .. i
    end

    local arena = fsFrame:GetContainer(provider, fsFrame.ContainerType.EnemyArena)

    assert(arena)

    local arenaContainer = arena.Frame

    for i = 1, arenaUnitsCount do
        local unit = frameMock:New("Frame", nil, arenaContainer, nil)
        unit.unit = "arena" .. i
    end

    addon.WoW.Api.IsInInstance = function()
        return true, "arena"
    end
    addon.WoW.Api.GetNumGroupMembers = function()
        return partyUnitsCount
    end
    addon.WoW.Api.GetNumArenaOpponentSpecs = function()
        return arenaUnitsCount
    end
    addon.WoW.Api.UnitExists = function(unit)
        local number = tonumber(unit:match("%d+"))

        assert(number and number > 0)

        return number <= 3
    end
    addon.WoW.Capabilities.HasEnemySpecSupport = function()
        return true
    end
    addon.WoW.Capabilities.HasSpecializations = function()
        return true
    end

    addon.Locale["Can't do that during combat."] = "a"
end

function M:teardown()
    addon.WoW.WowEx.ClearMockInstance()
end

function M:test_frame_number_for_unit()
    ---@type ApiV3
    local v3 = FrameSortApi.v3
    local config = addon.DB.Options.Sorting

    -- reverse the ordering to ensure we're not lucky
    config.Arena.Default.Enabled = true
    config.Arena.Default.Reverse = true

    config.EnemyArena.Enabled = true
    config.EnemyArena.Reverse = true

    assertEquals(v3.Frame:FrameNumberForUnit("raid1"), 6)
    assertEquals(v3.Frame:FrameNumberForUnit("raid2"), 5)
    assertEquals(v3.Frame:FrameNumberForUnit("raid3"), 4)

    assertEquals(v3.Frame:FrameNumberForUnit("arena1"), 3)
    assertEquals(v3.Frame:FrameNumberForUnit("arena2"), 2)
    assertEquals(v3.Frame:FrameNumberForUnit("arena3"), 1)

    assertEquals(v3.Frame:FrameNumberForUnit(""), nil)
    assertEquals(v3.Frame:FrameNumberForUnit("party99"), nil)
end

function M:test_error_doesnt_propagate()
    ---@type ApiV3
    local v3 = FrameSortApi.v3

    local fsSort = addon.Modules.Sorting

    -- corrupt some stuff to cause an error
    ---@diagnostic disable-next-line: duplicate-set-field
    fsSort.RegisterPostSortCallback = function()
        assert(false, "Swallowed error")
    end

    local result = v3.Sorting:RegisterPostSortCallback(function() end)

    assertEquals(result, false)
end

function M:test_get_party_frames()
    local data = FrameSortApi.v3.Sorting:GetPartyFrames()
    local frames = data["Test"]

    assertEquals(#frames, partyUnitsCount)
end

function M:test_get_raid_frames()
    local data = FrameSortApi.v3.Sorting:GetRaidFrames()
    local frames = data["Test"]

    assertEquals(#frames, raidUnitsCount)
end

function M:test_get_arena_frames()
    local data = FrameSortApi.v3.Sorting:GetArenaFrames()
    local frames = data["Test"]

    assertEquals(#frames, arenaUnitsCount)
end

function M:test_get_friendly_units()
    local units = FrameSortApi.v3.Sorting:GetFriendlyUnits()

    assertEquals(#units, raidUnitsCount)
end

function M:test_get_enemy_units()
    local config = addon.DB.Options.Sorting.EnemyArena

    config.Enabled = true

    local units = FrameSortApi.v3.Sorting:GetEnemyUnits()

    -- times 2 for pets
    assertEquals(#units, arenaUnitsCount * 2)
end

function M:test_get_sort_mode()
    local config = addon.DB.Options.Sorting
    config.Arena.Twos.PlayerSortMode = "ArenaTestPlayer"
    config.Arena.Default.PlayerSortMode = "ArenaTestPlayer"
    config.Dungeon.PlayerSortMode = "DungeonTestPlayer"
    config.Raid.PlayerSortMode = "PlayerTestPlayer"
    config.World.PlayerSortMode = "WorldTestPlayer"

    config.Arena.GroupSortMode = "ArenaTestGroup"
    config.Dungeon.GroupSortMode = "DungeonTestGroup"
    config.Raid.GroupSortMode = "RaidTestGroup"
    config.World.GroupSortMode = "WorldTestGroup"

    assertEquals(FrameSortApi.v3.Options:GetPlayerSortMode("Arena - 2v2"), config.Arena.Twos.PlayerSortMode)
    assertEquals(FrameSortApi.v3.Options:GetPlayerSortMode("Arena - Default"), config.Arena.Default.PlayerSortMode)
    assertEquals(FrameSortApi.v3.Options:GetPlayerSortMode("Dungeon"), config.Dungeon.PlayerSortMode)
    assertEquals(FrameSortApi.v3.Options:GetPlayerSortMode("Raid"), config.Raid.PlayerSortMode)
    assertEquals(FrameSortApi.v3.Options:GetPlayerSortMode("World"), config.World.PlayerSortMode)

    assertEquals(FrameSortApi.v3.Options:GetGroupSortMode("Arena - 2v2"), config.Arena.Twos.GroupSortMode)
    assertEquals(FrameSortApi.v3.Options:GetGroupSortMode("Arena - Default"), config.Arena.Default.GroupSortMode)
    assertEquals(FrameSortApi.v3.Options:GetGroupSortMode("Dungeon"), config.Dungeon.GroupSortMode)
    assertEquals(FrameSortApi.v3.Options:GetGroupSortMode("Raid"), config.Raid.GroupSortMode)
    assertEquals(FrameSortApi.v3.Options:GetGroupSortMode("World"), config.World.GroupSortMode)

    ---@diagnostic disable-next-line: param-type-mismatch
    assertEquals(FrameSortApi.v3.Options:GetPlayerSortMode(nil), nil)
    ---@diagnostic disable-next-line: param-type-mismatch
    assertEquals(FrameSortApi.v3.Options:GetPlayerSortMode("invalid"), nil)

    ---@diagnostic disable-next-line: param-type-mismatch
    assertEquals(FrameSortApi.v3.Options:GetGroupSortMode(nil), nil)
    ---@diagnostic disable-next-line: param-type-mismatch
    assertEquals(FrameSortApi.v3.Options:GetGroupSortMode("invalid"), nil)
end

function M:test_set_sort_mode()
    assertEquals(FrameSortApi.v3.Options:SetPlayerSortMode("Arena - 2v2", "Bottom"), true)
    assertEquals(FrameSortApi.v3.Options:SetPlayerSortMode("Arena - Default", "Bottom"), true)
    assertEquals(FrameSortApi.v3.Options:SetPlayerSortMode("Dungeon", "Bottom"), true)
    assertEquals(FrameSortApi.v3.Options:SetPlayerSortMode("Raid", "Bottom"), true)
    assertEquals(FrameSortApi.v3.Options:SetPlayerSortMode("World", "Bottom"), true)

    assertEquals(FrameSortApi.v3.Options:SetGroupSortMode("Arena - 2v2", "Role"), true)
    assertEquals(FrameSortApi.v3.Options:SetGroupSortMode("Arena - Default", "Role"), true)
    assertEquals(FrameSortApi.v3.Options:SetGroupSortMode("Dungeon", "Role"), true)
    assertEquals(FrameSortApi.v3.Options:SetGroupSortMode("Raid", "Role"), true)
    assertEquals(FrameSortApi.v3.Options:SetGroupSortMode("World", "Role"), true)

    ---@diagnostic disable-next-line: param-type-mismatch
    assertEquals(FrameSortApi.v3.Options:SetPlayerSortMode("Invalid", "Bottom"), false)
    ---@diagnostic disable-next-line: param-type-mismatch
    assertEquals(FrameSortApi.v3.Options:SetGroupSortMode("Invalid", "Role"), false)

    local config = addon.DB.Options.Sorting
    assertEquals(config.Arena.Twos.PlayerSortMode, "Bottom")
    assertEquals(config.Arena.Default.PlayerSortMode, "Bottom")
    assertEquals(config.Dungeon.PlayerSortMode, "Bottom")
    assertEquals(config.Raid.PlayerSortMode, "Bottom")
    assertEquals(config.World.PlayerSortMode, "Bottom")

    assertEquals(config.Arena.Twos.GroupSortMode, "Role")
    assertEquals(config.Arena.Default.GroupSortMode, "Role")
    assertEquals(config.Dungeon.GroupSortMode, "Role")
    assertEquals(config.Raid.GroupSortMode, "Role")
    assertEquals(config.World.GroupSortMode, "Role")
end

function M:test_register_external_frame_provider_nil()
    ---@type ApiV3
    local v3 = FrameSortApi.v3

    ---@diagnostic disable-next-line: param-type-mismatch
    local ok = v3.Sorting:RegisterFrameProvider(nil)

    assertEquals(ok, false)
end

function M:test_register_external_frame_provider_invalid_provider_not_added()
    ---@type ApiV3
    local v3 = FrameSortApi.v3

    local beforeCount = #addon.Providers.All

    -- Missing required methods (Name, IsVisible)
    local invalidProvider = {
        Enabled = function()
            return true
        end,
    }

    local ok = v3.Sorting:RegisterFrameProvider(invalidProvider)

    assertEquals(ok, false)
    assertEquals(#addon.Providers.All, beforeCount)
end

function M:test_register_external_frame_provider_valid_provider_added_and_marked_external()
    ---@type ApiV3
    local v3 = FrameSortApi.v3

    local beforeCount = #addon.Providers.All

    local externalProvider = {
        Enabled = function()
            return true
        end,
        Name = function()
            return "ExternalTest"
        end,
        IsVisible = function()
            return true
        end,
    }

    local ok = v3.Sorting:RegisterFrameProvider(externalProvider)

    assertEquals(ok, true)
    assertEquals(externalProvider.IsExternal, true)
    assertEquals(#addon.Providers.All, beforeCount + 1)
    assertEquals(addon.Providers.All[#addon.Providers.All], externalProvider)
end

function M:test_register_external_frame_provider_error_doesnt_propagate()
    ---@type ApiV3
    local v3 = FrameSortApi.v3

    -- Force an error inside the providers module method to ensure SafeCall swallows it
    ---@diagnostic disable-next-line: duplicate-set-field
    addon.Providers.RegisterFrameProvider = function()
        error("Swallowed error")
    end

    local provider = {
        Enabled = function()
            return true
        end,
        Name = function()
            return "ExternalErrorTest"
        end,
        IsVisible = function()
            return true
        end,
    }

    local ok = v3.Sorting:RegisterFrameProvider(provider)

    assertEquals(ok, false)
end


function M:test_api_cycle_friendly_roles_happy_path_calls_sortedunits_and_run()
    ---@type ApiV3
    local v3 = FrameSortApi.v3

    -- ensure not in combat
    addon.WoW.Api.InCombatLockdown = function()
        return false
    end

    local calledCycle = 0
    local calledRun = 0
    local gotRoles, gotCycles

    addon.Modules.Sorting.SortedUnits.CycleFriendlyRoles = function(_, roles, cycles)
        calledCycle = calledCycle + 1
        gotRoles = roles
        gotCycles = cycles
    end

    addon.Modules.Run = function()
        calledRun = calledRun + 1
    end

    local roles = { "TANK", "DAMAGER", "HEALER" }
    local ok = v3.Frame:CycleFriendlyRoles(roles, 2)

    assertEquals(ok, true)
    assertEquals(calledCycle, 1)
    assertEquals(calledRun, 1)
    assert(gotRoles == roles)
    assertEquals(gotCycles, 2)
end

function M:test_api_cycle_enemy_roles_happy_path_calls_sortedunits_and_run()
    ---@type ApiV3
    local v3 = FrameSortApi.v3

    addon.WoW.Api.InCombatLockdown = function()
        return false
    end

    local calledCycle = 0
    local calledRun = 0
    local gotRoles, gotCycles

    addon.Modules.Sorting.SortedUnits.CycleEnemyRoles = function(_, roles, cycles)
        calledCycle = calledCycle + 1
        gotRoles = roles
        gotCycles = cycles
    end

    addon.Modules.Run = function()
        calledRun = calledRun + 1
    end

    local roles = { "DAMAGER", "HEALER" }
    local ok = v3.Frame:CycleEnemyRoles(roles, 1)

    assertEquals(ok, true)
    assertEquals(calledCycle, 1)
    assertEquals(calledRun, 1)
    assert(gotRoles == roles)
    assertEquals(gotCycles, 1)
end

function M:test_api_cycle_roles_returns_false_in_combat_and_does_not_call_run_or_cycle()
    ---@type ApiV3
    local v3 = FrameSortApi.v3

    addon.WoW.Api.InCombatLockdown = function()
        return true
    end

    local friendlyCalled = 0
    local enemyCalled = 0
    local runCalled = 0

    addon.Modules.Sorting.SortedUnits.CycleFriendlyRoles = function()
        friendlyCalled = friendlyCalled + 1
    end
    addon.Modules.Sorting.SortedUnits.CycleEnemyRoles = function()
        enemyCalled = enemyCalled + 1
    end
    addon.Modules.Run = function()
        runCalled = runCalled + 1
    end

    assertEquals(v3.Frame:CycleFriendlyRoles({ "DAMAGER" }, 1), false)
    assertEquals(v3.Frame:CycleEnemyRoles({ "DAMAGER" }, 1), false)

    assertEquals(friendlyCalled, 0)
    assertEquals(enemyCalled, 0)
    assertEquals(runCalled, 0)
end

function M:test_api_cycle_friendly_roles_rejects_nil_or_non_table_roles()
    ---@type ApiV3
    local v3 = FrameSortApi.v3

    addon.WoW.Api.InCombatLockdown = function()
        return false
    end

    local called = 0
    addon.Modules.Sorting.SortedUnits.CycleFriendlyRoles = function()
        called = called + 1
    end

    ---@diagnostic disable-next-line: param-type-mismatch
    assertEquals(v3.Frame:CycleFriendlyRoles(nil, 1), false)
    ---@diagnostic disable-next-line: param-type-mismatch
    assertEquals(v3.Frame:CycleFriendlyRoles("DAMAGER", 1), false)

    assertEquals(called, 0)
end

function M:test_api_cycle_enemy_roles_rejects_nil_or_non_table_roles()
    ---@type ApiV3
    local v3 = FrameSortApi.v3

    addon.WoW.Api.InCombatLockdown = function()
        return false
    end

    local called = 0
    addon.Modules.Sorting.SortedUnits.CycleEnemyRoles = function()
        called = called + 1
    end

    ---@diagnostic disable-next-line: param-type-mismatch
    assertEquals(v3.Frame:CycleEnemyRoles(nil, 1), false)
    ---@diagnostic disable-next-line: param-type-mismatch
    assertEquals(v3.Frame:CycleEnemyRoles(123, 1), false)

    assertEquals(called, 0)
end

function M:test_api_cycle_friendly_roles_swallows_internal_error_and_returns_false()
    ---@type ApiV3
    local v3 = FrameSortApi.v3

    addon.WoW.Api.InCombatLockdown = function()
        return false
    end

    addon.Modules.Sorting.SortedUnits.CycleFriendlyRoles = function()
        error("Swallowed error")
    end

    local runCalled = 0
    addon.Modules.Run = function()
        runCalled = runCalled + 1
    end

    local ok = v3.Frame:CycleFriendlyRoles({ "DAMAGER" }, 1)
    assertEquals(ok, false)
    assertEquals(runCalled, 0)
end

function M:test_api_cycle_enemy_roles_swallows_internal_error_and_returns_false()
    ---@type ApiV3
    local v3 = FrameSortApi.v3

    addon.WoW.Api.InCombatLockdown = function()
        return false
    end

    addon.Modules.Sorting.SortedUnits.CycleEnemyRoles = function()
        error("Swallowed error")
    end

    local runCalled = 0
    addon.Modules.Run = function()
        runCalled = runCalled + 1
    end

    local ok = v3.Frame:CycleEnemyRoles({ "DAMAGER" }, 1)
    assertEquals(ok, false)
    assertEquals(runCalled, 0)
end

function M:test_api_reset_friendly_cycles_calls_sortedunits_and_run()
    ---@type ApiV3
    local v3 = FrameSortApi.v3

    addon.WoW.Api.InCombatLockdown = function()
        return false
    end

    local calledReset = 0
    local calledRun = 0

    addon.Modules.Sorting.SortedUnits.ResetFriendlyCycles = function()
        calledReset = calledReset + 1
    end

    addon.Modules.Run = function()
        calledRun = calledRun + 1
    end

    local ok = v3.Frame:ResetFriendlyCycles()

    assertEquals(ok, true)
    assertEquals(calledReset, 1)
    assertEquals(calledRun, 1)
end

function M:test_api_reset_enemy_cycles_calls_sortedunits_and_run()
    ---@type ApiV3
    local v3 = FrameSortApi.v3

    addon.WoW.Api.InCombatLockdown = function()
        return false
    end

    local calledReset = 0
    local calledRun = 0

    addon.Modules.Sorting.SortedUnits.ResetEnemyCycles = function()
        calledReset = calledReset + 1
    end

    addon.Modules.Run = function()
        calledRun = calledRun + 1
    end

    local ok = v3.Frame:ResetEnemyCycles()

    assertEquals(ok, true)
    assertEquals(calledReset, 1)
    assertEquals(calledRun, 1)
end

function M:test_api_reset_cycles_returns_false_in_combat_and_does_not_call_run()
    ---@type ApiV3
    local v3 = FrameSortApi.v3

    addon.WoW.Api.InCombatLockdown = function()
        return true
    end

    local friendlyCalled = 0
    local enemyCalled = 0
    local runCalled = 0

    addon.Modules.Sorting.SortedUnits.ResetFriendlyCycles = function()
        friendlyCalled = friendlyCalled + 1
    end
    addon.Modules.Sorting.SortedUnits.ResetEnemyCycles = function()
        enemyCalled = enemyCalled + 1
    end
    addon.Modules.Run = function()
        runCalled = runCalled + 1
    end

    assertEquals(v3.Frame:ResetFriendlyCycles(), false)
    assertEquals(v3.Frame:ResetEnemyCycles(), false)

    assertEquals(friendlyCalled, 0)
    assertEquals(enemyCalled, 0)
    assertEquals(runCalled, 0)
end

local function UseManualEnemyRoles()
    addon.WoW.Api.GetBuildInfo = function()
        return "x", "0", "0", 120105
    end
    addon.WoW.Api.GetSpecializationInfoByID = function(specId)
        return specId, "", "", 0, addon.Modules.EnemyAssignments:RoleForSpec(specId), "", ""
    end
    addon.WoW.Api.InCombatLockdown = function()
        return false
    end
    addon.WoW.WowEx.MockInstance(true, "arena")

    -- the run would re-sort real frames, which these tests don't care about
    addon.Modules.Run = function() end

    local config = addon.DB.Options.Sorting.EnemyArena
    config.Enabled = true
    config.GroupSortMode = "Role"
    config.Reverse = false
end

function M:test_enemy_get_assignments_is_in_sorted_frame_order_with_role_spec_and_source()
    ---@type ApiV3
    local v3 = FrameSortApi.v3
    local marks = addon.Modules.EnemyAssignments
    UseManualEnemyRoles()

    marks:Set(1, "DAMAGER")
    marks:Set(2, nil, 65)
    marks:Set(3, "TANK")

    assertEquals(v3.Enemy:GetAssignments(), {
        { Unit = "arena3", Slot = 3, FrameNumber = 1, Role = "TANK", SpecId = nil, Source = "Manual" },
        { Unit = "arena2", Slot = 2, FrameNumber = 2, Role = "HEALER", SpecId = 65, Source = "Manual" },
        { Unit = "arena1", Slot = 1, FrameNumber = 3, Role = "DAMAGER", SpecId = nil, Source = "Manual" },
    })
end

function M:test_enemy_get_assignments_leaves_unmarked_enemies_without_a_role_or_source()
    ---@type ApiV3
    local v3 = FrameSortApi.v3
    UseManualEnemyRoles()

    local assignments = v3.Enemy:GetAssignments()

    assertEquals(#assignments, 3)
    assertEquals(assignments[1], { Unit = "arena1", Slot = 1, FrameNumber = 1 })
end

function M:test_enemy_get_assignments_reports_game_specs_as_game()
    ---@type ApiV3
    local v3 = FrameSortApi.v3
    UseManualEnemyRoles()
    addon.WoW.Api.GetBuildInfo = function()
        return "x", "0", "0", 120100
    end
    addon.WoW.Api.GetArenaOpponentSpec = function(i)
        return i == 1 and 65 or nil
    end

    local first = v3.Enemy:GetAssignments()[1]

    assertEquals(first.Unit, "arena1")
    assertEquals(first.SpecId, 65)
    assertEquals(first.Role, "HEALER")
    assertEquals(first.Source, "Game")
end

function M:test_enemy_get_assignments_is_empty_outside_an_arena()
    ---@type ApiV3
    local v3 = FrameSortApi.v3
    UseManualEnemyRoles()
    addon.WoW.WowEx.ClearMockInstance()
    addon.WoW.Api.IsInInstance = function()
        return false, "none"
    end

    assertEquals(v3.Enemy:GetAssignments(), {})
end

function M:test_enemy_get_assignments_reports_game_specs_when_manual_roles_are_inactive()
    ---@type ApiV3
    local v3 = FrameSortApi.v3
    UseManualEnemyRoles()
    addon.WoW.Api.GetBuildInfo = function()
        return "x", "0", "0", 120100
    end
    addon.WoW.Api.GetArenaOpponentSpec = function()
        return 65
    end

    local marks = addon.Modules.EnemyAssignments
    local entries = v3.Enemy:GetAssignments()

    assertEquals(marks:Set(1, "TANK"), false)
    assertEquals(#entries, 3)

    for _, entry in ipairs(entries) do
        assertEquals(entry.Role, "HEALER")
        assertEquals(entry.Source, "Game")
    end
end

function M:test_enemy_request_spec_picker_records_the_addon_in_order()
    ---@type ApiV3
    local v3 = FrameSortApi.v3

    assertEquals(v3.Enemy:RequestSpecPicker("Shackled"), true)
    assertEquals(v3.Enemy:RequestSpecPicker("Other"), true)

    assertEquals(addon.Modules.EnemyAssignmentsWindow:SpecPickerRequesters(), { "Shackled", "Other" })
end

function M:test_enemy_request_spec_picker_ignores_a_repeated_name()
    ---@type ApiV3
    local v3 = FrameSortApi.v3

    v3.Enemy:RequestSpecPicker("Shackled")
    v3.Enemy:RequestSpecPicker("Shackled")

    assertEquals(addon.Modules.EnemyAssignmentsWindow:SpecPickerRequesters(), { "Shackled" })
end

function M:test_enemy_request_spec_picker_ignores_bad_input()
    ---@type ApiV3
    local v3 = FrameSortApi.v3

    assertEquals(v3.Enemy:RequestSpecPicker(nil), false)
    assertEquals(v3.Enemy:RequestSpecPicker(""), false)
    assertEquals(v3.Enemy:RequestSpecPicker(123), false)
    assertEquals(v3.Enemy:RequestSpecPicker({}), false)

    assertEquals(addon.Modules.EnemyAssignmentsWindow:SpecPickerRequesters(), {})
end

function M:test_enemy_request_spec_picker_swallows_internal_errors()
    ---@type ApiV3
    local v3 = FrameSortApi.v3
    addon.Modules.EnemyAssignmentsWindow.RequestSpecPicker = function()
        error("boom")
    end

    assertEquals(v3.Enemy:RequestSpecPicker("Shackled"), false)
end

function M:test_enemy_get_assignments_swallows_internal_errors()
    ---@type ApiV3
    local v3 = FrameSortApi.v3
    UseManualEnemyRoles()
    addon.Modules.Sorting.SortedUnits.ArenaUnits = function()
        error("boom")
    end

    assertEquals(v3.Enemy:GetAssignments(), {})
end

function M:test_enemy_callback_receives_assignments_after_a_mark()
    ---@type ApiV3
    local v3 = FrameSortApi.v3
    UseManualEnemyRoles()

    local got
    local calls = 0
    local order = {}
    addon.Modules.Run = function()
        order[#order + 1] = "run"
    end

    assertEquals(v3.Enemy:RegisterAssignmentsChangedCallback(function(assignments)
        calls = calls + 1
        order[#order + 1] = "callback"
        got = assignments
    end), true)

    addon.Modules.EnemyAssignments:Set(2, "HEALER")

    assertEquals(calls, 1)
    assertEquals(order, { "run", "callback" })
    assertEquals(got[1].Unit, "arena2")
    assertEquals(got[1].Role, "HEALER")
end

function M:test_enemy_callback_gets_a_copy_it_can_mutate()
    ---@type ApiV3
    local v3 = FrameSortApi.v3
    UseManualEnemyRoles()

    v3.Enemy:RegisterAssignmentsChangedCallback(function(assignments)
        assignments[1].Role = "TANK"
        assignments[1] = nil
    end)
    local seen
    v3.Enemy:RegisterAssignmentsChangedCallback(function(assignments)
        seen = assignments
    end)

    addon.Modules.EnemyAssignments:Set(1, "HEALER")

    assertEquals(seen[1].Role, "HEALER")
    assertEquals(v3.Enemy:GetAssignments()[1].Role, "HEALER")
end

function M:test_enemy_callback_is_deferred_in_combat_until_combat_ends()
    ---@type ApiV3
    local v3 = FrameSortApi.v3
    local realRun = addon.Modules.Run
    UseManualEnemyRoles()

    local calls = 0
    local state = { combat = true }
    addon.WoW.Api.InCombatLockdown = function()
        return state.combat
    end
    addon.Modules.Run = realRun
    addon.Modules.Sorting.Run = function() end
    v3.Enemy:RegisterAssignmentsChangedCallback(function()
        calls = calls + 1
    end)

    addon.Modules.EnemyAssignments:Set(1, "TANK")
    addon.Modules.EnemyAssignments:Set(2, "HEALER")

    assertEquals(calls, 0)
    assertEquals(v3.Enemy:GetAssignments()[1].Role, "TANK")

    state.combat = false
    addon.Scheduling.Scheduler:ProcessEvent(addon.WoW.Events.PLAYER_REGEN_ENABLED)

    assertEquals(calls, 1)
end

function M:test_enemy_callback_errors_do_not_stop_other_callbacks()
    ---@type ApiV3
    local v3 = FrameSortApi.v3
    UseManualEnemyRoles()

    local called = false
    local logged = {}
    addon.Logging.Log.Error = function(_, format, ...)
        logged[#logged + 1] = string.format(format, ...)
    end
    v3.Enemy:RegisterAssignmentsChangedCallback(function()
        error("bad consumer")
    end)
    v3.Enemy:RegisterAssignmentsChangedCallback(function()
        called = true
    end)

    addon.Modules.EnemyAssignments:Set(1, "TANK")

    assertEquals(called, true)
    assertEquals(#logged, 1)
    assert(logged[1]:find("Api.v3.Enemy:RegisterAssignmentsChangedCallback", 1, true), logged[1])
    assert(logged[1]:find("bad consumer", 1, true), logged[1])
end

function M:test_enemy_callback_rejects_non_functions()
    ---@type ApiV3
    local v3 = FrameSortApi.v3

    assertEquals(v3.Enemy:RegisterAssignmentsChangedCallback(nil), false)
    assertEquals(v3.Enemy:RegisterAssignmentsChangedCallback("x"), false)
end

return M
