local wowFactory = require("TestHarness\\WowFactory")
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

---@class AddonFactory
local factory = {}

---@return Addon
function factory:Create()
    local addon = {
        Api = {},
        Collections = {},
        Language = {},
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
        Locale = {
            Current = {},
            enUS = {},
            deDE = {},
            esES = {},
            esMX = {},
            frFR = {},
            koKR = {},
            ruRU = {},
            zhCN = {},
            zhTW = {},
        },
    }

    local dependencies = DependenciesFromXml()
    LoadDependencies(addon, dependencies)

    addon.DB = addon.WoW.Api.CopyTable(addon.Configuration.DbDefaults)

    -- silence logging
    addon.Logging.Log.Log = function() end
    addon.Logging.Log.Debug = function() end
    addon.Logging.Log.Notify = function() end
    addon.Logging.Log.Warning = function() end
    addon.Logging.Log.Error = function() end
    addon.Logging.Log.Critical = function() end
    addon.Logging.Log.WarnOnce = function() end
    addon.Logging.Log.ErrorOnce = function() end

    return addon
end

return factory
