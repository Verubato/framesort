---@type string, Addon
local _, addon = ...
local wow = addon.WoW.Api
local fsFrame = addon.WoW.Frame
local fsEnumerable = addon.Collections.Enumerable
local fsUnit = addon.WoW.Unit
local fsProviders = addon.Providers
local events = addon.WoW.Api.Events
---@class BlizzardFrameProvider: FrameProvider
local M = {}
local callbacks = {}

fsProviders.Blizzard = M
table.insert(fsProviders.All, M)

local function IsValidGroupFrame(frame)
    if not frame then
        return false
    end

    if type(frame) ~= "table" then
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

local function Filter(frames, filter)
    filter = filter or function(frame)
        return fsFrame:IsValidUnitFrame(frame, function(x)
            return M:GetUnit(x)
        end)
    end

    return fsEnumerable
        :From(frames)
        :Where(function(frame)
            return filter(frame)
        end)
        :ToTable()
end

local function PartyFrames(filter)
    if M:IsUsingRaidStyleFrames() then
        local container = M:PartyContainer()
        if not container or not container.memberUnitFrames or container:IsForbidden() or not container:IsVisible() then
            return {}
        end

        local players = Filter(container.memberUnitFrames, filter)
        local pets = container.petUnitFrames and Filter(container.petUnitFrames, filter) or {}

        return fsEnumerable:From(players):Concat(pets):ToTable()
    else
        local container = wow.PartyFrame
        if not container or container:IsForbidden() or not container:IsVisible() then
            return {}
        end

        local frames = { container:GetChildren() }
        return Filter(frames, filter)
    end
end

local function EnemyArenaFrames(filter)
    local container = M:EnemyArenaContainer()
    if not container or not container.memberUnitFrames or container:IsForbidden() or not container:IsVisible() then
        return {}
    end

    return Filter(container.memberUnitFrames, filter)
end

local function RaidFrames(filter)
    local container = M:RaidContainer()
    if not container or not container.flowFrames or container:IsForbidden() or not container:IsVisible() then
        return {}
    end

    return Filter(container.flowFrames, filter)
end

local function GroupFrames(group, filter)
    if not group or not group.memberUnitFrames or group:IsForbidden() or not group:IsVisible() then
        return {}
    end

    return Filter(group.memberUnitFrames, filter)
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
    local party = M:PartyContainer()
    if party then
        -- frame addons will usually disable blizzard via unsubscribing group update events
        if party:IsVisible() or party:IsEventRegistered("GROUP_ROSTER_UPDATE") then
            return true
        end
    end

    local raid = M:RaidContainer()
    if raid then
        if raid:IsVisible() or raid:IsEventRegistered("GROUP_ROSTER_UPDATE") then
            return true
        end
    end

    return false
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
    eventFrame:RegisterEvent(events.PLAYER_ENTERING_WORLD)
    eventFrame:RegisterEvent(events.GROUP_ROSTER_UPDATE)
    eventFrame:RegisterEvent(events.PLAYER_ROLES_ASSIGNED)
    eventFrame:RegisterEvent(events.UNIT_PET)

    if wow.IsRetail() then
        wow.EventRegistry:RegisterCallback(events.EditModeExit, Update)
        eventFrame:RegisterEvent(events.ARENA_PREP_OPPONENT_SPECIALIZATIONS)
        eventFrame:RegisterEvent(events.ARENA_OPPONENT_UPDATE)
    end
end

function M:PartyContainer()
    return wow.CompactPartyFrame
end

function M:EnemyArenaContainer()
    return wow.CompactArenaFrame
end

function M:RaidContainer()
    return wow.CompactRaidFrameContainer
end

function M:RegisterCallback(callback)
    callbacks[#callbacks + 1] = callback
end

function M:GetUnit(frame)
    return frame.unit
end

function M:PartyFrames()
    return PartyFrames()
end

function M:EnemyArenaFrames()
    return EnemyArenaFrames()
end

function M:RaidFrames()
    return RaidFrames()
end

function M:RaidGroupMembers(group)
    return GroupFrames(group)
end

function M:RaidGroups()
    local container = M:RaidContainer()
    if not container or not container.flowFrames or container:IsForbidden() or not container:IsVisible() then
        return {}
    end

    return Filter(container.flowFrames, IsValidGroupFrame)
end

function M:PlayerRaidFrames()
    local isPlayer = function(frame)
        local unit = M:GetUnit(frame)
        -- a player can have more than one frame if they occupy a vehicle
        -- as both the player and vehicle pet frame are shown
        return unit and (unit == "player" or wow.UnitIsUnit(unit, "player")) and not fsUnit:IsPet(unit)
    end

    local party = PartyFrames(isPlayer)
    if #party > 0 then
        return party
    end

    if M:IsRaidGrouped() then
        local groups = M:RaidGroups()
        for _, group in ipairs(groups) do
            local members = GroupFrames(group, isPlayer)
            if #members > 0 then
                return members
            end
        end
    else
        local raid = RaidFrames(isPlayer)
        if #raid > 0 then
            return raid
        end
    end

    return {}
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

function M:IsEnemyArenaHorizontalLayout()
    return false
end

function M:IsUsingRaidStyleFrames()
    if wow.IsRetail() then
        return wow.EditModeManagerFrame:UseRaidStylePartyFrames()
    else
        return wow.GetCVarBool("useCompactPartyFrames")
    end
end
