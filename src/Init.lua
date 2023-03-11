local addonName, addon = ...
local loader = nil

---Initialises the addon.
local function Init()
    addon:InitOptions()
    addon:InitSorting()
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
