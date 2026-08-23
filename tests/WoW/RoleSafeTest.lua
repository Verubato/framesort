-- UnitGroupRolesAssignedSafe normalises whatever the client hands back into "a role string or
-- nil". Since Midnight that includes a SECRET value: once an addon has tainted execution the
-- client hides the role, and comparing a secret errors. Every caller compares the role against
-- something, so the wrapper is the one place that can drop it.

---@type WowEx
local wowEx
local addon
local M = {}

-- What the mocked client treats as secret; see TestHarness/WoWFactory.
local SECRET = "SECRET"

function M:setup()
    local addonFactory = require("TestHarness.AddonFactory")
    addon = addonFactory:Create()
    wowEx = addon.WoW.WowEx
end

function M:test_role_drops_a_secret()
    addon.WoW.Api.UnitGroupRolesAssigned = function()
        return SECRET
    end

    assertEquals(wowEx.UnitGroupRolesAssignedSafe("raid3target"), nil)
end

function M:test_role_keeps_a_real_role()
    addon.WoW.Api.UnitGroupRolesAssigned = function()
        return wowEx.Role.Dps
    end

    assertEquals(wowEx.UnitGroupRolesAssignedSafe("party1"), wowEx.Role.Dps)
end

function M:test_role_drops_a_missing_api()
    addon.WoW.Api.UnitGroupRolesAssigned = nil

    assertEquals(wowEx.UnitGroupRolesAssignedSafe("party1"), nil)
end

return M
