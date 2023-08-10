local _, addon = ...
local fsFrame = addon.Frame

local M = {}

fsFrame.Providers.GladiusEx = M
table.insert(fsFrame.Providers.All, M)

local function GetUnit(frame)
    return frame.unit
end

function M:Name()
    return "GladiusEx"
end

function M:Enabled()
    return GetAddOnEnableState(nil, "GladiusEx") ~= 0
end

function M:PartyFramesEnabled()
    return GladiusExPartyFrame and not GladiusExPartyFrame:IsForbidden() and GladiusExPartyFrame:IsVisible()
end

function M:RaidFramesEnabled()
    return false
end

function M:EnemyArenaFramesEnabled()
    return GladiusExArenaFrame and not GladiusExArenaFrame:IsForbidden() and GladiusExArenaFrame:IsVisible()
end

function M:GetUnit(frame)
    return GetUnit(frame)
end

function M:PartyFrames()
    return fsFrame:ChildUnitFrames(GladiusExPartyFrame, GetUnit)
end

function M:RaidFrames()
    return {}
end

function M:RaidGroupMembers(_)
    return {}
end

function M:RaidGroups()
    return {}
end

function M:EnemyArenaFrames()
    return fsFrame:ChildUnitFrames(GladiusExArenaFrame, GetUnit)
end

function M:ShowPartyPets()
    return false
end

function M:ShowRaidPets()
    return false
end

function M:IsRaidGrouped()
    return false
end

function M:IsPartyHorizontalLayout()
    return false
end

function M:IsRaidHorizontalLayout()
    return false
end
