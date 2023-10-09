---@type string, Addon
local _, addon = ...
local wow = addon.WoW.Api
local fsFrame = addon.WoW.Frame
local fsScheduler = addon.Scheduling.Scheduler
local fsProviders = addon.Providers
local events = addon.WoW.Api.Events
local M = {}
local callbacks = {}

fsProviders.GladiusEx = M
table.insert(fsProviders.All, M)

local function GetUnit(frame)
    return frame.unit
end

local function Update()
    for _, callback in pairs(callbacks) do
        callback(M)
    end
end

local function UpdateNextFrame()
    -- wait for GladiusEx to update their frames before we perform a sort
    fsScheduler:RunNextFrame(Update)
end

function M:Name()
    return "GladiusEx"
end

function M:Enabled()
    return wow.IsRetail() and wow.GetAddOnEnableState(nil, "GladiusEx") ~= 0
end

function M:Init()
    if not M:Enabled() then
        return
    end

    if #callbacks > 0 then
        callbacks = {}
    end

    local eventFrame = wow.CreateFrame("Frame")
    eventFrame:HookScript("OnEvent", UpdateNextFrame)
    eventFrame:RegisterEvent(events.PLAYER_ENTERING_WORLD)
    eventFrame:RegisterEvent(events.GROUP_ROSTER_UPDATE)
    eventFrame:RegisterEvent(events.PLAYER_ROLES_ASSIGNED)
    eventFrame:RegisterEvent(events.UNIT_PET)

    if wow.IsRetail() then
        eventFrame:RegisterEvent(events.ARENA_PREP_OPPONENT_SPECIALIZATIONS)
        eventFrame:RegisterEvent(events.ARENA_OPPONENT_UPDATE)
    end
end

function M:RegisterCallback(callback)
    callbacks[#callbacks + 1] = callback
end

function M:GetUnit(frame)
    return GetUnit(frame)
end

function M:PartyContainer()
    ---@diagnostic disable-next-line: undefined-global
    return GladiusExPartyFrame
end

function M:EnemyArenaContainer()
    ---@diagnostic disable-next-line: undefined-global
    return GladiusExArenaFrame
end

function M:RaidContainer()
    return nil
end

function M:PartyFrames()
    return fsFrame:ChildUnitFrames(M:PartyContainer(), GetUnit)
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
    return fsFrame:ChildUnitFrames(M:EnemyArenaContainer(), GetUnit)
end

function M:IsRaidGrouped()
    return false
end
