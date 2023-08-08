local _, addon = ...
local fsLog = addon.Log
local fsSort = addon.Sorting
local fsFrame = addon.Frame
local fsCompare = addon.Compare
local M = {}
addon.HidePlayer = M

local function CanUpdate()
    if InCombatLockdown() then
        return false
    end

    if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
        if EditModeManagerFrame.editModeActive then
            return false
        end
    end

    return true
end

local function Run()
    if not CanUpdate() then
        return
    end

    local player = fsFrame:PlayerRaidFrame()

    if not player or player:IsForbidden() then
        fsLog:Warning("Couldn't find player raid frame.")
        return
    end

    local enabled, mode, _, _ = fsCompare:FriendlySortMode()

    if not enabled then
        return
    end

    player:SetShown(mode ~= addon.PlayerSortMode.Hidden)
end

---Shows or hides the player (depending on settings).
function M:ShowHidePlayer()
    Run()
end

---Initialises the player show/hide module.
function addon:InitPlayerHiding()
    local eventFrame = CreateFrame("Frame")
    eventFrame:HookScript("OnEvent", Run)
    eventFrame:RegisterEvent(addon.Events.PLAYER_ENTERING_WORLD)
    eventFrame:RegisterEvent(addon.Events.GROUP_ROSTER_UPDATE)
    eventFrame:RegisterEvent(addon.Events.PLAYER_REGEN_ENABLED)
    fsSort:RegisterPostSortCallback(Run)
end
