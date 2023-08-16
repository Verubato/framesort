local addonName, addon = ...
local wow = addon.WoW
local loader = nil

local function InitSavedVars()
    if not FrameSortDB then
        FrameSortDB = {}
    end
    if not FrameSortDB.Options then
        FrameSortDB.Options = wow.CopyTable(addon.Defaults)
    end

    addon.Options = FrameSortDB.Options
    addon:UpgradeOptions(addon.Options)
end

---Initialises the addon.
local function Init()
    InitSavedVars()
    addon:InitOptions()
    addon:InitFrameProviders()
    addon:InitSorting()
    addon:InitPlayerHiding()
    addon:InitSpacing()
    addon:InitTargeting()
    addon:InitMacros()
    addon:InitApi()
    addon:InitScheduler()
end

---Listens for our to be loaded and then initialises it.
---@param name string the name of the addon being loaded.
local function OnLoadAddon(_, _, name)
    if name ~= addonName then
        return
    end

    Init()
    loader:UnregisterEvent("ADDON_LOADED")
end

loader = wow.CreateFrame("Frame")
loader:HookScript("OnEvent", OnLoadAddon)
loader:RegisterEvent("ADDON_LOADED")
