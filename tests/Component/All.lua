local addon = require("Addon")
local helper = require("Helper")
local M = {}

function M:teardown()
    addon:Reset()
end

function M:test_addon_starts_successfully()
    assertEquals(addon.Loaded, nil)
    addon.WoW:FireEvent("ADDON_LOADED", nil, nil, helper.AddonName)
    assertEquals(addon.Loaded, true)
end

return M
