local wowFactory = require("Mock\\WowFactory")
local addonName = "Test"
local moduleCache = {}

local function DependenciesFromXml()
    local xmlFilePath = "..\\src\\Load.xml"
    local dependencies = {}

    for line in io.lines(xmlFilePath) do
        local file = string.match(line, [[file="(.*)"]])

        if file and file ~= "WoW\\WoW.lua" and file ~= "Namespace.lua" and not string.match(file, "Libs\\.*") then
            dependencies[#dependencies + 1] = file
        end
    end

    return dependencies
end

local function LoadDependencies(addonTable, dependencies)
    for _, fileName in ipairs(dependencies) do
        local path = "..\\src\\" .. fileName
        local module = moduleCache[path] or loadfile(path)

        moduleCache[path] = module

        assert(module ~= nil, "Failed to load " .. fileName)

        module(addonName, addonTable)
    end
end

---@class AddonFactory : IFactory<Addon>
local factory = {}

function factory:Create()
    local addon = {
        Api = {},
        Collections = {},
        Configuration = {
            Panels = {},
        },
        Health = {},
        Logging = {},
        Modules = {
            Sorting = {
                Secure = {},
            },
            Macro = {},
        },
        Numerics = {},
        Providers = {
            All = {},
        },
        Scheduling = {},
        Utils = {},
        WoW = {
            Api = wowFactory:Create(),
        },
        DB = {},
        Locale = {}
    }

    local dependencies = DependenciesFromXml()
    LoadDependencies(addon, dependencies)

    addon.DB.Options = addon.WoW.Api.CopyTable(addon.Configuration.Defaults)

    return addon
end

return factory
