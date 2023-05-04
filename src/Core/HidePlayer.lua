local _, addon = ...
local eventFrame = nil

local function UpdateVisible(frame)
    if frame:IsForbidden() then return end
    if not IsInGroup() then return false end
    if InCombatLockdown() then return false end
    if not frame.unit or not frame.unitExists then return end
    if not UnitIsUnit("player", frame.unit) then return end
    if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
        if EditModeManagerFrame.editModeActive then
            return false
        end
    end

    local enabled, mode, _, _ = addon:GetSortMode()

    if not enabled then return end

    frame:SetShown(mode ~= addon.PlayerSortMode.Hidden)
end

local function OnSorted()
    local player = addon:GetPlayerFrame()
    UpdateVisible(player)
end

local function OnEvent()
    local player = addon:GetPlayerFrame()
    UpdateVisible(player)
end

---Initialises the player show/hide module.
function addon:InitPlayerHiding()
    eventFrame = CreateFrame("Frame")
    eventFrame:HookScript("OnEvent", OnEvent)
    eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    eventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
    hooksecurefunc("CompactUnitFrame_UpdateVisible", UpdateVisible)
    addon:RegisterPostSortCallback(OnSorted)
end
