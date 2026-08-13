-- The spec wrappers in WowEx normalise whatever the client hands back into "a usable spec id or
-- nil". Since Midnight that includes a SECRET value: the client keeps the spec of a unit it will
-- not let an addon identify, a mouseover of a stranger being the everyday way to get one.
-- Comparing a secret errors, so a caller can neither tell it apart from a real id nor cache it,
-- and the wrappers are the one place that can drop it.

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

function M:test_inspect_spec_drops_a_secret()
    addon.WoW.Api.GetInspectSpecialization = function()
        return SECRET
    end

    assertEquals(wowEx.GetInspectSpecializationSafe("mouseover"), nil)
end

function M:test_inspect_spec_keeps_a_real_id()
    addon.WoW.Api.GetInspectSpecialization = function()
        return 256
    end

    assertEquals(wowEx.GetInspectSpecializationSafe("party1"), 256)
end

function M:test_inspect_spec_still_drops_zero()
    addon.WoW.Api.GetInspectSpecialization = function()
        return 0
    end

    assertEquals(wowEx.GetInspectSpecializationSafe("party1"), nil)
end

function M:test_arena_spec_drops_a_secret()
    addon.WoW.Api.GetArenaOpponentSpec = function()
        return SECRET
    end

    assertEquals(wowEx.GetArenaOpponentSpecSafe(1), nil)
end

function M:test_arena_spec_keeps_a_real_id()
    addon.WoW.Api.GetArenaOpponentSpec = function()
        return 105
    end

    assertEquals(wowEx.GetArenaOpponentSpecSafe(1), 105)
end

return M
