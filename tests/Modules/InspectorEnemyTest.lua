---@diagnostic disable: duplicate-set-field, cast-local-type

---@type Addon
local addon
local wow
---@type InspectorModule
local fsInspector
---@type EnemyAssignmentsModule
local marks
local M = {}

local holyPaladin = 65

local function setBuild(build)
    wow.GetBuildInfo = function()
        return "x", "0", "0", build
    end
end

function M:setup()
    local addonFactory = require("TestHarness.AddonFactory")

    addon = addonFactory:Create()
    wow = addon.WoW.Api
    fsInspector = addon.Modules.Inspector
    marks = addon.Modules.EnemyAssignments

    addon.WoW.Capabilities.HasEnemySpecSupport = function()
        return true
    end
    addon.WoW.WowEx.MockInstance(true, "arena")
    setBuild(120105)

    -- the run would re-sort real frames, which this test has none of
    addon.Modules.Run = function() end
    wow.GetSpecializationInfoByID = function(specId)
        return specId, "", "", 0, marks:RoleForSpec(specId), "", ""
    end
end

function M:teardown()
    addon.WoW.WowEx.ClearMockInstance()
    addon = nil
    fsInspector = nil
    marks = nil
end

function M:test_enemy_spec_and_role_come_from_the_mark_in_an_arena()
    marks:Set(2, nil, holyPaladin)

    assertEquals(fsInspector:EnemyUnitSpec("arena2"), holyPaladin)
    assertEquals(fsInspector:EnemyUnitRole("arena2"), "HEALER")
end

function M:test_enemy_role_comes_from_a_mark_that_has_no_spec()
    marks:Set(1, "TANK")

    assertEquals(fsInspector:EnemyUnitSpec("arena1"), nil)
    assertEquals(fsInspector:EnemyUnitRole("arena1"), "TANK")
end

function M:test_an_unmarked_enemy_has_no_spec_or_role()
    marks:Set(1, "TANK")

    assertEquals(fsInspector:EnemyUnitSpec("arena2"), nil)
    assertEquals(fsInspector:EnemyUnitRole("arena2"), nil)
end

function M:test_a_spec_the_game_reports_wins_over_the_mark()
    marks:Set(1, nil, holyPaladin)
    wow.GetArenaOpponentSpec = function()
        return 72
    end

    assertEquals(fsInspector:EnemyUnitSpec("arena1"), 72)
    assertEquals(fsInspector:EnemyUnitRole("arena1"), "DAMAGER")
end

function M:test_marks_are_not_read_outside_an_arena()
    marks:Set(1, nil, holyPaladin)
    addon.WoW.WowEx.ClearMockInstance()
    wow.IsInInstance = function()
        return false
    end

    assertEquals(fsInspector:EnemyUnitSpec("arena1"), nil)
    assertEquals(fsInspector:EnemyUnitRole("arena1"), nil)
end

function M:test_marks_are_not_read_on_a_client_that_reads_specs_itself()
    marks:Set(1, nil, holyPaladin)
    setBuild(120100)

    assertEquals(fsInspector:EnemyUnitSpec("arena1"), nil)
    assertEquals(fsInspector:EnemyUnitRole("arena1"), nil)
end

function M:test_an_unresolved_nameplate_does_not_read_the_mark_of_the_same_number()
    marks:Set(2, nil, holyPaladin)
    wow.C_NamePlate = { GetNamePlateForUnit = function() end }

    assertEquals(fsInspector:EnemyUnitSpec("nameplate2"), nil)
    assertEquals(fsInspector:EnemyUnitRole("nameplate2"), nil)
end

function M:test_enemy_pets_have_no_spec_or_role()
    marks:Set(1, nil, holyPaladin)

    assertEquals(fsInspector:EnemyUnitSpec("arenapet1"), nil)
    assertEquals(fsInspector:EnemyUnitRole("arenapet1"), nil)
end

function M:test_enemy_role_falls_back_to_the_mark_when_the_game_gives_no_role_for_the_spec()
    marks:Set(1, nil, holyPaladin)
    wow.GetSpecializationInfoByID = function()
        return nil
    end

    assertEquals(fsInspector:EnemyUnitRole("arena1"), "HEALER")
end

return M
