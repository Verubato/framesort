local addonName, addon = ...
local loader = CreateFrame("Frame")

---Listens for events where we should refresh the frames.
---@param eventName string
local function OnEvent(_, eventName)
    -- only attempt to run after combat ends if one is pending
    if eventName == "PLAYER_REGEN_ENABLED" and not addon.SortPending then return end

    addon:Apply()
end

---Event hook on blizzard performing frame layouts.
local function OnLayout(container)
    if not container or container:IsForbidden() or not container:IsVisible() then return end
    if container ~= CompactRaidFrameContainer and container ~= CompactPartyFrame then return end
    if container.flowPauseUpdates then return end

    if addon.Options.SortingMethod.TaintlessEnabled then
        addon:Apply()
    else
        -- prevent stack overflow in traditional mode
        -- where calling TrySort() ends up calling OnLayout which calls TrySort()
        addon:ApplySpacing()
    end
end

---Initialises the addon.
local function Init()
    -- load our saved variables or init them if this is the first run
    Options = Options or CopyTable(addon.Defaults)
    addon.Options = Options
    addon:InitOptions()
    addon:InitTargeting()

    addon.EventLoop = CreateFrame("Frame")
    addon.EventLoop:HookScript("OnEvent", OnEvent)
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

    hooksecurefunc("FlowContainer_DoLayout", OnLayout)
end

---Listens for our to be loaded and then initialises it.
---@param name string the name of the addon being loaded.
local function OnLoadAddon(_, _, name)
    if name ~= addonName then return end

    Init()
    loader:UnregisterEvent("ADDON_LOADED")
end

---Applies sorting and spacing.
function addon:Apply()
    addon.SortPending = not addon:TrySort()
    addon:ApplySpacing()
    addon:UpdateTargets()
end

loader:HookScript("OnEvent", OnLoadAddon)
loader:RegisterEvent("ADDON_LOADED")
