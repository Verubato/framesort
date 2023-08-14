local _, addon = ...
local fsFrame = addon.Frame
local blizzard = fsFrame.Providers.Blizzard
local fsCompare = addon.Compare
local fsLog = addon.Log
local M = {}
addon.HidePlayer = M

local function CanUpdate()
    if not blizzard:Enabled() then
        return false
    end

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

local function UpdatePlayer(player, mode)
    if player:IsVisible() and mode == addon.PlayerSortMode.Hidden then
        player:Hide()
    elseif not player:IsVisible() and mode ~= addon.PlayerSortMode.Hidden then
        player:Show()
    end
end

local function Run(maybePlayer)
    if not CanUpdate() then
        return
    end

    local enabled, mode, _, _ = fsCompare:FriendlySortMode()
    if not enabled then
        return
    end

    if maybePlayer then
        local unit = blizzard:GetUnit(maybePlayer)
        if not unit or not UnitIsUnit("player", unit) then
            return
        end

        UpdatePlayer(maybePlayer, mode)
        return
    end

    local frames = blizzard:PlayerRaidFrames()

    if #frames == 0 and IsInGroup() then
        fsLog:Warning("Couldn't find player raid frame.")
        return
    end

    for _, player in ipairs(frames) do
        UpdatePlayer(player, mode)
    end
end

local function OnUpdateVisible(frame)
    if frame then
        Run(frame)
    end
end

---Shows or hides the player (depending on settings).
function M:ShowHidePlayer()
    Run()
end

---Initialises the player show/hide module.
function addon:InitPlayerHiding()
    hooksecurefunc("CompactUnitFrame_UpdateVisible", OnUpdateVisible)
    blizzard:RegisterCallback(Run)
end
