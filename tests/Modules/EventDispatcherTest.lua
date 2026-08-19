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

return M
