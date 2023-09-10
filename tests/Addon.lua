local helper = require("Helper")
local wow = require("Mock\\WoW")
local provider = require("Mock\\FrameProvider")
---@class AddonMock: Addon
local addon = {
    Api = {},
    Collections = {},
    Configuration = {},
    Health = {},
    Logging = {},
    Modules = {
        Sorting = {}
    },
    Numerics = {},
    Providers = {
        All = {},
    },
    Scheduling = {},
    Utils = {},
    WoW = {
        Api = wow
    },
}

local dependencies = helper:DependenciesFromXml()
helper:LoadDependencies(addon, dependencies)

addon.Providers.Test = provider
addon.Providers.All[#addon.Providers.All + 1] = provider

function addon:Reset()
    addon.WoW.Api:Reset()
    provider:Reset()
end

return addon
