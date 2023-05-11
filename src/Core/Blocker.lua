local _, addon = ...
local eventFrame = nil

local function PauseUpdates()
    if CompactRaidFrameContainer and not CompactRaidFrameContainer:UnregisterEvent("GROUP_ROSTER_UPDATE") then
        addon:Warning("Failed to unregister event GROUP_ROSTER_UPDATE from CompactRaidFrameContainer.")
    end

    if CompactPartyFrame and not CompactPartyFrame:UnregisterEvent("GROUP_ROSTER_UPDATE") then
        addon:Warning("Failed to register event GROUP_ROSTER_UPDATE from CompactPartyFrame.")
    end
end

local function ResumeUpdates()
    if CompactRaidFrameContainer and not CompactRaidFrameContainer:RegisterEvent("GROUP_ROSTER_UPDATE") then
        addon:Warning("Failed to register event GROUP_ROSTER_UPDATE to CompactRaidFrameContainer.")
    end

    if CompactPartyFrame and not CompactPartyFrame:RegisterEvent("GROUP_ROSTER_UPDATE") then
        addon:Warning("Failed to register event GROUP_ROSTER_UPDATE to CompactPartyFrame.")
    end
end

local function OnEvent(_, event)
    if event == "PLAYER_REGEN_ENABLED" then
        ResumeUpdates()
    elseif event == "PLAYER_REGEN_DISABLED" then
        PauseUpdates()
    elseif "GROUP_ROSTER_UPDATE" and InCombatLockdown() then
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
