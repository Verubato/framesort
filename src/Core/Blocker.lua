local _, addon = ...
local eventFrame = nil

local function RegisterEvent(frame, event)
    if not frame:RegisterEvent(event) then
        addon:Warning(string.format("Failed to register event %s to %s.", event, frame:GetName()))
    end
end

local function UnregisterEvent(frame, event)
    if not frame:UnregisterEvent(event) then
        addon:Warning(string.format("Failed to unregister event %s from %s.", event, frame:GetName()))
    end
end

local function PauseUpdates()
    if CompactRaidFrameContainer then
        UnregisterEvent(CompactRaidFrameContainer, "GROUP_ROSTER_UPDATE")
        UnregisterEvent(CompactRaidFrameContainer, "UNIT_PET")
    end

    if CompactPartyFrame then
        UnregisterEvent(CompactPartyFrame, "GROUP_ROSTER_UPDATE")
        UnregisterEvent(CompactPartyFrame, "UNIT_PET")
    end
end

local function ResumeUpdates()
    if CompactRaidFrameContainer then
        RegisterEvent(CompactRaidFrameContainer, "GROUP_ROSTER_UPDATE")
        RegisterEvent(CompactRaidFrameContainer, "UNIT_PET")
    end

    if CompactPartyFrame then
        RegisterEvent(CompactPartyFrame, "GROUP_ROSTER_UPDATE")
        RegisterEvent(CompactPartyFrame, "UNIT_PET")
    end
end

local function OnEvent(_, event)
    if event == "PLAYER_REGEN_ENABLED" then
        ResumeUpdates()
    elseif event == "PLAYER_REGEN_DISABLED" then
        PauseUpdates()
    end
end

---Initialises the in-combat raid frame layout blocking module.
function addon:InitCombatBlocking()
    eventFrame = CreateFrame("Frame")
    eventFrame:HookScript("OnEvent", OnEvent)
    eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
    eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
end
