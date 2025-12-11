---@type string, Addon
local addonName, addon = ...
local wow = addon.WoW.Api
local fsLog = addon.Logging.Log
local loader = nil

function addon:InitLocale()
    local function DefaultIndex(_, key)
        -- if there is no translation specified, then use the the key itself
        local locale = wow.GetLocale()
        if locale ~= "enUS" then
            fsLog:Warning("Missing translation for key '%s' and locale '%s'", key, locale)
        end

        return key
    end

    setmetatable(addon.Locale, { __index = DefaultIndex })
end

function addon:InitDB()
    fsLog:Debug("Loading saved variables.")
    FrameSortDB = FrameSortDB or {}
    FrameSortDB.Options = FrameSortDB.Options or wow.CopyTable(addon.Configuration.Defaults)

    addon.DB = FrameSortDB
    addon.Configuration.Upgrader:UpgradeOptions(addon.DB.Options)
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

    assert(loader)

    addon:Init()
    loader:UnregisterEvent("ADDON_LOADED")
end

loader = wow.CreateFrame("Frame")
loader:HookScript("OnEvent", OnLoadAddon)
loader:RegisterEvent("ADDON_LOADED")

FrameSort = addon
