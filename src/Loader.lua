local addonName, addon = ...

---Listens for our to be loaded and then initialises it.
---@param name string the name of the addon being loaded.
function addon:OnLoadAddon(name)
    if name ~= addonName then return end

    addon:Init()
    addon.Loader:UnregisterEvent("ADDON_LOADED")
end

---Initialises the addon.
function addon:Init()
    -- load our saved variables or init them if this is the first run
    Options = Options or CopyTable(addon.Defaults)
    addon.Options = Options
    addon:InitOptions()
    addon:InitTargeting()

    addon.EventLoop = CreateFrame("Frame")
    addon.EventLoop:HookScript("OnEvent", function(_, name) addon:OnEvent(name) end)
    -- Fired after ending combat, as regen rates return to normal.
    -- Useful for determining when a player has left combat.
    -- This occurs when you are not on the hate list of any NPC, or a few seconds after the latest pvp attack that you were involved with.
    -- It seems Blizzard do an update layout after combat ends, so even for the experimental mode we also need to re-sort.
    addon.EventLoop:RegisterEvent("PLAYER_REGEN_ENABLED")

    -- Fires when the player logs in, /reloads the UI or zones between map instances.
    -- Basically whenever the loading screen appears.
    addon.EventLoop:RegisterEvent("PLAYER_ENTERING_WORLD")

    -- Fired whenever a group or raid is formed or disbanded, players are leaving or joining the group or raid.
    addon.EventLoop:RegisterEvent("GROUP_ROSTER_UPDATE")

    hooksecurefunc("FlowContainer_DoLayout", function(container) addon:OnLayout(container) end)
end

addon.Loader = CreateFrame("Frame")
addon.Loader:HookScript("OnEvent", function(_, _, name) addon:OnLoadAddon(name) end)
addon.Loader:RegisterEvent("ADDON_LOADED")
