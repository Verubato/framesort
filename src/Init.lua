---@type string, Addon
local addonName, addon = ...
local wow = addon.WoW.Api
local loader = nil

function addon:InitDB()
    if not FrameSortDB then
        FrameSortDB = {}
    end
    if not FrameSortDB.Options then
        FrameSortDB.Options = wow.CopyTable(addon.Configuration.Defaults)
    end
    if FrameSortDB.Log then
        FrameSortDB.Log = nil
    end

    addon.DB = FrameSortDB
    addon.Configuration.Upgrader:UpgradeOptions(addon.DB.Options)
end

---Initialises the addon.
function addon:Init()
    addon:InitDB()
    addon.Configuration:Init()
    addon.Providers:Init()
    addon.Modules:Init()
    addon.Api:Init()
    addon.Scheduling.Scheduler:Init()

    addon.Loaded = true
end

---Listens for our to be loaded and then initialises it.
---@param name string the name of the addon being loaded.
local function OnLoadAddon(_, _, name)
    if name ~= addonName then
        return
    end

    addon:Init()

    assert(loader ~= nil)
    loader:UnregisterEvent("ADDON_LOADED")
end

loader = wow.CreateFrame("Frame")
loader:HookScript("OnEvent", OnLoadAddon)
loader:RegisterEvent("ADDON_LOADED")
