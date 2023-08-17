local addon = require("Addon")
local M = {}

function M:setup()
    addon:Reset()
end

function M:teardown()
    addon:Reset()
end

function M:test_addon_starts_successfully()
    assertEquals(addon.Loaded, nil)
    addon:Init()
    assertEquals(addon.Loaded, true)
end

return M
