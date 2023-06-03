local addonName, addon = ...
local loader = nil

local function InitSavedVars()
    if not FrameSortDB then FrameSortDB = {} end
    if not FrameSortDB.Options then
        FrameSortDB.Options = CopyTable(addon.Defaults)
    end

    addon.Options = FrameSortDB.Options
    addon:UpgradeOptions(addon.Options)
end

---Initialises the addon.
local function Init()
    InitSavedVars()
    addon:InitLogging()
    addon:InitOptions()
    addon:InitSorting()
    addon:InitPlayerHiding()
    addon:InitSpacing()
    addon:InitTargeting()
    addon:InitMacros()
end

---Listens for our to be loaded and then initialises it.
---@param name string the name of the addon being loaded.
local function OnLoadAddon(_, _, name)
    if name ~= addonName then return end

    Init()
    loader:UnregisterEvent("ADDON_LOADED")
end

loader = CreateFrame("Frame")
loader:HookScript("OnEvent", OnLoadAddon)
loader:RegisterEvent("ADDON_LOADED")
