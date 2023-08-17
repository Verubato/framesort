local M = {}
local helper = require("Helper")
local wow = require("Mock\\WoW")
local addon = { WoW = wow }
local dependencies = helper:DependenciesFromXml()
helper:LoadDependencies(addon, dependencies)

function M:teardown()
    wow:Reset()
end

function M:test_addon_starts_successfully()
    assertEquals(addon.Loaded, nil)
    helper:LoadDependencies(addon, dependencies)
    addon.WoW:FireEvent("ADDON_LOADED", nil, nil, helper.AddonName)
    assertEquals(addon.Loaded, true)
end

return M
