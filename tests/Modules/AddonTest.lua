local M = {}

function M:test_addon_starts_successfully()
    local addonFactory = require("TestHarness\\AddonFactory")
    local addon = addonFactory:Create()

    assertEquals(addon.Loaded, nil)
    addon:Init()
    assertEquals(addon.Loaded, true)
end

return M
