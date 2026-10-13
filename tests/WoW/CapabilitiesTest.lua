-- 12.1.5 makes GetArenaOpponentSpec return secret values, so the options panel stops offering
-- enemy spec sorting from that build onwards.

---@type ClientCapabilities
local capabilities
local addon
local M = {}

local function setBuild(build)
    addon.WoW.Api.GetBuildInfo = function()
        return "x", "0", "0", build
    end
end

function M:setup()
    local addonFactory = require("TestHarness.AddonFactory")
    addon = addonFactory:Create()
    capabilities = addon.WoW.Capabilities
end

function M:test_enemy_specs_readable_on_12_1_0()
    setBuild(120100)

    assertEquals(capabilities.CanReadEnemySpecs(), true)
end

function M:test_enemy_specs_unreadable_on_12_1_5()
    setBuild(120105)

    assertEquals(capabilities.CanReadEnemySpecs(), false)
end

function M:test_enemy_specs_unreadable_on_later_builds()
    setBuild(120200)

    assertEquals(capabilities.CanReadEnemySpecs(), false)
end

function M:test_enemy_specs_readable_on_classic()
    setBuild(50504)

    assertEquals(capabilities.CanReadEnemySpecs(), true)
end

function M:test_manual_enemy_roles_needed_on_12_1_5()
    setBuild(120105)
    capabilities.HasEnemySpecSupport = function()
        return true
    end

    assertEquals(capabilities.NeedsManualEnemyRoles(), true)
end

function M:test_manual_enemy_roles_not_needed_on_12_1_0()
    setBuild(120100)
    capabilities.HasEnemySpecSupport = function()
        return true
    end

    assertEquals(capabilities.NeedsManualEnemyRoles(), false)
end

function M:test_manual_enemy_roles_not_needed_without_enemy_spec_support()
    setBuild(120105)
    capabilities.HasEnemySpecSupport = function()
        return false
    end

    assertEquals(capabilities.NeedsManualEnemyRoles(), false)
end

return M
