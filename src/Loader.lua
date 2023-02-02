local addonName, addon = ...

-- listens for addon onload events
function addon:OnLoadAddon(_, addOnName)
    if addOnName ~= addonName then return end

    -- load our saved variables or init them if this is the first run
    Options = Options or CopyTable(addon.Defaults)
    addon.Options = Options
    addon:InitOptions()
    addon:HookEvents()
end

function addon:HookEvents()
    addon.EventLoop = CreateFrame("Frame")
    addon.EventLoop:HookScript("OnEvent", addon.OnEvent)
    -- Fired whenever a group or raid is formed or disbanded, players are leaving or joining the group or raid.
    addon.EventLoop:RegisterEvent("GROUP_ROSTER_UPDATE")
    -- Fired after ending combat, as regen rates return to normal.
    -- Useful for determining when a player has left combat.
    -- This occurs when you are not on the hate list of any NPC, or a few seconds after the latest pvp attack that you were involved with.
    addon.EventLoop:RegisterEvent("PLAYER_REGEN_ENABLED")
    -- Fires when the player logs in, /reloads the UI or zones between map instances.
    -- Basically whenever the loading screen appears.
    addon.EventLoop:RegisterEvent("PLAYER_ENTERING_WORLD")
end

addon.Loader = CreateFrame("Frame")
addon.Loader:HookScript("OnEvent", addon.OnLoadAddon)
addon.Loader:RegisterEvent("ADDON_LOADED")
