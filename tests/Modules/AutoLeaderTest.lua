---@diagnostic disable: duplicate-set-field, cast-local-type
---@type Addon
local addon
---@type AutoLeaderModule
local fsAutoLeader
local M = {}

function M:setup()
    local addonFactory = require("TestHarness\\AddonFactory")
    addon = addonFactory:Create()

    fsAutoLeader = addon.Modules.AutoLeader

    addon.DB.Options.AutoLeader.Enabled = true

    addon.WoW.Api.Enum = addon.WoW.Api.Enum or {}
    addon.WoW.Api.Enum.PvPMatchState = addon.WoW.Api.Enum.PvPMatchState or {
        StartUp = 1,
        PostRound = 2,
        Complete = 3,
    }

    addon.WoW.Api.C_PvP = addon.WoW.Api.C_PvP or {}
    addon.WoW.Api.C_PvP.GetActiveMatchState = function()
        -- pretend we are in solo shuffle waiting room by default
        return addon.WoW.Api.Enum.PvPMatchState.StartUp
    end

    addon.WoW.Capabilities.HasSoloShuffle = function()
        return true
    end

    -- Unit plumbing
    addon.WoW.Unit.FriendlyUnits = function()
        return { "player", "party1", "party2" }
    end

    -- roles: player=dps, party1=healer, party2=dps by default
    addon.WoW.Api.UnitGroupRolesAssigned = function(unit)
        if unit == "party1" then
            return "HEALER"
        end
        return "DAMAGER"
    end

    addon.WoW.Api.UnitIsUnit = function(a, b)
        return a == b
    end

    -- leadership defaults
    addon.WoW.Api.UnitIsGroupLeader = function(unit)
        return unit == "player"
    end

    -- promote spy
    self.promoted = nil
    addon.WoW.Api.PromoteToLeader = function(unit)
        self.promoted = unit
    end

    -- ensure healerHadLeader flag is reset between tests
    addon.WoW.Api.C_PvP.GetActiveMatchState = function()
        return addon.WoW.Api.Enum.PvPMatchState.Complete
    end

    fsAutoLeader:ProcessEvent(addon.WoW.Events.PVP_MATCH_STATE_CHANGED)

    addon.WoW.Api.C_PvP.GetActiveMatchState = function()
        return addon.WoW.Api.Enum.PvPMatchState.StartUp
    end
end

function M:teardown()
    addon = nil
    fsAutoLeader = nil
end

function M:test_disabled_does_nothing()
    addon.DB.Options.AutoLeader.Enabled = false

    fsAutoLeader:Run()

    assertEquals(self.promoted, nil)
end

function M:test_not_startup_state_does_not_run()
    addon.WoW.Api.C_PvP.GetActiveMatchState = function()
        return addon.WoW.Api.Enum.PvPMatchState.PostRound
    end

    fsAutoLeader:Run()

    assertEquals(self.promoted, nil)
end

function M:test_no_healer_found_does_nothing()
    addon.WoW.Api.UnitGroupRolesAssigned = function(_)
        return "DAMAGER"
    end

    fsAutoLeader:Run()

    assertEquals(self.promoted, nil)
end

function M:test_if_player_not_leader_does_nothing()
    addon.WoW.Api.UnitIsGroupLeader = function(unit)
        -- nobody is leader (or player isn't)
        return unit == "party2"
    end

    fsAutoLeader:Run()

    assertEquals(self.promoted, nil)
end

function M:test_if_player_is_healer_does_nothing()
    addon.WoW.Api.UnitGroupRolesAssigned = function(unit)
        if unit == "player" then
            return "HEALER"
        end
        return "DAMAGER"
    end

    fsAutoLeader:Run()

    assertEquals(self.promoted, nil)
end

function M:test_promotes_healer_when_player_is_leader_and_not_healer()
    -- player leader, healer is party1
    fsAutoLeader:Run()

    assertEquals(self.promoted, "party1")
end

function M:test_if_healer_already_leader_it_sets_flag_and_never_promotes_again()
    -- make healer already leader
    addon.WoW.Api.UnitIsGroupLeader = function(unit)
        return unit == "party1"
    end

    -- first run: should not promote, but should set internal healerHadLeader flag
    fsAutoLeader:Run()
    assertEquals(self.promoted, nil)

    -- now pretend player becomes leader again; module should not re-promote due to flag
    addon.WoW.Api.UnitIsGroupLeader = function(unit)
        return unit == "player"
    end

    fsAutoLeader:Run()
    assertEquals(self.promoted, nil)
end

function M:test_state_change_postround_resets_flag_allows_promote_again()
    -- Step 1: set flag by having healer be leader once
    addon.WoW.Api.UnitIsGroupLeader = function(unit)
        return unit == "party1"
    end
    fsAutoLeader:Run()
    assertEquals(self.promoted, nil)

    -- Step 2: state change resets flag
    addon.WoW.Api.C_PvP.GetActiveMatchState = function()
        return addon.WoW.Api.Enum.PvPMatchState.PostRound
    end
    fsAutoLeader:ProcessEvent(addon.WoW.Events.PVP_MATCH_STATE_CHANGED)

    -- Step 3: now player is leader and should promote again
    addon.WoW.Api.C_PvP.GetActiveMatchState = function()
        return addon.WoW.Api.Enum.PvPMatchState.StartUp
    end
    addon.WoW.Api.UnitIsGroupLeader = function(unit)
        return unit == "player"
    end

    fsAutoLeader:Run()

    assertEquals(self.promoted, "party1")
end

function M:test_process_event_ignores_other_events()
    -- set to a non-startup state so Run would normally do nothing anyway
    addon.WoW.Api.C_PvP.GetActiveMatchState = function()
        return addon.WoW.Api.Enum.PvPMatchState.StartUp
    end

    -- this should not reset anything or crash
    fsAutoLeader:ProcessEvent("SOME_OTHER_EVENT")

    fsAutoLeader:Run()
    assertEquals(self.promoted, "party1")
end

return M
