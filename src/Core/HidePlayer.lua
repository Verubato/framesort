local _, addon = ...
local fsSort = addon.Sorting
local fsFrame = addon.Frame
local fsCompare = addon.Compare
local M = {}
addon.HidePlayer = M

local function CanUpdate(frame)
    if not frame then
        return
    end
    if frame:IsForbidden() then
        return
    end
    if not IsInGroup() then
        return false
    end
    if InCombatLockdown() then
        return false
    end
    if not frame.unit or not frame.unitExists then
        return
    end
    if not UnitIsUnit("player", frame.unit) then
        return
    end
    if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
        if EditModeManagerFrame.editModeActive then
            return false
        end
    end

    return true
end

local function UpdateVisible(frame)
    if not CanUpdate(frame) then
        return
    end

    local enabled, mode, _, _ = fsCompare:GetSortMode()

    if not enabled then
        return
    end

    frame:SetShown(mode ~= addon.PlayerSortMode.Hidden)
end

local function Run()
    local player = fsFrame:GetPlayerFrame()
    if not player then
        return
    end

    UpdateVisible(player)
end

---Shows or hides the player (depending on settings).
function M:ShowHidePlayer()
    Run()
end

---Initialises the player show/hide module.
function addon:InitPlayerHiding()
    local eventFrame = CreateFrame("Frame")
    eventFrame:HookScript("OnEvent", Run)
    eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    eventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
    eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
    hooksecurefunc("CompactUnitFrame_UpdateVisible", UpdateVisible)
    fsSort:RegisterPostSortCallback(Run)
end
