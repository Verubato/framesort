local _, addon = ...
local fsFrame = addon.Frame
local fsEnumerable = addon.Enumerable
local M = {}
local callbacks = {}

fsFrame.Providers.Blizzard = M
table.insert(fsFrame.Providers.All, M)

local function IsValidUnitFrame(frame)
    if not frame then
        return false
    end

    if frame:IsForbidden() then
        return false
    end

    if frame:GetTop() == nil or frame:GetLeft() == nil then
        return false
    end

    if frame.inUse ~= nil and not frame.inUse then
        return false
    end

    if frame.frameType and frame.frameType == "target" then
        -- this frame is invisible when the tain/assist hasn't got anything targeted
        -- but we still want to include this frame for spacing reasons
        return true
    end

    local unit = M:GetUnit(frame)

    if unit == nil then
        return false
    end

    -- we may have hidden the player frame, but for other frames we don't want them
    if unit == "player" or UnitIsUnit(unit, "player") then
        return true
    end

    return frame:IsVisible()
end

local function IsValidGroupFrame(frame)
    if not frame then
        return false
    end

    if frame:IsForbidden() then
        return false
    end

    if frame:GetTop() == nil or frame:GetLeft() == nil then
        return false
    end

    if not frame:IsVisible() then
        return false
    end

    return string.match(frame:GetName() or "", "CompactRaidGroup") ~= nil
end

local function GetFrames(container, filter)
    if not container or container:IsForbidden() or not container:IsVisible() then
        return {}
    end

    filter = filter or IsValidUnitFrame

    return fsEnumerable
        :From({ container:GetChildren() })
        :Where(function(frame)
            return filter(frame)
        end)
        :ToTable()
end

local function InvokeCallbacks()
    for _, callback in pairs(callbacks) do
        callback(M)
    end
end

local function OnEvent()
    InvokeCallbacks()
end

local function OnEditModeExited()
    InvokeCallbacks()
end

function M:Name()
    return "Blizzard"
end

function M:Enabled()
    if not CompactPartyFrame or not CompactRaidFrameContainer then
        return false
    end

    -- frame addons will usually disable blizzard via unsubscribing group update events
    return CompactPartyFrame:IsEventRegistered("GROUP_ROSTER_UPDATE") or CompactRaidFrameContainer:IsEventRegistered("GROUP_ROSTER_UPDATE")
end

function M:Init()
    if not M:Enabled() then
        return
    end

    local eventFrame = CreateFrame("Frame")
    eventFrame:HookScript("OnEvent", OnEvent)
    eventFrame:RegisterEvent(addon.Events.PLAYER_ENTERING_WORLD)
    eventFrame:RegisterEvent(addon.Events.GROUP_ROSTER_UPDATE)
    eventFrame:RegisterEvent(addon.Events.PLAYER_ROLES_ASSIGNED)
    eventFrame:RegisterEvent(addon.Events.UNIT_PET)

    if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
        EventRegistry:RegisterCallback(addon.Events.EditModeExit, OnEditModeExited)
        eventFrame:RegisterEvent(addon.Events.ARENA_PREP_OPPONENT_SPECIALIZATIONS)
        eventFrame:RegisterEvent(addon.Events.ARENA_OPPONENT_UPDATE)
    end
end

function M:RegisterCallback(callback)
    callbacks[#callbacks + 1] = callback
end

function M:GetUnit(frame)
    return frame.unit
end

function M:PartyFrames()
    return GetFrames(CompactPartyFrame)
end

function M:RaidFrames()
    return GetFrames(CompactRaidFrameContainer)
end

function M:RaidGroupMembers(group)
    return GetFrames(group)
end

function M:RaidGroups()
    return GetFrames(CompactRaidFrameContainer, IsValidGroupFrame)
end

function M:EnemyArenaFrames()
    return GetFrames(CompactArenaFrame)
end

function M:ShowPartyPets()
    return M:ShowRaidPets()
end

function M:ShowRaidPets()
    return CompactRaidFrameManager_GetSetting("DisplayPets")
end

function M:IsRaidGrouped()
    if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
        local raidGroupDisplayType = EditModeManagerFrame:GetSettingValue(Enum.EditModeSystem.UnitFrame, Enum.EditModeUnitFrameSystemIndices.Raid, Enum.EditModeUnitFrameSetting.RaidGroupDisplayType)
        return raidGroupDisplayType == Enum.RaidGroupDisplayType.SeparateGroupsVertical or raidGroupDisplayType == Enum.RaidGroupDisplayType.SeparateGroupsHorizontal
    end

    return CompactRaidFrameManager_GetSetting("KeepGroupsTogether")
end

function M:IsPartyHorizontalLayout()
    if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
        return EditModeManagerFrame:GetSettingValueBool(Enum.EditModeSystem.UnitFrame, Enum.EditModeUnitFrameSystemIndices.Party, Enum.EditModeUnitFrameSetting.UseHorizontalGroups)
    end

    return CompactRaidFrameManager_GetSetting("HorizontalGroups")
end

function M:IsRaidHorizontalLayout()
    if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
        local displayType = EditModeManagerFrame:GetSettingValue(Enum.EditModeSystem.UnitFrame, Enum.EditModeUnitFrameSystemIndices.Raid, Enum.EditModeUnitFrameSetting.RaidGroupDisplayType)
        return displayType == Enum.RaidGroupDisplayType.SeparateGroupsHorizontal or displayType == Enum.RaidGroupDisplayType.CombineGroupsHorizontal
    end

    return CompactRaidFrameManager_GetSetting("HorizontalGroups")
end

function M:IsUsingRaidStyleFrames()
    if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
        return EditModeManagerFrame:UseRaidStylePartyFrames()
    else
        return GetCVarBool("useCompactPartyFrames")
    end
end
