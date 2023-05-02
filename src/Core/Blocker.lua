local _, addon = ...
local eventFrame = nil

local function PauseUpdates()
    CompactRaidFrameContainer:UnregisterEvent("GROUP_ROSTER_UPDATE")
end

local function ResumeUpdates()
    CompactRaidFrameContainer:RegisterEvent("GROUP_ROSTER_UPDATE")
end

local function OnEvent(_, event)
    if not CompactRaidFrameContainer then return end

    if event == "PLAYER_REGEN_ENABLED" then
        ResumeUpdates()
    elseif event == "PLAYER_REGEN_DISABLED" then
        PauseUpdates()
    elseif event == "GROUP_ROSTER_UPDATE" and InCombatLockdown() then
        addon:Debug("Blocked raid frame update during combat.")
    end
end

---Initialises the in-combat raid frame layout blocking module.
function addon:InitCombatBlocking()
    eventFrame = CreateFrame("Frame")
    eventFrame:HookScript("OnEvent", OnEvent)
    eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
    eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
    eventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
end
