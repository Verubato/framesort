---@diagnostic disable: duplicate-set-field, cast-local-type

---@type Addon
local addon
local wow
local events
---@type EnemyAssignmentsModule
local marks
local trace
local realRun
local M = {}

local Healer = "HEALER"
local Tank = "TANK"
local Dps = "DAMAGER"

local holyPaladin, protPaladin, arcaneMage, furyWarrior = 65, 66, 62, 72

local function setBuild(build)
    wow.GetBuildInfo = function()
        return "x", "0", "0", build
    end
end

local function enterArena()
    addon.WoW.WowEx.MockInstance(true, "arena")
end

local function setMatchState(state)
    wow.C_PvP = wow.C_PvP or {}
    wow.C_PvP.GetActiveMatchState = function()
        return state
    end
end

function M:setup()
    local addonFactory = require("TestHarness.AddonFactory")

    addon = addonFactory:Create()
    wow = addon.WoW.Api
    events = addon.WoW.Events
    marks = addon.Modules.EnemyAssignments
    trace = {}

    addon.WoW.Capabilities.HasEnemySpecSupport = function()
        return true
    end
    addon.WoW.Capabilities.HasSpecializations = function()
        return true
    end
    wow.GetNumArenaOpponentSpecs = function()
        return 3
    end
    wow.Enum.PvPMatchState = { StartUp = 1, Engaged = 2, PostRound = 3, Complete = 4 }
    wow.C_PvP = { IsSoloShuffle = function() return false end }
    setBuild(120105)

    realRun = addon.Modules.Run
    addon.Modules.Run = function()
        trace[#trace + 1] = "run"
    end
    marks:RegisterCallback(function()
        trace[#trace + 1] = "changed"
    end)
    marks:RegisterNotifyCallback(function()
        trace[#trace + 1] = "notify"
    end)
    marks:RegisterPromptCallback(function(visible)
        trace[#trace + 1] = visible and "show" or "hide"
    end)
end

function M:teardown()
    addon.WoW.WowEx.ClearMockInstance()
    addon = nil
    wow = nil
    events = nil
    marks = nil
    trace = nil
end

local function count(name)
    local total = 0

    for _, entry in ipairs(trace) do
        if entry == name then
            total = total + 1
        end
    end

    return total
end

function M:test_set_stores_a_role()
    assertEquals(marks:Set(2, Healer), true)

    assertEquals(marks:Role(2), Healer)
    assertEquals(marks:Spec(2), nil)
    assertEquals(marks:HasAny(), true)
    assertEquals(marks:Role(1), nil)
end

function M:test_a_spec_decides_the_role()
    marks:Set(1, Dps, holyPaladin)

    assertEquals(marks:Role(1), Healer)
    assertEquals(marks:Spec(1), holyPaladin)
end

function M:test_a_role_that_disagrees_with_the_kept_spec_drops_the_spec()
    marks:Set(1, nil, holyPaladin)

    marks:Set(1, Dps)

    assertEquals(marks:Role(1), Dps)
    assertEquals(marks:Spec(1), nil)
end

function M:test_a_role_that_agrees_with_the_kept_spec_keeps_the_spec()
    marks:Set(1, nil, holyPaladin)

    marks:Set(1, Healer)

    assertEquals(marks:Spec(1), holyPaladin)
end

function M:test_clear_spec_keeps_the_role()
    marks:Set(1, nil, holyPaladin)

    marks:ClearSpec(1)

    assertEquals(marks:Role(1), Healer)
    assertEquals(marks:Spec(1), nil)
end

function M:test_set_with_neither_clears_the_slot()
    marks:Set(1, Tank)

    marks:Set(1, nil)

    assertEquals(marks:Role(1), nil)
    assertEquals(marks:HasAny(), false)
end

function M:test_setting_the_same_mark_again_changes_nothing()
    marks:Set(1, Tank)
    trace = {}

    marks:Set(1, Tank)

    assertEquals(trace, {})
end

function M:test_clearing_an_empty_slot_changes_nothing()
    marks:Set(1, nil)

    assertEquals(trace, {})
end

function M:test_invalid_input_is_rejected_without_changing_anything()
    marks:Set(1, Tank)
    trace = {}

    assertEquals(marks:Set(0, Tank), false)
    assertEquals(marks:Set(6, Tank), false)
    assertEquals(marks:Set(1.5, Tank), false)
    assertEquals(marks:Set(1, "NONE"), false)
    assertEquals(marks:Set(1, "bogus"), false)
    assertEquals(marks:Set(1, nil, 999999), false)

    assertEquals(marks:Role(1), Tank)
    assertEquals(trace, {})
end

function M:test_nothing_is_stored_on_a_client_that_reads_specs_itself()
    setBuild(120100)

    assertEquals(marks:Set(1, Tank), false)

    assertEquals(marks:HasAny(), false)
    assertEquals(trace, {})
end

function M:test_is_complete_needs_every_slot_up_to_the_count()
    marks:Set(1, Tank)
    marks:Set(2, Healer)

    assertEquals(marks:IsComplete(2), true)
    assertEquals(marks:IsComplete(3), false)
    assertEquals(marks:IsComplete(0), false)
end

function M:test_role_for_spec_follows_the_spec_type()
    assertEquals(marks:RoleForSpec(protPaladin), Tank)
    assertEquals(marks:RoleForSpec(holyPaladin), Healer)
    assertEquals(marks:RoleForSpec(arcaneMage), Dps)
    assertEquals(marks:RoleForSpec(furyWarrior), Dps)
    assertEquals(marks:RoleForSpec(999999), nil)
end

function M:test_spec_choices_by_role()
    local tanks = marks:SpecChoices(Tank)

    assertEquals(tanks[1] ~= nil, true)
    for _, specId in ipairs(tanks) do
        assertEquals(marks:RoleForSpec(specId), Tank)
    end
    assertEquals(#marks:SpecChoices(Healer) < #marks:SpecChoices(), true)
    assertEquals(#tanks + #marks:SpecChoices(Healer) + #marks:SpecChoices(Dps), #marks:SpecChoices())
end

function M:test_spec_choices_by_role_and_class()
    -- paladin is class 2
    assertEquals(marks:SpecChoices(Healer, 2), { holyPaladin })
    assertEquals(marks:SpecChoices(Tank, 2), { protPaladin })
    assertEquals(marks:SpecChoices(Healer, 8), {})
end

function M:test_changed_callbacks_run_before_the_run_and_the_notify_follows()
    marks:Set(1, Tank)

    assertEquals(trace, { "changed", "run", "notify" })
end

function M:test_notify_waits_for_combat_to_end_and_repeats_collapse()
    addon.Modules.Run = realRun
    addon.Modules.Sorting.Run = function() end
    wow.State.MockInCombat = true

    marks:Set(1, Tank)
    marks:Set(2, Healer)

    assertEquals(count("changed"), 2)
    assertEquals(count("notify"), 0)

    wow.State.MockInCombat = false
    addon.Scheduling.Scheduler:ProcessEvent(events.PLAYER_REGEN_ENABLED)

    assertEquals(count("notify"), 1)
end

function M:test_notify_follows_the_sort_when_combat_ends()
    addon.Modules.Run = realRun
    addon.Modules.Sorting.Run = function()
        trace[#trace + 1] = "sort"
    end
    wow.State.MockInCombat = true

    marks:Set(1, Tank)

    wow.State.MockInCombat = false
    addon.Scheduling.Scheduler:ProcessEvent(events.PLAYER_REGEN_ENABLED)

    assertEquals(trace, { "changed", "sort", "notify" })
end

function M:test_after_run_requests_its_own_run_in_combat()
    addon.Modules.Run = realRun
    addon.Modules.Sorting.Run = function()
        trace[#trace + 1] = "sort"
    end
    wow.State.MockInCombat = true

    addon.Modules:AfterRun(function()
        trace[#trace + 1] = "after"
    end)

    wow.State.MockInCombat = false
    addon.Scheduling.Scheduler:ProcessEvent(events.PLAYER_REGEN_ENABLED)

    assertEquals(trace, { "sort", "after" })
end

function M:test_a_failing_after_run_callback_does_not_stop_the_others()
    addon.Modules.Run = realRun
    addon.Modules.Sorting.Run = function() end
    wow.State.MockInCombat = true

    addon.Modules:AfterRun(function()
        error("boom")
    end)
    addon.Modules:AfterRun(function()
        trace[#trace + 1] = "second"
    end)

    wow.State.MockInCombat = false
    addon.Scheduling.Scheduler:ProcessEvent(events.PLAYER_REGEN_ENABLED)

    assertEquals(trace, { "second" })
end

function M:test_shuffle_healer_marks_the_other_enemies_as_dps()
    wow.C_PvP.IsSoloShuffle = function()
        return true
    end
    marks:Set(1, Tank)
    trace = {}

    marks:Set(2, Healer)

    assertEquals(marks:Role(1), Tank)
    assertEquals(marks:Role(2), Healer)
    assertEquals(marks:Role(3), Dps)
    -- the fill is part of the same change
    assertEquals(trace, { "changed", "run", "notify" })
end

function M:test_the_prompt_stays_open_after_the_healer_fills_the_other_rows()
    enterArena()
    wow.C_PvP.IsSoloShuffle = function()
        return true
    end

    marks:Set(2, Healer)

    assertEquals(marks:IsComplete(3), true)
    assertEquals(count("hide"), 0)
end

function M:test_the_prompt_closes_once_the_user_sets_the_filled_rows_themselves()
    enterArena()
    wow.C_PvP.IsSoloShuffle = function()
        return true
    end
    marks:Set(2, Healer)

    marks:Set(1, Dps)
    assertEquals(count("hide"), 0)

    marks:Set(3, Dps)
    assertEquals(count("hide"), 1)
end

function M:test_shuffle_rule_does_nothing_outside_solo_shuffle()
    marks:Set(2, Healer)

    assertEquals(marks:Role(1), nil)
    assertEquals(marks:Role(3), nil)
end

function M:test_shuffle_rule_does_nothing_for_a_dps_mark()
    wow.C_PvP.IsSoloShuffle = function()
        return true
    end

    marks:Set(2, Dps)

    assertEquals(marks:Role(1), nil)
end

function M:test_clear_removes_every_mark_and_tells_listeners()
    marks:Set(1, Tank)
    marks:Set(2, Healer)
    trace = {}

    marks:Clear()

    assertEquals(marks:HasAny(), false)
    assertEquals(trace, { "changed", "run", "notify" })
end

function M:test_round_end_with_nothing_marked_does_not_run_or_notify()
    enterArena()
    setMatchState(wow.Enum.PvPMatchState.PostRound)

    marks:ProcessEvent(events.PVP_MATCH_STATE_CHANGED)

    assertEquals(count("run"), 0)
    assertEquals(count("notify"), 0)
end

function M:test_prep_event_shows_the_prompt_once_a_round()
    addon.DB.Options.EnemyAssignments.PopupEnabled = true
    enterArena()

    marks:ProcessEvent(events.ARENA_PREP_OPPONENT_SPECIALIZATIONS)
    marks:ProcessEvent(events.ARENA_PREP_OPPONENT_SPECIALIZATIONS)

    assertEquals(count("show"), 1)
end

function M:test_match_start_shows_the_prompt_when_the_prep_event_never_fires()
    addon.DB.Options.EnemyAssignments.PopupEnabled = true
    enterArena()
    setMatchState(wow.Enum.PvPMatchState.StartUp)

    marks:ProcessEvent(events.PVP_MATCH_STATE_CHANGED)

    assertEquals(count("show"), 1)
end

function M:test_prompt_stays_hidden_when_the_option_is_off()
    addon.DB.Options.EnemyAssignments.PopupEnabled = false
    enterArena()

    marks:ProcessEvent(events.ARENA_PREP_OPPONENT_SPECIALIZATIONS)

    assertEquals(count("show"), 0)
end

function M:test_prompt_stays_hidden_outside_an_arena()
    addon.DB.Options.EnemyAssignments.PopupEnabled = true

    marks:ProcessEvent(events.ARENA_PREP_OPPONENT_SPECIALIZATIONS)

    assertEquals(count("show"), 0)
end

function M:test_prompt_stays_hidden_when_every_enemy_is_already_marked()
    addon.DB.Options.EnemyAssignments.PopupEnabled = true
    enterArena()
    marks:Set(1, Tank)
    marks:Set(2, Healer)
    marks:Set(3, Dps)

    marks:ProcessEvent(events.ARENA_PREP_OPPONENT_SPECIALIZATIONS)

    assertEquals(count("show"), 0)
end

function M:test_round_end_clears_the_marks_and_the_next_round_offers_the_prompt_again()
    addon.DB.Options.EnemyAssignments.PopupEnabled = true
    enterArena()
    marks:ProcessEvent(events.ARENA_PREP_OPPONENT_SPECIALIZATIONS)
    marks:Set(1, Tank)
    trace = {}

    setMatchState(wow.Enum.PvPMatchState.PostRound)
    marks:ProcessEvent(events.PVP_MATCH_STATE_CHANGED)

    assertEquals(marks:HasAny(), false)
    assertEquals(count("hide"), 1)
    assertEquals(count("run"), 1)

    marks:ProcessEvent(events.ARENA_PREP_OPPONENT_SPECIALIZATIONS)

    assertEquals(count("show"), 1)
end

function M:test_match_complete_clears_the_marks()
    enterArena()
    marks:Set(1, Tank)

    setMatchState(wow.Enum.PvPMatchState.Complete)
    marks:ProcessEvent(events.PVP_MATCH_STATE_CHANGED)

    assertEquals(marks:HasAny(), false)
end

function M:test_entering_the_world_clears_the_marks()
    enterArena()
    marks:Set(1, Tank)

    marks:ProcessEvent(events.PLAYER_ENTERING_WORLD)

    assertEquals(marks:HasAny(), false)
end

function M:test_reloading_mid_round_offers_the_prompt_again()
    addon.DB.Options.EnemyAssignments.PopupEnabled = true
    enterArena()
    setMatchState(wow.Enum.PvPMatchState.Engaged)

    marks:ProcessEvent(events.PLAYER_ENTERING_WORLD)

    assertEquals(count("show"), 1)
end

function M:test_entering_the_world_after_a_match_does_not_offer_the_prompt()
    addon.DB.Options.EnemyAssignments.PopupEnabled = true
    enterArena()
    setMatchState(wow.Enum.PvPMatchState.Complete)

    marks:ProcessEvent(events.PLAYER_ENTERING_WORLD)

    assertEquals(count("show"), 0)
end

function M:test_events_are_ignored_on_a_client_that_reads_specs_itself()
    addon.DB.Options.EnemyAssignments.PopupEnabled = true
    enterArena()
    marks:Set(1, Tank)
    setBuild(120100)
    trace = {}

    marks:ProcessEvent(events.ARENA_PREP_OPPONENT_SPECIALIZATIONS)
    marks:ProcessEvent(events.PLAYER_ENTERING_WORLD)

    assertEquals(trace, {})
    setBuild(120105)
    assertEquals(marks:Role(1), Tank)
end

function M:test_events_are_ignored_on_a_client_without_enemy_specs()
    addon.DB.Options.EnemyAssignments.PopupEnabled = true
    enterArena()
    addon.WoW.Capabilities.HasEnemySpecSupport = function()
        return false
    end

    marks:ProcessEvent(events.ARENA_PREP_OPPONENT_SPECIALIZATIONS)

    assertEquals(trace, {})
end

function M:test_the_prompt_closes_once_every_enemy_has_a_role()
    enterArena()
    marks:Set(1, Tank)
    marks:Set(2, Healer)

    assertEquals(count("hide"), 0)

    marks:Set(3, Dps)

    assertEquals(count("hide"), 1)
end

function M:test_the_prompt_stays_open_when_the_marks_are_cleared_before_it_would_close()
    enterArena()
    local pending = {}
    wow.C_Timer.After = function(_, callback)
        pending[#pending + 1] = callback
    end
    marks:Set(1, Tank)
    marks:Set(2, Healer)
    marks:Set(3, Dps)

    marks:Clear()
    for _, callback in ipairs(pending) do
        callback()
    end

    assertEquals(count("hide"), 0)
end

function M:test_an_earlier_close_timer_does_not_close_the_prompt_after_a_mark_changes()
    enterArena()
    local pending = {}
    wow.C_Timer.After = function(_, callback)
        pending[#pending + 1] = callback
    end
    marks:Set(1, Tank)
    marks:Set(2, Healer)
    marks:Set(3, Dps)
    marks:Set(3, Tank)

    pending[1]()
    assertEquals(count("hide"), 0)

    pending[2]()
    assertEquals(count("hide"), 1)
end

return M
