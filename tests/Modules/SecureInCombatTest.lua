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

return M
