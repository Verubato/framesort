---@type string, Addon
local addonName, addon = ...
---@type WoW
local wow = addon.WoW
local loader = nil

function addon:InitSavedVars()
    if not FrameSortDB then
        FrameSortDB = {}
    end
    if not FrameSortDB.Options then
        FrameSortDB.Options = wow.CopyTable(addon.Defaults)
    end

    addon.Options = FrameSortDB.Options
    addon.OptionsUpgrader:UpgradeOptions(addon.Options)
end

---Initialises the addon.
function addon:Init()
    addon:InitSavedVars()
    addon:InitOptions()
    addon:InitFrameProviders()
    addon:InitSorting()
    addon:InitPlayerHiding()
    addon:InitSpacing()
    addon:InitTargeting()
    addon:InitMacros()
    addon:InitApi()
    addon:InitScheduler()

    addon.Loaded = true
end

---Listens for our to be loaded and then initialises it.
---@param name string the name of the addon being loaded.
local function OnLoadAddon(_, _, name)
    if name ~= addonName then
        return
    end

    if addon.Loaded then
        return
    end

    addon:Init()
    loader:UnregisterEvent("ADDON_LOADED")
end

loader = wow.CreateFrame("Frame")
loader:HookScript("OnEvent", OnLoadAddon)
loader:RegisterEvent("ADDON_LOADED")
