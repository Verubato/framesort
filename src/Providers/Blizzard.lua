---@type string, Addon
local _, addon = ...
---@type WoW
local wow = addon.WoW
local fsFrame = addon.Frame
local fsEnumerable = addon.Enumerable
local fsUnit = addon.Unit
local M = {}
local callbacks = {}

fsFrame.Providers.Blizzard = M
table.insert(fsFrame.Providers.All, M)

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

    filter = filter or function(frame)
        return fsFrame:IsValidUnitFrame(frame, function(x)
            return M:GetUnit(x)
        end)
    end

    return fsEnumerable
        :From({ container:GetChildren() })
        :Where(function(frame)
            return filter(frame)
        end)
        :ToTable()
end

local function Update()
    for _, callback in pairs(callbacks) do
        callback(M)
    end
end

function M:Name()
    return "Blizzard"
end

function M:Enabled()
    local enabled = false

    if wow.CompactPartyFrame then
        -- frame addons will usually disable blizzard via unsubscribing group update events
        enabled = wow.CompactPartyFrame:IsEventRegistered("GROUP_ROSTER_UPDATE")
    end

    if wow.CompactRaidFrameContainer then
        enabled = enabled or wow.CompactRaidFrameContainer:IsEventRegistered("GROUP_ROSTER_UPDATE")
    end

    return enabled
end

function M:Init()
    if not M:Enabled() then
        return
    end

    if #callbacks > 0 then
        callbacks = {}
    end

    local eventFrame = wow.CreateFrame("Frame")
    eventFrame:HookScript("OnEvent", Update)
    eventFrame:RegisterEvent(addon.Events.PLAYER_ENTERING_WORLD)
    eventFrame:RegisterEvent(addon.Events.GROUP_ROSTER_UPDATE)
    eventFrame:RegisterEvent(addon.Events.PLAYER_ROLES_ASSIGNED)
    eventFrame:RegisterEvent(addon.Events.UNIT_PET)

    if wow.IsRetail() then
        wow.EventRegistry:RegisterCallback(addon.Events.EditModeExit, Update)
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
    return GetFrames(wow.CompactPartyFrame)
end

function M:RaidFrames()
    return GetFrames(wow.CompactRaidFrameContainer)
end

function M:RaidGroupMembers(group)
    return GetFrames(group)
end

function M:RaidGroups()
    return GetFrames(wow.CompactRaidFrameContainer, IsValidGroupFrame)
end

function M:EnemyArenaFrames()
    return GetFrames(wow.CompactArenaFrame)
end

function M:PlayerRaidFrames()
    local isPlayer = function(frame)
        local unit = M:GetUnit(frame)
        -- a player can have more than one frame if they occupy a vehicle
        -- as both the player and vehicle pet frame are shown
        return unit and (unit == "player" or wow.UnitIsUnit(unit, "player")) and not fsUnit:IsPet(unit)
    end

    local party = GetFrames(wow.CompactPartyFrame, isPlayer)
    if #party > 0 then
        return party
    end

    if M:IsRaidGrouped() then
        local groups = M:RaidGroups()
        for _, group in ipairs(groups) do
            local members = GetFrames(group, isPlayer)
            if #members > 0 then
                return members
            end
        end
    else
        local raid = GetFrames(wow.CompactRaidFrameContainer, isPlayer)
        if #raid > 0 then
            return raid
        end
    end

    return {}
end

function M:ShowPartyPets()
    return M:ShowRaidPets()
end

function M:ShowRaidPets()
    return wow.CompactRaidFrameManager_GetSetting("DisplayPets")
end

function M:IsRaidGrouped()
    if wow.IsRetail() then
        local raidGroupDisplayType =
            wow.EditModeManagerFrame:GetSettingValue(wow.Enum.EditModeSystem.UnitFrame, wow.Enum.EditModeUnitFrameSystemIndices.Raid, wow.Enum.EditModeUnitFrameSetting.RaidGroupDisplayType)
        return raidGroupDisplayType == wow.Enum.RaidGroupDisplayType.SeparateGroupsVertical or raidGroupDisplayType == wow.Enum.RaidGroupDisplayType.SeparateGroupsHorizontal
    end

    return wow.CompactRaidFrameManager_GetSetting("KeepGroupsTogether")
end

function M:IsPartyHorizontalLayout()
    if wow.IsRetail() then
        return wow.EditModeManagerFrame:GetSettingValueBool(wow.Enum.EditModeSystem.UnitFrame, wow.Enum.EditModeUnitFrameSystemIndices.Party, wow.Enum.EditModeUnitFrameSetting.UseHorizontalGroups)
    end

    return wow.CompactRaidFrameManager_GetSetting("HorizontalGroups")
end

function M:IsRaidHorizontalLayout()
    if wow.IsRetail() then
        local displayType =
            wow.EditModeManagerFrame:GetSettingValue(wow.Enum.EditModeSystem.UnitFrame, wow.Enum.EditModeUnitFrameSystemIndices.Raid, wow.Enum.EditModeUnitFrameSetting.RaidGroupDisplayType)
        return displayType == wow.Enum.RaidGroupDisplayType.SeparateGroupsHorizontal or displayType == wow.Enum.RaidGroupDisplayType.CombineGroupsHorizontal
    end

    return wow.CompactRaidFrameManager_GetSetting("HorizontalGroups")
end

function M:IsUsingRaidStyleFrames()
    if wow.IsRetail() then
        return wow.EditModeManagerFrame:UseRaidStylePartyFrames()
    else
        return wow.GetCVarBool("useCompactPartyFrames")
    end
end
