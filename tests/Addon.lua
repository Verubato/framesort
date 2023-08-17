local helper = require("Helper")
local wow = require("Mock\\WoW")
local provider = require("Mock\\FrameProvider")
local addon = { WoW = wow }

local dependencies = helper:DependenciesFromXml()
helper:LoadDependencies(addon, dependencies)

addon.Frame.Providers.Test = provider
addon.Frame.Providers.All[#addon.Frame.Providers.All + 1] = provider

function addon:Reset()
    wow:Reset()
    provider:Reset()
end

return addon
