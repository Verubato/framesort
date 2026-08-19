---@type Addon
local addon
local wow
local events

local M = {}

-- The dispatcher reads addon.Providers, so replacing the method on the table is enough.
local function CaptureProviderEvents()
    local seen = {}

    addon.Providers.EnabledNotSelfManaged = function()
        return {
            {
                ProcessEvent = function(_, event)
                    seen[#seen + 1] = event
                end,
            },
        }
    end

    return seen
end

function M:setup()
    local addonFactory = require("TestHarness.AddonFactory")

    addon = addonFactory:Create()
    wow = addon.WoW.Api
    events = addon.WoW.Events

    addon.Modules.EventDispatcher:Init()
end

function M:teardown()
    addon.WoW.WowEx.ClearMockInstance()
end

function M:test_arena_opponent_events_skipped_outside_arena()
    local seen = CaptureProviderEvents()

    wow.FireEvent(events.ARENA_OPPONENT_UPDATE, "arena1", "seen")

    assertEquals(#seen, 0)
end

function M:test_arena_opponent_events_reach_providers_in_arena()
    local seen = CaptureProviderEvents()

    addon.WoW.WowEx.MockInstance(true, "arena")
    wow.FireEvent(events.ARENA_OPPONENT_UPDATE, "arena1", "seen")

    assertEquals(#seen, 1)
    assertEquals(seen[1], events.ARENA_OPPONENT_UPDATE)
end

function M:test_other_events_reach_providers_outside_arena()
    local seen = CaptureProviderEvents()

    wow.FireEvent(events.GROUP_ROSTER_UPDATE)

    assertEquals(#seen, 1)
    assertEquals(seen[1], events.GROUP_ROSTER_UPDATE)
end

function M:test_enemy_pet_skipped_outside_arena()
    local seen = CaptureProviderEvents()

    wow.FireEvent(events.UNIT_PET, "nameplate4")

    assertEquals(#seen, 0)
end

function M:test_friendly_pet_reaches_providers_outside_arena()
    local seen = CaptureProviderEvents()

    wow.FireEvent(events.UNIT_PET, "raid9")

    assertEquals(#seen, 1)
    assertEquals(seen[1], events.UNIT_PET)
end

function M:test_enemy_pet_reaches_providers_in_arena()
    local seen = CaptureProviderEvents()

    addon.WoW.WowEx.MockInstance(true, "arena")
    wow.FireEvent(events.UNIT_PET, "arena1")

    assertEquals(#seen, 1)
end

function M:test_pet_with_no_owner_reaches_providers()
    local seen = CaptureProviderEvents()

    -- only so SortedUnits, which runs first in the chain, survives the missing owner
    wow.UnitIsFriend = function()
        return false
    end

    wow.FireEvent(events.UNIT_PET)

    assertEquals(#seen, 1)
end

function M:test_mind_controlled_raid_member_pet_still_reaches_providers()
    local seen = CaptureProviderEvents()

    -- hostile while controlled, but still sitting on a raid frame blizzard will re-lay-out
    wow.UnitIsFriend = function()
        return false
    end

    wow.FireEvent(events.UNIT_PET, "raid9")

    assertEquals(#seen, 1)
end

function M:test_pet_owner_prefixes_match_blizzards_rule()
    local seen = CaptureProviderEvents()

    -- blizzard prefix matches, so these all reach their container and must reach ours
    for _, owner in ipairs({ "player", "raid9", "raid40", "raidpet3", "party2", "partypet1" }) do
        wow.FireEvent(events.UNIT_PET, owner)
    end

    assertEquals(#seen, 6)
end

return M
