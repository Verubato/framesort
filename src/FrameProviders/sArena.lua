local _, addon = ...
local fsFrame = addon.Frame
local M = {}
local callbacks = {}

fsFrame.Providers.sArena = M
table.insert(fsFrame.Providers.All, M)

local function GetUnit(frame)
    return frame.unit
end

local function OnEvent()
    for _, callback in pairs(callbacks) do
        callback(M)
    end
end

function M:Name()
    return "sArena"
end

function M:Enabled()
    if GetAddOnEnableState(nil, "sArena Updated") == 0 then
        return false
    end

    return sArena ~= nil
end

function M:Init()
    if not M:Enabled() then
        return
    end

    local eventFrame = CreateFrame("Frame")
    eventFrame:HookScript("OnEvent", OnEvent)
    eventFrame:RegisterEvent(addon.Events.ARENA_PREP_OPPONENT_SPECIALIZATIONS)
    eventFrame:RegisterEvent(addon.Events.ARENA_OPPONENT_UPDATE)
end

function M:RegisterCallback(callback)
    callbacks[#callbacks + 1] = callback
end

function M:GetUnit(frame)
    return GetUnit(frame)
end

function M:PartyFrames()
    return {}
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
    return fsFrame:ChildUnitFrames(sArena, GetUnit)
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
