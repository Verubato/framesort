local wowFactory = require("TestHarness.WoWFactory")
local addonName = "Test"
local moduleCache = {}

-- Test.lua publishes the addon root, so the suite runs from the repository root (which is what
-- CI does) as well as from inside tests. Forward slashes throughout: Windows accepts them and
-- Linux requires them.
local srcDir = (FS_ADDON_ROOT or "..") .. "/src"

local function DependenciesFromXml()
    local dependencies = {}

    for line in io.lines(srcDir .. "/Load.xml") do
        local file = string.match(line, [[file="(.*)"]])

        -- The xml spells its paths with backslashes; normalise before comparing or loading.
        file = file and file:gsub("\\", "/")

        if file and file ~= "WoW/WoW.lua" and file ~= "Namespace.lua" and not string.match(file, "Libs/.*") then
            dependencies[#dependencies + 1] = file
        end
    end

    return dependencies
end

local function LoadDependencies(addonTable, dependencies)
    for _, fileName in ipairs(dependencies) do
        local path = srcDir .. "/" .. fileName
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
        -- Mirrors src/Namespace.lua, which DependenciesFromXml deliberately skips - loading it
        -- would reset addon.WoW and throw away the mock api built above. A locale added there
        -- has to be added here too, or every test dies as that locale file loads, with
        -- "attempt to index local 'L' (a nil value)".
        Locale = {
            Current = {},
            enUS = {},
            deDE = {},
            esES = {},
            esMX = {},
            frFR = {},
            itIT = {},
            koKR = {},
            ptBR = {},
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
