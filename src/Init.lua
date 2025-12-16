---@type string, Addon
local addonName, addon = ...
local wow = addon.WoW.Api
local fsLog = addon.Logging.Log

function addon:InitLocale()
    local function DefaultIndex(_, key)
        -- if there is no translation specified, then use the the key itself
        local locale = wow.GetLocale()

        if locale ~= "enUS" then
            fsLog:WarnOnce("Missing translation for key '%s' and locale '%s'", key, locale)
        end

        return key
    end

    setmetatable(addon.Locale, { __index = DefaultIndex })
end

function addon:InitDB()
    fsLog:Debug("Loading saved variables.")

    FrameSortDB = FrameSortDB or wow.CopyTable(addon.Configuration.DbDefaults)
    FrameSortDB.Options = FrameSortDB.Options or wow.CopyTable(addon.Configuration.DbDefaults)

    local success = addon.Configuration.Upgrader:UpgradeDb(FrameSortDB)

    if not success then
        fsLog:Critical("Saved variables are corrupt, resetting to default settings.")

        FrameSortDB = wow.CopyTable(addon.Configuration.DbDefaults)
    end

    addon.DB = FrameSortDB
end

---Initialises the addon.
function addon:Init()
    fsLog:Init()
    fsLog:Debug("Initialising.")
    addon:InitLocale()
    addon:InitDB()
    addon.Configuration.Specs:Init()
    addon.Configuration:Init()
    addon.Providers:Init()
    addon.Modules:Init()
    addon.Api:Init()
    addon.Scheduling.Scheduler:Init()

    addon.Loaded = true
    fsLog:Debug("Initialisation finished.")
end

---Listens for our to be loaded and then initialises it.
---@param name string the name of the addon being loaded.
local function OnLoadAddon(_, _, name)
    if name ~= addonName then
        return
    end

    addon:Init()
    addon.Loader:UnregisterEvent("ADDON_LOADED")
end

addon.Loader = wow.CreateFrame("Frame")
addon.Loader:HookScript("OnEvent", OnLoadAddon)
addon.Loader:RegisterEvent("ADDON_LOADED")

FrameSort = addon
