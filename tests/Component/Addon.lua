local M = {}
local helper = require("Helper")
local wowMock = require("Mock\\WoW")

function M:test_addon_starts_successfully()
    -- addon table
    local addon = { WoW = wowMock }

    -- load all modules
    local dependencies = helper:DependenciesFromXml()
    helper:LoadDependencies(addon, dependencies)

    assertEquals(#addon.WoW.Frames, 1)

    local initFrame = addon.WoW.Frames[1]
    initFrame:FireEvent(nil, nil, helper.AddonName)

    assertEquals(true, addon.Loaded)
end

return M
