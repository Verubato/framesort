local _, addon = ...
local fsEnumerable = addon.Enumerable
local fsUnit = addon.Unit

local M = {}

addon.FrameProviders.Blizzard = M
table.insert(addon.FrameProviders.All, M)

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

    if M:GetUnit(frame) == nil then
        return false
    end

    if not frame:IsVisible() then
        return false
    end

    return true
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

local function Find(filter)
    local party = GetFrames(CompactPartyFrame, filter)
    local raid = GetFrames(CompactRaidFrameContainer, filter)
    local groups = M:RaidGroups()
    local groupedMembers = fsEnumerable
        :From(groups)
        :Map(function(group)
            return GetFrames(group, filter)
        end)
        :Flatten()
        :ToTable()

    return fsEnumerable:From(party):Concat(raid):Concat(groupedMembers):ToTable()
end

local function IsEnabled(container)
    return container and not container:IsForbidden() and container:IsVisible() and container:IsEventRegistered("GROUP_ROSTER_UPDATE")
end

function M:Name()
    return "Blizzard"
end

function M:Enabled()
    if not CompactPartyFrame or not CompactRaidFrameContainer then
        return false
    end

    -- frame addons will usually disable blizzard via unsubscribing group update events
    -- ShadowedUnitFrames disables this event
    if not UIParent:IsEventRegistered("GROUP_ROSTER_UPDATE") then
        return false
    end

    if not CompactPartyFrame:IsEventRegistered("GROUP_ROSTER_UPDATE") then
        return false
    end

    if not CompactRaidFrameContainer:IsEventRegistered("GROUP_ROSTER_UPDATE") then
        return false
    end

    return UIParent and UIParent:IsEventRegistered("GROUP_ROSTER_UPDATE")
end

function M:PartyFramesEnabled()
    return IsEnabled(CompactPartyFrame)
end

function M:RaidFramesEnabled()
    return IsEnabled(CompactRaidFrameContainer)
end

function M:EnemyArenaFramesEnabled()
    local enabled = GetCVarBool("showArenaEnemyFrames")
    return enabled and IsEnabled(CompactArenaFrame)
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
    local groups, _ = GetFrames(CompactRaidFrameContainer, IsValidGroupFrame)
    return groups
end

function M:EnemyArenaFrames()
    return GetFrames(CompactArenaFrame)
end

function M:PlayerRaidFrame()
    local players = Find(function(frame)
        local unit = M:GetUnit(frame)
        -- a player can have more than one frame if they occupy a vehicle
        -- as both the player and vehicle pet frame are shown
        return unit and UnitIsUnit("player", unit) and not fsUnit:IsPet(unit)
    end)

    if #players == 1 then
        return players[1]
    end

    return fsEnumerable:From(players):First(function(x)
        return x:IsVisible()
    end)
end

function M:ShowPartyPets()
    return M:ShowRaidPets()
end

function M:ShowRaidPets()
    return CompactRaidFrameManager_GetSetting("DisplayPets")
end

function M:PartyGrouped()
    if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
        return false
    end

    return CompactRaidFrameManager_GetSetting("KeepGroupsTogether")
end

function M:RaidGrouped()
    if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
        local raidGroupDisplayType = EditModeManagerFrame:GetSettingValue(Enum.EditModeSystem.UnitFrame, Enum.EditModeUnitFrameSystemIndices.Raid, Enum.EditModeUnitFrameSetting.RaidGroupDisplayType)
        return raidGroupDisplayType == Enum.RaidGroupDisplayType.SeparateGroupsVertical or raidGroupDisplayType == Enum.RaidGroupDisplayType.SeparateGroupsHorizontal
    end

    return CompactRaidFrameManager_GetSetting("KeepGroupsTogether")
end

function M:PartyHorizontalLayout()
    if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
        return EditModeManagerFrame:GetSettingValueBool(Enum.EditModeSystem.UnitFrame, Enum.EditModeUnitFrameSystemIndices.Party, Enum.EditModeUnitFrameSetting.UseHorizontalGroups)
    end

    return CompactRaidFrameManager_GetSetting("HorizontalGroups")
end

function M:RaidHorizontalLayout()
    if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
        local displayType = EditModeManagerFrame:GetSettingValue(Enum.EditModeSystem.UnitFrame, Enum.EditModeUnitFrameSystemIndices.Raid, Enum.EditModeUnitFrameSetting.RaidGroupDisplayType)
        return displayType == Enum.RaidGroupDisplayType.SeparateGroupsHorizontal or displayType == Enum.RaidGroupDisplayType.CombineGroupsHorizontal
    end

    return CompactRaidFrameManager_GetSetting("HorizontalGroups")
end

function M:UsingRaidStyleFrames()
    if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
        return EditModeManagerFrame:UseRaidStylePartyFrames()
    else
        return GetCVarBool("useCompactPartyFrames")
    end
end
