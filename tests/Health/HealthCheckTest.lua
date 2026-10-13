-- Enemy spacing is applied without Enemy Arena sorting when enemy specs can't be read, so it
-- counts there whatever the sorting toggle says.

local addon
local M = {}

local function spacingResult()
    local _, results = addon.Health.HealthCheck:IsHealthy()

    for _, result in ipairs(results) do
        if result.Description == addon.Locale.Current["Using Secure sorting mode when spacing is being used"] then
            return result
        end
    end
end

function M:setup()
    local addonFactory = require("TestHarness.AddonFactory")
    addon = addonFactory:Create()

    -- the harness locale has no entries, so fall back to the key as the client does
    setmetatable(addon.Locale.Current, {
        __index = function(_, key)
            return key
        end,
    })

    addon.WoW.Api.issecurevariable = function()
        return true
    end

    local options = addon.DB.Options
    options.Sorting.Method = addon.Configuration.SortingMethod.Traditional
    options.Sorting.World.Enabled = false
    options.Sorting.Raid.Enabled = false
    options.Sorting.EnemyArena.Enabled = true
    options.Spacing.EnemyArena.Vertical = 5
end

function M:test_enemy_spacing_fails_the_check_when_specs_are_readable()
    addon.WoW.Api.GetBuildInfo = function()
        return "x", "0", "0", 120100
    end

    assertEquals(spacingResult().Passed, false)
end

function M:test_enemy_spacing_fails_the_check_when_specs_are_unreadable_and_sorting_is_off()
    addon.DB.Options.Sorting.EnemyArena.Enabled = false
    addon.WoW.Api.GetBuildInfo = function()
        return "x", "0", "0", 120105
    end

    assertEquals(spacingResult().Passed, false)
end

function M:test_enemy_spacing_is_ignored_when_specs_are_readable_and_sorting_is_off()
    addon.DB.Options.Sorting.EnemyArena.Enabled = false
    addon.WoW.Api.GetBuildInfo = function()
        return "x", "0", "0", 120100
    end

    assertEquals(spacingResult().Passed, true)
end

return M
